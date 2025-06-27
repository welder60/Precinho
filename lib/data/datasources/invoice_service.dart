import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';
import '../../core/logging/firebase_logger.dart';

class InvoiceService {
  final FirebaseFirestore _firestore;

  InvoiceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> submitInvoice({
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
      throw Exception('Nota fiscal j\u00e1 cadastrada');
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
    FirebaseLogger.log('submitInvoice', data);
    await _firestore.collection('invoices').add(data);
  }

  Stream<QuerySnapshot> userInvoices(String userId) {
    return _firestore
        .collection('invoices')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> invoiceById(String id) {
    return _firestore.collection('invoices').doc(id).snapshots();
  }
}
