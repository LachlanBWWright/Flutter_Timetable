import '../constants/transport_modes.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

/// A particular departure, scoped to the NSW mode feed that identified it.
class ServiceIdentity {
  const ServiceIdentity({
    required this.mode,
    required this.tripId,
    this.startDate = '',
    this.startTime = '',
    this.routeId = '',
  });
  final TransportMode mode;
  final String tripId;
  final String startDate;
  final String startTime;
  final String routeId;
  String get source => 'tfnsw:${mode.id}';
  String get key => [
    source,
    tripId,
    startDate,
    startTime,
    routeId,
  ].map(Uri.encodeComponent).join(':');
  TripDescriptor get descriptor => TripDescriptor(
    tripId: tripId,
    startDate: startDate,
    startTime: startTime,
    routeId: routeId,
  );

  bool compatible(TripDescriptor other) {
    if (tripId.isEmpty || other.tripId != tripId) return false;
    for (final pair in [
      (startDate, other.startDate),
      (startTime, other.startTime),
      (routeId, other.routeId),
    ]) {
      if (pair.$1.isNotEmpty && pair.$2.isNotEmpty && pair.$1 != pair.$2) {
        return false;
      }
    }
    return true;
  }
}
