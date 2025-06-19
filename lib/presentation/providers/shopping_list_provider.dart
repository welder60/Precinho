import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/shopping_list.dart';
import '../../core/constants/enums.dart';

class ShoppingListNotifier extends StateNotifier<List<ShoppingList>> {
  ShoppingListNotifier() : super(const []);

  String createList(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final list = ShoppingList(
      id: id,
      userId: 'local',
      name: name,
      items: const [],
      status: ShoppingListStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [...state, list];
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
    for (final item in list.items) {
      final store = item.storeName ?? 'Indefinido';
      final price = item.price ?? 0;
      totals[store] = (totals[store] ?? 0) + price * item.quantity;
    }
    return totals;
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingList>>((ref) => ShoppingListNotifier());
