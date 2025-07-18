import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasources/invoice_import_service.dart';
import '../exceptions/missing_store_location_exception.dart';
import '../../core/constants/enums.dart';

class InvoiceHtmlParser {
  /// Converte string com vírgula em double. Ex: "1.234,56" => 1234.56
  static double _toDouble(String valor) {
    return double.tryParse(
      valor.replaceAll('.', '').replaceAll(',', '.'),
    ) ?? 0.0;
  }

  /// Extrai campos de um contêiner com múltiplos `div.col`
  static Map<String, List<String>> _extractFromCols(Element container) {
    final data = <String, List<String>>{};
    final cols = container.querySelectorAll('div.col, div.col-md-10');

    for (final col in cols) {
      final keyElement = col.querySelector('.sub-titulo');
      final valueElement = col.querySelector('.campo-xml');
      if (keyElement != null && valueElement != null) {
        final key = keyElement.text.trim();
        final value = valueElement.text.trim();
        if (key.isNotEmpty) {
          data.putIfAbsent(key, () => []).add(value);
        }
      }
    }

    return data;
  }

  /// Extrai todos os campos do documento inteiro
  static Map<String, List<String>> _extractFields(Document document) {
    // Aplica a extração no `body` completo
    final body = document.body;
    return body != null ? _extractFromCols(body) : {};
  }

  /// Extrai apenas os campos dos produtos, localizados em `div.card-body` com EAN
  static Map<String, List<String>> _extractPrices(Document document) {
    final data = <String, List<String>>{};
    final bodies = document.querySelectorAll('div.card-body');

    for (final body in bodies) {
      final filhos = body.querySelectorAll('*');
      final temEAN = filhos.any((el) => el.text.contains('Código EAN Comercial'));
	  final temICMS = filhos.any((el) => el.text.contains('ICMS NORMAL E ST'));
      if (temEAN && !temICMS) {
        final campos = _extractFromCols(body);
        for (final entry in campos.entries) {
          data.putIfAbsent(entry.key, () => []).addAll(entry.value);
        }
      }
    }

    return data;
  }

  /// Acesso público à extração de todos os campos
  static Map<String, List<String>> extractFields(String html) {
    final document = html_parser.parse(html);
    return _extractFields(document);
  }

  /// Acesso público à extração de campos de produtos
  static Map<String, List<String>> extractPrices(String html) {
    final document = html_parser.parse(html);
    return _extractPrices(document);
  }

  /// Analisa o HTML da NFC-e e imprime os dados principais e os itens.
  static String parse(String html) {
    final campos = extractFields(html);
    final produtos = extractPrices(html);    

    final chaveNF = campos['Chave de acesso']?[0].replaceAll(RegExp(r'\D'), '') ?? '';
    final emissao = campos['Data de Emissão']?[0] ?? '';
    final totalStr = campos['Valor Total da Nota Fiscal']?[0] ?? '0,00';
    final total = _toDouble(totalStr);

    print('Chave: $chaveNF');
    print('Data de Emissão: $emissao');
    print('Valor Total da Nota: R\$ ${total.toStringAsFixed(2)}');

    final cnpj = campos['CNPJ']?[0] ?? '';
    final razaoSocial = campos['Nome / Razão Social']?[0] ?? '';
    final endereco = campos['Endereço']?[0] ?? '';
    final cep = campos['CEP']?[0] ?? '';
    final municipio = campos['Município da Ocorrência do Fato Gerador do ICMS']?[0] ?? '';

    print('Emitente: $razaoSocial');
    print('CNPJ: $cnpj');
    print('Endereço: $endereco');
    print('CEP: $cep');
    print('Município: $municipio');
	
	final codigos = produtos['Código EAN Comercial'] ?? [];

    final nItens = codigos.length;
    double soma = 0;

    for (int i = 0; i < nItens; i++) {
      final ean = codigos[i];
      final ncm = produtos['Código NCM']?[i];
      final codigo = produtos['Código do produto']?[i];
      final descricao = produtos['Descrição']?[i];
      final quantidadeStr = produtos['Quantidade']?[i] ?? '0,00';
      final unidade = produtos['Unidade Comercial']?[i] ?? 'un';
      final valorStr = produtos['Valor(R\$)']?[i] ?? '0,00';
      final valorUnitarioStr = produtos['Valor Unitário de Comercialização']?[i] ?? '0,00';
      final descontoStr = produtos['Valor do Desconto']?[i] ?? '0,00';

      final quantidade = double.tryParse(quantidadeStr);
      final valor = _toDouble(valorStr);
      final valorUnitario = _toDouble(valorUnitarioStr);
      final desconto = _toDouble(descontoStr);

      soma += valor - desconto;

      print('\nProduto ${i + 1}:');
      print('  EAN: $ean');
      print('  NCM: $ncm');
      print('  Código: $codigo');
      print('  Descrição: $descricao');
      print('  Quantidade: $quantidade');
      print('  Unidade: $unidade');
      print('  Valor: R\$ ${valor.toStringAsFixed(2)}');
      print('  Unitário: R\$ ${valorUnitario.toStringAsFixed(2)}');
      print('  Desconto: R\$ ${desconto.toStringAsFixed(2)}');
    }

    print('\nSoma dos produtos (com descontos): R\$ ${soma.toStringAsFixed(2)}');

    final diferenca = (soma - total).abs();
    if (diferenca < 0.01) {
      print('✅ A soma dos itens confere com o valor total da nota.');
    } else {
      print('⚠️ Diferença encontrada entre os itens e o total da nota:');
      print('    Valor da Nota: R\$ ${total.toStringAsFixed(2)}');
      print('    Soma dos Itens: R\$ ${soma.toStringAsFixed(2)}');
      print('    Diferença: R\$ ${diferenca.toStringAsFixed(2)}');
    }

    return '$nItens preços importados';
  }

