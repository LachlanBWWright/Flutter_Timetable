import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransportPreferencesService {
  static const String _showNswTrainLinkKey = 'show_nsw_trainlink';

  static final ValueNotifier<bool> showNswTrainLink = ValueNotifier<bool>(
    false,
  );

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    showNswTrainLink.value = prefs.getBool(_showNswTrainLinkKey) ?? false;
  }

  static Future<void> setShowNswTrainLink(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showNswTrainLinkKey, value);
    showNswTrainLink.value = value;
  }
}
