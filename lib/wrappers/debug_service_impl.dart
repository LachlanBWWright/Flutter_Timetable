import 'package:flutter/foundation.dart';

import '../services/app_preferences.dart';

class DebugService {
  static const String _prefKey = 'show_debug_data';

  // Default is true (debug data visible)
  static final ValueNotifier<bool> showDebugData = ValueNotifier<bool>(true);

  static Future<void> init() async {
    final stored = await AppPreferences.getBoolOrThrow(_prefKey);
    if (stored != null) {
      showDebugData.value = stored;
    }
  }

  static Future<void> setShowDebugData(bool value) async {
    await AppPreferences.setBoolOrThrow(_prefKey, value);
    showDebugData.value = value;
  }
}
