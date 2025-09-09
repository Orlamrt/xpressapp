// lib/ui/tokens.dart
import 'package:flutter/material.dart';
import 'responsive.dart';

/// Tamaños escalables para iconos, fuentes, espacios y tarjetas.
class Sz {
  static double iconSm(BuildContext c) => 20 * rs(c);
  static double iconMd(BuildContext c) => 28 * rs(c);
  static double iconLg(BuildContext c) => 36 * rs(c);

  static double gapXs(BuildContext c) => 6 * rs(c);
  static double gapSm(BuildContext c) => 10 * rs(c);
  static double gapMd(BuildContext c) => 14 * rs(c);
  static double gapLg(BuildContext c) => 18 * rs(c);

  static double fontSm(BuildContext c) => 13 * rs(c);
  static double fontMd(BuildContext c) => 16 * rs(c);
  static double fontLg(BuildContext c) => 20 * rs(c);
  static double titleXL(BuildContext c) => 28 * rs(c);

  /// Tamaño “deseado” de la tarjeta/cuadrícula en dp (ancho).
  static double tileW(BuildContext c) => 170 * rs(c);
  /// Altura preferida del tile (ajusta si usas textos largos).
  static double tileH(BuildContext c) => 210 * rs(c);
}
