import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String? imageUrl;
  final ProductCategory category;
  final String? barcode;
  final String? equivalenceGroupId;
  final bool isFractional;
  final bool isApproved;
  final ModerationStatus status;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? averagePrice;
  final int priceCount;
  final Map<String, dynamic>? metadata;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    this.imageUrl,
    required this.category,
    this.barcode,
    this.equivalenceGroupId,
    required this.isFractional,
    required this.isApproved,
    required this.status,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    this.averagePrice,
    required this.priceCount,
    this.metadata,
  });

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? description,
    String? imageUrl,
    ProductCategory? category,
    String? barcode,
    String? equivalenceGroupId,
    bool? isFractional,
    bool? isApproved,
    ModerationStatus? status,
    String? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averagePrice,
    int? priceCount,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      equivalenceGroupId: equivalenceGroupId ?? this.equivalenceGroupId,
      isFractional: isFractional ?? this.isFractional,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averagePrice: averagePrice ?? this.averagePrice,
      priceCount: priceCount ?? this.priceCount,
      metadata: metadata ?? this.metadata,
    );
  }

  String get fullName => '$brand $name';

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        description,
        imageUrl,
        category,
        barcode,
        equivalenceGroupId,
        isFractional,
        isApproved,
        status,
        createdByUserId,
        createdAt,
        updatedAt,
        averagePrice,
        priceCount,
        metadata,
      ];

  @override
  String toString() {
    return 'Product(id: $id, name: $name, brand: $brand, category: $category, isApproved: $isApproved, fractional: $isFractional)';
  }
}

