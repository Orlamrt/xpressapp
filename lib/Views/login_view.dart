import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ControllerTeach controller = Get.find<ControllerTeach>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        titleTextStyle: const TextStyle(
          fontSize: 32,
          color: Color(0xDDD96C94),
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        backgroundColor: const Color(0xFFF2DCD8),
      ),
      backgroundColor: const Color(0xFFF2DCD8),
      body: Obx(() {
        // Verifica si el usuario ya está autenticado y redirige si es necesario
        if (controller.isAuthenticated.value) {
          Future.delayed(Duration.zero, () {
            controller.navigateByRole();
          });
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (imports y código anterior se mantienen igual)

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Color(0xDDD96C94),
                    fontSize: 18,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Color(0xDDD96C94),
                    fontSize: 20,
                  ),
                  prefixIcon: Icon(Icons.email, color: Color(0xDDD96C94)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Color(0xDDD96C94)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Color(0xDDD96C94)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Color(0xDDD96C94),
                      width: 2.0,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                    color: Color(0xDDD96C94),
                    fontSize: 18,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Color(0xDDD96C94),
                    fontSize: 20,
                  ),
                  prefixIcon: Icon(Icons.lock, color: Color(0xDDD96C94)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Color(0xDDD96C94)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Color(0xDDD96C94)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Color(0xDDD96C94),
                      width: 2.0,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                obscureText: true,
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  String email = emailController.text;
                  String password = passwordController.text;

                  bool success = await controller.loginUser(email, password);

                  if (success) {
                    // Redirigir según el rol del usuario usando el método del controlador
                    await controller.navigateByRole();
                  } else {
                    // Mostrar un mensaje de error
                    Get.snackbar(
                      'Error',
                      'Email o contraseña incorrectos',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xDDD96C94),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  elevation: 15,
                  shadowColor: const Color(0xDDD96C94),
                ),
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}
