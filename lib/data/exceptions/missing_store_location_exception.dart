import 'package:cloud_firestore/cloud_firestore.dart';

class MissingStoreLocationException implements Exception {
  final DocumentReference<Map<String, dynamic>> storeRef;
  MissingStoreLocationException(this.storeRef);

  @override
  String toString() => 'Store sem localização';
}
