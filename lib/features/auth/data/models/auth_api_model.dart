import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? username;
  final String? password; // only sent during register
  final String? phoneNumber;
  final String? profilePicture;
  final String? address;
  final String? dateOfBirth;
  final String? preferredDeliveryTime;

  AuthApiModel({
    this.id,
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

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'preferredDeliveryTime': preferredDeliveryTime,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id']?.toString(),
      fullName: (json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      username: json['username']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      profilePicture:
          json['profilePicture']?.toString() ?? 'default-profile.png',
      address: json['address']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      preferredDeliveryTime: json['preferredDeliveryTime']?.toString(),
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      address: address,
      dateOfBirth: dateOfBirth,
      preferredDeliveryTime: preferredDeliveryTime,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
      address: entity.address,
      dateOfBirth: entity.dateOfBirth,
      preferredDeliveryTime: entity.preferredDeliveryTime,
    );
  }
}
