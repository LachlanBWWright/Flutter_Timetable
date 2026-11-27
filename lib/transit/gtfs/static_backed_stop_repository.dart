import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value, BooleanExpressionOperators;
import 'package:flutter/foundation.dart' show Uint8List;

import '../../constants/transport_modes.dart';
import '../../gtfs/gtfs_data.dart';
import '../../schema/database.dart' as db;
import '../domain/transit_types.dart';
import '../errors/transit_failure.dart';
import '../interfaces/transit_interfaces.dart';
import '../runtime/cancellable_compute.dart';
import 'persistent_gtfs_store.dart';

/// Publishes cached matches immediately, then fills each missing or stale source.
/// Refresh work is shared, but a cancelled caller never owns another's work.
class StaticBackedStopRepository implements ProgressiveStopRepository {
  StaticBackedStopRepository({
    required this.region,
    required this.provider,
    required List<TransitSourceId> sources,
    required this.cachedStops,
    required this.staticData,
    this.database,
    DateTime Function()? now,
    this.modeForSource,
    this.stopSnapshotParser = parseGtfsStopSnapshot,
  }) : sources = List.unmodifiable(sources),
       now = now ?? DateTime.now;

  final TransitRegion region;
  final TransitProviderId provider;
  final List<TransitSourceId> sources;
  final StopRepository cachedStops;
  final StaticGtfsRepository staticData;
  final db.AppDatabase? database;
  final DateTime Function() now;
  final TransportMode? Function(TransitSourceId)? modeForSource;
  final GtfsData Function(Uint8List) stopSnapshotParser;
  final Set<String> _modeBackfills = {};
  static const maxAge = Duration(hours: 24);
  final Map<TransitSourceId, _SourceWork> _pending = {};
  Future<void> _tail = Future.value();
  db.AppDatabase get _database => database ?? db.AppDatabase();

  Future<bool> _hasStops(TransitSourceId source) async =>
      (await _database.searchStops(
        '',
        limit: 1,
        endpoints: [source.value],
      )).isNotEmpty;

  Future<bool> _isFresh(TransitSourceId source) async {
    if (!await _hasStops(source)) return false;
    final updated = (await _database.getStaticCacheStatus(source.value))
        ?.stopsUpdatedAt;
    if (updated == null) return false;
    final age = now().difference(updated);
    return !age.isNegative && age < maxAge;
  }

  Future<List<TransitStop>> _read(
    StopSearchRequest request,
    List<TransitSourceId> selected,
    TransitCancellation cancellation,
  ) async {
    if (!request.browse && request.sourceIds == null) {
      return _withModes(await cachedStops.searchStops(request), cancellation);
    }
    final rows = await _database.searchStops(
      request.query.trim(),
      limit: request.limit,
      endpoints: selected.map((source) => source.value),
    );
    return _withModes(
      rows
          .where(
            (row) => row.parentStation == null || row.parentStation!.isEmpty,
          )
          .map(
            (row) => TransitStop(
              ref: TransitStopRef(
                region: region,
                provider: provider,
                sourceId: TransitSourceId(row.endpoint),
                stopId: row.stopId,
              ),
              name: row.stopName,
              mode: modeForSource?.call(TransitSourceId(row.endpoint)),
              latitude: row.stopLat,
              longitude: row.stopLon,
              stopCode: row.stopCode,
              platformCode: row.platformCode,
              description: row.stopDesc,
            ),
          )
          .toList(),
      cancellation,
    );
  }

