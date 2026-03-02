import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/favorites/data/repositories/favorites_repository.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';

// ── GetFavorites ──────────────────────────────────────────────────────────────

final getFavoritesUsecaseProvider = Provider<GetFavoritesUsecase>((ref) {
  return GetFavoritesUsecase(ref.read(favoritesRepositoryProvider));
});

class GetFavoritesUsecase implements UseCaseWithoutParams<FavoritesEntity> {
  final IFavoritesRepository _repo;
  GetFavoritesUsecase(this._repo);

  @override
  Future<Either<Failure, FavoritesEntity>> call() => _repo.getFavorites();
}

// ── AddFavorite ───────────────────────────────────────────────────────────────

class AddFavoriteParams extends Equatable {
  final String type;
  final String refId;
  const AddFavoriteParams({required this.type, required this.refId});

  @override
  List<Object?> get props => [type, refId];
}

final addFavoriteUsecaseProvider = Provider<AddFavoriteUsecase>((ref) {
  return AddFavoriteUsecase(ref.read(favoritesRepositoryProvider));
});

class AddFavoriteUsecase
    implements UseCaseWithParams<FavoritesEntity, AddFavoriteParams> {
  final IFavoritesRepository _repo;
  AddFavoriteUsecase(this._repo);

  @override
  Future<Either<Failure, FavoritesEntity>> call(AddFavoriteParams params) =>
      _repo.addFavorite(type: params.type, refId: params.refId);
}

// ── RemoveFavorite ────────────────────────────────────────────────────────────

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
