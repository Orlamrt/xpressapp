import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Components/card_text_or_image_component.dart';
import 'package:xpressapp/Components/red_circle_with_cross.dart';
import 'package:xpressapp/Controllers/controller.dart';

class SelectedImageListComponent extends StatefulWidget {
  const SelectedImageListComponent({super.key});

  @override
  State<SelectedImageListComponent> createState() => _SelectedImageListComponentState();
}

class _SelectedImageListComponentState extends State<SelectedImageListComponent> {
  final scrollController = ScrollController();
  final controller = Get.find<ControllerTeach>();

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

    return Obx(
      () => SizedBox(
        height: 230,
        child: Scrollbar(
          controller: scrollController,
          child: ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.imagenes.length,
            itemBuilder: (context, index) {
              final imageModel = controller.imagenes[index];

              double maxWidth = screenWidth > 600 ? 200 : 160; // Tamaño máximo ajustable
              double aspectRatio = 1.0; // Relación de aspecto
              double maxHeight = maxWidth / aspectRatio;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0 , vertical: 5.5 ), // Reducir el padding horizontal
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxWidth,
                        maxHeight: maxHeight, // Usar el tamaño calculado
                      ),
                      child: CartdTextOrImageComponent(
                        color: imageModel.color!,
                        model: imageModel,
                        isImage: true,
                        nameImage: true,
                        onTap: () async {
                          await controller.tellPhrase(imageModel.nameOfImage!);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: RedCircleWithCross(
                      onTap: () {
                        controller.imagenes.removeAt(index);
                        controller.imagenes.refresh();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
