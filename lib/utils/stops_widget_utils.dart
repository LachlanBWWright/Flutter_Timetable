import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/utils/transport_display.dart';

Map<String, int> flattenStopsCountByEndpoint(
  Map<TransportMode?, Map<String, int>> grouped,
) {
  return {for (final group in grouped.values) ...group};
}

String displayNameForStopsModeGroup(
  TransportMode? mode,
  Map<String, int> endpoints,
) {
  if (mode == null) {
    return 'Other';
  }

  if (mode == TransportMode.bus) {
    final hasRegion = endpoints.keys.any(
      (key) => key.startsWith('regionbuses'),
    );
    final hasCity = endpoints.keys.any((key) => key.startsWith('buses'));
    if (hasRegion && !hasCity) {
      return 'Regional Buses';
    }
    if (hasCity && !hasRegion) {
      return 'City Buses';
    }
  }

  return getDisplayNameForTransportMode(mode);
}

String formatEndpointDisplayName(String endpointKey) {
  return endpointKey
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isNotEmpty
            ? word.substring(0, 1).toUpperCase() + word.substring(1)
            : word,
      )
      .join(' ');
}
