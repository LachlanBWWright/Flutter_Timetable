import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../constants/transport_modes.dart';
import '../../gtfs/gtfs_data.dart';
import '../../gtfs/stop.dart';
import '../../nsw/fetch_data/timetable_data.dart';
import '../../schema/database.dart' as db;
import '../domain/timetable_provenance.dart';
import '../domain/transit_cancellation.dart';
import '../errors/transit_failure.dart';
import '../runtime/cancellable_compute.dart';
import '../runtime/transit_resource_budget.dart';
import 'gtfs_feed_validation.dart';

/// Carries the original backend fetch date when an archive came via shared cache.
class GtfsArchiveDownload {
  const GtfsArchiveDownload(this.bytes, {this.fetchedAt});
  factory GtfsArchiveDownload.fromResponse(http.Response response) =>
      GtfsArchiveDownload(
        Uint8List.fromList(response.bodyBytes),
        fetchedAt: DateTime.tryParse(
          response.headers['x-transit-fetched-at'] ?? '',
        ),
      );
  final Uint8List bytes;
  final DateTime? fetchedAt;
}

/// Stores validated original feeds so every consumer can reconstruct complete
/// timetables, including calendars and stop times, after an application restart.
class PersistentGtfsStore {
  PersistentGtfsStore({
    db.AppDatabase? database,
    DateTime Function()? now,
    this.budget = const TransitResourceBudget(),
  }) : _injectedDatabase = database,
       now = now ?? DateTime.now;

  final db.AppDatabase? _injectedDatabase;
  final DateTime Function() now;
  final TransitResourceBudget budget;
  db.AppDatabase get database => _injectedDatabase ?? db.AppDatabase();
  static const maxAge = Duration(hours: 24);
  static final Expando<Map<String, _FeedWork>> _pending = Expando();
  static final Expando<Map<String, ({GtfsData data, DateTime fetchedAt})>>
  _parsed = Expando();

  /// The parsed feed already in memory, without opening a file or fetching.
  GtfsData? cachedDataFor(String source) => _parsed[database]?[source]?.data;

  void _remember(String source, GtfsData data, DateTime fetchedAt) {
    final entries = _parsed[database] ??= {};
    entries.remove(source);
    entries[source] = (data: data, fetchedAt: fetchedAt);
    int bytes(GtfsData d) =>
        d.stopTimes.length * 200 +
        d.stops.length * 512 +
        d.trips.length * 384 +
        d.routes.length * 512 +
        d.calendarDates.length * 96;
    while (entries.values.fold<int>(
              0,
              (sum, entry) => sum + bytes(entry.data),
            ) >
            budget.parsedBytes &&
        entries.isNotEmpty) {
      entries.remove(entries.keys.first);
    }
  }

  Future<GtfsData> load({
    required String source,
    Future<Uint8List> Function()? fetch,
    Future<Uint8List> Function(TransitCancellation cancellation)?
    fetchCancellable,
    Future<GtfsArchiveDownload> Function(TransitCancellation cancellation)?
    download,
    TransitCancellation? cancellation,
    GtfsData Function(Uint8List) parse = parseGtfsZipBytes,
    bool force = false,
    bool requireTimetable = false,
  }) async {
    cancellation?.throwIfCancelled();
    Future<GtfsArchiveDownload> fetchDownload(TransitCancellation token) async {
      if (download != null) return token.wait(download(token));
      return GtfsArchiveDownload(
        await token.wait(
          fetchCancellable != null ? fetchCancellable(token) : fetch!(),
        ),
      );
    }

    final active = _pending[database] ??= {};
    var work = active[source];
    if (force &&
        work != null &&
        !work.force &&
        !work.cancellation.isCancelled) {
      work.consumers++;
      try {
        await (cancellation?.wait(work.future) ?? work.future);
      } on TransitOperationCancelled {
        rethrow;
      } on TransitFailure {
        /* A forced retry still runs after an ordinary failure. */
      } finally {
        work.consumers--;
        if (work.consumers == 0) work.cancellation.cancel();
      }
      return load(
        source: source,
        fetch: fetch,
        fetchCancellable: fetchCancellable,
        download: download,
        cancellation: cancellation,
        parse: parse,
        force: true,
        requireTimetable: requireTimetable,
      );
    }
    if (work == null || work.cancellation.isCancelled) {
      work = _FeedWork(force);
      final started = work;
      active[source] = started;
      started.future =
          _load(
            source,
            () => fetchDownload(started.cancellation),
            parse,
            force,
            requireTimetable,
            started.cancellation,
          ).whenComplete(() {
            if (identical(active[source], started)) active.remove(source);
          });
    }
    work.consumers++;
    try {
      final data = await (cancellation?.wait(work.future) ?? work.future);
      cancellation?.throwIfCancelled();
      if (requireTimetable && data.trips.isEmpty) {
        // Another caller imported a compact stop snapshot. The original archive
        // is persisted, so reconstruct the timetable without downloading again.
        return await _load(
          source,
          () => fetchDownload(cancellation ?? TransitCancellation()),
          parse,
          false,
          true,
          cancellation ?? TransitCancellation(),
        );
      }
      // _load validates parsed archives once; shared and memory reads reuse
      // that validated snapshot rather than rescanning every stop time.
      return data;
    } finally {
      work.consumers--;
      if (work.consumers == 0) work.cancellation.cancel();
    }
  }

