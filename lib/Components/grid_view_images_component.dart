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
      ImageModel(imagePath: imagen.imagePath, color: imagen.color!),
    );

    Navigator.of(context).pop();
  }

  bool getIsSelected(int index) {
    if (widget.onTap == null) return false;
    if (index == 0 && !isChanged) return true;
    return selectedCards[index];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ajuste de columnas para pantallas grandes
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 800) {
      crossAxisCount = 3;
    } else if (screenWidth >= 500) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    // Cálculo mejorado del tamaño de tarjetas
    double cardWidth = (screenWidth / crossAxisCount) * 0.8;
    cardWidth = cardWidth.clamp(150.0, 300.0);

    return SizedBox(
      height: screenHeight * 0.8,
      width: screenWidth * 0.95,
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
              // Ajustamos la proporción para dar más espacio al texto
              childAspectRatio: 0.85,
            ),
            itemCount: widget.imagenes.length,
            itemBuilder: (context, index) {
              final imagen = widget.imagenes[index];

              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Contenedor para la imagen
                    Expanded(
                      flex: 7, // Ajustamos la proporción para la imagen
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
                                    widget.imagenes.length,
                                    (i) => false,
                                  );
                                  selectedCards[index] = true;
                                });
                                await widget.onTap!(index);
                              }
                            : () async => await agregarLista(imagen, context),
                        width: cardWidth,
                        height: cardWidth,
                      ),
                    ),
                    // Contenedor para el texto
                    Container(
                      height: 40, // Altura fija para el texto
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        imagen.nameOfImage ?? '',
                        style: TextStyle(
                          fontSize: (screenWidth * 0.012).clamp(12.0, 18.0),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
