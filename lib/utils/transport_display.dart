import '../constants/transport_modes.dart';

String getDisplayNameForTransportMode(TransportMode mode) {
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
