import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/registry/app_transit_context.dart';

void main() {
  test('application context resolves every registered Australian region', () {
    final context = AppTransitContext.instance;
    for (final region in TransitRegion.values) {
      final services = context.servicesFor(region);
      expect(services.region, region);
      expect(services.attribution.name, isNotEmpty);
      expect(services.stops, isNotNull);
    }
  });
}
