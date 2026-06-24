import 'package:shared_preferences/shared_preferences.dart';

import '../logs/logger.dart';

class AppPreferences {
  static Future<void> init() async {
    await _instance();
  }

  static Future<SharedPreferences?> _instance() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (error, stackTrace) {
      safeLogError(
        'Failed to initialize SharedPreferences',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<String?> getString(String key) async {
    final prefs = await _instance();
    if (prefs == null) {
      return null;
    }
    try {
      return prefs.getString(key);
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences.getString failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _instance();
    if (prefs == null) {
      return null;
    }
    try {
      return prefs.getBool(key);
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences.getBool failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<bool> setString(String key, String value) async {
    final prefs = await _instance();
    if (prefs == null) {
      return false;
    }
    try {
      return await prefs.setString(key, value);
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences.setString failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance();
    if (prefs == null) {
      return false;
    }
    try {
      return await prefs.setBool(key, value);
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences.setBool failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<bool> remove(String key) async {
    final prefs = await _instance();
    if (prefs == null) {
      return false;
    }

    try {
      return await prefs.remove(key);
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences.remove failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
