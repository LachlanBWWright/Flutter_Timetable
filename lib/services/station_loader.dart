import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';

/// Load stations for a mode from the local database only (no API fetch).
/// This was extracted from `NewTripScreen` to keep DB loading logic reusable.
Future<List<Station>> loadStationsFromDbForMode(TransportMode mode) async {
  // Map mode to endpoints (same mapping used elsewhere)
  List<String> endpoints;
  switch (mode) {
    case TransportMode.train:
      endpoints = ['nswtrains', 'sydneytrains'];
      break;
    case TransportMode.metro:
      endpoints = ['metro'];
      break;
    case TransportMode.lightrail:
      endpoints = [
        'lightrail_innerwest',
        'lightrail_newcastle',
        'lightrail_cbdandsoutheast',
        'lightrail_parramatta'
      ];
      break;
    case TransportMode.bus:
      endpoints = [
        'buses',
        'buses_SBSC006',
        'buses_GSBC001',
        'buses_GSBC002',
        'buses_GSBC003',
        'buses_GSBC004',
        'buses_GSBC007',
        'buses_GSBC008',
        'buses_GSBC009',
        'buses_GSBC010',
        'buses_GSBC014',
        'buses_OSMBSC001',
        'buses_OSMBSC002',
        'buses_OSMBSC003',
        'buses_OSMBSC004',
        'buses_OMBSC006',
        'buses_OMBSC007',
        'buses_OSMBSC008',
        'buses_OSMBSC009',
        'buses_OSMBSC010',
        'buses_OSMBSC011',
        'buses_OSMBSC012',
        'buses_NISC001',
        'buses_ReplacementBus',
      ];
      break;
    case TransportMode.ferry:
      endpoints = ['ferries_sydneyferries', 'ferries_MFF'];
      break;
  }

  final List<gtfs_stop.Stop> allStops = [];
  for (final endpoint in endpoints) {
    try {
      final stops = await StopsService.getStopsForEndpoint(endpoint);
      allStops.addAll(stops);
    } catch (_) {
      // ignore DB read errors for a single endpoint
    }
  }

  return allStops.map((stop) {
    String displayName = stop.stopName;

    return Station(
      name: displayName,
      id: stop.stopId,
      latitude: stop.stopLat != 0.0 ? stop.stopLat : null,
      longitude: stop.stopLon != 0.0 ? stop.stopLon : null,
    );
  }).toList();
}
