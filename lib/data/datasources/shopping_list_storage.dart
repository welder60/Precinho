import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/shopping_list_model.dart';

class ShoppingListStorage {
  static const _keyPrefix = 'shopping_lists_';

  String _key() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'local';
    return '${_keyPrefix}$uid';
  }

  Future<List<ShoppingListModel>> loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key());
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((e) => ShoppingListModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveLists(List<ShoppingListModel> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(lists.map((e) => e.toJson()).toList());
    await prefs.setString(_key(), data);
  }
}

