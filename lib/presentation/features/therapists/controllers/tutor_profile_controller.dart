import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/datasources/local/local_storage.dart';
import '../../../../data/datasources/marketplace_api_datasource.dart';
import '../../auth/controllers/auth_controller.dart';

class TutorProfileController extends GetxController {
  TutorProfileController({
    required this.datasource,
    required this.authController,
    required this.localStorage,
  });

  final MarketplaceApiDatasource datasource;
  final AuthController authController;
  final LocalStorage localStorage;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nombreCompletoController = TextEditingController();
  final TextEditingController cedulaProfesionalController = TextEditingController();
  final TextEditingController especialidadController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController precioConsultaController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController horariosController = TextEditingController();
  final TextEditingController contactoEmailController = TextEditingController();
  final TextEditingController contactoTelefonoController = TextEditingController();

  final RxList<String> selectedModalidades = <String>[].obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  void toggleModalidad(String modalidad) {
    if (selectedModalidades.contains(modalidad)) {
      selectedModalidades.remove(modalidad);
    } else {
      selectedModalidades.add(modalidad);
    }
  }

  bool isModalidadSeleccionada(String modalidad) {
    return selectedModalidades.contains(modalidad);
  }

  Future<String?> _ensureCorreo() async {
    final String emailFromState = authController.userEmail.value.trim();
    if (emailFromState.isNotEmpty) {
      return emailFromState;
    }

    final String? emailFromUser = authController.currentUser.value?.email;
    if (emailFromUser != null && emailFromUser.isNotEmpty) {
      authController.userEmail.value = emailFromUser;
      return emailFromUser;
    }

    final Map<String, dynamic>? storedUser = await localStorage.getUser();
    if (storedUser != null) {
      final dynamic storedEmail =
          storedUser['email'] ?? storedUser['Email'] ?? storedUser['correo'] ?? storedUser['Correo'];
      if (storedEmail is String && storedEmail.isNotEmpty) {
        authController.userEmail.value = storedEmail;
        return storedEmail;
      }
    }

    return null;
  }

  Future<void> save() async {
    final formState = formKey.currentState;
    if (formState == null) {
      return;
    }

    if (!formState.validate()) {
      return;
    }

    if (selectedModalidades.isEmpty) {
      Get.snackbar(
        'Modalidades requeridas',
        'Selecciona al menos una modalidad de atención.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String? correo = await _ensureCorreo();
    if (correo == null || correo.isEmpty) {
      errorMessage.value = 'No se pudo obtener el correo del terapeuta.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      'correo': correo,
      'nombre': nombreCompletoController.text.trim(),
      'cedula': cedulaProfesionalController.text.trim(),
      'especialidad': especialidadController.text.trim(),
      'modalidades': selectedModalidades.toList(),
    };

    final String bio = bioController.text.trim();
    if (bio.isNotEmpty) {
      payload['bio'] = bio;
    }

    final String precioText = precioConsultaController.text.trim().replaceAll(',', '.');
    if (precioText.isNotEmpty) {
      final double? precio = double.tryParse(precioText);
      if (precio == null) {
        Get.snackbar(
          'Precio inválido',
          'Ingresa un precio válido (solo números y decimales).',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      payload['precioConsulta'] = precio;
    }

    final String estado = estadoController.text.trim();
    final String ciudad = ciudadController.text.trim();
    if (estado.isNotEmpty || ciudad.isNotEmpty) {
      payload['ubicacion'] = <String, String>{
        if (estado.isNotEmpty) 'estado': estado,
        if (ciudad.isNotEmpty) 'ciudad': ciudad,
      };
    }

    final String horariosText = horariosController.text.trim();
    if (horariosText.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(horariosText);
        if (decoded is Map<String, dynamic>) {
          payload['horarios'] = decoded;
        } else {
          throw const FormatException('El JSON debe ser un objeto.');
        }
      } on FormatException catch (e) {
        errorMessage.value = e.message;
        Get.snackbar(
          'Horarios inválidos',
          'Revisa el formato JSON de los horarios.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final String contactoEmail = contactoEmailController.text.trim();
    final String contactoTelefono = contactoTelefonoController.text.trim();
    if (contactoEmail.isNotEmpty || contactoTelefono.isNotEmpty) {
      payload['contacto'] = <String, dynamic>{
        if (contactoEmail.isNotEmpty) 'email': contactoEmail,
        if (contactoTelefono.isNotEmpty) 'telefono': contactoTelefono,
      };
    }

    try {
      isSaving.value = true;
      errorMessage.value = '';

      await datasource.upsertProfile(payload);

      FocusManager.instance.primaryFocus?.unfocus();
      Get.snackbar(
        '¡Perfil actualizado!',
        'Tu información se guardó correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'No se pudo guardar tu información. Inténtalo nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nombreCompletoController.dispose();
    cedulaProfesionalController.dispose();
    especialidadController.dispose();
    bioController.dispose();
    precioConsultaController.dispose();
    estadoController.dispose();
    ciudadController.dispose();
    horariosController.dispose();
    contactoEmailController.dispose();
    contactoTelefonoController.dispose();
    super.onClose();
  }
}
