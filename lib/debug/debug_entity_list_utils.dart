import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;

DateTime? timestampFromUnixSeconds(int? seconds) {
  if (seconds == null) {
    return null;
  }
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}

List<String> sortedStrings(Iterable<String?> values) {
  final result =
      values
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false)
        ..sort();
  return result;
}

List<DebugDataSource> sortedSources(Iterable<DebugDataSource> sources) {
  return sources.toList(growable: false)
    ..sort((left, right) => left.label.compareTo(right.label));
}

String bestRouteTitle(gtfs_route.Route? route, String routeId) {
  if (route == null) {
    return routeId;
  }
  final longName = route.routeLongName;
  if (longName.isNotEmpty) {
    return longName;
  }
  final shortName = route.routeShortName;
  if (shortName.isNotEmpty) {
    return shortName;
  }
  return routeId;
}

String bestRouteSubtitle(gtfs_route.Route? route, List<String> endpoints) {
  final parts = <String>[];
  final shortName = route?.routeShortName;
  if (shortName != null && shortName.isNotEmpty) {
    parts.add(shortName);
  }
  if (endpoints.isNotEmpty) {
    parts.add(endpoints.join(', '));
  }
  return parts.isEmpty ? 'No GTFS metadata' : parts.join(' • ');
}

String routeDescription({
  required gtfs_agency.Agency? agency,
  required gtfs_route.Route? route,
  required int activeTrips,
  required int activeVehicles,
}) {
  final parts = <String>[];
  if (agency?.agencyName case final agencyName?) {
    parts.add(agencyName);
  }
  if (activeTrips > 0) {
    parts.add('$activeTrips active trip${activeTrips == 1 ? '' : 's'}');
  }
  if (activeVehicles > 0) {
    parts.add(
      '$activeVehicles active vehicle${activeVehicles == 1 ? '' : 's'}',
    );
  }
  if (route?.routeDesc case final routeDesc?) {
    parts.add(routeDesc);
  }
  return parts.join(' • ');
}

String routeActivity({
  required bool hasGtfs,
  required bool hasRealtime,
  required int activeTrips,
  required int activeVehicles,
}) {
  if (!hasGtfs && hasRealtime) {
    return 'realtime_only';
  }
  if (activeTrips > 0 && activeVehicles > 0) {
    return 'active_trips_and_vehicles';
  }
  if (activeTrips > 0) {
    return 'active_trips';
  }
  if (activeVehicles > 0) {
    return 'active_vehicles';
  }
  return 'catalog_only';
}

String tripDescription({
  required String? serviceDate,
  required int stopCount,
  required String? matchedVehicleId,
}) {
  final parts = <String>[];
  if (serviceDate != null && serviceDate.isNotEmpty) {
    parts.add('Service date: $serviceDate');
  }
  parts.add('$stopCount stop update${stopCount == 1 ? '' : 's'}');
  if (matchedVehicleId != null && matchedVehicleId.isNotEmpty) {
    parts.add('Vehicle: $matchedVehicleId');
  }
  return parts.join(' • ');
}

String filterLabel(String value) {
  final normalized = value.replaceAll('_', ' ');
  if (normalized.isEmpty) {
    return value;
  }
  return normalized
      .split(' ')
      .map((segment) {
        if (segment.isEmpty) {
          return segment;
        }
        return '${segment[0].toUpperCase()}${segment.substring(1)}';
      })
      .join(' ');
}

String listSubtitleForEntity(
  DebugEntityType entityType,
  String entityId,
  int endpointCount,
) {
  if (entityType != DebugEntityType.stop) {
    return entityId;
  }
  return '$entityId • $endpointCount endpoint${endpointCount == 1 ? '' : 's'}';
}
