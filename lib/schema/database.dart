import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:lbww_flutter/models/manual_trip_models.dart';

part 'tables/journeys.dart';
part 'tables/routes.dart';
part 'tables/static_cache_statuses.dart';
part 'tables/stop_line_memberships.dart';
part 'tables/stops.dart';
part 'tables/trip_planner_cache.dart';

part 'database.g.dart';

abstract class SafeTable extends Table {
  TextColumn _fallbackTextColumn({
    required bool nullable,
    String? defaultValue,
  }) {
    return GeneratedColumn<String>(
      '_fallback_text_${nullable ? 'nullable' : 'required'}',
      '_fallback_table',
      nullable,
      type: DriftSqlType.string,
      requiredDuringInsert: defaultValue == null && !nullable,
      defaultValue: defaultValue == null ? null : Constant(defaultValue),
    );
  }

  IntColumn _fallbackIntColumn({
    required bool nullable,
    required bool autoIncrement,
  }) {
    return GeneratedColumn<int>(
      autoIncrement ? '_fallback_int_autoincrement' : '_fallback_int',
      '_fallback_table',
      nullable,
      type: DriftSqlType.int,
      requiredDuringInsert: !nullable && !autoIncrement,
      hasAutoIncrement: autoIncrement,
      defaultConstraints: autoIncrement
          ? GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT')
          : null,
    );
  }

  RealColumn _fallbackRealColumn({required bool nullable}) {
    return GeneratedColumn<double>(
      '_fallback_real_${nullable ? 'nullable' : 'required'}',
      '_fallback_table',
      nullable,
      type: DriftSqlType.double,
      requiredDuringInsert: !nullable,
    );
  }

  BoolColumn _fallbackBoolColumn({bool? defaultValue}) {
    return GeneratedColumn<bool>(
      '_fallback_bool',
      '_fallback_table',
      false,
      type: DriftSqlType.bool,
      requiredDuringInsert: defaultValue == null,
      defaultValue: defaultValue == null ? null : Constant(defaultValue),
    );
  }

  DateTimeColumn _fallbackDateTimeColumn({required bool nullable}) {
    return GeneratedColumn<DateTime>(
      '_fallback_datetime_${nullable ? 'nullable' : 'required'}',
      '_fallback_table',
      nullable,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: !nullable,
    );
  }

  TextColumn safeTextColumn({bool nullable = false, String? defaultValue}) {
    try {
      if (defaultValue != null) {
        return text().withDefault(Constant(defaultValue))();
      }
      if (nullable) {
        return text().nullable()();
      }
      return text()();
    } catch (_) {
      return _fallbackTextColumn(
        nullable: nullable,
        defaultValue: defaultValue,
      );
    }
  }

  IntColumn safeIntColumn({bool nullable = false, bool autoIncrement = false}) {
    try {
      if (autoIncrement) {
        return integer().autoIncrement()();
      }
      if (nullable) {
        return integer().nullable()();
      }
      return integer()();
    } catch (_) {
      return _fallbackIntColumn(
        nullable: nullable,
        autoIncrement: autoIncrement,
      );
    }
  }

  RealColumn safeRealColumn({bool nullable = false}) {
    try {
      if (nullable) {
        return real().nullable()();
      }
      return real()();
    } catch (_) {
      return _fallbackRealColumn(nullable: nullable);
    }
  }

  BoolColumn safeBoolColumn({bool? defaultValue}) {
    try {
      if (defaultValue != null) {
        return boolean().withDefault(Constant(defaultValue))();
      }
      return boolean()();
    } catch (_) {
      return _fallbackBoolColumn(defaultValue: defaultValue);
    }
  }

  DateTimeColumn safeDateTimeColumn({bool nullable = false}) {
    try {
      if (nullable) {
        return dateTime().nullable()();
      }
      return dateTime()();
    } catch (_) {
      return _fallbackDateTimeColumn(nullable: nullable);
    }
  }
}

