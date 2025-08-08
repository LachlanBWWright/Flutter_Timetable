import 'package:flutter/material.dart';
import '../constants/transport_colors.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/realtime_service.dart';

/// Widget displaying realtime transport information
class RealtimeInfoWidget extends StatefulWidget {
  const RealtimeInfoWidget({super.key});

  @override
  State<RealtimeInfoWidget> createState() => _RealtimeInfoWidgetState();
}

class _RealtimeInfoWidgetState extends State<RealtimeInfoWidget> {
  Map<String, dynamic>? _statusSummary;
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

    try {
      final summary = await RealtimeService.getRealtimeStatusSummary();
      setState(() {
        _statusSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
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
      final mode = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final vehicleCount = data['vehicles'] as int;
      final updateCount = data['updates'] as int;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: _getModeColor(mode).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: _getModeColor(mode).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getModeColor(mode),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDisplayName(mode),
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

  Color _getModeColor(String mode) {
    if (mode.contains('trains')) return TransportColors.train;
    if (mode.contains('metro')) return TransportColors.metro;
    if (mode.contains('buses')) return TransportColors.bus;
    if (mode.contains('lightrail')) return TransportColors.lightRail;
    if (mode.contains('ferries')) return TransportColors.ferry;
    return Colors.grey;
  }

  String _getDisplayName(String mode) {
    switch (mode) {
      case 'sydney_trains':
        return 'Sydney Trains';
      case 'nsw_trains':
        return 'NSW Trains';
      case 'metro':
        return 'Sydney Metro';
      case 'buses':
        return 'Buses';
      case 'lightrail_cbd_southeast':
        return 'Light Rail CBD & SE';
      case 'lightrail_innerwest':
        return 'Light Rail Inner West';
      case 'lightrail_newcastle':
        return 'Light Rail Newcastle';
      case 'lightrail_parramatta':
        return 'Light Rail Parramatta';
      case 'ferries_sydney':
        return 'Sydney Ferries';
      case 'ferries_mff':
        return 'Manly Fast Ferry';
      default:
        return mode
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : word)
            .join(' ');
    }
  }
}

/// Widget for displaying specific transport mode positions
class TransportPositionsWidget extends StatefulWidget {
  final String mode;
  final String displayName;

  const TransportPositionsWidget({
    super.key,
    required this.mode,
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
      final feed = await RealtimeService.getPositionsForMode(widget.mode);
      final positions = RealtimeService.extractVehiclePositions(feed);
      setState(() {
        _positions = positions;
        _isLoading = false;
      });
    } catch (e) {
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
                      color: TransportColors.getColorByMode(widget.mode),
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
