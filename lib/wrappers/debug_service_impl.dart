import 'package:flutter/foundation.dart';

import '../services/app_preferences.dart';

class DebugService {
  static const String _prefKey = 'show_debug_data';

  // Default is true (debug data visible)
  static final ValueNotifier<bool> showDebugData = ValueNotifier<bool>(true);

  static Future<void> init() async {
    bool? stored;
    try {
      stored = await AppPreferences.getBool(_prefKey);
    } catch (_) {
      stored = null;
    }
    if (stored != null) {
      showDebugData.value = stored;
    } else {
      // default true
      showDebugData.value = true;
    }
  }

  static Future<void> setShowDebugData(bool value) async {
    try {
      await AppPreferences.setBool(_prefKey, value);
    } catch (_) {}
    showDebugData.value = value;
  }
}
