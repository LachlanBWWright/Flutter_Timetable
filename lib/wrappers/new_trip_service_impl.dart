import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../constants/transport_modes.dart';
import '../gtfs/gtfs_data.dart';
import '../gtfs/stop.dart';
import '../models/manual_trip_models.dart';
import '../nsw/wrappers/gtfs_endpoint_catalog.dart';
// logger removed
import '../services/location_service.dart';
import '../services/station_loader.dart';
import '../services/stops_service.dart';
import '../services/trip_line_service.dart';
import '../widgets/station_widgets.dart';
import 'new_trip_service/endpoint_stop_cache.dart';

part 'new_trip_service/stop_loader.dart';
part 'new_trip_service/static_transport_updater.dart';
part 'new_trip_service/endpoint_update_queue.dart';
part 'new_trip_service/gtfs_endpoint_fetcher.dart';
part 'new_trip_service/station_sorter.dart';
part 'new_trip_service/manual_trip_builder.dart';

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

/// Service for loading stops and assembling manual trips.
///
/// The public entry point delegates to focused loading, update, sorting and
/// trip-building components within this library.
class NewTripService {
  static Future<List<Station>> loadStopsForMode(
    TransportMode mode, {
    NewTripProgressCallback? onProgress,
  }) => _NewTripStops.loadStopsForMode(mode, onProgress: onProgress);

  static List<StopsEndpoint> getEndpointsForMode(TransportMode mode) =>
      _NewTripStops.getEndpointsForMode(mode);

  static Stream<StaticTransportUpdateProgress> updateStaticTransportData({
    bool force = false,
    List<StopsEndpoint>? endpoints,
  }) => _StaticTransportUpdater.updateStaticTransportData(
    force: force,
    endpoints: endpoints,
  );

  static Future<GtfsData?> fetchGtfsDataForEndpoint(StopsEndpoint endpoint) =>
      _GtfsEndpointFetcher.fetchGtfsDataForEndpoint(endpoint);

  static List<Station> sortAlphabetically(List<Station> stations) =>
      _StationSorter.sortAlphabetically(stations);

  static Future<List<Station>> sortByDistance(List<Station> stations) =>
      _StationSorter.sortByDistance(stations);

  static String getModeDisplayName(TransportMode mode) => mode.displayName;

  static List<Station> buildOrderedTripStops({
    required Station origin,
    required Station destination,
    List<Station> interchanges = const [],
  }) => _ManualTripBuilder.buildOrderedTripStops(
    origin: origin,
    destination: destination,
    interchanges: interchanges,
  );

  static List<ManualTripLeg> buildManualTripLegs({
    required Station origin,
    required Station destination,
    required List<Station> interchanges,
    TransportMode fallbackMode = TransportMode.train,
  }) => _ManualTripBuilder.buildManualTripLegs(
    origin: origin,
    destination: destination,
    interchanges: interchanges,
    fallbackMode: fallbackMode,
  );

  static Future<List<ManualTripLeg>> buildManualTripLegsWithResolvedMetadata({
    required Station origin,
    required Station destination,
    required List<Station> interchanges,
    required TransportMode fallbackMode,
    TripLineService? tripLineService,
  }) => _ManualTripBuilder.buildManualTripLegsWithResolvedMetadata(
    origin: origin,
    destination: destination,
    interchanges: interchanges,
    fallbackMode: fallbackMode,
    tripLineService: tripLineService,
  );

  static String? validateManualTrip({
    required Station? origin,
    required Station? destination,
    required List<Station> interchanges,
    TransportMode fallbackMode = TransportMode.train,
  }) => _ManualTripBuilder.validateManualTrip(
    origin: origin,
    destination: destination,
    interchanges: interchanges,
    fallbackMode: fallbackMode,
  );
}
