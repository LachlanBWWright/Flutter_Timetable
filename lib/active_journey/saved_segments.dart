import '../constants/transport_modes.dart';
import '../models/manual_trip_models.dart';
import '../schema/database.dart' show Journey;

/// Manual itineraries store per-leg caches rather than a single combined plan.
Iterable<({Journey journey, bool reverse, String key, int? index})>
savedSegments(Journey journey, bool reverse, TransportMode mode) sync* {
  if (!journey.isManualMultiLeg) {
    yield (journey: journey, reverse: reverse, key: 'direct', index: null);
    return;
  }
  final definition = journey.manualTripDefinition;
  if (definition == null) return;
  final legs = reverse ? definition.reversed().legs : definition.legs;
  for (final leg in legs) {
    if (leg.mode != mode) continue;
    yield (
      journey: Journey(
        id: journey.id,
        tripType: 'direct',
        origin: leg.originName,
        originId: leg.originId,
        destination: leg.destinationName,
        destinationId: leg.destinationId,
        mode: mode.id,
        isPinned: journey.isPinned,
      ),
      reverse: false,
      key: '${leg.index}:${leg.originId}:${leg.destinationId}:${mode.id}',
      index: leg.index,
    );
  }
}
