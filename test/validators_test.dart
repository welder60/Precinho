import 'package:flutter_test/flutter_test.dart';
import 'package:precinho_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validateEmail', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('invalid'), isNotNull);
    });

    test('validatePassword', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('123'), isNotNull);
    });

    test('validatePrice', () {
      expect(Validators.validatePrice('10,50'), isNull);
      expect(Validators.validatePrice('-1'), isNotNull);
    });

    test('validateCpf', () {
      expect(Validators.validateCpf('111.444.777-35'), isNull);
      expect(Validators.validateCpf('123.456.789-00'), isNotNull);
    });
  });
}
