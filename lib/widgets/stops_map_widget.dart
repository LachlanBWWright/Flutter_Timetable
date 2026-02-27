import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../gtfs/stop.dart';
// logger removed
import '../services/location_service.dart';
import '../services/stops_service.dart';
import '../utils/color_utils.dart';

/// Widget for displaying stops on a map for a specific transport mode
class StopsMapWidget extends StatefulWidget {
  final TransportMode transportMode;
  final String modeDisplayName;
  final Function(String, String) onStopSelected;

  const StopsMapWidget({
    super.key,
    required this.transportMode,
    required this.modeDisplayName,
    required this.onStopSelected,
  });

  @override
  State<StopsMapWidget> createState() => _StopsMapWidgetState();
}

class _StopsMapWidgetState extends State<StopsMapWidget> {
  final MapController _mapController = MapController();
  List<Stop> _stops = [];
  List<Marker> _cachedMarkers = [];
  Position? _userLocation;
  bool _isLoading = true;
  String? _error;
  bool _mapIsReady = false;
  VoidCallback? _pendingMapAction;
  double _currentZoom = 10.0;
  bool _showZoomWarning = false;
  Timer? _zoomDebounce;

  @override
  void initState() {
    super.initState();
    _loadStopsAndLocation();
  }

  @override
  void dispose() {
    _zoomDebounce?.cancel();
    super.dispose();
  }

