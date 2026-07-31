import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/realtime_service.dart';
import '../transit/transit.dart';
import '../utils/guarded_state.dart';

/// Widget displaying realtime transport information
class RealtimeInfoWidget extends StatefulWidget {
  const RealtimeInfoWidget({super.key});

  @override
  State<RealtimeInfoWidget> createState() => _RealtimeInfoWidgetState();
}

class _RealtimeInfoWidgetState extends State<RealtimeInfoWidget>
    with GuardedState<RealtimeInfoWidget> {
  int _vehicleCount = 0;
  int _updateCount = 0;
  int _alertCount = 0;
  String? _providerLabel;
  String? _unavailableMessage;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRealtimeStatus();
  }

  Future<void> _loadRealtimeStatus() async {
    guardedSetState(() {
      _isLoading = true;
      _error = null;
    });

    await runAsyncGuarded(
      () async {
        final services = AppTransitContext.instance.currentServices;
        final realtime = services.realtime;
        if (realtime == null) {
          guardedSetState(() {
            _providerLabel = services.attribution.name;
            _unavailableMessage =
                'Realtime is unavailable for ${services.region.label}.';
            _vehicleCount = 0;
            _updateCount = 0;
            _alertCount = 0;
            _isLoading = false;
          });
          return;
        }
        final vehicles = await realtime.getVehiclePositions(
          const RealtimeRequest(),
        );
        final updates = await realtime.getTripUpdates(const RealtimeRequest());
        final alerts = await realtime.getAlerts(const RealtimeRequest());
        guardedSetState(() {
          _providerLabel = services.attribution.name;
          _unavailableMessage = null;
          _vehicleCount = vehicles.items.length;
          _updateCount = updates.items.length;
          _alertCount = alerts.items.length;
          _isLoading = false;
        });
      },
      onError: (error, _) {
        guardedSetState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Realtime Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadRealtimeStatus,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red))
            else if (_unavailableMessage != null)
              Text(
                _unavailableMessage!,
                style: const TextStyle(color: Colors.grey),
              )
            else
              ..._buildStatusList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusList() {
    return [
      if (_providerLabel != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _providerLabel!,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      _buildMetricTile(
        icon: Icons.directions_bus,
        label: 'Tracked vehicles',
        count: _vehicleCount,
        color: TransportColors.getColorByTransportMode(TransportMode.bus),
      ),
      _buildMetricTile(
        icon: Icons.update,
        label: 'Trip updates',
        count: _updateCount,
        color: TransportColors.getColorByTransportMode(TransportMode.train),
      ),
      _buildMetricTile(
        icon: Icons.warning_amber_rounded,
        label: 'Alerts',
        count: _alertCount,
        color: Colors.orange,
      ),
    ];
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying specific transport mode positions
class TransportPositionsWidget extends StatefulWidget {
  final TransportMode? mode;
  final TransportMode? transportMode;
  final String displayName;

  const TransportPositionsWidget({
    super.key,
    this.mode,
    this.transportMode,
    required this.displayName,
  });

  @override
  State<TransportPositionsWidget> createState() =>
      _TransportPositionsWidgetState();
}

class _TransportPositionsWidgetState extends State<TransportPositionsWidget>
    with GuardedState<TransportPositionsWidget> {
  List<VehiclePosition> _positions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    guardedSetState(() {
      _isLoading = true;
      _error = null;
    });

    await runAsyncGuarded(
      () async {
        FeedMessage? feed;
        final transportMode = widget.transportMode;
        final mode = widget.mode;
        if (transportMode != null) {
          feed = await RealtimeService.getPositionsForTransportMode(
            transportMode,
          );
        } else if (mode != null) {
          feed = await RealtimeService.getPositionsForTransportMode(mode);
        } else {
          feed = null;
        }
        final positions = RealtimeService.extractVehiclePositions(feed);
        guardedSetState(() {
          _positions = positions;
          _isLoading = false;
        });
      },
      onError: (error, _) {
        guardedSetState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.displayName} Positions',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadPositions,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red))
            else if (_positions.isEmpty)
              const Text('No vehicles currently tracked')
            else
              ..._buildPositionsList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPositionsList() {
    final mode = widget.mode;
    return _positions
        .take(10)
        .map<Widget>((position) {
          final vehicle = position.vehicle;
          final trip = position.trip;
          final pos = position.position;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vehicle.hasId()
                          ? 'Vehicle ${vehicle.id}'
                          : 'Unknown Vehicle',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (trip.hasRouteId())
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: mode != null
                              ? TransportColors.getColorByTransportMode(mode)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          trip.routeId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (trip.hasTripId())
                  Text(
                    'Trip: ${trip.tripId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                if (pos.hasLatitude() && pos.hasLongitude())
                  Text(
                    'Position: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                if (position.hasTimestamp())
                  Text(
                    'Updated: ${DateTime.fromMillisecondsSinceEpoch(position.timestamp.toInt() * 1000)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          );
        })
        .toList(growable: false);
  }
}
