import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/gtfs/public_gtfs_transit_adapter.dart';
import 'package:lbww_flutter/transit/gtfs/static_backed_stop_repository.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/widgets/stops/stops_search_repository.dart';

const a = TransitSourceId('test:a');
const b = TransitSourceId('test:b');
const config = PublicGtfsProviderConfig(
  region: TransitRegion.tasmania,
  provider: TransitProviderId.tasmaniaPublicTransport,
  attributionName: 'Test',
  attributionUrl: 'https://example.com',
  feeds: [
    PublicGtfsFeedConfig(sourceId: a, label: 'A', url: 'https://example.com/a'),
    PublicGtfsFeedConfig(sourceId: b, label: 'B', url: 'https://example.com/b'),
  ],
);

class _Import implements StaticGtfsRepository {
  _Import(this.run);
  final Future<String?> Function(StaticImportRequest) run;
  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    yield StaticImportProgress(
      sourceId: request.sourceIds!.single,
      completed: 0,
      total: 1,
      message: 'Fetching',
    );
    final error = await run(request);
    yield StaticImportProgress(
      sourceId: request.sourceIds!.single,
      completed: error == null ? 1 : 0,
      total: 1,
      message: 'Done',
      error: error,
    );
  }
}

void main() {
  late db.AppDatabase database;
  setUp(() => database = db.AppDatabase.connect(NativeDatabase.memory()));
  tearDown(() => database.close());
  Future<void> save(TransitSourceId source, String name) async {
    await database.insertStopsForEndpoint([
      db.StopsCompanion.insert(
        endpoint: source.value,
        stopId: source.value,
        stopName: name,
      ),
    ], source.value);
  }

  StaticBackedStopRepository repository(_Import importer) =>
      StaticBackedStopRepository(
        region: config.region,
        provider: config.provider,
        sources: [a, b],
        cachedStops: PublicGtfsStopRepository(
          config: config,
          database: database,
        ),
        staticData: importer,
        database: database,
      );

  test('cached matches do not hide a missing source and are emitted before its download', () async {
    await save(a, 'Central A');
    final gate = Completer<void>();
    final started = Completer<void>();
    final updates = <StopSearchUpdate>[];
    final stops = repository(
      _Import((request) async {
        expect(request.sourceIds, [b]);
        started.complete();
        await gate.future;
        await save(b, 'Central B');
        return null;
      }),
    );
    final done = stops
        .watchStops(const StopSearchRequest(query: 'Central'))
        .listen(updates.add)
        .asFuture<void>();
    await started.future;
    expect(
      updates.any((update) => update.stops.length == 1 && update.isLoading),
      isTrue,
    );
    gate.complete();
    await done;
    expect(updates.last.stops.map((stop) => stop.name), [
      'Central A',
      'Central B',
    ]);
    expect(updates.last.isLoading, isFalse);
  });

  test(
    'stale refresh failure retains cached stops and exposes the failed source',
    () async {
      await save(a, 'Central A');
      await save(b, 'Central B');
      final old = DateTime.now().subtract(const Duration(days: 3));
      await (database.update(database.staticCacheStatuses)
            ..where((row) => row.endpoint.equals(a.value)))
          .write(db.StaticCacheStatusesCompanion(stopsUpdatedAt: Value(old)));
      final stops = repository(
        _Import((request) async {
          expect(request.force, isTrue);
          expect(request.sourceIds, [a]);
          return 'Offline';
        }),
      );
      final updates = await stops
          .watchStops(const StopSearchRequest(query: 'Central'))
          .toList();
      expect(updates.first.stops, hasLength(2));
      expect(updates.last.errors, contains(a.value));
      expect(updates.last.stops, hasLength(2));
      expect(
        (await database.getStaticCacheStatus(a.value))
            ?.stopsUpdatedAt
            ?.millisecondsSinceEpoch,
        closeTo(old.millisecondsSinceEpoch, 1000),
      );
    },
  );

  test(
    'cancelling closes the search promptly and skips remaining feed downloads',
    () async {
      final started = Completer<void>();
      final gate = Completer<void>();
      TransitCancellation? active;
      final downloads = <TransitSourceId>[];
      final stops = repository(
        _Import((request) async {
          downloads.add(request.sourceIds!.single);
          started.complete();
          active = request.cancellation;
          await active!.wait(gate.future);
          await save(a, 'Central A');
          return null;
        }),
      );
      final token = StopSearchCancellation();
      final done = stops
          .watchStops(StopSearchRequest(query: 'Central', cancellation: token))
          .drain<void>();
      await started.future;
      token.cancel();
      await done.timeout(const Duration(seconds: 1));
      gate.complete();
      expect(active!.isCancelled, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(downloads, [a]);
      expect(await database.getAllStopsForEndpoint(a.value), isEmpty);
    },
  );

  test('regional results arrive before a slower region and partial failures stay visible', () async {
    final slow = Completer<List<TransitStop>>();
    TransitRegionServices service(TransitRegion region, StopRepository stops) =>
        TransitRegionServices(
          region: region,
          provider: TransitProviderId.tfnsw,
          stops: stops,
          attribution: const TransitProviderAttribution(
            provider: TransitProviderId.tfnsw,
            name: 'Test',
            licenseName: 'Test',
            url: 'https://example.com',
          ),
        );
    final updates = <RegionalStopSearchSnapshot>[];
    final available = Completer<void>();
    final repository = RegionalStopsSearchRepository(
      enabledServices: () => [
        service(
          TransitRegion.nsw,
          _Stops(
            (_) async => [
              const TransitStop(
                ref: TransitStopRef(
                  region: TransitRegion.nsw,
                  provider: TransitProviderId.tfnsw,
                  sourceId: a,
                  stopId: 'A',
                ),
                name: 'Central',
              ),
            ],
          ),
        ),
        service(TransitRegion.victoria, _Stops((_) => slow.future)),
      ],
    );
    final done = repository.watchStops('Central').listen((snapshot) {
      updates.add(snapshot);
      if (snapshot.stops.isNotEmpty && !available.isCompleted) {
        available.complete();
      }
    }).asFuture<void>();
    await available.future;
    expect(updates.last.isLoading, isTrue);
    slow.completeError(const ProviderUnavailable(message: 'Offline'));
    await done;
    expect(updates.last.stops, hasLength(1));
    expect(updates.last.errors, contains(TransitRegion.victoria));
  });
  test('one cancelled consumer does not cancel a shared download needed by another', () async {
    final gate = Completer<void>();
    final started = Completer<void>();
    var downloads = 0;
    final stops = repository(
      _Import((_) async {
        downloads++;
        started.complete();
        await gate.future;
        await save(a, 'Central A');
        return null;
      }),
    );
    final cancelled = StopSearchCancellation();
    final first = stops
        .watchStops(
          StopSearchRequest(
            query: 'Central',
            sourceIds: [a],
            cancellation: cancelled,
          ),
        )
        .drain<void>();
    await started.future;
    final joined = Completer<void>();
    final updates = <StopSearchUpdate>[];
    final second = stops
        .watchStops(const StopSearchRequest(query: 'Central', sourceIds: [a]))
        .listen((update) {
          updates.add(update);
          if (!joined.isCompleted) joined.complete();
        })
        .asFuture<void>();
    await joined.future;
    cancelled.cancel();
    await first.timeout(const Duration(seconds: 1));
    gate.complete();
    await second;
    expect(downloads, 1);
    expect(updates.last.stops.single.name, 'Central A');
  });
}

class _Stops implements StopRepository {
  _Stops(this.search);
  final Future<List<TransitStop>> Function(StopSearchRequest) search;
  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) =>
      search(request);
  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async => null;
}
