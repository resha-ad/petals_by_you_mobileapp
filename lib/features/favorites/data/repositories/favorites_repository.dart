import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/favorites/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<IFavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(
    remote: ref.read(favoritesRemoteDatasourceProvider),
  );
});

class FavoritesRepositoryImpl implements IFavoritesRepository {
  final IFavoritesRemoteDatasource _remote;
  FavoritesRepositoryImpl({required IFavoritesRemoteDatasource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, FavoritesEntity>> getFavorites() async {
    try {
      final model = await _remote.getFavorites();
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, FavoritesEntity>> addFavorite({
    required String type,
    required String refId,
  }) async {
    try {
      final model = await _remote.addFavorite(type: type, refId: refId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, FavoritesEntity>> removeFavorite(String refId) async {
    try {
      final model = await _remote.removeFavorite(refId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
