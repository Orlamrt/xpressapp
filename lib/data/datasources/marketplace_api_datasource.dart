import 'dart:convert';

import 'package:http/http.dart' as http;

class MarketplaceApiDatasource {
  MarketplaceApiDatasource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _base = 'https://xpressatec.online/marketplace/terapeuta';

  Future<void> upsertProfile(Map<String, dynamic> payloadConCorreo) async {
    final uri = Uri.parse('$_base/profile');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payloadConCorreo),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
