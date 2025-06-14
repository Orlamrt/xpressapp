import 'package:flutter/material.dart';

class Pallete {

  Pallete();
  
  // Generamos todos los colores que usaremos a lo largo de la aplicacion
  final Color rosa = Colors.pink[300]!;
  static const Color azul = Colors.blue;
  static const Color verde = Colors.green;
  final Color amarillo = Colors.yellow[600]!;
  final Color rojo = Colors.red[600]!;
  static const Color cafe = Colors.brown;
  static const Color morado = Colors.purple;
  static const Color naranja = Colors.orange;

  // generamos una lista con esos colores para usarla en cualquier lado de la app
  late List<Color> colores = [
    amarillo,
    rosa,
    verde,
    azul,
    cafe,
    rojo,
    morado,
    naranja,
  ];
}