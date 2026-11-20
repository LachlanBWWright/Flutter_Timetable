import 'dart:convert';
import 'dart:math' as math;

import '../../gtfs/agency.dart';
import '../../gtfs/calendar.dart';
import '../../gtfs/calendar_date.dart';
import '../../gtfs/frequency.dart';
import '../../gtfs/gtfs_data.dart';
import '../../gtfs/pathway.dart';
import '../../gtfs/route.dart';
import '../../gtfs/stop.dart';
import '../../gtfs/stop_time.dart';
import '../../gtfs/transfer.dart';
import '../../gtfs/trip.dart';
import '../domain/transit_types.dart';
import '../errors/transit_failure.dart';
import '../interfaces/transit_interfaces.dart';
import '../registry/transit_registry.dart';
import '../runtime/cancellable_compute.dart';
import '../runtime/transit_resource_budget.dart';
import 'gtfs_journey_planner.dart';
import 'gtfs_realtime_updates.dart';
import 'gtfs_service_clock.dart';

/// Joins explicitly selected feed snapshots without treating local IDs as global.
/// Cross-feed footpaths are estimates, limited to 250 metres, and never asserted
/// to be wheelchair-accessible without published pathway evidence.
class GtfsNetworkPlanner implements CapableJourneyPlanner {
  GtfsNetworkPlanner({
    required this.servicesFor,
    this.budget = const TransitResourceBudget(),
  });
  final TransitResourceBudget budget;
  final TransitRegionServices Function(TransitRegion) servicesFor;
  @override
  TransitPlanningCapabilities get capabilities =>
      const TransitPlanningCapabilities(
        arriveBy: true,
        accessibility: true,
        walkingLimits: true,
        crossFeed: true,
        crossRegion: true,
        frequencyServices: true,
      );
  @override
  Future<JourneyPlan> planJourney(JourneyPlanRequest request) async {
    final feeds = <(TransitRegionServices, TransitSourceId, GtfsData)>[];
    final keys = <String>{};
    for (final ref in [request.origin, request.destination]) {
      final service = servicesFor(ref.region);
      if (service.provider != ref.provider ||
          !service.timetableSources.contains(ref.sourceId)) {
        throw const InvalidJourneyRequest(
          message: 'The selected stop does not belong to a configured timetable source.',
        );
      }
      final key =
          '${ref.region.name}|${ref.provider.name}|${ref.sourceId.value}';
      if (!keys.add(key)) continue;
      final loader = service.timetableLoader;
      if (loader == null) {
        throw const UnsupportedCapability(
          message: 'A selected provider has no local timetable loader.',
        );
      }
      final future = service.cancellableTimetableLoader == null
          ? loader(ref.sourceId)
          : service.cancellableTimetableLoader!(
              ref.sourceId,
              request.cancellation ?? TransitCancellation(),
            );
      final data = await (request.cancellation?.wait(future) ?? future);
      feeds.add((service, ref.sourceId, data));
    }
    if (feeds.fold<int>(0, (sum, f) => sum + f.$3.stopTimes.length) >
        budget.maximumStopTimes) {
      throw const TransitResourceLimit(
        message:
            'The connected feeds exceed the combined timetable memory budget.',
      );
    }
    final merged = await runTransitCompute(_mergeFeeds, [
      for (final (service, source, data) in feeds)
        (
          service.region,
          service.provider,
          service.attribution.url,
          source,
          data,
        ),
    ], cancellation: request.cancellation);
    final live = <TransitTripUpdate>[];
    var fallback = false;
    for (final (service, source, data) in feeds) {
      if (service.realtime == null) continue;
      final base =
          '${service.region.name}|${service.provider.name}|${source.value}';
      final updates = await freshGtfsUpdates(
        data,
        () =>
            service.realtime!.getTripUpdates(RealtimeRequest(sourceId: source)),
      );
      if (updates.isEmpty) fallback = true;
      live.addAll(
        updates
            .where((u) => u.sourceId == source)
            .map(
              (u) => remapGtfsUpdate(
                u,
                tripId: jsonEncode([base, 'trip', u.tripId]),
                source: const TransitSourceId('__network__'),
                stop: u.stop == null
                    ? null
                    : TransitStopRef(
                        region: request.origin.region,
                        provider: request.origin.provider,
                        sourceId: const TransitSourceId('__network__'),
                        stopId: jsonEncode([base, 'stop', u.stop!.stopId]),
                      ),
              ),
            ),
      );
    }
    request.cancellation?.throwIfCancelled();
    String stopKey(TransitStopRef ref) => jsonEncode([
      '${ref.region.name}|${ref.provider.name}|${ref.sourceId.value}',
      'stop',
      ref.stopId,
    ]);
    const network = TransitSourceId('__network__');
    final internal = GtfsJourneyPlanner(
      region: request.origin.region,
      provider: request.origin.provider,
      loadData: (_) async => merged,
      budget: budget,
      loadRealtime: live.isEmpty
          ? null
          : (_) async =>
                RealtimeSnapshot(items: live, fetchedAt: DateTime.now()),
    );
    final result = await internal.planJourney(
      JourneyPlanRequest(
        origin: TransitStopRef(
          region: request.origin.region,
          provider: request.origin.provider,
          sourceId: network,
          stopId: stopKey(request.origin),
        ),
        destination: TransitStopRef(
          region: request.origin.region,
          provider: request.origin.provider,
          sourceId: network,
          stopId: stopKey(request.destination),
        ),
        when: request.when,
        arrivalBased: request.arrivalBased,
        enabledModes: request.enabledModes,
        walkingLimit: request.walkingLimit,
        accessibility: request.accessibility,
        cancellation: request.cancellation,
      ),
    );
    final provenance =
        feeds
            .map((f) => f.$3.timetable)
            .whereType<TimetableProvenance>()
            .toList()
          ..sort((a, b) => a.fetchedAt.compareTo(b.fetchedAt));
    return JourneyPlan(
      journeys: result.journeys,
      rawPayload: {
        if (result.rawPayload is Map) ...result.rawPayload as Map,
        if (fallback)
          'realtimeStatus':
              'Some live updates unavailable; timetable used where needed.',
      },
      timetable: provenance.isEmpty
          ? null
          : TimetableProvenance(
              fetchedAt: provenance.first.fetchedAt,
              isStale: provenance.any((p) => p.isStale),
              offlineFallback: provenance.any((p) => p.offlineFallback),
            ),
    );
  }
}

