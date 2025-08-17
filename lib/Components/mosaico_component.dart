import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Views/alert_images_component.dart';
import 'package:xpressapp/Components/card_text_or_image_component.dart';
import 'package:xpressapp/Constants/colors.dart';
import 'package:xpressapp/Constants/strings.dart';
import 'package:xpressapp/Controllers/controller.dart';

class MosaicoComponent extends StatelessWidget {
  final List<int> blockedIndexes = []; // Indices bloqueados, ahora vacía

  // Método constructor
  MosaicoComponent({super.key});

  // Esta es la función para crear un widget
  onTap(BuildContext context, int index) async {
    if (blockedIndexes.contains(index)) {
      // Acción extra si la tarjeta está bloqueada
      return;
    }

    final Pallete pallete = Pallete();
    final color = pallete.colores[index];
    final controller = Get.find<ControllerTeach>();
    final title = Textos.preguntas[index];

    await controller.tellPhrase(title);

    List<String> imagenes = await controller.obtenerListaImagenes(
      Textos.colores[index],
    );

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: color),
            dialogBackgroundColor: Colors.white,
          ),
          child: AlertImagesComponent(
            color: color,
            imagenes: imagenes,
            title: title,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Pallete pallete = Pallete();

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 1; // Mostrar 1 tarjeta
    } else if (width < 900) {
      crossAxisCount = 2; // Mostrar 2 tarjetas
    } else {
      crossAxisCount = 4; // Dispositivos grandes
    }

    final controller = Get.find<ControllerTeach>();

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0.0,
        ), // Reduce el padding vertical
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            height: controller.imagenes.isEmpty ? (height - 80) - 51 : 370,
            width: controller.imagenes.isEmpty ? width : 650,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0, // Mantener un aspecto cuadrado
              ),
              itemCount: pallete.colores.length,
              itemBuilder: (context, index) {
                final color = pallete.colores[index];
                final text = Textos.preguntas[index];
                return GestureDetector(
                  onTap: () => onTap(context, index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xDDD96C94),
                        width: 1.0,
                      ), // Borde
                      borderRadius: BorderRadius.circular(
                        3.0,
                      ), // Bordes redondeados
                    ),
                    child: CartdTextOrImageComponent(color: color, text: text),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