  Future<List<TransitStop>> _withModes(
    List<TransitStop> stops,
    TransitCancellation cancellation,
  ) async {
    final maps = <String, Map<String, dynamic>>{};
    for (final source in stops.map((s) => s.ref.sourceId.value).toSet()) {
      final row =
          await (_database.selectOnly(_database.gtfsFeedCaches)
                ..addColumns([_database.gtfsFeedCaches.stopModes])
                ..where(_database.gtfsFeedCaches.source.equals(source)))
              .getSingleOrNull();
      final json = row?.read(_database.gtfsFeedCaches.stopModes);
      if (json != null) maps[source] = jsonDecode(json) as Map<String, dynamic>;
      // Schema 10 archives already contain the timetable. Fill the new compact
      // index locally, preserving the original feed age and offline usability.
      if (json == '{}' && _modeBackfills.add(source)) {
        try {
          final saved = await (_database.select(
            _database.gtfsFeedCaches,
          )..where((row) => row.source.equals(source))).getSingleOrNull();
          if (saved != null) {
            final snapshot = await runTransitCompute(
              stopSnapshotParser,
              saved.archive,
              cancellation: cancellation,
            );
            final encoded = {
              for (final e in snapshot.stopModes.entries)
                e.key: e.value.map((m) => m.name).toList(),
            };
            maps[source] = encoded;
            await (_database.update(_database.gtfsFeedCaches)..where(
                  (row) =>
                      row.source.equals(source) &
                      row.fetchedAt.equals(saved.fetchedAt),
                ))
                .write(
                  db.GtfsFeedCachesCompanion(
                    stopModes: Value(jsonEncode(encoded)),
                  ),
                );
          }
        } on TransitOperationCancelled {
          _modeBackfills.remove(source);
          rethrow;
        } on Exception {
          // Keep old stops searchable even if a pre-validation archive is bad.
        }
      }
    }
    return stops.map((stop) {
      final names =
          maps[stop.ref.sourceId.value]?[stop.ref.stopId] as List<dynamic>?;
      if (names == null) return stop;
      return stop.withModes(
        TransportMode.values.where((m) => names.contains(m.name)).toSet(),
      );
    }).toList();
  }

  @override
  Stream<StopSearchUpdate> watchStops(StopSearchRequest request) {
    final cancellation = request.cancellation ?? StopSearchCancellation();
    final local = StopSearchCancellation();
    late final StreamController<StopSearchUpdate> controller;
    void emit(StopSearchUpdate update) {
      if (!local.isCancelled && !cancellation.isCancelled) {
        controller.add(update);
      }
    }

    controller = StreamController(
      onListen: () {
        unawaited(() async {
          try {
            if ((!request.browse && request.query.trim().isEmpty) ||
                request.limit <= 0) {
              emit(const StopSearchUpdate(stops: []));
              return;
            }
            final selected = sources
                .where(
                  (source) =>
                      request.sourceIds == null ||
                      request.sourceIds!.contains(source),
                )
                .toList();
            if (selected.isEmpty) {
              emit(const StopSearchUpdate(stops: []));
              return;
            }
            var stops = <TransitStop>[];
            final errors = <String, String>{};
            try {
              stops = await _read(request, selected, local);
            } on Exception catch (error) {
              errors['search'] = error.toString();
            }
            final needed = <TransitSourceId>[];
            for (final source in selected) {
              if (!await _isFresh(source)) needed.add(source);
            }
            emit(
              StopSearchUpdate(
                stops: stops,
                isLoading: needed.isNotEmpty,
                isStale: needed.isNotEmpty && stops.isNotEmpty,
                errors: Map.of(errors),
              ),
            );
            for (final source in needed) {
              if (local.isCancelled || cancellation.isCancelled) break;
              final work = _ensureSource(source);
              work.consumers.add(local);
              final subscription = work.progress.stream.listen((progress) {
                emit(
                  StopSearchUpdate(
                    stops: stops,
                    isLoading: true,
                    progress: progress,
                    errors: Map.of(errors),
                    isStale: stops.isNotEmpty,
                  ),
                );
              });
              try {
                await Future.any([
                  work.done,
                  local.whenCancelled,
                  cancellation.whenCancelled,
                ]);
                if (local.isCancelled || cancellation.isCancelled) break;
                errors.remove(source.value);
              } on Exception catch (error) {
                errors[source.value] = error.toString();
              } finally {
                work.consumers.remove(local);
                if (work.consumers.isEmpty) work.cancellation.cancel();
                await subscription.cancel();
              }
              if (local.isCancelled || cancellation.isCancelled) break;
              try {
                stops = await _read(request, selected, local);
                errors.remove('search');
              } on Exception catch (error) {
                errors['search'] = error.toString();
              }
              emit(
                StopSearchUpdate(
                  stops: stops,
                  isLoading: source != needed.last,
                  errors: Map.of(errors),
                  isStale: errors.isNotEmpty && stops.isNotEmpty,
                ),
              );
            }
          } catch (error, stack) {
            if (!local.isCancelled && !cancellation.isCancelled) {
              controller.addError(error, stack);
            }
          } finally {
            await controller.close();
          }
        }());
      },
      onCancel: local.cancel,
    );
    // Wake an active search immediately even if its shared download is waiting.
    unawaited(cancellation.whenCancelled.then((_) => local.cancel()));
    return controller.stream;
  }

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async {
    StopSearchUpdate? latest;
    await for (final update in watchStops(request)) {
      latest = update;
    }
    if (latest == null) return const [];
    if (latest.stops.isEmpty && latest.errors.isNotEmpty) {
      throw ProviderUnavailable(message: latest.errors.values.join('; '));
    }
    return latest.stops;
  }

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async {
    if (!stop.belongsTo(region, provider)) return null;
    final cached = await cachedStops.getStop(stop);
    if (!sources.contains(stop.sourceId)) return cached;
    // Complete this source's refresh even when an old matching stop exists.
    await searchStops(
      StopSearchRequest(
        query: '',
        browse: true,
        sourceIds: [stop.sourceId],
        limit: 1,
      ),
    );
    final loaded = await cachedStops.getStop(stop);
    return loaded == null
        ? null
        : (await _withModes([loaded], TransitCancellation())).single;
  }

