import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../logs/logger.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/debug_service.dart';
import '../services/realtime_service.dart';
import '../services/transport_api_service.dart';
import 'realtime_map_helpers.dart';

/// Widget for displaying GTFS realtime vehicle positions on a map
class RealtimeMapWidget extends StatefulWidget {
  final TransportMode? mode;
  final TransportMode? transportMode;
  final String? routeFilter;
  final Leg? leg;

  /// Other legs of the same trip to render as deemphasized polylines.
  final List<Leg>? additionalLegs;

  /// If true, attempt to filter vehicles to only those matching the trip ids
  /// for this trip/leg (fall back to route filtering when no trip ids are
  /// available). When false, the map shows all vehicles (diagnostic mode).
  final bool filterByLegTrip;

  /// Trip ids (if known) to match vehicles against when `filterByLegTrip` is true.
  final Set<String>? tripIds;

  /// Optional exact vehicle id filter. If provided, only the vehicle whose
  /// vehicle.id equals this value will be shown on the map.
  final String? vehicleId;

  /// Optional override function to fetch the realtime positions for the map.
  /// This allows tests to provide a predictable feed without hitting real
  /// network providers. If omitted, the widget uses [RealtimeService.getAllRealtimePositions].
  final Future<Map<TransportMode, FeedMessage?>> Function()? getPositions;

  /// Optional override to fetch aggregated vehicle positions + breakdown.
  /// Use this to include all partitioned feeds (region buses, ferries, lightrail)
  /// and facilitate tests.
  final Future<Map<String, dynamic>> Function()? getAllVehiclesAggregated;

  /// Whether to show the small vehicle count overlay in the top-right.
  /// Defaults to true; set false for embedded maps where it is redundant.
  final bool showVehicleCount;

