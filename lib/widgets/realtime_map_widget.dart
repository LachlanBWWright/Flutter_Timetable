import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/realtime_service.dart';
import '../services/transport_api_service.dart';
import 'realtime_map_helpers.dart';

/// Widget for displaying GTFS realtime vehicle positions on a map
class RealtimeMapWidget extends StatefulWidget {
  final TransportMode? mode;
  final TransportMode? transportMode;
  final String? routeFilter;
  final Leg? leg;

  const RealtimeMapWidget({
    super.key,
    this.mode,
    this.transportMode,
    this.routeFilter,
    this.leg,
  });

  @override
  State<RealtimeMapWidget> createState() => _RealtimeMapWidgetState();
}

// Small helper struct to keep a VehiclePosition together with its inferred mode
class _VehicleWithMode {
  final VehiclePosition vehicle;
  final TransportMode? mode;

  _VehicleWithMode(this.vehicle, this.mode);
}

class _RealtimeMapWidgetState extends State<RealtimeMapWidget> {
  final MapController _mapController = MapController();
  // Store vehicles with an associated mode so markers can use mode-specific
  // colors and icons.
  List<_VehicleWithMode> _vehicles = [];
  bool _isLoading = false;
  String? _error;
  // Map readiness and pending actions
  bool _mapIsReady = false;
  CameraFit? _pendingFit;
  LatLng? _pendingCenter;

  // Available transport modes and whether they're enabled in the UI filter.
  static const List<TransportMode> _allModes = [
    TransportMode.train,
    TransportMode.metro,
    TransportMode.bus,
    TransportMode.ferry,
    TransportMode.lightrail,
  ];

  late Map<TransportMode, bool> _modeEnabled;

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
        // entry.key is now a TransportMode (per RealtimeService changes).
        final feedMode = entry.key;

        // If a TransportMode filter was provided, prefer that and compare directly.
        if (widget.transportMode != null) {
          if (feedMode != widget.transportMode) continue;
        } else if (widget.mode != null) {
          final requested = widget.mode!;
          if (feedMode != requested) continue;
        }

        final feedMessage = entry.value;
        if (feedMessage != null) {
          final vehiclePositions =
              RealtimeService.extractVehiclePositions(feedMessage);
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
            (() {
              final parsed = vw.mode;
              if (parsed != null) return _modeEnabled[parsed] ?? true;
              return true;
            })())
        .map((vw) {
      final vehicle = vw.vehicle;
      final position = vehicle.position;
      final mode = vw.mode;

      // Use mode-based color and icon mapping. Prefer typed API when possible.
      final Color markerColor = mode != null
          ? TransportColors.getColorByTransportMode(mode)
          : Colors.grey;

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
              getVehicleIconByTransportMode(mode),
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _openModeFilterSheet(BuildContext context) async {
    // Compute vehicle counts per transport mode from the current loaded
    // vehicles so we can show counts next to each mode in the toggle list.
    final counts = <TransportMode, int>{};
    for (final m in _allModes) {
      counts[m] = 0;
    }
    for (final vw in _vehicles) {
      final parsed = vw.mode;
      if (parsed != null) counts[parsed] = (counts[parsed] ?? 0) + 1;
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
                      final display = modeDisplayNameForTransportMode(mode);
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

  // Helper functions moved to `realtime_map_helpers.dart`.

  // Non-nullable overload removed; use the nullable-accepting
  // _getVehicleIconByTransportMode(TransportMode?) instead.

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
                        onMapReady: () {
                          setState(() {
                            _mapIsReady = true;
                          });
                          if (_pendingFit != null) {
                            _mapController.fitCamera(_pendingFit!);
                            _pendingFit = null;
                          } else if (_pendingCenter != null) {
                            _mapController.move(_pendingCenter!, 11.0);
                            _pendingCenter = null;
                          }
                        },
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
          // Fit map to show all vehicles or leg. If the map isn't ready,
          // store the intent and apply when onMapReady fires.
          if (_vehicles.isNotEmpty) {
            final bounds =
                _calculateBounds(_vehicles.map((vw) => vw.vehicle).toList());
            final fit = CameraFit.bounds(
                bounds: bounds, padding: const EdgeInsets.all(50));
            if (_mapIsReady) {
              _mapController.fitCamera(fit);
            } else {
              _pendingFit = fit;
            }
          } else if (widget.leg != null &&
              widget.leg!.origin.coord != null &&
              widget.leg!.destination.coord != null) {
            final bounds = LatLngBounds(
              LatLng(
                  widget.leg!.origin.coord![0], widget.leg!.origin.coord![1]),
              LatLng(widget.leg!.destination.coord![0],
                  widget.leg!.destination.coord![1]),
            );
            final fit = CameraFit.bounds(
                bounds: bounds, padding: const EdgeInsets.all(50));
            if (_mapIsReady) {
              _mapController.fitCamera(fit);
            } else {
              _pendingFit = fit;
            }
          } else {
            if (_mapIsReady) {
              _mapController.move(_mapCenter, 11.0);
            } else {
              _pendingCenter = _mapCenter;
            }
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
