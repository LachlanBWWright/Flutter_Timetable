import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../logs/logger.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/api_key_service.dart';
import '../services/debug_service.dart';
import '../services/realtime_service.dart';
import '../services/transport_api_service.dart' hide logger;
import '../utils/guarded_state.dart';
import '../utils/realtime_leg_match.dart';
import '../utils/realtime_map_widget_utils.dart';
import '../utils/safe_value_utils.dart';
import '../utils/visible_realtime_refresh.dart';
import 'realtime_map_helpers.dart';
import 'trip_widgets.dart' show TransportModeUtils;

part 'realtime_map/route_layers.dart';
part 'realtime_map/vehicle_loading.dart';
part 'realtime_map/markers.dart';
part 'realtime_map/detail_sheets.dart';
part 'realtime_map/map_content.dart';
part 'realtime_map/map_page.dart';

/// Widget for displaying GTFS realtime vehicle positions on a map
class RealtimeMapWidget extends StatefulWidget {
  final TransportMode? mode;
  final TransportMode? transportMode;
  final String? routeFilter;
  final Leg? leg;

  /// Other legs of the same trip to render as deemphasized polylines.
  final List<Leg>? additionalLegs;

  /// If true, show only vehicles with a matching trip ID. An unidentified leg
  /// shows no vehicles rather than broadening the filter to its entire route.
  /// When false, the map shows all vehicles (diagnostic mode).
  final bool filterByLegTrip;

  /// Trip ids (if known) to match vehicles against when `filterByLegTrip` is true.
  final Set<String>? tripIds;
  final TripDescriptor? matchedTrip;

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
  final Future<VehiclePositionAggregationResult> Function()?
  getAllVehiclesAggregated;

  /// Invalidates caches owned by an injected provider before an explicit refresh.
  final Future<void> Function()? onRefresh;

  /// Reloads this map when the owning screen starts a new request generation.
  final int refreshGeneration;

  /// Disable when an owning screen already refreshes the same feeds.
  final bool autoRefresh;

  /// Whether to show the small vehicle count overlay in the top-right.
  /// Defaults to true; set false for embedded maps where it is redundant.
  final bool showVehicleCount;

  /// Whether to load OpenStreetMap tiles. Disable this for offline previews
  /// and golden tests so captures do not depend on network or host plugins.
  final bool showTileLayer;

