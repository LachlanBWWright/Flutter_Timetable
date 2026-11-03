import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/realtime_service.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'FIREBASE_CACHE_URL=https://cache.example/transitCache',
    );
  });
  setUp(RealtimeService.invalidateRealtimeCache);

  test(
    'selected trip reaches backend and preserves original cache age',
    () async {
      final fetched = DateTime.now().toUtc().subtract(
        const Duration(seconds: 20),
      );
      final requests = <Map<String, dynamic>>[];
      final result = await http.runWithClient(
        () => RealtimeService.getTripUpdatesForModeSafe(
          TransportMode.train,
          query: RealtimeQuery(tripIds: ['trip-a']),
        ),
        () => MockClient((request) async {
          expect(request.url.host, 'cache.example');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          requests.add(body);
          final feed = FeedMessage(
            header: FeedHeader(gtfsRealtimeVersion: '2.0'),
            entity: [
              FeedEntity(
                id: 'trip-a',
                tripUpdate: TripUpdate(
                  trip: TripDescriptor(tripId: 'trip-a', startDate: '20261028'),
                ),
              ),
            ],
          );
          return http.Response.bytes(
            feed.writeToBuffer(),
            200,
            headers: {
              'content-type': 'application/x-protobuf',
              'x-transit-version': '1',
              'x-transit-fetched-at': fetched.toIso8601String(),
              'x-transit-expires-at': fetched
                  .add(const Duration(seconds: 30))
                  .toIso8601String(),
            },
          );
        }),
      );
      expect(requests, hasLength(1));
      expect(requests.single['filter'], {
        'tripIds': ['trip-a'],
      });
      expect(result.tripUpdates.single.trip.startDate, '20261028');
      expect(result.metadata.fetchedAt, fetched);
      expect(result.metadata.failedSources, isEmpty);
    },
  );

  test(
    'fresh loaded full feed answers scoped query without another request',
    () async {
      var requests = 0;
      final fetched = DateTime.now().toUtc();
      await http.runWithClient(
        () async {
          await RealtimeService.getTripUpdatesForModeSafe(TransportMode.train);
          final result = await RealtimeService.getTripUpdatesForModeSafe(
            TransportMode.train,
            query: RealtimeQuery(tripIds: ['trip-b']),
          );
          // A full loaded feed is valid coverage; final identity matching remains
          // with the existing caller. No filtered download is necessary.
          expect(result.tripUpdates.single.trip.tripId, 'trip-b');
          expect(result.metadata.fetchedAt, fetched);
        },
        () => MockClient((request) async {
          requests++;
          final feed = FeedMessage(
            header: FeedHeader(gtfsRealtimeVersion: '2.0'),
            entity: [
              FeedEntity(
                id: 'b',
                tripUpdate: TripUpdate(trip: TripDescriptor(tripId: 'trip-b')),
              ),
            ],
          );
          return http.Response.bytes(
            feed.writeToBuffer(),
            200,
            headers: {
              'content-type': 'application/x-protobuf',
              'x-transit-version': '1',
              'x-transit-fetched-at': fetched.toIso8601String(),
              'x-transit-expires-at': fetched
                  .add(const Duration(seconds: 30))
                  .toIso8601String(),
            },
          );
        }),
      );
      expect(requests, 1);
    },
  );
}
