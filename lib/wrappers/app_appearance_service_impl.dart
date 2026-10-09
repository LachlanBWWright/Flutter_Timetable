import 'package:flutter/material.dart';

import '../services/app_preferences.dart';

class AppAppearanceService {
  static const String _themeModeKey = 'theme_mode';

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  static Future<void> init() async {
    final storedMode = await AppPreferences.getString(_themeModeKey);
    themeMode.value = switch (storedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    await AppPreferences.setString(_themeModeKey, mode.name);
    themeMode.value = mode;
  }
}