  Future<GtfsData> _load(
    String source,
    Future<GtfsArchiveDownload> Function() fetch,
    GtfsData Function(Uint8List) parse,
    bool force,
    bool requireTimetable,
    TransitCancellation cancellation,
  ) async {
    final memory = _parsed[database]?[source];
    if (memory != null && !force) {
      final metadata =
          await (database.selectOnly(database.gtfsFeedCaches)
                ..addColumns([database.gtfsFeedCaches.fetchedAt])
                ..where(database.gtfsFeedCaches.source.equals(source)))
              .getSingleOrNull();
      final age = now().difference(memory.fetchedAt);
      if (metadata?.read(database.gtfsFeedCaches.fetchedAt) ==
              memory.fetchedAt &&
          !age.isNegative &&
          age < maxAge) {
        return _dated(memory.data, memory.fetchedAt);
      }
      if (metadata == null) _parsed[database]?.remove(source);
    }
    final saved = await (database.select(
      database.gtfsFeedCaches,
    )..where((row) => row.source.equals(source))).getSingleOrNull();
    GtfsData? previous;
    if (saved != null) {
      try {
        final parsed = await runTransitCompute(_parseGtfsSnapshot, (
          parse: parse,
          bytes: saved.archive,
          index: requireTimetable,
          maximumStopTimes: budget.maximumStopTimes,
        ), cancellation: cancellation);
        _validate(parsed, requireTimetable);
        previous = _dated(parsed, saved.fetchedAt);
        if (requireTimetable) _remember(source, previous, saved.fetchedAt);
      } on TransitOperationCancelled {
        rethrow;
      } on Exception {
        previous = null;
      }
      final age = now().difference(saved.fetchedAt);
      if (!force && previous != null && !age.isNegative && age < maxAge) {
        return previous;
      }
    }
    try {
      final GtfsArchiveDownload downloaded;
      try {
        downloaded = await fetch();
        cancellation.throwIfCancelled();
      } on TransitFailure {
        rethrow;
      } on Exception {
        throw const ProviderUnavailable(
          message: 'The timetable could not be downloaded.',
        );
      }
      final bytes = downloaded.bytes;
      if (bytes.length > budget.archiveBytes ||
          bytes.length > budget.diskArchiveBytes) {
        throw const TransitResourceLimit(
          message: 'This archive exceeds the configured storage budget.',
        );
      }
      GtfsData parsed;
      try {
        parsed = await runTransitCompute(_parseGtfsSnapshot, (
          parse: parse,
          bytes: bytes,
          index: requireTimetable,
          maximumStopTimes: budget.maximumStopTimes,
        ), cancellation: cancellation);
      } on TransitFailure {
        rethrow;
      } on Exception {
        throw const InvalidProviderResponse(
          message: 'The timetable could not be read.',
        );
      }
      _validate(parsed, requireTimetable);
      if (parsed.stopModes.isEmpty) {
        parsed = parsed.withStopModes(deriveGtfsStopModes(parsed));
      }
      cancellation.throwIfCancelled();
      final fetchedAt = downloaded.fetchedAt ?? now();
      if (fetchedAt.isAfter(now().add(const Duration(seconds: 5)))) {
        throw const InvalidProviderResponse(
          message: 'The timetable has an invalid download date.',
        );
      }
      await database.transaction(() async {
        await database
            .into(database.gtfsFeedCaches)
            .insertOnConflictUpdate(
              db.GtfsFeedCachesCompanion.insert(
                source: source,
                archive: bytes,
                fetchedAt: fetchedAt,
                stopModes: Value(
                  jsonEncode({
                    for (final e in parsed.stopModes.entries)
                      e.key: e.value.map((m) => m.name).toList(),
                  }),
                ),
              ),
            );
        await _enforceArchiveBudget(source);
      });
      if (requireTimetable) {
        final recorded =
            await (database.selectOnly(database.gtfsFeedCaches)
                  ..addColumns([database.gtfsFeedCaches.fetchedAt])
                  ..where(database.gtfsFeedCaches.source.equals(source)))
                .getSingle();
        _remember(
          source,
          parsed,
          recorded.read(database.gtfsFeedCaches.fetchedAt)!,
        );
      }
      return _dated(parsed, fetchedAt);
    } on TransitOperationCancelled {
      rethrow;
    } on Exception {
      // Explicit refresh failures stay visible. Ordinary offline reads can
      // reuse a previously validated timetable without changing its timestamp.
      if (!force && previous != null) {
        return _dated(previous, saved!.fetchedAt, offline: true);
      }
      rethrow;
    }
  }

