import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/chat/screens/chat_screen.dart';
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
      Widget body;

      switch (section) {
        case NavigationSection.teacch:
          body = const TeacchBoardScreen();
          break;
        case NavigationSection.chat:
          body = const ChatScreen();
          break;
        case NavigationSection.statistics:
          body = const StatisticsScreen();
          break;
      }

      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: section == NavigationSection.chat
            ? null
            : XpressatecHeaderAppBar(
                showMenu: true,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        drawer: const CustomDrawer(),
        body: body,
        bottomNavigationBar: const BottomNavBar(),
        floatingActionButton: section == NavigationSection.teacch
            ? const TeacchGeneratePhraseFab()
            : null,
        floatingActionButtonLocation:
            section == NavigationSection.teacch
                ? FloatingActionButtonLocation.centerFloat
                : null,
      );
    });
  }
}