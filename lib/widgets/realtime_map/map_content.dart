part of '../realtime_map_widget.dart';

extension _RealtimeMapContent on _RealtimeMapWidgetState {
  Widget _buildMapContent(BuildContext context) {
    final count = _vehicles.length;
    final mode = widget.transportMode ?? widget.mode;
    final singular = switch (mode) {
      TransportMode.metro => 'metro train',
      TransportMode.lightrail => 'light rail vehicle',
      _ => mode?.displayName.toLowerCase() ?? 'vehicle',
    };
    final plural = switch (mode) {
      TransportMode.bus => 'buses',
      TransportMode.ferry => 'ferries',
      _ => '${singular}s',
    };
    final countLabel = count == 0 && _metadata.isUnavailable
        ? 'Live positions unavailable'
        : count == 0
        ? 'No $plural${_usesViewportQuery ? ' in this area' : ' reported'}'
        : '$count ${count == 1 ? singular : plural}';
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: 11.0,
            minZoom: 8.0,
            maxZoom: 18.0,
            onPositionChanged: (_, hasGesture) {
              if (hasGesture) _onViewportChanged();
            },
            onMapReady: () {
              _mapReady = true;
              _onViewportChanged();
              final fit = _pendingFit;
              final center = _pendingCenter;
              _pendingFit = null;
              _pendingCenter = null;
              if (fit != null) {
                _mapController.fitCamera(fit);
              } else if (center != null) {
                _mapController.move(center, 11.0);
              }
            },
          ),
          children: [
            if (widget.showTileLayer)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lbww.flutter_timetable',
              ),
            // Draw the route polyline if available
            PolylineLayer(polylines: _buildRoutePolylines()),
            // Show stop markers (if the leg has stops)
            MarkerLayer(markers: _buildStopMarkers()),
            // Show vehicle markers above stops so they remain visible
            MarkerLayer(markers: _buildVehicleMarkers()),
          ],
        ),
        if (widget.showVehicleCount &&
            (!_isLoading || count > 0) &&
            (widget.vehicleId == null || count > 0 || _metadata.isUnavailable))
          PositionedDirectional(
            top: 16,
            start: 16,
            end: 16,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.inverseSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  countLabel,
                  style: TextStyle(
                    color: colors.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        // Show an overlay if a vehicleId was requested but no vehicle
        // (by vehicle id or fallback route id) was found in the latest feed.
        if (!_isLoading &&
            !_metadata.isUnavailable &&
            widget.vehicleId != null &&
            _vehicles.isEmpty)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                vehicleNotFoundMessage(widget.vehicleId ?? ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
