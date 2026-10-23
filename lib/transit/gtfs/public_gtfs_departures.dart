part of 'public_gtfs_transit_adapter.dart';

class PublicGtfsDepartureRepository implements DepartureRepository {
  PublicGtfsDepartureRepository({
    required this.config,
    this.fetcher = _fetchPublicGtfsFeed,
  });

  final PublicGtfsProviderConfig config;
  final PublicGtfsFetcher fetcher;
  final Map<String, GtfsData> _cache = <String, GtfsData>{};
  final Map<String, DateTime> _cacheFetchedAt = <String, DateTime>{};
  static const Duration _cacheTtl = Duration(hours: 6);

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    final data = await loadFeed(request.stop.sourceId);
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
                          region: config.region,
                          provider: config.provider,
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

  Future<GtfsData> loadFeed(TransitSourceId sourceId) async {
    final cached = _cache[sourceId.value];
    final fetchedAt = _cacheFetchedAt[sourceId.value];
    if (cached != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _cacheTtl) {
      return cached;
    }
    final feed = config.feeds.firstWhereOrNull(
      (candidate) => candidate.sourceId == sourceId,
    );
    if (feed == null) {
      throw const InvalidJourneyRequest(
        message: 'The requested public GTFS source is not configured.',
      );
    }
    final http.Response response;
    try {
      response = await fetcher(Uri.parse(feed.url));
    } on TransitFailure {
      rethrow;
    } on Exception catch (error, stackTrace) {
      safeLogWarning('${feed.label} GTFS download failed: $error\n$stackTrace');
      throw ProviderUnavailable(
        message: 'The ${feed.label} timetable could not be downloaded.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProviderUnavailable(
        message: 'The ${feed.label} timetable is temporarily unavailable.',
      );
    }
    final GtfsData data;
    try {
      data = await compute(parseGtfsZipBytes, response.bodyBytes);
      if (data.stops.isEmpty ||
          data.routes.isEmpty ||
          data.trips.isEmpty ||
          data.stopTimes.isEmpty ||
          (data.calendars.isEmpty && data.calendarDates.isEmpty)) {
        throw const FormatException('Missing required GTFS timetable data.');
      }
    } on TransitFailure {
      rethrow;
    } on Exception catch (error, stackTrace) {
      safeLogWarning('${feed.label} GTFS parse failed: $error\n$stackTrace');
      throw InvalidProviderResponse(
        message: 'The ${feed.label} timetable could not be read.',
      );
    }
    _cache[sourceId.value] = data;
    _cacheFetchedAt[sourceId.value] = DateTime.now();
    return data;
  }
}

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
