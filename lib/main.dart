import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Controllers/controller.dart';
import 'package:xpresatecch/Views/SplashScreen.dart';
import 'package:xpresatecch/Views/principal_view_Paciente.dart'; // PrincipalViewPaciente
 // el de arriba

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ControllerTeach()); // inyección del controller
  ControllerTeach controller = Get.find<ControllerTeach>();
  controller.copiarImagenesAssetsAlLocal();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XPRESSATEC',
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: '/principal',
          page: () => const PrincipalViewPaciente(),
          // puedes dejar sin transición aquí porque ya hacemos fade en Get.offNamed
        ),
      ],
    );
  }
}
