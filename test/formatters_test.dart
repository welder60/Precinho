import 'package:flutter_test/flutter_test.dart';
import 'package:precinho_app/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatPrice and parsePrice', () {
      final formatted = Formatters.formatPrice(10);
      expect(formatted.contains('10,00'), isTrue);
      expect(Formatters.parsePrice(formatted), 10);
    });

    test('formatPhone', () {
      expect(Formatters.formatPhone('11987654321'), '(11) 98765-4321');
    });

    test('formatDistance', () {
      expect(Formatters.formatDistance(0.5), '500m');
      expect(Formatters.formatDistance(2), '2.0km');
    });

    test('formatCpf', () {
      expect(Formatters.formatCpf('11144477735'), '111.444.777-35');
    });
  });
}
