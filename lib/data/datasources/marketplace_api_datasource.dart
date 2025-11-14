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
  MarketplaceApiDatasource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _base = 'https://xpressatec.online';

  Future<void> upsertProfile(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_base/marketplace/terapeuta/profile');
    final res = await _client.post(
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
