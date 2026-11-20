import 'package:timezone/timezone.dart' as tz;

import '../../gtfs/gtfs_data.dart';
import '../../gtfs/stop_time.dart';
import '../../gtfs/timetable_index.dart' show gtfsTimeSeconds;
import '../domain/transit_types.dart';
import '../errors/transit_failure.dart';
import '../interfaces/transit_interfaces.dart';
import '../runtime/transit_resource_budget.dart';
import 'gtfs_feed_validation.dart';
import 'gtfs_realtime_updates.dart';
import 'gtfs_service_clock.dart';
import 'gtfs_trip_instances.dart';

/// Enforce ownership before a repository performs any I/O.
void validateDepartureStop(
  TransitStopRef stop, {
  required TransitRegion region,
  required TransitProviderId provider,
  required bool Function(TransitSourceId source) acceptsSource,
}) {
  if (!stop.belongsTo(region, provider) ||
      !acceptsSource(stop.sourceId) ||
      stop.stopId.trim().isEmpty ||
      stop.stopId.length > 256) {
    throw const InvalidJourneyRequest(
      message: 'The departure stop does not belong to this provider or source.',
    );
  }
}

List<TransitDeparture> scheduledGtfsDepartures(
  GtfsData data,
  DepartureRequest request, {
  List<TransitTripUpdate> updates = const [],
  TransitResourceBudget budget = const TransitResourceBudget(),
}) {
  final index = data.index;
  if (index.maximumHour ~/ 24 + 1 > budget.maximumServiceDays) {
    throw const TransitResourceLimit(
      message: 'This timetable exceeds the service-day budget.',
    );
  }
  final zones = gtfsRouteTimeZones(data, request.stop.region);
  final location = gtfsFeedTimeZone(data, request.stop.region);
  final when = request.when?.toUtc() ?? DateTime.now().toUtc();
  final times = <StopTime>[
    for (final id in index.boardingStops(request.stop.stopId))
      ...?index.timesByStop[id],
  ];
  final departures = <TransitDeparture>[];
  for (final date in gtfsCandidateServiceDates(
    when,
    index.maximumHour ~/ 24 + 1,
    location: location,
  )) {
    final services = index.activeServices(date);
    for (final time in times) {
      final trip = index.trips[time.tripId];
      if (trip == null ||
          !services.contains(trip.serviceId) ||
          (time.pickupType != null &&
              time.pickupType!.isNotEmpty &&
              time.pickupType != '0')) {
        continue;
      }
      final zone = tz.getLocation(zones[trip.routeId] ?? location.name);
      final seconds = gtfsTimeSeconds(time.departureTime);
      if (seconds == null) continue;
      final allTripUpdates = updates
          .where(
            (u) =>
                u.tripId == trip.tripId &&
                (u.sourceId == null || u.sourceId == request.stop.sourceId) &&
                (u.stop == null ||
                    u.stop!.belongsTo(
                      request.stop.region,
                      request.stop.provider,
                    )),
          )
          .toList();
      for (final instance in gtfsTripInstances(index, trip.tripId)) {
        final tripUpdates = gtfsInstanceUpdates(
          index,
          trip.tripId,
          instance.offset,
          allTripUpdates,
        );
        final planned = gtfsTimeOnDate(
          date,
          gtfsSecondsText(seconds + instance.offset),
          zone,
        );
        if (planned == null ||
            planned.isBefore(when.subtract(const Duration(minutes: 1))) ||
            planned.isAfter(when.add(const Duration(days: 1)))) {
          continue;
        }
        if (tripUpdates.any(
          (u) =>
              (u.cancelled || (u.skipped && u.stop?.stopId == time.stopId)) &&
              gtfsUpdateApplies(u, date, planned),
        )) {
          continue;
        }
        final estimated = gtfsUpdatedTime(
          tripUpdates,
          time.stopId,
          planned,
          date,
          arrival: false,
          stopTimes: index.timesByTrip[trip.tripId] ?? const [],
        );
        final route = index.routes[trip.routeId];
        departures.add(
          TransitDeparture(
            stop: request.stop,
            tripId: trip.tripId,
            destinationName: time.stopHeadsign ?? trip.tripHeadsign,
            platform: index.stops[time.stopId]?.platformCode,
            plannedTime: planned,
            timetable: data.timetable,
            estimatedTime: estimated,
            isApproximate: instance.approximate,
            headwaySeconds: instance.headway,
            statusText: instance.approximate
                ? 'Approximate · every ${(instance.headway! / 60).ceil()} min'
                : null,
            route: route == null
                ? null
                : TransitRoute(
                    ref: TransitRouteRef(
                      region: request.stop.region,
                      provider: request.stop.provider,
                      sourceId: request.stop.sourceId,
                      routeId: route.routeId,
                    ),
                    name: route.routeLongName.isEmpty
                        ? route.routeShortName
                        : route.routeLongName,
                    shortName: route.routeShortName,
                    mode: gtfsRouteMode(route.routeType),
                  ),
          ),
        );
      }
    }
  }
  departures.sort((a, b) {
    final order = a.plannedTime!.compareTo(b.plannedTime!);
    if (order != 0) return order;
    return (a.tripId ?? '').compareTo(b.tripId ?? '');
  });
  return departures.take(20).toList(growable: false);
}
