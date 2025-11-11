import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/teacch_controller.dart';

class TeacchGeneratePhraseFab extends StatelessWidget {
  const TeacchGeneratePhraseFab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacchController>();

    return Obx(() {
      if (controller.selectedItems.length >= 2) {
        return FloatingActionButton.extended(
          onPressed: controller.generateAndShowPhrase,
          backgroundColor: Colors.green,
          icon: const Icon(Icons.auto_awesome, color: Colors.white),
          label: const Text(
            'Generar Frase',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}