  const RealtimeMapWidget({
    super.key,
    this.mode,
    this.transportMode,
    this.routeFilter,
    this.leg,
    this.additionalLegs,
    this.filterByLegTrip = false,
    this.tripIds,
    this.vehicleId,
    this.getPositions,
    this.getAllVehiclesAggregated,
    this.showVehicleCount = true,
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
  // map readiness flag removed (not required for current behaviour)
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
  void initState() {
    super.initState();
    // Enable all modes by default (initialize before loading)
    _modeEnabled = {for (var m in _allModes) m: true};

    final leg = widget.leg;
    if (leg != null) {
      // Prefer fitting camera to show all leg stops; fall back to leg origin.
      final points = _legPoints(leg);
      if (points.length >= 2) {
        _pendingFit = CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(50.0),
        );
        // Use the midpoint as the default center in case the fit is delayed.
        _mapCenter = points[points.length ~/ 2];
      } else {
        final legOriginCoord = leg.origin.coord;
        if (legOriginCoord != null && legOriginCoord.length == 2) {
          _mapCenter = LatLng(legOriginCoord[0], legOriginCoord[1]);
        } else {
          _mapCenter = const LatLng(-33.8688, 151.2093); // Sydney CBD default
        }
      }
    } else {
      _mapCenter = const LatLng(-33.8688, 151.2093); // Sydney CBD default
    }

    _loadVehiclePositions();
  }

  // Build polyline(s) for leg stops if provided (in order)
  List<Polyline> _buildRoutePolylines() {
    final polylines = <Polyline>[];

    // Draw additional (other) legs first so they appear below the active leg.
    for (final otherLeg in widget.additionalLegs ?? []) {
      final points = _legPoints(otherLeg);
      if (points.length >= 2) {
        polylines.add(
          Polyline(
            points: points,
            strokeWidth: 2.0,
            color: Colors.grey.withValues(alpha: 0.45),
          ),
        );
      }
    }

    final leg = widget.leg;
    if (leg == null) return polylines;

    final points = _legPoints(leg);
    if (points.length < 2) return polylines;

    final mode = widget.transportMode;
    if (mode == null) {
      // Walk or unknown — dashed grey line
      polylines.add(
        Polyline(
          points: points,
          strokeWidth: 3.0,
          color: Colors.grey.shade600,
          pattern: StrokePattern.dashed(segments: const [12, 6]),
        ),
      );
    } else {
      polylines.add(
        Polyline(
          points: points,
          strokeWidth: 4.0,
          color: TransportColors.getColorByTransportMode(mode),
        ),
      );
    }
    return polylines;
  }

  /// Extract an ordered list of [LatLng] points from a leg's stop sequence or
  /// coords polyline.
  List<LatLng> _legPoints(Leg leg) {
    final points = <LatLng>[];
    final stopSequence = leg.stopSequence;
    if (stopSequence != null && stopSequence.isNotEmpty) {
      for (final s in stopSequence) {
        final coord = s.coord;
        if (coord != null && coord.length >= 2) {
          points.add(LatLng(coord[0], coord[1]));
        }
      }
    }
    final legCoords = leg.coords;
    if (points.length < 2 && legCoords != null && legCoords.length >= 2) {
      for (final c in legCoords) {
        if (c.length >= 2) points.add(LatLng(c[0], c[1]));
      }
    }
    return points;
  }

  Future<void> _loadVehiclePositions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<TransportMode, FeedMessage?>? mapPositions;
      List<VehiclePosition>? aggregatedVehicles;
      final getAllVehiclesAggregated = widget.getAllVehiclesAggregated;
      final getPositions = widget.getPositions;
      if (getAllVehiclesAggregated != null) {
        final agg = await getAllVehiclesAggregated();
        aggregatedVehicles = agg['vehicles'] as List<VehiclePosition>?;
      } else if (getPositions != null) {
        mapPositions = await getPositions();
      } else {
        mapPositions = await RealtimeService.getAllRealtimePositions();
      }
      final vehicles = <_VehicleWithMode>[];

      if (mapPositions != null) {
        for (final entry in mapPositions.entries) {
          final feedMode = entry.key;
          final mode = widget.mode;
          if (widget.transportMode != null) {
            if (feedMode != widget.transportMode) continue;
          } else if (mode != null) {
            if (feedMode != mode) continue;
          }
          final feedMessage = entry.value;
          if (feedMessage != null) {
            final vehiclePositions = RealtimeService.extractVehiclePositions(
              feedMessage,
            );
            vehicles.addAll(
              vehiclePositions.map((v) => _VehicleWithMode(v, feedMode)),
            );
          }
        }
      } else if (aggregatedVehicles != null) {
        // The aggregated list is untyped to a mode; keep mode as null so using
        // the default color/icon for unknown modes. This is acceptable for a
        // generic debug map view. Further enhancements could annotate each
        // position with a mode if desired by the caller.
        vehicles.addAll(
          aggregatedVehicles.map((v) => _VehicleWithMode(v, null)),
        );
      }

      // Apply trip/route filter when requested (match trip ids first, then route id fallback).
      if (widget.filterByLegTrip) {
        final ids = widget.tripIds ?? <String>{};
        if (ids.isNotEmpty) {
          vehicles.retainWhere(
            (vw) =>
                vw.vehicle.trip.hasTripId() &&
                ids.contains(vw.vehicle.trip.tripId),
          );
        } else if (widget.routeFilter?.isNotEmpty == true) {
          vehicles.removeWhere(
            (vw) =>
                vw.vehicle.trip.hasRouteId() &&
                vw.vehicle.trip.routeId != widget.routeFilter,
          );
        }
      }

      // If a leg is provided, filter vehicles to those matching the leg's route id
      // If a vehicle id filter is provided, prefer filtering by vehicle id
      // (VehicleDescriptor.id) rather than trip/route id. This allows showing
      // the exact tracked vehicle associated with a leg, when the leg's
      // transportation.id contains a vehicle id.
      // Leg-specific filtering disabled (show all vehicles)

      if (!mounted) return;
      // If a specific vehicle id was requested, prefer matching by vehicle id
      // (VehicleDescriptor.id). If none are found, fall back to treating the
      // requested id as a route id and show vehicles for that route instead.
      final vehicleId = widget.vehicleId;
      if (vehicleId != null) {
        // Keep an unfiltered copy for fallback matching by route id
        final unfiltered = List<_VehicleWithMode>.from(vehicles);
        // Try to match by vehicle descriptor id first
        vehicles.removeWhere(
          (vw) =>
              !vw.vehicle.vehicle.hasId() || vw.vehicle.vehicle.id != vehicleId,
        );

        if (vehicles.isEmpty) {
          // No vehicle found by vehicleDescriptor id; try matching as route id
          final routeMatches = unfiltered.where(
            (vw) =>
                vw.vehicle.trip.hasRouteId() &&
                vw.vehicle.trip.routeId == vehicleId,
          );
          final routeList = routeMatches.toList();
          if (routeList.isNotEmpty) {
            logger.i(
              'RealtimeMapWidget: vehicle id $vehicleId not found as vehicle id. Falling back to route id and showing ${routeList.length} vehicle(s).',
            );
            vehicles.clear();
            vehicles.addAll(routeList);
          } else {
            logger.i(
              'RealtimeMapWidget: vehicle id $vehicleId not found in feeds',
            );
          }
        }
      }
      setState(() {
        _vehicles = vehicles;
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

  List<Marker> _buildVehicleMarkers() {
    return _vehicles
        .where(
          (vw) =>
              vw.vehicle.hasPosition() &&
              vw.vehicle.position.hasLatitude() &&
              vw.vehicle.position.hasLongitude() &&
              // Only include vehicles whose mode is enabled in the filter
              (() {
                final parsed = vw.mode;
                if (parsed != null) return _modeEnabled[parsed] ?? true;
                return true;
              })(),
        )
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
        })
        .toList();
  }

  /// Build stop markers from a provided `leg` stopSequence
  List<Marker> _buildStopMarkers() {
    final markers = <Marker>[];

    // Deemphasized (smaller) markers for other-leg stops
    for (final otherLeg in widget.additionalLegs ?? []) {
      final stops = otherLeg.stopSequence;
      if (stops == null) continue;
      for (final s in stops) {
        final coord = s.coord;
        if (coord == null || coord.length < 2) continue;
        markers.add(
          Marker(
            point: LatLng(coord[0], coord[1]),
            width: 10.0,
            height: 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      }
    }

    // Active leg stop markers
    final leg = widget.leg;
    if (leg == null) return markers;
    final stops = leg.stopSequence;
    if (stops == null || stops.isEmpty) return markers;
    // Determine color/icon from the provided transportMode (or fallback)
    final mode = widget.transportMode;
    final markerColor = mode != null
        ? TransportColors.getColorByTransportMode(mode)
        : Colors.grey;

    for (final s in stops.where((s) => (s.coord?.length ?? 0) >= 2)) {
      markers.add(
        Marker(
          point: LatLng(s.coord?[0] ?? 0, s.coord?[1] ?? 0),
          width: 22,
          height: 22,
          child: GestureDetector(
            onTap: () => _showStopDetails(s),
            child: Container(
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Icon(
                  mode != null
                      ? getVehicleIconByTransportMode(mode)
                      : Icons.place,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _showStopDetails(Stop stop) {
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
              if (showDebug && (stop.coord?.length ?? 0) >= 2)
                _buildInfoRow(
                  'Coords',
                  '${stop.coord![0].toStringAsFixed(6)}, ${stop.coord![1].toStringAsFixed(6)}',
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mode filter sheet removed (map no longer exposes a mode filter control).

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

  @override
  Widget build(BuildContext context) {
    // Return embeddable map content without top-level scaffold/appbar
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVehiclePositions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: 11.0,
            minZoom: 8.0,
            maxZoom: 18.0,
            onMapReady: () {
              final fit = _pendingFit;
              final center = _pendingCenter;
              _pendingFit = null;
              _pendingCenter = null;
              if (fit != null) {
                _mapController.fitCamera(fit);
              } else if (center != null) {
                _mapController.move(center, 11.0);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.lbww.flutter_timetable',
            ),
            // Draw the route polyline if available
            PolylineLayer(polylines: _buildRoutePolylines()),
            // Show stop markers (if the leg has stops)
            MarkerLayer(markers: _buildStopMarkers()),
            // Show vehicle markers above stops so they remain visible
            MarkerLayer(markers: _buildVehicleMarkers()),
          ],
        ),
        if (widget.showVehicleCount)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        // Show an overlay if a vehicleId was requested but no vehicle
        // (by vehicle id or fallback route id) was found in the latest feed.
        if (widget.vehicleId != null && _vehicles.isEmpty)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'No vehicle found for id ${widget.vehicleId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // _calculateBounds not needed with current embeddable map view - remove for now.
}

/// Page wrapper that provides a Scaffold/AppBar for the map when it's
/// shown as a full page. For embedded uses (e.g., inside a Card) use
/// `RealtimeMapWidget` directly so the parent can provide navigation chrome.
class RealtimeMapPage extends StatelessWidget {
  final TransportMode? mode;
  final TransportMode? transportMode;
  final String? routeFilter;
  final Leg? leg;
  final String? vehicleId;
  final Future<Map<TransportMode, FeedMessage?>> Function()? getPositions;
  final Future<Map<String, dynamic>> Function()? getAllVehiclesAggregated;
  final bool filterByLegTrip;
  final Set<String>? tripIds;

  const RealtimeMapPage({
    super.key,
    this.mode,
    this.transportMode,
    this.routeFilter,
    this.leg,
    this.vehicleId,
    this.getPositions,
    this.getAllVehiclesAggregated,
    this.filterByLegTrip = false,
    this.tripIds,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<_RealtimeMapWidgetState> mapKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode != null
              ? '$mode Map'
              : leg != null
              ? 'Trip Leg Map'
              : 'Realtime Map',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => mapKey.currentState?._loadVehiclePositions(),
          ),
        ],
      ),
      body: RealtimeMapWidget(
        key: mapKey,
        mode: mode,
        transportMode: transportMode,
        routeFilter: routeFilter,
        leg: leg,
        filterByLegTrip: filterByLegTrip,
        tripIds: tripIds,
        vehicleId: vehicleId,
        getPositions: getPositions,
        getAllVehiclesAggregated: getAllVehiclesAggregated,
      ),
    );
  }
}
