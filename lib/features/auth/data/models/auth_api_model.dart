import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';

///   POST /api/auth/register  → response.data.data
///   POST /api/auth/login     → response.data.data
///   GET  /api/auth/whoami    → response.data.data
///   PUT  /api/auth/profile   → response.data.data
class AuthApiModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? phone;
  final String? imageUrl;
  final String role;

  // Only used when sending to register endpoint
  final String? password;
  final String? confirmPassword;

  AuthApiModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.phone,
    this.imageUrl,
    this.role = 'user',
    this.password,
    this.confirmPassword,
  });

  /// Serialise for POST /api/auth/register
  Map<String, dynamic> toRegisterJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'username': username,
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
  };

  /// Deserialise from backend response
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id']?.toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      phone: json['phone']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      role: (json['role'] ?? 'user').toString(),
    );
  }

  AuthEntity toEntity() => AuthEntity(
    authId: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    username: username,
    phone: phone,
    imageUrl: imageUrl,
    role: role,
  );

  factory AuthApiModel.fromEntity(AuthEntity entity) => AuthApiModel(
    id: entity.authId,
    firstName: entity.firstName,
    lastName: entity.lastName,
    email: entity.email,
    username: entity.username,
    phone: entity.phone,
    imageUrl: entity.imageUrl,
    role: entity.role,
    password: entity.password,
  );
}
