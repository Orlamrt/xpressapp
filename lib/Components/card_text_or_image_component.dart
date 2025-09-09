import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Components/white_box_text_component.dart';
import 'package:xpresatecch/Models/image_model.dart';
import 'package:xpresatecch/Controllers/controller.dart';
import 'dart:io';

import '../ui/tokens.dart'; // <- tamaños responsivos

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

  // Cargar imagen (local o asset)
  Future<ImageProvider> _loadImageProvider() async {
    if (model?.isLocal == true) {
      final file = File(model!.imagePath);
      if (await file.exists()) {
        return FileImage(file);
      } else {
        throw Exception("La imagen local no existe");
      }
    } else if (model != null) {
      return AssetImage(model!.imagePath);
    } else {
      throw Exception("Modelo de imagen no proporcionado");
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ControllerTeach>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            width: borderThickness,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(12),
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
        padding: EdgeInsets.all(
          nameImage
              ? Sz.gapSm(context)
              : (controller.imagenes.isEmpty ? Sz.gapLg(context) : Sz.gapMd(context)),
        ),
        child:// dentro de build(), reemplaza la rama !isImage:
!isImage
    ? Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Reservamos una porción grande del tile para el texto
            final w = (width ?? constraints.maxWidth) * 0.95 ;
            final h = (height ?? constraints.maxHeight) * 0.8;

            return SizedBox(
              width: w,
              height: h,
              child: Padding(
                padding: EdgeInsets.all(Sz.gapSm(context)),
                child: FittedBox(
                  fit: BoxFit.scaleDown, // crece todo lo posible
                  child: WhiteBoxTextComponent(
                    text: text,
                    // base razonable; FittedBox la escalará
                    style: TextStyle(
                      fontSize: Sz.fontLg(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      )
   

            : FutureBuilder<ImageProvider>(
                future: _loadImageProvider(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error al cargar la imagen",
                        style: TextStyle(fontSize: Sz.fontSm(context)),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return SizedBox(
                      width: width ?? Sz.tileW(context),
                      height: height ?? Sz.tileH(context),
                      child: Image(
                        image: snapshot.data!,
                        fit: BoxFit.contain,
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        "No se pudo cargar la imagen",
                        style: TextStyle(fontSize: Sz.fontSm(context)),
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}
