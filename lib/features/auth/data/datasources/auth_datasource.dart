import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDataSource {
  Future<bool> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<bool> isEmailExists(String email);
}
