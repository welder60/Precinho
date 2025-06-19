import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/shopping_list_model.dart';

class ShoppingListStorage {
  static const _listsKey = 'shopping_lists';

  Future<List<ShoppingListModel>> loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_listsKey);
    if (jsonString == null) return [];
    final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
    return data
        .map((e) => ShoppingListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLists(List<ShoppingListModel> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final data = lists.map((e) => e.toJson()).toList();
    await prefs.setString(_listsKey, json.encode(data));
  }
}
