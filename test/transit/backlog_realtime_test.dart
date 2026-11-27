import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart'
    as pb;
import 'package:lbww_flutter/transit/gtfs/gtfs_realtime_updates.dart';
import 'package:lbww_flutter/transit/transit.dart';

import 'gtfs_planner_fixtures.dart';

void main() {
  test(
    'maps every stop update, cancellations, source and service identity',
    () {
      final feed = (pb.FeedMessage()
        ..mergeFromProto3Json(
          jsonDecode(
            '''{"header":{"gtfsRealtimeVersion":"2.0"},"entity":[{"id":"1","tripUpdate":{"trip":{"tripId":"T1","startDate":"20260813","routeId":"R1"},"stopTimeUpdate":[{"stopId":"A","departure":{"delay":120}},{"stopId":"B","scheduleRelationship":"SKIPPED"},{"stopSequence":3,"arrival":{"delay":180}}]}}]}''',
          ),
        ));
      final updates = gtfsRealtimeUpdates(
        feed,
        region: TransitRegion.queensland,
        provider: TransitProviderId.translink,
        source: plannerSource,
      );
      expect(updates, hasLength(3));
      expect(updates[0].departureDelaySeconds, 120);
      expect(updates[1].skipped, isTrue);
      expect(
        updates.every(
          (u) => u.serviceDate == '20260813' && u.sourceId == plannerSource,
        ),
        isTrue,
      );
      final matched = matchGtfsUpdates(plannerData(), updates);
      expect(matched.last.stop!.stopId, 'C');
    },
  );
  test('delays propagate to later stops until NO_DATA', () {
    final data = plannerData();
    final planned = DateTime.utc(2026, 8, 13, 0, 20),
        date = DateTime.utc(2026, 8, 13);
    final update = TransitTripUpdate(
      tripId: 'T1',
      stop: plannerStop('A'),
      serviceDate: '20260813',
      departureDelaySeconds: 120,
    );
    expect(
      gtfsUpdatedTime(
        [update],
        'C',
        planned,
        date,
        arrival: true,
        stopTimes: data.index.timesByTrip['T1']!,
      ),
      planned.add(const Duration(minutes: 2)),
    );
    final noData = TransitTripUpdate(
      tripId: 'T1',
      stop: plannerStop('B'),
      serviceDate: '20260813',
      noData: true,
    );
    expect(
      gtfsUpdatedTime(
        [update, noData],
        'C',
        planned,
        date,
        arrival: true,
        stopTimes: data.index.timesByTrip['T1']!,
      ),
      isNull,
    );
  });
  test('a foreign route ID never attaches to a matching trip ID', () {
    expect(
      matchGtfsUpdates(plannerData(), [
        const TransitTripUpdate(tripId: 'T1', routeId: 'foreign'),
      ]),
      isEmpty,
    );
  });
}
