import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

class DebugExtractors {
  static Object? _mapValueOrNull(Map<String, dynamic>? values, String key) {
    if (values == null) {
      return null;
    }
    try {
      return values[key];
    } catch (_) {
      return null;
    }
  }

  static void _collectTripIdsFromRawJsonIntoSafe(
    Map<String, dynamic>? rawJson,
    Set<String> ids,
  ) {
    try {
      collectTripIdsFromRawJsonInto(rawJson, ids);
    } catch (_) {}
  }

  static void collectTripIdsFromRawJsonInto(
    Map<String, dynamic>? rawJson,
    Set<String> ids,
  ) {
    if (rawJson == null) return;

    for (final key in const ['tripId', 'id', 'trip_id']) {
      final value = _mapValueOrNull(rawJson, key)?.toString();
      if (value != null && value.isNotEmpty) {
        ids.add(value);
      }
    }

    final transportation = _mapValueOrNull(rawJson, 'transportation');
    if (transportation is! Map) {
      return;
    }
    final typedTransportation = Map<String, dynamic>.from(transportation);

    final properties = _mapValueOrNull(typedTransportation, 'properties');
    if (properties is! Map) {
      return;
    }
    final typedProperties = Map<String, dynamic>.from(properties);

    for (final key in const [
      'RealtimeTripId',
      'AVMSTripID',
      'realtimeTripId',
    ]) {
      final value = _mapValueOrNull(typedProperties, key)?.toString();
      if (value != null && value.isNotEmpty) {
        ids.add(value);
      }
    }
  }

  static Set<String> collectTripIdsForTrip(api.TripJourney? trip) {
    final ids = <String>{};
    if (trip == null) {
      return ids;
    }

    _collectTripIdsFromRawJsonIntoSafe(trip.rawJson, ids);
    for (final leg in trip.legs) {
      _collectTripIdsFromRawJsonIntoSafe(leg.rawJson, ids);
    }

    final rawLegs = _mapValueOrNull(trip.rawJson, 'legs');
    if (rawLegs is List) {
      for (final legJson in rawLegs.whereType<Map<String, dynamic>>()) {
        _collectTripIdsFromRawJsonIntoSafe(legJson, ids);
      }
    }

    return ids;
  }

  static Set<String> collectTripIdsForLeg(
    api.Leg? leg, {
    api.TripJourney? trip,
  }) {
    final ids = <String>{};
    _collectTripIdsFromRawJsonIntoSafe(trip?.rawJson, ids);
    _collectTripIdsFromRawJsonIntoSafe(leg?.rawJson, ids);
    return ids;
  }

  static Set<String> collectRouteIdsForTrip(api.TripJourney? trip) {
    final ids = <String>{};
    if (trip == null) {
      return ids;
    }

    for (final leg in trip.legs) {
      final routeId = leg.transportation?.id?.trim();
      if (routeId != null && routeId.isNotEmpty) {
        ids.add(routeId);
      }

      final rawTransport = _mapValueOrNull(leg.rawJson, 'transportation');
      if (rawTransport is Map) {
        final typedRawTransport = Map<String, dynamic>.from(rawTransport);
        final rawId = _mapValueOrNull(typedRawTransport, 'id')?.toString();
        if (rawId != null && rawId.isNotEmpty) {
          ids.add(rawId);
        }
      }
    }

    final rawLegs = _mapValueOrNull(trip.rawJson, 'legs');
    if (rawLegs is List) {
      for (final legJson in rawLegs.whereType<Map<String, dynamic>>()) {
        final rawTransport = _mapValueOrNull(legJson, 'transportation');
        if (rawTransport is Map) {
          final typedRawTransport = Map<String, dynamic>.from(rawTransport);
          final rawId = _mapValueOrNull(typedRawTransport, 'id')?.toString();
          if (rawId != null && rawId.isNotEmpty) {
            ids.add(rawId);
          }
        }
      }
    }

    return ids;
  }

