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
        StopsEndpoint.lightrail_innerwest,
        StopsEndpoint.lightrail_newcastle,
        StopsEndpoint.lightrail_cbdandsoutheast,
        StopsEndpoint.lightrail_parramatta,
      ];
      break;
    case TransportMode.bus:
      endpoints = [
        StopsEndpoint.buses,
        StopsEndpoint.buses_SBSC006,
        StopsEndpoint.buses_GSBC001,
        StopsEndpoint.buses_GSBC002,
        StopsEndpoint.buses_GSBC003,
        StopsEndpoint.buses_GSBC004,
        StopsEndpoint.buses_GSBC007,
        StopsEndpoint.buses_GSBC008,
        StopsEndpoint.buses_GSBC009,
        StopsEndpoint.buses_GSBC010,
        StopsEndpoint.buses_GSBC014,
        StopsEndpoint.buses_OSMBSC001,
        StopsEndpoint.buses_OSMBSC002,
        StopsEndpoint.buses_OSMBSC003,
        StopsEndpoint.buses_OSMBSC004,
        StopsEndpoint.buses_OMBSC006,
        StopsEndpoint.buses_OMBSC007,
        StopsEndpoint.buses_OSMBSC008,
        StopsEndpoint.buses_OSMBSC009,
        StopsEndpoint.buses_OSMBSC010,
        StopsEndpoint.buses_OSMBSC011,
        StopsEndpoint.buses_OSMBSC012,
        StopsEndpoint.buses_NISC001,
        StopsEndpoint.buses_ReplacementBus,
      ];
      break;
    case TransportMode.ferry:
      endpoints = [
        StopsEndpoint.ferries_sydneyferries,
        StopsEndpoint.ferries_MFF
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
