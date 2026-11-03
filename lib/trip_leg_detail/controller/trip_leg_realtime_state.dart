import 'package:lbww_flutter/services/realtime_service.dart';

/// Immutable view of one realtime request generation.
class TripLegRealtimeState {
  final int generation;
  final VehiclePositionAggregationResult? vehicles;
  final TripUpdateAggregationResult? tripUpdates;
  final bool loadingVehicles;
  final bool loadingTripUpdates;
  final String? error;

  const TripLegRealtimeState({
    this.generation = 0,
    this.vehicles,
    this.tripUpdates,
    this.loadingVehicles = false,
    this.loadingTripUpdates = false,
    this.error,
  });

  TripLegRealtimeState copyWith({
    int? generation,
    VehiclePositionAggregationResult? vehicles,
    TripUpdateAggregationResult? tripUpdates,
    bool? loadingVehicles,
    bool? loadingTripUpdates,
    String? error,
    bool clearVehicles = false,
    bool clearTripUpdates = false,
    bool clearError = false,
  }) => TripLegRealtimeState(
    generation: generation ?? this.generation,
    vehicles: clearVehicles ? null : vehicles ?? this.vehicles,
    tripUpdates: clearTripUpdates ? null : tripUpdates ?? this.tripUpdates,
    loadingVehicles: loadingVehicles ?? this.loadingVehicles,
    loadingTripUpdates: loadingTripUpdates ?? this.loadingTripUpdates,
    error: clearError ? null : error ?? this.error,
  );
}
