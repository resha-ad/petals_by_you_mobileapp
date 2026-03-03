import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/core/services/hive/hive_service.dart';
import 'package:sprint1_project/features/cart/data/datasources/remote/cart_remote_datasource.dart';
import 'package:sprint1_project/features/cart/data/models/cart_hive_model.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<ICartRepository>((ref) {
  return CartRepositoryImpl(
    remote: ref.read(cartRemoteDatasourceProvider),
    hive: ref.read(hiveServiceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class CartRepositoryImpl implements ICartRepository {
  final ICartRemoteDatasource _remote;
  final HiveService _hive;
  final INetworkInfo _networkInfo;

  CartRepositoryImpl({
    required ICartRemoteDatasource remote,
    required HiveService hive,
    required INetworkInfo networkInfo,
  }) : _remote = remote,
       _hive = hive,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      final cached = _hive.getCachedCart();
      return Right(cached ?? const CartEntity(userId: '', items: [], total: 0));
    }
    try {
      final model = await _remote.getCart();
      final entity = model.toEntity();
      await _cacheCart(entity);
      return Right(entity);
    } catch (e) {
      final cached = _hive.getCachedCart();
      if (cached != null) return Right(cached);
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addProduct({
    required String itemId,
    required int quantity,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to add items to cart.'),
      );
    }
    try {
      final model = await _remote.addProduct(
        itemId: itemId,
        quantity: quantity,
      );
      final entity = model.toEntity();
      await _cacheCart(entity);
      return Right(entity);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeItem(String refId) async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to update cart.'),
      );
    }
    try {
      final model = await _remote.removeItem(refId);
      final entity = model.toEntity();
      await _cacheCart(entity);
      return Right(entity);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String refId,
    required int quantity,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to update cart.'),
      );
    }
    try {
      final model = await _remote.updateQuantity(
        refId: refId,
        quantity: quantity,
      );
      final entity = model.toEntity();
      await _cacheCart(entity);
      return Right(entity);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, CartEntity>> clearCart() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      return const Left(
        ApiFailure(message: 'You\'re offline. Connect to clear cart.'),
      );
    }
    try {
      final model = await _remote.clearCart();
      final entity = model.toEntity();
      await _hive.clearCart();
      return Right(entity);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  CartEntity? getCachedCart() => _hive.getCachedCart();

  Future<void> _cacheCart(CartEntity entity) async {
    final hiveItems = entity.items.map(CartItemHiveModel.fromEntity).toList();
    await _hive.saveCart(hiveItems, entity.total);
  }
}
