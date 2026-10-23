part of '../trip_leg_detail_screen.dart';

/// Loads and filters the active leg’s realtime vehicle and trip feeds.
extension _RealtimeLoading on _TripLegDetailScreenState {
  void _syncRealtimeState() {
    final snapshot = _realtimeController.state;
    if (!mounted) return;
    guardedSetState(() {
      _isLoadingVehicles = snapshot.loadingVehicles;
      if (snapshot.vehicles != null) {
        _vehicles = snapshot.vehicles!.vehicles.toList();
        _vehicles.sort(
          (a, b) => vehicleDisplayId(
            a,
          ).toLowerCase().compareTo(vehicleDisplayId(b).toLowerCase()),
        );
        _vehicleBreakdown = snapshot.vehicles!.breakdown;
      }
    });
  }

  TransportMode? _getRealtimeModeFromClass(int? transportClass) {
    if (transportClass == null) return null;
    switch (transportClass) {
      case 1: // Train
        return TransportMode.train;
      case 2: // Metro
        return TransportMode.metro;
      case 4: // Light Rail
        return TransportMode.lightrail;
      case 5: // Bus
      case 11: // School Bus
        return TransportMode.bus;
      case 9: // Ferry
        return TransportMode.ferry;
      default:
        return null;
    }
  }

  bool _isManualLeg(Leg leg) {
    final rawJson = leg.rawJson;
    if (tryReadMapValue(rawJson, 'manual') == true) {
      return true;
    }

    final transportRawJson = _transportRawJson(leg.transportation);
    return tryReadMapValue(transportRawJson, 'manual') == true;
  }

  bool _supportsRealtimeForLeg(Leg leg) {
    final transportId = _legRouteIdFor(leg);
    return tryReadMapValue(leg.rawJson, 'provenance') !=
            'regional_journey_planner' &&
        !_isManualLeg(leg) &&
        transportId != null &&
        transportId.isNotEmpty &&
        _getRealtimeModeFromClass(_transportClass(leg.transportation)) != null;
  }

  Future<void> _refreshLegData({bool forceRefresh = false}) async {
    if (!mounted) return;
    if (forceRefresh) RealtimeService.invalidateRealtimeCache();
    final generation = ++_requestGeneration;
    _realtimeController.beginGeneration();
    final activeLeg = _activeLeg;
    _stopRequestGeneration++;
    _debugRequestGeneration++;
    _resetRouteDebugState();
    guardedSetState(() {
      _error = null;
      _isLoadingVehicleStops = false;
    });

    await runAsyncGuarded(
      () async {
        if (!_isCurrentRequest(generation, activeLeg)) return;
        if (_supportsRealtimeForLeg(activeLeg)) {
          await Future.wait([
            _loadVehiclesForLeg(),
            _loadRealtimeTripStatusForLeg(),
          ]);
          if (!_isCurrentRequest(generation, activeLeg)) return;
          if (_showAllVehicleStops) {
            await _loadVehicleStopsForLeg();
          }
          if (!_isCurrentRequest(generation, activeLeg)) return;
          if (DebugService.showDebugData.value) {
            _ensureRouteDebugLoaded();
          }
        } else if (mounted) {
          guardedSetState(() {
            _vehicles = [];
            _vehicleBreakdown = {};
            _vehicleStops = [];
            _vehicleStopsError = null;
            _isLoadingVehicles = false;
            _isLoadingVehicleStops = false;
            _resetRouteDebugState();
          });
        }
      },
      onError: (error, _) {
        if (!_isCurrentRequest(generation, activeLeg)) return;
        guardedSetState(() {
          _error = error.toString();
          _isLoadingVehicles = false;
        });
      },
    );
  }

  Future<VehiclePositionAggregationResult> _loadVehicleAggregate() async {
    final getAllVehiclesAggregated = widget.getAllVehiclesAggregated;
    if (getAllVehiclesAggregated != null) {
      try {
        return await getAllVehiclesAggregated.call();
      } on Exception catch (error) {
        safeLogInfo('Failed to fetch live vehicles: $error');
        return const VehiclePositionAggregationResult(
          vehicles: <VehiclePosition>[],
          breakdown: <String, int>{},
          metadata: RealtimeSnapshotMetadata(failedSources: {'vehicles'}),
        );
      }
    }
    final mode = _getRealtimeModeFromClass(
      _transportClass(_activeLeg.transportation),
    );
    if (mode == null) {
      return const VehiclePositionAggregationResult(
        vehicles: <VehiclePosition>[],
        breakdown: <String, int>{},
      );
    }
    return RealtimeService.getVehiclePositionsForModeSafe(mode);
  }

