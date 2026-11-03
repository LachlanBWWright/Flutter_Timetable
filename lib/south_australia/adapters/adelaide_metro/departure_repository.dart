part of '../adelaide_metro_transit_adapter.dart';

class AdelaideMetroDepartureRepository implements DepartureRepository {
  final Future<GtfsData> Function() _loadData;

  AdelaideMetroDepartureRepository({Future<GtfsData> Function()? loadData})
    : _loadData = loadData ?? _loadAdelaideMetroGtfs;

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    final data = await _loadData();
    final now = request.when ?? DateTime.now();
    final activeServices = _activeServiceIds(data, now);
    final trips = {for (final trip in data.trips) trip.tripId: trip};
    final routes = {for (final route in data.routes) route.routeId: route};
    final departures =
        data.stopTimes
            .where((time) => time.stopId == request.stop.stopId)
            .where(
              (time) => activeServices.contains(trips[time.tripId]?.serviceId),
            )
            .map((time) {
              final trip = trips[time.tripId];
              final route = trip == null ? null : routes[trip.routeId];
              final planned = _gtfsTimeToDateTime(now, time.departureTime);
              return TransitDeparture(
                stop: request.stop,
                route: route == null
                    ? null
                    : TransitRoute(
                        ref: TransitRouteRef(
                          region: TransitRegion.southAustralia,
                          provider: TransitProviderId.adelaideMetro,
                          sourceId: request.stop.sourceId,
                          routeId: route.routeId,
                        ),
                        name: route.routeLongName.isNotEmpty
                            ? route.routeLongName
                            : route.routeShortName,
                        shortName: route.routeShortName,
                        mode: _modeFromRouteType(route.routeType),
                      ),
                tripId: time.tripId,
                destinationName: trip?.tripHeadsign,
                plannedTime: planned,
                estimatedTime: planned,
              );
            })
            .where((departure) => departure.plannedTime != null)
            .where(
              (departure) => !departure.plannedTime!.isBefore(
                now.subtract(const Duration(minutes: 1)),
              ),
            )
            .toList(growable: false)
          ..sort(
            (left, right) => left.plannedTime!.compareTo(right.plannedTime!),
          );
    return departures.take(20).toList(growable: false);
  }
}

Future<GtfsData>? _adelaideMetroGtfs;

Future<GtfsData> _loadAdelaideMetroGtfs() => _adelaideMetroGtfs ??= () async {
  final response = await AppHttpClient.get(
    Uri.parse(adelaideMetroStaticGtfsUrl),
  );
  if (response == null || response.statusCode != 200) {
    return _emptyGtfsData();
  }
  try {
    return await compute(parseGtfsZipBytes, response.bodyBytes);
  } catch (error, stackTrace) {
    safeLogWarning('Adelaide Metro GTFS parse failed: $error\n$stackTrace');
    return _emptyGtfsData();
  }
}();

GtfsData _emptyGtfsData() => GtfsData(
  agencies: const [],
  calendars: const [],
  calendarDates: const [],
  routes: const [],
  stops: const [],
  stopTimes: const [],
  trips: const [],
  shapes: const [],
  notes: const [],
);

Set<String> _activeServiceIds(GtfsData data, DateTime moment) {
  final date =
      '${moment.year.toString().padLeft(4, '0')}'
      '${moment.month.toString().padLeft(2, '0')}'
      '${moment.day.toString().padLeft(2, '0')}';
  final services = <String>{};
  for (final calendar in data.calendars) {
    if (date.compareTo(calendar.startDate) < 0 ||
        date.compareTo(calendar.endDate) > 0) {
      continue;
    }
    final active = [
      calendar.monday,
      calendar.tuesday,
      calendar.wednesday,
      calendar.thursday,
      calendar.friday,
      calendar.saturday,
      calendar.sunday,
    ][moment.weekday - 1];
    if (active == '1') services.add(calendar.serviceId);
  }
  for (final exception in data.calendarDates.where(
    (item) => item.date == date,
  )) {
    if (exception.exceptionType == '1') services.add(exception.serviceId);
    if (exception.exceptionType == '2') services.remove(exception.serviceId);
  }
  return services;
}

DateTime? _gtfsTimeToDateTime(DateTime date, String value) {
  final parts = value.split(':').map(int.tryParse).toList();
  if (parts.length != 3 || parts.any((part) => part == null)) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
    parts[0]! % 24,
    parts[1]!,
    parts[2]!,
  ).add(Duration(days: parts[0]! ~/ 24));
}

TransportMode? _modeFromRouteType(String routeType) {
  switch (routeType) {
    case '0':
      return TransportMode.lightrail;
    case '1':
      return TransportMode.metro;
    case '2':
      return TransportMode.train;
    case '3':
      return TransportMode.bus;
    case '4':
      return TransportMode.ferry;
    default:
      return null;
  }
}
