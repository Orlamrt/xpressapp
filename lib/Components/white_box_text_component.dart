import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Controllers/controller.dart';

import '../ui/tokens.dart'; // <- tamaños responsivos

class WhiteBoxTextComponent extends StatelessWidget {
  /// Texto a mostrar en el cuadro blanco
  final String text;

  /// Si el texto es para una imagen, marcar como true
  final bool isForImage;

  /// Estilo opcional; si no lo pasas, se calcula responsivo
  final TextStyle? style;

  /// Color del borde (opcional)
  final Color borderColor;

  /// Grosor del borde (opcional)
  final double borderWidth;

  /// Ruta de la imagen (opcional, solo si isForImage == true)
  final String? imagePath;

  const WhiteBoxTextComponent({
    super.key,
    required this.text,
    this.isForImage = false,
    this.style,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.imagePath,
    
  });

  TextStyle _computedTextStyle(BuildContext context) {
    final controller = Get.find<ControllerTeach>();

    // Tamaños base según contexto de uso
    final double fontSize = isForImage
        ? Sz.fontMd(context) // etiquetas bajo imágenes
        : (controller.imagenes.isEmpty
            ? Sz.titleXL(context) // título cuando no hay imágenes en la lista
            : Sz.fontLg(context)); // título/etiqueta normal

    // Usa el theme como base para respetar familia/peso por defecto
    final base = Theme.of(context).textTheme.bodyLarge ??
        const TextStyle(fontSize: 16);

    return base.copyWith(
      fontSize: fontSize,
      fontWeight: isForImage ? FontWeight.w600 : FontWeight.w700,
      color: Colors.black,
      height: 1.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? _computedTextStyle(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(8.0), // más amable en móvil
      ),
      padding: EdgeInsets.symmetric(
  horizontal: Sz.gapLg(context)*0.1,
  vertical: Sz.gapMd(context),
),
constraints: BoxConstraints(minHeight: Sz.tileH(context) * 0.4),

    child: FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(
  text,
  textAlign: TextAlign.center,
  style: textStyle,
  // quita maxLines/ellipsis para que FittedBox mande
  softWrap: true,
),
),

    );
  }
}
