part of '../database.dart';

mixin _CacheQueries on _$AppDatabase, _DatabaseOperations {
  Future<void> markStaticCacheBuildStarted(String endpoint) =>
      _runDatabaseOperation('markStaticCacheBuildStarted', () {
        final now = DateTime.now();
        return into(staticCacheStatuses).insert(
          StaticCacheStatusesCompanion.insert(
            endpoint: endpoint,
            lastBuildStartedAt: Value(now),
            lastError: const Value(null),
            isBuilding: const Value(true),
          ),
          onConflict: DoUpdate(
            (_) => StaticCacheStatusesCompanion(
              lastBuildStartedAt: Value(now),
              lastError: const Value(null),
              isBuilding: const Value(true),
            ),
          ),
        );
      });

  Future<void> markStaticCacheBuildFinished(
    String endpoint, {
    required bool stopsUpdated,
    required bool lineMembershipsUpdated,
    String? error,
  }) => _runDatabaseOperation('markStaticCacheBuildFinished', () {
    final now = DateTime.now();
    return into(staticCacheStatuses).insert(
      StaticCacheStatusesCompanion.insert(
        endpoint: endpoint,
        stopsUpdatedAt: stopsUpdated ? Value(now) : const Value.absent(),
        lineMembershipsUpdatedAt: lineMembershipsUpdated
            ? Value(now)
            : const Value.absent(),
        lastBuildFinishedAt: Value(now),
        lastError: Value(error),
        isBuilding: const Value(false),
      ),
      onConflict: DoUpdate(
        (_) => StaticCacheStatusesCompanion(
          stopsUpdatedAt: stopsUpdated ? Value(now) : const Value.absent(),
          lineMembershipsUpdatedAt: lineMembershipsUpdated
              ? Value(now)
              : const Value.absent(),
          lastBuildFinishedAt: Value(now),
          lastError: Value(error),
          isBuilding: const Value(false),
        ),
      ),
    );
  });

  Future<StaticCacheStatuse?> getStaticCacheStatus(String endpoint) =>
      _runDatabaseRead(
        'getStaticCacheStatus',
        () => (select(
          staticCacheStatuses,
        )..where((tbl) => tbl.endpoint.equals(endpoint))).getSingleOrNull(),
      );

  Future<List<StaticCacheStatuse>> getAllStaticCacheStatuses() =>
      _runDatabaseRead(
        'getAllStaticCacheStatuses',
        () => (select(
          staticCacheStatuses,
        )..orderBy([(tbl) => OrderingTerm(expression: tbl.endpoint)])).get(),
      );

  Future<void> upsertTripPlannerCache({
    required String originId,
    required String destinationId,
    required DateTime fetchedAt,
    String? responseJson,
    String? error,
  }) => _runDatabaseOperation(
    'upsertTripPlannerCache',
    () => into(tripPlannerCache).insertOnConflictUpdate(
      TripPlannerCacheCompanion.insert(
        originId: originId,
        destinationId: destinationId,
        fetchedAt: fetchedAt,
        responseJson: Value(responseJson),
        error: Value(error),
      ),
    ),
  );

  Future<void> markTripPlannerCacheError({
    required String originId,
    required String destinationId,
    required DateTime fetchedAt,
    required String error,
  }) => _runDatabaseOperation<void>(
    'markTripPlannerCacheError',
    () => into(tripPlannerCache).insert(
      TripPlannerCacheCompanion.insert(
        originId: originId,
        destinationId: destinationId,
        fetchedAt: fetchedAt,
        error: Value(error),
      ),
      // Updating only the error makes the success timestamp and payload atomic
      // with respect to concurrent successful imports and failed refreshes.
      onConflict: DoUpdate(
        (_) => TripPlannerCacheCompanion(error: Value(error)),
      ),
    ),
  );

  Future<TripPlannerCacheData?> getTripPlannerCache(
    String originId,
    String destinationId,
  ) => _runDatabaseRead(
    'getTripPlannerCache',
    () =>
        (select(tripPlannerCache)
              ..where((tbl) => tbl.originId.equals(originId))
              ..where((tbl) => tbl.destinationId.equals(destinationId)))
            .getSingleOrNull(),
  );

  Future<int> deleteTripPlannerCache(String originId, String destinationId) =>
      _runDatabaseOperation(
        'deleteTripPlannerCache',
        () =>
            (delete(tripPlannerCache)
                  ..where((tbl) => tbl.originId.equals(originId))
                  ..where((tbl) => tbl.destinationId.equals(destinationId)))
                .go(),
      );

  /// Deletes expired cache rows and caps retained rows by most recent fetch.
  Future<void> pruneTripPlannerCache({
    required DateTime olderThan,
    required int maxEntries,
  }) => _runDatabaseOperation('pruneTripPlannerCache', () async {
    if (maxEntries < 1) {
      throw ArgumentError.value(maxEntries, 'maxEntries', 'must be positive');
    }
    await transaction(() async {
      await (delete(
        tripPlannerCache,
      )..where((tbl) => tbl.responseJson.isNull())).go();
      await (delete(
        tripPlannerCache,
      )..where((tbl) => tbl.fetchedAt.isSmallerThanValue(olderThan))).go();
      await customUpdate(
        'DELETE FROM "trip_planner_cache" '
        'WHERE rowid NOT IN ('
        'SELECT rowid FROM "trip_planner_cache" '
        'ORDER BY "fetched_at" DESC, rowid DESC LIMIT ?)',
        variables: [Variable.withInt(maxEntries)],
        updates: {tripPlannerCache},
      );
    });
  });

  Future<int> deleteAllTripPlannerCache() => _runDatabaseOperation(
    'deleteAllTripPlannerCache',
    () => delete(tripPlannerCache).go(),
  );
}
