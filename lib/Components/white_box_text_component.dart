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
    // definimos el estilo del texto en caso de que sea para una imagen
    if (isForImage) {
      return Theme.of(context).textTheme.bodyMedium;
    }
    // modificamos la interfaz para cuando haya datos en la lista
    if (controller.imagenes.isEmpty) {
      return Theme.of(context).textTheme.displayMedium;
    } else {
      return Theme.of(context).textTheme.titleLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border.all(color: borderColor, width: borderWidth), // Agregar borde
        borderRadius:
            BorderRadius.circular(3.0), // Bordes redondeados (opcional)
      ),
      padding: const EdgeInsets.all(10.0), // Espaciado interno
      child: Center(
        child: isForImage &&
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
