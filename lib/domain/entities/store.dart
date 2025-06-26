import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? cnpj;
  final double latitude;
  final double longitude;
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
  final bool hasLoyaltyProgram;
  final String? loyaltyProgramName;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    this.cnpj,
    required this.latitude,
    required this.longitude,
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
    this.hasLoyaltyProgram = false,
    this.loyaltyProgramName,
  });

  Store copyWith({
    String? id,
    String? name,
    String? address,
    String? cnpj,
    double? latitude,
    double? longitude,
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
    bool? hasLoyaltyProgram,
    String? loyaltyProgramName,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      cnpj: cnpj ?? this.cnpj,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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
      hasLoyaltyProgram: hasLoyaltyProgram ?? this.hasLoyaltyProgram,
      loyaltyProgramName: loyaltyProgramName ?? this.loyaltyProgramName,
    );
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
        hasLoyaltyProgram,
        loyaltyProgramName,
      ];

  @override
  String toString() {
    return 'Store(id: $id, name: $name, address: $address, category: $category, isApproved: $isApproved)';
  }
}

