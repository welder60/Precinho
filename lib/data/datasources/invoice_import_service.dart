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

  /// Cria ou retorna um produto existente pelo EAN ou NCM.
  Future<DocumentReference<Map<String, dynamic>>> getOrCreateProduct({
    String? ean,
    String? ncm,
    required String name,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('products');
    if (ean != null && ean.isNotEmpty) {
      query = query.where('barcode', isEqualTo: ean);
    } else if (ncm != null && ncm.isNotEmpty) {
      query = query.where('ncm_code', isEqualTo: ncm);
    }
    final snap = await query.limit(1).get();
    if (snap.docs.isNotEmpty) return snap.docs.first.reference;

    final data = {
      'name': name,
      if (ean != null) 'barcode': ean,
      if (ncm != null) 'ncm_code': ncm,
      'created_at': Timestamp.now(),
    };
    final doc = await _firestore.collection('products').add(data);
    return doc;
  }

  /// Cria um preço vinculado a um produto e comércio existentes.
  Future<DocumentReference<Map<String, dynamic>>> createPrice({
    String? ncm,
    String? ean,
    String? customCode,
    required double value,
    required String description,
    required DocumentReference storeRef,
    required DocumentReference productRef,
  }) async {
    final data = {
      'product_id': productRef.id,
      'store_id': storeRef.id,
      'price': value,
      'description': description,
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
