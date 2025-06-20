import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/shopping_list_model.dart';

class ShoppingListStorage {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<ShoppingListModel>> loadLists() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _firestore
        .collection('shopping_lists')
        .where('user_id', isEqualTo: uid)
        .get();
    return snap.docs
        .map((e) =>
            ShoppingListModel.fromJson({...e.data(), 'id': e.id}))
        .toList();
  }

  Future<void> saveLists(List<ShoppingListModel> lists) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final batch = _firestore.batch();
    final collection = _firestore.collection('shopping_lists');
    for (final list in lists) {
      final doc = collection.doc(list.id);
      batch.set(doc, list.toJson());
    }
    await batch.commit();
  }
}
