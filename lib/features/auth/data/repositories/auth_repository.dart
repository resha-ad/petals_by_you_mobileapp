import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/core/services/storage/secure_storage_service.dart';
import 'package:sprint1_project/features/auth/data/datasources/auth_datasource.dart';
import 'package:sprint1_project/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sprint1_project/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:sprint1_project/features/auth/data/models/auth_api_model.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    localDatasource: ref.read(authLocalDatasourceProvider),
    remoteDatasource: ref.read(authRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _local;
  final IAuthRemoteDataSource _remote;
  final NetworkInfo _networkInfo;
  final SecureStorageService _secureStorage;

  AuthRepository({
    required IAuthLocalDataSource localDatasource,
    required IAuthRemoteDataSource remoteDatasource,
    required NetworkInfo networkInfo,
    required SecureStorageService secureStorage,
  }) : _local = localDatasource,
       _remote = remoteDatasource,
       _networkInfo = networkInfo,
       _secureStorage = secureStorage;

  // ─── Register ──────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final apiModel = AuthApiModel.fromEntity(entity);
      await _remote.register(apiModel, entity.password ?? '');
      // Registration succeeds — user must login separately (no token on register)
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Registration failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiUser = await _remote.login(email, password);
        // Cache user locally after successful login
        final hiveModel = AuthHiveModel.fromApiModel(apiUser);
        await _local.saveUser(hiveModel);
        return Right(apiUser.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
        );
      }
    } else {
      // Offline: try local cache
      final cached = await _local.getCachedUser();
      if (cached != null && cached.email == email) {
        return Right(cached.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: 'No internet connection'),
      );
    }
  }

  // ─── Get current user ──────────────────────────────────────────────────────
  // Tries remote first (to get fresh data), falls back to local cache
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    final token = await _secureStorage.getToken();
    if (token == null) {
      return const Left(ApiFailure(message: 'Not authenticated'));
    }

    if (await _networkInfo.isConnected) {
      try {
        final apiUser = await _remote.whoAmI();
        final hiveModel = AuthHiveModel.fromApiModel(apiUser);
        await _local.saveUser(hiveModel);
        return Right(apiUser.toEntity());
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          await _secureStorage.deleteToken();
          return const Left(
            ApiFailure(message: 'Session expired. Please login again.'),
          );
        }
        // Fall back to cache on other network errors
        final cached = await _local.getCachedUser();
        if (cached != null) return Right(cached.toEntity());
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch user',
          ),
        );
      } catch (e) {
        final cached = await _local.getCachedUser();
        if (cached != null) return Right(cached.toEntity());
        return Left(
          ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
        );
      }
    } else {
      final cached = await _local.getCachedUser();
      if (cached != null) return Right(cached.toEntity());
      return const Left(
        LocalDatabaseFailure(message: 'No internet connection'),
      );
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _secureStorage.deleteToken();
      await _local.clearUser();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ─── Update Profile ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, AuthEntity>> updateProfile(
    Map<String, dynamic> data,
    File? image,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final apiUser = await _remote.updateProfile(data, image);
      final hiveModel = AuthHiveModel.fromApiModel(apiUser);
      await _local.saveUser(hiveModel);
      return Right(apiUser.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Update failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ─── Forgot Password ───────────────────────────────────────────────────────
  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      await _remote.forgotPassword(email);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Request failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ─── Reset Password ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, bool>> resetPassword(
    String token,
    String newPassword,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      await _remote.resetPassword(token, newPassword);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Reset failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
