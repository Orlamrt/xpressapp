import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Views/principal_view_Paciente.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    // 1) animamos entrada
    _c.forward();

    // 2) esperamos un poco y hacemos salida suave hacia la siguiente pantalla
    Future.delayed(const Duration(seconds: 5), () async {
      // animación de salida opcional 
     _c.duration = const Duration(milliseconds: 300); // duración para la salida
await _c.reverse();

      if (!mounted) return;
      Get.off(
  () => const PrincipalViewPaciente(),
  transition: Transition.fadeIn,
  duration: const Duration(milliseconds: 320),
);

    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2DCD8),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO
                Image.asset("assets/imagenes/XpressaLogo.png", height: 120),
                const SizedBox(height: 16),
                // TÍTULO
                Text(
                  "XPRESSATEC",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(0xDDD96C94),
                      ),
                ),
                const SizedBox(height: 8),
                // SUBTÍTULO
                Text(
                  "Un mundo de palabras a un toque",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
