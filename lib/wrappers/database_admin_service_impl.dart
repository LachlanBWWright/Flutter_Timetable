import 'package:lbww_flutter/schema/database.dart' as db;

import '../logs/logger.dart';
import '../nsw/wrappers/realtime_service_impl.dart';
import '../nsw/wrappers/station_loader_impl.dart';
import '../nsw/wrappers/stops_service_impl.dart';
import 'trip_cache_service_impl.dart';
import 'trip_line_service_impl.dart';

class DatabaseAdminService {
  const DatabaseAdminService._();

  static Future<bool>? _resetInFlight;

  static Future<bool> resetDatabase() =>
      _resetInFlight ??= _reset().whenComplete(() => _resetInFlight = null);

  static Future<bool> _reset() async {
    try {
      _invalidateMemoryCaches();
      // This is also a barrier for previously accepted cache writes. If it
      // fails, do not wipe storage while those writes may still be pending.
      await TripCacheService.clearMemoryCache();

      await db.AppDatabase.resetDatabase();
      // Loads may have started between the first invalidation and the wipe.
      // Advance their generations again before returning to the caller.
      _invalidateMemoryCaches();
      await TripCacheService.clearMemoryCache();
      return true;
    } catch (error, stackTrace) {
      safeLogError(
        'Failed to reset database',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static void _invalidateMemoryCaches() {
    _clearCacheSafely('trip line indexes', () {
      TripLineService.instance.clearCache();
    });
    _clearCacheSafely('station lists', clearStationCache);
    _clearCacheSafely('stop modes', StopsService.clearModeCache);
    _clearCacheSafely(
      'realtime feed cache',
      RealtimeService.invalidateRealtimeCache,
    );
  }

  static void _clearCacheSafely(String cacheName, void Function() clear) {
    try {
      clear();
    } catch (error, stackTrace) {
      _logCacheClearFailure(cacheName, error, stackTrace);
    }
  }

  static void _logCacheClearFailure(
    String cacheName,
    Object error,
    StackTrace stackTrace,
  ) {
    safeLogWarning('Failed to clear $cacheName while resetting the database');
    safeLogError(
      'Database reset cache invalidation failure: $cacheName',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
