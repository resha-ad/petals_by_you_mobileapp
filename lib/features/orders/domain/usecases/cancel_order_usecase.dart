import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/orders/data/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';

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
