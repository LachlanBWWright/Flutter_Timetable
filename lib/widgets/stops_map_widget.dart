import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../gtfs/stop.dart';
import '../services/debug_service.dart';
import '../services/location_service.dart';
import '../services/stops_service.dart';
import '../utils/color_utils.dart';
import '../utils/guarded_state.dart';
import '../utils/stops_map_utils.dart';
import '../utils/stops_spatial_index.dart';

part 'stops_map/stop_loading.dart';
part 'stops_map/map_controls.dart';
part 'stops_map/map_content.dart';
part 'stops_map/stop_details.dart';

/// Widget for displaying stops on a map for a specific transport mode.
///
/// When [embedded] is true the widget renders without a [Scaffold]/[AppBar] so
/// it can be placed inline inside another screen (e.g. replacing a station list
/// in the New Trip screen).  In embedded mode, stop selection calls
/// [onStopSelected] and then invokes [onClose] (if provided) so the parent can
/// dismiss the map view.
class StopsMapWidget extends StatefulWidget {
  final TransportMode transportMode;
  final String modeDisplayName;
  final void Function(String stopName, String stopId) onStopSelected;
  final List<StopsEndpoint>? endpoints;
  final Set<String>? allowedStopIds;

  /// When true, renders the map content without its own Scaffold/AppBar.
  final bool embedded;

  /// Called when the user wants to close the embedded map and return to the
  /// list view.  Only used when [embedded] is true.
  final VoidCallback? onClose;

  /// Whether to load OpenStreetMap tiles. Disable this for offline previews
  /// and golden tests so captures do not depend on network or host plugins.
  final bool showTileLayer;
  final bool skipInitialLoad;
  final List<Stop> initialStops;

  const StopsMapWidget({
    super.key,
    required this.transportMode,
    required this.modeDisplayName,
    required this.onStopSelected,
    this.endpoints,
    this.allowedStopIds,
    this.embedded = false,
    this.onClose,
    this.showTileLayer = true,
    this.skipInitialLoad = false,
    this.initialStops = const [],
  });

  @override
  State<StopsMapWidget> createState() => _StopsMapWidgetState();
}

