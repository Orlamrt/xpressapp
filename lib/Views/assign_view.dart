import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart'; // Asegúrate de tener la ruta correcta al controlador

class AssignView extends StatelessWidget {
  final ControllerTeach controller = Get.put(ControllerTeach());

  // Variables para almacenar los emails seleccionados
  String? selectedPatientEmail;
  String? selectedTutorEmail;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Asignar Tutor a Paciente'),
          backgroundColor: const Color(0xFFF2DCD8),
          titleTextStyle: const TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ), automaticallyImplyLeading: false,
        ),
        backgroundColor: const Color(0xFFF2DCD8),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown para seleccionar un paciente
              Obx(
                () => DropdownButton<String>(
                  hint: const Text('Selecciona un paciente'),
                  value: selectedPatientEmail,
                  items: controller.patients
                      .map(
                        (patient) => DropdownMenuItem(
                          value: patient.email,
                          child: Text(patient.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selectedPatientEmail = value;
                  },
                  isExpanded: true,
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown para seleccionar un tutor
              Obx(
                () => DropdownButton<String>(
                  hint: const Text('Selecciona un tutor'),
                  value: selectedTutorEmail,
                  items: controller.tutors
                      .map(
                        (tutor) => DropdownMenuItem(
                          value: tutor.email,
                          child: Text(tutor.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selectedTutorEmail = value;
                  },
                  isExpanded: true,
                ),
              ),
              const SizedBox(height: 16),

              // Botón para asignar el tutor al paciente
              ElevatedButton(
                onPressed: () {
                  if (selectedTutorEmail != null && selectedPatientEmail != null) {
                    // Asignar tutor al paciente seleccionado
                    controller.assignTutorToPatient(selectedTutorEmail!, selectedPatientEmail!);
                  } else {
                    // Mostrar mensaje de error si no se han seleccionado ambos
                    Get.snackbar(
                      'Error',
                      'Por favor selecciona un tutor y un paciente',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
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
                child: const Text('Asignar Paciente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
