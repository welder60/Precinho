import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final int points;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? phoneNumber;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.latitude,
    this.longitude,
    required this.points,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.phoneNumber,
    this.lastLoginAt,
  });

  User copyWith({
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
    return User(
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

  bool get isAdmin => role == UserRole.admin;
  bool get isModerator => role == UserRole.moderator;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        photoUrl,
        latitude,
        longitude,
        points,
        role,
        createdAt,
        updatedAt,
        isActive,
        phoneNumber,
        lastLoginAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, points: $points, role: $role)';
  }
}

