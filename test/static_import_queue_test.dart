import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs;
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';

void main() {
  test('same endpoint waits while unrelated endpoint can import', () async {
    final releaseTrain = await EndpointStaticUpdateQueue.acquire(
      StopsEndpoint.nswtrains,
    );
    final acquired = Completer<void>();
    final pendingTrain =
        EndpointStaticUpdateQueue.acquire(StopsEndpoint.nswtrains).then((
          release,
        ) {
          acquired.complete();
          return release;
        });
    final releaseMetro = await EndpointStaticUpdateQueue.acquire(
      StopsEndpoint.metro,
    );
    expect(acquired.isCompleted, false);
    releaseMetro();
    releaseTrain();
    final releaseNextTrain = await pendingTrain;
    expect(acquired.isCompleted, true);
    releaseNextTrain();
  });

  test(
    'background preparation publishes database and memory index together',
    () async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final service = TripLineService(
        readPersistedCache: false,
        gtfsLoader: (_) async => throw StateError('Should use published index'),
      );
      final feed = GtfsData(
        agencies: [],
        calendars: [],
        calendarDates: [],
        routes: [
          gtfs_route.Route(
            routeId: 'R',
            routeShortName: 'T1',
            routeLongName: 'Line',
            routeType: '2',
          ),
        ],
        stops: [
          gtfs.Stop(
            stopId: 'S',
            stopName: 'Station',
            stopLat: -33,
            stopLon: 151,
            locationType: 1,
            wheelchairBoarding: 1,
          ),
        ],
        trips: [Trip(routeId: 'R', serviceId: 'WD', tripId: 'T')],
        stopTimes: [
          StopTime(
            tripId: 'T',
            arrivalTime: '08:00:00',
            departureTime: '08:00:00',
            stopId: 'S',
            stopSequence: '1',
          ),
        ],
        shapes: [],
        notes: [],
      );
      await service.publishStaticDataForEndpoint(
        StopsEndpoint.nswtrains,
        feed,
        database: database,
      );
      expect(
        (await database.getAllStopsForEndpoint('nswtrains')).single.stopId,
        'S',
      );
      expect(
        (await database.getRoutesForEndpoint('nswtrains')).single.routeId,
        'R',
      );
      final lines = await service.getStopsForLine(
        'nswtrains|R',
        TransportMode.train,
        allowBuild: true,
      );
      expect(lines.single.stopId, 'S');
      expect(
        (await database.getStaticCacheStatus('nswtrains'))?.isBuilding,
        false,
      );
    },
  );

  test(
    'invalid prepared feed preserves published data and releases queue',
    () async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      await database.insertStop(
        StopsCompanion.insert(
          endpoint: 'nswtrains',
          stopId: 'old',
          stopName: 'Old station',
        ),
      );
      final service = TripLineService(readPersistedCache: false);
      final invalid = GtfsData(
        agencies: [],
        calendars: [],
        calendarDates: [],
        routes: [],
        stops: [],
        stopTimes: [],
        trips: [],
        shapes: [],
        notes: [],
      );
      await expectLater(
        service.publishStaticDataForEndpoint(
          StopsEndpoint.nswtrains,
          invalid,
          database: database,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        (await database.getAllStopsForEndpoint('nswtrains')).single.stopId,
        'old',
      );
      expect(await database.getStaticCacheStatus('nswtrains'), isNull);
      final release = await EndpointStaticUpdateQueue.acquire(
        StopsEndpoint.nswtrains,
      );
      release();
    },
  );
}
