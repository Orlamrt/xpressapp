import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Views/alert_images_component.dart';
import 'package:xpresatecch/Components/card_text_or_image_component.dart';
import 'package:xpresatecch/Constants/Colors.dart';
import 'package:xpresatecch/Constants/strings.dart';
import 'package:xpresatecch/Controllers/controller.dart';

import '../ui/tokens.dart'; // <- tokens responsivos

class MosaicoComponent extends StatelessWidget {
  final List<int> blockedIndexes = [];

  MosaicoComponent({super.key});

  onTap(BuildContext context, int index) async {
    if (blockedIndexes.contains(index)) return;

    final Pallete pallete = Pallete();
    final color = pallete.colores[index];
    final controller = Get.find<ControllerTeach>();
    final title = Textos.preguntas[index];

    await controller.tellPhrase(title);

    final imagenes =
        await controller.obtenerListaImagenes(Textos.colores[index]);

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
    final pallete = Pallete();
    final controller = Get.find<ControllerTeach>();

    return Obx(
      () => Padding(
        padding: EdgeInsets.all(Sz.gapSm(context)),
        child: SizedBox(
          // altura adaptada: si hay imágenes, fijo a 370; si no, usar pantalla
          height: controller.imagenes.isEmpty
              ? MediaQuery.of(context).size.height * 0.7
              : 370,
          width: controller.imagenes.isEmpty
              ? MediaQuery.of(context).size.width
              : 650,
          child: GridView.builder(
            padding: EdgeInsets.all(Sz.gapSm(context)),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: Sz.tileW(context), // ancho objetivo
              mainAxisExtent: Sz.tileH(context) * 0.8,
              crossAxisSpacing: Sz.gapSm(context),
              mainAxisSpacing: Sz.gapSm(context),
              childAspectRatio: 1.0,
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
                      color: const Color(0xFFD96C94),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: CartdTextOrImageComponent(
                    color: color,
                    text: text,
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
