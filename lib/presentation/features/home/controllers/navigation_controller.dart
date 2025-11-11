import 'package:get/get.dart';
import 'package:xpressatec/domain/entities/user.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

enum NavigationSection { teacch, chat, statistics }

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxList<NavigationSection> sections = <NavigationSection>[
    NavigationSection.teacch,
    NavigationSection.statistics,
  ].obs;

  late final AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    _configureSections(_authController.currentUser.value);
    ever<User?>(_authController.currentUser, _configureSections);
  }

  void changePage(int index) {
    if (index < sections.length) {
      currentIndex.value = index;
    }
  }

  NavigationSection get currentSection {
    if (sections.isEmpty) {
      return NavigationSection.teacch;
    }
    final safeIndex = currentIndex.value.clamp(0, sections.length - 1);
    return sections[(safeIndex as num).toInt()];
  }

  void _configureSections(User? user) {
    final isTutor = user?.isTutor ?? false;
    final isTerapeuta = user?.isTerapeuta ?? false;

    final updatedSections = <NavigationSection>[
      NavigationSection.teacch,
      if (isTutor || isTerapeuta) NavigationSection.chat,
      NavigationSection.statistics,
    ];

    final safeIndex = updatedSections.isEmpty
        ? 0
        : currentIndex.value.clamp(0, updatedSections.length - 1);

    sections.assignAll(updatedSections);
    currentIndex.value = (safeIndex as num).toInt();
  }
}
