import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/core/services/notifications/push_notification_service.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';
import 'package:sprint1_project/features/cart/data/models/cart_hive_model.dart';
import 'package:sprint1_project/features/delivery/data/models/delivery_hive_model.dart';
import 'package:sprint1_project/features/favorites/data/models/favorites_hive_model.dart';
import 'package:sprint1_project/features/items/data/models/item_hive_model.dart';
import 'package:sprint1_project/features/notifications/data/models/notification_hive_model.dart';
import 'package:sprint1_project/features/orders/data/models/order_hive_model.dart';
import 'package:sprint1_project/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiEndpoints.init();

  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);

  // Register ALL adapters before opening any box
  // Notification adapter
  if (!Hive.isAdapterRegistered(HiveTableConstant.notificationTypeId)) {
    Hive.registerAdapter(NotificationHiveModelAdapter());
  }
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
  // ── NEW: Delivery adapter ──────────────────────────────────────────────────
  if (!Hive.isAdapterRegistered(HiveTableConstant.deliveryTypeId)) {
    Hive.registerAdapter(DeliveryHiveModelAdapter());
  }

  await _safeOpenBox<NotificationHiveModel>(
    directory.path,
    HiveTableConstant.notificationTable,
  );
  // Open all boxes with stale-data recovery
  await _safeOpenBox<AuthHiveModel>(
    directory.path,
    HiveTableConstant.authTable,
  );
  await _safeOpenBox<dynamic>(
    directory.path,
    HiveTableConstant.appSettingsTable,
  );
  await _safeOpenBox<ItemHiveModel>(
    directory.path,
    HiveTableConstant.itemTable,
  );
  await _safeOpenBox<FavoriteItemHiveModel>(
    directory.path,
    HiveTableConstant.favoritesTable,
  );
  await _safeOpenBox<CartItemHiveModel>(
    directory.path,
    HiveTableConstant.cartTable,
  );
  await _safeOpenBox<OrderHiveModel>(
    directory.path,
    HiveTableConstant.orderTable,
  );
  // ── NEW: Delivery box ──────────────────────────────────────────────────────
  await _safeOpenBox<DeliveryHiveModel>(
    directory.path,
    HiveTableConstant.deliveryTable,
  );

  runApp(const ProviderScope(child: MyApp()));
  // Init push notification service
  await PushNotificationService.instance.init();
}

Future<void> _safeOpenBox<T>(String dirPath, String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
  } catch (e) {
    debugPrint('[Hive] Failed to open "$boxName": $e — wiping and retrying.');
    final boxFile = File('$dirPath/$boxName.hive');
    final lockFile = File('$dirPath/$boxName.lock');
    if (await boxFile.exists()) await boxFile.delete();
    if (await lockFile.exists()) await lockFile.delete();
    await Hive.openBox<T>(boxName);
  }
}
