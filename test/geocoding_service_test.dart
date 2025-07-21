import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:precinho_app/data/datasources/geocoding_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  test('geocodeCep returns coordinates from API', () async {
    final client = MockHttpClient();
    final service = GeocodingService(client: client);

    const responseBody = '{"results": [{"geometry": {"location": {"lat": 1.0, "lng": 2.0}}}]}';
    when(client.get(any)).thenAnswer((_) async => http.Response(responseBody, 200));

    final result = await service.geocodeCep('12345-678');

    expect(result, isNotNull);
    expect(result!['lat'], 1.0);
    expect(result['lng'], 2.0);
  });
}
