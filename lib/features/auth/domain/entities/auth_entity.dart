import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? password; // only used during registration
  final String? phone;
  final String? imageUrl;
  final String role; // "user" | "admin"

  const AuthEntity({
    this.authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.password,
    this.phone,
    this.imageUrl,
    this.role = 'user',
  });

  /// Convenience getter — combines firstName + lastName
  String get fullName => '$firstName $lastName'.trim();

  AuthEntity copyWith({
    String? authId,
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? password,
    String? phone,
    String? imageUrl,
    String? role,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
    authId,
    firstName,
    lastName,
    email,
    username,
    phone,
    imageUrl,
    role,
  ];
}
