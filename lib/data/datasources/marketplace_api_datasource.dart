import 'dart:convert';

import 'package:http/http.dart' as http;

class MarketplaceApiException implements Exception {
  MarketplaceApiException(this.statusCode, this.message);

  final int statusCode;
  final String? message;

  @override
  String toString() => 'MarketplaceApiException($statusCode): $message';
}

class MarketplaceApiDatasource {
  MarketplaceApiDatasource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> upsertTutorProfile({
    required String email,
    required String cedula,
    String? especialidad,
    required String tipoSector,
    String? telefono,
    String? celular,
    String? correoAlternativo,
    String? redSocial,
    String? whatsapp,
    String? token,
  }) async {
    final Uri url =
        Uri.parse('https://xpressatec.online/marketplace/terapeuta/profile');

    String? _normalize(String? value) {
      if (value == null) {
        return null;
      }
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer ${token.trim()}',
    };

    final Map<String, String> contacto = <String, String>{};
    void addContacto(String key, String? value) {
      final String? normalized = _normalize(value);
      if (normalized != null) {
        contacto[key] = normalized;
      }
    }

    addContacto('Telefono', telefono);
    addContacto('Celular', celular);
    addContacto('Correo', correoAlternativo);
    addContacto('RedSocial', redSocial);
    addContacto('WhatsApp', whatsapp);

    final Map<String, dynamic> body = <String, dynamic>{
      'email': email.trim(),
      'cedula_profesional': cedula.trim(),
      'tipo_sector': tipoSector.trim(),
    };

    final String? normalizedEspecialidad = _normalize(especialidad);
    if (normalizedEspecialidad != null) {
      body['especialidad'] = normalizedEspecialidad;
    }

    if (contacto.isNotEmpty) {
      body['contacto'] = contacto;
    }

    final http.Response response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    Map<String, dynamic> decoded = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      try {
        final dynamic json = jsonDecode(response.body);
        if (json is Map<String, dynamic>) {
          decoded = json;
        }
      } catch (_) {
        decoded = <String, dynamic>{};
      }
    }

    if (response.statusCode == 200) {
      return <String, dynamic>{
        'success': true,
        'message': decoded['message'] is String
            ? decoded['message'] as String
            : 'Perfil de terapeuta actualizado correctamente para el marketplace.',
        'data': decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : <String, dynamic>{},
      };
    }

    final String errorMessage = decoded['message'] is String
        ? decoded['message'] as String
        : 'Error al comunicarse con el servicio (código ${response.statusCode}).';
    throw MarketplaceApiException(response.statusCode, errorMessage);
  }

  @Deprecated('Usa upsertTutorProfile en su lugar')
  Future<void> upsertProfile(Map<String, dynamic> payload) async {
    final Uri url =
        Uri.parse('https://xpressatec.online/marketplace/terapeuta/profile');
    final http.Response res = await _client.post(
      url,
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final String? message = res.body.isEmpty ? null : res.body;
      throw MarketplaceApiException(res.statusCode, message);
    }
  }
}
