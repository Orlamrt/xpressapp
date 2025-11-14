import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/data/datasources/local/local_storage.dart';
import 'package:xpressatec/data/datasources/marketplace_api_datasource.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

class TutorProfileController extends GetxController {
  TutorProfileController({
    MarketplaceApiDatasource? marketplaceApi,
    AuthController? authController,
    LocalStorage? localStorage,
  })  : marketplaceApi = marketplaceApi ?? Get.find<MarketplaceApiDatasource>(),
        authController = authController ?? Get.find<AuthController>(),
        _localStorage = localStorage ?? (Get.isRegistered<LocalStorage>() ? Get.find<LocalStorage>() : null);

  final MarketplaceApiDatasource marketplaceApi;
  final AuthController authController;
  final LocalStorage? _localStorage;

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
    final LocalStorage? storage = _localStorage;
    if (storage == null) {
      return null;
    }

    try {
      final Map<String, dynamic>? storedUser = await storage.getUser();
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

    final String email = emailCtrl.text.trim();
    final String cedula = cedulaCtrl.text.trim();
    if (email.isEmpty || cedula.isEmpty) {
      Get.snackbar('Campos requeridos', 'Email y cédula profesional son obligatorios');
      return;
    }

    isSaving.value = true;
    try {
      final Map<String, dynamic> payload = {
        'email': email,
        'cedula_profesional': cedula,
        'especialidad': _opt(especialidadCtrl.text),
        'tipo_sector': selectedSector.value,
        'contacto': _compact({
          'Telefono': _opt(telCtrl.text),
          'Celular': _opt(celCtrl.text),
          'Correo': _opt(correoAltCtrl.text),
          'RedSocial': _opt(redSocialCtrl.text),
          'WhatsApp': _opt(waCtrl.text),
        }),
      };

      payload.removeWhere((key, value) => value == null || (value is Map && value.isEmpty));

      await marketplaceApi.upsertProfile(payload);

      Get.snackbar('Éxito', 'Perfil actualizado correctamente');
    } on MarketplaceApiException catch (e) {
      if (e.statusCode == 404) {
        Get.snackbar('No encontrado', 'No existe un usuario con ese correo');
      } else if (e.statusCode == 400) {
        Get.snackbar('Datos inválidos', 'Faltan email y/o cédula profesional');
      } else {
        Get.snackbar('Error', e.message ?? 'Error de servidor');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  String? _opt(String? value) {
    final String trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, dynamic> _compact(Map<String, dynamic?> source) {
    final Map<String, dynamic> result = <String, dynamic>{};
    source.forEach((String key, dynamic value) {
      if (value == null) {
        return;
      }
      if (value is String) {
        final String trimmed = value.trim();
        if (trimmed.isEmpty) {
          return;
        }
        result[key] = trimmed;
      } else {
        result[key] = value;
      }
    });
    return result;
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
