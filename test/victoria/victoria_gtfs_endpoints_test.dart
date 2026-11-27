import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/victoria/services/victoria_gtfs_endpoints.dart';

void main() {
  group('Transport Victoria endpoint catalog', () {
    test('uses the official GTFS Schedule download', () {
      expect(victoriaStaticGtfsUrl, endsWith('/download/gtfs.zip'));
    });

    test('contains all published realtime mode feed sets', () {
      expect(victoriaRealtimeFeedSets, hasLength(4));
      expect(
        victoriaRealtimeFeedSetById('metro')?.alertsUrl,
        endsWith('/metro/service-alerts/'),
      );
      expect(
        victoriaRealtimeFeedSetById('tram')?.tripUpdatesUrl,
        endsWith('/tram/trip-updates/'),
      );
      expect(victoriaRealtimeFeedSetById('bus')?.alertsUrl, isNull);
      expect(victoriaRealtimeFeedSetById('vline')?.alertsUrl, isNull);
      expect(victoriaRealtimeFeedSetById('missing'), isNull);
    });
  });
}
