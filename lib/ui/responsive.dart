// lib/ui/responsive.dart
import 'dart:math';
import 'package:flutter/widgets.dart';

/// Escala base según el lado más corto (teléfono vs tablet).
/// 390 es un ancho base típico (iPhone 12/Pixel). Ajusta si tu diseño base es otro.
double rs(BuildContext context) {
  final s = MediaQuery.of(context).size;
  final shortest = min(s.width, s.height);
  return (shortest / 390).clamp(0.85, 1.35);
}
