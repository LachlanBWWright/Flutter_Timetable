import 'dart:async';

import '../constants/transport_modes.dart';
import '../fetch_data/timetable_data.dart';
import '../gtfs/gtfs_data.dart';
import '../gtfs/stop.dart';
import '../models/manual_trip_models.dart';
// logger removed
import '../services/location_service.dart';
import '../services/stops_service.dart';
import '../services/trip_line_service.dart';
import '../widgets/station_widgets.dart';

enum StaticTransportUpdateStage {
  fetching,
  parsing,
  storingStops,
  storingLineMemberships,
  complete,
  failed,
}

class StaticTransportUpdateProgress {
  const StaticTransportUpdateProgress({
    required this.endpoint,
    required this.stage,
    required this.completed,
    required this.total,
    this.message,
    this.error,
  });

  final StopsEndpoint? endpoint;
  final StaticTransportUpdateStage stage;
  final int completed;
  final int total;
  final String? message;
  final String? error;

  bool get success => error == null;
}

typedef NewTripProgressCallback =
    void Function(String message, int current, int total);

/// Service for managing stops data in the New Trip screen
class NewTripService {
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

  static Future<List<Stop>> _loadStoredStopsForEndpoints(
    List<StopsEndpoint> endpoints,
  ) async {
    final allStops = <Stop>[];
    for (final endpoint in endpoints) {
      try {
        allStops.addAll(await StopsService.getStopsForEndpoint(endpoint));
      } catch (_) {}
    }
    return allStops;
  }

  static Future<GtfsData?> _loadEndpointStaticData(
    StopsEndpoint endpoint,
  ) async {
    final gtfsData = await fetchGtfsDataForEndpoint(endpoint);
    if (gtfsData == null || gtfsData.stops.isEmpty) {
      return null;
    }
    return gtfsData;
  }

  static Future<void> _storeEndpointStaticData(
    StopsEndpoint endpoint,
    GtfsData gtfsData,
  ) async {
    await StopsService.storeStopsToDatabase(gtfsData.stops, endpoint);
    await TripLineService.instance.cacheGtfsDataForEndpoint(endpoint, gtfsData);
  }

  static Future<void> _refreshStopsForEndpoints(
    List<StopsEndpoint> endpoints, {
    NewTripProgressCallback? onProgress,
  }) async {
    final total = endpoints.length;
    for (final entry in endpoints.indexed) {
      final i = entry.$1;
      final endpoint = entry.$2;
      _reportProgress(onProgress, 'Loading ${endpoint.key}...', i + 1, total);

      try {
        final gtfsData = await _loadEndpointStaticData(endpoint);
        if (gtfsData == null) {
          _reportProgress(
            onProgress,
            'No data found for ${endpoint.key}',
            i + 1,
            total,
          );
          continue;
        }

        await _storeEndpointStaticData(endpoint, gtfsData);
        _reportProgress(
          onProgress,
          'Loaded ${gtfsData.stops.length} stops from ${endpoint.key}',
          i + 1,
          total,
        );
      } catch (e) {
        _reportProgress(
          onProgress,
          'Error loading ${endpoint.key}: $e',
          i + 1,
          total,
        );
      }
    }
  }

  static Future<List<Stop>> _loadStopsFromCacheOrRefresh(
    List<StopsEndpoint> endpoints, {
    NewTripProgressCallback? onProgress,
  }) async {
    final cachedStops = await _loadStoredStopsForEndpoints(endpoints);
    if (cachedStops.isNotEmpty) {
      return cachedStops;
    }

    try {
      await _refreshStopsForEndpoints(endpoints, onProgress: onProgress);
    } catch (_) {}
    return _loadStoredStopsForEndpoints(endpoints);
  }

  /// Load stops for a specific transport mode from database or API
  /// Optional progress callback for UI updates
  static Future<List<Station>> loadStopsForMode(
    TransportMode mode, {
    NewTripProgressCallback? onProgress,
  }) async {
    final endpoints = _getEndpointsForMode(mode);
    try {
      final stops = await _loadStopsFromCacheOrRefresh(
        endpoints,
        onProgress: onProgress,
      );
      return stops.map((stop) => _stationFromStop(stop, mode)).toList();
    } catch (_) {
      return const <Station>[];
    }
  }

