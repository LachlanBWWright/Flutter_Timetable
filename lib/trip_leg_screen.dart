import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';
import 'package:lbww_flutter/utils/trip_leg_detail_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

import 'utils/color_utils.dart';

class TripLegDetailScreen extends StatefulWidget {
  final Map<String, dynamic> leg;
  const TripLegDetailScreen({super.key, required this.leg});

  @override
  State<TripLegDetailScreen> createState() => _TripLegDetailScreenState();
}

class _TripLegDetailScreenState extends State<TripLegDetailScreen>
    with GuardedState<TripLegDetailScreen> {
  final MapController _mapController = MapController();
  geo.Position? _userLocation;
  VehiclePosition? _currentVehicle;
  bool _isLoadingLocation = false;
  bool _isLoadingVehicles = false;

  // Sydney CBD as default center
  static const LatLng _defaultCenter = LatLng(-33.8688, 151.2093);

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _loadRealtimeData();
  }

  Future<void> _loadUserLocation() async {
    guardedSetState(() {
      _isLoadingLocation = true;
    });

    final position = await LocationService.getCurrentLocation();
    if (mounted) {
      guardedSetState(() {
        _userLocation = position;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadRealtimeData() async {
    guardedSetState(() {
      _isLoadingVehicles = true;
    });

    final int? transportClass = extractTransportClassFromLeg(widget.leg);
    final tripId = extractTripId(widget.leg);

    if (transportClass != null) {
      final TransportMode? mode = realtimeModeFromClass(transportClass);

      if (mode != null) {
        final feedMessage = await RealtimeService.getPositionsForTransportMode(
          mode,
        );
        final vehicles = RealtimeService.extractVehiclePositions(feedMessage);

        final currentVehicle = tripId == null
            ? null
            : vehicles.firstWhereOrNull(
                (vehicle) => vehicle.trip.tripId == tripId,
              );

        if (mounted) {
          guardedSetState(() {
            _currentVehicle = currentVehicle;
            _isLoadingVehicles = false;
          });
        }
        return;
      }
    }

    if (mounted) {
      guardedSetState(() {
        _isLoadingVehicles = false;
      });
    }
  }

  LatLng _getMapCenter() {
    // Prefer current vehicle position
    final currentVehicle = _currentVehicle;
    if (currentVehicle != null &&
        currentVehicle.hasPosition() &&
        currentVehicle.position.hasLatitude() &&
        currentVehicle.position.hasLongitude()) {
      return LatLng(
        currentVehicle.position.latitude,
        currentVehicle.position.longitude,
      );
    }

    final origin = tryReadJsonMap(widget.leg, 'origin');
    final originCoord = parseStopCoord(origin);
    if (originCoord != null) {
      return originCoord;
    }

    // Fall back to user location
    final userLocation = _userLocation;
    if (userLocation != null) {
      return LatLng(userLocation.latitude, userLocation.longitude);
    }

    // Default to Sydney CBD
    return _defaultCenter;
  }

  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];
    final int transportClassForMarkers =
        extractTransportClassFromLeg(widget.leg) ?? 5;

    // Add user location marker
    final userLocation = _userLocation;
    if (userLocation != null) {
      markers.add(
        Marker(
          point: LatLng(userLocation.latitude, userLocation.longitude),
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 30,
          ),
        ),
      );
    }

    // Add current vehicle marker if available
    final currentVehicle = _currentVehicle;
    if (currentVehicle != null &&
        currentVehicle.hasPosition() &&
        currentVehicle.position.hasLatitude() &&
        currentVehicle.position.hasLongitude()) {
      markers.add(
        Marker(
          point: LatLng(
            currentVehicle.position.latitude,
            currentVehicle.position.longitude,
          ),
          child: Icon(
            Icons.directions_bus,
            color: TransportModeUtils.getModeColor(transportClassForMarkers),
            size: 25,
          ),
        ),
      );
    }

    // Add origin and destination markers
    final origin = tryReadJsonMap(widget.leg, 'origin');
    final destination = tryReadJsonMap(widget.leg, 'destination');
    final originCoord = parseStopCoord(origin);
    if (originCoord != null) {
      markers.add(
        Marker(
          point: originCoord,
          child: const Icon(Icons.play_arrow, color: Colors.green, size: 25),
        ),
      );
    }

    final destinationCoord = parseStopCoord(destination);
    if (destinationCoord != null) {
      markers.add(
        Marker(
          point: destinationCoord,
          child: const Icon(Icons.stop, color: Colors.red, size: 25),
        ),
      );
    }

    return markers;
  }

  Widget _buildMapView() {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _getMapCenter(), initialZoom: 14.0),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: _buildMapMarkers()),
        ],
      ),
    );
  }

  Widget _buildStopCard(Map<String, dynamic> stop, int index) {
    final stopName =
        tryReadStringValue(stop, 'disassembledName') ??
        tryReadStringValue(stop, 'name') ??
        'Unknown Stop';
    final departureTimePlanned = tryReadStringValue(
      stop,
      'departureTimePlanned',
    );
    final departureTimeEstimated = tryReadStringValue(
      stop,
      'departureTimeEstimated',
    );
    final arrivalTimePlanned = tryReadStringValue(stop, 'arrivalTimePlanned');
    final arrivalTimeEstimated = tryReadStringValue(
      stop,
      'arrivalTimeEstimated',
    );

    // Check if this stop is where the vehicle currently is
    bool isCurrentStop = false;
    final currentVehicle = _currentVehicle;
    if (currentVehicle != null) {
      final currentStopSequence = currentVehicle.currentStopSequence;
      if (currentStopSequence > 0 && currentStopSequence == index + 1) {
        isCurrentStop = true;
      }
    }

    return Card(
      elevation: isCurrentStop ? 8 : 2,
      color: isCurrentStop ? Colors.orange.withValues(alpha: .1) : null,
      child: Container(
        decoration: isCurrentStop
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 2),
              )
            : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isCurrentStop ? Colors.orange : Colors.grey,
            foregroundColor: getContrastingForeground(
              isCurrentStop ? Colors.orange : Colors.grey,
            ),
            child: Text('${index + 1}'),
          ),
          title: Text(
            stopName,
            style: TextStyle(
              fontWeight: isCurrentStop ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (departureTimePlanned != null ||
                  departureTimeEstimated != null)
                Row(
                  children: [
                    const Icon(
                      Icons.departure_board,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Depart: ${formatTimeDifference(departureTimePlanned, departureTimeEstimated)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              if (arrivalTimePlanned != null || arrivalTimeEstimated != null)
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      'Arrive: ${formatTimeDifference(arrivalTimePlanned, arrivalTimeEstimated)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
          trailing: isCurrentStop
              ? const Icon(Icons.directions_bus, color: Colors.orange)
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transportation = tryReadJsonMap(widget.leg, 'transportation');
    final int? transportClass = extractTransportClassFromLeg(widget.leg);

    final origin = tryReadJsonMap(widget.leg, 'origin');
    final destination = tryReadJsonMap(widget.leg, 'destination');
    final originName =
        tryReadStringValue(origin, 'disassembledName') ??
        tryReadStringValue(origin, 'name') ??
        'Unknown';
    final destinationName =
        tryReadStringValue(destination, 'disassembledName') ??
        tryReadStringValue(destination, 'name') ??
        'Unknown';
    final transportName =
        tryReadStringValue(transportation, 'name') ??
        tryReadStringValue(transportation, 'disassembledName') ??
        '';
    final stopSequence = tryReadListValue(widget.leg, 'stopSequence');

    final currentVehicle = _currentVehicle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Leg Details:'),
        actions: [
          if (_isLoadingLocation || _isLoadingVehicles)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map view at the top
            _buildMapView(),

            // Trip information
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: $originName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'To: $destinationName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (transportName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.train,
                          color: transportClass != null
                              ? TransportModeUtils.getModeColor(transportClass)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Service: $transportName',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                  if (currentVehicle != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: .3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_bus,
                            color: TransportModeUtils.getModeColor(
                              transportClass ?? 5,
                            ),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (currentVehicle.vehicle.hasId())
                                  ? 'Vehicle ${currentVehicle.vehicle.id}'
                                  : 'Vehicle (unknown)',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Stops:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Stops list as cards
            if (stopSequence != null && stopSequence.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: stopSequence.length,
                itemBuilder: (context, index) {
                  final rawStop = stopSequence.elementAtOrNull(index);
                  final stop = rawStop is Map<String, dynamic>
                      ? rawStop
                      : rawStop is Map
                      ? {
                          for (final entry in rawStop.entries)
                            entry.key.toString(): entry.value,
                        }
                      : null;
                  if (stop == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildStopCard(stop, index),
                  );
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.directions_walk,
                      color: Colors.orange,
                    ),
                    title: const Text('Walking'),
                    subtitle: Text('Walk from $originName to $destinationName'),
                  ),
                ),
              ),
            // (Debug card removed — moved to Trip Leg Detail screen)
          ],
        ),
      ),
    );
  }

  // Debug pretty-printer moved to Trip Leg Detail screen
}
