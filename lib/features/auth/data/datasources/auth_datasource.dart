import 'dart:io';

import 'package:sprint1_project/features/auth/data/models/auth_api_model.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<AuthHiveModel> saveUser(AuthHiveModel user);
  Future<AuthHiveModel?> getCachedUser();
  Future<bool> clearUser();
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user, String confirmPassword);
  Future<AuthApiModel> login(String email, String password);
  Future<AuthApiModel> whoAmI();
  Future<AuthApiModel> updateProfile(Map<String, dynamic> data, File? image);
  Future<bool> forgotPassword(String email);
  Future<bool> resetPassword(String token, String newPassword);
}
