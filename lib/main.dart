import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Controllers/sound_controller.dart'; // Nuevo import
import 'package:xpressapp/Views/star_session.dart';
import 'package:xpressapp/Views/principal_viewTutor.dart';
import 'package:xpressapp/Services/notification_service.dart'; // nuevo de las notificaciones

void main() {
  // Asegurarse de que las vinculaciones de Flutter estén inicializadas
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar primero el SoundController
  Get.put(SoundController());

  // Luego inicializar el ControllerTeach
  Get.put(ControllerTeach());

  // Inicializar notificaciones
  final notificationService = NotificationService();
  notificationService.initializeNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mover la inicialización del controlador fuera del build
    ControllerTeach controller = Get.find<ControllerTeach>();
    controller.copiarImagenesAssetsAlLocal();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Xpresa-Teacch',
      theme: ThemeData(primaryColor: const Color(0xFFF2DCD8)),
      home: const PrincipalViewTutor(),
    );
  }
}
