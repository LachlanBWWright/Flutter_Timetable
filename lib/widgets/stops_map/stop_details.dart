part of '../stops_map_widget.dart';

extension _StopsMapDetails on _StopsMapWidgetState {
  void _showStopDetails(Stop stop) {
    final userLoc = _userLocation;
    final modeColor = _getModeColor();
    final modeIcon = _getModeIcon();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ValueListenableBuilder<bool>(
        valueListenable: DebugService.showDebugData,
        builder: (context, showDebug, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color accent bar at top
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: modeColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(modeIcon, color: modeColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stop.stopName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (showDebug) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Stop ID: ${stop.stopId}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (stop.platformCode?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Platform: ${stop.platformCode}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (userLoc != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Distance: ${LocationService.calculateDistance(userLoc.latitude, userLoc.longitude, stop.stopLat, stop.stopLon).toStringAsFixed(2)} km',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (showDebug) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Coordinates: ${stop.stopLat.toStringAsFixed(6)}, ${stop.stopLon.toStringAsFixed(6)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    if (stop.parentStation != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Parent Station: ${stop.parentStation}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: modeColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _selectStop(stop);
                        _safePop();
                        if (!widget.embedded) {
                          // Also close the map page when not embedded
                          _safePop();
                        } else {
                          // In embedded mode notify the parent to dismiss the map view
                          _closeEmbeddedMap();
                        }
                      },
                      child: const Text('Select Stop'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
