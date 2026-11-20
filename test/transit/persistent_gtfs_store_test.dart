import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/gtfs/persistent_gtfs_store.dart';
import 'package:lbww_flutter/transit/gtfs/public_gtfs_transit_adapter.dart';
import 'package:lbww_flutter/transit/runtime/transit_resource_budget.dart';
import 'package:lbww_flutter/transit/transit.dart';

Uint8List _feed() => Uint8List.fromList(
  ZipEncoder().encode(
    Archive()
      ..addFile(
        ArchiveFile.string(
          'stops.txt',
          'stop_id,stop_name,stop_lat,stop_lon\nA,Alpha,-27,153\nB,Beta,-27,153\n',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'routes.txt',
          'route_id,route_short_name,route_long_name,route_type\nR,1,Route,3\n',
        ),
      )
      ..addFile(
        ArchiveFile.string('trips.txt', 'route_id,service_id,trip_id\nR,S,T\n'),
      )
      ..addFile(
        ArchiveFile.string(
          'stop_times.txt',
          'trip_id,arrival_time,departure_time,stop_id,stop_sequence\nT,10:00:00,10:00:00,A,1\nT,10:10:00,10:10:00,B,2\n',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'calendar.txt',
          'service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date\nS,1,1,1,1,1,1,1,20260101,20271231\n',
        ),
      ),
  ),
);

