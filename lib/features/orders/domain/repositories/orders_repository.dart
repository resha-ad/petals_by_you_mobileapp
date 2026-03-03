import 'package:dartz/dartz.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';

abstract interface class IOrderRepository {
  Future<Either<Failure, OrderEntity>> placeOrder({
    required String paymentMethod,
    required Map<String, dynamic> deliveryDetails,
    String? notes,
  });
  Future<Either<Failure, List<OrderEntity>>> getMyOrders({int page, int limit});
  Future<Either<Failure, OrderEntity>> getOrderById(String id);
  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String id,
    String? reason,
  });
  List<OrderEntity> getCachedOrders();
}
