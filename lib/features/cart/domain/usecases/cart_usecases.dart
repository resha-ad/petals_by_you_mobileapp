import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/cart/data/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';

// ── GetCart ───────────────────────────────────────────────────────────────────
final getCartUsecaseProvider = Provider<GetCartUsecase>((ref) {
  return GetCartUsecase(ref.read(cartRepositoryProvider));
});

class GetCartUsecase implements UseCaseWithoutParams<CartEntity> {
  final ICartRepository _repo;
  GetCartUsecase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call() => _repo.getCart();
}

// ── AddProduct ────────────────────────────────────────────────────────────────
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

// ── RemoveItem ────────────────────────────────────────────────────────────────
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

// ── UpdateQuantity ────────────────────────────────────────────────────────────
class UpdateQuantityParams extends Equatable {
  final String refId;
  final int quantity;
  const UpdateQuantityParams({required this.refId, required this.quantity});

  @override
  List<Object?> get props => [refId, quantity];
}

final updateCartQuantityUsecaseProvider = Provider<UpdateCartQuantityUsecase>((
  ref,
) {
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

// ── ClearCart ─────────────────────────────────────────────────────────────────
final clearCartUsecaseProvider = Provider<ClearCartUsecase>((ref) {
  return ClearCartUsecase(ref.read(cartRepositoryProvider));
});

class ClearCartUsecase implements UseCaseWithoutParams<CartEntity> {
  final ICartRepository _repo;
  ClearCartUsecase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call() => _repo.clearCart();
}
