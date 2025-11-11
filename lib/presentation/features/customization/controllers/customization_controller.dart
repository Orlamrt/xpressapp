import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final MediaApiDatasource mediaApiDatasource;
  final LocalAssetStorage localAssetStorage;
  final LocalStorage localStorage;
  final ImagePicker _imagePicker;

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
  final Map<String, List<CustomPictogram>> _customPictograms = {};

  bool _initialized = false;

  Future<void> initCustomization({bool promptUser = true}) async {
    if (_initialized) return;
    _initialized = true;

    await _loadCustomPictograms();

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

  Future<void> addCustomPictogram(String parentPath) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return;
      }

      final String? suggestedName = _extractBaseName(file);
      final String? providedName = await _promptForCustomName(initialValue: suggestedName);
      if (providedName == null || providedName.trim().isEmpty) {
        return;
      }

      final String normalizedParent = MediaPathMapper.normalize(parentPath);
      final String sanitizedFileName = _sanitizeFileName(providedName);
      if (sanitizedFileName.isEmpty) {
        Get.snackbar(
          'Nombre inválido',
          'Intenta con un nombre diferente para el pictograma.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final String extension = _detectExtension(file);
      final String joinedPath = _joinPaths(normalizedParent, '$sanitizedFileName$extension');
      final String normalizedPath = MediaPathMapper.normalize(joinedPath);

      if (_customPictogramExists(normalizedPath)) {
        Get.snackbar(
          'Pictograma existente',
          'Ya existe un pictograma con ese nombre en esta categoría.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final bytes = await file.readAsBytes();
      await localAssetStorage.saveImage(normalizedPath, bytes);

      final pictogram = CustomPictogram(
        id: _generateId(),
        name: providedName.trim(),
        relativePath: normalizedPath,
        parentPath: normalizedParent,
      );

      _addCustomPictogramToCache(pictogram);
      await _persistCustomPictograms();

      _localCache.add(MediaPathMapper.normalize(normalizedPath));
      _providerCache.remove(MediaPathMapper.normalize(normalizedPath));

      treeRefreshToken.value++;
      update();

      Get.snackbar(
        'Pictograma agregado',
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
    final normalized = MediaPathMapper.normalize(parentPath);
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

  Future<void> _loadCustomPictograms() async {
    final stored = await localStorage.getCustomPictograms();
    _customPictograms.clear();

    for (final pictogram in stored) {
      final normalizedParent = MediaPathMapper.normalize(pictogram.parentPath);
      final normalizedPath = MediaPathMapper.normalize(pictogram.relativePath);
      final normalized = pictogram.copyWith(
        parentPath: normalizedParent,
        relativePath: normalizedPath,
      );

      final list = _customPictograms.putIfAbsent(normalizedParent, () => []);
      list.add(normalized);

      if (await localAssetStorage.exists(normalizedPath)) {
        _localCache.add(normalizedPath);
      }
    }

    _sortCustomLists();
  }

  Future<void> _persistCustomPictograms() async {
    final all = _customPictograms.values.expand((list) => list).toList();
    await localStorage.saveCustomPictograms(all);
  }

  void _addCustomPictogramToCache(CustomPictogram pictogram) {
    final normalizedParent = MediaPathMapper.normalize(pictogram.parentPath);
    final normalizedPath = MediaPathMapper.normalize(pictogram.relativePath);
    final normalized = pictogram.copyWith(
      parentPath: normalizedParent,
      relativePath: normalizedPath,
    );

    final list = _customPictograms.putIfAbsent(normalizedParent, () => []);
    list.removeWhere(
      (existing) => MediaPathMapper.normalize(existing.relativePath) == normalizedPath,
    );
    list.add(normalized);

    _sortCustomLists();
  }

  bool _customPictogramExists(String relativePath) {
    final normalized = MediaPathMapper.normalize(relativePath);
    if (PictogramPaths.values.contains(normalized)) {
      return true;
    }
    return _customPictograms.values.any(
      (list) => list.any(
        (p) => MediaPathMapper.normalize(p.relativePath) == normalized,
      ),
    );
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
    final ext = p.extension(source).toLowerCase();
    if (ext.isEmpty) {
      return '.png';
    }
    return ext;
  }

  String? _extractBaseName(XFile file) {
    final source = file.name.isNotEmpty ? file.name : file.path;
    if (source.isEmpty) {
      return null;
    }
    return p.basenameWithoutExtension(source);
  }

  String _joinPaths(String parent, String child) {
    final joined = p.join(parent, child);
    return joined.replaceAll('\\', '/');
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  void _sortCustomLists() {
    for (final list in _customPictograms.values) {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
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
