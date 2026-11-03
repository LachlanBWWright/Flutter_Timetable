import '../constants/transport_modes.dart';
import 'service_identity.dart';

class FinderLocation {
  const FinderLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
    this.speed,
    this.heading,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;
  final double? speed;
  final double? heading;
}

class FinderVehicle {
  const FinderVehicle({
    required this.id,
    required this.mode,
    required this.latitude,
    required this.longitude,
    required this.observedAt,
    required this.tripKey,
    this.service,
    this.currentStopId,
    this.currentStopSequence,
    this.atStop = false,
    this.route,
    this.label,
    this.speed,
    this.heading,
  });

  final String id;
  final TransportMode mode;
  final double latitude;
  final double longitude;
  final DateTime observedAt;
  final String tripKey;
  final ServiceIdentity? service;
  final String? currentStopId;
  final int? currentStopSequence;
  final bool atStop;
  final String? route;
  final String? label;
  final double? speed;
  final double? heading;
  String get key =>
      '${mode.id}:${Uri.encodeComponent(id)}:${service?.key ?? Uri.encodeComponent(tripKey)}';
  String get title =>
      label?.isNotEmpty == true ? label! : '${mode.displayName} $id';
}

class VehicleCandidate {
  const VehicleCandidate({
    required this.vehicle,
    required this.distance,
    required this.observations,
    required this.score,
    required this.likely,
  });

  final FinderVehicle vehicle;

  /// Distance to the phone at the vehicle's observation time, not necessarily now.
  final double distance;
  final int observations;
  final double score;
  final bool likely;
}
