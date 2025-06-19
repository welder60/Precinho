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

  String buildPhotoUrl(String photoReference, {int maxWidth = 600}) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=${AppConstants.googleMapsApiKey}';
  }

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

  Future<String?> getPhotoReference(String placeId) async {
    final queryParameters = {
      'place_id': placeId,
      'fields': 'photos',
      'key': AppConstants.googleMapsApiKey,
    };

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      queryParameters,
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar detalhes: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>?;
    final photos = result?['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final firstPhoto = photos.first as Map<String, dynamic>;
      return firstPhoto['photo_reference'] as String?;
    }
    return null;
  }
}
