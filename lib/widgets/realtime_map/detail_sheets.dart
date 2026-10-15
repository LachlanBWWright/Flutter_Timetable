part of '../realtime_map_widget.dart';

extension _RealtimeMapDetailSheets on _RealtimeMapWidgetState {
  void _showStopDetails(Stop stop) {
    final latitude = _coordValueAt(stop.coord, 0);
    final longitude = _coordValueAt(stop.coord, 1);
    showModalBottomSheet(
      context: context,
      builder: (context) => ValueListenableBuilder<bool>(
        valueListenable: DebugService.showDebugData,
        builder: (context, showDebug, _) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stop.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (showDebug) _buildInfoRow('Stop ID', stop.id),
              if (stop.disassembledName case final name?)
                _buildInfoRow('Name', name),
              if (stop.arrivalTimePlanned case final arrive?)
                _buildInfoRow('Arrive (planned)', arrive),
              if (stop.departureTimePlanned case final depart?)
                _buildInfoRow('Depart (planned)', depart),
              if (showDebug && latitude != null && longitude != null)
                _buildInfoRow(
                  'Coords',
                  '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _closeBottomSheet,
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVehicleInfo(VehiclePosition vehicle) {
    final trip = vehicle.trip;
    final vehicleDesc = vehicle.vehicle;
    final position = vehicle.position;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (vehicleDesc.hasId())
              _buildInfoRow('Vehicle ID', vehicleDesc.id),
            if (trip.hasRouteId()) _buildInfoRow('Route', trip.routeId),
            if (trip.hasTripId()) _buildInfoRow('Trip ID', trip.tripId),
            if (position.hasLatitude() && position.hasLongitude())
              _buildInfoRow(
                'Position',
                '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
              ),
            if (position.hasSpeed())
              _buildInfoRow(
                'Speed',
                '${position.speed.toStringAsFixed(1)} m/s',
              ),
            if (position.hasBearing())
              _buildInfoRow(
                'Bearing',
                '${position.bearing.toStringAsFixed(0)}°',
              ),
            if (vehicle.hasTimestamp())
              _buildInfoRow(
                'Last Update',
                DateTime.fromMillisecondsSinceEpoch(
                  vehicle.timestamp.toInt() * 1000,
                ).toString(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
