import 'package:lbww_flutter/services/trip_cache_service.dart';

/// The earliest upcoming journey, including walking and transfer legs.
class NextJourneyTimes {
  const NextJourneyTimes(this.departure, this.arrival);

  final DateTime departure;
  final DateTime? arrival;

  static NextJourneyTimes? fromSnapshot(
    TripCacheSnapshot? snapshot,
    DateTime now,
  ) {
    if (snapshot == null || snapshot.isExpired) return null;
    final response = snapshot.response;
    if (response == null) return null;
    NextJourneyTimes? next;
    for (final trip in response.tripJourneys) {
      if (trip.legs.isEmpty) continue;
      final origin = trip.legs.first.origin;
      final departure =
          DateTime.tryParse(origin.departureTimeEstimated ?? '') ??
          DateTime.tryParse(origin.departureTimePlanned ?? '');
      if (departure == null || departure.isBefore(now)) continue;
      if (next != null && !departure.isBefore(next.departure)) continue;
      final destination = trip.legs.last.destination;
      final arrival =
          DateTime.tryParse(destination.arrivalTimeEstimated ?? '') ??
          DateTime.tryParse(destination.arrivalTimePlanned ?? '');
      next = NextJourneyTimes(
        departure,
        arrival != null && !arrival.isBefore(departure) ? arrival : null,
      );
    }
    return next;
  }
}
