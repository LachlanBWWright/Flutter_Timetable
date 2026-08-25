import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/services/app_preferences.dart';

class PtvCredentials {
  const PtvCredentials({required this.developerId, required this.apiKey});

  final String developerId;
  final String apiKey;

  bool get isConfigured => developerId.isNotEmpty && apiKey.isNotEmpty;
}

class PtvCredentialService {
  static const _developerIdKey = 'ptv_user_developer_id';
  static const _apiKeyKey = 'ptv_user_api_key';

  static String? _developerId;
  static String? _apiKey;

  static Future<void> init() async {
    _developerId = _nonEmpty(await AppPreferences.getString(_developerIdKey));
    _apiKey = _nonEmpty(await AppPreferences.getString(_apiKeyKey));
  }

  static PtvCredentials get effectiveCredentials {
    final builtIn = _builtInCredentials();
    return PtvCredentials(
      developerId: _developerId ?? builtIn.developerId,
      apiKey: _apiKey ?? builtIn.apiKey,
    );
  }

  static bool get hasUserCredentials => _developerId != null && _apiKey != null;

  static bool get hasBuiltInCredentials => _builtInCredentials().isConfigured;

  static Future<void> setUserCredentials({
    required String developerId,
    required String apiKey,
  }) async {
    final normalizedDeveloperId = _nonEmpty(developerId);
    final normalizedApiKey = _nonEmpty(apiKey);
    if (normalizedDeveloperId == null || normalizedApiKey == null) {
      throw ArgumentError('Both PTV developer ID and API key are required.');
    }
    await AppPreferences.setString(_developerIdKey, normalizedDeveloperId);
    await AppPreferences.setString(_apiKeyKey, normalizedApiKey);
    _developerId = normalizedDeveloperId;
    _apiKey = normalizedApiKey;
  }

  static Future<void> clearUserCredentials() async {
    await AppPreferences.remove(_developerIdKey);
    await AppPreferences.remove(_apiKeyKey);
    _developerId = null;
    _apiKey = null;
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

PtvCredentials _builtInCredentials() {
  String read(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  return PtvCredentials(
    developerId: read('PTV_DEV_ID'),
    apiKey: read('PTV_API_KEY'),
  );
}

PtvCredentials loadPtvCredentials() =>
    PtvCredentialService.effectiveCredentials;
