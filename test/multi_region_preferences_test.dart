import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('enabled regions persist alongside a primary region', () async {
    await TransportPreferencesService.init();
    await TransportPreferencesService.setEnabledRegions({
      TransitRegion.nsw,
      TransitRegion.victoria,
    });
    await TransportPreferencesService.setSelectedRegion(TransitRegion.victoria);

    await TransportPreferencesService.init();

    expect(TransportPreferencesService.enabledRegions.value, {
      TransitRegion.nsw,
      TransitRegion.victoria,
    });
    expect(
      TransportPreferencesService.selectedRegion.value,
      TransitRegion.victoria,
    );
  });

  test('primary region always remains enabled', () async {
    await TransportPreferencesService.init();
    await TransportPreferencesService.setSelectedRegion(
      TransitRegion.queensland,
    );

    expect(
      TransportPreferencesService.enabledRegions.value,
      contains(TransitRegion.queensland),
    );
  });
}
