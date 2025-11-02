import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/transport_colors.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/realtime_service.dart';
import '../services/transport_api_service.dart';

/// Widget for displaying GTFS realtime vehicle positions on a map
class RealtimeMapWidget extends StatefulWidget {
  final String? mode;
  final String? routeFilter;
  final Leg? leg;

  const RealtimeMapWidget({super.key, this.mode, this.routeFilter, this.leg});

  @override
  State<RealtimeMapWidget> createState() => _RealtimeMapWidgetState();
}

// Small helper struct to keep a VehiclePosition together with its inferred mode
class _VehicleWithMode {
  final VehiclePosition vehicle;
  final String mode;

  _VehicleWithMode(this.vehicle, this.mode);
}

class _RealtimeMapWidgetState extends State<RealtimeMapWidget> {
  final MapController _mapController = MapController();
  // Store vehicles with an associated mode so markers can use mode-specific
  // colors and icons.
  List<_VehicleWithMode> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  // Available modes (keys) and whether they're enabled in the UI filter.
  static const List<String> _allModes = [
    'train',
    'metro',
    'bus',
    'ferry',
    'lightrail',
    'coach',
    'unknown',
  ];

  late Map<String, bool> _modeEnabled;

  // Sydney CBD as default center
  late LatLng _mapCenter;

  @override
  @override
  void initState() {
    super.initState();
    // If a leg is provided, use its origin as the map center
    if (widget.leg != null &&
        widget.leg!.origin.coord != null &&
        widget.leg!.origin.coord!.length == 2) {
      _mapCenter =
          LatLng(widget.leg!.origin.coord![0], widget.leg!.origin.coord![1]);
    } else {
      _mapCenter = const LatLng(-33.8688, 151.2093); // Sydney CBD default
    }
    // Enable all modes by default (initialize before loading)
    _modeEnabled = {for (var m in _allModes) m: true};
    _loadVehiclePositions();
  }

  Future<void> _loadVehiclePositions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allPositions = await RealtimeService.getAllRealtimePositions();
      final vehicles = <_VehicleWithMode>[];

      for (final entry in allPositions.entries) {
        if (widget.mode != null && !entry.key.contains(widget.mode!)) {
          continue;
        }

        final feedMessage = entry.value;
        if (feedMessage != null) {
          final vehiclePositions =
              RealtimeService.extractVehiclePositions(feedMessage);
          // Determine a mode for this feed key so we can colour and icon each marker
          final feedMode = _modeFromFeedKey(entry.key);
          vehicles.addAll(
              vehiclePositions.map((v) => _VehicleWithMode(v, feedMode)));
        }
      }

      // Filter by route if specified
      if (widget.routeFilter != null) {
        // Only remove vehicles that have a routeId and do not match the filter.
        // Do not drop vehicles that lack routeId information.
        vehicles.removeWhere((vw) =>
            vw.vehicle.trip.hasRouteId() &&
            !vw.vehicle.trip.routeId.contains(widget.routeFilter!));
      }

      // If a leg is provided, filter vehicles to those matching the leg's route id
      if (widget.leg != null &&
          widget.leg!.transportation != null &&
          widget.leg!.transportation!.id != null) {
        final legRouteId = widget.leg!.transportation!.id!;
        // Only remove vehicles that have a routeId and it doesn't match the leg.
        vehicles.removeWhere((vw) =>
            vw.vehicle.trip.hasRouteId() &&
            vw.vehicle.trip.routeId != legRouteId);
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
        .where((vw) =>
            vw.vehicle.hasPosition() &&
            vw.vehicle.position.hasLatitude() &&
            vw.vehicle.position.hasLongitude() &&
            // Only include vehicles whose mode is enabled in the filter
            (_modeEnabled[vw.mode] ?? (_modeEnabled['unknown'] ?? true)))
        .map((vw) {
      final vehicle = vw.vehicle;
      final position = vehicle.position;
      final mode = vw.mode;

      // Use mode-based color and icon mapping
      Color markerColor = TransportColors.getColorByMode(mode);

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
              _getVehicleIconByMode(mode),
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _openModeFilterSheet(BuildContext context) async {
    // Compute vehicle counts per mode from the current loaded vehicles so we
    // can show counts next to each mode in the toggle list.
    final counts = <String, int>{};
    for (final m in _allModes) counts[m] = 0;
    for (final vw in _vehicles) {
      counts[vw.mode] = (counts[vw.mode] ?? 0) + 1;
    }

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          // Constrain the bottom sheet height and make contents scrollable so
          // a long list of modes doesn't overflow on smaller screens.
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Allow the sheet to grow but cap at 70% of the screen height
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Show modes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ..._allModes.map((mode) {
                      final display = _modeDisplayName(mode);
                      final count = counts[mode] ?? 0;
                      return CheckboxListTile(
                        value: _modeEnabled[mode] ?? true,
                        title: Text('$display (${count.toString()})'),
                        onChanged: (v) {
                          setSheetState(() => _modeEnabled[mode] = v ?? false);
                          setState(() {});
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  String _modeDisplayName(String mode) {
    switch (mode) {
      case 'train':
        return 'Trains';
      case 'metro':
        return 'Metro';
      case 'bus':
        return 'Buses';
      case 'ferry':
        return 'Ferries';
      case 'lightrail':
        return 'Light Rail';
      case 'coach':
        return 'Coach';
      case 'unknown':
      default:
        return mode[0].toUpperCase() + mode.substring(1);
    }
  }

  // Infer a simple mode string from the feed key used in RealtimeService
  String _modeFromFeedKey(String feedKey) {
    final k = feedKey.toLowerCase();
    if (k.contains('train')) return 'train';
    if (k.contains('metro')) return 'metro';
    if (k.contains('bus')) return 'bus';
    if (k.contains('ferry') || k.contains('ferries')) return 'ferry';
    if (k.contains('lightrail')) return 'lightrail';
    if (k.contains('coach')) return 'coach';
    return 'unknown';
  }

  IconData _getVehicleIconByMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'train':
        return Icons.train;
      case 'metro':
        return Icons.subway;
      case 'lightrail':
      case 'light rail':
        return Icons.tram;
      case 'ferry':
        return Icons.directions_boat;
      case 'coach':
        return Icons.airline_seat_recline_normal;
      case 'bus':
        return Icons.directions_bus;
      case 'unknown':
      default:
        return Icons.help_outline;
    }
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
        title: Text(widget.mode != null
            ? '${widget.mode} Map'
            : widget.leg != null
                ? 'Trip Leg Map'
                : 'Realtime Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadVehiclePositions,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter modes',
            onPressed: () => _openModeFilterSheet(context),
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
                      options: MapOptions(
                        initialCenter: _mapCenter,
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
          // Fit map to show all vehicles or leg
          if (_vehicles.isNotEmpty) {
            final bounds =
                _calculateBounds(_vehicles.map((vw) => vw.vehicle).toList());
            _mapController.fitCamera(CameraFit.bounds(
                bounds: bounds, padding: const EdgeInsets.all(50)));
          } else if (widget.leg != null &&
              widget.leg!.origin.coord != null &&
              widget.leg!.destination.coord != null) {
            final bounds = LatLngBounds(
              LatLng(
                  widget.leg!.origin.coord![0], widget.leg!.origin.coord![1]),
              LatLng(widget.leg!.destination.coord![0],
                  widget.leg!.destination.coord![1]),
            );
            _mapController.fitCamera(CameraFit.bounds(
                bounds: bounds, padding: const EdgeInsets.all(50)));
          } else {
            _mapController.move(_mapCenter, 11.0);
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
