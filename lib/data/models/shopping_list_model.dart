import '../../domain/entities/shopping_list.dart';
import '../../core/constants/enums.dart';

class ShoppingListItemModel extends ShoppingListItem {
  const ShoppingListItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.quantity,
    super.price,
    super.storeId,
    super.storeName,
    required super.isCompleted,
    super.isDisabled,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      storeId: json['store_id'] as String?,
      storeName: json['store_name'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      isDisabled: json['is_disabled'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'store_id': storeId,
      'store_name': storeName,
      'is_completed': isCompleted,
      'is_disabled': isDisabled,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ShoppingListItemModel.fromEntity(ShoppingListItem item) {
    return ShoppingListItemModel(
      id: item.id,
      productId: item.productId,
      productName: item.productName,
      quantity: item.quantity,
      price: item.price,
      storeId: item.storeId,
      storeName: item.storeName,
      isCompleted: item.isCompleted,
      isDisabled: item.isDisabled,
      notes: item.notes,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }
}

class ShoppingListModel extends ShoppingList {
  const ShoppingListModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.items,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.budget,
    super.metadata,
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              ShoppingListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: ShoppingListStatus.values.firstWhere(
        (s) => s.value == json['status'],
        orElse: () => ShoppingListStatus.active,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      description: json['description'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'items': items
          .map((e) => ShoppingListItemModel.fromEntity(e).toJson())
          .toList(),
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'description': description,
      'budget': budget,
      'metadata': metadata,
    };
  }

  factory ShoppingListModel.fromEntity(ShoppingList list) {
    return ShoppingListModel(
      id: list.id,
      userId: list.userId,
      name: list.name,
      items: list.items
          .map((e) => ShoppingListItemModel.fromEntity(e))
          .toList(),
      status: list.status,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
      description: list.description,
      budget: list.budget,
      metadata: list.metadata,
    );
  }
}
