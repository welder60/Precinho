import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class Price extends Equatable {
  final String id;
  final String productId;
  final String storeId;
  final String userId;
  final double value;
  final String? imageUrl;
  final String productName;
  final String storeName;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? notes;
  final bool isPromotional;
  final DateTime? promotionalUntil;
  final String? ncmCode;
  final String? eanCode;
  final String? cnpj;
  final DateTime? validUntil;
  final bool promotion;
  final bool loyaltyProgramOnly;
  final String? loyaltyProgramName;
  final Map<String, dynamic>? metadata;
  final double? variation;

  const Price({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.userId,
    required this.value,
    this.imageUrl,
    required this.productName,
    required this.storeName,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.expiresAt,
    required this.updatedAt,
    this.isActive = true,
    this.notes,
    required this.isPromotional,
    this.promotionalUntil,
    this.ncmCode,
    this.eanCode,
    this.cnpj,
    this.validUntil,
    this.promotion = false,
    this.loyaltyProgramOnly = false,
    this.loyaltyProgramName,
    this.metadata,
    this.variation,
  });

  Price copyWith({
    String? id,
    String? productId,
    String? storeId,
    String? userId,
    double? value,
    String? imageUrl,
    String? productName,
    String? storeName,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? updatedAt,
    bool? isActive,
    String? notes,
    bool? isPromotional,
    DateTime? promotionalUntil,
    String? ncmCode,
    String? eanCode,
    String? cnpj,
    DateTime? validUntil,
    bool? promotion,
    bool? loyaltyProgramOnly,
    String? loyaltyProgramName,
    Map<String, dynamic>? metadata,
    double? variation,
  }) {
    return Price(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      value: value ?? this.value,
      imageUrl: imageUrl ?? this.imageUrl,
      productName: productName ?? this.productName,
      storeName: storeName ?? this.storeName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      isPromotional: isPromotional ?? this.isPromotional,
      promotionalUntil: promotionalUntil ?? this.promotionalUntil,
      ncmCode: ncmCode ?? this.ncmCode,
      eanCode: eanCode ?? this.eanCode,
      cnpj: cnpj ?? this.cnpj,
      validUntil: validUntil ?? this.validUntil,
      promotion: promotion ?? this.promotion,
      loyaltyProgramOnly: loyaltyProgramOnly ?? this.loyaltyProgramOnly,
      loyaltyProgramName: loyaltyProgramName ?? this.loyaltyProgramName,
      metadata: metadata ?? this.metadata,
      variation: variation ?? this.variation,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isPromotionalActive {
    if (!isPromotional || promotionalUntil == null) return false;
    return DateTime.now().isBefore(promotionalUntil!);
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String get formattedValue => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  @override
  List<Object?> get props => [
        id,
        productId,
        storeId,
        userId,
        value,
        imageUrl,
        productName,
        storeName,
        latitude,
        longitude,
        createdAt,
        expiresAt,
        updatedAt,
        isActive,
        notes,
        isPromotional,
        promotionalUntil,
        ncmCode,
        eanCode,
        cnpj,
        validUntil,
        promotion,
        loyaltyProgramOnly,
        loyaltyProgramName,
        metadata,
        variation,
      ];

  @override
  String toString() {
    return 'Price(id: $id, productId: $productId, storeId: $storeId, value: $value, variation: $variation)';
  }
}

