import 'package:flutter/material.dart';
import 'package:xpressapp/Components/bottom_navigation_bar_component.dart';
import 'package:xpressapp/Views/newImage_view.dart';
import 'package:xpressapp/Views/register_view.dart';
import 'package:xpressapp/Views/profile_view.dart'; // Importa tu ProfileView
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Views/inicio_view.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpressapp/Views/star_session.dart'; // Asegúrate de importar SharedPreferences

class PrincipalViewPaciente extends StatefulWidget {
  const PrincipalViewPaciente({super.key});

  @override
  State<PrincipalViewPaciente> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalViewPaciente> {
  final ControllerTeach controller = Get.find<ControllerTeach>();
  final PageController pageController = PageController();
  int _currentIndex = 0; // Mantén el índice del ítem seleccionado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Actualiza dinámicamente las vistas cuando cambia el estado de autenticación
        return PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            const InicioView(),
            controller.isAuthenticated.value
                ? FutureBuilder(
                    future: _loadUserData(), // Carga los datos del usuario
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error al cargar datos'));
                      } else {
                        final data = snapshot.data as Map<String, String>;
                        return ProfileView(
                          name: data['userName']!,
                          email: data['userEmail']!,
                          role: data[
                              'userRole']!, // Asegúrate de que el rol se pase aquí
                        );
                      }
                    },
                  )
                : const RegisterView(),
            controller.isAuthenticated.value
                ? ImageUploadView()
                : const PrincipalInicio(),
          ],
        );
      }),
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

  Future<Map<String, String>> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'No disponible';
    final userEmail = prefs.getString('userEmail') ?? 'No disponible';
    final userRole = prefs.getString('userRole') ??
        'No disponible'; // Asegúrate de obtener el rol aquí
    return {'userName': userName, 'userEmail': userEmail, 'userRole': userRole};
  }
}
