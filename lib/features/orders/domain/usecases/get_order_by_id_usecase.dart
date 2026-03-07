import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/usecases/app_usecase.dart';
import 'package:sprint1_project/features/orders/data/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';

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
