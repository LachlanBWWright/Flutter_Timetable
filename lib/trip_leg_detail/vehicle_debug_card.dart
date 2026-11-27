part of '../trip_leg_detail_screen.dart';

/// Builds the vehicle diagnostics list and its filtering status.
extension _VehicleDebugCard on _TripLegDetailScreenState {
  Widget _buildVehicleDebugCard(Leg leg, String? transportId, Color modeColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Vehicle debug data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Open vehicle debug browser',
                      onPressed: () => _openVehicleDebugBrowser(leg),
                      icon: const Icon(Icons.manage_search, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Copy vehicle debug to clipboard',
                      onPressed: () async {
                        final lines = _displayedVehicles
                            .map((v) {
                              final id = v.vehicle.hasId()
                                  ? v.vehicle.id
                                  : 'N/A';
                              final tripId = v.trip.hasTripId()
                                  ? v.trip.tripId
                                  : 'N/A';
                              final routeId = v.trip.hasRouteId()
                                  ? v.trip.routeId
                                  : 'N/A';
                              final pos =
                                  v.hasPosition() &&
                                      v.position.hasLatitude() &&
                                      v.position.hasLongitude()
                                  ? '${v.position.latitude.toStringAsFixed(6)}, ${v.position.longitude.toStringAsFixed(6)}'
                                  : 'N/A';
                              final ts = v.hasTimestamp()
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      v.timestamp.toInt() * 1000,
                                    ).toIso8601String()
                                  : 'N/A';
                              return 'id=$id trip=$tripId route=$routeId pos=$pos ts=$ts';
                            })
                            .join('\n');

                        await _copyDebugText(
                          text: lines,
                          successMessage:
                              'Copied vehicle debug data to clipboard',
                          failureMessage: 'Failed to copy vehicle debug data',
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Showing ${_displayedVehicles.length} of ${_vehicles.length} realtime vehicles (sorted alphabetically):',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            if (_vehicleBreakdown.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _vehicleBreakdown.entries
                    .map(
                      (e) => Chip(
                        label: Text('${e.key}: ${e.value}'),
                        backgroundColor: Colors.grey.shade100,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 8),
            if (transportId == null || transportId.isEmpty)
              const ListTile(
                leading: Icon(Icons.route, color: Colors.grey),
                title: Text('Realtime tracking unavailable for this leg'),
              )
            else if (_isLoadingVehicles)
              const Center(child: CircularProgressIndicator())
            else if (_vehicles.isEmpty)
              const ListTile(
                leading: Icon(Icons.location_off, color: Colors.grey),
                title: Text('No vehicles found'),
              )
            else if (_displayedVehicles.isEmpty)
              const ListTile(
                leading: Icon(Icons.filter_alt_off, color: Colors.grey),
                title: Text('No vehicles match the current trip/route filter'),
              )
            else
              SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: _displayedVehicles.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final v = _itemAt(_displayedVehicles, index);
                    if (v == null) {
                      return const SizedBox.shrink();
                    }
                    final id = v.vehicle.hasId() ? v.vehicle.id : 'N/A';
                    final tripId = v.trip.hasTripId() ? v.trip.tripId : 'N/A';
                    final routeId = v.trip.hasRouteId()
                        ? v.trip.routeId
                        : 'N/A';
                    final pos =
                        v.hasPosition() &&
                            v.position.hasLatitude() &&
                            v.position.hasLongitude()
                        ? '${v.position.latitude.toStringAsFixed(6)}, ${v.position.longitude.toStringAsFixed(6)}'
                        : 'N/A';
                    final routeMatch =
                        v.trip.hasRouteId() && v.trip.routeId == transportId;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: routeMatch ? Colors.orange : modeColor,
                        foregroundColor: getContrastingForeground(modeColor),
                        child: Text(
                          id == 'N/A' ? '?' : id.substring(0, 1).toUpperCase(),
                        ),
                      ),
                      title: Text(id),
                      subtitle: Text(
                        'Trip: $tripId • Route: $routeId • Pos: $pos',
                      ),
                      dense: true,
                      onTap: () => _openVehicleDebugPage(leg, v),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (routeMatch)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.orange,
                              size: 18,
                            ),
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_new, size: 18),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
