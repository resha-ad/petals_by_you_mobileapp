import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprint1_project/core/sensors/light_sensor_service.dart';

enum ThemePref { system, light, dark, auto }

class AppThemeNotifier extends Notifier<ThemeMode> {
  static const _kPrefKey = 'theme_pref';
  ThemePref _pref = ThemePref.system;

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefKey) ?? 'system';
    _pref = ThemePref.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => ThemePref.system,
    );
    state = _resolve(_pref, null);
  }

  ThemeMode _resolve(ThemePref pref, AmbientLight? light) => switch (pref) {
    ThemePref.light => ThemeMode.light,
    ThemePref.dark => ThemeMode.dark,
    ThemePref.auto =>
      light == AmbientLight.dark ? ThemeMode.dark : ThemeMode.light,
    ThemePref.system => ThemeMode.system,
  };

  Future<void> setPref(ThemePref pref) async {
    _pref = pref;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, pref.name);
    state = _resolve(pref, null);
  }

  /// Called by profile screen on every light sensor update.
  void applyLightSensor(AmbientLight light) {
    if (_pref == ThemePref.auto) state = _resolve(_pref, light);
  }

  ThemePref get pref => _pref;
}

final appThemeProvider = NotifierProvider<AppThemeNotifier, ThemeMode>(
  AppThemeNotifier.new,
);
