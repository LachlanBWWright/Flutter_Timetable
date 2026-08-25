import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/queensland/translink/translink.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';

void main() {
  final runLiveTests = Platform.environment['RUN_QLD_API_TESTS'] == 'true';

  test(
    'public TransLink SEQ static GTFS downloads and parses stops',
    () async {
      final bytes = await fetchTranslinkStaticGtfsZip('SEQ');
      expect(bytes, isNotNull);
      expect(bytes, isNotEmpty);

      final stops = parseStopsOnlyFromZipBytes(Uint8List.fromList(bytes!));
      expect(stops, isNotEmpty);
      expect(stops.first.stopName, isNotEmpty);
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'published TransLink GTFS-Realtime feeds return protobuf',
    () async {
      for (final feedSet in translinkRealtimeFeedSets) {
        final feeds = <FeedMessage?>[
          await fetchTranslinkTripUpdates(feedSet.id),
          await fetchTranslinkVehiclePositions(feedSet.id),
          await fetchTranslinkAlerts(feedSet.id),
        ];
        for (final feed in feeds) {
          expect(feed, isNotNull, reason: feedSet.id);
          expect(feed!.header.gtfsRealtimeVersion, isNotEmpty);
        }
      }
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'the app realtime repository maps the public SEQ feed',
    () async {
      const repository = TranslinkRealtimeRepository();
      final snapshot = await repository.getTripUpdates(
        const RealtimeRequest(sourceId: TransitSourceId('qld:SEQ')),
      );
      expect(snapshot.fetchedAt, isNotNull);
      for (final update in snapshot.items) {
        expect(update.tripId, isNotNull);
      }
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
