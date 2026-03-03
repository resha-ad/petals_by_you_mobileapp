import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/orders/data/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';

// ── PlaceOrder ────────────────────────────────────────────────────────────────
class PlaceOrderParams extends Equatable {
  final String paymentMethod;
  final Map<String, dynamic> deliveryDetails;
  final String? notes;

  const PlaceOrderParams({
    required this.paymentMethod,
    required this.deliveryDetails,
    this.notes,
  });

  @override
  List<Object?> get props => [paymentMethod, deliveryDetails];
}

final placeOrderUsecaseProvider = Provider<PlaceOrderUsecase>((ref) {
  return PlaceOrderUsecase(ref.read(orderRepositoryProvider));
});

class PlaceOrderUsecase
    implements UseCaseWithParams<OrderEntity, PlaceOrderParams> {
  final IOrderRepository _repo;
  PlaceOrderUsecase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) =>
      _repo.placeOrder(
        paymentMethod: params.paymentMethod,
        deliveryDetails: params.deliveryDetails,
        notes: params.notes,
      );
}

// ── GetMyOrders ───────────────────────────────────────────────────────────────
final getMyOrdersUsecaseProvider = Provider<GetMyOrdersUsecase>((ref) {
  return GetMyOrdersUsecase(ref.read(orderRepositoryProvider));
});

class GetMyOrdersUsecase implements UseCaseWithoutParams<List<OrderEntity>> {
  final IOrderRepository _repo;
  GetMyOrdersUsecase(this._repo);

  @override
  Future<Either<Failure, List<OrderEntity>>> call() =>
      _repo.getMyOrders(page: 1, limit: 20);
}

// ── GetOrderById ──────────────────────────────────────────────────────────────
final getOrderByIdUsecaseProvider = Provider<GetOrderByIdUsecase>((ref) {
  return GetOrderByIdUsecase(ref.read(orderRepositoryProvider));
});

class GetOrderByIdUsecase implements UseCaseWithParams<OrderEntity, String> {
  final IOrderRepository _repo;
  GetOrderByIdUsecase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(String id) =>
      _repo.getOrderById(id);
}

// ── CancelOrder ───────────────────────────────────────────────────────────────
class CancelOrderParams extends Equatable {
  final String id;
  final String? reason;
  const CancelOrderParams({required this.id, this.reason});

  @override
  List<Object?> get props => [id];
}

final cancelOrderUsecaseProvider = Provider<CancelOrderUsecase>((ref) {
  return CancelOrderUsecase(ref.read(orderRepositoryProvider));
});

class CancelOrderUsecase
    implements UseCaseWithParams<OrderEntity, CancelOrderParams> {
  final IOrderRepository _repo;
  CancelOrderUsecase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(CancelOrderParams params) =>
      _repo.cancelOrder(id: params.id, reason: params.reason);
}
