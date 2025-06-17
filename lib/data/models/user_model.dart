import '../../domain/entities/user.dart';
import '../../core/constants/enums.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    super.latitude,
    super.longitude,
    required super.points,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    super.phoneNumber,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photo_url'] as String?,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      points: json['points'] as int? ?? 0,
      role: UserRole.values.firstWhere(
        (role) => role.value == json['role'],
        orElse: () => UserRole.user,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      phoneNumber: json['phone_number'] as String?,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'points': points,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'phone_number': phoneNumber,
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      photoUrl: user.photoUrl,
      latitude: user.latitude,
      longitude: user.longitude,
      points: user.points,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
      phoneNumber: user.phoneNumber,
      lastLoginAt: user.lastLoginAt,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    double? latitude,
    double? longitude,
    int? points,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? phoneNumber,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      points: points ?? this.points,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

