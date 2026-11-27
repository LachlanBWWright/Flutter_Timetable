import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../logs/logger.dart';
import '../services/api_key_service.dart';
import '../services/app_appearance_service.dart';
import '../services/app_preferences.dart';
import '../services/debug_service.dart';
import '../services/preference_read_failure.dart';
import '../services/transport_preferences_service.dart';
import '../transit/registry/app_transit_context.dart';
import '../victoria/services/ptv_credentials.dart';

@immutable
class BootstrapStageFailure {
  const BootstrapStageFailure(this.stage);

  final String stage;

  String get message => 'Could not load $stage. Retry to try again.';
}

@immutable
class BootstrapReport {
  BootstrapReport(Iterable<BootstrapStageFailure> failures)
    : failures = List.unmodifiable(failures);

  final List<BootstrapStageFailure> failures;
  bool get hasFailures => failures.isNotEmpty;
}

class AppBootstrapService {
  const AppBootstrapService._();

  static final ValueNotifier<BootstrapReport> report =
      ValueNotifier<BootstrapReport>(BootstrapReport(const []));
  static final Map<String, Future<void> Function()> _stages = {
    'appearance settings': AppAppearanceService.init,
    'debug settings': DebugService.init,
    'transport settings': TransportPreferencesService.init,
    'API key settings': ApiKeyService.init,
    'PTV credentials': PtvCredentialService.init,
  };
  static final Map<String, BootstrapStageFailure> _failures = {};

  static Future<void> initialize() async {
    await _loadDotEnv();
    await AppPreferences.init();
    for (final stage in _stages.entries) {
      await _runStage(stage.key, stage.value);
    }
    await AppTransitContext.instance.initialize();
  }

  static Future<void> retryFailedStages() async {
    for (final stage in _stages.entries) {
      if (_failures.containsKey(stage.key)) {
        await _runStage(stage.key, stage.value);
      }
    }
  }

  static Future<void> _runStage(
    String name,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      _failures.remove(name);
    } on PreferenceReadFailure catch (error, stackTrace) {
      safeLogWarning('Failed to load $name: $error\n$stackTrace');
      _failures[name] = BootstrapStageFailure(name);
    }
    report.value = BootstrapReport(_failures.values);
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
