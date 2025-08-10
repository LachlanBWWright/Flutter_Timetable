import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/transport_colors.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/realtime_service.dart';

/// Widget for displaying GTFS realtime vehicle positions on a map
class RealtimeMapWidget extends StatefulWidget {
  final String? mode;
  final String? routeFilter;

  const RealtimeMapWidget({
    super.key,
    this.mode,
    this.routeFilter,
  });

  @override
  State<RealtimeMapWidget> createState() => _RealtimeMapWidgetState();
}

class _RealtimeMapWidgetState extends State<RealtimeMapWidget> {
  final MapController _mapController = MapController();
  List<VehiclePosition> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  // Sydney CBD as default center
  static const LatLng _sydneyCenter = LatLng(-33.8688, 151.2093);

  @override
  void initState() {
    super.initState();
    _loadVehiclePositions();
  }

  Future<void> _loadVehiclePositions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allPositions = await RealtimeService.getAllRealtimePositions();
      final vehicles = <VehiclePosition>[];

      for (final entry in allPositions.entries) {
        if (widget.mode != null && !entry.key.contains(widget.mode!)) {
          continue;
        }

        final feedMessage = entry.value;
        if (feedMessage != null) {
          final vehiclePositions =
              RealtimeService.extractVehiclePositions(feedMessage);
          vehicles.addAll(vehiclePositions);
        }
      }

      // Filter by route if specified
      if (widget.routeFilter != null) {
        vehicles.removeWhere((vehicle) =>
            !vehicle.trip.hasRouteId() ||
            !vehicle.trip.routeId.contains(widget.routeFilter!));
      }

      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Marker> _buildVehicleMarkers() {
    return _vehicles
        .where((vehicle) =>
            vehicle.hasPosition() &&
            vehicle.position.hasLatitude() &&
            vehicle.position.hasLongitude())
        .map((vehicle) {
      final position = vehicle.position;
      final trip = vehicle.trip;

      // Determine color based on route or mode
      Color markerColor = TransportColors.bus; // default
      if (trip.hasRouteId()) {
        markerColor = TransportColors.getColorByLine(trip.routeId);
        if (markerColor == Colors.grey) {
          // Fallback to mode-based color
          if (trip.routeId.startsWith('T')) {
            markerColor = TransportColors.train;
          } else if (trip.routeId.startsWith('M')) {
            markerColor = TransportColors.metro;
          } else if (trip.routeId.startsWith('L')) {
            markerColor = TransportColors.lightRail;
          } else if (trip.routeId.startsWith('F')) {
            markerColor = TransportColors.ferry;
          }
        }
      }

      return Marker(
        point: LatLng(position.latitude, position.longitude),
        width: 32,
        height: 32,
        child: GestureDetector(
          onTap: () => _showVehicleInfo(vehicle),
          child: Container(
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getVehicleIcon(trip.routeId),
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  IconData _getVehicleIcon(String routeId) {
    if (routeId.startsWith('T')) return Icons.train;
    if (routeId.startsWith('M')) return Icons.subway;
    if (routeId.startsWith('L')) return Icons.tram;
    if (routeId.startsWith('F')) return Icons.directions_boat;
    return Icons.directions_bus;
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
              _buildInfoRow('Position',
                  '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'),
            if (position.hasSpeed())
              _buildInfoRow(
                  'Speed', '${position.speed.toStringAsFixed(1)} m/s'),
            if (position.hasBearing())
              _buildInfoRow(
                  'Bearing', '${position.bearing.toStringAsFixed(0)}°'),
            if (vehicle.hasTimestamp())
              _buildInfoRow(
                  'Last Update',
                  DateTime.fromMillisecondsSinceEpoch(
                          vehicle.timestamp.toInt() * 1000)
                      .toString()),
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.mode != null ? '${widget.mode} Map' : 'Realtime Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadVehiclePositions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadVehiclePositions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: _sydneyCenter,
                        initialZoom: 11.0,
                        minZoom: 8.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.lbww.flutter_timetable',
                        ),
                        MarkerLayer(
                          markers: _buildVehicleMarkers(),
                        ),
                      ],
                    ),
                    // Vehicle count overlay
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
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
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Fit map to show all vehicles
          if (_vehicles.isNotEmpty) {
            final bounds = _calculateBounds(_vehicles);
            _mapController.fitCamera(CameraFit.bounds(
                bounds: bounds, padding: const EdgeInsets.all(50)));
          } else {
            _mapController.move(_sydneyCenter, 11.0);
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  LatLngBounds _calculateBounds(List<VehiclePosition> vehicles) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final vehicle in vehicles) {
      if (vehicle.hasPosition() &&
          vehicle.position.hasLatitude() &&
          vehicle.position.hasLongitude()) {
        final lat = vehicle.position.latitude;
        final lng = vehicle.position.longitude;

        minLat = lat < minLat ? lat : minLat;
        maxLat = lat > maxLat ? lat : maxLat;
        minLng = lng < minLng ? lng : minLng;
        maxLng = lng > maxLng ? lng : maxLng;
      }
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }
}
