import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Views/star_session.dart';
import 'package:xpressapp/Views/principal_viewTutor.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ControllerTeach());
    ControllerTeach controller = Get.find<ControllerTeach>();
    controller.copiarImagenesAssetsAlLocal();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Xpresa-Teacch',
      theme: ThemeData(
        primaryColor: const Color(0xFFF2DCD8),
      ),
      home: const PrincipalViewTutor(),
    );
  }
}
