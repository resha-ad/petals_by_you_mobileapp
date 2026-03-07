import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/cart/data/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';

final clearCartUsecaseProvider = Provider<ClearCartUsecase>((ref) {
  return ClearCartUsecase(ref.read(cartRepositoryProvider));
});

class ClearCartUsecase implements UseCaseWithoutParams<CartEntity> {
  final ICartRepository _repo;
  ClearCartUsecase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call() => _repo.clearCart();
}
