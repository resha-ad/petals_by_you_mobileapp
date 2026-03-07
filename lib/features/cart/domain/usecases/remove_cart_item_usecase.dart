import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/cart/data/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';

final removeCartItemUsecaseProvider = Provider<RemoveCartItemUsecase>((ref) {
  return RemoveCartItemUsecase(ref.read(cartRepositoryProvider));
});

class RemoveCartItemUsecase implements UseCaseWithParams<CartEntity, String> {
  final ICartRepository _repo;
  RemoveCartItemUsecase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(String refId) =>
      _repo.removeItem(refId);
}