GtfsData _mergeFeeds(
  List<(TransitRegion, TransitProviderId, String, TransitSourceId, GtfsData)>
  feeds,
) {
  final agencies = <Agency>[],
      calendars = <Calendar>[],
      calendarDates = <CalendarDate>[],
      routes = <Route>[],
      stops = <Stop>[],
      times = <StopTime>[],
      trips = <Trip>[],
      frequencies = <GtfsFrequency>[],
      pathways = <GtfsPathway>[],
      transfers = <GtfsTransfer>[];
  final stopReferences = <String, TransitStopRef>{},
      routeReferences = <String, TransitRouteRef>{};
  final sourceByStop = <String, String>{};
  for (final (region, provider, attributionUrl, source, data) in feeds) {
    final base = '${region.name}|${provider.name}|${source.value}';
    String key(String type, String id) => jsonEncode([base, type, id]);
    String? optional(String type, String? id) =>
        id == null || id.isEmpty ? id : key(type, id);
    for (final a in data.agencies) {
      agencies.add(
        Agency(
          agencyId: key('agency', a.agencyId ?? ''),
          agencyName: a.agencyName,
          agencyUrl: a.agencyUrl,
          agencyTimezone: a.agencyTimezone,
          agencyLang: a.agencyLang,
          agencyPhone: a.agencyPhone,
          agencyFareUrl: a.agencyFareUrl,
          agencyEmail: a.agencyEmail,
        ),
      );
    }
    for (final c in data.calendars) {
      calendars.add(
        Calendar(
          serviceId: key('service', c.serviceId),
          monday: c.monday,
          tuesday: c.tuesday,
          wednesday: c.wednesday,
          thursday: c.thursday,
          friday: c.friday,
          saturday: c.saturday,
          sunday: c.sunday,
          startDate: c.startDate,
          endDate: c.endDate,
        ),
      );
    }
    for (final c in data.calendarDates) {
      calendarDates.add(
        CalendarDate(
          serviceId: key('service', c.serviceId),
          date: c.date,
          exceptionType: c.exceptionType,
        ),
      );
    }
    for (final r in data.routes) {
      routes.add(
        Route(
          routeId: key('route', r.routeId),
          agencyId: r.agencyId == null && data.agencies.length <= 1
              ? key('agency', data.agencies.firstOrNull?.agencyId ?? '')
              : optional('agency', r.agencyId),
          routeShortName: r.routeShortName,
          routeLongName: r.routeLongName,
          routeDesc: r.routeDesc,
          routeType: r.routeType,
          routeUrl: r.routeUrl,
          routeColor: r.routeColor,
          routeTextColor: r.routeTextColor,
          routeSortOrder: r.routeSortOrder,
          continuousPickup: r.continuousPickup,
          continuousDropOff: r.continuousDropOff,
          networkId: r.networkId,
        ),
      );
      routeReferences[key('route', r.routeId)] = TransitRouteRef(
        region: region,
        provider: provider,
        sourceId: source,
        routeId: r.routeId,
      );
    }
    for (final s in data.stops) {
      stops.add(
        Stop(
          stopId: key('stop', s.stopId),
          stopCode: s.stopCode,
          stopName: s.stopName,
          ttsStopName: s.ttsStopName,
          stopDesc: s.stopDesc,
          stopLat: s.stopLat,
          stopLon: s.stopLon,
          zoneId: s.zoneId,
          stopUrl: s.stopUrl,
          locationType: s.locationType,
          parentStation: optional('stop', s.parentStation),
          stopTimezone: s.stopTimezone,
          wheelchairBoarding: s.wheelchairBoarding,
          levelId: s.levelId,
          platformCode: s.platformCode,
        ),
      );
      stopReferences[key('stop', s.stopId)] = TransitStopRef(
        region: region,
        provider: provider,
        sourceId: source,
        stopId: s.stopId,
      );
      sourceByStop[key('stop', s.stopId)] = base;
    }
    for (final t in data.trips) {
      trips.add(
        Trip(
          routeId: key('route', t.routeId),
          serviceId: key('service', t.serviceId),
          tripId: key('trip', t.tripId),
          shapeId: t.shapeId,
          tripHeadsign: t.tripHeadsign,
          tripShortName: t.tripShortName,
          directionId: t.directionId,
          blockId: t.blockId,
          wheelchairAccessible: t.wheelchairAccessible,
          bikesAllowed: t.bikesAllowed,
          tripNote: t.tripNote,
          routeDirection: t.routeDirection,
        ),
      );
    }
    for (final t in data.stopTimes) {
      times.add(
        StopTime(
          tripId: key('trip', t.tripId),
          arrivalTime: t.arrivalTime,
          departureTime: t.departureTime,
          stopId: key('stop', t.stopId),
          stopSequence: t.stopSequence,
          stopHeadsign: t.stopHeadsign,
          pickupType: t.pickupType,
          dropOffType: t.dropOffType,
          continuousPickup: t.continuousPickup,
          continuousDropOff: t.continuousDropOff,
          shapeDistTraveled: t.shapeDistTraveled,
          timepoint: t.timepoint,
          stopNote: t.stopNote,
        ),
      );
    }
    if (data.agencies.isEmpty) {
      agencies.add(
        Agency(
          agencyId: key('agency', ''),
          agencyName: provider.label,
          agencyUrl: attributionUrl,
          agencyTimezone: gtfsFeedTimeZone(data, region).name,
        ),
      );
    }
    frequencies.addAll(
      data.frequencies.map(
        (f) => GtfsFrequency(
          tripId: key('trip', f.tripId),
          startTime: f.startTime,
          endTime: f.endTime,
          headwaySeconds: f.headwaySeconds,
          exact: f.exact,
        ),
      ),
    );
    pathways.addAll(
      data.pathways.map(
        (p) => GtfsPathway(
          id: key('path', p.id),
          fromStopId: key('stop', p.fromStopId),
          toStopId: key('stop', p.toStopId),
          mode: p.mode,
          bidirectional: p.bidirectional,
          seconds: p.seconds,
          length: p.length,
          estimated: p.estimated,
          accessibilityKnown: p.accessibilityKnown,
        ),
      ),
    );
    transfers.addAll(
      data.transfers.map(
        (t) => GtfsTransfer(
          fromStopId: t.fromStopId.isEmpty ? '' : key('stop', t.fromStopId),
          toStopId: t.toStopId.isEmpty ? '' : key('stop', t.toStopId),
          type: t.type,
          minimumSeconds: t.minimumSeconds,
          fromRouteId: optional('route', t.fromRouteId),
          toRouteId: optional('route', t.toRouteId),
          fromTripId: optional('trip', t.fromTripId),
          toTripId: optional('trip', t.toTripId),
        ),
      ),
    );
  }
  // ECEF metre buckets avoid quadratic comparisons and longitude edge cases.
  final buckets = <(int, int, int), List<Stop>>{};
  (int, int, int) bucket(Stop s) {
    final lat = s.stopLat * math.pi / 180, lon = s.stopLon * math.pi / 180;
    return (
      (6371000 * math.cos(lat) * math.cos(lon) / 250).floor(),
      (6371000 * math.cos(lat) * math.sin(lon) / 250).floor(),
      (6371000 * math.sin(lat) / 250).floor(),
    );
  }

  for (final stop in stops) {
    if (stop.parentStation?.isNotEmpty == true ||
        !stop.stopLat.isFinite ||
        !stop.stopLon.isFinite ||
        stop.stopLat.abs() > 90 ||
        stop.stopLon.abs() > 180 ||
        (stop.stopLat == 0 && stop.stopLon == 0)) {
      continue;
    }
    final (x, y, z) = bucket(stop);
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        for (var dz = -1; dz <= 1; dz++) {
          for (final other
              in buckets[(x + dx, y + dy, z + dz)] ?? const <Stop>[]) {
            if (sourceByStop[other.stopId] == sourceByStop[stop.stopId]) {
              continue;
            }
            final distance = _distance(other, stop);
            if (distance > 250) continue;
            pathways.add(
              GtfsPathway(
                id: 'bridge:${pathways.length}',
                fromStopId: other.stopId,
                toStopId: stop.stopId,
                mode: 1,
                bidirectional: true,
                seconds: (distance / 1.2).ceil() + 30,
                estimated: true,
                accessibilityKnown: false,
              ),
            );
          }
        }
      }
    }
    (buckets[(x, y, z)] ??= []).add(stop);
  }
  return GtfsData(
    agencies: agencies,
    calendars: calendars,
    calendarDates: calendarDates,
    routes: routes,
    stops: stops,
    stopTimes: times,
    trips: trips,
    shapes: [],
    notes: [],
    frequencies: frequencies,
    pathways: pathways,
    transfers: transfers,
    stopReferences: stopReferences,
    routeReferences: routeReferences,
  );
}

double _distance(Stop a, Stop b) {
  final lat = (b.stopLat - a.stopLat) * math.pi / 180,
      lon = (b.stopLon - a.stopLon) * math.pi / 180;
  final value =
      math.pow(math.sin(lat / 2), 2) +
      math.cos(a.stopLat * math.pi / 180) *
          math.cos(b.stopLat * math.pi / 180) *
          math.pow(math.sin(lon / 2), 2);
  return 12742000 * math.asin(math.sqrt(value.clamp(0, 1)));
}
