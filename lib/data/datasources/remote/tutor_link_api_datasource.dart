import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/link_tutor_response_model.dart';

abstract class TutorLinkApiDatasource {
  Future<LinkTutorResponseModel> linkTutorWithPatient({
    required String patientUuid,
    required String tutorEmail,
  });
}

class TutorLinkApiDatasourceImpl implements TutorLinkApiDatasource {
  TutorLinkApiDatasourceImpl({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = 'https://xpressatec.online';

  final http.Client _client;
  final String _baseUrl;

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
      };

  Uri _buildUri(String path) => Uri.parse('$_baseUrl$path');

  @override
  Future<LinkTutorResponseModel> linkTutorWithPatient({
    required String patientUuid,
    required String tutorEmail,
  }) async {
    final response = await _client.post(
      _buildUri('link/link-tutor-patient'),
      headers: _headers,
      body: jsonEncode({
        'patient_uuid': patientUuid,
        'tutor_email': tutorEmail,
      }),
    );

    final decoded = _decodeResponseBody(response);
    final message = _extractMessage(decoded);

    switch (response.statusCode) {
      case 200:
        return LinkTutorResponseModel(
          success: true,
          message:
              message ?? 'Paciente vinculado correctamente.',
        );
      case 404:
        return LinkTutorResponseModel(
          success: false,
          message:
              message ?? 'Paciente o tutor no encontrado.',
        );
      case 409:
        return LinkTutorResponseModel(
          success: false,
          message: message ?? 'Este paciente ya está vinculado a otro tutor.',
        );
      case 500:
        return LinkTutorResponseModel(
          success: false,
          message: message ?? 'Ocurrió un error en el servidor.',
        );
      default:
        return LinkTutorResponseModel(
          success: false,
          message:
              message ?? 'No se pudo vincular al paciente. Inténtalo de nuevo.',
        );
    }
  }

  dynamic _decodeResponseBody(http.Response response) {
    try {
      if (response.bodyBytes.isEmpty) {
        return null;
      }
      final decodedBody = utf8.decode(response.bodyBytes);
      if (decodedBody.isEmpty) {
        return null;
      }
      return jsonDecode(decodedBody);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final Object? message = decoded['message'] ?? decoded['detail'];
      return message?.toString();
    }
    if (decoded is String) {
      return decoded;
    }
    return null;
  }
}
