import 'package:dartz/dartz.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';

abstract interface class IFavoritesRepository {
  Future<Either<Failure, FavoritesEntity>> getFavorites();
  Future<Either<Failure, FavoritesEntity>> addFavorite({
    required String type,
    required String refId,
  });
  Future<Either<Failure, FavoritesEntity>> removeFavorite(String refId);
}
