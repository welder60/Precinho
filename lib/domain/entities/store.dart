import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? cnpj;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? mapImageUrl;
  final StoreCategory category;
  final bool isApproved;
  final ModerationStatus status;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phoneNumber;
  final String? website;
  final Map<String, String>? openingHours;
  final double? rating;
  final int reviewCount;
  final Map<String, dynamic>? metadata;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    this.cnpj,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.mapImageUrl,
    required this.category,
    required this.isApproved,
    required this.status,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.website,
    this.openingHours,
    this.rating,
    required this.reviewCount,
    this.metadata,
  });

  Store copyWith({
    String? id,
    String? name,
    String? address,
    String? cnpj,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? mapImageUrl,
    StoreCategory? category,
    bool? isApproved,
    ModerationStatus? status,
    String? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    String? website,
    Map<String, String>? openingHours,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? metadata,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      cnpj: cnpj ?? this.cnpj,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      mapImageUrl: mapImageUrl ?? this.mapImageUrl,
      category: category ?? this.category,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get hasImage {
    return (imageUrl != null && imageUrl!.isNotEmpty) ||
        (mapImageUrl != null && mapImageUrl!.isNotEmpty);
  }
  bool get hasRating => rating != null && rating! > 0;
  bool get hasContact => phoneNumber != null || website != null;

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        cnpj,
        latitude,
        longitude,
        imageUrl,
        mapImageUrl,
        category,
        isApproved,
        status,
        createdByUserId,
        createdAt,
        updatedAt,
        phoneNumber,
        website,
        openingHours,
        rating,
        reviewCount,
        metadata,
      ];

  @override
  String toString() {
    return 'Store(id: $id, name: $name, address: $address, category: $category, isApproved: $isApproved)';
  }
}

