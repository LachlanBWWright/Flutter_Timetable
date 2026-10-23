import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:option_result/option_result.dart';

void main() {
  final now = DateTime.utc(2026, 10, 13);
  GetTripsResponse response(String version) => GetTripsResponse(
    tripJourneys: const [],
    systemMessages: const SystemMessages(),
    version: version,
    rawJson: const {},
  );

  test(
    'invalidation orders a blocked old write, delete, and replacement',
    () async {
      TripCacheEntry? persisted;
      final writeStarted = Completer<void>();
      final releaseWrite = Completer<void>();
      final operations = <String>[];
      var fetches = 0;
      final repo = TripCacheRepository(
        clock: () => now,
        readCache: (o, d) async => persisted,
        fetchTrips: (o, d) async => Ok(response('${++fetches}')),
        writeCache: (o, d, entry) async {
          operations.add('write${entry.response.version}');
          if (entry.response.version == '1') {
            writeStarted.complete();
            await releaseWrite.future;
          }
          persisted = entry;
        },
        markError: (o, d, e) async {},
        deleteCache: (o, d) async {
          operations.add('delete');
          persisted = null;
        },
        deleteAll: () async {},
      );
      final old = repo.getSnapshotOrFetch(originId: 'o', destinationId: 'd');
      await writeStarted.future;
      repo.invalidate('o', 'd');
      final replacement = repo.getSnapshotOrFetch(
        originId: 'o',
        destinationId: 'd',
      );
      releaseWrite.complete();
      await old;
      await replacement;
      expect(operations, ['write1', 'delete', 'write2']);
      expect(persisted!.response.version, '2');
    },
  );

  test(
    'an obsolete network result cannot repopulate invalidated storage',
    () async {
      final fetchStarted = Completer<void>();
      final releaseFetch = Completer<Result<GetTripsResponse, String>>();
      final operations = <String>[];
      final repo = TripCacheRepository(
        clock: () => now,
        readCache: (o, d) async => null,
        fetchTrips: (o, d) {
          fetchStarted.complete();
          return releaseFetch.future;
        },
        writeCache: (o, d, entry) async {
          operations.add('write');
        },
        markError: (o, d, e) async {
          operations.add('error');
        },
        deleteCache: (o, d) async {
          operations.add('delete');
        },
        deleteAll: () async {},
      );
      final pending = repo.getSnapshotOrFetch(
        originId: 'o',
        destinationId: 'd',
      );
      await fetchStarted.future;
      repo.invalidate('o', 'd');
      releaseFetch.complete(Ok(response('obsolete')));
      await pending;
      expect(operations, ['delete']);
      expect(repo.isCached('o', 'd'), isFalse);
    },
  );
}
