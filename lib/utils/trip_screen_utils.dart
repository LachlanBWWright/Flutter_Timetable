import 'dart:convert';

import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'date_time_utils.dart';

List<TripJourney> sortTripJourneysForDisplay(
  List<TripJourney> journeys, {
  DateTime? now,
}) {
  final referenceTime = now ?? DateTime.now();
  final upcoming = <TripJourney>[];
  final past = <TripJourney>[];

  for (final journey in journeys) {
    final departure = departureTimeForTripJourney(journey);
    if (departure != null && !departure.isBefore(referenceTime)) {
      upcoming.add(journey);
    } else {
      past.add(journey);
    }
  }

  upcoming.sort(_compareTripsAscending);
  past.sort(_compareTripsDescending);
  return [...upcoming, ...past];
}

DateTime? departureTimeForTripJourney(TripJourney journey) {
  if (journey.legs.isEmpty) {
    return null;
  }

  final firstLeg = journey.legs.first;
  final departure =
      firstLeg.origin.departureTimeEstimated ??
      firstLeg.origin.departureTimePlanned;
  return departure == null
      ? null
      : DateTimeUtils.parseTimeToDateTime(departure);
}

String? prettyPrintRawJson(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }
  return const JsonEncoder.withIndent('  ').convert(json);
}

String loadingTripMessage(Journey journey) {
  if (journey.isManualMultiLeg) {
    return 'Loading saved trip from ${journey.origin} to ${journey.destination}...';
  }
  return 'Loading trips from ${journey.origin} to ${journey.destination}...';
}

String emptyTripMessage(Journey journey) {
  if (journey.isManualMultiLeg) {
    return 'This saved manual trip could not be rendered.';
  }
  return 'No trips found from ${journey.origin} to ${journey.destination}.';
}

String retryButtonLabel(Journey journey) {
  return journey.isManualMultiLeg ? 'Reload' : 'Search again';
}

int _compareTripsAscending(TripJourney a, TripJourney b) {
  final departureA = departureTimeForTripJourney(a);
  final departureB = departureTimeForTripJourney(b);
  if (departureA == null && departureB == null) return 0;
  if (departureA == null) return 1;
  if (departureB == null) return -1;
  return departureA.compareTo(departureB);
}

int _compareTripsDescending(TripJourney a, TripJourney b) {
  final departureA = departureTimeForTripJourney(a);
  final departureB = departureTimeForTripJourney(b);
  if (departureA == null && departureB == null) return 0;
  if (departureA == null) return 1;
  if (departureB == null) return -1;
  return departureB.compareTo(departureA);
}
