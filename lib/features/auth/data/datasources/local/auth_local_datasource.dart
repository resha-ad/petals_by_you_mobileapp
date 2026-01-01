import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/hive/hive_service.dart';
import 'package:sprint1_project/features/auth/data/datasources/auth_datasource.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      return _hiveService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      return await _hiveService.loginUser(email, password);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      await _hiveService.registerUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      return _hiveService.isEmailExists(email);
    } catch (e) {
      return false;
    }
  }
}
