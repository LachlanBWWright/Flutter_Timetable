part of '../new_trip_service_impl.dart';

class _NewTripStops {
  static void _reportProgress(
    NewTripProgressCallback? onProgress,
    String message,
    int current,
    int total,
  ) {
    if (onProgress == null) {
      return;
    }
    try {
      onProgress(message, current, total);
    } catch (_) {}
  }

  static Station _stationFromStop(Stop stop, TransportMode mode) {
    return Station(
      name: stop.stopName,
      id: stop.stopId,
      mode: mode,
      stopCode: stop.stopCode,
      stopDesc: stop.stopDesc,
      zoneId: stop.zoneId,
      stopUrl: stop.stopUrl,
      stopTimezone: stop.stopTimezone,
      levelId: stop.levelId,
      parentStation: stop.parentStation,
      wheelchairBoarding: stop.wheelchairBoarding,
      platformCode: stop.platformCode,
      latitude: stop.stopLat != 0.0 ? stop.stopLat : null,
      longitude: stop.stopLon != 0.0 ? stop.stopLon : null,
    );
  }

  static final _cacheLoader = EndpointStopCacheLoader(
    readEndpoint: _readEndpointCache,
    refreshEndpoint: (endpoint) async {
      // Reuse atomic publication, cancellation handling and the endpoint lock.
      await _StaticTransportUpdater.updateStaticTransportData(
        endpoints: [endpoint],
      ).drain<void>();
    },
  );

  static Future<EndpointStopCacheSnapshot> _readEndpointCache(
    StopsEndpoint endpoint,
  ) async {
    final stops = await StopsService.getStopsForEndpoint(endpoint);
    try {
      final db = StopsService.database;
      final status = await db.getStaticCacheStatus(endpoint.key);
      final count = await db.getStopLineMembershipCountForEndpoint(
        endpoint.key,
      );
      return EndpointStopCacheSnapshot(
        stops: stops,
        stopsUpdatedAt: status?.stopsUpdatedAt,
        lineMembershipsUpdatedAt: status?.lineMembershipsUpdatedAt,
        membershipCount: count,
      );
    } catch (_) {
      // Metadata failure must not discard the previous usable stop snapshot.
      return EndpointStopCacheSnapshot(stops: stops);
    }
  }

  static Future<GtfsData?> _loadEndpointStaticData(
    StopsEndpoint endpoint,
  ) async {
    final gtfsData = await _GtfsEndpointFetcher.fetchGtfsDataForEndpoint(
      endpoint,
    );
    if (gtfsData == null || gtfsData.stops.isEmpty) {
      return null;
    }
    return gtfsData;
  }

  /// Load stops for a specific transport mode from database or API
  /// Optional progress callback for UI updates
  static Future<List<Station>> loadStopsForMode(
    TransportMode mode, {
    NewTripProgressCallback? onProgress,
  }) async {
    final endpoints = _getEndpointsForMode(mode);
    List<Stop> stops;
    try {
      _reportProgress(
        onProgress,
        'Checking cached stops...',
        0,
        endpoints.length,
      );
      stops = await _cacheLoader.load(endpoints);
    } catch (_) {
      return const <Station>[];
    }
    return stops.map((stop) => _stationFromStop(stop, mode)).toList();
  }

  /// Get the list of API endpoints for a transport mode
  static List<StopsEndpoint> getEndpointsForMode(TransportMode mode) {
    return _getEndpointsForMode(mode);
  }

  static List<StopsEndpoint> _getEndpointsForMode(TransportMode mode) =>
      NswGtfsEndpointCatalog.endpointsForMode(mode);
}
