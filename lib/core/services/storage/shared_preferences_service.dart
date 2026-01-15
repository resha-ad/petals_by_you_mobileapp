import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPrefsService>((ref) {
  return SharedPrefsService();
});

class SharedPrefsService {
  static const String _isFirstLaunch = 'is_first_launch';

  Future<void> setFirstLaunch(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunch, value);
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunch) ?? true;
  }
}
