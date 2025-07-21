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

    test('isValidInvoiceAccessKey', () {
      const validKey = '12345678901234567890123456789012345678901235';
      const invalidKey = '12345678901234567890123456789012345678901234';
      expect(Validators.isValidInvoiceAccessKey(validKey), isTrue);
      expect(Validators.isValidInvoiceAccessKey(invalidKey), isFalse);
    });

    test('validateInvoiceAccessKey', () {
      const validKey = '12345678901234567890123456789012345678901235';
      expect(Validators.validateInvoiceAccessKey(validKey), isNull);
      expect(Validators.validateInvoiceAccessKey('123'), isNotNull);
    });
  });
}
