part of '../realtime_map_widget.dart';

extension _RealtimeMapContent on _RealtimeMapWidgetState {
  Widget _buildMapContent(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: 11.0,
            minZoom: 8.0,
            maxZoom: 18.0,
            onMapReady: () {
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
        if (widget.showVehicleCount)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_vehicles.length} vehicles',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
