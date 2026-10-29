part of '../trip_leg_screen.dart';

class _TripLegMapView extends StatelessWidget {
  const _TripLegMapView({
    required this.leg,
    required this.userLocation,
    required this.currentVehicle,
    required this.mapController,
  });

  final Map<String, dynamic> leg;
  final geo.Position? userLocation;
  final VehiclePosition? currentVehicle;
  final MapController mapController;
  static const LatLng _defaultCenter = LatLng(-33.8688, 151.2093);

  LatLng _getMapCenter() {
    // Prefer current vehicle position
    final currentVehicle = this.currentVehicle;
    if (currentVehicle != null &&
        currentVehicle.hasPosition() &&
        currentVehicle.position.hasLatitude() &&
        currentVehicle.position.hasLongitude()) {
      return LatLng(
        currentVehicle.position.latitude,
        currentVehicle.position.longitude,
      );
    }

    final origin = tryReadJsonMap(leg, 'origin');
    final originCoord = parseStopCoord(origin);
    if (originCoord != null) {
      return originCoord;
    }

    // Fall back to user location
    final userLocation = this.userLocation;
    if (userLocation != null) {
      return LatLng(userLocation.latitude, userLocation.longitude);
    }

    // Default to Sydney CBD
    return _defaultCenter;
  }

  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];
    final int transportClassForMarkers = extractTransportClassFromLeg(leg) ?? 5;

    // Add user location marker
    final userLocation = this.userLocation;
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
    final currentVehicle = this.currentVehicle;
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
    final origin = tryReadJsonMap(leg, 'origin');
    final destination = tryReadJsonMap(leg, 'destination');
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: FlutterMap(
        mapController: mapController,
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
}