  void _buildMarkerCache() {
    final color = _getModeColor();
    final icon = _getModeIcon();
    _cachedMarkers = _stops
        .map(
          (stop) => Marker(
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
        )
        .toList();
  }

  Future<void> _loadStopsAndLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load user location
      _userLocation = await LocationService.getCurrentLocation();

      // Load stops for the transport mode
      final allStops = await _getStopsForTransportMode(widget.transportMode);

      if (!mounted) return;

      // Pre-filter stops with invalid coordinates once on load
      _stops = allStops
          .where((s) => s.stopLat != 0.0 && s.stopLon != 0.0)
          .toList();
      _buildMarkerCache();

      setState(() {
        _isLoading = false;
      });

      // Center map on user location or stops
      final userLoc = _userLocation;
      if (userLoc != null) {
        if (_mapIsReady) {
          _mapController.move(
            LatLng(userLoc.latitude, userLoc.longitude),
            13.0,
          );
        } else {
          _pendingMapAction = () {
            _mapController.move(
              LatLng(userLoc.latitude, userLoc.longitude),
              13.0,
            );
          };
        }
      } else if (_stops.isNotEmpty) {
        _centerMapOnStops();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<Stop>> _getStopsForTransportMode(TransportMode mode) async {
    final List<StopsEndpoint> endpoints = _getEndpointsForMode(mode);
    final List<Stop> allStops = [];

    for (final endpoint in endpoints) {
      try {
        final stops = await StopsService.getStopsForEndpoint(endpoint);
        // Exclude child/platform stops (those with a parent_station) so the
        // map shows only top-level stations.
        allStops.addAll(stops.where((s) => s.parentStation == null));
      } catch (e) {
        // Error loading stops for endpoint: $endpoint
      }
    }

    return allStops;
  }

  List<StopsEndpoint> _getEndpointsForMode(TransportMode mode) {
    switch (mode) {
      case TransportMode.metro:
        return [StopsEndpoint.metro];
      case TransportMode.train:
        return [StopsEndpoint.nswtrains, StopsEndpoint.sydneytrains];
      case TransportMode.lightrail:
        return [
          StopsEndpoint.lightrailInnerwest,
          StopsEndpoint.lightrailNewcastle,
          StopsEndpoint.lightrailCbdandsoutheast,
          StopsEndpoint.lightrailParramatta,
        ];
      case TransportMode.bus:
        return [
          StopsEndpoint.buses,
          StopsEndpoint.busesSbsc006,
          StopsEndpoint.busesGbsc001,
          StopsEndpoint.busesGsbc002,
          StopsEndpoint.busesGsbc003,
          StopsEndpoint.busesGsbc004,
          StopsEndpoint.busesGsbc007,
          StopsEndpoint.busesGsbc008,
          StopsEndpoint.busesGsbc009,
          StopsEndpoint.busesGsbc010,
          StopsEndpoint.busesGsbc014,
          StopsEndpoint.busesOsmbsc001,
          StopsEndpoint.busesOsmbsc002,
          StopsEndpoint.busesOsmbsc003,
          StopsEndpoint.busesOsmbsc004,
          StopsEndpoint.busesOmbsc006,
          StopsEndpoint.busesOmbsc007,
          StopsEndpoint.busesOsmbsc008,
          StopsEndpoint.busesOsmbsc009,
          StopsEndpoint.busesOsmbsc010,
          StopsEndpoint.busesOsmbsc011,
          StopsEndpoint.busesOsmbsc012,
          StopsEndpoint.busesNisc001,
          StopsEndpoint.busesReplacementBus,
        ];
      case TransportMode.ferry:
        return [StopsEndpoint.ferriesSydneyFerries, StopsEndpoint.ferriesMff];
    }
  }

  void _centerMapOnStops() {
    if (_stops.isEmpty) return;

    final latLngs = _stops
        .map((stop) => LatLng(stop.stopLat, stop.stopLon))
        .toList();

    if (latLngs.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(latLngs);
      void action() {
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)),
        );
      }

      if (_mapIsReady) {
        action();
      } else {
        _pendingMapAction = action;
      }
    }
  }

  /// Determine if markers should be shown based on zoom level
  /// For buses, require higher zoom to prevent crashes from too many markers
  bool _shouldShowMarkers() {
    if (widget.transportMode == TransportMode.bus) {
      return _currentZoom >= 13.0;
    }
    // Other modes can show markers at any zoom level
    return true;
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

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.modeDisplayName} Stops Map'),
        backgroundColor: _getModeColor(),
        foregroundColor: getContrastingForeground(_getModeColor()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading stops: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStopsAndLocation,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _stops.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.modeDisplayName.toLowerCase()} stops found',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStopsAndLocation,
                    child: const Text('Reload'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(-33.8688, 151.2093), // Sydney
                    initialZoom: 10.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    onPositionChanged: (position, hasGesture) {
                      _zoomDebounce?.cancel();
                      _zoomDebounce = Timer(
                        const Duration(milliseconds: 150),
                        () {
                          if (!mounted) return;
                          setState(() {
                            _currentZoom = position.zoom;
                            _showZoomWarning =
                                widget.transportMode == TransportMode.bus &&
                                _currentZoom < 13.0;
                          });
                        },
                      );
                    },
                    onMapReady: () {
                      // Mark map as ready and run any pending map action
                      setState(() {
                        _mapIsReady = true;
                      });
                      if (_pendingMapAction != null) {
                        final action = _pendingMapAction;
                        _pendingMapAction = null;
                        action?.call();
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.flutter_timetable',
                    ),
                    if (userLoc != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(userLoc.latitude, userLoc.longitude),
                            width: 30.0,
                            height: 30.0,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),
                    if (_shouldShowMarkers())
                      MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          maxClusterRadius: 120,
                          disableClusteringAtZoom: 16,
                          markers: _cachedMarkers,
                          builder: (context, markers) {
                            return Container(
                              decoration: BoxDecoration(
                                color: _getModeColor(),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  markers.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                // Zoom warning overlay for buses
                if (_showZoomWarning)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: Colors.orange.shade100,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.orange,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Zoom In to View Stops',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Too many bus stops to display. Please zoom in to see stops.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (userLoc != null)
            FloatingActionButton(
              heroTag: 'location',
              mini: true,
              onPressed: () {
                _mapController.move(
                  LatLng(userLoc.latitude, userLoc.longitude),
                  15.0,
                );
              },
              child: const Icon(Icons.my_location),
            ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'fit_stops',
            mini: true,
            onPressed: _centerMapOnStops,
            child: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
    );
  }

  IconData _getModeIcon() {
    switch (widget.transportMode) {
      case TransportMode.metro:
        return Icons.subway;
      case TransportMode.train:
        return Icons.directions_train;
      case TransportMode.lightrail:
        return Icons.tram;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.ferry:
        return Icons.directions_ferry;
    }
  }

  void _showStopDetails(Stop stop) {
    final userLoc = _userLocation;
    final modeColor = _getModeColor();
    final modeIcon = _getModeIcon();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Color accent bar at top
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: modeColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(modeIcon, color: modeColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stop.stopName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Stop ID: ${stop.stopId}',
                    style: Theme.of(context).textTheme.bodyMedium),
                if (stop.platformCode?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text('Platform: ${stop.platformCode}',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (userLoc != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Distance: ${LocationService.calculateDistance(userLoc.latitude, userLoc.longitude, stop.stopLat, stop.stopLon).toStringAsFixed(2)} km',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: modeColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      widget.onStopSelected(stop.stopName, stop.stopId);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Also close the map
                    },
                    child: const Text('Select Stop'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