  /// Get the list of API endpoints for a transport mode
  static List<StopsEndpoint> getEndpointsForMode(TransportMode mode) {
    return _getEndpointsForMode(mode);
  }

  static List<StopsEndpoint> _getEndpointsForMode(TransportMode mode) {
    switch (mode) {
      case TransportMode.train:
        return [StopsEndpoint.nswtrains, StopsEndpoint.sydneytrains];
      case TransportMode.metro:
        return [StopsEndpoint.metro];
      case TransportMode.lightrail:
        return [
          StopsEndpoint.lightrailInnerwest,
          StopsEndpoint.lightrailNewcastle,
          StopsEndpoint.lightrailCbdandsoutheast,
          StopsEndpoint.lightrailParramatta,
        ];
      case TransportMode.bus:
        return [
          StopsEndpoint.buses,
          StopsEndpoint.busesSbsc006,
          StopsEndpoint.busesGbsc001,
          StopsEndpoint.busesGsbc002,
          StopsEndpoint.busesGsbc003,
          StopsEndpoint.busesGsbc004,
          StopsEndpoint.busesGsbc007,
          StopsEndpoint.busesGsbc008,
          StopsEndpoint.busesGsbc009,
          StopsEndpoint.busesGsbc010,
          StopsEndpoint.busesGsbc014,
          StopsEndpoint.busesOsmbsc001,
          StopsEndpoint.busesOsmbsc002,
          StopsEndpoint.busesOsmbsc003,
          StopsEndpoint.busesOsmbsc004,
          StopsEndpoint.busesOmbsc006,
          StopsEndpoint.busesOmbsc007,
          StopsEndpoint.busesOsmbsc008,
          StopsEndpoint.busesOsmbsc009,
          StopsEndpoint.busesOsmbsc010,
          StopsEndpoint.busesOsmbsc011,
          StopsEndpoint.busesOsmbsc012,
          StopsEndpoint.busesNisc001,
          StopsEndpoint.busesReplacementBus,
        ];
      case TransportMode.ferry:
        return [StopsEndpoint.ferriesSydneyFerries, StopsEndpoint.ferriesMff];
    }
  }

  static Stream<StaticTransportUpdateProgress> updateStaticTransportData({
    bool force = false,
    List<StopsEndpoint>? endpoints,
  }) {
    final selectedEndpoints = _selectedEndpointsOrDefault(endpoints);
    final total = selectedEndpoints.length;
    final controller = StreamController<StaticTransportUpdateProgress>();

    _runUpdateStaticTransportData(
      controller: controller,
      selectedEndpoints: selectedEndpoints,
      total: total,
      force: force,
    );

    return controller.stream;
  }

  static Future<void> _runUpdateStaticTransportData({
    required StreamController<StaticTransportUpdateProgress> controller,
    required List<StopsEndpoint> selectedEndpoints,
    required int total,
    required bool force,
  }) async {
    var completed = 0;
    for (final endpoint in selectedEndpoints) {
      try {
        final cached = await _hasValidStaticCache(endpoint);
        if (cached && !force) {
          completed += 1;
          controller.add(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.complete,
              completed: completed,
              total: total,
              message: 'Using cached ${endpoint.key}',
            ),
          );
          continue;
        }

        await StopsService.database.markStaticCacheBuildStarted(endpoint.key);
        controller.add(
          StaticTransportUpdateProgress(
            endpoint: endpoint,
            stage: StaticTransportUpdateStage.fetching,
            completed: completed,
            total: total,
            message: 'Fetching ${endpoint.key}',
          ),
        );

        try {
          final gtfsData = await _loadEndpointStaticData(endpoint);
          if (gtfsData == null) {
            const error = 'GTFS data unavailable';
            await StopsService.database.markStaticCacheBuildFinished(
              endpoint.key,
              stopsUpdated: false,
              lineMembershipsUpdated: false,
              error: error,
            );
            controller.add(
              StaticTransportUpdateProgress(
                endpoint: endpoint,
                stage: StaticTransportUpdateStage.failed,
                completed: completed,
                total: total,
                message: 'Failed ${endpoint.key}',
                error: '$error for ${endpoint.key}',
              ),
            );
            continue;
          }

          controller.add(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.parsing,
              completed: completed,
              total: total,
              message: 'Parsed ${endpoint.key}',
            ),
          );

          controller.add(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.storingStops,
              completed: completed,
              total: total,
              message: 'Storing stops for ${endpoint.key}',
            ),
          );
          await StopsService.storeStopsToDatabase(gtfsData.stops, endpoint);

          controller.add(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.storingLineMemberships,
              completed: completed,
              total: total,
              message: 'Storing line memberships for ${endpoint.key}',
            ),
          );
          await TripLineService.instance.cacheGtfsDataForEndpoint(
            endpoint,
            gtfsData,
          );

