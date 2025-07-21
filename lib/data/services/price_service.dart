import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/firebase_logger.dart';

class PriceService {
  final FirebaseFirestore _firestore;

  PriceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<DocumentReference<Map<String, dynamic>>> createPrice({
    required String productId,
    required String productName,
    required String storeId,
    required String storeName,
    String? userId,
    required double value,
    double? invoiceValue,
    double? unitPrice,
    double? discount,
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
    bool isActive = true,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? extra,
  }) async {
    await _deactivatePrevious(productId, storeId);

    final baseDate = createdAt ?? DateTime.now();
    final data = <String, dynamic>{
      'product_id': productId,
      'product_name': productName,
      'store_id': storeId,
      'store_name': storeName,
      if (userId != null) 'user_id': userId,
      'price': value,
      if (invoiceValue != null) 'invoice_value': invoiceValue,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (discount != null) 'discount': discount,
      if (description != null) 'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'created_at': Timestamp.fromDate(baseDate),
      'expires_at': Timestamp.fromDate(
        expiresAt ??
            baseDate.add(
              const Duration(days: AppConstants.defaultPriceValidityDays),
            ),
      ),
      if (extra != null) ...extra,
    };

    FirebaseLogger.log('createPrice', data);
    return await _firestore.collection('prices').add(data);
  }

  Future<void> _deactivatePrevious(String productId, String storeId) async {
    final prev = await _firestore
        .collection('prices')
        .where('product_id', isEqualTo: productId)
        .where('store_id', isEqualTo: storeId)
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();
    if (prev.docs.isNotEmpty) {
      await prev.docs.first.reference.update({'is_active': false});
    }
  }
}
