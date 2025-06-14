import 'package:flutter/material.dart';
import 'package:xpressapp/Components/white_box_text_component.dart';
import 'package:xpressapp/Models/image_model.dart';
import 'dart:io';

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

  Future<Image> _loadImage() async {
    if (model.isLocal == true) {
      // Verificar si el archivo local existe antes de cargarlo
      final file = File(model.imagePath);
      if (await file.exists()) {
        return Image.file(file);
      } else {
        throw Exception("La imagen local no existe");
      }
    } else {
      return Image.asset(model.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: _loadImage(),
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Mostrar cargando
        } else if (snapshot.hasError) {
          return Center(
              child: Text("Error al cargar la imagen: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return const Center(child: Text("No se pudo cargar la imagen"));
        }

        final image = snapshot.data!;

        return !nameImage
            ? SizedBox(
                width: width ?? 150,
                height: height ?? 150,
                child: image,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Colors.white,
                    child: SizedBox(
                      width: width ?? 150,
                      height: height ?? 150,
                      child: image,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: WhiteBoxTextComponent(
                      text: model.nameOfImage!,
                      isForImage: true,
                    ),
                  ),
                ],
              );
      },
    );
  }
}
