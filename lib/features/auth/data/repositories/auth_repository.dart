import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/auth/data/datasources/auth_datasource.dart';
import 'package:sprint1_project/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sprint1_project/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:sprint1_project/features/auth/data/models/auth_api_model.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    localDatasource: ref.read(authLocalDatasourceProvider),
    remoteDatasource: ref.read(authRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _localDatasource;
  final IAuthRemoteDataSource _remoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource localDatasource,
    required IAuthRemoteDataSource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    final apiModel = AuthApiModel.fromEntity(entity);

    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.register(apiModel);

        // Cache in Hive
        final hiveModel = AuthHiveModel.fromEntity(entity);
        await _localDatasource.register(hiveModel);

        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline registration
      final exists = await _localDatasource.isEmailExists(entity.email);
      if (exists) {
        return const Left(
          LocalDatabaseFailure(message: "Email already exists"),
        );
      }

      final hiveModel = AuthHiveModel.fromEntity(entity);
      await _localDatasource.register(hiveModel);
      return const Right(true);
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiUser = await _remoteDatasource.login(email, password);
        if (apiUser != null) {
          final entity = apiUser.toEntity();

          // Cache/update Hive
          final hiveModel = AuthHiveModel.fromEntity(entity);
          await _localDatasource.register(hiveModel);

          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid email or password"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline login (from cache)
      final model = await _localDatasource.login(email, password);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "Invalid credentials"));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _localDatasource.getCurrentUser();
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _localDatasource.logout();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
