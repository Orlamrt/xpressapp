import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  final controller = Get.find<ControllerTeach>();

  String? selectedRole;
  bool isTherapist = false;

  // ... (imports y código anterior se mantienen igual)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        titleTextStyle: const TextStyle(
          fontSize: 32,
          color: Color(0xDDD96C94),
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        backgroundColor: const Color(0xFFF2DCD8),
      ),
      body: Container(
        color: const Color(0xFFF2DCD8),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2DCD8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(
                        color: Color(0xDDD96C94),
                        fontSize: 18,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Color(0xDDD96C94),
                        fontSize: 20,
                      ),
                      prefixIcon: Icon(Icons.person, color: Color(0xDDD96C94)),
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
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
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
                  TextFormField(
                    controller: birthDateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Nacimiento',
                      labelStyle: TextStyle(
                        color: Color(0xDDD96C94),
                        fontSize: 18,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Color(0xDDD96C94),
                        fontSize: 20,
                      ),
                      prefixIcon: Icon(Icons.cake, color: Color(0xDDD96C94)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today,
                            color: Color(0xDDD96C94)),
                        onPressed: () => _selectDate(context),
                      ),
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
                    readOnly: true,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      labelStyle: TextStyle(
                        color: Color(0xDDD96C94),
                        fontSize: 18,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Color(0xDDD96C94),
                        fontSize: 20,
                      ),
                      prefixIcon:
                          Icon(Icons.people_alt, color: Color(0xDDD96C94)),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    dropdownColor: Color(0xFFF2DCD8),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    items: ['Paciente', 'Terapeuta', 'Tutor'].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                        isTherapist = value == 'Terapeuta';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isTherapist) ...[
                    TextFormField(
                      controller: licenseController,
                      decoration: InputDecoration(
                        labelText: 'Cédula Profesional',
                        labelStyle: TextStyle(
                          color: Color(0xDDD96C94),
                          fontSize: 18,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xDDD96C94),
                          fontSize: 20,
                        ),
                        prefixIcon: Icon(Icons.medical_services,
                            color: Color(0xDDD96C94)),
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
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: () async {
                      String nombre = nameController.text;
                      String email = emailController.text;
                      String password = passwordController.text;
                      String fechaNacimiento = birthDateController.text;

                      // Validar que se seleccione un rol
                      if (selectedRole == null) {
                        Get.snackbar('Error', 'Por favor, seleccione un rol');
                        return;
                      }

                      if (isTherapist) {
                        String license = licenseController.text;
                        if (license.isEmpty) {
                          Get.snackbar('Error',
                              'Por favor, ingrese su cédula profesional');
                          return;
                        }
                        await controller.registerUser(
                          nombre,
                          email,
                          password,
                          selectedRole!, // Asegúrate de pasar el rol seleccionado
                          fechaNacimiento: fechaNacimiento,
                          license: license,
                        );
                      } else {
                        await controller.registerUser(
                          nombre,
                          email,
                          password,
                          selectedRole!, // Asegúrate de pasar el rol seleccionado
                          fechaNacimiento: fechaNacimiento,
                        );
                      }

                      // Mostrar un AlertDialog de confirmación
                      _showConfirmationDialog();
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
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// ... (resto del código se mantiene igual)

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        birthDateController.text =
            "${picked.toLocal()}".split(' ')[0]; // Formato de fecha YYYY-MM-DD
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registro Exitoso'),
          content: const Text('Su registro se realizó correctamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
