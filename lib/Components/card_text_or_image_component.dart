import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Components/white_box_text_component.dart';
import 'package:xpressapp/Models/image_model.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'dart:io';

class CartdTextOrImageComponent extends StatelessWidget {
  final bool isImage;
  final bool nameImage;
  final bool isSelected;
  final Color color;
  final String text;
  final ImageModel? model;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final double borderThickness;

  const CartdTextOrImageComponent({
    super.key,
    required this.color,
    this.text = 'Item',
    this.model,
    this.isImage = false,
    this.nameImage = false,
    this.onTap,
    this.isSelected = false,
    this.width,
    this.height,
    this.borderThickness = 0,
  });

  // Función para cargar imágenes desde el almacenamiento local o los assets
  Future<Image> _loadImage() async {
    if (model!.isLocal) {
      // Verifica si la imagen es del almacenamiento local
      final file = File(model!.imagePath);
      if (await file.exists()) {
        return Image.file(file);
      } else {
        throw Exception("La imagen local no existe");
      }
    } else {
      return Image.asset(model!.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ControllerTeach>();
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            width: borderThickness,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.9),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        padding: !nameImage
            ? EdgeInsets.all(controller.imagenes.isEmpty ? 20 : 10)
            : const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: !isImage
            ? WhiteBoxTextComponent(text: text)
            : FutureBuilder<Image>(
                future: _loadImage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error al cargar la imagen: ${snapshot.error}",
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return SizedBox(
                      width: width ?? screenWidth * 0.2, // Cambiado aquí
                      height: height ?? screenWidth * 0.2, // Cambiado aquí
                      child: Image(
                        image: snapshot.data!.image,
                        fit: BoxFit.contain, // Cambiado a contain
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text("No se pudo cargar la imagen"),
                    );
                  }
                },
              ),
      ),
    );
  }
}