void main() {
  test(
    'forced callers share a fresh download after an ordinary load',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final store = PersistentGtfsStore(database: database);
      final started = Completer<void>(), release = Completer<void>();
      var ordinary = 0, forced = 0;
      final first = store.load(
        source: 'force-race',
        requireTimetable: true,
        fetch: () async {
          ordinary++;
          started.complete();
          await release.future;
          return _feed();
        },
      );
      await started.future;
      Future<Uint8List> fetch() async {
        forced++;
        return _feed();
      }

      final second = store.load(
        source: 'force-race',
        requireTimetable: true,
        force: true,
        fetch: fetch,
      );
      final third = store.load(
        source: 'force-race',
        requireTimetable: true,
        force: true,
        fetch: fetch,
      );
      release.complete();
      await Future.wait([first, second, third]);
      expect(ordinary, 1);
      expect(forced, 1);
    },
  );
  test(
    'disk archive budget evicts oldest archive while preserving stop modes',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final bytes = _feed();
      final store = PersistentGtfsStore(
        database: database,
        budget: TransitResourceBudget(diskArchiveBytes: bytes.length + 1),
      );
      await store.load(
        source: 'older',
        requireTimetable: true,
        fetch: () async => bytes,
      );
      await store.load(
        source: 'newer',
        requireTimetable: true,
        fetch: () async => bytes,
      );
      final rows = await database.select(database.gtfsFeedCaches).get();
      expect(rows.singleWhere((r) => r.source == 'older').archive, isEmpty);
      expect(
        rows.singleWhere((r) => r.source == 'older').stopModes,
        contains('bus'),
      );
      expect(rows.singleWhere((r) => r.source == 'newer').archive, isNotEmpty);
    },
  );

  test('stop import, journey planning, and departures reuse one persisted feed after restart', () async {
    final directory = Directory.systemTemp.createTempSync('gtfs-offline-plan');
    final file = File('${directory.path}/cache.sqlite');
    var database = db.AppDatabase.connect(NativeDatabase(file));
    const source = TransitSourceId('test:all');
    const config = PublicGtfsProviderConfig(
      region: TransitRegion.tasmania,
      provider: TransitProviderId.tasmaniaPublicTransport,
      attributionName: 'Test',
      attributionUrl: 'https://example.com',
      feeds: [
        PublicGtfsFeedConfig(
          sourceId: source,
          label: 'Test',
          url: 'https://example.com/feed',
        ),
      ],
    );
    var downloads = 0;
    final online = buildPublicGtfsRegionServices(
      config: config,
      database: database,
      fetcher: (_) async {
        downloads++;
        return http.Response.bytes(_feed(), 200);
      },
    );
    final origin = (await online.stops.searchStops(
      const StopSearchRequest(query: 'Alpha'),
    )).single;
    final destination = (await online.stops.searchStops(
      const StopSearchRequest(query: 'Beta'),
    )).single;
    expect(origin.supportsMode(TransportMode.bus), isTrue);
    expect(origin.supportsMode(TransportMode.train), isFalse);
    await database.close();
    database = db.AppDatabase.connect(NativeDatabase(file));
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });
    final offline = buildPublicGtfsRegionServices(
      config: config,
      database: database,
      fetcher: (_) async {
        downloads++;
        throw const NetworkUnavailable(message: 'Offline');
      },
    );
    final when = DateTime(2026, 11, 6, 9, 59);
    final plan = await offline.journeyPlanner!.planJourney(
      JourneyPlanRequest(
        origin: origin.ref,
        destination: destination.ref,
        when: when,
      ),
    );
    final departures = await offline.departures!.getDepartures(
      DepartureRequest(stop: origin.ref, when: when),
    );
    expect(plan.journeys, isNotEmpty);
    expect(departures.single.tripId, 'T');
    expect(departures.single.estimatedTime, isNull);
    expect(departures.single.isRealtime, isFalse);
    expect(departures.single.timetable, isNotNull);
    expect(plan.timetable, isNotNull);
    final cached = (await offline.stops.searchStops(
      const StopSearchRequest(query: 'Alpha'),
    )).single;
    expect(cached.modes, {TransportMode.bus});
    expect(downloads, 1);
  });
  test('complete timetables survive a restart and stale feeds remain usable offline', () async {
    final directory = Directory.systemTemp.createTempSync('gtfs-persist');
    final file = File('${directory.path}/cache.sqlite');
    var database = db.AppDatabase.connect(NativeDatabase(file));
    var now = DateTime(2026, 11, 6);
    final store = PersistentGtfsStore(database: database, now: () => now);
    var downloads = 0;
    final bytes = _feed();
    final original = await store.load(
      source: 'test',
      requireTimetable: true,
      fetch: () async {
        downloads++;
        return bytes;
      },
    );
    expect(original.stopTimes, hasLength(2));
    await database.close();
    database = db.AppDatabase.connect(NativeDatabase(file));
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });
    now = now.add(const Duration(days: 2));
    final restored = PersistentGtfsStore(database: database, now: () => now);
    final offline = await restored.load(
      source: 'test',
      requireTimetable: true,
      fetch: () async {
        downloads++;
        throw const NetworkUnavailable(message: 'Offline');
      },
    );
    expect(offline.timetable!.offlineFallback, isTrue);
    expect(offline.timetable!.isStale, isTrue);
    expect(offline.timetable!.fetchedAt, DateTime(2026, 11, 6));
    expect(offline.calendars.single.serviceId, 'S');
    expect(offline.trips.single.tripId, 'T');
    expect(offline.stopTimes.last.stopId, 'B');
    expect(downloads, 2);
    await expectLater(
      restored.load(
        source: 'test',
        force: true,
        fetch: () async => Uint8List(0),
      ),
      throwsA(isA<InvalidProviderResponse>()),
    );
    final saved = await database.select(database.gtfsFeedCaches).getSingle();
    expect(saved.fetchedAt, DateTime(2026, 11, 6));
    expect(saved.archive, bytes);
  });

  test('shared backend fetch dates are retained instead of restamped on the device', () async {
    final database = db.AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime(2026, 11, 6, 18);
    final fetched = DateTime(2026, 11, 6);
    final store = PersistentGtfsStore(database: database, now: () => now);
    final data = await store.load(
      source: 'backend',
      download: (_) async => GtfsArchiveDownload.fromResponse(
        http.Response.bytes(
          _feed(),
          200,
          headers: {'x-transit-fetched-at': fetched.toIso8601String()},
        ),
      ),
    );
    expect(data.timetable!.fetchedAt, fetched);
    expect(data.timetable!.isStale, isFalse);
    expect(
      (await database.select(database.gtfsFeedCaches).getSingle()).fetchedAt,
      fetched,
    );
    await expectLater(
      store.load(
        source: 'backend',
        force: true,
        download: (_) async => GtfsArchiveDownload(
          _feed(),
          fetchedAt: now.add(const Duration(days: 1)),
        ),
      ),
      throwsA(isA<InvalidProviderResponse>()),
    );
    expect(
      (await database.select(database.gtfsFeedCaches).getSingle()).fetchedAt,
      fetched,
    );
  });

  test(
    'rejects broken references and calendars without replacing a good archive',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final store = PersistentGtfsStore(database: database);
      await store.load(source: 'validated', fetch: () async => _feed());
      for (final change in <(String, String, String)>[
        ('trips.txt', 'R,S,T', 'missing,S,T'),
        ('trips.txt', 'R,S,T', 'R,missing,T'),
        (
          'stop_times.txt',
          'T,10:00:00,10:00:00,A,1',
          'missing,10:00:00,10:00:00,A,1',
        ),
        (
          'stop_times.txt',
          'T,10:00:00,10:00:00,A,1',
          'T,10:00:00,10:00:00,missing,1',
        ),
        ('calendar.txt', '20260101,20271231', '20260230,20271231'),
      ]) {
        final archive = ZipDecoder().decodeBytes(_feed());
        final replaced = Archive();
        for (final file in archive) {
          final contents = utf8.decode(file.content as List<int>);
          replaced.addFile(
            ArchiveFile.string(
              file.name,
              file.name == change.$1
                  ? contents.replaceAll(change.$2, change.$3)
                  : contents,
            ),
          );
        }
        await expectLater(
          store.load(
            source: 'validated',
            force: true,
            parse: parseGtfsStopSnapshot,
            fetch: () async =>
                Uint8List.fromList(ZipEncoder().encode(replaced)),
          ),
          throwsA(isA<InvalidProviderResponse>()),
        );
        expect(
          (await database.select(database.gtfsFeedCaches).getSingle()).archive,
          _feed(),
        );
      }
    },
  );

  test(
    'only the last departing consumer aborts a shared feed transfer',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final store = PersistentGtfsStore(database: database);
      final started = Completer<TransitCancellation>();
      final gate = Completer<Uint8List>();
      var downloads = 0;
      Future<Uint8List> fetch(TransitCancellation token) {
        downloads++;
        started.complete(token);
        return token.wait(gate.future);
      }

      final one = TransitCancellation();
      final two = TransitCancellation();
      final first = store.load(
        source: 'shared',
        fetchCancellable: fetch,
        cancellation: one,
      );
      final firstCancelled = expectLater(
        first,
        throwsA(isA<TransitOperationCancelled>()),
      );
      final transfer = await started.future;
      final second = store.load(
        source: 'shared',
        fetchCancellable: fetch,
        cancellation: two,
      );
      final secondCancelled = expectLater(
        second,
        throwsA(isA<TransitOperationCancelled>()),
      );
      one.cancel();
      await firstCancelled;
      expect(transfer.isCancelled, isFalse);
      two.cancel();
      await secondCancelled;
      expect(transfer.isCancelled, isTrue);
      expect(downloads, 1);
      gate.complete(_feed());
      await Future<void>.delayed(Duration.zero);
      expect(await database.select(database.gtfsFeedCaches).get(), isEmpty);
      final retry = await store.load(
        source: 'shared',
        fetch: () async => _feed(),
      );
      expect(retry.stops, hasLength(2));
    },
  );

  test(
    'version ten migration retains feed bytes and adds mode metadata',
    () async {
      final directory = Directory.systemTemp.createTempSync(
        'gtfs-modes-migrate',
      );
      final file = File('${directory.path}/cache.sqlite');
      var database = db.AppDatabase.connect(NativeDatabase(file));
      await PersistentGtfsStore(database: database)
          .load(source: 'old', fetch: () async => _feed());
      await database.customStatement(
        'ALTER TABLE gtfs_feed_caches DROP COLUMN stop_modes',
      );
      await database.customStatement('PRAGMA user_version = 10');
      await database.close();
      database = db.AppDatabase.connect(NativeDatabase(file));
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });
      final saved = await database.select(database.gtfsFeedCaches).getSingle();
      expect(saved.archive, _feed());
      expect(saved.stopModes, '{}');
      await database.insertStopsForEndpoint([
        db.StopsCompanion.insert(
          endpoint: 'old',
          stopId: 'A',
          stopName: 'Alpha',
        ),
      ], 'old');
      final services = buildPublicGtfsRegionServices(
        config: const PublicGtfsProviderConfig(
          region: TransitRegion.tasmania,
          provider: TransitProviderId.tasmaniaPublicTransport,
          attributionName: 'Test',
          attributionUrl: 'https://example.com',
          feeds: [
            PublicGtfsFeedConfig(
              sourceId: TransitSourceId('old'),
              label: 'Old',
              url: 'https://example.com/old',
            ),
          ],
        ),
        database: database,
        fetcher: (_) async =>
            throw StateError('Mode migration must not download'),
      );
      final stop = (await services.stops.searchStops(
        const StopSearchRequest(query: 'Alpha'),
      )).single;
      expect(stop.modes, {TransportMode.bus});
      expect(
        (await database.select(database.gtfsFeedCaches).getSingle()).fetchedAt,
        saved.fetchedAt,
      );
    },
  );

  test(
    'version nine migration preserves journeys and creates feed storage',
    () async {
      final directory = Directory.systemTemp.createTempSync('gtfs-migrate');
      final file = File('${directory.path}/cache.sqlite');
      var database = db.AppDatabase.connect(NativeDatabase(file));
      await database.insertJourney(
        db.JourneysCompanion.insert(
          origin: 'A',
          originId: 'A',
          destination: 'B',
          destinationId: 'B',
        ),
      );
      await database.customStatement('DROP TABLE gtfs_feed_caches');
      await database.customStatement('PRAGMA user_version = 9');
      await database.close();
      database = db.AppDatabase.connect(NativeDatabase(file));
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });
      expect((await database.getAllJourneys()).single.origin, 'A');
      expect(await database.select(database.gtfsFeedCaches).get(), isEmpty);
    },
  );
}
