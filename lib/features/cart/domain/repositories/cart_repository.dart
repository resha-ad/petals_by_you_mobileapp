import 'package:dartz/dartz.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';

abstract interface class ICartRepository {
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> addProduct({
    required String itemId,
    required int quantity,
  });
  Future<Either<Failure, CartEntity>> removeItem(String refId);
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String refId,
    required int quantity,
  });
  Future<Either<Failure, CartEntity>> clearCart();
  CartEntity? getCachedCart();
}
