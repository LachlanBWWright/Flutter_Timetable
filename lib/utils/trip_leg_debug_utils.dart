import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/stops_service.dart';

String vehicleDisplayId(VehiclePosition vehicle) {
  final descriptor = vehicle.vehicle;
  if (descriptor.hasId()) {
    return descriptor.id;
  }
  if (vehicle.trip.hasTripId()) {
    return 'trip:${vehicle.trip.tripId}';
  }
  if (vehicle.trip.hasRouteId()) {
    return 'route:${vehicle.trip.routeId}';
  }
  return 'unknown';
}

StopsEndpoint? currentGtfsEndpointFromKey(String? endpointKey) {
  if (endpointKey == null || endpointKey.isEmpty) {
    return null;
  }

  for (final endpoint in StopsEndpoint.values) {
    if (endpoint.key == endpointKey) {
      return endpoint;
    }
  }
  return null;
}

String? firstSortedValue(Iterable<String> values) {
  final sorted = values.where((value) => value.isNotEmpty).toSet().toList()
    ..sort();
  if (sorted.isEmpty) {
    return null;
  }
  return sorted.first;
}

void appendScalarPreviewFields(
  StringBuffer buffer,
  Map<String, dynamic>? json, {
  required String title,
  int maxEntries = 8,
}) {
  if (json == null) {
    return;
  }

  final entries = json.entries
      .where((entry) {
        final value = entry.value;
        return value == null ||
            value is String ||
            value is num ||
            value is bool;
      })
      .take(maxEntries)
      .toList();

  if (entries.isEmpty) {
    return;
  }

  buffer.writeln('\n$title:');
  for (final entry in entries) {
    buffer.writeln('  ${entry.key}: ${entry.value}');
  }
}
