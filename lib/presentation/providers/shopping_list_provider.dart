import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/shopping_list.dart';
import '../../core/constants/enums.dart';
import '../../data/models/shopping_list_model.dart';
import '../../data/datasources/shopping_list_storage.dart';

class ShoppingListNotifier extends StateNotifier<List<ShoppingList>> {
  final ShoppingListStorage _storage;

  ShoppingListNotifier(this._storage) : super(const []) {
    _loadLists();
  }

  Future<void> _loadLists() async {
    final lists = await _storage.loadLists();
    if (state.isEmpty) {
      state = lists;
    }
  }

  String createList(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'local';
    final list = ShoppingList(
      id: id,
      userId: userId,
      name: name,
      items: const [],
      status: ShoppingListStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [...state, list];
    _storage.saveLists(
        state.map((e) => ShoppingListModel.fromEntity(e)).toList());
    return id;
  }

  void addProductToList({
    required String listId,
    required String productId,
    required String productName,
    required double quantity,
    double? price,
    String? storeId,
    String? storeName,
  }) {
    state = [
      for (final l in state)
        if (l.id == listId)
          l.copyWith(
            items: [
              ...l.items,
              ShoppingListItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                productId: productId,
                productName: productName,
                quantity: quantity,
                price: price,
                storeId: storeId,
                storeName: storeName,
                isCompleted: false,
                isDisabled: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                notes: null,
              ),
            ],
            updatedAt: DateTime.now(),
          )
        else
          l
    ];
      _storage.saveLists(
          state.map((e) => ShoppingListModel.fromEntity(e)).toList());
    }

  void updateItemPrice({
    required String listId,
    required String productId,
    double? price,
    String? storeId,
    String? storeName,
  }) {
    state = [
      for (final l in state)
        if (l.id == listId)
          l.copyWith(
            items: [
              for (final item in l.items)
                if (item.productId == productId)
                  item.copyWith(
                    price: price,
                    storeId: storeId,
                    storeName: storeName,
                    updatedAt: DateTime.now(),
                  )
                else
                  item,
            ],
            updatedAt: DateTime.now(),
          )
        else
          l
    ];
    _storage
        .saveLists(state.map((e) => ShoppingListModel.fromEntity(e)).toList());
  }

  void toggleItemDisabled({required String listId, required String itemId}) {
    state = [
      for (final l in state)
        if (l.id == listId)
          l.copyWith(
            items: [
              for (final item in l.items)
                if (item.id == itemId)
                  item.copyWith(
                    isDisabled: !item.isDisabled,
                    updatedAt: DateTime.now(),
                  )
                else
                  item,
            ],
            updatedAt: DateTime.now(),
          )
        else
          l
    ];
    _storage.saveLists(state.map((e) => ShoppingListModel.fromEntity(e)).toList());
  }

  void clearPrices(String listId) {
    state = [
      for (final l in state)
        if (l.id == listId)
          l.copyWith(
            items: [
              for (final item in l.items)
                item.copyWith(
                  price: null,
                  storeId: null,
                  storeName: null,
                  updatedAt: DateTime.now(),
                )
            ],
            updatedAt: DateTime.now(),
          )
        else
          l
    ];
    _storage.saveLists(state.map((e) => ShoppingListModel.fromEntity(e)).toList());
  }

  ShoppingList? getList(String id) {
    for (final list in state) {
      if (list.id == id) return list;
    }
    return null;
  }

  Map<String, double> totalsByStore(String listId) {
    final list = getList(listId);
    if (list == null) return {};
    final totals = <String, double>{};
    for (final item in list.items.where((e) => !e.isDisabled)) {
      final store = item.storeName ?? 'Indefinido';
      final price = item.price ?? 0;
      totals[store] = (totals[store] ?? 0) + price * item.quantity;
    }
    return totals;
  }
}

final shoppingListStorageProvider = Provider<ShoppingListStorage>((ref) {
  return ShoppingListStorage();
});

final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, List<ShoppingList>>((ref) {
  final storage = ref.watch(shoppingListStorageProvider);
  return ShoppingListNotifier(storage);
});