  _SourceWork _ensureSource(TransitSourceId source) {
    final active = _pending[source];
    if (active != null && !active.cancellation.isCancelled) return active;
    final work = _SourceWork();
    _pending[source] = work;
    work.done = _tail
        .then((_) async {
          if (!work.consumers.any((token) => !token.isCancelled)) return;
          if (await _isFresh(source)) return;
          String? error;
          await for (final progress in staticData.refreshStaticData(
            StaticImportRequest(
              cancellation: work.cancellation,
              sourceIds: [source],
              force: await _hasStops(source),
            ),
          )) {
            work.progress.add(progress);
            error ??= progress.error;
          }
          work.cancellation.throwIfCancelled();
          if (error != null || !await _hasStops(source)) {
            throw ProviderUnavailable(
              message: error ?? 'No stops were imported for ${region.label}.',
            );
          }
          final feed =
              await (_database.selectOnly(_database.gtfsFeedCaches)
                    ..addColumns([_database.gtfsFeedCaches.fetchedAt])
                    ..where(
                      _database.gtfsFeedCaches.source.equals(source.value),
                    ))
                  .getSingleOrNull();
          await _database
              .into(_database.staticCacheStatuses)
              .insertOnConflictUpdate(
                db.StaticCacheStatusesCompanion.insert(
                  endpoint: source.value,
                  stopsUpdatedAt: Value(
                    feed?.read(_database.gtfsFeedCaches.fetchedAt) ?? now(),
                  ),
                ),
              );
        })
        .whenComplete(() async {
          if (identical(_pending[source], work)) _pending.remove(source);
          await work.progress.close();
        });
    _tail = work.done.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return work;
  }
}

class _SourceWork {
  final cancellation = TransitCancellation();
  final consumers = <StopSearchCancellation>{};
  final progress = StreamController<StaticImportProgress>.broadcast();
  late Future<void> done;
}
