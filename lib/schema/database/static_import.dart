part of '../database.dart';

mixin _StaticImportQueries on _$AppDatabase, _DatabaseOperations {
  /// Publish a prepared feed as one snapshot. Any SQL failure rolls back all
  /// tables and the successful-build timestamps together.
  Future<void> replaceStaticDataForEndpoint({
    required String endpoint,
    required List<StopsCompanion> stopRows,
    required List<RoutesCompanion> routeRows,
    required List<StopLineMembershipsCompanion> memberships,
  }) async {
    if (endpoint.isEmpty ||
        stopRows.isEmpty ||
        routeRows.isEmpty ||
        memberships.isEmpty) {
      throw ArgumentError('A complete static feed is required for $endpoint');
    }
    if (stopRows.any((row) => row.endpoint.value != endpoint) ||
        routeRows.any((row) => row.endpoint.value != endpoint) ||
        memberships.any((row) => row.endpoint.value != endpoint)) {
      throw ArgumentError('Static feed rows must belong to $endpoint');
    }
    await _runDatabaseTransaction('replaceStaticDataForEndpoint', () async {
      await (delete(stops)..where((row) => row.endpoint.equals(endpoint))).go();
      await (delete(
        routes,
      )..where((row) => row.endpoint.equals(endpoint))).go();
      await (delete(
        stopLineMemberships,
      )..where((row) => row.endpoint.equals(endpoint))).go();
      await batch((batch) {
        batch.insertAll(stops, stopRows);
        batch.insertAll(routes, routeRows);
        batch.insertAll(stopLineMemberships, memberships);
      });
      final now = DateTime.now();
      await into(staticCacheStatuses).insertOnConflictUpdate(
        StaticCacheStatusesCompanion.insert(
          endpoint: endpoint,
          stopsUpdatedAt: Value(now),
          lineMembershipsUpdatedAt: Value(now),
          lastBuildFinishedAt: Value(now),
          lastError: const Value(null),
          isBuilding: const Value(false),
        ),
      );
    });
  }
}
