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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Nuevo sistema de cálculo para tamaños de tarjetas
    double cardSize;
    int crossAxisCount;
    double minCardSize = 200.0; // Tamaño mínimo de tarjeta
    double maxCardSize = 400.0; // Tamaño máximo de tarjeta

    if (screenWidth < 600) {
      crossAxisCount = 1;
      cardSize = screenWidth * 0.85;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
      cardSize = (screenWidth * 0.4).clamp(minCardSize, maxCardSize);
    } else if (screenWidth < 1200) {
      crossAxisCount = 3;
      cardSize = (screenWidth * 0.3).clamp(minCardSize, maxCardSize);
    } else {
      crossAxisCount = 4;
      cardSize = (screenWidth * 0.22).clamp(minCardSize, maxCardSize);
    }

    // Calcular el padding basado en el tamaño de la pantalla
    double paddingSize = screenWidth * 0.02; // 2% del ancho de la pantalla

    final controller = Get.find<ControllerTeach>();

    return Obx(
      () => Padding(
        padding: EdgeInsets.all(paddingSize),
        child: SizedBox(
          width: screenWidth,
          height: controller.imagenes.isEmpty
              ? screenHeight * 0.85
              : screenHeight * 0.7,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: paddingSize,
              mainAxisSpacing: paddingSize,
              childAspectRatio: 1.0,
            ),
            itemCount: pallete.colores.length,
            itemBuilder: (context, index) {
              final color = pallete.colores[index];
              final text = Textos.preguntas[index];
              return GestureDetector(
                onTap: () => onTap(context, index),
                child: SizedBox(
                  width: cardSize,
                  height: cardSize,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xDDD96C94),
                        width: 3.0, // Borde más grueso para mejor visibilidad
                      ),
                      borderRadius: BorderRadius.circular(
                        8.0,
                      ), // Radio más pronunciado
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CartdTextOrImageComponent(color: color, text: text),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
