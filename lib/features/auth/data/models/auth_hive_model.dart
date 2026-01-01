import 'package:hive/hive.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
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
  final String? password;
  @HiveField(4)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.password,
    this.profilePicture,
  }) : authId = authId ?? const Uuid().v4();

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      password: password,
      profilePicture: profilePicture,
    );
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }
}
