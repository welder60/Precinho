import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../models/place_result.dart';

class PlacesService {
  final http.Client _client;

  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PlaceResult>> searchPlacesByName({
    required String name,
    double? latitude,
    double? longitude,
    int radiusInMeters = 5000,
  }) async {
    final queryParameters = {
      'key': AppConstants.googleMapsApiKey,
      'query': name,
      'radius': '$radiusInMeters',
      if (latitude != null && longitude != null)
        'location': '$latitude,$longitude',
    };

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/textsearch/json',
      queryParameters,
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar locais: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .map((e) => PlaceResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
