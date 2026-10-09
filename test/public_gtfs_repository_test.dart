// ignore_for_file: no_null_assertion

import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/gtfs/public_gtfs_transit_adapter.dart';

void main() {
  const sourceId = TransitSourceId('fixture:network');
  const config = PublicGtfsProviderConfig(
    region: TransitRegion.tasmania,
    provider: TransitProviderId.tasmaniaPublicTransport,
    attributionName: 'Fixture Transit',
    attributionUrl: 'https://fixture.example',
    feeds: [
      PublicGtfsFeedConfig(
        sourceId: sourceId,
        label: 'Fixture network',
        url: 'https://fixture.example/gtfs.zip',
      ),
    ],
  );

  test(
    'imports fixture stops, supports lookup, and reports completion',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      var requests = 0;
      final services = buildPublicGtfsRegionServices(
        config: config,
        database: database,
        fetcher: (_) async {
          requests++;
          return _fixtureResponse();
        },
      );

      final progress = await services.staticGtfs!
          .refreshStaticData(const StaticImportRequest())
          .toList();
      final repeatedProgress = await services.staticGtfs!
          .refreshStaticData(const StaticImportRequest())
          .toList();
      final matches = await services.stops.searchStops(
        const StopSearchRequest(query: 'Argyle', limit: 5),
      );
      final stop = await services.stops.getStop(
        const TransitStopRef(
          region: TransitRegion.tasmania,
          provider: TransitProviderId.tasmaniaPublicTransport,
          sourceId: sourceId,
          stopId: 'A1',
        ),
      );
      final plan = await services.journeyPlanner!.planJourney(
        JourneyPlanRequest(
          origin: stop!.ref,
          destination: const TransitStopRef(
            region: TransitRegion.tasmania,
            provider: TransitProviderId.tasmaniaPublicTransport,
            sourceId: sourceId,
            stopId: 'B1',
          ),
          when: DateTime(2026, 8, 12, 9),
        ),
      );
      final saved = await database.insertJourney(
        db.JourneysCompanion.insert(
          origin: stop.name,
          originId: stop.ref.storageKey,
          destination: plan.journeys.single.legs.single.destination.name,
          destinationId:
              plan.journeys.single.legs.single.destination.ref.storageKey,
        ),
      );
      final storedJourneys = await database.getAllJourneys();

      expect(requests, 3);
      expect(progress, hasLength(2));
      expect(progress.first.completed, 0);
      expect(progress.last.completed, 1);
      expect(progress.last.error, isNull);
      expect(repeatedProgress.last.completed, 1);
      expect(
        await database.getAllStopsForEndpoint(sourceId.value),
        hasLength(2),
      );
      expect(matches.map((item) => item.ref.stopId), ['A1']);
      expect(stop?.name, 'Argyle Street');
      expect(stop?.ref.sourceId, sourceId);
      expect(plan.journeys, hasLength(1));
      expect(plan.journeys.single.legs.single.route?.shortName, '10');
      expect(storedJourneys, hasLength(1));
      expect(storedJourneys.single.id, saved);
      expect(storedJourneys.single.originId, stop.ref.storageKey);
    },
  );

  test(
    'maps fixture timetable rows to sorted departures and caches the feed',
    () async {
      var requests = 0;
      final services = buildPublicGtfsRegionServices(
        config: config,
        fetcher: (_) async {
          requests++;
          return _fixtureResponse();
        },
      );
      const stop = TransitStopRef(
        region: TransitRegion.tasmania,
        provider: TransitProviderId.tasmaniaPublicTransport,
        sourceId: sourceId,
        stopId: 'A1',
      );
      final request = DepartureRequest(
        stop: stop,
        when: DateTime(2026, 8, 11, 9, 0),
      );

      final departures = await services.departures!.getDepartures(request);
      final cachedDepartures = await services.departures!.getDepartures(
        request,
      );

      expect(requests, 1);
      expect(departures, hasLength(2));
      expect(departures.map((item) => item.tripId), ['T1', 'T2']);
      expect(departures.first.plannedTime, DateTime(2026, 8, 11, 10));
      expect(departures.last.plannedTime, DateTime(2026, 8, 11, 10, 30));
      expect(departures.first.route?.shortName, '10');
      expect(departures.first.route?.mode, isNotNull);
      expect(cachedDepartures, hasLength(2));
    },
  );

  test(
    'applies calendar exceptions and supports trips after midnight',
    () async {
      final services = buildPublicGtfsRegionServices(
        config: config,
        fetcher: (_) async => _fixtureResponse(),
      );
      const stop = TransitStopRef(
        region: TransitRegion.tasmania,
        provider: TransitProviderId.tasmaniaPublicTransport,
        sourceId: sourceId,
        stopId: 'A1',
      );

      final exceptionDay = await services.departures!.getDepartures(
        DepartureRequest(stop: stop, when: DateTime(2026, 8, 13, 9)),
      );
      final overnight = await services.departures!.getDepartures(
        DepartureRequest(stop: stop, when: DateTime(2026, 8, 12, 23)),
      );

      expect(exceptionDay, hasLength(1));
      expect(exceptionDay.single.tripId, 'T3');
      expect(overnight, hasLength(1));
      expect(overnight.single.tripId, 'T4');
      expect(overnight.single.plannedTime, DateTime(2026, 8, 13, 1, 10));
    },
  );

  test(
    'reports invalid feed responses without claiming an import succeeded',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = PublicGtfsStaticRepository(
        config: config,
        database: database,
        fetcher: (_) async => http.Response('not a zip file', 200),
      );

      final progress = await repository
          .refreshStaticData(const StaticImportRequest())
          .toList();
      final importedStops = await database.getAllStopsForEndpoint(
        sourceId.value,
      );

      expect(progress.last.error, isNotNull);
      expect(progress.last.completed, 0);
      expect(importedStops, isEmpty);
    },
  );
}

http.Response _fixtureResponse() {
  final archive = Archive()
    ..addFile(
      ArchiveFile.string(
        'stops.txt',
        'stop_id,stop_name,stop_lat,stop_lon\n'
            'A1,Argyle Street,-42.88,147.33\n'
            'B1,Hobart City,-42.89,147.32\n',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'calendar.txt',
        'service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date\n'
            'daily,1,1,1,1,1,1,1,20260101,20261231\n',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'calendar_dates.txt',
        'service_id,date,exception_type\n'
            'daily,20260813,2\n'
            'overnight,20260812,1\n'
            'special,20260813,1\n',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'routes.txt',
        'route_id,route_short_name,route_long_name,route_type\n'
            'R1,10,City bus,3\n',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'trips.txt',
        'route_id,service_id,trip_id,trip_headsign\n'
            'R1,daily,T1,Hobart City\n'
            'R1,daily,T2,Hobart City\n'
            'R1,special,T3,Hobart City\n'
            'R1,overnight,T4,Hobart City\n',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'stop_times.txt',
        'trip_id,arrival_time,departure_time,stop_id,stop_sequence\n'
            'T2,10:30:00,10:30:00,A1,1\n'
            'T1,10:00:00,10:00:00,A1,1\n'
            'T3,11:00:00,11:00:00,A1,1\n'
            'T4,25:10:00,25:10:00,A1,1\n'
            'T1,10:10:00,10:10:00,B1,2\n'
            'T2,10:40:00,10:40:00,B1,2\n'
            'T3,11:10:00,11:10:00,B1,2\n'
            'T4,25:20:00,25:20:00,B1,2\n',
      ),
    );
  final bytes = Uint8List.fromList(ZipEncoder().encode(archive));
  return http.Response.bytes(bytes, 200);
}