          completed += 1;
          await StopsService.database.markStaticCacheBuildFinished(
            endpoint.key,
            stopsUpdated: true,
            lineMembershipsUpdated: true,
          );
          controller.add(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.complete,
              completed: completed,
              total: total,
              message: 'Completed ${endpoint.key}',
            ),
          );
        } catch (e) {
          await StopsService.database.markStaticCacheBuildFinished(
            endpoint.key,
            stopsUpdated: false,
            lineMembershipsUpdated: false,
            error: e.toString(),
          );
          controller.add(
            StaticTransportUpdateProgress(
              endpoint: endpoint,
              stage: StaticTransportUpdateStage.failed,
              completed: completed,
              total: total,
              message: 'Failed ${endpoint.key}',
              error: e.toString(),
            ),
          );
        }
      } catch (e) {
        // Defensive: catch errors in _hasValidStaticCache or other boundaries
        controller.add(
          StaticTransportUpdateProgress(
            endpoint: endpoint,
            stage: StaticTransportUpdateStage.failed,
            completed: completed,
            total: total,
            message: 'Failed ${endpoint.key}',
            error: e.toString(),
          ),
        );
      }
    }

    controller.add(
      StaticTransportUpdateProgress(
        endpoint: null,
        stage: StaticTransportUpdateStage.complete,
        completed: completed,
        total: total,
        message: 'Finished updating static transport data (completed/total)',
      ),
    );
    await controller.close();
  }

  static Future<bool> _hasValidStaticCache(StopsEndpoint endpoint) async {
    final status = await StopsService.database.getStaticCacheStatus(
      endpoint.key,
    );
    if (status == null ||
        status.stopsUpdatedAt == null ||
        status.lineMembershipsUpdatedAt == null) {
      return false;
    }
    final stopCount = await StopsService.database
        .getStopLineMembershipCountForEndpoint(endpoint.key);
    return stopCount > 0;
  }

  /// Helper function to call the appropriate GTFS fetch function for an endpoint
  static Future<GtfsData?> fetchGtfsDataForEndpoint(
    StopsEndpoint endpoint,
  ) async {
    switch (endpoint) {
      // Trains
      case StopsEndpoint.nswtrains:
        return await fetchNswTrainsGtfsData();
      case StopsEndpoint.sydneytrains:
        return await fetchSydneyTrainsGtfsData();

      case StopsEndpoint.metro:
        return await fetchMetroGtfsData();

      // Light Rail
      case StopsEndpoint.lightrailInnerwest:
        return await fetchLightRailInnerWestGtfsData();
      case StopsEndpoint.lightrailNewcastle:
        return await fetchLightRailNewcastleGtfsData();
      case StopsEndpoint.lightrailCbdandsoutheast:
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case StopsEndpoint.lightrailParramatta:
        return await fetchLightRailParramattaGtfsData();

      // Buses
      case StopsEndpoint.buses:
        return await fetchBusesGtfsData();
      case StopsEndpoint.busesSbsc006:
        return await fetchBusesSBSC006GtfsData();
      case StopsEndpoint.busesGbsc001:
        return await fetchBusesGSBC001GtfsData();
      case StopsEndpoint.busesGsbc002:
        return await fetchBusesGSBC002GtfsData();
      case StopsEndpoint.busesGsbc003:
        return await fetchBusesGSBC003GtfsData();
      case StopsEndpoint.busesGsbc004:
        return await fetchBusesGSBC004GtfsData();
      case StopsEndpoint.busesGsbc007:
        return await fetchBusesGSBC007GtfsData();
      case StopsEndpoint.busesGsbc008:
        return await fetchBusesGSBC008GtfsData();
      case StopsEndpoint.busesGsbc009:
        return await fetchBusesGSBC009GtfsData();
      case StopsEndpoint.busesGsbc010:
        return await fetchBusesGSBC010GtfsData();
      case StopsEndpoint.busesGsbc014:
        return await fetchBusesGSBC014GtfsData();
      case StopsEndpoint.busesOsmbsc001:
        return await fetchBusesOSMBSC001GtfsData();
      case StopsEndpoint.busesOsmbsc002:
        return await fetchBusesOSMBSC002GtfsData();
      case StopsEndpoint.busesOsmbsc003:
        return await fetchBusesOSMBSC003GtfsData();
      case StopsEndpoint.busesOsmbsc004:
        return await fetchBusesOSMBSC004GtfsData();
      case StopsEndpoint.busesOmbsc006:
        return await fetchBusesOMBSC006GtfsData();
      case StopsEndpoint.busesOmbsc007:
        return await fetchBusesOMBSC007GtfsData();
      case StopsEndpoint.busesOsmbsc008:
        return await fetchBusesOSMBSC008GtfsData();
      case StopsEndpoint.busesOsmbsc009:
        return await fetchBusesOSMBSC009GtfsData();
      case StopsEndpoint.busesOsmbsc010:
        return await fetchBusesOSMBSC010GtfsData();
      case StopsEndpoint.busesOsmbsc011:
        return await fetchBusesOSMBSC011GtfsData();
      case StopsEndpoint.busesOsmbsc012:
        return await fetchBusesOSMBSC012GtfsData();
      case StopsEndpoint.busesNisc001:
        return await fetchBusesNISC001GtfsData();
      case StopsEndpoint.busesReplacementBus:
        return await fetchBusesReplacementBusGtfsData();

      // Ferries
      case StopsEndpoint.ferriesSydneyFerries:
        return await fetchFerriesSydneyFerriesGtfsData();
      case StopsEndpoint.ferriesMff:
        return await fetchFerriesMFFGtfsData();

      default:
        return null;
    }
  }

  /// Sort stations alphabetically by name
  static List<Station> sortAlphabetically(List<Station> stations) {
    final sorted = List<Station>.from(stations);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// Sort stations by distance from user's current location
  static Future<List<Station>> sortByDistance(List<Station> stations) async {
    final stationsWithCoords = stations
        .where(
          (station) => station.latitude != null && station.longitude != null,
        )
        .toList();

    if (stationsWithCoords.isEmpty) {
      return sortAlphabetically(stations);
    }

    try {
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        return sortAlphabetically(stations);
      }

      // Calculate distances and create new Station objects with distance data
      final stationsWithDistance = stationsWithCoords.map((station) {
        final lat = station.latitude;
        final lon = station.longitude;
        final double distance = lat != null && lon != null
            ? LocationService.calculateDistance(
                position.latitude,
                position.longitude,
                lat,
                lon,
              )
            : 0.0;
        return station.copyWith(distance: distance);
      }).toList();

      stationsWithDistance.sort((a, b) {
        final distA = a.distance;
        final distB = b.distance;
        if (distA == null && distB == null) return 0;
        if (distA == null) return 1;
        if (distB == null) return -1;
        return distA.compareTo(distB);
      });

      // Add stations without coordinates at the end (sorted alphabetically)
      final stationsWithoutCoords = stations
          .where(
            (station) => station.latitude == null || station.longitude == null,
          )
          .toList();
      stationsWithoutCoords.sort((a, b) => a.name.compareTo(b.name));

      return [...stationsWithDistance, ...stationsWithoutCoords];
    } catch (e) {
      // Error sorting by distance
      return sortAlphabetically(stations);
    }
  }

  /// Get display name for transport mode
  static String getModeDisplayName(TransportMode mode) {
    return mode.displayName;
  }

  static T? _firstNonNull<T>(T? primary, T? fallback) {
    if (primary != null) {
      return primary;
    }
    return fallback;
  }

  static TransportMode? _fallbackModeForLineId(String? lineId) {
    final fallbackEndpointKey = _endpointKeyFromLineId(lineId);
    if (fallbackEndpointKey == null) {
      return null;
    }
    return StopsService.modeForEndpointKey(fallbackEndpointKey);
  }

  static List<StopsEndpoint> _selectedEndpointsOrDefault(
    List<StopsEndpoint>? endpoints,
  ) {
    if (endpoints != null) {
      return endpoints;
    }
    return StopsEndpoint.values;
  }

  static TripLineService _lineServiceOrDefault(TripLineService? lineService) {
    if (lineService != null) {
      return lineService;
    }
    return TripLineService.instance;
  }

  static String? _lineIdForSharedLine(StopLineMatch? sharedLine) {
    if (sharedLine == null) {
      return null;
    }
    return sharedLine.lineId;
  }

  static String? _lineNameForSharedLine(StopLineMatch? sharedLine) {
    if (sharedLine == null) {
      return null;
    }
    return sharedLine.lineName;
  }

  static String? _endpointKeyForSharedLine(StopLineMatch? sharedLine) {
    if (sharedLine == null) {
      return null;
    }
    return sharedLine.endpointKey;
  }

  static TransportMode? _modeForSharedLine(StopLineMatch? sharedLine) {
    if (sharedLine == null) {
      return null;
    }
    return sharedLine.mode;
  }

  static String? _fallbackLineIdForStations(
    Station origin,
    Station destination,
  ) {
    return _firstNonNull(origin.lineId, destination.lineId);
  }

  static String? _fallbackLineNameForStations(
    Station origin,
    Station destination,
  ) {
    return _firstNonNull(origin.lineName, destination.lineName);
  }

  static TransportMode? _preferredLegMode(Station origin, Station destination) {
    return _firstNonNull(origin.mode, destination.mode);
  }

  static TransportMode? _fallbackLineMode(String? lineId) {
    return _fallbackModeForLineId(lineId);
  }

  static StopLineMatch? _selectSharedLine({
    required List<StopLineMatch> sharedLines,
    required TransportMode? preferredMode,
    required TransportMode? previousMode,
    required TransportMode fallbackMode,
  }) {
    if (preferredMode != null) {
      final matchingPreferredMode = _firstWhereOrNull(
        sharedLines,
        (line) => line.mode == preferredMode,
      );
      if (matchingPreferredMode != null) {
        return matchingPreferredMode;
      }
    }

    final previousOrFallbackMode = _firstNonNull(previousMode, fallbackMode);
    final matchingPreviousOrFallback = _firstWhereOrNull(
      sharedLines,
      (line) => line.mode == previousOrFallbackMode,
    );
    if (matchingPreviousOrFallback != null) {
      return matchingPreviousOrFallback;
    }
    return _firstWhereOrNull(sharedLines, (_) => true);
  }

  static TransportMode _resolveManualLegMode({
    StopLineMatch? selectedSharedLine,
    required TransportMode? preferredMode,
    required TransportMode? previousMode,
    required TransportMode? fallbackLineMode,
    required TransportMode fallbackMode,
  }) {
    final selectedMode = _modeForSharedLine(selectedSharedLine);
    if (selectedMode != null) {
      return selectedMode;
    }
    if (preferredMode != null) {
      return preferredMode;
    }
    if (previousMode != null) {
      return previousMode;
    }
    if (fallbackLineMode != null) {
      return fallbackLineMode;
    }
    return fallbackMode;
  }

  static List<Station> buildOrderedTripStops({
    required Station origin,
    required Station destination,
    List<Station> interchanges = const [],
  }) {
    return [origin, ...interchanges, destination];
  }

  static List<ManualTripLeg> buildManualTripLegs({
    required Station origin,
    required Station destination,
    required List<Station> interchanges,
    TransportMode fallbackMode = TransportMode.train,
  }) {
    final orderedStops = buildOrderedTripStops(
      origin: origin,
      destination: destination,
      interchanges: interchanges,
    );

    final legs = <ManualTripLeg>[];
    Station? prev;
    int idx = 0;
    for (final stop in orderedStops) {
      if (prev != null) {
        final legOrigin = prev;
        final legDestination = stop;
        final fallbackLineId = _fallbackLineIdForStations(
          legOrigin,
          legDestination,
        );
        final fallbackEndpointKey = _endpointKeyFromLineId(fallbackLineId);
        final fallbackLineMode = _fallbackLineMode(fallbackLineId);

        legs.add(
          ManualTripLeg(
            index: idx,
            originName: legOrigin.name,
            originId: legOrigin.id,
            destinationName: legDestination.name,
            destinationId: legDestination.id,
            mode: _resolveManualLegMode(
              selectedSharedLine: null,
              preferredMode: _preferredLegMode(legOrigin, legDestination),
              previousMode: null,
              fallbackLineMode: fallbackLineMode,
              fallbackMode: fallbackMode,
            ),
            lineId: fallbackLineId,
            lineName: _fallbackLineNameForStations(legOrigin, legDestination),
            endpointKey: fallbackEndpointKey,
          ),
        );
        idx++;
      }
      prev = stop;
    }
    return legs;
  }

  static Future<List<ManualTripLeg>> buildManualTripLegsWithResolvedMetadata({
    required Station origin,
    required Station destination,
    required List<Station> interchanges,
    required TransportMode fallbackMode,
    TripLineService? tripLineService,
  }) async {
    final lineService = _lineServiceOrDefault(tripLineService);
    final orderedStops = buildOrderedTripStops(
      origin: origin,
      destination: destination,
      interchanges: interchanges,
    );
    final legs = <ManualTripLeg>[];
    TransportMode? previousMode;

    Station? prev;
    int idx = 0;
    for (final stop in orderedStops) {
      if (prev != null) {
        final legOrigin = prev;
        final legDestination = stop;
        List<StopLineMatch> originLines = [];
        List<StopLineMatch> destinationLines = [];
        try {
          originLines = await lineService.getLinesForStop(
            legOrigin.id,
            allowBuild: true,
          );
        } catch (_) {}
        try {
          destinationLines = await lineService.getLinesForStop(
            legDestination.id,
            allowBuild: true,
          );
        } catch (_) {}
        final destinationLineIds = destinationLines
            .map((line) => line.lineId)
            .toSet();
        final sharedLines = originLines
            .where((line) => destinationLineIds.contains(line.lineId))
            .toList();

        final preferredMode = _preferredLegMode(legOrigin, legDestination);
        final selectedSharedLine = _selectSharedLine(
          sharedLines: sharedLines,
          preferredMode: preferredMode,
          previousMode: previousMode,
          fallbackMode: fallbackMode,
        );
        final fallbackLineId = _fallbackLineIdForStations(
          legOrigin,
          legDestination,
        );
        final resolvedMode = _resolveManualLegMode(
          selectedSharedLine: selectedSharedLine,
          preferredMode: preferredMode,
          previousMode: previousMode,
          fallbackLineMode: _fallbackLineMode(fallbackLineId),
          fallbackMode: fallbackMode,
        );

        legs.add(
          ManualTripLeg(
            index: idx,
            originName: legOrigin.name,
            originId: legOrigin.id,
            destinationName: legDestination.name,
            destinationId: legDestination.id,
            mode: resolvedMode,
            lineId: _lineIdForSharedLine(selectedSharedLine),
            lineName: _lineNameForSharedLine(selectedSharedLine),
            endpointKey: _endpointKeyForSharedLine(selectedSharedLine),
          ),
        );
        previousMode = resolvedMode;
        idx++;
      }
      prev = stop;
    }

    return legs;
  }

  static String? validateManualTrip({
    required Station? origin,
    required Station? destination,
    required List<Station> interchanges,
    TransportMode fallbackMode = TransportMode.train,
  }) {
    if (origin == null || destination == null) {
      return 'Select an origin and destination first.';
    }

    final orderedStops = buildOrderedTripStops(
      origin: origin,
      destination: destination,
      interchanges: interchanges,
    );

    if (orderedStops.length < 2) {
      return 'Choose at least one leg before saving.';
    }

    Station? prev;
    for (final stop in orderedStops) {
      if (prev != null) {
        final currentStop = prev;
        final nextStop = stop;
        if (currentStop.id == nextStop.id) {
          return 'Adjacent stops cannot be the same.';
        }
      }
      prev = stop;
    }

    final definition = ManualTripDefinition(
      legs: buildManualTripLegs(
        origin: origin,
        destination: destination,
        interchanges: interchanges,
        fallbackMode: fallbackMode,
      ),
    );

    if (!definition.isValid) {
      return 'Manual trip legs must remain continuous.';
    }

    return null;
  }

  static String? _endpointKeyFromLineId(String? lineId) {
    if (lineId == null) {
      return null;
    }
    final separatorIndex = lineId.indexOf('|');
    if (separatorIndex <= 0) {
      return null;
    }
    return lineId.substring(0, separatorIndex);
  }

  static StopLineMatch? _firstWhereOrNull(
    List<StopLineMatch> matches,
    bool Function(StopLineMatch) predicate,
  ) {
    for (final match in matches) {
      try {
        if (predicate(match)) {
          return match;
        }
      } catch (_) {
        // Defensive: ignore predicate errors
      }
    }
    return null;
  }
}
