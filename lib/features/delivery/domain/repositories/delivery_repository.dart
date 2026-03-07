import 'package:dartz/dartz.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';

abstract interface class IDeliveryRepository {
  /// Fetch delivery info for a specific order. Returns cached if offline.
  Future<Either<Failure, DeliveryEntity>> getDeliveryByOrderId(String orderId);

  /// Returns cached delivery for an order, or null if not cached.
  DeliveryEntity? getCachedDeliveryForOrder(String orderId);
}
