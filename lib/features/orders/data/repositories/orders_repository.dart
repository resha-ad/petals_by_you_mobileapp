import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/core/services/hive/hive_service.dart';
import 'package:sprint1_project/features/orders/data/datasources/remote/orders_remote_datasource.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  return OrderRepositoryImpl(
    remote: ref.read(orderRemoteDatasourceProvider),
    hive: ref.read(hiveServiceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDatasource _remote;
  final HiveService _hive;
  final INetworkInfo _networkInfo;

  OrderRepositoryImpl({
    required IOrderRemoteDatasource remote,
    required HiveService hive,
    required INetworkInfo networkInfo,
  }) : _remote = remote,
       _hive = hive,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, OrderEntity>> placeOrder({
    required String paymentMethod,
    required Map<String, dynamic> deliveryDetails,
    String? notes,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to place an order.'),
      );
    }
    try {
      final model = await _remote.placeOrder(
        paymentMethod: paymentMethod,
        deliveryDetails: deliveryDetails,
        notes: notes,
      );
      final entity = model.toEntity();
      // Prepend new order to cache
      final cached = _hive.getCachedOrders();
      await _hive.saveOrders([entity, ...cached]);
      return Right(entity);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return Right(_hive.getCachedOrders());
    }
    try {
      final models = await _remote.getMyOrders(page: page, limit: limit);
      final entities = models.map((m) => m.toEntity()).toList();
      await _hive.saveOrders(entities);
      return Right(entities);
    } catch (e) {
      final cached = _hive.getCachedOrders();
      if (cached.isNotEmpty) return Right(cached);
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String id) async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      final cached = _hive
          .getCachedOrders()
          .where((o) => o.id == id)
          .firstOrNull;
      if (cached != null) return Right(cached);
      return const Left(
        ApiFailure(message: 'You\'re offline and this order isn\'t cached.'),
      );
    }
    try {
      final model = await _remote.getOrderById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder({
    required String id,
    String? reason,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to cancel an order.'),
      );
    }
    try {
      final model = await _remote.cancelOrder(id: id, reason: reason);
      final entity = model.toEntity();
      // Update cache
      final cached = _hive.getCachedOrders();
      final updated = cached.map((o) => o.id == id ? entity : o).toList();
      await _hive.saveOrders(updated);
      return Right(entity);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  List<OrderEntity> getCachedOrders() => _hive.getCachedOrders();
}
