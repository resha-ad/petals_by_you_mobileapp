import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? username;
  final String? password; // only used during registration
  final String? phoneNumber;
  final String? profilePicture;
  // Future profile fields
  final String? address;
  final String? dateOfBirth;
  final String? preferredDeliveryTime;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.username,
    this.password,
    this.phoneNumber,
    this.profilePicture,
    this.address,
    this.dateOfBirth,
    this.preferredDeliveryTime,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    username,
    password,
    phoneNumber,
    profilePicture,
    address,
    dateOfBirth,
    preferredDeliveryTime,
  ];
}
