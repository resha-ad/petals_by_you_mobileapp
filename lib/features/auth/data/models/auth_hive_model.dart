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
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String username;

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final String? phone;

  @HiveField(7)
  final String? imageUrl;

  @HiveField(8)
  final String role;

  AuthHiveModel({
    String? authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.password,
    this.phone,
    this.imageUrl,
    this.role = 'user',
  }) : authId = authId ?? const Uuid().v4();

  AuthEntity toEntity() => AuthEntity(
    authId: authId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    username: username,
    phone: phone,
    imageUrl: imageUrl,
    role: role,
  );

  factory AuthHiveModel.fromEntity(AuthEntity entity) => AuthHiveModel(
    authId: entity.authId,
    firstName: entity.firstName,
    lastName: entity.lastName,
    email: entity.email,
    username: entity.username,
    password: entity.password,
    phone: entity.phone,
    imageUrl: entity.imageUrl,
    role: entity.role,
  );

  factory AuthHiveModel.fromApiModel(AuthApiModel apiModel) => AuthHiveModel(
    authId: apiModel.id,
    firstName: apiModel.firstName,
    lastName: apiModel.lastName,
    email: apiModel.email,
    username: apiModel.username,
    phone: apiModel.phone,
    imageUrl: apiModel.imageUrl,
    role: apiModel.role,
  );
}
