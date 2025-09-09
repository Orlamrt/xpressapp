import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpresatecch/Views/Tareas_view.dart';
import 'package:xpresatecch/Views/allchatView.dart';
import 'package:xpresatecch/Views/assign_view.dart';
import 'package:xpresatecch/Views/calendar_view.dart';
import 'package:xpresatecch/Views/register_view.dart';
import 'package:xpresatecch/Views/profile_view.dart';
import 'package:xpresatecch/Components/bottom_navigation_bar_componentTutor.dart';
import 'package:xpresatecch/Controllers/controller.dart';
import 'package:xpresatecch/Views/Tecch_View.dart';
import 'package:xpresatecch/Views/star_session.dart';
import 'package:xpresatecch/Views/therapists_view.dart';

class PrincipalViewTutor extends StatefulWidget {
  const PrincipalViewTutor({Key? key}) : super(key: key);

  @override
  State<PrincipalViewTutor> createState() => _PrincipalViewTutorState();
}

class _PrincipalViewTutorState extends State<PrincipalViewTutor> {
  final ControllerTeach controller = Get.find<ControllerTeach>();
  final PageController pageController = PageController();
  int _currentIndex = 0;
  RxString assignedPatientName = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadAssignedPatient();
  }

  Future<void> _loadAssignedPatient() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorEmail = prefs.getString('userEmail') ?? '';
    final patientName = await controller.getAssignedPatient(tutorEmail);

    assignedPatientName.value = patientName ?? 'No hay paciente asignado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            const TecchView(),
            controller.isAuthenticated.value
                ? FutureBuilder<Map<String, String>>(
                    future: _loadUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error al cargar datos'));
                      } else {
                        final data = snapshot.data ?? {};
                        return ProfileView(
                          name: data['userName'] ?? 'Nombre no disponible',
                          email: data['userEmail'] ?? 'Email no disponible',
                          role: data['userRole'] ?? 'Rol no disponible',
                          assignedPatientName: assignedPatientName
                              .value, // Pasa el nombre del paciente asignado
                        );
                      }
                    },
                  )
                : const RegisterView(),
            const CodeVer(),
            controller.isAuthenticated.value
                ? const CalendarView()
                : const PrincipalInicio(),
            AssignView(),
            TherapistsView(),
            AllChatsView()
          ],
        );
      }),
      bottomNavigationBar: BottomNavigationBarComponentTutor(
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
    final userRole = prefs.getString('userRole') ?? 'No disponible';
    return {'userName': userName, 'userEmail': userEmail, 'userRole': userRole};
  }
}
