import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class InvoiceHtmlParser {
  /// Extracts key/value pairs from the provided NFC-e HTML.
  ///
  /// Each field is generally composed of a `div` with the `sub-titulo` class
  /// followed by another `div` with the `campo-xml` class containing the
  /// respective value. This helper iterates through all column containers and
  /// stores the pairs in a map.
  static Map<String, String> _extractFields(Document document) {
    final data = <String, String>{};
    final cols = document.querySelectorAll('div.col');
    for (final col in cols) {
      final keyElement = col.querySelector('.sub-titulo');
      final valueElement = col.querySelector('.campo-xml');
      if (keyElement != null && valueElement != null) {
        final key = keyElement.text.trim();
        final value = valueElement.text.trim();
        if (key.isNotEmpty) data[key] = value;
      }
    }
    return data;
  }

  /// Returns all key/value pairs extracted from the HTML.
  static Map<String, String> extractFields(String html) {
    final document = html_parser.parse(html);
    return _extractFields(document);
  }

  /// Parses the HTML of an NFC-e file and returns a short summary message.
  static String parse(String html) {
    final fields = extractFields(html);

    final numero = fields['Número NFC-e'] ?? fields['Número'];
    final total =
        fields['Valor Total da Nota Fiscal'] ?? fields['Valor Total da NFe'];

    return 'NFC-e ' + (numero ?? '?') + ' - Total R\$ ' + (total ?? '?') +
        ' (' + fields.length.toString() + ' campos)';
  }
}
