part of '../trip_leg_detail_screen.dart';

/// Builds the embedded map and its delayed loading placeholder.
extension _MapSection on _TripLegDetailScreenState {
  TripDescriptor? _matchedTripForMap(Leg leg) {
    final updates = _realtimeController.state.tripUpdates?.tripUpdates;
    return updates == null
        ? null
        : _matchTripUpdateForLeg(updates, leg: leg)?.trip;
  }

  bool _legHasCoords(Leg leg) {
    final coords = leg.coords;
    if (coords != null && coords.length >= 2) return true;
    final stops = leg.stopSequence;
    if (stops != null && stops.length >= 2) return true;
    // At minimum, origin + destination coords are enough to draw a line.
    return (leg.origin.coord?.length ?? 0) >= 2 &&
        (leg.destination.coord?.length ?? 0) >= 2;
  }

  /// Builds the core [RealtimeMapWidget] for a leg, used in both the card
  /// (scrollable debug layout) and the full-height (non-scrollable) layout.
  RealtimeMapWidget _buildRealtimeMapWidget(
    String? transportId,
    TransportMode? mode,
    Leg leg,
    List<Leg> additionalLegs,
  ) {
    final hasTransport = transportId != null && transportId.isNotEmpty;
    final supportsRealtime = _supportsRealtimeForLeg(leg);
    return RealtimeMapWidget(
      // No ValueKey: didUpdateWidget in RealtimeMapWidget handles camera
      // updates when the leg prop changes, avoiding a full teardown/rebuild.
      leg: leg,
      additionalLegs: additionalLegs,
      transportMode: mode,
      routeFilter: hasTransport ? transportId : null,
      filterByLegTrip: hasTransport,
      tripIds: hasTransport ? _collectLegTripIds() : null,
      matchedTrip: _matchedTripForMap(leg),
      showVehicleCount: false,
      autoRefresh: false,
      onRefresh: supportsRealtime ? _retryRealtimeFeeds : null,
      refreshGeneration: _realtimeController.state.generation,
      getAllVehiclesAggregated: supportsRealtime
          ? _getVehicleAggregate
          : () async => const VehiclePositionAggregationResult(
              vehicles: <VehiclePosition>[],
              breakdown: <String, int>{},
            ),
    );
  }

  /// Returns the map widget filling all available space (used in the
  Widget _buildMapCard(
    String? transportId,
    TransportMode? mode,
    Leg leg,
    Color modeColor,
    List<Leg> additionalLegs,
  ) {
    if (widget.skipInitialLoadDelay) {
      return const SizedBox.shrink();
    }

    final hasTransport = transportId != null && transportId.isNotEmpty;
    if (!hasTransport && !_legHasCoords(leg)) {
      return const SizedBox.shrink();
    }

    if (!_showEmbeddedMap) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            _buildRealtimeMapWidget(transportId, mode, leg, additionalLegs),
            Positioned(
              bottom: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen),
                  color: modeColor,
                  tooltip: 'Open fullscreen map',
                  onPressed: _openFullscreenMap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
