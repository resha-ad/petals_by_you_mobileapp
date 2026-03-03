import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/orders/data/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';

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
