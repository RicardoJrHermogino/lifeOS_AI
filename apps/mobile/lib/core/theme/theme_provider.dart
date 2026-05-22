import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/flex_theme_config.dart';
import 'package:mobile/services/storage/theme_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// State class holding the current theme configuration.
class ThemeState {
  const ThemeState({required this.themeMode});

  final ThemeMode themeMode;

  factory ThemeState.defaults() => const ThemeState(
        themeMode: FlexThemeConfig.defaultThemeMode,
      );

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState && other.themeMode == themeMode;
  }

  @override
  int get hashCode => themeMode.hashCode;
}

/// Provider for the theme state with persistence.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  late ThemeStorageService _storageService;

  @override
  ThemeState build() {
    _storageService = ref.watch(themeStorageServiceProvider);

    final savedThemeMode = _storageService.getThemeMode();

    return ThemeState(
      themeMode: savedThemeMode ?? FlexThemeConfig.defaultThemeMode,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _storageService.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> resetToDefaults() async {
    await _storageService.clearPreferences();
    state = ThemeState.defaults();
  }
}

@riverpod
ThemeMode themeMode(Ref ref) {
  return ref.watch(themeControllerProvider).themeMode;
}

@riverpod
ThemeData lightTheme(Ref ref) {
  return FlexThemeConfig.light();
}

@riverpod
ThemeData darkTheme(Ref ref) {
  return FlexThemeConfig.dark();
}

@riverpod
String themeModeDisplayName(Ref ref) {
  final mode = ref.watch(themeModeProvider);
  return switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };
}
