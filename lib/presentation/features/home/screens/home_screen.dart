import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/chat/screens/chat_screen.dart';
import 'package:xpressatec/presentation/features/customization/screens/customization_screen.dart';
import 'package:xpressatec/presentation/features/home/controllers/navigation_controller.dart';
import 'package:xpressatec/presentation/features/home/widgets/bottom_nav_bar.dart';
import 'package:xpressatec/presentation/features/home/widgets/custom_drawer.dart';
import 'package:xpressatec/presentation/features/statistics/screens/statistics_screen.dart';
import 'package:xpressatec/presentation/features/teacch_board/screens/teacch_board_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();
    final theme = Theme.of(context);
    final titleColor = theme.appBarTheme.titleTextStyle?.color ??
        theme.textTheme.titleLarge?.color ??
        theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Obx(() {
          switch (navController.currentSection) {
            case NavigationSection.teacch:
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/images/imagen.svg',
                    height: 180,
                    semanticsLabel: 'Icono del tablero TEACCH',
                  ),
                ],
              );
            case NavigationSection.chat:
              return const Text('Chat con Terapeuta');
            case NavigationSection.customization:
              return const Text('Personalización');
            case NavigationSection.statistics:
              return const Text('Estadísticas');
          }
        }),
      ),
      drawer: const CustomDrawer(),
      body: Obx(() {
        switch (navController.currentSection) {
          case NavigationSection.teacch:
            return const TeacchBoardScreen();
          case NavigationSection.chat:
            return const ChatScreen();
          case NavigationSection.customization:
            return const CustomizationScreen();
          case NavigationSection.statistics:
            return const StatisticsScreen();
        }
      }),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}