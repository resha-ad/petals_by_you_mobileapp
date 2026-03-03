import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/delivery/data/datasources/local/delivery_local_datasource.dart';
import 'package:sprint1_project/features/delivery/data/datasources/remote/delivery_remote_datasource.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';
import 'package:sprint1_project/features/delivery/domain/repositories/delivery_repository.dart';

final deliveryRepositoryProvider = Provider<IDeliveryRepository>((ref) {
  return DeliveryRepositoryImpl(
    remote: ref.read(deliveryRemoteDatasourceProvider),
    local: ref.read(deliveryLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class DeliveryRepositoryImpl implements IDeliveryRepository {
  final IDeliveryRemoteDatasource _remote;
  final IDeliveryLocalDatasource _local;
  final INetworkInfo _networkInfo;

  DeliveryRepositoryImpl({
    required IDeliveryRemoteDatasource remote,
    required IDeliveryLocalDatasource local,
    required INetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, DeliveryEntity>> getDeliveryByOrderId(
    String orderId,
  ) async {
    final isOnline = await _networkInfo.isConnected;

    // Offline — serve from local cache
    if (!isOnline) {
      final cached = _local.getDeliveryByOrderId(orderId);
      if (cached != null) return Right(cached);
      return const Left(
        ApiFailure(message: 'You\'re offline and delivery info is not cached.'),
      );
    }

    // Online — fetch from API, cache it, return it
    try {
      final model = await _remote.getDeliveryByOrderId(orderId);
      if (model == null) {
        // No delivery record yet for this order
        return const Left(
          ApiFailure(message: 'No delivery info available for this order yet.'),
        );
      }
      final entity = model.toEntity();
      await _local.saveDelivery(entity);
      return Right(entity);
    } catch (e) {
      // Network call failed — try cache as fallback
      final cached = _local.getDeliveryByOrderId(orderId);
      if (cached != null) return Right(cached);
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  DeliveryEntity? getCachedDeliveryForOrder(String orderId) =>
      _local.getDeliveryByOrderId(orderId);
}
