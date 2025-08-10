import 'package:flutter_test/flutter_test.dart';
import 'package:precinho_app/data/parsers/invoice_html_parser.dart';

void main() {
  group('InvoiceHtmlParser', () {
    test('extractFields parses general invoice data', () {
      const html = '''
      <div class="col">
        <div class="sub-titulo">Chave de acesso</div>
        <div class="campo-xml">12345678901234567890123456789012345678901234</div>
      </div>
      <div class="col">
        <div class="sub-titulo">Data de Emissão</div>
        <div class="campo-xml">18/07/2025 18:20:49-03:00</div>
      </div>
      <div class="col">
        <div class="sub-titulo">Valor Total da Nota Fiscal</div>
        <div class="campo-xml">123,45</div>
      </div>
      ''';
      final fields = InvoiceHtmlParser.extractFields(html);
      expect(fields['Chave de acesso'], ['12345678901234567890123456789012345678901234']);
      expect(fields['Data de Emissão'], ['18/07/2025 18:20:49-03:00']);
      expect(fields['Valor Total da Nota Fiscal'], ['123,45']);
    });

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
      expect(fields['CNPJ'], ['12345678000190']);
      final summary = InvoiceHtmlParser.parse(html);
      expect(summary.contains('Total'), isTrue);
    });

    test('extractPrices parses product data', () {
      const html = '''
      <div class="card-body">
        <div class="col">
          <div class="sub-titulo">Código EAN Comercial</div>
          <div class="campo-xml">7891234567890</div>
        </div>
        <div class="col">
          <div class="sub-titulo">Descrição</div>
          <div class="campo-xml">PRODUTO DE TESTE</div>
        </div>
        <div class="col">
          <div class="sub-titulo">Quantidade</div>
          <div class="campo-xml">2,00</div>
        </div>
        <div class="col">
          <div class="sub-titulo">Valor(R\$)</div>
          <div class="campo-xml">20,00</div>
        </div>
      </div>
      ''';
      final prices = InvoiceHtmlParser.extractPrices(html);
      expect(prices['Código EAN Comercial'], ['7891234567890']);
      expect(prices['Descrição'], ['PRODUTO DE TESTE']);
      expect(prices['Quantidade'], ['2,00']);
      expect(prices['Valor(R\$)'], ['20,00']);
    });
  });
}
