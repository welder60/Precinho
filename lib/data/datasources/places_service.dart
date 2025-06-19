import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:js_util' as js_util;

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
    if (kIsWeb) {
      final resultJson = await js_util.promiseToFuture<String>(
        js_util.callMethod(
          js_util.globalThis,
          'searchPlaces',
          [name, latitude, longitude, radiusInMeters],
        ) as dynamic,
      );
      final data = json.decode(resultJson) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];
      return results
          .map((e) => PlaceResult.fromJson(
              Map<String, dynamic>.from(e as Map<String, dynamic>)))
          .toList();
    }
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
