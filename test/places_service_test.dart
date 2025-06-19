import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:precinho_app/data/datasources/places_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  test('searchPlacesByName returns results from API', () async {
    final client = MockHttpClient();
    final service = PlacesService(client: client);

    const responseBody = '{"results": [{"place_id": "1", "name": "Store", "formatted_address": "Street", "geometry": {"location": {"lat": 0, "lng": 0}}}] }';
    when(client.get(any)).thenAnswer((_) async => http.Response(responseBody, 200));

    final results = await service.searchPlacesByName(name: 'Store');

    expect(results, isNotEmpty);
    expect(results.first.id, '1');
  });
});
