import 'package:get/get.dart';

import '../../domain/usecases/tutor/link_tutor_with_patient_usecase.dart';
import '../../presentation/features/auth/controllers/auth_controller.dart';
import '../../presentation/features/profile/controllers/scan_qr_controller.dart';

class ScanQrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanQrController>(
      () => ScanQrController(
        linkTutorWithPatientUseCase: Get.find<LinkTutorWithPatientUseCase>(),
        authController: Get.find<AuthController>(),
      ),
    );
  }
}
