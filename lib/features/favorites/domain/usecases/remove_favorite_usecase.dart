import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/favorites/data/repositories/favorites_repository.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';

final removeFavoriteUsecaseProvider = Provider<RemoveFavoriteUsecase>((ref) {
  return RemoveFavoriteUsecase(ref.read(favoritesRepositoryProvider));
});

class RemoveFavoriteUsecase
    implements UseCaseWithParams<FavoritesEntity, String> {
  final IFavoritesRepository _repo;
  RemoveFavoriteUsecase(this._repo);

  @override
  Future<Either<Failure, FavoritesEntity>> call(String refId) =>
      _repo.removeFavorite(refId);
}
