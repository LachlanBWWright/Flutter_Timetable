import 'package:collection/collection.dart';
import 'package:lbww_flutter/debug/debug_extractors.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

import 'entity_data_source.dart';
import 'resolver_models.dart';

class DebugRealtimeMatcher {
  final DebugEntityDataSource _dataSource;

  const DebugRealtimeMatcher({required DebugEntityDataSource dataSource})
    : _dataSource = dataSource;

  Future<List<VehiclePosition>> matchVehicles({
    Set<String> tripIds = const <String>{},
    Set<String> routeIds = const <String>{},
  }) async {
    final aggregation = await _dataSource.vehicleAggregation();
    final matches = <VehiclePosition>[];
    for (final vehicle in aggregation.vehicles) {
      final tripId = vehicle.trip.hasTripId() ? vehicle.trip.tripId : '';
      final routeId = vehicle.trip.hasRouteId() ? vehicle.trip.routeId : '';
      if (tripIds.isNotEmpty) {
        if (tripId.isNotEmpty && tripIds.contains(tripId)) {
          matches.add(vehicle);
        }
        continue;
      }
      if (routeIds.isNotEmpty) {
        if (routeId.isNotEmpty && routeIds.contains(routeId)) {
          matches.add(vehicle);
        }
        continue;
      }
      matches.add(vehicle);
    }
    return matches;
  }

  Future<List<TripUpdate>> matchTripUpdates({
    Set<String> tripIds = const <String>{},
    Set<String> routeIds = const <String>{},
  }) async {
    final aggregation = await _dataSource.tripUpdateAggregation();
    final matches = <TripUpdate>[];
    for (final update in aggregation.tripUpdates) {
      final tripId = update.trip.hasTripId() ? update.trip.tripId : '';
      final routeId = update.trip.hasRouteId() ? update.trip.routeId : '';
      if (tripIds.isNotEmpty) {
        if (tripId.isNotEmpty && tripIds.contains(tripId)) {
          matches.add(update);
        }
        continue;
      }
      if (routeIds.isNotEmpty) {
        if (routeId.isNotEmpty && routeIds.contains(routeId)) {
          matches.add(update);
        }
        continue;
      }
      matches.add(update);
    }
    return matches;
  }

  Future<VehiclePosition?> resolveVehicle({
    VehiclePosition? preferredVehicle,
    String? vehicleId,
    String? tripId,
    String? routeId,
  }) async {
    if (preferredVehicle != null) {
      return preferredVehicle;
    }
    final aggregation = await _dataSource.vehicleAggregation();
    if (vehicleId != null && vehicleId.isNotEmpty) {
      final exact = aggregation.vehicles.firstWhereOrNull((vehicle) {
        final rawId = vehicle.vehicle.hasId() ? vehicle.vehicle.id : '';
        final extractedId = DebugExtractors.vehicleId(vehicle);
        return rawId == vehicleId || extractedId == vehicleId;
      });
      if (exact != null) {
        return exact;
      }
    }
    if (tripId != null && tripId.isNotEmpty) {
      final byTrip = aggregation.vehicles.firstWhereOrNull(
        (vehicle) => vehicle.trip.hasTripId() && vehicle.trip.tripId == tripId,
      );
      if (byTrip != null) {
        return byTrip;
      }
    }
    if (routeId != null && routeId.isNotEmpty) {
      final byRoute = aggregation.vehicles.firstWhereOrNull(
        (vehicle) =>
            vehicle.trip.hasRouteId() && vehicle.trip.routeId == routeId,
      );
      if (byRoute != null) {
        return byRoute;
      }
    }
    return null;
  }

  Future<DebugDerivedVehicleStops> deriveVehicleStops(
    VehiclePosition vehicle, {
    TripUpdate? preferredTripUpdate,
  }) async {
    final tripIds = <String>{
      if (vehicle.trip.hasTripId() && vehicle.trip.tripId.isNotEmpty)
        vehicle.trip.tripId,
    };
    final routeIds = <String>{
      if (tripIds.isEmpty &&
          vehicle.trip.hasRouteId() &&
          vehicle.trip.routeId.isNotEmpty)
        vehicle.trip.routeId,
    };
    final candidates = await matchTripUpdates(
      tripIds: tripIds,
      routeIds: routeIds,
    );
    final orderedCandidates = <TripUpdate>[
      if (preferredTripUpdate != null) preferredTripUpdate,
      ...candidates.where(
        (candidate) => !identical(candidate, preferredTripUpdate),
      ),
    ];
    final matched = orderedCandidates.firstOrNull;
    if (matched == null) {
      return const DebugDerivedVehicleStops(
        reason:
            'No matching realtime trip updates were found for this vehicle.',
      );
    }

    TripUpdate_StopTimeUpdate? currentStop;
    TripUpdate_StopTimeUpdate? nextStop;
    final updates = matched.stopTimeUpdate.toList(growable: false);
    if (updates.isNotEmpty) {
      if (vehicle.hasCurrentStopSequence()) {
        final currentSequence = vehicle.currentStopSequence;
        final index = updates.indexWhere(
          (stop) =>
              stop.hasStopSequence() && stop.stopSequence == currentSequence,
        );
        if (index >= 0) {
          currentStop = updates.elementAtOrNull(index);
          nextStop = updates.elementAtOrNull(index + 1);
        }
      }
      currentStop ??= updates.firstOrNull;
      if (nextStop == null && updates.length > 1) {
        nextStop = updates.elementAtOrNull(1);
      }
    }

    return DebugDerivedVehicleStops(
      currentStop: currentStop,
      nextStop: nextStop,
      matchedTripUpdate: matched,
      candidateTripUpdates: orderedCandidates,
      reason: currentStop == null
          ? 'Trip update matched, but no stop-time updates were available.'
          : 'Derived from realtime trip updates.',
    );
  }
}
