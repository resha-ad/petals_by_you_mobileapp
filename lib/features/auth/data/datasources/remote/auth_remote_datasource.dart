import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/api/api_client.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/core/services/storage/secure_storage_service.dart';
import 'package:sprint1_project/features/auth/data/datasources/auth_datasource.dart';
import 'package:sprint1_project/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage;

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.dio.post(
        // Changed to .dio.post
        ApiEndpoints.users,
        data: user.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final registeredUser = AuthApiModel.fromJson(data);

        // Token usually NOT returned after register
        // Only save if your backend returns it (very rare)
        final token = response.data['token'] as String?;
        if (token != null) {
          await _secureStorage.saveToken(token);
        }

        return registeredUser;
      }

      throw Exception(response.data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        // Changed to .dio.post
        ApiEndpoints.userLogin,
        data: {"email": email, "password": password},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final user = AuthApiModel.fromJson(data);

        final token = response.data['token'] as String?;
        if (token != null) {
          await _secureStorage.saveToken(token);
        }

        return user;
      }

      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }
}
