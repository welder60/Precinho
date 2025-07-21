import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/logging/maps_logger.dart';

class GeocodingService {
  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, double>?> geocodeCep(String cep) async {
    final sanitized = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': sanitized,
      'components': 'country:BR',
      'key': AppConstants.googleMapsApiKey,
    });

    MapsLogger.log('geocodeCep_request', {'uri': uri.toString()});
    final response = await _client.get(uri);
    MapsLogger.log('geocodeCep_response', {
      'status': response.statusCode,
      'body': response.body,
    });

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final location = results.first['geometry']['location'] as Map<String, dynamic>;
    final lat = (location['lat'] as num).toDouble();
    final lng = (location['lng'] as num).toDouble();
    return {'lat': lat, 'lng': lng};
  }
}
