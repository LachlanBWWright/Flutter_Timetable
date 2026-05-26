import 'package:flutter/foundation.dart';

import '../services/app_preferences.dart';

class TransportPreferencesService {
  static const String _showNswTrainLinkKey = 'show_nsw_trainlink';

  static final ValueNotifier<bool> showNswTrainLink = ValueNotifier<bool>(
    false,
  );

  static Future<void> init() async {
    try {
      showNswTrainLink.value =
          await AppPreferences.getBool(_showNswTrainLinkKey) ?? false;
    } catch (_) {
      showNswTrainLink.value = false;
    }
  }

  static Future<void> setShowNswTrainLink(bool value) async {
    try {
      await AppPreferences.setBool(_showNswTrainLinkKey, value);
    } catch (_) {}
    showNswTrainLink.value = value;
  }
}
