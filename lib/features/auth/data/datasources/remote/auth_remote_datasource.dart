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

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.users,
        data: user.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final registeredUser = AuthApiModel.fromJson(data);
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

  @override
  Future<String> uploadProfilePicture(File image) async {
    try {
      final fileName = image.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiEndpoints.userUploadProfilePicture,
        data: formData,
      );

      if (response.data['success'] == true) {
        return response.data['data'] as String;
      }

      throw Exception(response.data['message'] ?? 'Upload failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<AuthApiModel> updateUser(
    String id,
    Map<String, dynamic> data,
    File? image,
  ) async {
    try {
      dynamic requestData = data;

      // If image is provided, use FormData (supports both image + fields in one request)
      if (image != null) {
        final fileName = image.path.split(Platform.pathSeparator).last;
        final formData = FormData.fromMap({
          ...data,
          'profilePicture': await MultipartFile.fromFile(
            image.path,
            filename: fileName,
          ),
        });
        requestData = formData;
      }

      final response = await _apiClient.dio.put(
        ApiEndpoints.userById(id),
        data: requestData,
        options: image != null
            ? Options(contentType: 'multipart/form-data')
            : null,
      );

      if (response.data['success'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(userData);
      }

      throw Exception(response.data['message'] ?? 'Update failed');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<AuthApiModel> getUser(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.userById(id));

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(data);
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
}