  Future<void> _enforceArchiveBudget(String current) async {
    final rows = await database
        .customSelect(
          'SELECT source, length(archive) AS bytes FROM gtfs_feed_caches ORDER BY fetched_at ASC',
        )
        .get();
    var total = rows.fold<int>(0, (sum, row) => sum + row.read<int>('bytes'));
    for (final row in rows) {
      if (total <= budget.diskArchiveBytes) break;
      final source = row.read<String>('source');
      if (source == current) continue;
      // Preserve stop modes and original age while releasing archive bytes.
      await (database.update(database.gtfsFeedCaches)
            ..where((r) => r.source.equals(source)))
          .write(db.GtfsFeedCachesCompanion(archive: Value(Uint8List(0))));
      total -= row.read<int>('bytes');
      _parsed[database]?.remove(source);
    }
  }

  GtfsData _dated(GtfsData data, DateTime fetchedAt, {bool offline = false}) =>
      data.withTimetable(
        TimetableProvenance(
          fetchedAt: fetchedAt,
          isStale:
              now().difference(fetchedAt).isNegative ||
              now().difference(fetchedAt) >= maxAge,
          offlineFallback: offline,
        ),
      );

  static void _validate(GtfsData data, bool requireTimetable) {
    validateGtfsFeed(
      data,
      requireTimetable: requireTimetable || !data.isStopSnapshot,
    );
  }
}

class _FeedWork {
  _FeedWork(this.force);
  final bool force;
  final cancellation = TransitCancellation();
  int consumers = 0;
  late Future<GtfsData> future;
}

GtfsData gtfsStopSnapshot(
  List<Stop> stops, {
  Map<String, Set<TransportMode>> stopModes = const {},
}) => GtfsData(
  stopModes: stopModes,
  isStopSnapshot: true,
  stops: stops,
  agencies: const [],
  calendars: const [],
  calendarDates: const [],
  routes: const [],
  stopTimes: const [],
  trips: const [],
  shapes: const [],
  notes: const [],
);
GtfsData validatedGtfsStopSnapshot(GtfsData data) {
  validateGtfsFeed(data);
  return gtfsStopSnapshot(data.stops, stopModes: deriveGtfsStopModes(data));
}

GtfsData parseGtfsStopSnapshot(Uint8List bytes) =>
    parseGtfsZipBytes(bytes, includeGeometry: false, stopsOnly: true);

GtfsData _parseGtfsSnapshot(
  ({
    GtfsData Function(Uint8List) parse,
    Uint8List bytes,
    bool index,
    int maximumStopTimes,
  })
  input,
) {
  final data = input.parse == parseGtfsZipBytes
      ? parseGtfsZipBytes(
          input.bytes,
          includeGeometry: false,
          maximumStopTimes: input.maximumStopTimes,
        )
      : input.parse(input.bytes);
  if (input.index && !data.isStopSnapshot) data.index;
  return data;
}
