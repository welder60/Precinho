import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../../core/logging/firebase_logger.dart';

class ContributionService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ContributionService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<void> submitPricePhoto({
    required File image,
    required Position position,
    required String userId,
  }) async {
    final path = 'price_photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(path);
    await ref.putFile(image);
    final url = await ref.getDownloadURL();
    final data = {
      'type': ContributionType.pricePhoto.value,
      'user_id': userId,
      'image_url': url,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'created_at': Timestamp.now(),
      'status': ModerationStatus.pending.value,
      'points': AppConstants.pointsForPricePhoto,
    };
    FirebaseLogger.log('submitPricePhoto', data);
    await _firestore.collection('contributions').add(data);
  }

  Future<void> submitInvoice({
    required String qrLink,
    required String accessKey,
    required String cnpj,
    required String userId,
  }) async {
    final existing = await _firestore
        .collection('contributions')
        .where('type', isEqualTo: ContributionType.invoice.value)
        .where('access_key', isEqualTo: accessKey)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Nota fiscal j\u00e1 cadastrada');
    }

    final data = {
      'type': ContributionType.invoice.value,
      'user_id': userId,
      'qr_link': qrLink,
      'access_key': accessKey,
      'cnpj': cnpj,
      'created_at': Timestamp.now(),
      'status': ModerationStatus.pending.value,
      'points': AppConstants.pointsForInvoice,
    };
    FirebaseLogger.log('submitInvoice', data);
    await _firestore.collection('contributions').add(data);
  }
}
