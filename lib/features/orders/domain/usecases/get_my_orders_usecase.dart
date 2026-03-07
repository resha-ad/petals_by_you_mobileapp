import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/orders/data/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';

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
