part of '../stops_map_widget.dart';

extension _StopsMapControls on _StopsMapWidgetState {
  Widget _buildFABs(Position? userLoc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.embedded)
          FloatingActionButton(
            heroTag: 'close_map',
            mini: true,
            onPressed: widget.onClose,
            child: const Icon(Icons.list),
          ),
        if (widget.embedded) const SizedBox(height: 8),
        if (userLoc != null)
          FloatingActionButton(
            heroTag: 'location',
            mini: true,
            onPressed: () {
              _cameraInteractionGeneration++;
              _mapController.move(
                LatLng(userLoc.latitude, userLoc.longitude),
                15.0,
              );
            },
            child: const Icon(Icons.my_location),
          ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'fit_stops',
          mini: true,
          onPressed: () {
            _cameraInteractionGeneration++;
            _centerMapOnStops();
          },
          child: const Icon(Icons.center_focus_strong),
        ),
      ],
    );
  }
}
