import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class Price extends Equatable {
  final String id;
  final String productId;
  final String storeId;
  final String userId;
  final double value;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final double latitude;
  final double longitude;
  final bool isApproved;
  final ModerationStatus status;
  final DateTime updatedAt;
  final String? notes;
  final bool isPromotional;
  final DateTime? promotionalUntil;
  final Map<String, dynamic>? metadata;

  const Price({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.userId,
    required this.value,
    this.imageUrl,
    required this.createdAt,
    this.expiresAt,
    required this.latitude,
    required this.longitude,
    required this.isApproved,
    required this.status,
    required this.updatedAt,
    this.notes,
    required this.isPromotional,
    this.promotionalUntil,
    this.metadata,
  });

  Price copyWith({
    String? id,
    String? productId,
    String? storeId,
    String? userId,
    double? value,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    double? latitude,
    double? longitude,
    bool? isApproved,
    ModerationStatus? status,
    DateTime? updatedAt,
    String? notes,
    bool? isPromotional,
    DateTime? promotionalUntil,
    Map<String, dynamic>? metadata,
  }) {
    return Price(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      value: value ?? this.value,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isPromotional: isPromotional ?? this.isPromotional,
      promotionalUntil: promotionalUntil ?? this.promotionalUntil,
      metadata: metadata ?? this.metadata,
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
        createdAt,
        expiresAt,
        latitude,
        longitude,
        isApproved,
        status,
        updatedAt,
        notes,
        isPromotional,
        promotionalUntil,
        metadata,
      ];

  @override
  String toString() {
    return 'Price(id: $id, productId: $productId, storeId: $storeId, value: $value, isApproved: $isApproved)';
  }
}

