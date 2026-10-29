import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/transit/registry/region_feature_flags.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('enabled regions persist alongside a primary region', () async {
    final regions = RegionFeatureFlags.enabledRegions;
    final selected = regions.last;
    await TransportPreferencesService.init();
    await TransportPreferencesService.setEnabledRegions(regions);
    await TransportPreferencesService.setSelectedRegion(selected);

    await TransportPreferencesService.init();

    expect(TransportPreferencesService.enabledRegions.value, regions);
    expect(TransportPreferencesService.selectedRegion.value, selected);
  });

  test('disabled regions cannot be selected', () async {
    await TransportPreferencesService.init();
    final disabled = TransitRegion.values.where(
      (r) => !RegionFeatureFlags.isEnabled(r),
    );
    for (final region in disabled) {
      await TransportPreferencesService.setSelectedRegion(region);
    }

    expect(
      TransportPreferencesService.selectedRegion.value,
      RegionFeatureFlags.enabledRegions.first,
    );
    expect(TransportPreferencesService.enabledRegions.value, {
      RegionFeatureFlags.enabledRegions.first,
    });
  });

  test('persisted regions are filtered by the active build flags', () async {
    final disabled = TransitRegion.values.where(
      (region) => !RegionFeatureFlags.isEnabled(region),
    );
    final stored = disabled.isEmpty
        ? RegionFeatureFlags.enabledRegions
              .map((region) => region.name)
              .join(',')
        : disabled.first.name;
    final selected = disabled.isEmpty ? 'unknown-region' : disabled.first.name;
    SharedPreferences.setMockInitialValues({
      'selected_transit_region': selected,
      'enabled_transit_regions': 'bad-region,,$stored',
    });

    await TransportPreferencesService.init();

    expect(
      TransportPreferencesService.selectedRegion.value,
      RegionFeatureFlags.enabledRegions.first,
    );
    expect(
      TransportPreferencesService.enabledRegions.value,
      disabled.isEmpty
          ? RegionFeatureFlags.enabledRegions
          : {RegionFeatureFlags.enabledRegions.first},
    );
  });

  test('changing the enabled set moves selection when needed', () async {
    await TransportPreferencesService.init();

    final target = RegionFeatureFlags.enabledRegions.last;
    await TransportPreferencesService.setEnabledRegions({target});

    expect(TransportPreferencesService.enabledRegions.value, {target});
    expect(
      TransportPreferencesService.enabledRegions.value,
      contains(TransportPreferencesService.selectedRegion.value),
    );
  });
}
