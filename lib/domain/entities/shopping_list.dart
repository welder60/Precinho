import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class ShoppingListItem extends Equatable {
  final String id;
  final String productId;
  final int quantity;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingListItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.isCompleted,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  ShoppingListItem copyWith({
    String? id,
    String? productId,
    int? quantity,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        quantity,
        isCompleted,
        notes,
        createdAt,
        updatedAt,
      ];
}

class ShoppingList extends Equatable {
  final String id;
  final String userId;
  final String name;
  final List<ShoppingListItem> items;
  final ShoppingListStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final double? budget;
  final Map<String, dynamic>? metadata;

  const ShoppingList({
    required this.id,
    required this.userId,
    required this.name,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.budget,
    this.metadata,
  });

  ShoppingList copyWith({
    String? id,
    String? userId,
    String? name,
    List<ShoppingListItem>? items,
    ShoppingListStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    double? budget,
    Map<String, dynamic>? metadata,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      metadata: metadata ?? this.metadata,
    );
  }

  int get totalItems => items.length;
  int get completedItems => items.where((item) => item.isCompleted).length;
  int get pendingItems => totalItems - completedItems;
  double get completionPercentage => totalItems > 0 ? (completedItems / totalItems) * 100 : 0;
  bool get isCompleted => status == ShoppingListStatus.completed;
  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        items,
        status,
        createdAt,
        updatedAt,
        description,
        budget,
        metadata,
      ];

  @override
  String toString() {
    return 'ShoppingList(id: $id, name: $name, totalItems: $totalItems, status: $status)';
  }
}

