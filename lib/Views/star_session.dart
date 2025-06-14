import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpressapp/Views/login_view.dart';
import 'package:xpressapp/Views/register_view.dart';
import 'package:xpressapp/Views/principal_view.dart';

class PrincipalInicio extends StatefulWidget {
  const PrincipalInicio({key});

  @override
  _PrincipalInicioState createState() => _PrincipalInicioState();
}

class _PrincipalInicioState extends State<PrincipalInicio> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    if (isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const PrincipalViewPaciente()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2DCD8),
        elevation: 0,
        title: const Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2DCD8),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _buildAuthButton(
              text: 'Iniciar Sesión',
              icon: Icons.person,
              onPressed: () => _navigateTo(context, LoginView()),
            ),
            const SizedBox(height: 25),
            _buildAuthButton(
              text: 'Registrarse',
              icon: Icons.person_add,
              onPressed: () => _navigateTo(context, RegisterView()),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          size: 28,
          color: Colors.white,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xDDD96C94),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          shadowColor: const Color(0xDDD96C94).withOpacity(0.3),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
