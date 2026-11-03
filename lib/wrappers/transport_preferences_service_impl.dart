import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/app_preferences.dart';
import '../transit/domain/transit_types.dart';
import '../transit/registry/region_feature_flags.dart';

class TransportPreferencesService {
  static const String _showNswTrainLinkKey = 'show_nsw_trainlink';
  static const String _selectedRegionKey = 'selected_transit_region';
  static const String _enabledRegionsKey = 'enabled_transit_regions';
  static const String _regionsRecordKey = 'transit_regions_record';
  static Future<void>? _pendingRegionWrite;

  static final ValueNotifier<bool> showNswTrainLink = ValueNotifier<bool>(
    false,
  );
  static final ValueNotifier<TransitRegion> selectedRegion =
      ValueNotifier<TransitRegion>(TransitRegion.nsw);
  static final ValueNotifier<Set<TransitRegion>> enabledRegions =
      ValueNotifier<Set<TransitRegion>>({TransitRegion.nsw});

  static Future<void> init() async {
    final nextShowNswTrainLink =
        await AppPreferences.getBoolOrThrow(_showNswTrainLinkKey) ?? false;
    final record = await AppPreferences.getStringOrThrow(_regionsRecordKey);
    String? storedSelected;
    Iterable<String>? storedRegions;
    if (record != null) {
      try {
        final decoded = jsonDecode(record) as Map<String, dynamic>;
        final selected = decoded['selected'] as String?;
        final enabled = (decoded['enabled'] as List?)?.cast<String>().toList();
        storedSelected = selected;
        storedRegions = enabled;
      } on FormatException {
        // A corrupt record uses safe defaults rather than older settings.
      } on TypeError {
        // Unknown record shapes also use safe defaults.
      }
    } else if (!await AppPreferences.containsKeyOrThrow(_regionsRecordKey)) {
      storedSelected = await AppPreferences.getStringOrThrow(
        _selectedRegionKey,
      );
      storedRegions = (await AppPreferences.getStringOrThrow(
        _enabledRegionsKey,
      ))?.split(',');
    }
    final parsedSelected = TransitRegionX.fromStorage(storedSelected);
    final selected = RegionFeatureFlags.isEnabled(parsedSelected)
        ? parsedSelected
        : RegionFeatureFlags.enabledRegions.first;
    final enabled = storedRegions
        ?.map(TransitRegionX.fromStorageOrNull)
        .whereType<TransitRegion>()
        .where(RegionFeatureFlags.isEnabled)
        .toSet();
    showNswTrainLink.value = nextShowNswTrainLink;
    enabledRegions.value = Set.unmodifiable({...?enabled, selected});
    selectedRegion.value = selected;
  }

  static Future<void> setShowNswTrainLink(bool value) async {
    await AppPreferences.setBoolOrThrow(_showNswTrainLinkKey, value);
    showNswTrainLink.value = value;
  }

  static Future<void> setSelectedRegion(TransitRegion region) {
    if (!RegionFeatureFlags.isEnabled(region)) return Future<void>.value();
    return _serializeRegionWrite(
      () => _saveRegions(region, {...enabledRegions.value, region}),
    );
  }

  static Future<void> setEnabledRegions(Set<TransitRegion> regions) {
    final allowed = regions.where(RegionFeatureFlags.isEnabled).toSet();
    final normalized = allowed.isEmpty
        ? RegionFeatureFlags.enabledRegions
        : allowed;
    return _serializeRegionWrite(
      () => _saveRegions(
        normalized.contains(selectedRegion.value)
            ? selectedRegion.value
            : normalized.first,
        normalized,
      ),
    );
  }

  static Future<void> _saveRegions(
    TransitRegion selected,
    Set<TransitRegion> enabled,
  ) async {
    await AppPreferences.setStringOrThrow(
      _regionsRecordKey,
      jsonEncode({
        'selected': selected.name,
        'enabled': enabled.map((region) => region.name).toList(),
      }),
    );
    enabledRegions.value = Set.unmodifiable(enabled);
    selectedRegion.value = selected;
  }

  // Serialize read-modify-write operations so concurrent saves preserve both
  // the selected region and the complete enabled set. A failure still reaches
  // its caller, while later saves are allowed to proceed.
  static Future<void> _serializeRegionWrite(Future<void> Function() write) {
    final previous = _pendingRegionWrite;
    final result = previous == null
        ? Future<void>.sync(write)
        : previous.then((_) => write());
    late final Future<void> pending;
    void release() {
      // Completed work must not retain a future from an earlier caller's zone.
      if (identical(_pendingRegionWrite, pending)) _pendingRegionWrite = null;
    }

    pending = result.then<void>(
      (_) => release(),
      onError: (Object _, StackTrace _) => release(),
    );
    _pendingRegionWrite = pending;
    return result;
  }
}
