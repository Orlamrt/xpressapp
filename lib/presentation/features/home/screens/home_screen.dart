import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/core/config/routes.dart';
import 'package:xpressatec/presentation/features/chat/screens/chat_list_screen.dart';
import 'package:xpressatec/presentation/features/home/controllers/navigation_controller.dart';
import 'package:xpressatec/presentation/features/home/widgets/bottom_nav_bar.dart';
import 'package:xpressatec/presentation/features/home/widgets/custom_drawer.dart';
import 'package:xpressatec/presentation/features/statistics/screens/statistics_screen.dart';
import 'package:xpressatec/presentation/features/teacch_board/screens/teacch_board_screen.dart';
import 'package:xpressatec/presentation/features/teacch_board/widgets/generate_phrase_fab.dart';
import 'package:xpressatec/presentation/shared/widgets/xpressatec_header_appbar.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();

    return Obx(() {
      final section = navController.currentSection;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      Widget body;
      PreferredSizeWidget? appBar;
      Widget? floatingActionButton;
      FloatingActionButtonLocation? floatingActionButtonLocation;

      switch (section) {
        case NavigationSection.teacch:
          body = const TeacchBoardScreen();
          appBar = XpressatecHeaderAppBar(
            showMenu: true,
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          );
          floatingActionButton = const TeacchGeneratePhraseFab();
          floatingActionButtonLocation = FloatingActionButtonLocation.centerFloat;
          break;
        case NavigationSection.chat:
          body = const ChatListScreen();
          appBar = AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.menu, color: colorScheme.onSurface),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: Text(
              'Chats',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
          floatingActionButton = FloatingActionButton(
            heroTag: 'chatFab',
            backgroundColor: colorScheme.primary,
            onPressed: () => Get.toNamed(Routes.newChat),
            child: Icon(Icons.chat, color: colorScheme.onPrimary),
          );
          floatingActionButtonLocation = FloatingActionButtonLocation.endFloat;
          break;
        case NavigationSection.statistics:
          body = const StatisticsScreen();
          appBar = XpressatecHeaderAppBar(
            showMenu: true,
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          );
          break;
      }

      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: colorScheme.background,
        appBar: appBar,
        drawer: const CustomDrawer(),
        body: body,
        bottomNavigationBar: const BottomNavBar(),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      );
    });
  }
}