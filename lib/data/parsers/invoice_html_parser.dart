import 'package:html/parser.dart' as html_parser;

class InvoiceHtmlParser {
  static String parse(String html) {
    final document = html_parser.parse(html);
    // TODO: Implementar extração de dados da nota fiscal em HTML
    return 'Arquivo HTML carregado (${document.body?.children.length} elementos)';
  }
}
