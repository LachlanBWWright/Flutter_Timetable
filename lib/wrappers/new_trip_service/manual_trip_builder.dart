part of '../new_trip_service_impl.dart';

class _ManualTripBuilder {
  static T? _firstNonNull<T>(T? primary, T? fallback) {
    if (primary != null) {
      return primary;
    }
    return fallback;
  }

  static TransportMode? _fallbackModeForLineId(String? lineId) {
    final fallbackEndpointKey = _endpointKeyFromLineId(lineId);
    if (fallbackEndpointKey == null) {
      return null;
    }
    return StopsService.modeForEndpointKey(fallbackEndpointKey);
  }

  static TripLineService _lineServiceOrDefault(TripLineService? lineService) {
    if (lineService != null) {
      return lineService;
    }
    return TripLineService.instance;
  }

  static String? _lineIdForSharedLine(StopLineMatch? sharedLine) {
    if (sharedLine == null) {
      return null;
    }
    return sharedLine.lineId;
  }

  static String? _lineNameForSharedLine(StopLineMatch? sharedLine) {
    if (sharedLine == null) {
      return null;
    }
    return sharedLine.lineName;
  }

  static String? _endpointKeyForSharedLine(StopLineMatch? sharedLine) {
    if (sharedLine == null) {
      return null;
    }
    return sharedLine.endpointKey;
  }

  static TransportMode? _modeForSharedLine(StopLineMatch? sharedLine) {
    if (sharedLine == null) {
      return null;
    }
    return sharedLine.mode;
  }

  static String? _fallbackLineIdForStations(
    Station origin,
    Station destination,
  ) {
    return _firstNonNull(origin.lineId, destination.lineId);
  }

  static String? _fallbackLineNameForStations(
    Station origin,
    Station destination,
  ) {
    return _firstNonNull(origin.lineName, destination.lineName);
  }

  static TransportMode? _preferredLegMode(Station origin, Station destination) {
    return _firstNonNull(origin.mode, destination.mode);
  }

  static TransportMode? _fallbackLineMode(String? lineId) {
    return _fallbackModeForLineId(lineId);
  }

  static StopLineMatch? _selectSharedLine({
    required List<StopLineMatch> sharedLines,
    required TransportMode? preferredMode,
    required TransportMode? previousMode,
    required TransportMode fallbackMode,
  }) {
    if (preferredMode != null) {
      final matchingPreferredMode = _firstWhereOrNull(
        sharedLines,
        (line) => line.mode == preferredMode,
      );
      if (matchingPreferredMode != null) {
        return matchingPreferredMode;
      }
    }

    final previousOrFallbackMode = _firstNonNull(previousMode, fallbackMode);
    final matchingPreviousOrFallback = _firstWhereOrNull(
      sharedLines,
      (line) => line.mode == previousOrFallbackMode,
    );
    if (matchingPreviousOrFallback != null) {
      return matchingPreviousOrFallback;
    }
    return _firstWhereOrNull(sharedLines, (_) => true);
  }

  static TransportMode _resolveManualLegMode({
    StopLineMatch? selectedSharedLine,
    required TransportMode? preferredMode,
    required TransportMode? previousMode,
    required TransportMode? fallbackLineMode,
    required TransportMode fallbackMode,
  }) {
    final selectedMode = _modeForSharedLine(selectedSharedLine);
    if (selectedMode != null) {
      return selectedMode;
    }
    if (preferredMode != null) {
      return preferredMode;
    }
    if (previousMode != null) {
      return previousMode;
    }
    if (fallbackLineMode != null) {
      return fallbackLineMode;
    }
    return fallbackMode;
  }

  static List<Station> buildOrderedTripStops({
    required Station origin,
    required Station destination,
    List<Station> interchanges = const [],
  }) {
    return [origin, ...interchanges, destination];
  }

  static List<ManualTripLeg> buildManualTripLegs({
    required Station origin,
    required Station destination,
    required List<Station> interchanges,
    TransportMode fallbackMode = TransportMode.train,
  }) {
    final orderedStops = buildOrderedTripStops(
      origin: origin,
      destination: destination,
      interchanges: interchanges,
    );

    final legs = <ManualTripLeg>[];
    Station? prev;
    int idx = 0;
    for (final stop in orderedStops) {
      if (prev != null) {
        final legOrigin = prev;
        final legDestination = stop;
        final fallbackLineId = _fallbackLineIdForStations(
          legOrigin,
          legDestination,
        );
        final fallbackEndpointKey = _endpointKeyFromLineId(fallbackLineId);
        final fallbackLineMode = _fallbackLineMode(fallbackLineId);

        legs.add(
          ManualTripLeg(
            index: idx,
            originName: legOrigin.name,
            originId: legOrigin.id,
            destinationName: legDestination.name,
            destinationId: legDestination.id,
            mode: _resolveManualLegMode(
              selectedSharedLine: null,
              preferredMode: _preferredLegMode(legOrigin, legDestination),
              previousMode: null,
              fallbackLineMode: fallbackLineMode,
              fallbackMode: fallbackMode,
            ),
            lineId: fallbackLineId,
            lineName: _fallbackLineNameForStations(legOrigin, legDestination),
            endpointKey: fallbackEndpointKey,
          ),
        );
        idx++;
      }
      prev = stop;
    }
    return legs;
  }

