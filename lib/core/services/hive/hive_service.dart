import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';
import 'package:sprint1_project/features/cart/data/models/cart_hive_model.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/delivery/data/models/delivery_hive_model.dart';
import 'package:sprint1_project/features/favorites/data/models/favorites_hive_model.dart';
import 'package:sprint1_project/features/items/data/models/item_hive_model.dart';
import 'package:sprint1_project/features/notifications/data/models/notification_hive_model.dart';
import 'package:sprint1_project/features/orders/data/models/order_hive_model.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';

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
    if (!Hive.isAdapterRegistered(HiveTableConstant.itemTypeId)) {
      Hive.registerAdapter(ItemHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.favoritesTypeId)) {
      Hive.registerAdapter(FavoriteItemHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.cartTypeId)) {
      Hive.registerAdapter(CartItemHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.orderTypeId)) {
      Hive.registerAdapter(OrderHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.deliveryTypeId)) {
      Hive.registerAdapter(DeliveryHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.notificationTypeId)) {
      Hive.registerAdapter(NotificationHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox(HiveTableConstant.appSettingsTable);
    await Hive.openBox<ItemHiveModel>(HiveTableConstant.itemTable);
    await Hive.openBox<FavoriteItemHiveModel>(HiveTableConstant.favoritesTable);
    await Hive.openBox<CartItemHiveModel>(HiveTableConstant.cartTable);
    await Hive.openBox<OrderHiveModel>(HiveTableConstant.orderTable);
    await Hive.openBox<DeliveryHiveModel>(HiveTableConstant.deliveryTable);
    await Hive.openBox<NotificationHiveModel>(
      HiveTableConstant.notificationTable,
    );
  }

  Future<void> close() async => await Hive.close();

  // ── Auth ───────────────────────────────────────────────────────────────────
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  static const String _currentUserKey = 'current_user';

  Future<void> saveUser(AuthHiveModel model) async =>
      await _authBox.put(_currentUserKey, model);
  AuthHiveModel? getCachedUser() => _authBox.get(_currentUserKey);
  Future<void> clearUser() async => await _authBox.delete(_currentUserKey);
  bool isEmailExists(String email) =>
      _authBox.values.any((u) => u.email == email);

  // ── Items ──────────────────────────────────────────────────────────────────
  Box<ItemHiveModel> get _itemBox =>
      Hive.box<ItemHiveModel>(HiveTableConstant.itemTable);

  Future<void> saveItems(List<ItemHiveModel> items) async {
    await _itemBox.clear();
    await _itemBox.putAll({for (final i in items) i.itemId: i});
  }

  Future<void> saveItem(ItemHiveModel item) async =>
      await _itemBox.put(item.itemId, item);
  List<ItemHiveModel> getAllItems() => _itemBox.values.toList();
  ItemHiveModel? getItemById(String itemId) => _itemBox.get(itemId);
  Future<void> deleteItem(String itemId) async => await _itemBox.delete(itemId);
  Future<void> clearItems() async => await _itemBox.clear();

  bool isItemCacheFresh({Duration maxAge = const Duration(hours: 1)}) {
    if (_itemBox.isEmpty) return false;
    final latest = _itemBox.values
        .map((i) => i.cachedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return DateTime.now().difference(latest) < maxAge;
  }

  // ── Favorites ──────────────────────────────────────────────────────────────
  Box<FavoriteItemHiveModel> get _favoritesBox =>
      Hive.box<FavoriteItemHiveModel>(HiveTableConstant.favoritesTable);

  Future<void> saveFavorites(List<FavoriteItemHiveModel> items) async {
    await _favoritesBox.clear();
    await _favoritesBox.putAll({for (final i in items) i.refId: i});
  }

  List<FavoriteItemHiveModel> getCachedFavorites() =>
      _favoritesBox.values.toList();
  Future<void> clearFavorites() async => await _favoritesBox.clear();

  // ── Cart ───────────────────────────────────────────────────────────────────
  Box<CartItemHiveModel> get _cartBox =>
      Hive.box<CartItemHiveModel>(HiveTableConstant.cartTable);

  static const String _cartTotalKey = '_cart_total_';

  Future<void> saveCart(List<CartItemHiveModel> items, double total) async {
    await _cartBox.clear();
    await _cartBox.putAll({for (final i in items) i.refId: i});
    final settingsBox = Hive.box(HiveTableConstant.appSettingsTable);
    await settingsBox.put(_cartTotalKey, total);
  }

  CartEntity? getCachedCart() {
    final items = _cartBox.values.toList();
    if (items.isEmpty) return null;
    final settingsBox = Hive.box(HiveTableConstant.appSettingsTable);
    final total = (settingsBox.get(_cartTotalKey) as num?)?.toDouble() ?? 0.0;
    return CartEntity(
      userId: '',
      items: items.map((m) => m.toEntity()).toList(),
      total: total,
    );
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
    final settingsBox = Hive.box(HiveTableConstant.appSettingsTable);
    await settingsBox.delete(_cartTotalKey);
  }

  // ── Orders ─────────────────────────────────────────────────────────────────
  Box<OrderHiveModel> get _orderBox =>
      Hive.box<OrderHiveModel>(HiveTableConstant.orderTable);

  Future<void> saveOrders(List<OrderEntity> orders) async {
    await _orderBox.clear();
    await _orderBox.putAll({
      for (final o in orders) o.id: OrderHiveModel.fromEntity(o),
    });
  }

  List<OrderEntity> getCachedOrders() =>
      _orderBox.values.map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> clearOrders() async => await _orderBox.clear();

  // ── Delivery ───────────────────────────────────────────────────────────────
  // The delivery local datasource accesses its own box directly
  // (keyed by orderId). These helpers are optional convenience wrappers.
  Box<DeliveryHiveModel> get _deliveryBox =>
      Hive.box<DeliveryHiveModel>(HiveTableConstant.deliveryTable);

  Future<void> clearDeliveries() async => await _deliveryBox.clear();
}

// ── Notifications ───────────────────────────────────────────────────────────
Box<NotificationHiveModel> get _notificationBox =>
    Hive.box<NotificationHiveModel>(HiveTableConstant.notificationTable);

Future<void> saveNotifications(List<NotificationHiveModel> models) async {
  await _notificationBox.clear();
  await _notificationBox.putAll({for (final m in models) m.id: m});
}

List<NotificationHiveModel> getCachedNotifications() =>
    _notificationBox.values.toList();

Future<void> clearNotifications() async => _notificationBox.clear();
