part of '../translink_transit_adapter.dart';

class TranslinkDepartureRepository implements DepartureRepository {
  TranslinkDepartureRepository();

  final Map<String, GtfsData> _cache = <String, GtfsData>{};
  final Map<String, DateTime> _cacheFetchedAt = <String, DateTime>{};
  static const Duration _cacheTtl = Duration(hours: 6);

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    final feedId = _feedIdFromSource(request.stop.sourceId.value);
    final data = await loadFeed(feedId);
    final now = request.when ?? DateTime.now();
    final activeServiceIds = _activeServiceIds(data, now);
    final tripsById = {for (final trip in data.trips) trip.tripId: trip};
    final routesById = {for (final route in data.routes) route.routeId: route};
    final departures =
        data.stopTimes
            .where((stopTime) => stopTime.stopId == request.stop.stopId)
            .where(
              (stopTime) => activeServiceIds.contains(
                tripsById[stopTime.tripId]?.serviceId,
              ),
            )
            .map((stopTime) {
              final departureTime = _gtfsTimeToDateTime(
                now,
                stopTime.departureTime,
              );
              final trip = tripsById[stopTime.tripId];
              final route = trip == null ? null : routesById[trip.routeId];
              return TransitDeparture(
                stop: request.stop,
                route: route == null
                    ? null
                    : TransitRoute(
                        ref: TransitRouteRef(
                          region: TransitRegion.queensland,
                          provider: TransitProviderId.translink,
                          sourceId: request.stop.sourceId,
                          routeId: route.routeId,
                        ),
                        name: route.routeLongName.isNotEmpty
                            ? route.routeLongName
                            : route.routeShortName,
                        shortName: route.routeShortName,
                        mode: _modeFromRouteType(route.routeType),
                      ),
                tripId: stopTime.tripId,
                destinationName: trip?.tripHeadsign,
                plannedTime: departureTime,
                estimatedTime: departureTime,
                platform: null,
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

  Future<GtfsData> loadFeed(String feedId) async {
    final cached = _cache[feedId];
    final fetchedAt = _cacheFetchedAt[feedId];
    if (cached != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _cacheTtl) {
      return cached;
    }
    try {
      final bytes = await fetchTranslinkStaticGtfsZip(feedId);
      if (bytes == null || bytes.isEmpty) {
        return _emptyGtfsData();
      }
      final parsed = await compute(
        parseGtfsZipBytes,
        Uint8List.fromList(bytes),
      );
      _cache[feedId] = parsed;
      _cacheFetchedAt[feedId] = DateTime.now();
      return parsed;
    } catch (error, stackTrace) {
      safeLogWarning(
        'TransLink GTFS parse failed for $feedId: $error\n$stackTrace',
      );
      return _emptyGtfsData();
    }
  }
}
