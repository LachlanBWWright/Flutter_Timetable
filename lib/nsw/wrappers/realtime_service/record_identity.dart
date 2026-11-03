part of '../realtime_service_impl.dart';

String _descriptorKey(TripDescriptor trip) => [
  trip.tripId,
  trip.startDate,
  trip.startTime,
].map(Uri.encodeComponent).join(':');

String _tripRecordKey(_RealtimeRecord<TripUpdate> record, int index) {
  final trip = record.value.trip;
  if (trip.tripId.trim().isNotEmpty) {
    return '${record.namespace}:trip:${_descriptorKey(trip)}';
  }
  // A route and date alone identify many departures. Without both service
  // date and start time there is no safe way to collapse missing-ID updates.
  if (trip.routeId.trim().isNotEmpty &&
      trip.startDate.isNotEmpty &&
      trip.startTime.isNotEmpty) {
    return '${record.namespace}:route:${Uri.encodeComponent(trip.routeId)}:'
        '${_descriptorKey(trip)}';
  }
  return '${record.namespace}:unknown:$index';
}

String _vehicleRecordKey(_RealtimeRecord<VehiclePosition> record, int index) {
  final value = record.value;
  // Canonical and grouped feeds can overlap. Keep their freshness precedence,
  // while separating unrelated modes and separate instances of a trip.
  if (value.vehicle.id.trim().isNotEmpty) {
    return '${record.namespace}:vid:${Uri.encodeComponent(value.vehicle.id)}';
  }
  if (value.trip.tripId.trim().isNotEmpty) {
    return '${record.namespace}:trip:${_descriptorKey(value.trip)}';
  }
  if (value.hasPosition() &&
      value.position.hasLatitude() &&
      value.position.hasLongitude()) {
    return '${record.namespace}:pos:'
        '${value.position.latitude.toStringAsFixed(6)}:'
        '${value.position.longitude.toStringAsFixed(6)}:'
        '${value.hasTimestamp() ? value.timestamp : 'nots'}';
  }
  return '${record.namespace}:unknown:$index';
}