class _StopsMapWidgetState extends State<StopsMapWidget>
    with GuardedState<StopsMapWidget> {
  final MapController _mapController = MapController();
  List<Stop> _stops = [];
  List<Marker> _cachedMarkers = [];
  final Map<Stop, Marker> _markerCache = {};
  StopsSpatialIndex _stopSpatialIndex = StopsSpatialIndex(const <Stop>[]);
  Position? _userLocation;
  bool _isLoading = true;
  String? _error;
  bool _mapIsReady = false;
  VoidCallback? _pendingMapAction;
  double _currentZoom = 10.0;
  bool _showZoomWarning = false;
  Timer? _viewportDebounce;
  MapCamera? _pendingCamera;
  int _stopLoadGeneration = 0;
  int _cameraInteractionGeneration = 0;

  void _safePop() {
    popPage();
  }

  void _selectStop(Stop stop) {
    final onStopSelected = widget.onStopSelected;
    try {
      onStopSelected.call(stop.stopName, stop.stopId);
    } catch (_) {}
  }

  void _closeEmbeddedMap() {
    final onClose = widget.onClose;
    if (onClose == null) {
      return;
    }
    try {
      onClose.call();
    } catch (_) {}
  }

  void _runPendingMapAction() {
    final action = _pendingMapAction;
    _pendingMapAction = null;
    if (action == null) {
      return;
    }
    runGuarded(action);
  }

  @override
  void initState() {
    super.initState();
    if (widget.skipInitialLoad) {
      _replaceStops(widget.initialStops);
      _isLoading = false;
      return;
    }
    _loadStopsAndLocation();
  }

  @override
  void didUpdateWidget(covariant StopsMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stopsFilterChanged =
        oldWidget.transportMode != widget.transportMode ||
        !const ListEquality<StopsEndpoint>().equals(
          oldWidget.endpoints,
          widget.endpoints,
        ) ||
        !const SetEquality<String>().equals(
          oldWidget.allowedStopIds,
          widget.allowedStopIds,
        );
    if (!stopsFilterChanged &&
        const ListEquality<Stop>().equals(
          oldWidget.initialStops,
          widget.initialStops,
        ) &&
        oldWidget.skipInitialLoad == widget.skipInitialLoad) {
      return;
    }

    if (widget.skipInitialLoad) {
      _stopLoadGeneration++;
      _pendingMapAction = null;
      guardedSetState(() {
        _isLoading = false;
        _error = null;
      });
      _replaceStops(widget.initialStops);
      if (_mapIsReady) _scheduleViewportUpdate(_mapController.camera);
    } else {
      _loadStopsAndLocation();
    }
  }

  @override
  void dispose() {
    _stopLoadGeneration++;
    _viewportDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  List<Stop> _filteredStops(Iterable<Stop> stops) {
    final allowedStopIds = widget.allowedStopIds;
    return stops
        .where(
          (stop) =>
              stop.stopLat.isFinite &&
              stop.stopLon.isFinite &&
              stop.stopLat >= -90 &&
              stop.stopLat <= 90 &&
              stop.stopLon >= -180 &&
              stop.stopLon <= 180 &&
              stop.stopLat != 0.0 &&
              stop.stopLon != 0.0 &&
              (allowedStopIds == null || allowedStopIds.contains(stop.stopId)),
        )
        .toList(growable: false);
  }

  void _replaceStops(Iterable<Stop> stops) {
    _stops = _filteredStops(stops);
    _stopSpatialIndex = StopsSpatialIndex(_stops);
    _markerCache.clear();
    _cachedMarkers = const [];
  }

  void _scheduleViewportUpdate(MapCamera camera) {
    _pendingCamera = camera;
    _viewportDebounce?.cancel();
    _viewportDebounce = Timer(const Duration(milliseconds: 140), () {
      final pendingCamera = _pendingCamera;
      _pendingCamera = null;
      if (!mounted || pendingCamera == null) return;
      _updateViewport(pendingCamera);
    });
  }

  void _updateViewport(MapCamera camera) {
    final zoom = camera.zoom;
    final shouldShowMarkers = shouldShowStopsMapMarkers(
      mode: widget.transportMode,
      currentZoom: zoom,
    );
    var nextMarkers = const <Marker>[];
    if (shouldShowMarkers) {
      final visibleBounds = camera.visibleBounds;
      final latitudePadding =
          (visibleBounds.north - visibleBounds.south) * 0.25;
      final longitudeHalfSpan = visibleBounds.longitudeWidth * 0.75;
      final visibleStops = _stopSpatialIndex.query(
        south: visibleBounds.south - latitudePadding,
        north: visibleBounds.north + latitudePadding,
        west: visibleBounds.longitudeCenter - longitudeHalfSpan,
        east: visibleBounds.longitudeCenter + longitudeHalfSpan,
      );
      final visibleStopSet = visibleStops.toSet();
      _markerCache.removeWhere((stop, _) => !visibleStopSet.contains(stop));
      final color = _getModeColor();
      final icon = _getModeIcon();
      nextMarkers = visibleStops
          .map(
            (stop) => _markerCache.putIfAbsent(
              stop,
              () => Marker(
                point: LatLng(stop.stopLat, stop.stopLon),
                width: 20.0,
                height: 20.0,
                child: GestureDetector(
                  onTap: () => _showStopDetails(stop),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(icon, color: Colors.white, size: 12.0),
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false);
    } else {
      _markerCache.clear();
    }

    final showZoomWarning = shouldShowBusZoomWarning(
      mode: widget.transportMode,
      currentZoom: zoom,
    );
    var markersUnchanged = _cachedMarkers.length == nextMarkers.length;
    for (
      var index = 0;
      markersUnchanged && index < nextMarkers.length;
      index++
    ) {
      markersUnchanged = identical(_cachedMarkers[index], nextMarkers[index]);
    }
    if (_currentZoom == zoom &&
        _showZoomWarning == showZoomWarning &&
        markersUnchanged) {
      return;
    }
    guardedSetState(() {
      _currentZoom = zoom;
      _showZoomWarning = showZoomWarning;
      _cachedMarkers = nextMarkers;
    });
  }

  /// Determine if markers should be shown based on zoom level
  /// For buses, require higher zoom to prevent crashes from too many markers
  bool _shouldShowMarkers() {
    return shouldShowStopsMapMarkers(
      mode: widget.transportMode,
      currentZoom: _currentZoom,
    );
  }

  Color _getModeColor() {
    switch (widget.transportMode) {
      case TransportMode.metro:
        return TransportColors.metro;
      case TransportMode.train:
        return TransportColors.train;
      case TransportMode.lightrail:
        return TransportColors.lightRail;
      case TransportMode.bus:
        return TransportColors.bus;
      case TransportMode.ferry:
        return TransportColors.ferry;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Capture user location for use in closure
    final userLoc = _userLocation;

    final mapBody = _buildMapBody(userLoc);

    if (widget.embedded) {
      return mapBody;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.modeDisplayName} Stops Map'),
        backgroundColor: _getModeColor(),
        foregroundColor: getContrastingForeground(_getModeColor()),
      ),
      body: mapBody,
      floatingActionButton: _buildFABs(userLoc),
    );
  }

  IconData _getModeIcon() {
    return iconForTransportMode(widget.transportMode);
  }
}
