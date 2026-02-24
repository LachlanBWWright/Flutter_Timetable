import 'package:flutter/material.dart';

import '../constants/transport_modes.dart';

/// Helper: human-friendly display name for a typed transport mode.
String modeDisplayNameForTransportMode(TransportMode mode) {
  switch (mode) {
    case TransportMode.train:
      return 'Trains';
    case TransportMode.metro:
      return 'Metro';
    case TransportMode.bus:
      return 'Buses';
    case TransportMode.lightrail:
      return 'Light Rail';
    case TransportMode.ferry:
      return 'Ferries';
  }
}

/// Infer a simple mode string from the feed key used in RealtimeService.

/// Map a typed transport mode to a suitable Material icon.
IconData getVehicleIconByTransportMode(TransportMode? mode) {
  if (mode == null) return Icons.help_outline;
  switch (mode) {
    case TransportMode.train:
      return Icons.train;
    case TransportMode.metro:
      return Icons.subway;
    case TransportMode.lightrail:
      return Icons.tram;
    case TransportMode.ferry:
      return Icons.directions_boat;
    case TransportMode.bus:
      return Icons.directions_bus;
  }
}
