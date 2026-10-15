import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/registry/region_feature_flags.dart';

void main() {
  test('region availability matches compile-time feature flags', () {
    expect(RegionFeatureFlags.enabledRegions, isNotEmpty);
    for (final region in TransitRegion.values) {
      expect(
        RegionFeatureFlags.isEnabled(region),
        RegionFeatureFlags.enabledRegions.contains(region),
      );
    }

    final nonNswEnabled = TransitRegion.values
        .where((region) => region != TransitRegion.nsw)
        .where(RegionFeatureFlags.isEnabled)
        .toList();
    if (nonNswEnabled.isEmpty) {
      expect(RegionFeatureFlags.enabledRegions, {TransitRegion.nsw});
    } else {
      expect(RegionFeatureFlags.nsw, isTrue);
      expect(RegionFeatureFlags.enabledRegions, containsAll(nonNswEnabled));
    }
  });
}
