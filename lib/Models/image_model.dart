import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Modelo para representar una imagen, sea asset o archivo local
class ImageModel {
  final String imagePath;
  final Color? color;
  final bool isLocal; // Indica si es un archivo local
  String? nameOfImage;

  ImageModel({required this.imagePath, this.nameOfImage, this.color})
    : isLocal =
          !kIsWeb && // En Web nunca será local
          (imagePath.startsWith('/data/') || imagePath.contains('/imagenes/')) {
    nameOfImage ??= processName(imagePath);
  }

  /// Lista filtrada por contenido
  static List<ImageModel> getEspecificListModel(
    List<String> list,
    String contains,
    Color color,
  ) {
    return list
        .where((p) => p.contains(contains))
        .map((p) => ImageModel(imagePath: p, color: color))
        .toList();
  }

  /// Lista completa
  static List<ImageModel> getListModel(List<String> list, Color color) {
    return list.map((p) => ImageModel(imagePath: p, color: color)).toList();
  }

  /// Nombre de la carpeta
  static String getFolderName(String imagePath) {
    List<String> path = imagePath.split('/');
    String name = path[path.length - 2];
    return capitalize(validateName(name));
  }

  /// Nombre a partir de la ruta
  static String processName(String imagePath) {
    String image = imagePath.split('/').last;
    String name = validateName(image.split('.').first);
    return capitalize(name);
  }

  static String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
  static String validateName(String s) => s.replaceAll('_', ' ');

  /// En Web siempre es asset, en móvil depende
  bool get isAsset => kIsWeb || !isLocal;
}
