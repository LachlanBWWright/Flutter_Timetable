import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the Transport for NSW API key used by all network requests.
///
/// The app may ship with a built-in key baked into the `.env` asset at build
/// time (via the `API_KEY` secret in CI/CD). Users can override it in the
/// Settings screen with their own key, which is persisted in
/// [SharedPreferences] and always takes priority over the built-in key.
class ApiKeyService {
  static const String _prefKey = 'user_api_key';

  /// In-memory cache of the user-supplied key. `null` means "no override".
  static String? _userApiKey;

  /// Load the user-supplied override from [SharedPreferences] into memory.
  /// Call once at app startup alongside other service initialisations.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    _userApiKey = (stored != null && stored.isNotEmpty) ? stored : null;
  }

  /// The active API key: user-supplied override if set, otherwise the key
  /// baked into the build via `.env`, falling back to an empty string.
  static String getEffectiveApiKey() {
    return _userApiKey ?? dotenv.env['API_KEY'] ?? '';
  }

  /// Whether the user has stored a custom API key override.
  static bool hasUserApiKey() => _userApiKey != null;

  /// Whether the build ships with a baked-in API key.
  static bool hasBuiltInApiKey() => (dotenv.env['API_KEY'] ?? '').isNotEmpty;

  /// Persist [key] as the user-supplied override and update the in-memory cache.
  static Future<void> setUserApiKey(String key) async {
    final trimmed = key.trim();
    final prefs = await SharedPreferences.getInstance();
    if (trimmed.isEmpty) {
      await prefs.remove(_prefKey);
      _userApiKey = null;
    } else {
      await prefs.setString(_prefKey, trimmed);
      _userApiKey = trimmed;
    }
  }

  /// Remove the user-supplied override and revert to the built-in key.
  static Future<void> clearUserApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    _userApiKey = null;
  }
}
