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

part 'trip_leg/map_view.dart';
part 'trip_leg/stop_card.dart';

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
            _TripLegMapView(
              leg: widget.leg,
              userLocation: _userLocation,
              currentVehicle: _currentVehicle,
              mapController: _mapController,
            ),

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

            // Stops list as a timeline-style list
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
                  return _TripLegStopCard(
                    stop: stop,
                    index: index,
                    currentVehicle: _currentVehicle,
                  );
                },
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.directions_walk,
                    color: Colors.orange,
                  ),
                  title: const Text('Walking'),
                  subtitle: Text('Walk from $originName to $destinationName'),
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
