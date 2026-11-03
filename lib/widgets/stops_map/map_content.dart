part of '../stops_map_widget.dart';

extension _StopsMapContent on _StopsMapWidgetState {
  Widget _buildMapBody(Position? userLoc) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading stops: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStopsAndLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_stops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No ${widget.modeDisplayName.toLowerCase()} stops found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStopsAndLocation,
              child: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(-33.8688, 151.2093), // Sydney
            initialZoom: 10.0,
            minZoom: 5.0,
            maxZoom: 18.0,
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture) _cameraInteractionGeneration++;
              _scheduleViewportUpdate(camera);
            },
            onMapReady: () {
              // Mark map as ready and run any pending map action
              guardedSetState(() {
                _mapIsReady = true;
              });
              _updateViewport(_mapController.camera);
              _runPendingMapAction();
            },
          ),
          children: [
            if (widget.showTileLayer)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_timetable',
              ),
            if (userLoc != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(userLoc.latitude, userLoc.longitude),
                    width: 30.0,
                    height: 30.0,
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            if (_shouldShowMarkers())
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 120,
                  disableClusteringAtZoom: 16,
                  markers: _cachedMarkers,
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        color: _getModeColor(),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        // Zoom warning overlay for buses
        if (_showZoomWarning)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.orange.shade100,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Zoom In to View Stops',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Too many bus stops to display. Please zoom in to see stops.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // In embedded mode, show FABs inside the map Stack
        if (widget.embedded)
          Positioned(bottom: 16, right: 16, child: _buildFABs(userLoc)),
      ],
    );
  }
}
