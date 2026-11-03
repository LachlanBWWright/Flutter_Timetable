import 'package:shared_preferences/shared_preferences.dart';

import '../logs/logger.dart';
import '../services/preference_read_failure.dart';
import '../services/preference_write_failure.dart';

class AppPreferences {
  static Future<void>? _pending;
  static bool _needsReload = false;

  // Serialize reads with writes: SharedPreferences updates its memory cache
  // before the platform confirms persistence.
  static Future<T> _serialized<T>(Future<T> Function() action) {
    final previous = _pending;
    final operation = previous == null
        ? Future<T>.sync(action)
        : previous.then((_) => action());
    late final Future<void> pending;
    void release() {
      // Idle calls start in their own zone; keep a tail only while work remains.
      if (identical(_pending, pending)) _pending = null;
    }

    pending = operation.then<void>(
      (_) => release(),
      onError: (Object _, StackTrace _) => release(),
    );
    _pending = pending;
    return operation;
  }

  static Future<void> init() => _serialized(() async {
    await _instance();
  });

  static Future<SharedPreferences?> _instance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_needsReload) {
        await prefs.reload();
        _needsReload = false;
      }
      return prefs;
    } catch (error, stackTrace) {
      safeLogError(
        'Failed to initialize or reload SharedPreferences',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<String?> getStringOrThrow(String key) => _serialized(() async {
    final prefs = await _instance();
    if (prefs == null) throw PreferenceReadFailure(key);
    try {
      return prefs.getString(key);
    } catch (_) {
      throw PreferenceReadFailure(key);
    }
  });

  /// Compatibility read: failures continue to produce null, with a log entry.
  static Future<String?> getString(String key) async {
    try {
      return await getStringOrThrow(key);
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences.getString failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Returns whether the key exists, or throws when storage cannot answer.
  static Future<bool> containsKeyOrThrow(String key) => _serialized(() async {
    final prefs = await _instance();
    if (prefs == null) throw PreferenceReadFailure(key);
    try {
      return prefs.containsKey(key);
    } catch (_) {
      throw PreferenceReadFailure(key);
    }
  });

  /// Compatibility read: returns null when storage cannot answer.
  static Future<bool?> containsKey(String key) async {
    try {
      return await containsKeyOrThrow(key);
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences.containsKey failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<bool?> getBoolOrThrow(String key) => _serialized(() async {
    final prefs = await _instance();
    if (prefs == null) throw PreferenceReadFailure(key);
    try {
      return prefs.getBool(key);
    } catch (_) {
      throw PreferenceReadFailure(key);
    }
  });

  /// Compatibility read: failures continue to produce null, with a log entry.
  static Future<bool?> getBool(String key) async {
    try {
      return await getBoolOrThrow(key);
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences.getBool failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<bool> _write(
    String key,
    Future<bool> Function(SharedPreferences prefs) write,
  ) => _serialized(() async {
    final prefs = await _instance();
    if (prefs == null) return false;
    try {
      if (await write(prefs)) return true;
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences write failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
    }
    // Roll back the plugin's optimistic cache from persisted values. If that
    // fails, subsequent reads/writes must reload before using the cache.
    _needsReload = true;
    try {
      await prefs.reload();
      _needsReload = false;
    } catch (error, stackTrace) {
      safeLogError(
        'SharedPreferences rollback failed for $key',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return false;
  });

  static Future<bool> setString(String key, String value) =>
      _write(key, (prefs) => prefs.setString(key, value));

  static Future<bool> setBool(String key, bool value) =>
      _write(key, (prefs) => prefs.setBool(key, value));

  static Future<bool> remove(String key) =>
      _write(key, (prefs) => prefs.remove(key));

  static Future<void> setStringOrThrow(String key, String value) async {
    if (!await setString(key, value)) throw PreferenceWriteFailure(key);
  }

  static Future<void> setBoolOrThrow(String key, bool value) async {
    if (!await setBool(key, value)) throw PreferenceWriteFailure(key);
  }

  static Future<void> removeOrThrow(String key) async {
    if (!await remove(key)) throw PreferenceWriteFailure(key);
  }
}
