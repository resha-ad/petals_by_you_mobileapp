import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/favorites/data/repositories/favorites_repository.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';

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
