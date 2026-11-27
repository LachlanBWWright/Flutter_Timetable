import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../logs/logger.dart';
import '../../schema/database.dart' as db;
import '../../services/transport_api_service.dart';
import '../../utils/safe_value_utils.dart';
import 'trip_cache_snapshot.dart';

const _tripCacheMaxDiskEntries = 250;
const _tripCachePruneInterval = Duration(hours: 6);
DateTime? _lastTripCachePrunedAt;
int _tripCacheWritesSincePrune = 0;

Future<void> _pruneTripCacheIfDue(db.AppDatabase database, DateTime now) async {
  _tripCacheWritesSincePrune++;
  final lastPrunedAt = _lastTripCachePrunedAt;
  if (lastPrunedAt != null) {
    final elapsed = now.difference(lastPrunedAt);
    if (!elapsed.isNegative &&
        elapsed < _tripCachePruneInterval &&
        _tripCacheWritesSincePrune < 64) {
      return;
    }
  }
  await database.pruneTripPlannerCache(
    olderThan: now.subtract(const Duration(hours: 24)),
    maxEntries: _tripCacheMaxDiskEntries,
  );
  _lastTripCachePrunedAt = now;
  _tripCacheWritesSincePrune = 0;
}

Future<TripCacheEntry?> readTripCache(String origin, String destination) async {
  final row = await db.AppDatabase().getTripPlannerCache(origin, destination);
  final json = row?.responseJson;
  if (row == null || json == null || json.isEmpty) return null;
  final response = await compute(parseTripCache, json);
  return response == null
      ? null
      : TripCacheEntry(
          response: response,
          fetchedAt: row.fetchedAt,
          error: row.error,
        );
}

GetTripsResponse? parseTripCache(String source) {
  final json = tryDecodeJsonMap(source);
  return json == null ? null : GetTripsResponse.fromJson(json);
}

Future<void> writeTripCache(
  String origin,
  String destination,
  TripCacheEntry entry,
) async {
  final database = db.AppDatabase();
  await database.upsertTripPlannerCache(
    originId: origin,
    destinationId: destination,
    fetchedAt: entry.fetchedAt,
    responseJson: jsonEncode(entry.response.rawJson),
  );
  try {
    await _pruneTripCacheIfDue(database, DateTime.now());
  } catch (error) {
    safeLogWarning('Trip cache pruning failed: $error');
  }
}

Future<void> markTripCacheError(
  String origin,
  String destination,
  String error,
) async {
  final database = db.AppDatabase();
  await database.markTripPlannerCacheError(
    originId: origin,
    destinationId: destination,
    fetchedAt: DateTime.now(),
    error: error,
  );
  try {
    await _pruneTripCacheIfDue(database, DateTime.now());
  } catch (pruneError) {
    safeLogWarning('Trip cache pruning failed: $pruneError');
  }
}
