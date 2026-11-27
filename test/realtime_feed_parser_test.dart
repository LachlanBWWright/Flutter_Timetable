import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/fetch_data/realtime_feed_parser.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

void main() {
  test('worker decode retains vehicle and trip update data', () async {
    final feed = FeedMessage(
      header: FeedHeader(gtfsRealtimeVersion: '2.0'),
      entity: [
        FeedEntity(
          id: 'vehicle',
          vehicle: VehiclePosition(
            trip: TripDescriptor(tripId: 'trip-1', routeId: 'route-1'),
            vehicle: VehicleDescriptor(id: 'vehicle-1'),
            position: Position(latitude: -33.86, longitude: 151.20),
          ),
        ),
        FeedEntity(
          id: 'update',
          tripUpdate: TripUpdate(
            trip: TripDescriptor(tripId: 'trip-1'),
            stopTimeUpdate: [TripUpdate_StopTimeUpdate(stopId: 'stop-1')],
          ),
        ),
      ],
    );

    final decoded = await decodeRealtimeFeed(feed.writeToBuffer());

    expect(decoded.writeToBuffer(), feed.writeToBuffer());
    expect(decoded.entity.first.vehicle.vehicle.id, 'vehicle-1');
    expect(
      decoded.entity.last.tripUpdate.stopTimeUpdate.single.stopId,
      'stop-1',
    );
  });

  test('worker decode propagates invalid protobuf errors', () async {
    await expectLater(
      decodeRealtimeFeed(Uint8List.fromList([255])),
      throwsA(isA<Exception>()),
    );
  });
}
