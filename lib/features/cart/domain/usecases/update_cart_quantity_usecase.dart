import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/cart/data/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';

class UpdateQuantityParams extends Equatable {
  final String refId;
  final int quantity;
  const UpdateQuantityParams({required this.refId, required this.quantity});

  @override
  List<Object?> get props => [refId, quantity];
}

final updateCartQuantityUsecaseProvider =
    Provider<UpdateCartQuantityUsecase>((ref) {
  return UpdateCartQuantityUsecase(ref.read(cartRepositoryProvider));
});

class UpdateCartQuantityUsecase
    implements UseCaseWithParams<CartEntity, UpdateQuantityParams> {
  final ICartRepository _repo;
  UpdateCartQuantityUsecase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(UpdateQuantityParams params) =>
      _repo.updateQuantity(refId: params.refId, quantity: params.quantity);
}
