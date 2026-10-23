part of '../database.dart';

mixin _StopQueries on _$AppDatabase, _DatabaseOperations {
  // Stop operations
  Future<int> insertStop(StopsCompanion stop) => _runDatabaseOperation(
    'insertStop',
    () => into(stops).insert(stop, mode: InsertMode.replace),
  );

  Future<List<Stop>> getAllStopsForEndpoint(String endpoint) =>
      _runDatabaseRead(
        'getAllStopsForEndpoint',
        () =>
            (select(stops)
                  ..where((tbl) => tbl.endpoint.equals(endpoint))
                  ..orderBy([(t) => OrderingTerm(expression: t.stopName)]))
                .get(),
      );

  Future<List<Stop>> getAllStopsForEndpoints(Iterable<String> endpoints) {
    final endpointList = endpoints.toSet().toList(growable: false);
    if (endpointList.isEmpty) return Future.value(const <Stop>[]);
    return _runDatabaseRead(
      'getAllStopsForEndpoints',
      () =>
          (select(stops)
                ..where((tbl) => tbl.endpoint.isIn(endpointList))
                ..orderBy([(tbl) => OrderingTerm(expression: tbl.stopName)]))
              .get(),
    );
  }

  Future<List<Stop>> getAllStops({int? limit}) async {
    final query = select(stops)
      ..orderBy([(t) => OrderingTerm(expression: t.stopName)]);
    if (limit != null) {
      query.limit(limit);
    }
    return _runDatabaseRead('getAllStops', () => query.get());
  }

  Future<List<Stop>> searchStops(
    String query, {
    int limit = 50,
    Iterable<String>? endpoints,
    String? endpointPrefix,
  }) {
    final endpointList = endpoints?.toSet().toList(growable: false);
    if (endpointList != null && endpointList.isEmpty) {
      return Future.value(const <Stop>[]);
    }

    final containsMatch = FunctionCallExpression<int>('instr', [
      stops.stopName.lower(),
      Variable.withString(query).lower(),
    ]).isBiggerThanValue(0);

    return _runDatabaseRead(
      'searchStops',
      () =>
          (select(stops)
                ..where((tbl) {
                  Expression<bool> condition = containsMatch;
                  if (endpointList != null) {
                    condition = condition & tbl.endpoint.isIn(endpointList);
                  }
                  if (endpointPrefix != null) {
                    condition =
                        condition & tbl.endpoint.like('$endpointPrefix%');
                  }
                  return condition;
                })
                ..orderBy([(tbl) => OrderingTerm(expression: tbl.stopName)])
                ..limit(limit))
              .get(),
    );
  }

  /// Get all stop rows matching the provided stopId across endpoints
  Future<List<Stop>> getStopsById(String stopId) => _runDatabaseRead(
    'getStopsById',
    () => (select(stops)..where((tbl) => tbl.stopId.equals(stopId))).get(),
  );

  Future<int> deleteStopsForEndpoint(String endpoint) => _runDatabaseOperation(
    'deleteStopsForEndpoint',
    () => (delete(stops)..where((tbl) => tbl.endpoint.equals(endpoint))).go(),
  );

  Future<int> getTotalStopsCount() async {
    final countExp = stops.stopId.count();
    final query = selectOnly(stops)..addColumns([countExp]);
    final result = await _runDatabaseRead(
      'getTotalStopsCount',
      () => query.getSingle(),
    );
    return result.read(countExp) ?? 0;
  }

  Future<Map<String, int>> getStopsCountByEndpoint() async {
    final countExp = stops.stopId.count();
    final query = selectOnly(stops)
      ..addColumns([stops.endpoint, countExp])
      ..groupBy([stops.endpoint])
      ..orderBy([OrderingTerm(expression: stops.endpoint)]);

    final results = await _runDatabaseRead(
      'getStopsCountByEndpoint',
      () => query.get(),
    );
    return Map.fromEntries(
      results.expand((row) {
        final endpoint = row.read(stops.endpoint);
        if (endpoint == null) return const <MapEntry<String, int>>[];
        return [MapEntry(endpoint, row.read(countExp) ?? 0)];
      }),
    );
  }

  Future<void> replaceStopLineMembershipsForEndpoint(
    String endpoint,
    List<StopLineMembershipsCompanion> memberships,
  ) async {
    await _runDatabaseTransaction(
      'replaceStopLineMembershipsForEndpoint',
      () async {
        await (delete(
          stopLineMemberships,
        )..where((tbl) => tbl.endpoint.equals(endpoint))).go();
        await batch((batch) {
          for (final membership in memberships) {
            batch.insert(
              stopLineMemberships,
              membership,
              mode: InsertMode.replace,
            );
          }
        });
      },
    );
  }

  Future<List<StopLineMembership>> getStopLineMembershipsForStop(
    String stopId,
  ) => _runDatabaseRead(
    'getStopLineMembershipsForStop',
    () =>
        (select(stopLineMemberships)
              ..where((tbl) => tbl.stopId.equals(stopId))
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.lineName)]))
            .get(),
  );

  Future<List<StopLineMembership>> getStopLineMembershipsForLine(
    String lineId,
  ) => _runDatabaseRead(
    'getStopLineMembershipsForLine',
    () =>
        (select(stopLineMemberships)
              ..where((tbl) => tbl.lineId.equals(lineId))
              ..orderBy([
                (tbl) => OrderingTerm(expression: tbl.stopOrder),
                (tbl) => OrderingTerm(expression: tbl.stopName),
              ]))
            .get(),
  );

  Future<int> getStopLineMembershipCountForEndpoint(String endpoint) async {
    final countExp = stopLineMemberships.stopId.count();
    final query = selectOnly(stopLineMemberships)
      ..addColumns([countExp])
      ..where(stopLineMemberships.endpoint.equals(endpoint));
    final result = await _runDatabaseRead(
      'getStopLineMembershipCountForEndpoint',
      () => query.getSingle(),
    );
    return result.read(countExp) ?? 0;
  }

  // Batch insert stops with transaction
  Future<void> insertStopsForEndpoint(
    List<StopsCompanion> stopsList,
    String endpoint,
  ) async {
    await _runDatabaseTransaction('insertStopsForEndpoint', () async {
      // Clear existing stops for this endpoint
      await deleteStopsForEndpoint(endpoint);

      // Insert new stops in batches
      await batch((batch) {
        for (final stop in stopsList) {
          batch.insert(stops, stop, mode: InsertMode.replace);
        }
      });
    });
  }
}
