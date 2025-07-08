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

  /// Cria ou retorna um produto existente pelo EAN/NCM ou c\u00f3digo do com\u00e9rcio.
  Future<DocumentReference<Map<String, dynamic>>> getOrCreateProduct({
    String? ean,
    String? ncm,
    required String name,
    DocumentReference<Map<String, dynamic>>? storeRef,
    String? storeCode,
    String? storeDescription,
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

    // Depois busca pelos atributos do produto (EAN ou NCM)
    Query<Map<String, dynamic>> query = _firestore.collection('products');
    if (ean != null && ean.isNotEmpty) {
      query = query.where('barcode', isEqualTo: ean);
    } else if (ncm != null && ncm.isNotEmpty) {
      query = query.where('ncm_code', isEqualTo: ncm);
    }
    final snap = await query.limit(1).get();
    DocumentReference<Map<String, dynamic>> productRef;
    if (snap.docs.isNotEmpty) {
      productRef = snap.docs.first.reference;
    } else {
      final data = {
        'name': name,
        if (ean != null) 'barcode': ean,
        if (ncm != null) 'ncm_code': ncm,
        'created_at': Timestamp.now(),
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
    required String description,
    required DocumentReference invoiceRef,
    required DocumentReference storeRef,
    required DocumentReference productRef,
  }) async {
    final data = {
      'product_id': productRef.id,
      'store_id': storeRef.id,
      'invoice_id': invoiceRef.id,
      'price': value,
      'description': description,
      'status': ModerationStatus.approved.value,
      if (ncm != null) 'ncm_code': ncm,
      if (ean != null) 'ean_code': ean,
      if (customCode != null) 'custom_code': customCode,
      'created_at': Timestamp.now(),
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
  }) async {
    final existing = await _firestore
        .collection('invoices')
        .where('access_key', isEqualTo: accessKey)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return existing.docs.first.reference;
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
    };
    final doc = await _firestore.collection('invoices').add(data);
    return doc;
  }
}