  const RealtimeMapWidget({
    super.key,
    this.mode,
    this.transportMode,
    this.routeFilter,
    this.leg,
    this.additionalLegs,
    this.filterByLegTrip = false,
    this.tripIds,
    this.matchedTrip,
    this.vehicleId,
    this.getPositions,
    this.getAllVehiclesAggregated,
    this.onRefresh,
    this.refreshGeneration = 0,
    this.autoRefresh = true,
    this.showVehicleCount = true,
    this.showTileLayer = true,
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

class _RealtimeMapWidgetState extends State<RealtimeMapWidget>
    with GuardedState<RealtimeMapWidget> {
  final MapController _mapController = MapController();
  // Store vehicles with an associated mode so markers can use mode-specific
  // colors and icons.
  List<_VehicleWithMode> _vehicles = [];
  bool _isLoading = false;
  int _loadGeneration = 0;
  late VisibleRealtimeRefresh _visibleRefresh;
  RealtimeSnapshotMetadata _metadata = const RealtimeSnapshotMetadata();
  final Map<Leg, List<LatLng>> _legPoints = Map.identity();
  List<LatLng>? _tripPoints;
  List<Polyline>? _routePolylines;
  List<Marker>? _stopMarkers;
  List<Marker>? _vehicleMarkers;
  // Camera actions applied once the map is ready.
  CameraFit? _pendingFit;
  LatLng? _pendingCenter;

  LatLng? _tryParseLatLngSafe(List<double>? coord) {
    return tryParseLatLng(coord);
  }

  bool _isModeEnabled(TransportMode? mode) {
    if (mode == null) {
      return true;
    }
    return _modeEnabled.entries
            .firstWhereOrNull((entry) => entry.key == mode)
            ?.value ??
        true;
  }

  double? _coordValueAt(List<double>? coord, int index) {
    if (coord == null || index < 0 || index >= coord.length) {
      return null;
    }
    return coord.elementAtOrNull(index);
  }

  LatLng? _pointAtOrNull(List<LatLng> points, int index) {
    if (index < 0 || index >= points.length) {
      return null;
    }
    return points.elementAtOrNull(index);
  }

  TransportMode? _modeForAggregatedVehicle(VehiclePosition vehicle) {
    final explicitMode = widget.transportMode ?? widget.mode;
    if (explicitMode != null) {
      return explicitMode;
    }

    if (!vehicle.trip.hasRouteId()) {
      return null;
    }

    final routeId = vehicle.trip.routeId.trim().toUpperCase();
    if (routeId.isEmpty) {
      return null;
    }
    if (routeId.startsWith('M')) {
      return TransportMode.metro;
    }
    if (routeId.startsWith('T') || routeId.startsWith('CCN')) {
      return TransportMode.train;
    }
    if (routeId.startsWith('L')) {
      return TransportMode.lightrail;
    }
    if (routeId.startsWith('F')) {
      return TransportMode.ferry;
    }
    return TransportMode.bus;
  }

  void _closeBottomSheet() {
    popPage();
  }

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

  List<LatLng> _pointsForLeg(Leg leg) => _legPoints.putIfAbsent(
    leg,
    () => List.unmodifiable(legPointsForMap(leg)),
  );

  void _invalidateRouteLayers() {
    _legPoints.clear();
    _tripPoints = null;
    _routePolylines = null;
    _stopMarkers = null;
  }

  List<LatLng> _visibleTripPoints() {
    if (_tripPoints case final points?) return points;
    final points = <LatLng>[
      for (final otherLeg in widget.additionalLegs ?? const <Leg>[])
        ..._pointsForLeg(otherLeg),
      if (widget.leg case final leg?) ..._pointsForLeg(leg),
    ];

    return _tripPoints = points;
  }

  @override
  void initState() {
    super.initState();
    // Enable all modes by default (initialize before loading)
    _modeEnabled = {for (var m in _allModes) m: true};

    final leg = widget.leg;
    if (leg != null) {
      // Prefer fitting camera to show the whole trip; fall back to leg origin.
      final points = _visibleTripPoints();
      if (points.length >= 2) {
        _pendingFit = CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(50.0),
        );
        // Use the midpoint as the default center in case the fit is delayed.
        _mapCenter =
            _pointAtOrNull(points, points.length ~/ 2) ??
            const LatLng(-33.8688, 151.2093);
      } else {
        _mapCenter =
            _tryParseLatLngSafe(leg.origin.coord) ??
            const LatLng(-33.8688, 151.2093);
      }
    } else {
      _mapCenter = const LatLng(-33.8688, 151.2093); // Sydney CBD default
    }

    _configureVisibleRefresh();
    if (!widget.autoRefresh) _loadVehiclePositions();
  }

  void _configureVisibleRefresh() {
    var firstRefresh = true;
    _visibleRefresh = VisibleRealtimeRefresh(
      onRefresh: () {
        final forceRefresh = !firstRefresh;
        firstRefresh = false;
        return _loadVehiclePositions(forceRefresh: forceRefresh);
      },
      enabled: widget.autoRefresh,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visibleRefresh.updateRoute(context);
  }

  @override
  void didUpdateWidget(RealtimeMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoRefresh != widget.autoRefresh) {
      _visibleRefresh.dispose();
      _configureVisibleRefresh();
      _visibleRefresh.updateRoute(context);
    }
    final filterChanged =
        oldWidget.routeFilter != widget.routeFilter ||
        oldWidget.transportMode != widget.transportMode ||
        oldWidget.mode != widget.mode ||
        oldWidget.filterByLegTrip != widget.filterByLegTrip ||
        !const SetEquality<String>().equals(
          oldWidget.tripIds,
          widget.tripIds,
        ) ||
        oldWidget.matchedTrip != widget.matchedTrip ||
        oldWidget.vehicleId != widget.vehicleId ||
        oldWidget.getPositions != widget.getPositions ||
        oldWidget.getAllVehiclesAggregated != widget.getAllVehiclesAggregated;
    // When the active leg changes, fit the camera to the new leg's stops
    // without recreating the whole widget (avoids visible flash/reload).
    final legChanged =
        oldWidget.leg != widget.leg ||
        !const ListEquality<Leg>().equals(
          oldWidget.additionalLegs,
          widget.additionalLegs,
        );
    if (legChanged || oldWidget.transportMode != widget.transportMode) {
      _invalidateRouteLayers();
    }
    final refreshChanged =
        oldWidget.refreshGeneration != widget.refreshGeneration;
    if (legChanged || filterChanged || refreshChanged) {
      final newLeg = widget.leg;
      if (legChanged && newLeg != null) {
        final points = _visibleTripPoints();
        if (points.length >= 2) {
          final fit = CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.all(50.0),
          );
          final fitted = tryFitMapCamera(_mapController, fit);
          if (!fitted) {
            _pendingFit = fit;
          }
        }
      }
      // Also reload vehicle positions for the new leg
      if (_visibleRefresh.isVisible) {
        _loadVehiclePositions(clearVehicles: legChanged || filterChanged);
      } else if (legChanged || filterChanged) {
        _loadGeneration++;
        _vehicles = [];
        _vehicleMarkers = null;
        _metadata = const RealtimeSnapshotMetadata();
        _isLoading = false;
      }
    }
  }

  @override
  void dispose() {
    _loadGeneration++;
    _visibleRefresh.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildMapContent(context);
}
