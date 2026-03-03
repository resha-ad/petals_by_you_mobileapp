import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/favorites/data/repositories/favorites_repository.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';

final getFavoritesUsecaseProvider = Provider<GetFavoritesUsecase>((ref) {
  return GetFavoritesUsecase(ref.read(favoritesRepositoryProvider));
});

class GetFavoritesUsecase implements UseCaseWithoutParams<FavoritesEntity> {
  final IFavoritesRepository _repo;
  GetFavoritesUsecase(this._repo);

  @override
  Future<Either<Failure, FavoritesEntity>> call() => _repo.getFavorites();
}
