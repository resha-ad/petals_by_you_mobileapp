import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/hive/hive_service.dart';
import 'package:sprint1_project/features/items/data/datasources/item_datasource.dart';
import 'package:sprint1_project/features/items/data/models/item_hive_model.dart';

final itemLocalDatasourceProvider = Provider<IItemLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return ItemLocalDatasource(hiveService: hiveService);
});

class ItemLocalDatasource implements IItemLocalDataSource {
  final HiveService _hiveService;

  ItemLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> saveItems(List<ItemHiveModel> items) async {
    await _hiveService.saveItems(items);
  }

  @override
  Future<void> saveItem(ItemHiveModel item) async {
    await _hiveService.saveItem(item);
  }

  @override
  List<ItemHiveModel> getAllItems() {
    return _hiveService.getAllItems();
  }

  @override
  ItemHiveModel? getItemById(String itemId) {
    return _hiveService.getItemById(itemId);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _hiveService.deleteItem(itemId);
  }

  @override
  Future<void> clearItems() async {
    await _hiveService.clearItems();
  }

  @override
  bool isCacheFresh({Duration maxAge = const Duration(hours: 1)}) {
    // Delegates to the correctly named method on HiveService
    return _hiveService.isItemCacheFresh(maxAge: maxAge);
  }
}
