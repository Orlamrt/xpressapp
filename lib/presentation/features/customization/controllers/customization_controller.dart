import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/pictogram_paths.dart';
import '../../../../core/utils/media_path_mapper.dart';
import '../../../../data/datasources/local/local_asset_storage.dart';
import '../../../../data/datasources/local/local_storage.dart';
import '../../../../data/datasources/remote/media_api_datasource.dart';
import '../../../../data/models/custom_pictogram.dart';

enum PictogramDownloadStatus { alreadyDownloaded, success, failure }

class CustomizationController extends GetxController {
  CustomizationController({
    required this.mediaApiDatasource,
    required this.localAssetStorage,
    required this.localStorage,
    ImagePicker? imagePicker,
    ImageCropper? imageCropper,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
        _imageCropper = imageCropper ?? ImageCropper();

  final MediaApiDatasource mediaApiDatasource;
  final LocalAssetStorage localAssetStorage;
  final LocalStorage localStorage;
  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;

  final RxBool isDownloading = false.obs;
  final RxInt downloadedCount = 0.obs;
  final RxInt totalCount = 0.obs;
  final RxBool downloadFailed = false.obs;
  final RxBool assetsReady = false.obs;
  final RxInt treeRefreshToken = 0.obs;

  static const String _downloadedKey = 'custom_assets_downloaded';
  static const String _promptedKey = 'asked_for_custom_assets';

  final Map<String, ImageProvider> _providerCache = {};
  final Set<String> _localCache = <String>{};
  final RxMap<String, List<CustomPictogram>> _customPictograms =
      <String, List<CustomPictogram>>{}.obs;

  late final List<String> _defaultDestinationFolders =
      _buildDefaultDestinationFolders();

  bool _initialized = false;

  Future<void> initCustomization({bool promptUser = true}) async {
    if (_initialized) return;
    _initialized = true;

    await loadPictogramsFromStorage();

    final bool alreadyDownloaded = localStorage.getBool(_downloadedKey) ?? false;
    if (alreadyDownloaded) {
      assetsReady.value = true;
      await _hydrateLocalCache();
      return;
    }

    if (!promptUser) {
      return;
    }

    final bool hasBeenPrompted = localStorage.getBool(_promptedKey) ?? false;
    if (!hasBeenPrompted) {
      final bool shouldDownload = await _askUserForDownload();
      await localStorage.saveBool(_promptedKey, true);
      if (shouldDownload) {
        await downloadAllAssets();
      }
    }
  }

  bool get hasDownloadedPictograms =>
      localStorage.getBool(_downloadedKey) ?? false;

  List<String> get availableDestinationFolders {
    final Set<String> folders = {..._defaultDestinationFolders};
    folders.addAll(
      _customPictograms.keys
          .map(_stripImagesPrefix)
          .map(_ensureTrailingSlash),
    );
    final List<String> sorted = folders.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return List<String>.unmodifiable(sorted);
  }

  Future<void> refreshDownloadStatus() async {
    final downloaded = hasDownloadedPictograms;
    assetsReady.value = downloaded;
    if (downloaded) {
      await _hydrateLocalCache();
    }
  }

  Future<PictogramDownloadStatus> downloadPictogramsIfNeeded({
    bool showProgressDialog = true,
    bool showFeedback = true,
  }) async {
    if (hasDownloadedPictograms) {
      assetsReady.value = true;
      await _hydrateLocalCache();
      return PictogramDownloadStatus.alreadyDownloaded;
    }

    await downloadAllAssets(
      showProgressDialog: showProgressDialog,
      showFeedback: showFeedback,
    );

    if (downloadFailed.value) {
      return PictogramDownloadStatus.failure;
    }
    return PictogramDownloadStatus.success;
  }

  Future<void> downloadAllAssets({
    bool showProgressDialog = true,
    bool showFeedback = true,
  }) async {
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadFailed.value = false;
    downloadedCount.value = 0;
    totalCount.value = PictogramPaths.values.length;

    if (showProgressDialog) {
      _showProgressDialog();
    }

    for (final relativePath in PictogramPaths.values) {
      try {
        final bytes = await mediaApiDatasource.downloadImage(relativePath);
        await localAssetStorage.saveImage(relativePath, bytes);
        final normalized = MediaPathMapper.normalize(relativePath);
        _localCache.add(normalized);
        _providerCache.remove(normalized);
        downloadedCount.value++;
      } catch (e) {
        downloadFailed.value = true;
        debugPrint('❌ Error descargando $relativePath: $e');
      }
    }

    isDownloading.value = false;
    if (showProgressDialog && Get.isDialogOpen == true) {
      Get.back();
    }

    if (!downloadFailed.value) {
      await localStorage.saveBool(_downloadedKey, true);
      assetsReady.value = true;
      if (showFeedback) {
        Get.snackbar(
          'Descarga exitosa',
          'Pictogramas descargados correctamente.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      if (showFeedback) {
        Get.snackbar(
          'Error',
          'Ocurrió un error al descargar los pictogramas. Intenta nuevamente.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> replaceImage(String relativePath) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      await localAssetStorage.saveImage(relativePath, bytes);
      final normalized = MediaPathMapper.normalize(relativePath);
      _localCache.add(normalized);
      _providerCache.remove(normalized);
      update();
      Get.snackbar(
        'Imagen actualizada',
        'El cambio aplica solo en este dispositivo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la imagen seleccionada.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addCustomPictogramToFolder(String parentPath) async {
    try {
      final XFile? file =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return;
      }

      final List<PlatformUiSettings> cropperSettings = [];
      if (GetPlatform.isAndroid) {
        cropperSettings.add(
           AndroidUiSettings(
            toolbarTitle: 'Ajustar pictograma',
            lockAspectRatio: true,
            hideBottomControls: true,
          ),
        );
      }
      if (GetPlatform.isIOS) {
        cropperSettings.add(
           IOSUiSettings(
            title: 'Ajustar pictograma',
            aspectRatioLockEnabled: true,
          ),
        );
      }
            if (GetPlatform.isWeb && Get.context != null) {
        cropperSettings.add(
          WebUiSettings(
            context: Get.context!,
            // Si tu versión soporta estilos, puedes usar algo como:
            // presentStyle: CropperPresentStyle.dialog,
            // pero lo dejamos comentado para evitar el error de tipo indefinido.
            // Opciones típicas disponibles según la versión:
            // enableExif: true,
            // enableZoom: true,
            // showZoomer: true,
          ),
        );
      }


      final CroppedFile? cropped = await _imageCropper.cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.png,
        uiSettings: cropperSettings,
      );

      if (cropped == null) {
        return;
      }

      final String? suggestedName = _extractBaseName(file);
      final String? providedName =
          await _promptForCustomName(initialValue: suggestedName);
      if (providedName == null || providedName.trim().isEmpty) {
        return;
      }

      final String folderKey = _normalizeFolderKey(parentPath);
      final String sanitizedFileName = _sanitizeFileName(providedName);
      if (sanitizedFileName.isEmpty) {
        Get.snackbar(
          'Nombre inválido',
          'Intenta con un nombre diferente para el pictograma.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final String extension =
          _detectExtensionFromPath(cropped.path.isNotEmpty ? cropped.path : file.path);
      final String relativePath = '$folderKey$sanitizedFileName$extension';
      final String normalizedRelativePath =
          MediaPathMapper.normalize(relativePath);

      final CustomPictogram? existing =
          _findCustomPictogramByRelativePath(relativePath);
      final bool reservedPath =
          _isReservedPictogramPath(relativePath) && existing == null;

      if (reservedPath) {
        Get.snackbar(
          'Pictograma existente',
          'Ya existe un pictograma oficial con ese nombre en esta categoría.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final bytes = await cropped.readAsBytes();
      await localAssetStorage.saveImage(normalizedRelativePath, bytes);

      final pictogram = CustomPictogram(
        id: existing?.id ?? _generateId(),
        name: providedName.trim(),
        relativePath: relativePath,
        parentPath: folderKey,
        createdAt: existing?.createdAt,
      );

      _addCustomPictogramToCache(pictogram);
      await _persistCustomPictograms();
      await loadPictogramsFromStorage();

      _localCache.add(normalizedRelativePath);
      _providerCache.remove(normalizedRelativePath);

      Get.snackbar(
        existing == null ? 'Pictograma agregado' : 'Pictograma actualizado',
        'Disponible solo en este dispositivo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo agregar el pictograma.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addCustomPictogram(String parentPath) async {
    await addCustomPictogramToFolder(parentPath);
  }

  Future<ImageProvider> getImageProvider(String relativePath) async {
    final normalized = MediaPathMapper.normalize(relativePath);

    if (_providerCache.containsKey(normalized)) {
      return _providerCache[normalized]!;
    }

    if (_localCache.contains(normalized) || await localAssetStorage.exists(normalized)) {
      final localFile = await localAssetStorage.getLocalImage(normalized);
      if (localFile != null) {
        final provider = FileImage(localFile);
        _providerCache[normalized] = provider;
        _localCache.add(normalized);
        return provider;
      }
    }

    final url = mediaApiDatasource.buildRemoteUrl(normalized);
    final provider = NetworkImage(url);
    _providerCache[normalized] = provider;
    return provider;
  }

  String buildRemoteUrl(String relativePath) {
    return mediaApiDatasource.buildRemoteUrl(relativePath);
  }

  List<CustomPictogram> getCustomPictogramsForParent(String parentPath) {
    final normalized = _normalizeFolderKey(parentPath);
    final list = _customPictograms[normalized];
    if (list == null) {
      return const [];
    }
    return List<CustomPictogram>.unmodifiable(list);
  }

  Future<void> _hydrateLocalCache() async {
    for (final path in PictogramPaths.values) {
      if (await localAssetStorage.exists(path)) {
        _localCache.add(MediaPathMapper.normalize(path));
      }
    }
  }

  Future<void> loadPictogramsFromStorage() async {
    final stored = await localStorage.getCustomPictograms();
    final Map<String, List<CustomPictogram>> grouped = {};
    final Set<String> discoveredLocalPaths = {};

    for (final pictogram in stored) {
      final folderKey = _normalizeFolderKey(pictogram.parentPath);
      final relativePath = _normalizeRelativeFilePath(pictogram.relativePath);
      final normalized = pictogram.copyWith(
        parentPath: folderKey,
        relativePath: relativePath,
      );

      final list = grouped.putIfAbsent(folderKey, () => <CustomPictogram>[]);
      list.add(normalized);

      if (await localAssetStorage.exists(relativePath)) {
        discoveredLocalPaths.add(MediaPathMapper.normalize(relativePath));
      }
    }

    _customPictograms.assignAll(grouped);
    _sortCustomLists();
    _customPictograms.refresh();

    if (discoveredLocalPaths.isNotEmpty) {
      _localCache.addAll(discoveredLocalPaths);
    }

    treeRefreshToken.value++;
    update();
  }

  Future<void> _persistCustomPictograms() async {
    final all = _customPictograms.values.expand((list) => list).toList();
    await localStorage.saveCustomPictograms(all);
  }

  void _addCustomPictogramToCache(CustomPictogram pictogram) {
    final folderKey = _normalizeFolderKey(pictogram.parentPath);
    final relativePath = _normalizeRelativeFilePath(pictogram.relativePath);
    final normalized = pictogram.copyWith(
      parentPath: folderKey,
      relativePath: relativePath,
    );

    final List<CustomPictogram> current =
        List<CustomPictogram>.from(_customPictograms[folderKey] ?? const []);
    final int existingIndex = current.indexWhere(
      (existing) =>
          MediaPathMapper.normalize(existing.relativePath) ==
              MediaPathMapper.normalize(relativePath) ||
          existing.id == normalized.id,
    );

    if (existingIndex >= 0) {
      final previous = current[existingIndex];
      current[existingIndex] =
          normalized.copyWith(createdAt: previous.createdAt);
    } else {
      current.add(normalized);
    }

    current.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    _customPictograms[folderKey] = current;
    _customPictograms.refresh();
  }

  Future<String?> _promptForCustomName({String? initialValue}) async {
    final textController = TextEditingController(text: initialValue ?? '');
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Nombre del pictograma'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Escribe un nombre',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: textController.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    final value = result?.trim();
    textController.dispose();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  String _sanitizeFileName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final withoutInvalid = trimmed.replaceAll(RegExp(r'[\/:*?"<>|]'), '');
    return withoutInvalid.replaceAll(RegExp(r'\s+'), '_');
  }

  String _detectExtension(XFile file) {
    final source = file.name.isNotEmpty ? file.name : file.path;
    return _detectExtensionFromPath(source);
  }

  String? _extractBaseName(XFile file) {
    final source = file.name.isNotEmpty ? file.name : file.path;
    if (source.isEmpty) {
      return null;
    }
    return p.basenameWithoutExtension(source);
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  void _sortCustomLists() {
    for (final entry in _customPictograms.entries.toList()) {
      final List<CustomPictogram> sorted = List<CustomPictogram>.from(entry.value)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _customPictograms[entry.key] = sorted;
    }
  }

  String _detectExtensionFromPath(String sourcePath) {
    final ext = p.extension(sourcePath).toLowerCase();
    if (ext.isEmpty) {
      return '.png';
    }
    return ext;
  }

  String _normalizeFolderKey(String parentPath) {
    String sanitized = parentPath.trim().replaceAll('\\', '/');
    if (sanitized.isEmpty) {
      throw ArgumentError('parentPath cannot be empty');
    }
    if (sanitized.startsWith('/')) {
      sanitized = sanitized.substring(1);
    }
    if (!sanitized.endsWith('/')) {
      sanitized = '$sanitized/';
    }
    if (sanitized.startsWith('assets/')) {
      sanitized = sanitized.substring('assets/'.length);
    }
    if (!sanitized.startsWith('images/')) {
      sanitized = 'images/$sanitized';
    }
    return _ensureTrailingSlash(sanitized);
  }

  String _normalizeRelativeFilePath(String relativePath) {
    final normalized = _stripAssetsPrefix(MediaPathMapper.normalize(relativePath));
    return normalized.startsWith('/') ? normalized.substring(1) : normalized;
  }

  String _stripAssetsPrefix(String path) {
    final normalized = MediaPathMapper.normalize(path);
    if (normalized.startsWith('assets/')) {
      return normalized.substring('assets/'.length);
    }
    return normalized;
  }

  String _stripImagesPrefix(String path) {
    if (path.startsWith('images/')) {
      return path.substring('images/'.length);
    }
    return path;
  }

  String _ensureTrailingSlash(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value.endsWith('/') ? value : '$value/';
  }

  bool _isReservedPictogramPath(String relativePath) {
    final normalized = MediaPathMapper.normalize(relativePath);
    return PictogramPaths.values.any(
      (path) => MediaPathMapper.normalize(path) == normalized,
    );
  }

  CustomPictogram? _findCustomPictogramByRelativePath(String relativePath) {
    final normalized = MediaPathMapper.normalize(relativePath);
    for (final list in _customPictograms.values) {
      for (final pictogram in list) {
        if (MediaPathMapper.normalize(pictogram.relativePath) == normalized) {
          return pictogram;
        }
      }
    }
    return null;
  }

  List<String> _buildDefaultDestinationFolders() {
    final Set<String> folders = {};

    for (final rawPath in PictogramPaths.values) {
      final stripped = _stripAssetsPrefix(MediaPathMapper.normalize(rawPath));
      final segments = stripped.split('/');
      if (segments.length <= 1) {
        continue;
      }

      String current = '';
      for (int i = 0; i < segments.length - 1; i++) {
        final segment = segments[i];
        if (segment.isEmpty) {
          continue;
        }
        current = current.isEmpty ? segment : '$current/$segment';
        if (current == 'images') {
          continue;
        }
        final folder = _stripImagesPrefix(current);
        if (folder.isEmpty) {
          continue;
        }
        folders.add(_ensureTrailingSlash(folder));
      }
    }

    final List<String> sorted = folders.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return List<String>.unmodifiable(sorted);
  }

  Future<bool> _askUserForDownload() async {
    final result = await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Descargar pictogramas'),
          content: const Text(
            'Para poder personalizar los pictogramas necesitamos descargarlos en el dispositivo. ¿Quieres hacerlo ahora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Más tarde'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Descargar'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  void _showProgressDialog() {
    if (Get.isDialogOpen == true) {
      return;
    }
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Obx(
          () {
            final total = totalCount.value;
            final completed = downloadedCount.value;
            final progress = total == 0 ? 0.0 : completed / total;
            return AlertDialog(
              title: const Text('Descargando pictogramas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: total == 0 ? null : progress),
                  const SizedBox(height: 12),
                  Text('$completed / $total archivos'),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }
}
