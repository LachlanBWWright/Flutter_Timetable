import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';

List<StopsEndpoint> endpointsForTransportMode(TransportMode mode) =>
    NewTripService.getEndpointsForMode(mode);

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
