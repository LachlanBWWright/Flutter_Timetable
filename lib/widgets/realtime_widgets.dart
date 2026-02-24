import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/realtime_service.dart';
import '../utils/transport_display.dart';

/// Widget displaying realtime transport information
class RealtimeInfoWidget extends StatefulWidget {
  const RealtimeInfoWidget({super.key});

  @override
  State<RealtimeInfoWidget> createState() => _RealtimeInfoWidgetState();
}

class _RealtimeInfoWidgetState extends State<RealtimeInfoWidget> {
  Map<TransportMode, Map<String, dynamic>>? _statusSummary;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRealtimeStatus();
  }

  Future<void> _loadRealtimeStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final summary = await RealtimeService.getRealtimeStatusSummary();
    if (!mounted) return;
    setState(() {
      _statusSummary = summary;
      _isLoading = false;
    });
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              )
            else if (_statusSummary != null)
              ..._buildStatusList()
            else
              const Text('No data available'),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusList() {
    final summary = _statusSummary!;
    return summary.entries.map((entry) {
      final modeKey = entry.key;
      final data = entry.value;
      final vehicleCount = data['vehicles'] as int;
      final updateCount = data['updates'] as int;

      // modeKey is a TransportMode enum per service contract. Use it
      // directly for display and color. Keep a modeString for any
      // legacy string-based fallbacks (not expected here).
      final TransportMode parsedMode = modeKey;

      // Resolve display name: prefer typed TransportMode helper, otherwise
      // fall back to a generic formatted fallback.
      final displayName = getDisplayNameForTransportMode(parsedMode);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: (() {
            return TransportColors.getColorByTransportMode(parsedMode)
                .withValues(alpha: 0.1);
          })(),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: (() {
            return TransportColors.getColorByTransportMode(parsedMode)
                .withValues(alpha: 0.3);
          })()),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: TransportColors.getColorByTransportMode(parsedMode),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$vehicleCount vehicles • $updateCount updates',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (vehicleCount > 0 || updateCount > 0)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              )
            else
              const Icon(
                Icons.error_outline,
                color: Colors.orange,
                size: 20,
              ),
          ],
        ),
      );
    }).toList();
  }

  // Color selection is performed inline where feed keys or group keys are
  // available so that transport modes are always represented by the
  // `TransportMode` enum when possible.

  // _getDisplayName removed — display name resolution is inlined where needed
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

class _TransportPositionsWidgetState extends State<TransportPositionsWidget> {
  List<VehiclePosition> _positions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      FeedMessage? feed;
      if (widget.transportMode != null) {
        feed = await RealtimeService.getPositionsForTransportMode(
            widget.transportMode!);
      } else if (widget.mode != null) {
        feed = await RealtimeService.getPositionsForTransportMode(widget.mode!);
      } else {
        feed = null;
      }
      final positions = RealtimeService.extractVehiclePositions(feed);
      if (!mounted) return;
      setState(() {
        _positions = positions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              )
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
    return _positions.take(10).map((position) {
      final vehicle = position.vehicle;
      final trip = position.trip;
      final pos = position.position;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vehicle.hasId() ? 'Vehicle ${vehicle.id}' : 'Unknown Vehicle',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (trip.hasRouteId())
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (() {
                        final parsed = widget.mode;
                        if (parsed != null) {
                          return TransportColors.getColorByTransportMode(
                              parsed);
                        }
                        return Colors.grey;
                      })(),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            if (pos.hasLatitude() && pos.hasLongitude())
              Text(
                'Position: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            if (position.hasTimestamp())
              Text(
                'Updated: ${DateTime.fromMillisecondsSinceEpoch(position.timestamp.toInt() * 1000)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
}
