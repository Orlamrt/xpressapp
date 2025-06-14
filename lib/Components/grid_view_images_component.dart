import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Components/card_text_or_image_component.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Models/image_model.dart';

class GridViewImagesComponent extends StatefulWidget {
  final List<ImageModel> imagenes;
  final dynamic Function(int)? onTap;

  const GridViewImagesComponent({
    super.key,
    required this.imagenes,
    this.onTap,
  });

  @override
  State<GridViewImagesComponent> createState() =>
      _GridViewImagesComponentState();
}

class _GridViewImagesComponentState extends State<GridViewImagesComponent> {
  List<bool> selectedCards = [];
  bool isChanged = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.onTap != null) {
      selectedCards = List.generate(widget.imagenes.length, (index) => false);
    }
  }

  Future<void> agregarLista(ImageModel imagen, BuildContext context) async {
    final controller = Get.find<ControllerTeach>();
    await controller.tellPhrase(imagen.nameOfImage!);

    if (!context.mounted) return;

    controller.imagenes.add(
      ImageModel(
        imagePath: imagen.imagePath,
        color: imagen.color!,
      ),
    );

    Navigator.of(context).pop();
  }

  bool getIsSelected(int index) {
    if (widget.onTap == null) return false;
    if (index == 0 && !isChanged) return true;
    return selectedCards[index];
  }

  Orientation obtenerRotacion(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho y alto del dispositivo
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientacion = obtenerRotacion(context);

    // Ajustar valores en función del tamaño de la pantalla y la orientación
    int crossAxisCount = (screenWidth > 600)
        ? (orientacion == Orientation.portrait ? 3 : 4)
        : (orientacion == Orientation.portrait ? 2 : 2);
    double aspectRatio =
        (screenWidth > 600) ? 0.8 : 0.7; // Proporción de aspecto ajustada

    return SizedBox(
      height:
          screenHeight * 0.75, // Ajustar altura en función del alto de pantalla
      width:
          screenWidth * 0.9, // Ajustar ancho en función del ancho de pantalla
      child: Center(
        child: Scrollbar(
          controller: scrollController,
          child: GridView.builder(
            controller: scrollController,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: aspectRatio,
            ),
            itemCount: widget.imagenes.length,
            itemBuilder: (context, index) {
              final imagen = widget.imagenes[index];

              return Column(
                children: [
                  Expanded(
                    child: CartdTextOrImageComponent(
                      color: imagen.color!,
                      model: imagen,
                      isImage: true,
                      nameImage: false,
                      isSelected: getIsSelected(index),
                      onTap: widget.onTap != null
                          ? () async {
                              setState(() {
                                isChanged = true;
                                selectedCards = List.generate(
                                    widget.imagenes.length, (index) => false);
                                selectedCards[index] = true;
                              });
                              await widget.onTap!(index);
                            }
                          : () async => await agregarLista(imagen, context),
                      width: screenWidth *
                          0.4, // Ajustar tamaño en función del ancho de pantalla
                      height: screenHeight *
                          0.25, // Ajustar tamaño en función del alto de pantalla
                      borderThickness: 0.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    imagen.nameOfImage ?? '',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
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
