part of '../realtime_map_widget.dart';

extension _RealtimeMapMarkers on _RealtimeMapWidgetState {
  List<Marker> _buildVehicleMarkers() {
    if (_vehicleMarkers case final cached?) return cached;
    return _vehicleMarkers = _vehicles
        .where(
          (vw) =>
              vw.vehicle.hasPosition() &&
              vw.vehicle.position.hasLatitude() &&
              vw.vehicle.position.hasLongitude() &&
              // Only include vehicles whose mode is enabled in the filter
              _isModeEnabled(vw.mode),
        )
        .map((vw) {
          final vehicle = vw.vehicle;
          final position = vehicle.position;
          final mode = vw.mode;

          // Use mode-based color and icon mapping. Prefer typed API when possible.
          final Color markerColor = mode != null
              ? TransportColors.getColorByTransportMode(mode)
              : Colors.grey;

          return Marker(
            point: LatLng(position.latitude, position.longitude),
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: () => _showVehicleInfo(vehicle),
              child: Container(
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  getVehicleIconByTransportMode(mode),
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          );
        })
        .toList();
  }

  /// Build stop markers from a provided `leg` stopSequence
  List<Marker> _buildStopMarkers() {
    if (_stopMarkers case final cached?) return cached;
    final markers = <Marker>[];

    // Markers for other-leg stops are deliberately quiet so the active leg
    // remains the visual anchor while the rest of the trip stays visible.
    for (final otherLeg in widget.additionalLegs ?? const <Leg>[]) {
      final stops = otherLeg.stopSequence;
      if (stops == null) continue;

      // Derive the colour from the other leg's transport class if available.
      final otherClass = otherLeg.transportation?.product?.classField;
      final Color otherColor = otherClass != null
          ? TransportModeUtils.getModeColor(otherClass)
          : Colors.blueGrey;

      for (final s in stops) {
        final point = _tryParseLatLngSafe(s.coord);
        if (point == null) continue;
        markers.add(
          Marker(
            point: point,
            width: 10.0,
            height: 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: otherColor.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      }
    }

    // Active leg stop markers
    final leg = widget.leg;
    if (leg == null) return _stopMarkers = markers;
    final stops = leg.stopSequence;
    if (stops == null || stops.isEmpty) return _stopMarkers = markers;
    // Determine color/icon from the provided transportMode (or fallback)
    final mode = widget.transportMode;
    final markerColor = mode != null
        ? TransportColors.getColorByTransportMode(mode)
        : Colors.grey;

    for (final s in stops) {
      final point = _tryParseLatLngSafe(s.coord);
      if (point == null) {
        continue;
      }
      markers.add(
        Marker(
          point: point,
          width: 22,
          height: 22,
          child: GestureDetector(
            onTap: () => _showStopDetails(s),
            child: Container(
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Icon(
                  mode != null
                      ? getVehicleIconByTransportMode(mode)
                      : Icons.place,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return _stopMarkers = markers;
  }
}
