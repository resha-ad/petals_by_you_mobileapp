import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/cart/data/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';

class AddProductParams extends Equatable {
  final String itemId;
  final int quantity;
  const AddProductParams({required this.itemId, this.quantity = 1});

  @override
  List<Object?> get props => [itemId, quantity];
}

final addProductUsecaseProvider = Provider<AddProductUsecase>((ref) {
  return AddProductUsecase(ref.read(cartRepositoryProvider));
});

class AddProductUsecase
    implements UseCaseWithParams<CartEntity, AddProductParams> {
  final ICartRepository _repo;
  AddProductUsecase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(AddProductParams params) =>
      _repo.addProduct(itemId: params.itemId, quantity: params.quantity);
}
