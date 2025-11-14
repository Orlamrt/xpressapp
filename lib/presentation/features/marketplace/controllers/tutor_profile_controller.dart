import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/data/datasources/local/local_storage.dart';
import 'package:xpressatec/data/datasources/marketplace_api_datasource.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

class TutorProfileController extends GetxController {
  TutorProfileController({
    required this.datasource,
    required this.authController,
    required this.localStorage,
  });

  final MarketplaceApiDatasource datasource;
  final AuthController authController;
  final LocalStorage localStorage;

  final formKey = GlobalKey<FormState>();
  final isSaving = false.obs;
  final selectedSector = 'PR'.obs;

  final emailCtrl = TextEditingController();
  final cedulaCtrl = TextEditingController();
  final especialidadCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  final celCtrl = TextEditingController();
  final correoAltCtrl = TextEditingController();
  final redSocialCtrl = TextEditingController();
  final waCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeEmail();
  }

  Future<void> _initializeEmail() async {
    final String? email = _getEmailFromAuth();
    if (email != null) {
      emailCtrl.text = email;
      return;
    }

    final String? storedEmail = await _getEmailFromStorage();
    if (storedEmail != null) {
      emailCtrl.text = storedEmail;
      authController.userEmail.value = storedEmail;
    }
  }

  String? _getEmailFromAuth() {
    final String emailFromState = authController.userEmail.value.trim();
    if (emailFromState.isNotEmpty) {
      return emailFromState;
    }

    final String? emailFromUser = authController.currentUser.value?.email;
    if (emailFromUser != null && emailFromUser.trim().isNotEmpty) {
      final String normalized = emailFromUser.trim();
      authController.userEmail.value = normalized;
      return normalized;
    }

    return null;
  }

  Future<String?> _getEmailFromStorage() async {
    try {
      final Map<String, dynamic>? storedUser = await localStorage.getUser();
      if (storedUser == null) {
        return null;
      }

      final dynamic emailCandidate = storedUser['email'] ??
          storedUser['Email'] ??
          storedUser['correo'] ??
          storedUser['Correo'];
      if (emailCandidate is String) {
        final String normalized = emailCandidate.trim();
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    } catch (_) {
      // Ignored: fallback retrieval should not break initialization
    }
    return null;
  }

  void changeSector(String sector) {
    if (sector == 'PR' || sector == 'PU' || sector == 'AM') {
      selectedSector.value = sector;
    }
  }

  String? validateEmail(String? value) {
    final String email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? validateCedula(String? value) {
    final String cedula = (value ?? '').trim();
    if (cedula.isEmpty) {
      return 'La cédula profesional es obligatoria';
    }
    return null;
  }

  Future<void> saveProfile() async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving.value = true;
    try {
      final Map<String, dynamic> response = await datasource.upsertTutorProfile(
        email: emailCtrl.text.trim(),
        cedula: cedulaCtrl.text.trim(),
        especialidad: especialidadCtrl.text.trim(),
        tipoSector: selectedSector.value,
        telefono: telCtrl.text.trim(),
        celular: celCtrl.text.trim(),
        correoAlternativo: correoAltCtrl.text.trim(),
        redSocial: redSocialCtrl.text.trim(),
        whatsapp: waCtrl.text.trim(),
        token: localStorage.getToken(),
      );

      final String message = (response['message'] as String?) ??
          'Perfil de terapeuta actualizado correctamente para el marketplace.';
      Get.snackbar('Éxito', message);
    } on MarketplaceApiException catch (e) {
      final String backendMessage = (e.message?.trim().isNotEmpty ?? false)
          ? e.message!.trim()
          : 'Ocurrió un error al actualizar el perfil.';
      Get.snackbar('Error', backendMessage);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    cedulaCtrl.dispose();
    especialidadCtrl.dispose();
    telCtrl.dispose();
    celCtrl.dispose();
    correoAltCtrl.dispose();
    redSocialCtrl.dispose();
    waCtrl.dispose();
    super.onClose();
  }
}
