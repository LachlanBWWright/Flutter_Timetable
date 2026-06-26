import 'package:flutter/foundation.dart';

import '../services/app_preferences.dart';
import '../transit/domain/transit_types.dart';

class TransportPreferencesService {
  static const String _showNswTrainLinkKey = 'show_nsw_trainlink';
  static const String _selectedRegionKey = 'selected_transit_region';

  static final ValueNotifier<bool> showNswTrainLink = ValueNotifier<bool>(
    false,
  );
  static final ValueNotifier<TransitRegion> selectedRegion =
      ValueNotifier<TransitRegion>(TransitRegion.nsw);

  static Future<void> init() async {
    try {
      showNswTrainLink.value =
          await AppPreferences.getBool(_showNswTrainLinkKey) ?? false;
      selectedRegion.value = TransitRegionX.fromStorage(
        await AppPreferences.getString(_selectedRegionKey),
      );
    } catch (_) {
      showNswTrainLink.value = false;
      selectedRegion.value = TransitRegion.nsw;
    }
  }

  static Future<void> setShowNswTrainLink(bool value) async {
    try {
      await AppPreferences.setBool(_showNswTrainLinkKey, value);
    } catch (_) {}
    showNswTrainLink.value = value;
  }

  static Future<void> setSelectedRegion(TransitRegion region) async {
    try {
      await AppPreferences.setString(_selectedRegionKey, region.name);
    } catch (_) {}
    selectedRegion.value = region;
  }
}
