import 'package:get/get.dart';

import '../../presentation/features/therapists/controllers/communication_therapist_controller.dart';

class CommunicationTherapistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunicationTherapistController>(
      () => CommunicationTherapistController(),
    );
  }
}
