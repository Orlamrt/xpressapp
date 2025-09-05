import 'package:flutter/material.dart';

/// Clase que se encarga de mostrar un circulo rojo con una cruz blanca
/// en el centro para indicar que se va a eliminar algo o que ya fue eliminado
class RedCircleWithCross extends StatelessWidget {
  /// Funcion que se va a ejecutar cuando se presione el circulo
  final void Function()? onTap;

  const RedCircleWithCross({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 20),
      ),
    );
  }
}
