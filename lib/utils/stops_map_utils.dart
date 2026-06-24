import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/stops_service.dart';

List<StopsEndpoint> endpointsForTransportMode(TransportMode mode) {
  switch (mode) {
    case TransportMode.metro:
      return [StopsEndpoint.metro];
    case TransportMode.train:
      return [StopsEndpoint.nswtrains, StopsEndpoint.sydneytrains];
    case TransportMode.lightrail:
      return [
        StopsEndpoint.lightrailInnerwest,
        StopsEndpoint.lightrailNewcastle,
        StopsEndpoint.lightrailCbdandsoutheast,
        StopsEndpoint.lightrailParramatta,
      ];
    case TransportMode.bus:
      return [
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
    case TransportMode.ferry:
      return [StopsEndpoint.ferriesSydneyFerries, StopsEndpoint.ferriesMff];
  }
}

bool shouldShowStopsMapMarkers({
  required TransportMode mode,
  required double currentZoom,
}) {
  if (mode == TransportMode.bus) {
    return currentZoom >= 13.0;
  }
  return true;
}

bool shouldShowBusZoomWarning({
  required TransportMode mode,
  required double currentZoom,
}) {
  return mode == TransportMode.bus && currentZoom < 13.0;
}

IconData iconForTransportMode(TransportMode mode) {
  switch (mode) {
    case TransportMode.metro:
      return Icons.subway;
    case TransportMode.train:
      return Icons.directions_train;
    case TransportMode.lightrail:
      return Icons.tram;
    case TransportMode.bus:
      return Icons.directions_bus;
    case TransportMode.ferry:
      return Icons.directions_ferry;
  }
}
