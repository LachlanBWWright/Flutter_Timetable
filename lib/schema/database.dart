import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';

import 'database_errors.dart';

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
  bool _isClosed = false;

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

  @override
  Future<void> close() async {
    _isClosed = true;
    await super.close();
  }

  Future<void> _createAllSafe(Migrator migrator) async {
    await _runDatabaseOperation<void>(
      'create_all_tables',
      () async => migrator.createAll(),
    );
  }

  Future<T> _runDatabaseOperation<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    if (_isClosed) {
      final error = StateError('Database is closed.');
      final stackTrace = StackTrace.current;
      safeLogError(
        'Database operation failed during $operation',
        error: error,
        stackTrace: stackTrace,
      );
      throw DatabaseOperationFailure(
        operation: operation,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    try {
      return await action();
    } catch (error, stackTrace) {
      safeLogError(
        'Database operation failed during $operation',
        error: error,
        stackTrace: stackTrace,
      );
      throw DatabaseOperationFailure(
        operation: operation,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<T> _runDatabaseRead<T>(
    String operation,
    Future<T> Function() action,
  ) => _runDatabaseOperation(operation, action);

  Future<void> _runDatabaseTransaction(
    String operation,
    Future<void> Function() action,
  ) => _runDatabaseOperation(operation, () async {
    await transaction(action);
  });

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
  Future<int> insertJourney(JourneysCompanion journey) => _runDatabaseOperation(
    'insertJourney',
    () => into(journeys).insert(journey),
  );

  Future<List<Journey>> getAllJourneys() =>
      _runDatabaseRead('getAllJourneys', () => select(journeys).get());

  Future<List<Journey>> getPinnedJourneys() => _runDatabaseRead(
    'getPinnedJourneys',
    () => (select(journeys)..where((tbl) => tbl.isPinned.equals(true))).get(),
  );

  Future<List<Journey>> getUnpinnedJourneys() => _runDatabaseRead(
    'getUnpinnedJourneys',
    () => (select(journeys)..where((tbl) => tbl.isPinned.equals(false))).get(),
  );

  Future<int> toggleJourneyPin(int id, bool isPinned) => _runDatabaseOperation(
    'toggleJourneyPin',
    () => (update(journeys)..where((tbl) => tbl.id.equals(id))).write(
      JourneysCompanion(isPinned: Value(isPinned)),
    ),
  );

  Future<int> deleteJourney(int id) => _runDatabaseOperation(
    'deleteJourney',
    () => (delete(journeys)..where((tbl) => tbl.id.equals(id))).go(),
  );

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

  Future<List<Stop>> getAllStops({int? limit}) async {
    final query = select(stops)
      ..orderBy([(t) => OrderingTerm(expression: t.stopName)]);
    if (limit != null) {
      query.limit(limit);
    }
    return _runDatabaseRead('getAllStops', () => query.get());
  }

  Future<List<Stop>> searchStops(String query, {int limit = 50}) =>
      _runDatabaseRead(
        'searchStops',
        () =>
            (select(stops)
                  ..where((tbl) => tbl.stopName.like('%$query%'))
                  ..orderBy([(t) => OrderingTerm(expression: t.stopName)])
                  ..limit(limit))
                .get(),
      );

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
  }) async {
    final existing = await _runDatabaseRead<TripPlannerCacheData?>(
      'getTripPlannerCache',
      () =>
          (select(tripPlannerCache)
                ..where((tbl) => tbl.originId.equals(originId))
                ..where((tbl) => tbl.destinationId.equals(destinationId)))
              .getSingleOrNull(),
    );
    if (existing == null) {
      await _runDatabaseOperation<void>(
        'insertTripPlannerCacheError',
        () => into(tripPlannerCache).insert(
          TripPlannerCacheCompanion.insert(
            originId: originId,
            destinationId: destinationId,
            fetchedAt: fetchedAt,
            error: Value(error),
          ),
        ),
      );
      return;
    }
    await _runDatabaseOperation<void>(
      'updateTripPlannerCacheError',
      () =>
          (update(tripPlannerCache)
                ..where((tbl) => tbl.originId.equals(originId))
                ..where((tbl) => tbl.destinationId.equals(destinationId)))
              .write(
                TripPlannerCacheCompanion(
                  fetchedAt: Value(fetchedAt),
                  error: Value(error),
                ),
              ),
    );
  }

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

  // No extra connection helpers are exposed; use the AppDatabase() singleton.

  /// Close, delete and recreate the underlying database file.
  ///
  /// This is intended for development/testing only. It will close the current
  /// instance (if any), delete the database file from the application's
  /// documents directory and create a fresh DB instance.
  static Future<void> resetDatabase() async {
    // Close existing instance if open.
    try {
      await _instance?.close();
    } catch (error, stackTrace) {
      safeLogWarning(
        'Failed to close the existing database instance during reset',
      );
      safeLogError(
        'Database reset close failure',
        error: error,
        stackTrace: stackTrace,
      );
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
