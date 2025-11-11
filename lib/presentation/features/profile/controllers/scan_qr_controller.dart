import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../domain/usecases/tutor/link_tutor_with_patient_usecase.dart';
import '../../auth/controllers/auth_controller.dart';

class ScanQrController extends GetxController {
  ScanQrController({
    required this.linkTutorWithPatientUseCase,
    required this.authController,
  });

  final LinkTutorWithPatientUseCase linkTutorWithPatientUseCase;
  final AuthController authController;

  final MobileScannerController scannerController = MobileScannerController();

  final RxBool isTorchOn = false.obs;
  final RxString statusMessage = 'Escanea un código QR para comenzar.'.obs;
  final RxBool hasError = false.obs;
  final RxnString scannedUuid = RxnString();
  final RxBool isProcessing = false.obs;

  // ignore: avoid_void_async
  void onDetect(BarcodeCapture capture) async {
    if (isProcessing.value) return;
    if (capture.barcodes.isEmpty) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) {
      hasError.value = true;
      scannedUuid.value = null;
      statusMessage.value = 'El código escaneado no es válido.';
      Get.snackbar(
        'Código inválido',
        statusMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isProcessing.value = true;
    await scannerController.stop();

    try {
      if (!authController.isTutor) {
        hasError.value = true;
        scannedUuid.value = null;
        statusMessage.value =
            'Solo un tutor puede enlazar con un paciente.';
        Get.snackbar(
          'Acceso restringido',
          statusMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final tutorEmail = authController.currentUser.value?.email ??
          authController.userEmail.value;
      if (tutorEmail.isEmpty) {
        hasError.value = true;
        scannedUuid.value = null;
        statusMessage.value =
            'No se encontró el correo del tutor autenticado.';
        Get.snackbar(
          'Información incompleta',
          statusMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      statusMessage.value = 'Vinculando paciente...';
      hasError.value = false;
      scannedUuid.value = null;

      final result = await linkTutorWithPatientUseCase(
        patientUuid: raw,
        tutorEmail: tutorEmail,
      );

      if (result.success) {
        hasError.value = false;
        scannedUuid.value = raw;
        statusMessage.value = result.message;
        Get.snackbar(
          '¡Éxito!',
          statusMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        hasError.value = true;
        scannedUuid.value = null;
        statusMessage.value = result.message;
        Get.snackbar(
          'No se pudo completar la vinculación',
          statusMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      hasError.value = true;
      scannedUuid.value = null;
      statusMessage.value =
          'Error al enlazar con el paciente. Intenta de nuevo.';
      Get.snackbar(
        'Error',
        statusMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> toggleTorch() async {
    await scannerController.toggleTorch();
    isTorchOn.value = !isTorchOn.value;
  }

  void resumeScanning() {
    scannedUuid.value = null;
    hasError.value = false;
    statusMessage.value = 'Escanea un código QR para comenzar.';
    scannerController.start();
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
