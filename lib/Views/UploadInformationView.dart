import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart'; // Asegúrate de que la ruta de importación sea correcta.

class UploadInformationView extends StatelessWidget {
  final ControllerTeach controller = Get.find<ControllerTeach>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subir Información'),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF2DCD8),
          titleTextStyle: const TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: const Color(0xFFF2DCD8),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(
                  labelText: 'Especialización',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Biografía',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _submitInformation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xDDD96C94),
                  foregroundColor: const Color(0xFFF2DCD8),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  elevation: 15,
                  shadowColor: const Color(0xDDD96C94),
                ),
                child: const Text('Guardar Información'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitInformation() {
    final name = nameController.text;
    final specialization = specializationController.text;
    final bio = bioController.text;

    if (name.isEmpty || specialization.isEmpty || bio.isEmpty) {
      Get.snackbar(
        'Error',
        'Todos los campos son obligatorios',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Aquí puedes agregar la lógica para subir la información al servidor o guardarla en algún lugar.
    // Por ejemplo, puedes llamar a un método en el controlador para manejar el envío.

    // Ejemplo de cómo podrías hacerlo:
    controller.uploadTherapistInformation(name, specialization, bio);

    //  Notificación local de éxito
    Get.find<ControllerTeach>().notificationService.showProgressAchievement(
      ' Información del terapeuta guardada exitosamente',
    );

    Get.snackbar(
      'Éxito',
      'La información se ha guardado correctamente',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