  static Future<List<ManualTripLeg>> buildManualTripLegsWithResolvedMetadata({
    required Station origin,
    required Station destination,
    required List<Station> interchanges,
    required TransportMode fallbackMode,
    TripLineService? tripLineService,
  }) async {
    final lineService = _lineServiceOrDefault(tripLineService);
    final orderedStops = buildOrderedTripStops(
      origin: origin,
      destination: destination,
      interchanges: interchanges,
    );
    final legs = <ManualTripLeg>[];
    TransportMode? previousMode;

    Station? prev;
    int idx = 0;
    for (final stop in orderedStops) {
      if (prev != null) {
        final legOrigin = prev;
        final legDestination = stop;
        List<StopLineMatch> originLines = [];
        List<StopLineMatch> destinationLines = [];
        try {
          originLines = await lineService.getLinesForStop(
            legOrigin.id,
            allowBuild: true,
          );
        } catch (_) {}
        try {
          destinationLines = await lineService.getLinesForStop(
            legDestination.id,
            allowBuild: true,
          );
        } catch (_) {}
        final destinationLineIds = destinationLines
            .map((line) => line.lineId)
            .toSet();
        final sharedLines = originLines
            .where((line) => destinationLineIds.contains(line.lineId))
            .toList();

        final preferredMode = _preferredLegMode(legOrigin, legDestination);
        final selectedSharedLine = _selectSharedLine(
          sharedLines: sharedLines,
          preferredMode: preferredMode,
          previousMode: previousMode,
          fallbackMode: fallbackMode,
        );
        final fallbackLineId = _fallbackLineIdForStations(
          legOrigin,
          legDestination,
        );
        final resolvedMode = _resolveManualLegMode(
          selectedSharedLine: selectedSharedLine,
          preferredMode: preferredMode,
          previousMode: previousMode,
          fallbackLineMode: _fallbackLineMode(fallbackLineId),
          fallbackMode: fallbackMode,
        );

        legs.add(
          ManualTripLeg(
            index: idx,
            originName: legOrigin.name,
            originId: legOrigin.id,
            destinationName: legDestination.name,
            destinationId: legDestination.id,
            mode: resolvedMode,
            lineId: _lineIdForSharedLine(selectedSharedLine),
            lineName: _lineNameForSharedLine(selectedSharedLine),
            endpointKey: _endpointKeyForSharedLine(selectedSharedLine),
          ),
        );
        previousMode = resolvedMode;
        idx++;
      }
      prev = stop;
    }

    return legs;
  }

  static String? validateManualTrip({
    required Station? origin,
    required Station? destination,
    required List<Station> interchanges,
    TransportMode fallbackMode = TransportMode.train,
  }) {
    if (origin == null || destination == null) {
      return 'Select an origin and destination first.';
    }

    final orderedStops = buildOrderedTripStops(
      origin: origin,
      destination: destination,
      interchanges: interchanges,
    );

    if (orderedStops.length < 2) {
      return 'Choose at least one leg before saving.';
    }

    Station? prev;
    for (final stop in orderedStops) {
      if (prev != null) {
        final currentStop = prev;
        final nextStop = stop;
        if (currentStop.id == nextStop.id) {
          return 'Adjacent stops cannot be the same.';
        }
      }
      prev = stop;
    }

    final definition = ManualTripDefinition(
      legs: buildManualTripLegs(
        origin: origin,
        destination: destination,
        interchanges: interchanges,
        fallbackMode: fallbackMode,
      ),
    );

    if (!definition.isValid) {
      return 'Manual trip legs must remain continuous.';
    }

    return null;
  }

  static String? _endpointKeyFromLineId(String? lineId) {
    if (lineId == null) {
      return null;
    }
    final separatorIndex = lineId.indexOf('|');
    if (separatorIndex <= 0) {
      return null;
    }
    return lineId.substring(0, separatorIndex);
  }

  static StopLineMatch? _firstWhereOrNull(
    List<StopLineMatch> matches,
    bool Function(StopLineMatch) predicate,
  ) {
    for (final match in matches) {
      if (predicate(match)) return match;
    }
    return null;
  }
}
