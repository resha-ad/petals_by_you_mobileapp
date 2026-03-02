import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';
import 'package:sprint1_project/features/items/data/models/item_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init('${directory.path}/${HiveTableConstant.dbName}');
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    // Items adapter
    if (!Hive.isAdapterRegistered(HiveTableConstant.itemTypeId)) {
      Hive.registerAdapter(ItemHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox(HiveTableConstant.appSettingsTable);
    //Items box
    await Hive.openBox<ItemHiveModel>(HiveTableConstant.itemTable);
  }

  Future<void> close() async => await Hive.close();

  // Auth box
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  static const String _currentUserKey = 'current_user';

  Future<void> saveUser(AuthHiveModel model) async {
    await _authBox.put(_currentUserKey, model);
  }

  AuthHiveModel? getCachedUser() {
    return _authBox.get(_currentUserKey);
  }

  Future<void> clearUser() async {
    await _authBox.delete(_currentUserKey);
  }

  bool isEmailExists(String email) {
    return _authBox.values.any((u) => u.email == email);
  }

  // Items box
  Box<ItemHiveModel> get _itemBox =>
      Hive.box<ItemHiveModel>(HiveTableConstant.itemTable);

  Future<void> saveItems(List<ItemHiveModel> items) async {
    await _itemBox.clear();
    await _itemBox.putAll({for (final i in items) i.itemId: i});
  }

  Future<void> saveItem(ItemHiveModel item) async {
    await _itemBox.put(item.itemId, item);
  }

  List<ItemHiveModel> getAllItems() => _itemBox.values.toList();

  ItemHiveModel? getItemById(String itemId) => _itemBox.get(itemId);

  Future<void> deleteItem(String itemId) async {
    await _itemBox.delete(itemId);
  }

  Future<void> clearItems() async {
    await _itemBox.clear();
  }

  bool isItemCacheFresh({Duration maxAge = const Duration(hours: 1)}) {
    if (_itemBox.isEmpty) return false;
    final latest = _itemBox.values
        .map((i) => i.cachedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return DateTime.now().difference(latest) < maxAge;
  }
}
