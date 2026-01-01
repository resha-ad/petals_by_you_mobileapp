import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? password;
  final String? profilePicture; // Optional for future

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    password,
    profilePicture,
  ];
}
