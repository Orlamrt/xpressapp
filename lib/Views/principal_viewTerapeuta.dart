import 'package:flutter/material.dart';
import 'package:xpressapp/Components/bottom_navigation_bar_componentTerapeuta.dart';
import 'package:xpressapp/Views/agendar_view.dart';
import 'package:xpressapp/Views/chat_view_terapeuta.dart';
import 'package:xpressapp/Views/register_view.dart';
import 'package:xpressapp/Views/profile_view.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Views/inicio_view.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpressapp/Views/star_session.dart';
import 'package:xpressapp/Views/UploadInformationView.dart';

class PrincipalViewTerapeuta extends StatefulWidget {
  const PrincipalViewTerapeuta({key});

  @override
  State<PrincipalViewTerapeuta> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalViewTerapeuta> {
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
                          role:
                              data['userRole']!, // Pasa el rol del usuario aquí
                        );
                      }
                    },
                  )
                : RegisterView(),
            controller.isAuthenticated.value
                ? const AgendarView()
                : const PrincipalInicio(),
            ChatViewTerapeuta(),
            UploadInformationView()
          ],
        );
      }),
      bottomNavigationBar: BottomNavigationBarComponentTerpeuta(
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
        'No disponible'; // Obtén el rol del usuario aquí
    return {'userName': userName, 'userEmail': userEmail, 'userRole': userRole};
  }
}
