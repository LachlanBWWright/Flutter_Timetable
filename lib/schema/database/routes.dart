part of '../database.dart';

mixin _RouteQueries on _$AppDatabase, _DatabaseOperations {
  Future<void> replaceRoutesForEndpoint(
    String endpoint,
    List<RoutesCompanion> routeRows,
  ) async {
    await _runDatabaseTransaction('replaceRoutesForEndpoint', () async {
      await (delete(
        routes,
      )..where((tbl) => tbl.endpoint.equals(endpoint))).go();
      await batch((batch) {
        for (final route in routeRows) {
          batch.insert(routes, route, mode: InsertMode.replace);
        }
      });
    });
  }

  Future<List<Route>> getAllRoutes() => _runDatabaseRead(
    'getAllRoutes',
    () =>
        (select(routes)..orderBy([
              (tbl) => OrderingTerm(expression: tbl.routeShortName),
              (tbl) => OrderingTerm(expression: tbl.routeLongName),
              (tbl) => OrderingTerm(expression: tbl.routeId),
            ]))
            .get(),
  );

  Future<List<Route>> getRoutesForEndpoint(String endpoint) => _runDatabaseRead(
    'getRoutesForEndpoint',
    () =>
        (select(routes)
              ..where((tbl) => tbl.endpoint.equals(endpoint))
              ..orderBy([
                (tbl) => OrderingTerm(expression: tbl.routeShortName),
                (tbl) => OrderingTerm(expression: tbl.routeLongName),
                (tbl) => OrderingTerm(expression: tbl.routeId),
              ]))
            .get(),
  );

  Future<Route?> getRouteByLineId(String lineId) => _runDatabaseRead(
    'getRouteByLineId',
    () => (select(
      routes,
    )..where((tbl) => tbl.lineId.equals(lineId))).getSingleOrNull(),
  );
}
