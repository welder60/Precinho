import '../../domain/entities/product.dart';
import '../../core/constants/enums.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.description,
    super.imageUrl,
    required super.category,
    super.barcode,
    super.ncmCode,
    super.equivalentProductIds = const [],
    required super.isFractional,
    required super.isApproved,
    required super.status,
    required super.createdByUserId,
    required super.createdAt,
    required super.updatedAt,
    super.averagePrice,
    required super.priceCount,
    super.metadata,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      category: ProductCategory.values.firstWhere(
        (category) => category.value == json['category'],
        orElse: () => ProductCategory.other,
      ),
      barcode: json['barcode'] as String?,
      ncmCode: json['ncm_code'] as String?,
      equivalentProductIds: (json['equivalent_product_ids'] as List?)
              ?.cast<String>() ??
          const [],
      isFractional: json['is_fractional'] as bool? ?? false,
      isApproved: json['is_approved'] as bool? ?? false,
      status: ModerationStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => ModerationStatus.pending,
      ),
      createdByUserId: json['created_by_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      averagePrice: json['average_price']?.toDouble(),
      priceCount: json['price_count'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'image_url': imageUrl,
      'category': category.value,
      'barcode': barcode,
      'ncm_code': ncmCode,
      'equivalent_product_ids': equivalentProductIds,
      'is_fractional': isFractional,
      'is_approved': isApproved,
      'status': status.value,
      'created_by_user_id': createdByUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'average_price': averagePrice,
      'price_count': priceCount,
      'metadata': metadata,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      brand: product.brand,
      description: product.description,
      imageUrl: product.imageUrl,
      category: product.category,
      barcode: product.barcode,
      ncmCode: product.ncmCode,
      equivalentProductIds: product.equivalentProductIds,
      isFractional: product.isFractional,
      isApproved: product.isApproved,
      status: product.status,
      createdByUserId: product.createdByUserId,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      averagePrice: product.averagePrice,
      priceCount: product.priceCount,
      metadata: product.metadata,
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? description,
    String? imageUrl,
    ProductCategory? category,
    String? barcode,
    String? ncmCode,
    List<String>? equivalentProductIds,
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
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      ncmCode: ncmCode ?? this.ncmCode,
      equivalentProductIds:
          equivalentProductIds ?? this.equivalentProductIds,
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
}

