import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/services/realtime_service.dart';

import 'trip_leg_realtime_state.dart';

typedef VehicleAggregateLoader =
    Future<VehiclePositionAggregationResult> Function();
typedef TripUpdateAggregateLoader =
    Future<TripUpdateAggregationResult> Function();

/// Owns realtime aggregate loading, in-flight de-duplication and stale result guards.
class TripLegRealtimeController extends ChangeNotifier {
  TripLegRealtimeController({
    required VehicleAggregateLoader loadVehicles,
    required TripUpdateAggregateLoader loadTripUpdates,
  }) : _loadVehicles = loadVehicles,
       _loadTripUpdates = loadTripUpdates;

  final VehicleAggregateLoader _loadVehicles;
  final TripUpdateAggregateLoader _loadTripUpdates;
  TripLegRealtimeState _state = const TripLegRealtimeState();
  TripLegRealtimeState get state => _state;
  Future<VehiclePositionAggregationResult>? _vehiclesInFlight;
  Future<TripUpdateAggregationResult>? _updatesInFlight;
  int? _vehicleCacheGeneration;
  int? _updatesCacheGeneration;
  DateTime? _vehiclesLoadedAt;
  DateTime? _updatesLoadedAt;
  static const _snapshotTtl = Duration(seconds: 30);

  bool _isFresh(DateTime? loadedAt) =>
      loadedAt != null && DateTime.now().difference(loadedAt) < _snapshotTtl;
  bool _disposed = false;
  bool _notificationQueued = false;

  int beginGeneration({bool clearSnapshot = false}) {
    if (_disposed) return _state.generation;
    final generation = _state.generation + 1;
    _vehiclesInFlight = null;
    _updatesInFlight = null;
    _vehicleCacheGeneration = null;
    _updatesCacheGeneration = null;
    _publish(
      _state.copyWith(
        generation: generation,
        loadingVehicles: false,
        loadingTripUpdates: false,
        clearError: true,
        clearVehicles: clearSnapshot,
        clearTripUpdates: clearSnapshot,
      ),
    );
    return generation;
  }

  bool isCurrent(int generation) =>
      !_disposed && generation == _state.generation;

  Future<VehiclePositionAggregationResult> vehicles(int generation) {
    if (!isCurrent(generation)) {
      return Future.error(StateError('Stale realtime generation'));
    }
    final cached = _state.vehicles;
    if (cached != null &&
        _vehicleCacheGeneration == generation &&
        _isFresh(_vehiclesLoadedAt)) {
      return Future.value(cached);
    }
    final existing = _vehiclesInFlight;
    if (existing != null) return existing;
    _publish(_state.copyWith(loadingVehicles: true, clearError: true));
    final future = Future<VehiclePositionAggregationResult>.sync(_loadVehicles)
        .then(
          (result) {
            if (isCurrent(generation)) {
              _vehiclesInFlight = null;
              _vehicleCacheGeneration = generation;
              _vehiclesLoadedAt = result.metadata.fetchedAt ?? DateTime.now();
              _publish(
                _state.copyWith(
                  vehicles: _freezeVehicles(result),
                  loadingVehicles: false,
                ),
              );
            }
            return result;
          },
          onError: (Object error, StackTrace stack) {
            if (isCurrent(generation)) {
              _vehiclesInFlight = null;
              _publish(
                _state.copyWith(
                  loadingVehicles: false,
                  error: error.toString(),
                ),
              );
            }
            Error.throwWithStackTrace(error, stack);
          },
        );
    _vehiclesInFlight = future;
    return future;
  }

  Future<TripUpdateAggregationResult> tripUpdates(int generation) {
    if (!isCurrent(generation)) {
      return Future.error(StateError('Stale realtime generation'));
    }
    final cached = _state.tripUpdates;
    if (cached != null &&
        _updatesCacheGeneration == generation &&
        _isFresh(_updatesLoadedAt)) {
      return Future.value(cached);
    }
    final existing = _updatesInFlight;
    if (existing != null) return existing;
    _publish(_state.copyWith(loadingTripUpdates: true, clearError: true));
    final future = Future<TripUpdateAggregationResult>.sync(_loadTripUpdates)
        .then(
          (result) {
            if (isCurrent(generation)) {
              _updatesInFlight = null;
              _updatesCacheGeneration = generation;
              _updatesLoadedAt = result.metadata.fetchedAt ?? DateTime.now();
              _publish(
                _state.copyWith(
                  tripUpdates: _freezeUpdates(result),
                  loadingTripUpdates: false,
                ),
              );
            }
            return result;
          },
          onError: (Object error, StackTrace stack) {
            if (isCurrent(generation)) {
              _updatesInFlight = null;
              _publish(
                _state.copyWith(
                  loadingTripUpdates: false,
                  error: error.toString(),
                ),
              );
            }
            Error.throwWithStackTrace(error, stack);
          },
        );
    _updatesInFlight = future;
    return future;
  }

  void _publish(TripLegRealtimeState state) {
    if (_disposed) {
      return;
    }
    _state = state;
    if (_notificationQueued) {
      return;
    }
    _notificationQueued = true;
    scheduleMicrotask(() {
      _notificationQueued = false;
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _state = _state.copyWith(
      generation: _state.generation + 1,
      loadingVehicles: false,
      loadingTripUpdates: false,
    );
    _vehiclesInFlight = null;
    _updatesInFlight = null;
    super.dispose();
  }

  VehiclePositionAggregationResult _freezeVehicles(
    VehiclePositionAggregationResult value,
  ) => VehiclePositionAggregationResult(
    vehicles: List.unmodifiable(value.vehicles),
    breakdown: Map.unmodifiable(value.breakdown),
    metadata: _freezeMetadata(value.metadata),
  );

  TripUpdateAggregationResult _freezeUpdates(
    TripUpdateAggregationResult value,
  ) => TripUpdateAggregationResult(
    tripUpdates: List.unmodifiable(value.tripUpdates),
    breakdown: Map.unmodifiable(value.breakdown),
    metadata: _freezeMetadata(value.metadata),
  );

  RealtimeSnapshotMetadata _freezeMetadata(RealtimeSnapshotMetadata value) =>
      RealtimeSnapshotMetadata(
        fetchedAt: value.fetchedAt,
        failedSources: Set.unmodifiable(value.failedSources),
        staleSources: Set.unmodifiable(value.staleSources),
      );
}