@DriftDatabase(
  tables: [
    Journeys,
    Routes,
    Stops,
    StopLineMemberships,
    StaticCacheStatuses,
    TripPlannerCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static AppDatabase? _instance;

  // Single QueryExecutor reused across the app to avoid multiple database
  // instances. Uses drift_flutter which picks the right backend per platform
  // (NativeDatabase on mobile/desktop, IndexedDB on web).
  static final QueryExecutor _sharedExecutor = driftDatabase(
    name: 'trip_database',
  );

  AppDatabase._internal() : super(_sharedExecutor);

  factory AppDatabase() => _instance ??= AppDatabase._internal();

  /// Create an AppDatabase backed by the provided [QueryExecutor].
  /// Useful for tests where an in-memory or temporary file database is required.
  AppDatabase.connect(super.executor);

  Future<void> _createAllSafe(Migrator migrator) async {
    try {
      await migrator.createAll();
    } catch (_) {}
  }

  T? _readValueOrNull<T extends Object>(
    TypedResult row,
    Expression<T> expression,
  ) {
    try {
      return row.read(expression);
    } catch (_) {
      return null;
    }
  }

  Future<List<T>> _getSafe<T>(Selectable<T> query) async {
    try {
      return await query.get();
    } catch (_) {
      return <T>[];
    }
  }

  Future<T?> _insertSafe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }

  Future<void> _transactionSafe(Future<void> Function() action) async {
    try {
      await transaction(action);
    } catch (_) {}
  }

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await _createAllSafe(m);
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Add new stop columns introduced in schemaVersion 4. Drift will
      // skip columns that already exist when upgrading.
      if (from < 4) {
        await m.addColumn(stops, stops.stopCode);
        await m.addColumn(stops, stops.ttsStopName);
        await m.addColumn(stops, stops.stopDesc);
        await m.addColumn(stops, stops.zoneId);
        await m.addColumn(stops, stops.stopUrl);
        await m.addColumn(stops, stops.stopTimezone);
        await m.addColumn(stops, stops.levelId);
      }

      if (from < 5) {
        await m.addColumn(journeys, journeys.tripType);
        await m.addColumn(journeys, journeys.mode);
        await m.addColumn(journeys, journeys.lineId);
        await m.addColumn(journeys, journeys.lineName);
        await m.addColumn(journeys, journeys.legsJson);
        await customStatement(
          "UPDATE journeys SET trip_type = '${SavedTripType.direct.storageValue}' WHERE trip_type IS NULL OR trip_type = ''",
        );
      }

      if (from < 6) {
        await m.createTable(stopLineMemberships);
      }

      if (from < 7) {
        await m.createTable(staticCacheStatuses);
        await m.createTable(tripPlannerCache);
      }

      if (from < 8) {
        await m.createTable(routes);
      }
    },
  );

  // Journey operations
  Future<int> insertJourney(JourneysCompanion journey) =>
      into(journeys).insert(journey);

  Future<List<Journey>> getAllJourneys() => select(journeys).get();

  Future<List<Journey>> getPinnedJourneys() =>
      (select(journeys)..where((tbl) => tbl.isPinned.equals(true))).get();

  Future<List<Journey>> getUnpinnedJourneys() =>
      (select(journeys)..where((tbl) => tbl.isPinned.equals(false))).get();

  Future<int> toggleJourneyPin(int id, bool isPinned) =>
      (update(journeys)..where((tbl) => tbl.id.equals(id))).write(
        JourneysCompanion(isPinned: Value(isPinned)),
      );

  Future<int> deleteJourney(int id) =>
      (delete(journeys)..where((tbl) => tbl.id.equals(id))).go();

  // Stop operations
  Future<int> insertStop(StopsCompanion stop) =>
      into(stops).insert(stop, mode: InsertMode.replace);

  Future<List<Stop>> getAllStopsForEndpoint(String endpoint) =>
      (select(stops)
            ..where((tbl) => tbl.endpoint.equals(endpoint))
            ..orderBy([(t) => OrderingTerm(expression: t.stopName)]))
          .get();

  Future<List<Stop>> getAllStops({int? limit}) {
    final query = select(stops)
      ..orderBy([(t) => OrderingTerm(expression: t.stopName)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<Stop>> searchStops(String query, {int limit = 50}) =>
      (select(stops)
            ..where((tbl) => tbl.stopName.like('%$query%'))
            ..orderBy([(t) => OrderingTerm(expression: t.stopName)])
            ..limit(limit))
          .get();

  /// Get all stop rows matching the provided stopId across endpoints
  Future<List<Stop>> getStopsById(String stopId) =>
      (select(stops)..where((tbl) => tbl.stopId.equals(stopId))).get();

  Future<int> deleteStopsForEndpoint(String endpoint) =>
      (delete(stops)..where((tbl) => tbl.endpoint.equals(endpoint))).go();

  Future<int> getTotalStopsCount() async {
    final countExp = stops.stopId.count();
    final query = selectOnly(stops)..addColumns([countExp]);
    final result = await query.getSingle();
    return _readValueOrNull(result, countExp) ?? 0;
  }

  Future<Map<String, int>> getStopsCountByEndpoint() async {
    final countExp = stops.stopId.count();
    final query = selectOnly(stops)
      ..addColumns([stops.endpoint, countExp])
      ..groupBy([stops.endpoint])
      ..orderBy([OrderingTerm(expression: stops.endpoint)]);

    final results = await _getSafe(query);
    return Map.fromEntries(
      results.expand((row) {
        final endpoint = _readValueOrNull(row, stops.endpoint);
        if (endpoint == null) return const <MapEntry<String, int>>[];
        return [MapEntry(endpoint, _readValueOrNull(row, countExp) ?? 0)];
      }),
    );
  }

  Future<void> replaceStopLineMembershipsForEndpoint(
    String endpoint,
    List<StopLineMembershipsCompanion> memberships,
  ) async {
    await _transactionSafe(() async {
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
    });
  }

  Future<void> markStaticCacheBuildStarted(String endpoint) {
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
  }

  Future<void> markStaticCacheBuildFinished(
    String endpoint, {
    required bool stopsUpdated,
    required bool lineMembershipsUpdated,
    String? error,
  }) {
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
  }

  Future<StaticCacheStatuse?> getStaticCacheStatus(String endpoint) {
    return (select(
      staticCacheStatuses,
    )..where((tbl) => tbl.endpoint.equals(endpoint))).getSingleOrNull();
  }

  Future<List<StaticCacheStatuse>> getAllStaticCacheStatuses() {
    return (select(
      staticCacheStatuses,
    )..orderBy([(tbl) => OrderingTerm(expression: tbl.endpoint)])).get();
  }

  Future<void> upsertTripPlannerCache({
    required String originId,
    required String destinationId,
    required DateTime fetchedAt,
    String? responseJson,
    String? error,
  }) {
    return into(tripPlannerCache).insertOnConflictUpdate(
      TripPlannerCacheCompanion.insert(
        originId: originId,
        destinationId: destinationId,
        fetchedAt: fetchedAt,
        responseJson: Value(responseJson),
        error: Value(error),
      ),
    );
  }

  Future<void> markTripPlannerCacheError({
    required String originId,
    required String destinationId,
    required DateTime fetchedAt,
    required String error,
  }) async {
    final existing = await getTripPlannerCache(originId, destinationId);
    if (existing == null) {
      await _insertSafe(() {
        return into(tripPlannerCache).insert(
          TripPlannerCacheCompanion.insert(
            originId: originId,
            destinationId: destinationId,
            fetchedAt: fetchedAt,
            error: Value(error),
          ),
        );
      });
      return;
    }
    await (update(tripPlannerCache)
          ..where((tbl) => tbl.originId.equals(originId))
          ..where((tbl) => tbl.destinationId.equals(destinationId)))
        .write(
          TripPlannerCacheCompanion(
            fetchedAt: Value(fetchedAt),
            error: Value(error),
          ),
        );
  }

  Future<TripPlannerCacheData?> getTripPlannerCache(
    String originId,
    String destinationId,
  ) {
    return (select(tripPlannerCache)
          ..where((tbl) => tbl.originId.equals(originId))
          ..where((tbl) => tbl.destinationId.equals(destinationId)))
        .getSingleOrNull();
  }

  Future<int> deleteTripPlannerCache(String originId, String destinationId) {
    return (delete(tripPlannerCache)
          ..where((tbl) => tbl.originId.equals(originId))
          ..where((tbl) => tbl.destinationId.equals(destinationId)))
        .go();
  }

  Future<void> replaceRoutesForEndpoint(
    String endpoint,
    List<RoutesCompanion> routeRows,
  ) async {
    await _transactionSafe(() async {
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

  Future<List<Route>> getAllRoutes() {
    return (select(routes)..orderBy([
          (tbl) => OrderingTerm(expression: tbl.routeShortName),
          (tbl) => OrderingTerm(expression: tbl.routeLongName),
          (tbl) => OrderingTerm(expression: tbl.routeId),
        ]))
        .get();
  }

  Future<List<Route>> getRoutesForEndpoint(String endpoint) {
    return (select(routes)
          ..where((tbl) => tbl.endpoint.equals(endpoint))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.routeShortName),
            (tbl) => OrderingTerm(expression: tbl.routeLongName),
            (tbl) => OrderingTerm(expression: tbl.routeId),
          ]))
        .get();
  }

  Future<Route?> getRouteByLineId(String lineId) {
    return (select(
      routes,
    )..where((tbl) => tbl.lineId.equals(lineId))).getSingleOrNull();
  }

  Future<List<StopLineMembership>> getStopLineMembershipsForStop(
    String stopId,
  ) {
    return (select(stopLineMemberships)
          ..where((tbl) => tbl.stopId.equals(stopId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.lineName)]))
        .get();
  }

  Future<List<StopLineMembership>> getStopLineMembershipsForLine(
    String lineId,
  ) {
    return (select(stopLineMemberships)
          ..where((tbl) => tbl.lineId.equals(lineId))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.stopOrder),
            (tbl) => OrderingTerm(expression: tbl.stopName),
          ]))
        .get();
  }

  Future<int> getStopLineMembershipCountForEndpoint(String endpoint) async {
    final countExp = stopLineMemberships.stopId.count();
    final query = selectOnly(stopLineMemberships)
      ..addColumns([countExp])
      ..where(stopLineMemberships.endpoint.equals(endpoint));
    final result = await query.getSingle();
    return _readValueOrNull(result, countExp) ?? 0;
  }

  // Batch insert stops with transaction
  Future<void> insertStopsForEndpoint(
    List<StopsCompanion> stopsList,
    String endpoint,
  ) async {
    await _transactionSafe(() async {
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

  // No extra connection helpers are exposed; use the AppDatabase() singleton.

  /// Close, delete and recreate the underlying database file.
  ///
  /// This is intended for development/testing only. It will close the current
  /// instance (if any), delete the database file from the application's
  /// documents directory and create a fresh DB instance.
  static Future<void> resetDatabase() async {
    // Close existing instance if open
    try {
      await _instance?.close();
    } catch (_) {
      // ignore errors during close
    }

    _instance = null;

    // Create a fresh instance backed by a new executor.
    _instance = AppDatabase.connect(driftDatabase(name: 'trip_database'));
  }
}

/* LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/trip_database.db');
    return NativeDatabase(file);
  });
}
 */
