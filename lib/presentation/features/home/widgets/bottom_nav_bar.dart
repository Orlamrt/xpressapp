import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/core/theme/app_colors.dart';
import 'package:xpressatec/presentation/features/home/controllers/navigation_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find();

    return Obx(() {
      final sections = controller.sections;
      if (sections.isEmpty) {
        return const SizedBox.shrink();
      }

      final selectedIndex =
          controller.currentIndex.value.clamp(0, sections.length - 1);

      return NavigationBar(
        selectedIndex: (selectedIndex as num).toInt(),
        onDestinationSelected: controller.changePage,
        indicatorColor: AppColors.secondary,
        backgroundColor: Colors.white,
        destinations: sections.map((section) {
          switch (section) {
            case NavigationSection.teacch:
              return const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: Colors.white),
                label: 'Tablero',
              );
            case NavigationSection.chat:
              return const NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble, color: Colors.white),
                label: 'Chat',
              );
            case NavigationSection.statistics:
              return const NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart, color: Colors.white),
                label: 'Estadísticas',
              );
          }
        }).toList(),
      );
    });
  }
}
