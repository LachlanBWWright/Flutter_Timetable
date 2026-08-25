import 'package:flutter/foundation.dart';

import '../services/app_preferences.dart';
import '../transit/domain/transit_types.dart';

class TransportPreferencesService {
  static const String _showNswTrainLinkKey = 'show_nsw_trainlink';
  static const String _selectedRegionKey = 'selected_transit_region';
  static const String _enabledRegionsKey = 'enabled_transit_regions';

  static final ValueNotifier<bool> showNswTrainLink = ValueNotifier<bool>(
    false,
  );
  static final ValueNotifier<TransitRegion> selectedRegion =
      ValueNotifier<TransitRegion>(TransitRegion.nsw);
  static final ValueNotifier<Set<TransitRegion>> enabledRegions =
      ValueNotifier<Set<TransitRegion>>({TransitRegion.nsw});

  static Future<void> init() async {
    try {
      showNswTrainLink.value =
          await AppPreferences.getBool(_showNswTrainLinkKey) ?? false;
      selectedRegion.value = TransitRegionX.fromStorage(
        await AppPreferences.getString(_selectedRegionKey),
      );
      final storedRegions = await AppPreferences.getString(_enabledRegionsKey);
      final parsedRegions = storedRegions
          ?.split(',')
          .map(TransitRegionX.fromStorageOrNull)
          .whereType<TransitRegion>()
          .toSet();
      enabledRegions.value = parsedRegions == null || parsedRegions.isEmpty
          ? {selectedRegion.value}
          : parsedRegions;
      if (!enabledRegions.value.contains(selectedRegion.value)) {
        enabledRegions.value = {...enabledRegions.value, selectedRegion.value};
      }
    } catch (_) {
      showNswTrainLink.value = false;
      selectedRegion.value = TransitRegion.nsw;
      enabledRegions.value = {TransitRegion.nsw};
    }
  }

  static Future<void> setShowNswTrainLink(bool value) async {
    try {
      await AppPreferences.setBool(_showNswTrainLinkKey, value);
    } catch (_) {}
    showNswTrainLink.value = value;
  }

  static Future<void> setSelectedRegion(TransitRegion region) async {
    if (!enabledRegions.value.contains(region)) {
      await setEnabledRegions({...enabledRegions.value, region});
    }
    try {
      await AppPreferences.setString(_selectedRegionKey, region.name);
    } catch (_) {}
    selectedRegion.value = region;
  }

  static Future<void> setEnabledRegions(Set<TransitRegion> regions) async {
    final normalized = regions.isEmpty ? {selectedRegion.value} : {...regions};
    if (!normalized.contains(selectedRegion.value)) {
      selectedRegion.value = normalized.first;
      try {
        await AppPreferences.setString(
          _selectedRegionKey,
          selectedRegion.value.name,
        );
      } catch (_) {}
    }
    try {
      await AppPreferences.setString(
        _enabledRegionsKey,
        normalized.map((region) => region.name).join(','),
      );
    } catch (_) {}
    enabledRegions.value = normalized;
  }
}
