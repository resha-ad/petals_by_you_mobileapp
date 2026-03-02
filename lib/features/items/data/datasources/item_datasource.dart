import 'package:sprint1_project/features/items/data/models/item_api_model.dart';
import 'package:sprint1_project/features/items/data/models/item_hive_model.dart';

// ── Local (Hive) ──────────────────────────────────────────────────────────────

abstract interface class IItemLocalDataSource {
  /// Overwrite the entire cached list.
  Future<void> saveItems(List<ItemHiveModel> items);

  /// Persist a single item (upsert).
  Future<void> saveItem(ItemHiveModel item);

  /// Return all cached items.
  List<ItemHiveModel> getAllItems();

  /// Return a single item by id, or null.
  ItemHiveModel? getItemById(String itemId);

  /// Remove a single item from cache.
  Future<void> deleteItem(String itemId);

  /// Wipe the entire cache.
  Future<void> clearItems();

  /// True when cached data was saved within [maxAge].
  bool isCacheFresh({Duration maxAge});
}

// ── Remote (API) ──────────────────────────────────────────────────────────────

abstract interface class IItemRemoteDataSource {
  Future<List<ItemApiModel>> getItems({
    int page,
    int limit,
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? featured,
    String? sort,
  });

  Future<ItemApiModel> getItemById(String id);
}
