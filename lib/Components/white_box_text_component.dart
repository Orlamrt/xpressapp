import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';

class WhiteBoxTextComponent extends StatelessWidget {
  /// Definimos el texto que se va a mostrar en el cuadro blanco
  final String text;

  /// Si el texto es para una imagen, esta propiedad se tiene que marcar como true
  final bool isForImage;

  /// Si queremos un texto más personalizado, se puede definir el estilo.
  /// Sino, ya viene con estilos por defecto
  final TextStyle? style;

  /// Color del borde (opcional)
  final Color borderColor;

  /// Grosor del borde (opcional)
  final double borderWidth;

  /// Ruta de la imagen (opcional)
  final String? imagePath;

  const WhiteBoxTextComponent({
    super.key,
    required this.text,
    this.isForImage = false,
    this.style,
    this.borderColor = Colors.black, // Color del borde por defecto
    this.borderWidth = 1.0, // Grosor del borde por defecto
    this.imagePath, // Ruta de la imagen
  });

  TextStyle? getStyle(BuildContext context) {
    final controller = Get.find<ControllerTeach>();
    final screenWidth = MediaQuery.of(context).size.width;

    // Tamaños de fuente mínimos y máximos
    const double minFontSize = 16.0;
    const double maxFontSize = 32.0;

    // Calcular el tamaño de fuente base
    double baseFontSize = (screenWidth * 0.015).clamp(minFontSize, maxFontSize);

    if (isForImage) {
      return Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: baseFontSize,
        fontWeight: FontWeight.bold,
      );
    }

    if (controller.imagenes.isEmpty) {
      return Theme.of(context).textTheme.displayMedium?.copyWith(
        fontSize: baseFontSize * 1.5,
        fontWeight: FontWeight.bold,
      );
    } else {
      return Theme.of(context).textTheme.titleLarge?.copyWith(
        fontSize: baseFontSize * 1.2,
        fontWeight: FontWeight.w600,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ), // Agregar borde
        borderRadius: BorderRadius.circular(
          3.0,
        ), // Bordes redondeados (opcional)
      ),
      padding: const EdgeInsets.all(10.0), // Espaciado interno
      child: Center(
        child:
            isForImage &&
                imagePath !=
                    null // Verifica si es para imagen y si hay una ruta de imagen
            ? Image.asset(
                imagePath!, // Carga la imagen desde la ruta especificada
                fit: BoxFit.cover, // Ajusta la imagen
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: style ?? getStyle(context),
              ),
      ),
    );
  }
}