  static Iterable<api.Stop> collectStopsForTrip(api.TripJourney? trip) sync* {
    if (trip == null) {
      return;
    }

    for (final leg in trip.legs) {
      yield leg.origin;
      for (final stop in leg.stopSequence ?? const <api.Stop>[]) {
        yield stop;
      }
      yield leg.destination;
    }
  }

  static api.Stop? bestStopFromContext(
    String stopId, {
    api.Stop? preferredStop,
    api.Leg? leg,
    api.TripJourney? trip,
  }) {
    if (preferredStop != null && preferredStop.id == stopId) {
      return preferredStop;
    }

    final legStop = _findStopInLeg(stopId, leg);
    if (legStop != null) {
      return legStop;
    }

    for (final candidate in collectStopsForTrip(trip)) {
      if (candidate.id == stopId) {
        return candidate;
      }
    }

    return null;
  }

  static api.Transportation? bestTransportationFromContext(
    String routeId, {
    api.Transportation? preferredTransportation,
    api.Leg? leg,
    api.TripJourney? trip,
  }) {
    if (preferredTransportation?.id == routeId) {
      return preferredTransportation;
    }

    final legTransport = leg?.transportation;
    if (legTransport?.id == routeId) {
      return legTransport;
    }

    if (trip != null) {
      for (final candidateLeg in trip.legs) {
        if (candidateLeg.transportation?.id == routeId) {
          return candidateLeg.transportation;
        }
      }
    }

    return null;
  }

  static List<api.Leg> legsForRoute(api.TripJourney? trip, String routeId) {
    if (trip == null) {
      return const [];
    }

    return trip.legs
        .where((leg) => leg.transportation?.id == routeId)
        .toList(growable: false);
  }

  static TransportMode? transportModeFromTransportation(
    api.Transportation? transportation,
  ) {
    final transportClass = transportation?.product?.classField;
    switch (transportClass) {
      case 1:
        return TransportMode.train;
      case 2:
        return TransportMode.metro;
      case 4:
        return TransportMode.lightrail;
      case 5:
      case 11:
        return TransportMode.bus;
      case 9:
        return TransportMode.ferry;
      default:
        return null;
    }
  }

  static String vehicleDisplayId(VehiclePosition vehicle) {
    if (vehicle.vehicle.hasId()) {
      return vehicle.vehicle.id;
    }
    if (vehicle.vehicle.hasLabel()) {
      return vehicle.vehicle.label;
    }
    if (vehicle.trip.hasTripId()) {
      return 'trip:${vehicle.trip.tripId}';
    }
    if (vehicle.trip.hasRouteId()) {
      return 'route:${vehicle.trip.routeId}';
    }
    return 'unknown';
  }

  static String? vehicleId(VehiclePosition vehicle) {
    if (vehicle.vehicle.hasId()) {
      return vehicle.vehicle.id;
    }
    if (vehicle.vehicle.hasLabel()) {
      return vehicle.vehicle.label;
    }
    return null;
  }

  static String? vehicleTripId(VehiclePosition vehicle) {
    return vehicle.trip.hasTripId() ? vehicle.trip.tripId : null;
  }

  static String? vehicleRouteId(VehiclePosition vehicle) {
    return vehicle.trip.hasRouteId() ? vehicle.trip.routeId : null;
  }

  static List<String> dedupeStrings(
    Iterable<String?> values, {
    String? exclude,
  }) {
    final unique = <String>{};
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty || trimmed == exclude) {
        continue;
      }
      unique.add(trimmed);
    }
    return unique.toList(growable: false);
  }

  static api.Stop? _findStopInLeg(String stopId, api.Leg? leg) {
    if (leg == null) {
      return null;
    }
    if (leg.origin.id == stopId) {
      return leg.origin;
    }
    if (leg.destination.id == stopId) {
      return leg.destination;
    }
    for (final stop in leg.stopSequence ?? const <api.Stop>[]) {
      if (stop.id == stopId) {
        return stop;
      }
    }
    return null;
  }
}
