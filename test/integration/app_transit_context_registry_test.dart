import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/registry/app_transit_context.dart';
import 'package:lbww_flutter/transit/registry/region_feature_flags.dart';

void main() {
  test('application context resolves each build-enabled region', () {
    final context = AppTransitContext.instance;
    for (final region in RegionFeatureFlags.enabledRegions) {
      final services = context.servicesFor(region);
      expect(services.region, region);
      expect(services.attribution.name, isNotEmpty);
      expect(services.stops, isNotNull);
    }
    expect(
      RegionFeatureFlags.enabledRegions.containsAll(context.enabledRegions),
      isTrue,
    );
  });
}
