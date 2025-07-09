import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';

class CosmosService {
  final http.Client _client;
  final String _token;

  CosmosService({http.Client? client})
      : _client = client ?? http.Client(),
        _token = AppConfig.get('COSMOS_TOKEN');

  Future<Map<String, dynamic>?> fetchProduct(String ean) async {
    if (ean.isEmpty) return null;
    final uri = Uri.https('api.cosmos.bluesoft.com.br', '/gtins/$ean.json');
    final response = await _client.get(
      uri,
      headers: {'X-Cosmos-Token': _token},
    );
    if (response.statusCode != 200) return null;
    return json.decode(response.body) as Map<String, dynamic>;
  }
}
