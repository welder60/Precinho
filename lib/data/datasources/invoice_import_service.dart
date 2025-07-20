import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';

/// Serviço auxiliar para criação de entidades ao importar notas fiscais.
class InvoiceImportService {
  final FirebaseFirestore _firestore;

  InvoiceImportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Cria ou retorna um comércio existente pelo CNPJ.
  Future<DocumentReference<Map<String, dynamic>>> getOrCreateStore({
    required String cnpj,
    required String name,
    String? address,
  }) async {
    final existing = await _firestore
        .collection('stores')
        .where('cnpj', isEqualTo: cnpj)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return existing.docs.first.reference;
    }

    final data = {
      'cnpj': cnpj,
      'name': name,
      if (address != null) 'address': address,
      'created_at': Timestamp.now(),
    };
    final doc = await _firestore.collection('stores').add(data);
    return doc;
  }

  /// Cria ou retorna um produto existente pelo c\u00f3digo de barras (EAN) ou
  /// c\u00f3digo do com\u00e9rcio.
  Future<DocumentReference<Map<String, dynamic>>> getOrCreateProduct({
    String? ean,
    String? ncm,
    required String name,
    DocumentReference<Map<String, dynamic>>? storeRef,
    String? storeCode,
    String? storeDescription,
    String? userId,
    bool isFractional = false,
    double? volume,
    String? unit,
  }) async {
    // Primeiro tenta encontrar pelo c\u00f3digo vinculado ao com\u00e9rcio
    if (storeRef != null && storeCode != null && storeCode.isNotEmpty) {
      final mappingSnap = await _firestore
          .collection('store_products')
          .where('store_id', isEqualTo: storeRef.id)
          .where('code', isEqualTo: storeCode)
          .limit(1)
          .get();
      if (mappingSnap.docs.isNotEmpty) {
        final productId = mappingSnap.docs.first.data()['product_id'] as String;
        return _firestore.collection('products').doc(productId);
      }
    }

    // Depois busca pelo EAN do produto, se informado.
    DocumentReference<Map<String, dynamic>>? productRef;
    if (ean != null && ean.isNotEmpty) {
      final snap = await _firestore
          .collection('products')
          .where('barcode', isEqualTo: ean)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        productRef = snap.docs.first.reference;
      }
    }
    if (productRef == null) {
      final data = {
        'name': name,
        if (ean != null) 'barcode': ean,
        if (ncm != null) 'ncm_code': ncm,
        if (ean != null && ean.isNotEmpty)
          'image_url': 'https://cdn-cosmos.bluesoft.com.br/products/$ean',
        'created_at': Timestamp.now(),
        if (isFractional) 'is_fractional': true,
        if (volume != null) 'volume': volume,
        if (unit != null) 'unit': unit,
      };
      productRef = await _firestore.collection('products').add(data);
    }

    // Se houver informa\u00e7\u00f5es do c\u00f3digo do com\u00e9rcio, cria o v\u00ednculo
    if (storeRef != null && storeCode != null && storeCode.isNotEmpty) {
      final mappingSnap = await _firestore
          .collection('store_products')
          .where('store_id', isEqualTo: storeRef.id)
          .where('code', isEqualTo: storeCode)
          .limit(1)
          .get();
      if (mappingSnap.docs.isEmpty) {
        await _firestore.collection('store_products').add({
          'store_id': storeRef.id,
          'product_id': productRef.id,
          'code': storeCode,
          'description': storeDescription ?? name,
          if (userId != null) 'user_id': userId,
          if (ncm != null) 'ncm_code': ncm,
          if (ean != null) 'ean_code': ean,
          'created_at': Timestamp.now(),
        });
      }
    }

    return productRef;
  }

  /// Cria um preço vinculado a um produto e comércio existentes.
  Future<DocumentReference<Map<String, dynamic>>> createPrice({
    String? ncm,
    String? ean,
    String? customCode,
    required double value,
    required double invoiceValue,
    double? unitValue,
    required double discount,
    required String description,
    required DocumentReference<Map<String, dynamic>> invoiceRef,
    required DocumentReference<Map<String, dynamic>> storeRef,
    required DocumentReference<Map<String, dynamic>> productRef,
    /// Data de criação do preço. Se não informada, usa [DateTime.now()].
    DateTime? createdAt,
  }) async {
    final productSnap = await productRef.get();
    final productData = productSnap.data() ?? <String, dynamic>{};
    final storeSnap = await storeRef.get();
    final storeData = storeSnap.data() ?? <String, dynamic>{};

    // Calcula o preço por quilo ou litro considerando o volume do produto
    // Quando a unidade for "unidade" ("un"), calcula o valor de uma unidade
    double? unitPrice;
    final volume = productData['volume'];
    final unit = productData['unit'];
    if (volume is num && unit is String) {
      final normalized = unit.toLowerCase();
      double multiplier;
      if (normalized == 'kg' ||
          normalized == 'l' ||
          normalized == 'lt' ||
          normalized == 'lt.') {
        multiplier = 1;
      } else if (normalized == 'g' || normalized == 'ml') {
        multiplier = 1 / 1000;
      } else if (normalized == 'un' || normalized == 'unidade') {
        multiplier = 1;
      } else {
        multiplier = 1;
      }
      final baseVolume = volume.toDouble() * multiplier;
      if (baseVolume > 0) {
        unitPrice = value / baseVolume;
      }
    }
    unitPrice ??= unitValue;

    final data = {
      'product_id': productRef.id,
      'store_id': storeRef.id,
      'invoice_id': invoiceRef.id,
      'price': value,
      'invoice_value': invoiceValue,
      if (unitPrice != null) 'unit_price': unitPrice,
      'discount': discount,
      'description': description,
      'product_name': productData['name'],
      'store_name': storeData['name'],
      'image_url': productData['image_url'],
      'is_active': true,
      if (storeData['latitude'] != null)
        'latitude': (storeData['latitude'] as num).toDouble(),
      if (storeData['longitude'] != null)
        'longitude': (storeData['longitude'] as num).toDouble(),
      if (ncm != null) 'ncm_code': ncm,
      if (ean != null) 'ean_code': ean,
      if (customCode != null) 'custom_code': customCode,
      'created_at': Timestamp.fromDate(createdAt ?? DateTime.now()),
    };
    final doc = await _firestore.collection('prices').add(data);
    return doc;
  }

  /// Cria ou retorna uma nota fiscal existente pela chave de acesso.
  Future<DocumentReference<Map<String, dynamic>>> getOrCreateInvoice({
    required String qrLink,
    required String accessKey,
    required String cnpj,
    required String series,
    required String number,
    required String userId,
    String? storeId,
  }) async {
    final existing = await _firestore
        .collection('invoices')
        .where('access_key', isEqualTo: accessKey)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      final ref = existing.docs.first.reference;
      if (storeId != null) {
        final data = existing.docs.first.data();
        if (!(data.containsKey('store_id'))) {
          await ref.update({'store_id': storeId});
        }
      }
      return ref;
    }

    final data = {
      'user_id': userId,
      'qr_link': qrLink,
      'access_key': accessKey,
      'cnpj': cnpj,
      'series': series,
      'number': number,
      'created_at': Timestamp.now(),
      'status': ModerationStatus.underReview.value,
      if (storeId != null) 'store_id': storeId,
    };
    final doc = await _firestore.collection('invoices').add(data);
    return doc;
  }
}
