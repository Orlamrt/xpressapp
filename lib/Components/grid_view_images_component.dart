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
    final isLandscape = screenWidth > screenHeight;

    // Determinar número de columnas según tamaño de pantalla y orientación
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = isLandscape ? 5 : 4;
    } else if (screenWidth >= 800) {
      crossAxisCount = isLandscape ? 4 : 3;
    } else if (screenWidth >= 500) {
      crossAxisCount = isLandscape ? 3 : 2;
    } else {
      crossAxisCount = 1;
    }

    // Ajustar proporción de aspecto según orientación y tamaño de pantalla
    double childAspectRatio = isLandscape
        ? (screenWidth / screenHeight) * 1.2
        : (screenWidth / screenHeight) * 0.9;

    // Tamaño máximo y mínimo de cada tarjeta
    double cardWidth = (screenWidth / crossAxisCount) * 0.9;
    double cardHeight = screenHeight * (isLandscape ? 0.35 : 0.25);
    cardWidth = cardWidth.clamp(100.0, 400.0);
    cardHeight = cardHeight.clamp(120.0, 400.0);

    return SizedBox(
      height: screenHeight * (isLandscape ? 0.85 : 0.75),
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
              childAspectRatio: childAspectRatio,
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
                                  widget.imagenes.length,
                                  (i) => false,
                                );
                                selectedCards[index] = true;
                              });
                              await widget.onTap!(index);
                            }
                          : () async => await agregarLista(imagen, context),
                      width: cardWidth,
                      height: cardHeight,
                      borderThickness: 0.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    imagen.nameOfImage ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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
