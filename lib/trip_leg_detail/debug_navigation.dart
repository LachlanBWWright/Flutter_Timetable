part of '../trip_leg_detail_screen.dart';

/// Opens diagnostic pages and browsers with the active leg’s context.
extension _DebugNavigation on _TripLegDetailScreenState {
  StopsEndpoint? _currentGtfsEndpoint() {
    return currentGtfsEndpointFromKey(_gtfsRouteEndpointKey);
  }

  DebugEntityContext _debugContextForLeg(Leg leg, {VehiclePosition? vehicle}) {
    return DebugEntityContext(
      tripJourney: widget.trip,
      leg: leg,
      transportation: leg.transportation,
      vehiclePosition: vehicle,
      gtfsRoute: _gtfsRoute,
      gtfsAgency: _gtfsAgency,
      gtfsEndpoint: _currentGtfsEndpoint(),
      gtfsMatchReason: _gtfsRouteMatchReason,
    );
  }

  Future<void> _openTripDebugPage(Leg leg) async {
    final trip = widget.trip;
    if (trip == null) {
      return;
    }
    final tripIds = _collectDebugTripIds(trip);
    final tripId = tripIds.isNotEmpty ? tripIds.first : 'trip';
    await DebugNavigation.pushEntity(
      context,
      request: DebugEntityRequest(
        entityType: DebugEntityType.trip,
        entityId: tripId,
        context: _debugContextForLeg(leg),
      ),
      loader: _debugPageLoader,
    );
  }

  Future<void> _openRouteDebugPage(Leg leg) async {
    final routeId = _legRouteIdFor(leg);
    if (routeId == null || routeId.isEmpty) {
      return;
    }
    await DebugNavigation.pushEntity(
      context,
      request: DebugEntityRequest(
        entityType: DebugEntityType.route,
        entityId: routeId,
        context: _debugContextForLeg(leg),
      ),
      loader: _debugPageLoader,
    );
  }

  Future<void> _openVehicleDebugPage(Leg leg, VehiclePosition vehicle) async {
    final vehicleId = vehicleDisplayId(vehicle);
    await DebugNavigation.pushEntity(
      context,
      request: DebugEntityRequest(
        entityType: DebugEntityType.vehicle,
        entityId: vehicleId,
        context: _debugContextForLeg(leg, vehicle: vehicle),
      ),
      loader: _debugPageLoader,
    );
  }

  Future<void> _openDebugBrowser(
    DebugEntityType entityType, {
    String? initialSearchQuery,
    Map<String, String> initialFilters = const {},
  }) async {
    await DebugNavigation.pushBrowser(
      context,
      entityType: entityType,
      listLoader: _debugListLoader,
      pageLoader: _debugPageLoader,
      initialSearchQuery: initialSearchQuery,
      initialFilters: initialFilters,
    );
  }

  Future<void> _openTripDebugBrowser(Leg leg) async {
    final routeId = _legRouteIdFor(leg);
    final tripId = firstSortedValue(_collectTripIdsForActiveLeg());
    await _openDebugBrowser(
      DebugEntityType.trip,
      initialSearchQuery: tripId,
      initialFilters: {
        if (routeId != null && routeId.isNotEmpty) 'route': routeId,
      },
    );
  }

  Future<void> _openRouteDebugBrowser(Leg leg) async {
    final routeId = _legRouteIdFor(leg);
    await _openDebugBrowser(
      DebugEntityType.route,
      initialSearchQuery: routeId != null && routeId.isNotEmpty
          ? routeId
          : null,
    );
  }

  Future<void> _openVehicleDebugBrowser(Leg leg) async {
    final routeId = _legRouteIdFor(leg);
    final tripId = firstSortedValue(_collectTripIdsForActiveLeg());
    await _openDebugBrowser(
      DebugEntityType.vehicle,
      initialFilters: {
        if (routeId != null && routeId.isNotEmpty) 'route': routeId,
        if (tripId != null) 'trip': tripId,
      },
    );
  }

  Future<void> _copyDebugText({
    required String text,
    required String successMessage,
    required String failureMessage,
  }) async {
    final copied = await setClipboardTextSafely(text);
    if (copied) {
      showSnackBar(SnackBar(content: Text(successMessage)));
      return;
    }
    showSnackBar(SnackBar(content: Text(failureMessage)));
  }

  String _formatTimeDifference(String? plannedTime, String? estimatedTime) {
    return formatTimeDifference(plannedTime, estimatedTime);
  }

  /// Returns true when the leg has enough coordinate data to render a map.
}
