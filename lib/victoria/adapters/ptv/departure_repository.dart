part of '../ptv_transit_adapter.dart';

class PtvDepartureRepository implements DepartureRepository {
  PtvDepartureRepository({PtvSignedClient? signedClient})
    : _signedClient = signedClient ?? PtvSignedClient();

  final PtvSignedClient _signedClient;

  @override
  Future<List<TransitDeparture>> getDepartures(DepartureRequest request) async {
    if (request.stop.sourceId.value == 'ptv:static') {
      return _getStaticDepartures(request);
    }
    if (!_signedClient.isConfigured &&
        !SharedTransitCache.instance.isConfigured) {
      throw const InvalidCredentials(
        message:
            'PTV credentials are not configured. Set PTV_DEV_ID and PTV_API_KEY.',
      );
    }
    final routeType = _parseRouteType(request.stop.sourceId.value);
    final stopId = int.tryParse(request.stop.stopId);
    if (routeType == null || stopId == null) {
      return const <TransitDeparture>[];
    }
    final response = await _signedClient.client
        .v3DeparturesRouteTypeRouteTypeStopStopIdGet(
          routeType: _departureRouteTypeEnum(routeType),
          stopId: stopId,
          gtfs: true,
          dateUtc: request.when?.toUtc(),
          maxResults: 20,
          includeCancelled: true,
          devid: _signedClient.developerId,
          signature: _signedClient.signatureForPath(
            '/v3/departures/route_type/$routeType/stop/$stopId',
            {
              'gtfs': 'true',
              if (request.when != null)
                'date_utc': request.when!.toUtc().toIso8601String(),
              'max_results': '20',
              'include_cancelled': 'true',
            },
          ),
        );
    final body = response.body;
    if (!response.isSuccessful || body == null) {
      throw const ProviderUnavailable(
        message: 'Failed to load PTV departures.',
      );
    }
    final routes = body.routes ?? const <String, dynamic>{};
    final runs = body.runs ?? const <String, dynamic>{};
    final directions = body.directions ?? const <String, dynamic>{};
    return (body.departures ?? const <V3Departure>[])
        .map((departure) {
          final routeJson =
              (tryReadMapValue(routes, '${departure.routeId}')
                  as Map<String, dynamic>?) ??
              (tryReadMapValue(routes, departure.routeId?.toString() ?? '')
                  as Map<String, dynamic>?);
          final routeName =
              tryReadStringValue(routeJson, 'route_name') ??
              tryReadStringValue(routeJson, 'route_number') ??
              'Route ${departure.routeId ?? ''}'.trim();
          final routeNumber = tryReadStringValue(routeJson, 'route_number');
          final directionJson =
              (tryReadMapValue(directions, '${departure.directionId}')
                  as Map<String, dynamic>?) ??
              (tryReadMapValue(
                    directions,
                    departure.directionId?.toString() ?? '',
                  )
                  as Map<String, dynamic>?);
          final runJson =
              (tryReadMapValue(runs, '${departure.runId}')
                  as Map<String, dynamic>?) ??
              (tryReadMapValue(runs, departure.runId?.toString() ?? '')
                  as Map<String, dynamic>?);
          return TransitDeparture(
            stop: request.stop,
            route: departure.routeId == null
                ? null
                : TransitRoute(
                    ref: TransitRouteRef(
                      region: TransitRegion.victoria,
                      provider: TransitProviderId.ptv,
                      sourceId: request.stop.sourceId,
                      routeId: '${departure.routeId}',
                    ),
                    name: routeName,
                    shortName: routeNumber,
                    mode: _transportModeForRouteType(routeType),
                  ),
            tripId: departure.runId?.toString(),
            destinationName:
                tryReadStringValue(directionJson, 'direction_name') ??
                tryReadStringValue(runJson, 'destination_name'),
            platform: departure.platformNumber,
            plannedTime: departure.scheduledDepartureUtc?.toLocal(),
            estimatedTime: departure.estimatedDepartureUtc?.toLocal(),
            cancelled: departure.flags?.contains('cancelled') ?? false,
            statusText: departure.departureNote,
          );
        })
        .toList(growable: false);
  }

  Future<List<TransitDeparture>> _getStaticDepartures(
    DepartureRequest request,
  ) async {
    final data = await _loadVictoriaGtfs();
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
                          region: TransitRegion.victoria,
                          provider: TransitProviderId.ptv,
                          sourceId: request.stop.sourceId,
                          routeId: route.routeId,
                        ),
                        name: route.routeLongName.isNotEmpty
                            ? route.routeLongName
                            : route.routeShortName,
                        shortName: route.routeShortName,
                        mode: _transportModeForRouteType(
                          int.tryParse(route.routeType) ?? -1,
                        ),
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
