import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/utils/transport_display.dart';

Map<String, int> flattenStopsCountByEndpoint(
  Map<TransportMode?, Map<String, int>> grouped,
) {
  final flattened = <String, int>{};
  for (final group in grouped.values) {
    for (final entry in group.entries) {
      flattened[entry.key] = entry.value;
    }
  }
  return flattened;
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
        (word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word,
      )
      .join(' ');
}
