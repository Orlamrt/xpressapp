import 'package:flutter/material.dart';

class BottomNavigationBarComponent extends StatelessWidget {
  final void Function(int) onTap;
  final int currentIndex;

  const BottomNavigationBarComponent({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          elevation: 15,
          backgroundColor: const Color(0xFFF2DCD8),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
            ),
            _buildNavItem(
              icon: Icons.person_2_outlined,
              activeIcon: Icons.person_2,
              label: 'Perfil',
            ),
            _buildNavItem(
              icon: Icons.upload_file_outlined,
              activeIcon: Icons.upload,
              label: 'Subir',
            ),
          ],
          currentIndex: currentIndex,
          selectedItemColor: const Color(0xDDD96C94),
          unselectedItemColor: const Color(0xDDD96C94).withOpacity(0.5),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            fontFamily: 'Roboto',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            fontFamily: 'Roboto',
          ),
          iconSize: 28,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: onTap,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(icon, key: ValueKey(icon)),
      ),
      activeIcon: Icon(activeIcon, color: const Color(0xDDD96C94)),
      label: label,
    );
  }
}
