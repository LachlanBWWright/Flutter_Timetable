import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/gtfs/public_gtfs_transit_adapter.dart';
import 'package:lbww_flutter/transit/gtfs/static_backed_stop_repository.dart';
import 'package:lbww_flutter/transit/transit.dart';

class _Import implements StaticGtfsRepository {
  _Import(this.run);
  final Future<String?> Function(TransitSourceId) run;
  @override
  Stream<StaticImportProgress> refreshStaticData(
    StaticImportRequest request,
  ) async* {
    final source = request.sourceIds!.single;
    final error = await run(source);
    yield StaticImportProgress(
      sourceId: source,
      completed: error == null ? 1 : 0,
      total: 1,
      message: 'Import',
      error: error,
    );
  }
}

class _LiveStop implements StopRepository {
  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async =>
      TransitStop(ref: stop, name: 'Live stop');
  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async =>
      const [];
}

void main() {
  const source = TransitSourceId('test:static');
  const config = PublicGtfsProviderConfig(
    region: TransitRegion.tasmania,
    provider: TransitProviderId.tasmaniaPublicTransport,
    attributionName: 'Test',
    attributionUrl: 'https://example.com',
    feeds: [
      PublicGtfsFeedConfig(
        sourceId: source,
        label: 'Test',
        url: 'https://example.com/gtfs.zip',
      ),
    ],
  );
  late db.AppDatabase database;
  setUp(() => database = db.AppDatabase.connect(NativeDatabase.memory()));
  tearDown(() => database.close());
  test(
    'live source lookups remain available without importing static data',
    () async {
      final stops = StaticBackedStopRepository(
        region: config.region,
        provider: config.provider,
        sources: [source],
        cachedStops: _LiveStop(),
        staticData: _Import(
          (_) async => throw StateError('Unexpected download'),
        ),
        database: database,
      );
      final found = await stops.getStop(
        const TransitStopRef(
          region: TransitRegion.tasmania,
          provider: TransitProviderId.tasmaniaPublicTransport,
          sourceId: TransitSourceId('live'),
          stopId: 'remote',
        ),
      );
      expect(found?.name, 'Live stop');
    },
  );
  Future<void> publish() => database
      .insertStop(
        db.StopsCompanion.insert(
          endpoint: source.value,
          stopId: '1',
          stopName: 'Central',
        ),
      )
      .then((_) {});
  StaticBackedStopRepository repository(StaticGtfsRepository importer) =>
      StaticBackedStopRepository(
        region: config.region,
        provider: config.provider,
        sources: [source],
        cachedStops: PublicGtfsStopRepository(
          config: config,
          database: database,
        ),
        staticData: importer,
        database: database,
      );

  test('concurrent empty-cache searches share an import and then reuse cached data', () async {
    var downloads = 0;
    final gate = Completer<void>();
    final started = Completer<void>();
    final stops = repository(
      _Import((_) async {
        downloads++;
        started.complete();
        await gate.future;
        await publish();
        return null;
      }),
    );
    final first = stops.searchStops(const StopSearchRequest(query: 'Central'));
    final second = stops.searchStops(const StopSearchRequest(query: 'Central'));
    await started.future;
    gate.complete();
    for (final result in await Future.wait([first, second])) {
      expect(result.single.name, 'Central');
    }
    expect(downloads, 1);
    expect(
      await stops.searchStops(const StopSearchRequest(query: 'unknown')),
      isEmpty,
    );
    expect(downloads, 1);
    await database.delete(database.stops).go();
    // Readiness comes from the DB, so resets must not leave an in-memory
    // "already initialized" flag that suppresses the next download.
  });

  test(
    'failed imports are visible and retryable; database resets fetch again',
    () async {
      var downloads = 0;
      final stops = repository(
        _Import((_) async {
          downloads++;
          if (downloads == 1) return 'Offline';
          await publish();
          return null;
        }),
      );
      await expectLater(
        stops.searchStops(const StopSearchRequest(query: 'Central')),
        throwsA(isA<ProviderUnavailable>()),
      );
      expect(
        (await stops.searchStops(const StopSearchRequest(query: 'Central')))
            .single
            .name,
        'Central',
      );
      await database.delete(database.stops).go();
      expect(
        (await stops.searchStops(const StopSearchRequest(query: 'Central')))
            .single
            .name,
        'Central',
      );
      expect(downloads, 3);
    },
  );

  test('lookup initializes only its source and rejects foreign or blank requests without downloading', () async {
    var downloads = 0;
    final stops = repository(
      _Import((selected) async {
        expect(selected, source);
        downloads++;
        await publish();
        return null;
      }),
    );
    expect(
      await stops.searchStops(const StopSearchRequest(query: ' ')),
      isEmpty,
    );
    expect(
      await stops.searchStops(
        const StopSearchRequest(query: 'Central', limit: 0),
      ),
      isEmpty,
    );
    expect(
      await stops.getStop(
        const TransitStopRef(
          region: TransitRegion.nsw,
          provider: TransitProviderId.tfnsw,
          sourceId: source,
          stopId: '1',
        ),
      ),
      isNull,
    );
    expect(downloads, 0);
    final found = await stops.getStop(
      const TransitStopRef(
        region: TransitRegion.tasmania,
        provider: TransitProviderId.tasmaniaPublicTransport,
        sourceId: source,
        stopId: '1',
      ),
    );
    expect(found?.name, 'Central');
    expect(downloads, 1);
  });
}
