import 'package:lbww_flutter/south_australia/adelaide_metro/adelaide_metro_endpoints.dart';
import 'package:test/test.dart';

void main() {
  test('Adelaide Metro endpoint catalog uses the public GTFS feeds', () {
    expect(
      adelaideMetroStaticGtfsUrl,
      contains('/static/latest/google_transit.zip'),
    );
    expect(adelaideMetroVehiclePositionsUrl, endsWith('/vehicle_positions'));
    expect(adelaideMetroTripUpdatesUrl, endsWith('/trip_updates'));
    expect(adelaideMetroServiceAlertsUrl, endsWith('/service_alerts'));
  });
}
