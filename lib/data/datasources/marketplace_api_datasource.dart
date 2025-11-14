import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:xpressatec/data/models/terapeuta_marketplace.dart';

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
  static const String _base = 'https://xpressatec.online';

  Future<List<TerapeutaMarketplace>> fetchPublicTerapeutas({
    String? sector,
    String? especialidad,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final Uri uri = Uri.parse('$_base/marketplace/public/terapeutas').replace(
      queryParameters: <String, String>{
        if (sector != null && sector.isNotEmpty) 'sector': sector,
        if (especialidad != null && especialidad.isNotEmpty)
          'especialidad': especialidad,
        if (search != null && search.isNotEmpty) 'search': search,
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final http.Response response = await _client.get(
      uri,
      headers: const {'Content-Type': 'application/json'},
    );

    Map<String, dynamic>? decoded;
    if (response.body.isNotEmpty) {
      try {
        final dynamic json = jsonDecode(response.body);
        if (json is Map<String, dynamic>) {
          decoded = json;
        }
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode != 200) {
      final String? message = decoded != null && decoded['message'] is String
          ? decoded!['message'] as String
          : 'Error al comunicarse con el servicio (código ${response.statusCode}).';
      throw MarketplaceApiException(response.statusCode, message);
    }

    if (decoded == null || decoded['success'] != true) {
      final String? message = decoded != null && decoded['message'] is String
          ? decoded['message'] as String
          : 'No fue posible obtener la información de terapeutas.';
      throw MarketplaceApiException(response.statusCode, message);
    }

    final dynamic data = decoded['data'];
    if (data is! List) {
      throw MarketplaceApiException(
        response.statusCode,
        'La respuesta del servicio no contiene la lista de terapeutas.',
      );
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(TerapeutaMarketplace.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> upsertTutorProfile({
    required String email,
    required String cedula,
    String? especialidad,
    String? tipoSector,
    String? telefono,
    String? celular,
    String? correoAlternativo,
    String? redSocial,
    String? whatsapp,
    String? token,
  }) async {
    final Uri uri = Uri.parse('$_base/marketplace/terapeuta/profile');

    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.trim().isNotEmpty) 'Authorization': 'Bearer ${token.trim()}',
    };

    String? _normalize(String? value) {
      if (value == null) {
        return null;
      }
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

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
      'especialidad': _normalize(especialidad),
      'tipo_sector': _normalize(tipoSector) ?? 'PR',
      'contacto': contacto.isEmpty ? null : contacto,
    };

    body.removeWhere((String key, dynamic value) => value == null);

    final http.Response response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    Map<String, dynamic>? decoded;
    if (response.body.isNotEmpty) {
      try {
        final dynamic json = jsonDecode(response.body);
        if (json is Map<String, dynamic>) {
          decoded = json;
        }
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> result = <String, dynamic>{
        'success': true,
        'message': decoded != null && decoded['message'] is String
            ? decoded!['message'] as String
            : 'Perfil de terapeuta actualizado correctamente para el marketplace.',
        'data': decoded != null && decoded['data'] is Map<String, dynamic>
            ? decoded!['data'] as Map<String, dynamic>
            : decoded,
      };
      return result;
    }

    final String? message = decoded != null && decoded['message'] is String
        ? decoded['message'] as String
        : 'Error al comunicarse con el servicio (código ${response.statusCode}).';
    throw MarketplaceApiException(response.statusCode, message);
  }

  @Deprecated('Usa upsertTutorProfile en su lugar')
  Future<void> upsertProfile(Map<String, dynamic> payload) async {
    final Uri uri = Uri.parse('$_base/marketplace/terapeuta/profile');
    final http.Response res = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final String? message = res.body.isEmpty ? null : res.body;
      throw MarketplaceApiException(res.statusCode, message);
    }
  }
}
