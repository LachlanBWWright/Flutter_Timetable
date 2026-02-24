import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugService {
  static const String _prefKey = 'show_debug_data';

  // Default is true (debug data visible)
  static final ValueNotifier<bool> showDebugData = ValueNotifier<bool>(true);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_prefKey);
    if (stored != null) {
      showDebugData.value = stored;
    } else {
      // default true
      showDebugData.value = true;
    }
  }

  static Future<void> setShowDebugData(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    showDebugData.value = value;
  }
}
