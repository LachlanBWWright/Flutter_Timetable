import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
import 'package:lbww_flutter/nsw/wrappers/gtfs_endpoint_catalog.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

/// In-memory cache for non-empty station lists keyed by [TransportMode].
final Map<TransportMode, List<Station>> _stationCache = {};
int _stationCacheGeneration = 0;
final Map<TransportMode, int> _modeCacheGenerations = {};

List<Station>? _cachedStationsForMode(TransportMode mode) =>
    _stationCache[mode];

void _cacheStationsForMode(TransportMode mode, List<Station> stations) {
  _stationCache[mode] = stations;
}

/// Load stations for a mode from the local database only (no API fetch).
/// Results are cached in memory so repeated calls are instantaneous.
///
/// This was extracted from `NewTripScreen` to keep DB loading logic reusable.
Future<List<Station>> loadStationsFromDbForMode(TransportMode mode) async {
  final cachedStations = _cachedStationsForMode(mode);
  if (cachedStations != null) {
    return cachedStations;
  }
  final generation = _stationCacheGeneration;
  final modeGeneration = _modeCacheGenerations[mode] ?? 0;
  final endpoints = endpointsForMode(mode);

  final stations = await loadStationsFromDbForEndpoints(endpoints);

  // Startup can prefetch before GTFS downloads finish. Never cache an empty
  // result, or it would hide the stops once those downloads populate the DB.
  if (stations.isNotEmpty &&
      generation == _stationCacheGeneration &&
      modeGeneration == (_modeCacheGenerations[mode] ?? 0)) {
    _cacheStationsForMode(mode, stations);
  }
  return stations;
}

/// Drop a mode's cached stations after its GTFS endpoint has been refreshed.
void invalidateStationCacheForEndpoint(StopsEndpoint endpoint) {
  final mode = StopsService.modeForEndpointKey(endpoint.key);
  if (mode != null) {
    _modeCacheGenerations.update(mode, (value) => value + 1, ifAbsent: () => 1);
    _stationCache.remove(mode);
  }
}

/// Drop all cached station lists after the database is reset.
void clearStationCache() {
  _stationCacheGeneration += 1;
  _stationCache.clear();
  _modeCacheGenerations.clear();
}

List<StopsEndpoint> endpointsForMode(TransportMode mode) =>
    NswGtfsEndpointCatalog.endpointsForMode(mode, includeTrainLink: false);

Future<List<Station>> loadStationsFromDbForEndpoints(
  List<StopsEndpoint> endpoints,
) async {
  final List<gtfs_stop.Stop> allStops = [];
  for (final endpoint in endpoints) {
    try {
      final stops = await StopsService.getStopsForEndpoint(endpoint);
      // Exclude child/platform stops which have a parent_station value.
      allStops.addAll(stops.where((s) => s.parentStation == null));
    } catch (_) {
      // ignore DB read errors for a single endpoint
    }
  }

  return allStops.map((stop) {
    final String displayName = stop.stopName;

    return Station(
      name: displayName,
      id: stop.stopId,
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
  }).toList();
}

/// Preemptively load stations for all transport modes in the background.
/// Cached results will be available immediately when [NewTripScreen] opens.
void prefetchAllStations() {
  for (final mode in TransportMode.values) {
    if (!_stationCache.containsKey(mode)) {
      // Fire-and-forget; errors are swallowed inside loadStationsFromDbForMode
      loadStationsFromDbForMode(mode).ignore();
    }
  }
}
