import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Components/card_text_or_image_component.dart';
import 'package:xpresatecch/Controllers/controller.dart';
import 'package:xpresatecch/Models/image_model.dart';

import '../ui/tokens.dart'; // <- tamaños responsivos

class GridViewImagesComponent extends StatefulWidget {
  final List<ImageModel> imagenes;
  final Future<void> Function(int)? onTap;

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
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.onTap != null) {
      selectedCards = List.generate(widget.imagenes.length, (_) => false);
    }
  }

  Future<void> agregarLista(ImageModel imagen, BuildContext context) async {
    final controller = Get.find<ControllerTeach>();

    await controller.tellPhrase11labs(imagen.nameOfImage!);
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

  @override
  Widget build(BuildContext context) {
    final gap = Sz.gapMd(context);

    return Scrollbar(
      controller: scrollController,
      child: GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.all(gap),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          // Ancho preferido por tarjeta (se adapta a móvil/tablet)
          maxCrossAxisExtent: Sz.tileW(context),
          // Espaciados responsivos
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          // Relación ancho/alto del "tile" (ajústala si deseas más alto)
          childAspectRatio: 0.9,
        ),
        itemCount: widget.imagenes.length,
        itemBuilder: (context, index) {
          final imagen = widget.imagenes[index];

          return Column(
            children: [
              // Tarjeta (imagen/ícono) llena el alto disponible del tile
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
                                widget.imagenes.length, (_) => false);
                            selectedCards[index] = true;
                          });
                          await widget.onTap!(index);
                        }
                      : () async => await agregarLista(imagen, context),

                  // Tamaños base (el grid ya limita el ancho/alto del tile)
                  width: Sz.tileW(context) - Sz.gapSm(context) * 2,
                  height: Sz.tileH(context) * 0.75,
                  borderThickness: 0.0,
                ),
              ),
              SizedBox(height: Sz.gapXs(context)),
              Text(
                imagen.nameOfImage ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: Sz.fontMd(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
