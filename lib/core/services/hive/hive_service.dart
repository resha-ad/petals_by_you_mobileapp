import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/auth/data/models/auth_hive_model.dart';

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
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox(HiveTableConstant.appSettingsTable);
  }

  Future<void> close() async => await Hive.close();

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // ─── Cache the logged-in user ─────────────────────────────────────────────
  // We store only one user under a fixed key for simplicity.
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
}
