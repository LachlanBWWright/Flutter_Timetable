import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

/// Load stations for a mode from the local database only (no API fetch).
/// This was extracted from `NewTripScreen` to keep DB loading logic reusable.
Future<List<Station>> loadStationsFromDbForMode(TransportMode mode) async {
  // Map mode to endpoints (same mapping used elsewhere)
  List<StopsEndpoint> endpoints;
  switch (mode) {
    case TransportMode.train:
      endpoints = [StopsEndpoint.nswtrains, StopsEndpoint.sydneytrains];
      break;
    case TransportMode.metro:
      endpoints = [StopsEndpoint.metro];
      break;
    case TransportMode.lightrail:
      endpoints = [
        StopsEndpoint.lightrailInnerwest,
        StopsEndpoint.lightrailNewcastle,
        StopsEndpoint.lightrailCbdandsoutheast,
        StopsEndpoint.lightrailParramatta,
      ];
      break;
    case TransportMode.bus:
      endpoints = [
        StopsEndpoint.buses,
        StopsEndpoint.busesSbsc006,
        StopsEndpoint.busesGbsc001,
        StopsEndpoint.busesGsbc002,
        StopsEndpoint.busesGsbc003,
        StopsEndpoint.busesGsbc004,
        StopsEndpoint.busesGsbc007,
        StopsEndpoint.busesGsbc008,
        StopsEndpoint.busesGsbc009,
        StopsEndpoint.busesGsbc010,
        StopsEndpoint.busesGsbc014,
        StopsEndpoint.busesOsmbsc001,
        StopsEndpoint.busesOsmbsc002,
        StopsEndpoint.busesOsmbsc003,
        StopsEndpoint.busesOsmbsc004,
        StopsEndpoint.busesOmbsc006,
        StopsEndpoint.busesOmbsc007,
        StopsEndpoint.busesOsmbsc008,
        StopsEndpoint.busesOsmbsc009,
        StopsEndpoint.busesOsmbsc010,
        StopsEndpoint.busesOsmbsc011,
        StopsEndpoint.busesOsmbsc012,
        StopsEndpoint.busesNisc001,
        StopsEndpoint.busesReplacementBus,
      ];
      break;
    case TransportMode.ferry:
      endpoints = [
        StopsEndpoint.ferriesSydneyFerries,
        StopsEndpoint.ferriesMff
      ];
      break;
  }

  final List<gtfs_stop.Stop> allStops = [];
  for (final endpoint in endpoints) {
    try {
      final stops = await StopsService.getStopsForEndpoint(endpoint);
      // Exclude child/platform stops which have a parent_station value.
      allStops.addAll(stops.where((s) => s.parentStation == null));
    } catch (_) {
      // ignore DB read errors for a single endpoint
    }
  }

  return allStops.map((stop) {
    final String displayName = stop.stopName;

    return Station(
      name: displayName,
      id: stop.stopId,
      latitude: stop.stopLat != 0.0 ? stop.stopLat : null,
      longitude: stop.stopLon != 0.0 ? stop.stopLon : null,
    );
  }).toList();
}
