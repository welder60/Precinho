import 'package:flutter_test/flutter_test.dart';
import 'package:precinho_app/data/parsers/invoice_html_parser.dart';

void main() {
  test('extractFields parses CNPJ', () {
    const html = '''
<div class="col">
  <div class="sub-titulo">CNPJ</div>
  <div class="campo-xml">12345678000190</div>
</div>
<div class="col">
  <div class="sub-titulo">Número</div>
  <div class="campo-xml">1</div>
</div>
<div class="col">
  <div class="sub-titulo">Valor Total da Nota Fiscal</div>
  <div class="campo-xml">1,00</div>
</div>
''';
    final fields = InvoiceHtmlParser.extractFields(html);
    expect(fields['CNPJ'], '12345678000190');
    final summary = InvoiceHtmlParser.parse(html);
    expect(summary.contains('Total'), isTrue);
  });
}
