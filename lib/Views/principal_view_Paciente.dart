import 'package:flutter/material.dart';
import 'package:xpresatecch/Components/bottom_navigation_bar_component.dart';
import 'package:xpresatecch/Views/newImage_view.dart';
import 'package:xpresatecch/Views/register_view.dart';
import 'package:xpresatecch/Views/profile_view.dart';
import 'package:xpresatecch/Views/Tecch_View.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpresatecch/Views/star_session.dart';

class PrincipalViewPaciente extends StatefulWidget {
  const PrincipalViewPaciente({super.key});

  @override
  State<PrincipalViewPaciente> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalViewPaciente> {
  final PageController pageController = PageController();
  int _currentIndex = 0;

  bool _isAuthenticated = false;
  Map<String, String> _userData = const {
    'userName': 'No disponible',
    'userEmail': 'No disponible',
    'userRole': 'No disponible',
  };

  @override
  void initState() {
    super.initState();
    _loadAuthAndUser();
  }

  Future<void> _loadAuthAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    // cambia la clave si usas otra para auth
    final isAuth = prefs.getBool('isAuthenticated') ?? false;

    final userName = prefs.getString('userName') ?? 'No disponible';
    final userEmail = prefs.getString('userEmail') ?? 'No disponible';
    final userRole = prefs.getString('userRole') ?? 'No disponible';

    if (!mounted) return;
    setState(() {
      _isAuthenticated = isAuth;
      _userData = {
        'userName': userName,
        'userEmail': userEmail,
        'userRole': userRole,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          const TecchView(),
          // Perfil con datos cargados de SharedPreferences
          _isAuthenticated
              ? ProfileView(
                  name: _userData['userName'] ?? 'No disponible',
                  email: _userData['userEmail'] ?? 'No disponible',
                  role: _userData['userRole'] ?? 'No disponible',
                )
              : const ProfileView(name: "No disponible", email:"No disponible" , role:"No disponible"),
          // Vista para gestionar/agregar imágenes locales
          ImageUploadView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarComponent(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}
