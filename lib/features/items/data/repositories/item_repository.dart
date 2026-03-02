import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/items/data/datasources/item_datasource.dart';
import 'package:sprint1_project/features/items/data/datasources/local/item_local_datasource.dart';
import 'package:sprint1_project/features/items/data/datasources/remote/item_remote_datasource.dart';
import 'package:sprint1_project/features/items/data/models/item_api_model.dart';
import 'package:sprint1_project/features/items/data/models/item_hive_model.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';
import 'package:sprint1_project/features/items/domain/repositories/item_repository.dart';

final itemRepositoryProvider = Provider<IItemRepository>((ref) {
  return ItemRepository(
    localDatasource: ref.read(itemLocalDatasourceProvider),
    remoteDatasource: ref.read(itemRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// ── DataResult wrapper ────────────────────────────────────────────────────────
// Wraps the returned data with a flag telling the ViewModel whether the data
// came from the live API (fromCache=false) or Hive (fromCache=true).
// This is the ONLY reliable way to propagate the cache flag through Either<>.
class DataResult<T> {
  final T data;
  final bool fromCache;
  const DataResult(this.data, {required this.fromCache});
}

class ItemRepository implements IItemRepository {
  final IItemLocalDataSource _local;
  final IItemRemoteDataSource _remote;
  final INetworkInfo _networkInfo;

  ItemRepository({
    required IItemLocalDataSource localDatasource,
    required IItemRemoteDataSource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _local = localDatasource,
       _remote = remoteDatasource,
       _networkInfo = networkInfo;

  // ── getItems ───────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, DataResult<List<ItemEntity>>>> getItems({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? featured,
    String? sort,
  }) async {
    final hasInternet = await _networkInfo.isConnected;

    // ── OFFLINE ──────────────────────────────────────────────────────────────
    if (!hasInternet) {
      final cached = _local.getAllItems();
      if (cached.isNotEmpty) {
        return Right(
          DataResult(
            ItemHiveModel.toEntityList(cached),
            fromCache: true, // ← this flag drives the offline UI
          ),
        );
      }
      return const Left(
        LocalDatabaseFailure(message: 'No internet and no cached data'),
      );
    }

    // ── ONLINE ───────────────────────────────────────────────────────────────
    try {
      final models = await _remote.getItems(
        page: page,
        limit: limit,
        search: search,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        featured: featured,
        sort: sort,
      );
      final entities = ItemApiModel.toEntityList(models);

      // Cache only first unfiltered page for offline use
      final isUnfiltered =
          search == null &&
          category == null &&
          minPrice == null &&
          maxPrice == null &&
          featured == null &&
          sort == null &&
          page == 1;

      if (isUnfiltered) {
        await _local.saveItems(entities.map(ItemHiveModel.fromEntity).toList());
      }

      return Right(DataResult(entities, fromCache: false));
    } catch (e) {
      // Network call failed (timeout, server error, etc.) → try cache
      final cached = _local.getAllItems();
      if (cached.isNotEmpty) {
        return Right(
          DataResult(ItemHiveModel.toEntityList(cached), fromCache: true),
        );
      }
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ── getItemById ────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, DataResult<ItemEntity>>> getItemById(String id) async {
    final hasInternet = await _networkInfo.isConnected;

    if (!hasInternet) {
      final model = _local.getItemById(id);
      if (model != null) {
        return Right(DataResult(model.toEntity(), fromCache: true));
      }
      return const Left(
        LocalDatabaseFailure(message: 'No internet and item not cached'),
      );
    }

    try {
      final model = await _remote.getItemById(id);
      final entity = model.toEntity();
      await _local.saveItem(ItemHiveModel.fromEntity(entity));
      return Right(DataResult(entity, fromCache: false));
    } catch (e) {
      final model = _local.getItemById(id);
      if (model != null) {
        return Right(DataResult(model.toEntity(), fromCache: true));
      }
      return Left(
        ApiFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  bool hasCachedItems() => _local.getAllItems().isNotEmpty;

  @override
  List<ItemEntity> getCachedItems() =>
      ItemHiveModel.toEntityList(_local.getAllItems());

  @override
  bool isCacheFresh({Duration maxAge = const Duration(hours: 1)}) =>
      _local.isCacheFresh(maxAge: maxAge);
}
