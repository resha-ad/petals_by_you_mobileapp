import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';
import 'package:sprint1_project/features/items/data/models/item_hive_model.dart'; // NEW
import 'package:sprint1_project/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive
  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);

  // Register type adapters
  if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
    Hive.registerAdapter(AuthHiveModelAdapter());
  }
  // NEW — item adapter
  if (!Hive.isAdapterRegistered(HiveTableConstant.itemTypeId)) {
    Hive.registerAdapter(ItemHiveModelAdapter());
  }

  // Open required boxes
  await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  await Hive.openBox(HiveTableConstant.appSettingsTable);
  await Hive.openBox<ItemHiveModel>(HiveTableConstant.itemTable); // NEW

  runApp(const ProviderScope(child: MyApp()));
}
