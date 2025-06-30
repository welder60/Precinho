import 'package:flutter_test/flutter_test.dart';
import 'package:precinho_app/data/datasources/submission_service.dart';

void main() {
  test('service can be instantiated', () {
    final service = SubmissionService();
    expect(service, isNotNull);
  });
}
