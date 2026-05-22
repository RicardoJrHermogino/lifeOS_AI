import 'package:flutter/material.dart';
import 'package:mobile/core/theme/flex_theme_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_storage_service.g.dart';

/// Service for persisting theme preferences (theme mode) to [SharedPreferences].
class ThemeStorageService {
  ThemeStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = 'theme_mode';

  ThemeMode? getThemeMode() {
    final value = _prefs.getString(_themeModeKey);
    if (value == null) return null;
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => FlexThemeConfig.defaultThemeMode,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  Future<void> clearPreferences() async {
    await _prefs.remove(_themeModeKey);
  }
}

/// Provider for [ThemeStorageService].
@Riverpod(keepAlive: true)
ThemeStorageService themeStorageService(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeStorageService(prefs);
}

/// Provider for [SharedPreferences].
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
}
