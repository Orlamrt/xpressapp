import 'package:flutter/material.dart';
import 'dart:io';

class ImageModel {
  final String imagePath;
  final Color? color;
  final bool isLocal; // Indica si la imagen es local o no
  String? nameOfImage;

  // Constructor que inicializa isLocal según la ruta de la imagen
  ImageModel({
    required this.imagePath,
    this.nameOfImage,
    this.color,
  }) : isLocal =
            imagePath.startsWith('/data/') || imagePath.contains('/imagenes/') {
    nameOfImage ??= processName(imagePath);
  }

  // Método estático para obtener la lista de imágenes específicas filtradas por contenido
  static List<ImageModel> getEspecificListModel(
      List<String> list, String contains, Color color) {
    List<ImageModel> imagenesModel = [];
    for (int i = 0; i < list.length; i++) {
      if (list[i].contains(contains)) {
        final imageModel = ImageModel(
          imagePath: list[i],
          color: color,
        );
        imagenesModel.add(imageModel);
      }
    }
    return imagenesModel;
  }

  // Método estático para obtener una lista completa de imágenes
  static List<ImageModel> getListModel(List<String> list, Color color) {
    List<ImageModel> imagenesModel = [];
    for (int i = 0; i < list.length; i++) {
      final imageModel = ImageModel(
        imagePath: list[i],
        color: color,
      );
      imagenesModel.add(imageModel);
    }
    return imagenesModel;
  }

  // Método para obtener el nombre de la carpeta desde la ruta de la imagen
  static String getFolderName(String imagePath) {
    List<String> path = imagePath.split('/');
    String name = path[path.length - 2];
    return capitalize(validateName(name));
  }

  // Método para procesar el nombre de la imagen
  static String processName(String imagePath) {
    String image = imagePath.split('/').last;
    String name = validateName(image.split('.').first);
    return capitalize(name);
  }

  // Método para capitalizar la primera letra de una palabra
  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  // Método para reemplazar guiones bajos por espacios
  static String validateName(String s) => s.replaceAll('_', ' ');

  // Método para determinar si la imagen es local o un asset
  bool get isAsset => !isLocal; // Si no es local, entonces es un asset
}
