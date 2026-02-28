import 'dart:io';

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

  // ─── Register ──────────────────────────────────────────────────────────────
  // POST /api/auth/register
  // Body: { firstName, lastName, username, email, password, confirmPassword }
  // Response: { success, message, data: { user fields } }
  @override
  Future<AuthApiModel> register(
    AuthApiModel user,
    String confirmPassword,
  ) async {
    try {
      final body = user.toRegisterJson()..['confirmPassword'] = confirmPassword;

      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: body,
      );

      if (response.data['success'] == true) {
        // Registration returns user data but no token — user must login
        return AuthApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────────────
  // POST /api/auth/login
  // Body: { email, password }
  // Response: { success, message, data: { user fields }, token: "..." }
  @override
  Future<AuthApiModel> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        // Save JWT token to secure storage
        final token = response.data['token'] as String?;
        if (token != null) {
          await _secureStorage.saveToken(token);
        }
        return AuthApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Login failed',
      );
    }
  }

  // ─── Who Am I ──────────────────────────────────────────────────────────────
  // GET /api/auth/whoami   (requires Bearer token)
  // Response: { success, data: { user fields }, message }
  @override
  Future<AuthApiModel> whoAmI() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.whoAmI);

      if (response.data['success'] == true) {
        return AuthApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch user');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  // ─── Update Profile ────────────────────────────────────────────────────────
  // PUT /api/auth/profile   (requires Bearer token)
  // Body (multipart if image): firstName, lastName, phone, username, password, image (file field = "image")
  // Response: { success, message, data: { user fields } }
  @override
  Future<AuthApiModel> updateProfile(
    Map<String, dynamic> data,
    File? image,
  ) async {
    try {
      dynamic requestData;

      if (image != null) {
        final fileName = image.path.split(Platform.pathSeparator).last;
        requestData = FormData.fromMap({
          ...data,
          'image': await MultipartFile.fromFile(image.path, filename: fileName),
        });
      } else {
        requestData = data;
      }

      final response = await _apiClient.dio.put(
        ApiEndpoints.updateProfile,
        data: requestData,
        options: image != null
            ? Options(contentType: 'multipart/form-data')
            : null,
      );

      if (response.data['success'] == true) {
        return AuthApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Update failed');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  // ─── Forgot Password ───────────────────────────────────────────────────────
  // POST /api/auth/forgot-password
  // Body: { email }
  // Response: { success, message }
  @override
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  // ─── Reset Password ────────────────────────────────────────────────────────
  // POST /api/auth/reset-password
  // Body: { token, newPassword }
  // Response: { success, message }
  @override
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }
}
