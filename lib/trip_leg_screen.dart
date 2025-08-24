import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/location_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

class TripLegDetailScreen extends StatefulWidget {
  final Map<String, dynamic> leg;
  const TripLegDetailScreen({super.key, required this.leg});

  @override
  State<TripLegDetailScreen> createState() => _TripLegDetailScreenState();
}

class _TripLegDetailScreenState extends State<TripLegDetailScreen> {
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
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _userLocation = position;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _loadRealtimeData() async {
    setState(() {
      _isLoadingVehicles = true;
    });

    try {
      // Get the transport mode from leg data
      final transportation =
          widget.leg['transportation'] as Map<String, dynamic>?;
      final transportProduct =
          transportation?['product'] as Map<String, dynamic>?;
      final transportClass = transportProduct?['class'];
      final tripId = transportation?['id'];

      if (transportClass != null) {
        // Determine which realtime feed to query based on transport mode
        final String? mode = _getRealtimeModeFromClass(transportClass);

        if (mode != null) {
          final feedMessage = await RealtimeService.getPositionsForMode(mode);
          final vehicles = RealtimeService.extractVehiclePositions(feedMessage);

          // Try to find the specific vehicle for this trip
          VehiclePosition? currentVehicle;
          if (tripId != null) {
            try {
              currentVehicle = vehicles.firstWhere(
                (vehicle) => vehicle.trip.tripId == tripId,
              );
            } catch (e) {
              // Vehicle not found, keep currentVehicle as null
            }
          }

          if (mounted) {
            setState(() {
              _currentVehicle = currentVehicle;
              _isLoadingVehicles = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVehicles = false;
        });
      }
    }
  }

  String? _getRealtimeModeFromClass(int transportClass) {
    switch (transportClass) {
      case 1: // Train
        return 'sydney_trains'; // Could also be nsw_trains or metro
      case 4: // Light Rail
        return 'lightrail_cbd_southeast'; // Could be other light rail lines
      case 5: // Bus
      case 11: // School Bus
        return 'buses';
      case 9: // Ferry
        return 'ferries_sydney';
      default:
        return null;
    }
  }

  LatLng _getMapCenter() {
    // Prefer current vehicle position
    if (_currentVehicle?.position != null) {
      return LatLng(
        _currentVehicle!.position.latitude,
        _currentVehicle!.position.longitude,
      );
    }

    // Try to get center from stop coordinates
    final origin = widget.leg['origin'] as Map<String, dynamic>?;

    if (origin?['coord'] != null) {
      final coord = origin!['coord'] as List?;
      if (coord != null &&
          coord.length >= 2 &&
          coord[0] != null &&
          coord[1] != null) {
        return LatLng(
          (coord[0] as num).toDouble(),
          (coord[1] as num).toDouble(),
        );
      }
    }

    // Fall back to user location
    if (_userLocation != null) {
      return LatLng(_userLocation!.latitude, _userLocation!.longitude);
    }

    // Default to Sydney CBD
    return _defaultCenter;
  }

  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];

    // Add user location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 30,
          ),
        ),
      );
    }

    // Add current vehicle marker if available
    if (_currentVehicle?.position != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentVehicle!.position.latitude,
            _currentVehicle!.position.longitude,
          ),
          child: Icon(
            Icons.directions_bus,
            color: TransportModeUtils.getModeColor(
              (widget.leg['transportation']
                      as Map<String, dynamic>?)?['product']?['class'] ??
                  5,
            ),
            size: 25,
          ),
        ),
      );
    }

    // Add origin and destination markers
    final origin = widget.leg['origin'] as Map<String, dynamic>?;
    final destination = widget.leg['destination'] as Map<String, dynamic>?;

    if (origin?['coord'] != null) {
      final coord = origin!['coord'] as List?;
      if (coord != null && coord.length >= 2) {
        markers.add(
          Marker(
            point: LatLng(
              (coord[0] as num).toDouble(),
              (coord[1] as num).toDouble(),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.green,
              size: 25,
            ),
          ),
        );
      }
    }

    if (destination?['coord'] != null) {
      final destCoord = destination!['coord'] as List?;
      if (destCoord != null && destCoord.length >= 2) {
        markers.add(
          Marker(
            point: LatLng(
              (destCoord[0] as num).toDouble(),
              (destCoord[1] as num).toDouble(),
            ),
            child: const Icon(
              Icons.stop,
              color: Colors.red,
              size: 25,
            ),
          ),
        );
      }
    }

    return markers;
  }

  Widget _buildMapView() {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _getMapCenter(),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: _buildMapMarkers(),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(dynamic stop, int index) {
    final stopName = stop['disassembledName'] ?? stop['name'] ?? 'Unknown Stop';
    final departureTimePlanned = stop['departureTimePlanned'] as String?;
    final departureTimeEstimated = stop['departureTimeEstimated'] as String?;
    final arrivalTimePlanned = stop['arrivalTimePlanned'] as String?;
    final arrivalTimeEstimated = stop['arrivalTimeEstimated'] as String?;

    // Check if this stop is where the vehicle currently is
    bool isCurrentStop = false;
    if (_currentVehicle != null) {
      final currentStopSequence = _currentVehicle!.currentStopSequence;
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
            foregroundColor: Colors.white,
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
                    const Icon(Icons.departure_board,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Depart: ${_formatTimeDifference(departureTimePlanned, departureTimeEstimated)}',
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
                      'Arrive: ${_formatTimeDifference(arrivalTimePlanned, arrivalTimeEstimated)}',
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

  String _formatTimeDifference(String? plannedTime, String? estimatedTime) {
    if (estimatedTime == null) {
      return plannedTime != null
          ? DateTimeUtils.parseTimeOnly(plannedTime)
          : 'TBD';
    }

    if (plannedTime == null) {
      return DateTimeUtils.parseTimeOnly(estimatedTime);
    }

    try {
      final planned = DateTimeUtils.parseTimeToDateTime(plannedTime);
      final estimated = DateTimeUtils.parseTimeToDateTime(estimatedTime);

      if (planned == null || estimated == null) {
        return DateTimeUtils.parseTimeOnly(estimatedTime);
      }

      final difference = estimated.difference(planned).inMinutes;

      if (difference == 0) {
        return DateTimeUtils.parseTimeOnly(estimatedTime);
      } else if (difference > 0) {
        return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (+${difference}m late)';
      } else {
        return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (${difference.abs()}m early)';
      }
    } catch (e) {
      return DateTimeUtils.parseTimeOnly(estimatedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transportation =
        widget.leg['transportation'] as Map<String, dynamic>?;
    final transportProduct =
        transportation?['product'] as Map<String, dynamic>?;
    final transportClass = transportProduct?['class'];

    final origin = widget.leg['origin'] as Map<String, dynamic>?;
    final destination = widget.leg['destination'] as Map<String, dynamic>?;
    final originName = origin?['disassembledName'] ?? origin?['name'];
    final destinationName =
        destination?['disassembledName'] ?? destination?['name'];
    final transportName =
        transportation?['name'] ?? transportation?['disassembledName'] ?? '';
    final stopSequence = widget.leg['stopSequence'] as List?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Leg Details'),
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
                  Text('From: $originName',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('To: $destinationName',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
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
                  if (_currentVehicle != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: .3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_bus,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Vehicle ${_currentVehicle?.vehicle.label ?? _currentVehicle?.vehicle.id ?? 'Unknown'} is tracked',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text('Stops:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildStopCard(stopSequence[index], index),
                  );
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.directions_walk, color: Colors.orange),
                    title: const Text('Walking'),
                    subtitle: Text('Walk from $originName to $destinationName'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
