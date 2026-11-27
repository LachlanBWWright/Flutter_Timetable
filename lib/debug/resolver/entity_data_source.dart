import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';

import 'resolver_models.dart';

class DebugEntityDataSource {
  final DebugGtfsLoader _getGtfsData;
  final DebugVehicleAggregationLoader _getVehicles;
  final DebugTripUpdateAggregationLoader _getTripUpdates;
  final DebugDbStopLoader _getDbStops;

  final Map<StopsEndpoint, GtfsData?> _gtfsByEndpoint =
      <StopsEndpoint, GtfsData?>{};
  VehiclePositionAggregationResult? _vehicleAggregation;
  TripUpdateAggregationResult? _tripUpdateAggregation;
  final Map<String, List<db.Stop>> _dbStopsById = <String, List<db.Stop>>{};

  DebugEntityDataSource({
    required DebugGtfsLoader getGtfsDataForEndpoint,
    required DebugVehicleAggregationLoader getAllVehiclesAggregated,
    required DebugTripUpdateAggregationLoader getAllTripUpdatesAggregated,
    required DebugDbStopLoader getDbStopsById,
  }) : _getGtfsData = getGtfsDataForEndpoint,
       _getVehicles = getAllVehiclesAggregated,
       _getTripUpdates = getAllTripUpdatesAggregated,
       _getDbStops = getDbStopsById;

  static V? _mapValueOrNull<K, V>(Map<K, V> values, K key) {
    for (final entry in values.entries) {
      if (entry.key == key) {
        return entry.value;
      }
    }
    return null;
  }

  static void _putValue<K, V>(Map<K, V> values, K key, V value) {
    values.remove(key);
    values.addAll(<K, V>{key: value});
  }

  static Future<T?> _awaitOrNull<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }

  Future<DebugSourceResult<GtfsData>> loadGtfsForEndpointResult(
    StopsEndpoint endpoint,
  ) async {
    if (_gtfsByEndpoint.containsKey(endpoint)) {
      return DebugSourceResult<GtfsData>(
        value: _mapValueOrNull<StopsEndpoint, GtfsData?>(
          _gtfsByEndpoint,
          endpoint,
        ),
        source: DebugDataSource.gtfs,
      );
    }
    try {
      final data = await _getGtfsData(endpoint);
      _putValue(_gtfsByEndpoint, endpoint, data);
      return DebugSourceResult<GtfsData>(
        value: data,
        source: DebugDataSource.gtfs,
      );
    } catch (error, stackTrace) {
      _putValue(_gtfsByEndpoint, endpoint, null);
      return DebugSourceResult<GtfsData>(
        value: null,
        source: DebugDataSource.gtfs,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<GtfsData?> loadGtfsForEndpoint(StopsEndpoint endpoint) async {
    final result = await _awaitOrNull<DebugSourceResult<GtfsData>>(
      () => loadGtfsForEndpointResult(endpoint),
    );
    return result?.value;
  }

  Future<DebugSourceResult<VehiclePositionAggregationResult>>
  vehicleAggregationResult() async {
    final cached = _vehicleAggregation;
    if (cached != null) {
      return DebugSourceResult<VehiclePositionAggregationResult>(
        value: cached,
        source: DebugDataSource.realtime,
      );
    }
    try {
      final loaded =
          await _getVehicles() ??
          const VehiclePositionAggregationResult(
            vehicles: <VehiclePosition>[],
            breakdown: <String, int>{},
          );
      _vehicleAggregation = loaded;
      return DebugSourceResult<VehiclePositionAggregationResult>(
        value: loaded,
        source: DebugDataSource.realtime,
      );
    } catch (error, stackTrace) {
      const fallback = VehiclePositionAggregationResult(
        vehicles: <VehiclePosition>[],
        breakdown: <String, int>{},
      );
      _vehicleAggregation = fallback;
      return DebugSourceResult<VehiclePositionAggregationResult>(
        value: fallback,
        source: DebugDataSource.realtime,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<VehiclePositionAggregationResult> vehicleAggregation() async {
    return (await vehicleAggregationResult()).value ??
        const VehiclePositionAggregationResult(
          vehicles: <VehiclePosition>[],
          breakdown: <String, int>{},
        );
  }

  Future<DebugSourceResult<TripUpdateAggregationResult>>
  tripUpdateAggregationResult() async {
    final cached = _tripUpdateAggregation;
    if (cached != null) {
      return DebugSourceResult<TripUpdateAggregationResult>(
        value: cached,
        source: DebugDataSource.realtime,
      );
    }
    try {
      final loaded =
          await _getTripUpdates() ??
          const TripUpdateAggregationResult(
            tripUpdates: <TripUpdate>[],
            breakdown: <String, int>{},
          );
      _tripUpdateAggregation = loaded;
      return DebugSourceResult<TripUpdateAggregationResult>(
        value: loaded,
        source: DebugDataSource.realtime,
      );
    } catch (error, stackTrace) {
      const fallback = TripUpdateAggregationResult(
        tripUpdates: <TripUpdate>[],
        breakdown: <String, int>{},
      );
      _tripUpdateAggregation = fallback;
      return DebugSourceResult<TripUpdateAggregationResult>(
        value: fallback,
        source: DebugDataSource.realtime,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<TripUpdateAggregationResult> tripUpdateAggregation() async {
    return (await tripUpdateAggregationResult()).value ??
        const TripUpdateAggregationResult(
          tripUpdates: <TripUpdate>[],
          breakdown: <String, int>{},
        );
  }

  Future<DebugSourceResult<List<db.Stop>>> lookupDbStopsResult(
    String stopId,
  ) async {
    if (_dbStopsById.containsKey(stopId)) {
      return DebugSourceResult<List<db.Stop>>(
        value: _mapValueOrNull(_dbStopsById, stopId),
        source: DebugDataSource.localDb,
      );
    }
    try {
      final rows = await _getDbStops(stopId);
      _putValue(_dbStopsById, stopId, rows);
      return DebugSourceResult<List<db.Stop>>(
        value: rows,
        source: DebugDataSource.localDb,
      );
    } catch (error, stackTrace) {
      _putValue(_dbStopsById, stopId, const <db.Stop>[]);
      return DebugSourceResult<List<db.Stop>>(
        value: const <db.Stop>[],
        source: DebugDataSource.localDb,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<db.Stop>> lookupDbStops(String stopId) async {
    final result = await _awaitOrNull<DebugSourceResult<List<db.Stop>>>(
      () => lookupDbStopsResult(stopId),
    );
    return result?.value ?? const <db.Stop>[];
  }
}
