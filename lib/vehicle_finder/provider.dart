import 'package:geolocator/geolocator.dart';

import '../constants/transport_modes.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import '../services/api_key_service.dart';
import '../services/location_service.dart';
import '../services/realtime_service.dart';
import 'models.dart';
import 'service_identity.dart';

class VehicleFinderException implements Exception {
  const VehicleFinderException(this.message, {this.isFatal = false});
  final String message;
  final bool isFatal;
  @override
  String toString() => message;
}

Stream<FinderLocation> finderLocations() async* {
  final failure = await LocationService.checkAndRequestLocationAvailability();
  if (failure != null) throw VehicleFinderException(failure);
  const settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );
  await for (final position in Geolocator.getPositionStream(
    locationSettings: settings,
  )) {
    yield FinderLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
    );
  }
}

Future<List<FinderVehicle>> finderVehicles(TransportMode mode) async {
  if (ApiKeyService.getEffectiveApiKey().isEmpty &&
      !RealtimeService.usesSharedCache) {
    throw const VehicleFinderException(
      'Add a TfNSW API key in Settings to find live vehicles.',
      isFatal: true,
    );
  }
  final result = await RealtimeService.getVehiclePositionsForModeSafe(mode);
  return finderVehiclesFromSnapshot(mode, result);
}

List<FinderVehicle> finderVehiclesFromSnapshot(
  TransportMode mode,
  VehiclePositionAggregationResult result,
) {
  if (result.metadata.isUnavailable || result.metadata.isStale) {
    throw const VehicleFinderException(
      'Live vehicle positions are unavailable or out of date. Try again shortly.',
    );
  }
  final observations = [
    for (final vehicle in result.vehicles)
      if (vehicle.hasPosition() &&
          vehicle.position.hasLatitude() &&
          vehicle.position.hasLongitude() &&
          vehicle.hasTimestamp() &&
          vehicle.vehicle.hasId() &&
          vehicle.vehicle.id.isNotEmpty)
        FinderVehicle(
          id: vehicle.vehicle.id,
          service: ServiceIdentity(
            mode: mode,
            tripId: vehicle.trip.tripId,
            startDate: vehicle.trip.startDate,
            startTime: vehicle.trip.startTime,
            routeId: vehicle.trip.routeId,
          ),
          currentStopId: vehicle.hasStopId() ? vehicle.stopId : null,
          currentStopSequence: vehicle.hasCurrentStopSequence()
              ? vehicle.currentStopSequence
              : null,
          atStop:
              vehicle.currentStatus ==
              VehiclePosition_VehicleStopStatus.STOPPED_AT,
          mode: mode,
          latitude: vehicle.position.latitude,
          longitude: vehicle.position.longitude,
          observedAt: DateTime.fromMillisecondsSinceEpoch(
            vehicle.timestamp.toInt() * 1000,
            isUtc: true,
          ),
          tripKey: [
            vehicle.trip.tripId,
            vehicle.trip.startDate,
            vehicle.trip.startTime,
          ].map(Uri.encodeComponent).join(':'),
          label: vehicle.vehicle.hasLabel() ? vehicle.vehicle.label : null,
          route: vehicle.trip.hasRouteId() ? vehicle.trip.routeId : null,
          speed: vehicle.position.hasSpeed() ? vehicle.position.speed : null,
          heading: vehicle.position.hasBearing()
              ? vehicle.position.bearing
              : null,
        ),
  ];
  if (result.vehicles.isNotEmpty && observations.isEmpty) {
    throw const VehicleFinderException(
      'This feed has no usable, timestamped vehicle positions right now. Try another transport type or retry later.',
    );
  }
  return observations;
}

/// Keep map navigation scoped to the selected departure, even if a physical
/// vehicle has since started another service using a reused trip ID.
Future<VehiclePositionAggregationResult> finderServiceMapVehicles(
  FinderVehicle vehicle,
) async {
  final result = await RealtimeService.getVehiclePositionsForModeSafe(
    vehicle.mode,
    query: RealtimeQuery(
      tripIds: [if (vehicle.service != null) vehicle.service!.tripId],
    ),
  );
  final identity = vehicle.service;
  return VehiclePositionAggregationResult(
    vehicles: result.vehicles
        .where(
          (value) =>
              value.vehicle.id == vehicle.id &&
              (identity == null ||
                  identity.tripId.isEmpty ||
                  identity.compatible(value.trip)),
        )
        .toList(),
    breakdown: result.breakdown,
    metadata: result.metadata,
  );
}
