import 'package:flutter_test/flutter_test.dart';
import 'package:precinho_app/data/datasources/contribution_service.dart';

void main() {
  test('service can be instantiated', () {
    final service = ContributionService();
    expect(service, isNotNull);
  });
}