  Future<TripUpdateAggregationResult> _loadTripUpdateAggregate() async {
    final getAllTripUpdatesAggregated = widget.getAllTripUpdatesAggregated;
    if (getAllTripUpdatesAggregated != null) {
      try {
        return await getAllTripUpdatesAggregated.call();
      } on Exception catch (error) {
        safeLogInfo('Failed to fetch live trip updates: $error');
        return const TripUpdateAggregationResult(
          tripUpdates: <TripUpdate>[],
          breakdown: <String, int>{},
          metadata: RealtimeSnapshotMetadata(failedSources: {'trip updates'}),
        );
      }
    }
    final mode = _getRealtimeModeFromClass(
      _transportClass(_activeLeg.transportation),
    );
    if (mode == null) {
      return const TripUpdateAggregationResult(
        tripUpdates: <TripUpdate>[],
        breakdown: <String, int>{},
      );
    }
    return RealtimeService.getTripUpdatesForModeSafe(mode);
  }

  // Kept as screen-level adapters for map and stop-loading parts that share
  // these aggregate request providers.
  Future<VehiclePositionAggregationResult> _getVehicleAggregate() =>
      _realtimeController.vehicles(_realtimeController.state.generation);

  Future<TripUpdateAggregationResult> _getTripUpdateAggregate() =>
      _realtimeController.tripUpdates(_realtimeController.state.generation);

  String? _legRouteId() => _legRouteIdFor(_activeLeg);

  Set<String> _collectTripIdsForActiveLeg() {
    return collectTripIdsForVehicleFiltering(
      tripRawJson: widget.trip?.rawJson,
      legRawJson: _activeLeg.rawJson,
    );
  }

  /// Collect only the trip IDs that belong to the active leg (not the whole trip)
  Set<String> _collectLegTripIds() {
    final ids = _collectTripIdsForActiveLeg();
    if (ids.isNotEmpty) return ids;
    final updates = _realtimeController.state.tripUpdates?.tripUpdates;
    if (updates == null) return const {};
    final match = _matchTripUpdateForLeg(updates);
    return match == null ? const {} : {match.trip.tripId};
  }

  List<VehiclePosition> get _displayedVehicles {
    if (!_filterByLegRoute) {
      return _vehicles;
    }

    final tripIds = _collectLegTripIds();

    final updates = _realtimeController.state.tripUpdates?.tripUpdates;
    final matched = updates == null ? null : _matchTripUpdateForLeg(updates);
    return filterRealtimeVehiclesForLeg(
      _vehicles,
      _activeLeg,
      tripIds,
      matchedTrip: matched?.trip,
    );
  }

  Future<void> _loadVehiclesForLeg() async {
    final generation = _requestGeneration;
    final leg = _activeLeg;
    final controllerGeneration = _realtimeController.state.generation;
    final aggregate = await _realtimeController.vehicles(controllerGeneration);
    if (!_isCurrentRequest(generation, leg)) return;
    final dedupedVehicles = aggregate.vehicles.toList();
    final breakdown = aggregate.breakdown;

    dedupedVehicles.sort(
      (a, b) => vehicleDisplayId(
        a,
      ).toLowerCase().compareTo(vehicleDisplayId(b).toLowerCase()),
    );

    guardedSetState(() {
      _vehicles = dedupedVehicles;
      _vehicleBreakdown = breakdown;
      _isLoadingVehicles = false;
    });
  }

  Future<void> _loadRealtimeTripStatusForLeg() async {
    await _realtimeController.tripUpdates(_realtimeController.state.generation);
  }

  TripUpdate? _matchTripUpdateForLeg(List<TripUpdate> tripUpdates, {Leg? leg}) {
    final matchingLeg = leg ?? _activeLeg;
    final tripIds = collectTripIdsForVehicleFiltering(
      tripRawJson: widget.trip?.rawJson,
      legRawJson: matchingLeg.rawJson,
    );
    return matchRealtimeUpdateForLeg(tripUpdates, matchingLeg, tripIds);
  }
}
