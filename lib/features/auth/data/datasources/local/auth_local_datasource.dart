import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/hive/hive_service.dart';
import 'package:sprint1_project/features/auth/data/datasources/auth_datasource.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<IAuthLocalDataSource>((ref) {
  return AuthLocalDatasource(hiveService: ref.watch(hiveServiceProvider));
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModel> saveUser(AuthHiveModel user) async {
    await _hiveService.saveUser(user);
    return user;
  }

  @override
  Future<AuthHiveModel?> getCachedUser() async {
    try {
      return _hiveService.getCachedUser();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> clearUser() async {
    try {
      await _hiveService.clearUser();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      return _hiveService.isEmailExists(email);
    } catch (_) {
      return false;
    }
  }
}