  /// Importa os dados da NFC-e para o Firestore.
  static Future<String> importInvoice(
    String html, {
    required String userId,
    String qrLink = '',
  }) async {
    final campos = extractFields(html);
    final produtos = extractPrices(html);

    final chaveNF =
        campos['Chave de acesso']?[0].replaceAll(RegExp(r'\D'), '') ?? '';
    final serie = campos['Série']?[0] ?? '';
    final numero = campos['Número']?[0] ?? '';

    final cnpj = campos['CNPJ']?[0].replaceAll(RegExp(r'\D'), '') ?? '';
    final nome = campos['Nome / Razão Social']?.first ??
        campos['Razão Social']?.first ??
        campos['Nome']?.first ??
        'Desconhecido';
    final endereco = campos['Endereço']?.first;

    final service = InvoiceImportService();

    DocumentReference<Map<String, dynamic>> invoiceRef;

    invoiceRef = await service.getOrCreateInvoice(
      qrLink: qrLink,
      accessKey: chaveNF,
      cnpj: cnpj,
      series: serie,
      number: numero,
      userId: userId,
    );

    final invoiceSnap = await invoiceRef.get();
    final currentStatus = invoiceSnap.data()?['status'] as String?;
    if (currentStatus == ModerationStatus.approved.value) {
      throw Exception('Invoice j\u00e1 aprovada');
    }

    final existingStoreId = invoiceSnap.data()?['store_id'] as String?;
    DocumentReference<Map<String, dynamic>> storeRef;
    if (existingStoreId != null) {
      storeRef = FirebaseFirestore.instance.collection('stores').doc(existingStoreId);
    } else {
      storeRef = await service.getOrCreateStore(
        cnpj: cnpj,
        name: nome,
        address: endereco,
      );
      await invoiceRef.update({'store_id': storeRef.id});
    }

    final storeSnap = await storeRef.get();
    if (storeSnap.data()?['latitude'] == null ||
        storeSnap.data()?['longitude'] == null) {
      throw MissingStoreLocationException(storeRef);
    }

    final eans = produtos['Código EAN Comercial'] ?? [];
    final ncms = produtos['Código NCM'] ?? [];
    final codigos = produtos['Código do produto'] ?? [];
    final descricoes = produtos['Descrição'] ?? [];
    final valores = produtos['Valor(R\$)'] ?? [];
    final unitarios = produtos['Valor Unit\u00e1rio de Comercializa\u00e7\u00e3o'] ?? [];
    final quantidades = produtos['Quantidade'] ?? [];
    final descontos = produtos['Valor do Desconto'] ?? [];

    final nItens = descricoes.length;

      for (int i = 0; i < nItens; i++) {
        final rawEan = i < eans.length ? eans[i].trim() : null;
        String? cleanEan = rawEan;
        if (cleanEan != null) {
          cleanEan = cleanEan.replaceAll(RegExp(r'\D'), '');
          if (cleanEan.isEmpty) {
            cleanEan = null;
          }
        }
        final isFractional = cleanEan == null;
      final ncm = i < ncms.length ? ncms[i] : null;
      final codigo = i < codigos.length ? codigos[i] : null;
      final descricao = descricoes[i];
      final valorStr = i < valores.length ? valores[i] : '0,00';
      final unitarioStr = i < unitarios.length ? unitarios[i] : '0,00';
      final quantidadeStr = i < quantidades.length ? quantidades[i] : '0,00';
      final descontoStr = i < descontos.length ? descontos[i] : '0,00';
      final valor = _toDouble(valorStr);
      final unitario = _toDouble(unitarioStr);
      final quantidade = _toDouble(quantidadeStr);
      double? unidadePreco;
      if (quantidade > 0) {
        unidadePreco = unitario / quantidade;
      }
      final desconto = _toDouble(descontoStr);

      final productRef = await service.getOrCreateProduct(
        ean: cleanEan,
        ncm: ncm?.isNotEmpty == true ? ncm : null,
        name: descricao,
        storeRef: storeRef,
        storeCode: codigo,
        storeDescription: descricao,
        userId: userId,
        isFractional: isFractional,
        volume: isFractional ? 1.0 : null,
        unit: isFractional ? 'kg' : null,
      );

      await service.createPrice(
        ncm: ncm?.isNotEmpty == true ? ncm : null,
        ean: cleanEan,
        customCode: codigo,
        value: unitario,
        invoiceValue: valor,
        unitValue: unidadePreco,
        discount: desconto,
        description: descricao,
        invoiceRef: invoiceRef,
        storeRef: storeRef,
        productRef: productRef,
      );
    }

    await invoiceRef.update({'status': ModerationStatus.approved.value});

    return '$nItens preços importados';
  }
}
