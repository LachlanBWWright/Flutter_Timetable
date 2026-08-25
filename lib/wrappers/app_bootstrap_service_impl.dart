import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../logs/logger.dart';
import '../services/api_key_service.dart';
import '../services/app_preferences.dart';
import '../services/debug_service.dart';
import '../services/transport_preferences_service.dart';
import '../transit/registry/app_transit_context.dart';
import '../victoria/services/ptv_credentials.dart';

class AppBootstrapService {
  const AppBootstrapService._();

  static Future<void> initialize() async {
    await _loadDotEnv();
    await AppPreferences.init();
    await DebugService.init();
    await TransportPreferencesService.init();
    await ApiKeyService.init();
    await PtvCredentialService.init();
    await AppTransitContext.instance.initialize();
  }

  static Future<void> _loadDotEnv() async {
    try {
      await dotenv.load();
    } catch (error, stackTrace) {
      safeLogWarning(
        'Failed to load dotenv during app bootstrap: $error\n$stackTrace',
      );
    }
  }
}
