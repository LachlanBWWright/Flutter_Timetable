import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/queensland/translink/translink.dart';

void main() {
  group('TransLink endpoint catalog', () {
    test('contains static GTFS feeds from Queensland open data', () {
      expect(translinkStaticGtfsFeeds, hasLength(19));
      expect(translinkStaticFeedById('SEQ')?.url, endsWith('/SEQ_GTFS.zip'));
      expect(translinkStaticFeedById('CNS')?.label, 'Cairns');
      expect(translinkStaticFeedById('missing'), isNull);
    });

    test('contains published GTFS-Realtime feed sets', () {
      expect(translinkRealtimeFeedSets, hasLength(5));

      final seq = translinkRealtimeFeedSetById('SEQ');
      expect(seq, isNotNull);
      expect(seq!.tripUpdatesUrl, endsWith('/SEQ/TripUpdates'));
      expect(seq.vehiclePositionsUrl, endsWith('/SEQ/VehiclePositions'));
      expect(seq.alertsUrl, endsWith('/SEQ/Alerts'));
      expect(translinkRealtimeFeedSetById('missing'), isNull);
    });
  });
}
