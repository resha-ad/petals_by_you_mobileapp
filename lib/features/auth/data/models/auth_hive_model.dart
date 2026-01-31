import 'package:hive/hive.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/auth/data/models/auth_api_model.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';
part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? username;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String? phoneNumber;

  @HiveField(6)
  final String? profilePicture;

  // Future profile fields
  @HiveField(7)
  final String? address;

  @HiveField(8)
  final String? dateOfBirth;

  @HiveField(9)
  final String? preferredDeliveryTime;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.phoneNumber,
    this.profilePicture,
    this.address,
    this.dateOfBirth,
    this.preferredDeliveryTime,
  }) : authId = authId ?? const Uuid().v4();

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
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

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
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

  // factory to convert from API model ───────────────────────
  factory AuthHiveModel.fromApiModel(AuthApiModel apiModel) {
    return AuthHiveModel(
      authId: apiModel.id,
      fullName: apiModel.fullName,
      email: apiModel.email,
      username: apiModel.username,
      password: apiModel.password, // usually null from API after login/register
      phoneNumber: apiModel.phoneNumber,
      profilePicture: apiModel.profilePicture,
      address: apiModel.address,
      dateOfBirth: apiModel.dateOfBirth,
      preferredDeliveryTime: apiModel.preferredDeliveryTime,
    );
  }
}
