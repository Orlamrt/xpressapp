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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isSaving = false.obs;
  final RxString selectedSector = 'PR'.obs;

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController cedulaCtrl = TextEditingController();
  final TextEditingController especialidadCtrl = TextEditingController();
  final TextEditingController telCtrl = TextEditingController();
  final TextEditingController celCtrl = TextEditingController();
  final TextEditingController correoAltCtrl = TextEditingController();
  final TextEditingController redSocialCtrl = TextEditingController();
  final TextEditingController waCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final String userEmail = _resolveUserEmail();
    emailCtrl.text = userEmail;
  }

  String _resolveUserEmail() {
    final String reactiveEmail = authController.userEmail.value.trim();
    if (reactiveEmail.isNotEmpty) {
      return reactiveEmail;
    }
    final String? currentEmail = authController.currentUser.value?.email;
    if (currentEmail != null && currentEmail.trim().isNotEmpty) {
      return currentEmail.trim();
    }
    return '';
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
    final String? token = localStorage.getToken();

    try {
      final Map<String, dynamic> result = await datasource.upsertTutorProfile(
        email: emailCtrl.text.trim(),
        cedula: cedulaCtrl.text.trim(),
        especialidad: especialidadCtrl.text.trim(),
        tipoSector: selectedSector.value,
        telefono: telCtrl.text,
        celular: celCtrl.text,
        correoAlternativo: correoAltCtrl.text,
        redSocial: redSocialCtrl.text,
        whatsapp: waCtrl.text,
        token: token,
      );

      final String message = (result['message'] as String?) ??
          'Perfil de terapeuta actualizado correctamente para el marketplace.';
      Get.snackbar('Éxito', message);
    } on MarketplaceApiException catch (e) {
      final String backendMessage = (e.message ?? '').trim().isNotEmpty
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
