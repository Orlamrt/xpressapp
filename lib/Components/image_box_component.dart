import 'package:flutter/material.dart';
import 'package:xpresatecch/Components/white_box_text_component.dart';
import 'package:xpresatecch/Models/image_model.dart';
import 'dart:io';

import '../ui/tokens.dart'; // <- tamaños responsivos

class ImageBoxComponent extends StatelessWidget {
  final bool nameImage;
  final ImageModel model;
  final double? width;
  final double? height;

  const ImageBoxComponent({
    super.key,
    required this.model,
    required this.nameImage,
    this.width,
    this.height,
  });

  Future<ImageProvider> _loadImageProvider() async {
    if (model.isLocal == true) {
      final file = File(model.imagePath);
      if (await file.exists()) {
        return FileImage(file);
      } else {
        throw Exception("La imagen local no existe");
      }
    } else {
      return AssetImage(model.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tamaños base responsivos (se pueden sobrescribir con width/height)
    final baseW = width ?? (Sz.tileW(context) * 0.9);
    final baseH = height ?? (Sz.tileH(context) * 0.8);

    return FutureBuilder<ImageProvider>(
      future: _loadImageProvider(),
      builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error al cargar la imagen",
              style: TextStyle(fontSize: Sz.fontSm(context)),
              textAlign: TextAlign.center,
            ),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: Text(
              "No se pudo cargar la imagen",
              style: TextStyle(fontSize: Sz.fontSm(context)),
              textAlign: TextAlign.center,
            ),
          );
        }

        final provider = snapshot.data!;

        // Contenido de la imagen en sí (reutilizado en ambos modos)
        final imageWidget = ConstrainedBox(
          // Asegura objetivo táctil mínimo
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Container(
            color: Colors.white,
            child: Center(
              child: SizedBox(
                width: baseW,
                height: baseH,
                child: Image(
                  image: provider,
                  fit: BoxFit.contain, // <- clave para que no se vea diminuta
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    size: Sz.iconLg(context),
                  ),
                ),
              ),
            ),
          ),
        );

        if (!nameImage) {
          return imageWidget;
        }

        // Con nombre debajo
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            imageWidget,
            Padding(
              padding: EdgeInsets.symmetric(vertical: Sz.gapXs(context)),
              child: WhiteBoxTextComponent(
                text: model.nameOfImage ?? '',
                isForImage: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
