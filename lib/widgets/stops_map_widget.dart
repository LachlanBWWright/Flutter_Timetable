import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../gtfs/stop.dart';
import '../services/stops_service.dart';
import '../services/location_service.dart';
import '../constants/transport_colors.dart';

/// Widget for displaying stops on a map for a specific transport mode
class StopsMapWidget extends StatefulWidget {
  final String transportMode;
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
  Position? _userLocation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStopsAndLocation();
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
      
      setState(() {
        _stops = allStops;
        _isLoading = false;
      });

      // Center map on user location or stops
      if (_userLocation != null) {
        _mapController.move(
          LatLng(_userLocation!.latitude, _userLocation!.longitude),
          13.0,
        );
      } else if (_stops.isNotEmpty) {
        _centerMapOnStops();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<Stop>> _getStopsForTransportMode(String mode) async {
    final List<String> endpoints = _getEndpointsForMode(mode);
    final List<Stop> allStops = [];

    for (final endpoint in endpoints) {
      try {
        final stops = await StopsService.getStopsForEndpoint(endpoint);
        allStops.addAll(stops);
      } catch (e) {
        print('Error loading stops for endpoint $endpoint: $e');
      }
    }

    return allStops;
  }

  List<String> _getEndpointsForMode(String mode) {
    switch (mode) {
      case 'train':
        return ['nswtrains', 'sydneytrains'];
      case 'lightrail':
        return [
          'lightrail_innerwest',
          'lightrail_newcastle',
          'lightrail_cbdandsoutheast',
          'lightrail_parramatta'
        ];
      case 'bus':
        return [
          'buses',
          'buses_SBSC006',
          'buses_GSBC001',
          'buses_GSBC002',
          'buses_GSBC003',
          'buses_GSBC004',
          'buses_GSBC007',
          'buses_GSBC008',
          'buses_GSBC009',
          'buses_GSBC010',
          'buses_GSBC014',
          'buses_OSMBSC001',
          'buses_OSMBSC002',
          'buses_OSMBSC003',
          'buses_OSMBSC004',
          'buses_OMBSC006',
          'buses_OMBSC007',
          'buses_OSMBSC008',
          'buses_OSMBSC009',
          'buses_OSMBSC010',
          'buses_OSMBSC011',
          'buses_OSMBSC012',
          'buses_NISC001',
          'buses_ReplacementBus',
        ];
      case 'ferry':
        return ['ferries_sydneyferries', 'ferries_MFF'];
      default:
        return [];
    }
  }

  void _centerMapOnStops() {
    if (_stops.isEmpty) return;

    final latLngs = _stops
        .where((stop) => stop.stopLat != 0.0 && stop.stopLon != 0.0)
        .map((stop) => LatLng(stop.stopLat, stop.stopLon))
        .toList();

    if (latLngs.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(latLngs);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
    }
  }

  Color _getModeColor() {
    switch (widget.transportMode) {
      case 'train':
        return TransportColors.train;
      case 'lightrail':
        return TransportColors.lightRail;
      case 'bus':
        return TransportColors.bus;
      case 'ferry':
        return TransportColors.ferry;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.modeDisplayName} Stops Map'),
        backgroundColor: _getModeColor(),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
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
                          Icon(Icons.location_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('No ${widget.modeDisplayName.toLowerCase()} stops found'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadStopsAndLocation,
                            child: const Text('Reload'),
                          ),
                        ],
                      ),
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(-33.8688, 151.2093), // Sydney
                        initialZoom: 10.0,
                        minZoom: 5.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.flutter_timetable',
                        ),
                        MarkerLayer(
                          markers: [
                            // User location marker
                            if (_userLocation != null)
                              Marker(
                                point: LatLng(_userLocation!.latitude, _userLocation!.longitude),
                                width: 30.0,
                                height: 30.0,
                                child: const Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                              ),
                            // Stop markers
                            ..._stops
                                .where((stop) => stop.stopLat != 0.0 && stop.stopLon != 0.0)
                                .map(
                                  (stop) => Marker(
                                    point: LatLng(stop.stopLat, stop.stopLon),
                                    width: 20.0,
                                    height: 20.0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showStopDetails(stop);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _getModeColor(),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: Icon(
                                          _getModeIcon(),
                                          color: Colors.white,
                                          size: 12.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ],
                    ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_userLocation != null)
            FloatingActionButton(
              heroTag: "location",
              mini: true,
              onPressed: () {
                _mapController.move(
                  LatLng(_userLocation!.latitude, _userLocation!.longitude),
                  15.0,
                );
              },
              child: const Icon(Icons.my_location),
            ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "fit_stops",
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
      case 'train':
        return Icons.directions_train;
      case 'lightrail':
        return Icons.tram;
      case 'bus':
        return Icons.directions_bus;
      case 'ferry':
        return Icons.directions_ferry;
      default:
        return Icons.location_on;
    }
  }

  void _showStopDetails(Stop stop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stop.stopName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stop ID: ${stop.stopId}'),
            const SizedBox(height: 8),
            if (stop.platformCode != null && stop.platformCode!.isNotEmpty)
              Text('Platform: ${stop.platformCode}'),
            if (_userLocation != null)
              Text(
                'Distance: ${LocationService.calculateDistance(
                  _userLocation!.latitude,
                  _userLocation!.longitude,
                  stop.stopLat,
                  stop.stopLon,
                ).toStringAsFixed(2)} km',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onStopSelected(stop.stopName, stop.stopId);
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Also close the map
            },
            child: const Text('Select Stop'),
          ),
        ],
      ),
    );
  }
}