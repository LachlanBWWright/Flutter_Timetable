part of '../trip_leg_detail_screen.dart';

/// Both map entry points observe the same live matching snapshot.
extension _MapOpening on _TripLegDetailScreenState {
  RealtimeMapLegSnapshot _mapLegSnapshot() {
    final leg = _activeLeg;
    final state = _realtimeController.state;
    final routeId = _legRouteIdFor(leg);
    final tripIds = collectTripIdsForVehicleFiltering(
      tripRawJson: widget.trip?.rawJson,
      legRawJson: leg.rawJson,
    );
    final updates = state.tripUpdates?.tripUpdates;
    final matchedTrip = updates == null
        ? null
        : _matchTripUpdateForLeg(updates, leg: leg)?.trip;
    if (tripIds.isEmpty && matchedTrip != null) {
      tripIds.add(matchedTrip.tripId);
    }
    return RealtimeMapLegSnapshot(
      leg: leg,
      additionalLegs: _tripLegs.where((other) => other != leg).toList(),
      transportMode: _getRealtimeModeFromClass(
        _transportClass(leg.transportation),
      ),
      routeFilter: routeId,
      tripIds: tripIds,
      matchedTrip: matchedTrip,
      refreshGeneration: state.generation,
    );
  }

  Future<VehiclePositionAggregationResult> _fullscreenVehicles() {
    if (!mounted || !_supportsRealtimeForLeg(_activeLeg)) {
      return Future.value(
        const VehiclePositionAggregationResult(
          vehicles: <VehiclePosition>[],
          breakdown: <String, int>{},
        ),
      );
    }
    return _getVehicleAggregate();
  }

  void _openFullscreenMap() {
    pushPage(
      (context) => RealtimeMapPage(
        legListenable: _realtimeController,
        getLegSnapshot: _mapLegSnapshot,
        getAllVehiclesAggregated: _fullscreenVehicles,
        onRefresh: _supportsRealtimeForLeg(_activeLeg)
            ? _retryRealtimeFeeds
            : null,
      ),
    );
  }
}
