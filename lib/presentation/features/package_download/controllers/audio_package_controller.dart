import 'package:get/get.dart';
import 'package:xpressatec/data/datasources/local/audio_package_manager.dart';
import 'package:xpressatec/core/config/routes.dart';

class AudioPackageController extends GetxController {
  final AudioPackageManager _packageManager;

  AudioPackageController({required AudioPackageManager packageManager})
      : _packageManager = packageManager;

  // Observable state
  final RxBool isDownloading = false.obs;
  final RxBool isChecking = true.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxString currentWord = ''.obs;
  final RxInt currentFile = 0.obs;
  final RxInt totalFiles = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxList<String> availableAssistants = <String>[].obs;
  final RxString selectedAssistant = 'emmanuel'.obs;
  final RxBool hasDownloaded = false.obs;
  final RxBool downloadFailed = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshStatus();
  }

  Future<void> refreshStatus() async {
    try {
      isChecking.value = true;
      downloadFailed.value = false;
      errorMessage.value = '';

      hasDownloaded.value = await _packageManager.isPackageDownloaded();

      await _checkAvailableAssistants();
    } catch (e) {
      print('❌ Error refreshing audio package status: $e');
      errorMessage.value = 'Error al verificar el estado de los paquetes de audio';
    } finally {
      isChecking.value = false;
    }
  }

  /// Check which assistants are available in Firebase
  Future<void> _checkAvailableAssistants() async {
    try {
      final assistants = await _packageManager.getAvailableAssistants();
      availableAssistants.value = assistants;

      // Set default to emmanuel if available
      if (assistants.contains('emmanuel')) {
        selectedAssistant.value = 'emmanuel';
      } else if (assistants.isNotEmpty) {
        selectedAssistant.value = assistants.first;
      }
    } catch (e) {
      print('❌ Error checking assistants: $e');
      errorMessage.value = 'Error al verificar asistentes disponibles';
    }
  }

  /// Start downloading the selected assistant package
  Future<void> downloadPackage({bool navigateOnSuccess = true}) async {
    if (isDownloading.value) return;

    try {
      isDownloading.value = true;
      errorMessage.value = '';
      downloadProgress.value = 0.0;
      currentFile.value = 0;
      totalFiles.value = 0;
      downloadFailed.value = false;

      print('📥 Starting download for: ${selectedAssistant.value}');

      final success = await _packageManager.downloadPackageForAssistant(
        selectedAssistant.value,
        onProgress: (current, total, word) {
          currentFile.value = current;
          totalFiles.value = total;
          currentWord.value = word;
          downloadProgress.value = current / total;
        },
      );

      if (success) {
        hasDownloaded.value = true;
        downloadFailed.value = false;
        Get.snackbar(
          'Descarga completa',
          'Paquetes de audio descargados correctamente.',
          snackPosition: SnackPosition.BOTTOM,
        );

        if (navigateOnSuccess) {
          // Navigate to login after successful download
          await Future.delayed(const Duration(seconds: 1));
          Get.offAllNamed(Routes.login);
        }
      } else {
        downloadFailed.value = true;
        errorMessage.value =
            'Error al descargar los paquetes de audio. Intenta nuevamente.';
      }
    } catch (e) {
      print('❌ Error downloading package: $e');
      downloadFailed.value = true;
      errorMessage.value = 'Error: $e';
    } finally {
      isDownloading.value = false;
    }
  }

  /// Skip download and go to login (will download on-demand)
  void skipDownload() {
    Get.offAllNamed(Routes.login);
  }
}