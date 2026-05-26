import 'dart:convert';

import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/logs/logger.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';
import 'package:option_result/option_result.dart';

enum SavedTripType {
  direct,
  manualMultiLeg;

  String get storageValue {
    switch (this) {
      case SavedTripType.direct:
        return 'direct';
      case SavedTripType.manualMultiLeg:
        return 'manualMultiLeg';
    }
  }

  static SavedTripType fromStorage(String? value) {
    for (final tripType in SavedTripType.values) {
      if (tripType.storageValue == value) {
        return tripType;
      }
    }
    return SavedTripType.direct;
  }
}

TransportMode? transportModeFromStorage(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  for (final mode in TransportMode.values) {
    if (mode.id == value) {
      return mode;
    }
  }

  return null;
}

class ManualTripDecodeFailure {
  const ManualTripDecodeFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

Object? _jsonValueOrNull(Map<String, dynamic> json, String key) {
  try {
    return json[key];
  } catch (_) {
    return null;
  }
}

String _stringValueOrEmpty(Map<String, dynamic> json, String key) {
  return _jsonValueOrNull(json, key)?.toString() ?? '';
}

String? _stringValueOrNull(Map<String, dynamic> json, String key) {
  return _jsonValueOrNull(json, key)?.toString();
}

void _safeLogWarning(String message) {
  try {
    logger.w(message);
  } catch (_) {}
}

String? _reversedLegsJsonOrFallback(
  ManualTripDefinition? manualDefinition,
  String? fallbackLegsJson,
) {
  if (manualDefinition == null) {
    return fallbackLegsJson;
  }
  try {
    return manualDefinition.reversed().toLegsJson();
  } catch (_) {
    return fallbackLegsJson;
  }
}

class ManualTripLeg {
  const ManualTripLeg({
    required this.index,
    required this.originName,
    required this.originId,
    required this.destinationName,
    required this.destinationId,
    required this.mode,
    this.lineId,
    this.lineName,
    this.endpointKey,
  });

  final int index;
  final String originName;
  final String originId;
  final String destinationName;
  final String destinationId;
  final TransportMode mode;
  final String? lineId;
  final String? lineName;
  final String? endpointKey;

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'originName': originName,
      'originId': originId,
      'destinationName': destinationName,
      'destinationId': destinationId,
      'mode': mode.id,
      if (lineId != null) 'lineId': lineId,
      if (lineName != null) 'lineName': lineName,
      if (endpointKey != null) 'endpointKey': endpointKey,
    };
  }

  static Result<ManualTripLeg, ManualTripDecodeFailure> tryDecode(
    Map<String, dynamic> json, {
    TransportMode? fallbackMode,
  }) {
    final parsedMode =
        transportModeFromStorage(_jsonValueOrNull(json, 'mode')?.toString()) ??
        fallbackMode;
    if (parsedMode == null) {
      return const Err(
        ManualTripDecodeFailure('Manual trip leg is missing a valid mode'),
      );
    }

    return Ok(
      ManualTripLeg(
        index: tryParseIntValue(_jsonValueOrNull(json, 'index')) ?? 0,
        originName: _stringValueOrEmpty(json, 'originName'),
        originId: _stringValueOrEmpty(json, 'originId'),
        destinationName: _stringValueOrEmpty(json, 'destinationName'),
        destinationId: _stringValueOrEmpty(json, 'destinationId'),
        mode: parsedMode,
        lineId: _stringValueOrNull(json, 'lineId'),
        lineName: _stringValueOrNull(json, 'lineName'),
        endpointKey: _stringValueOrNull(json, 'endpointKey'),
      ),
    );
  }
}

class ManualTripDefinition {
  const ManualTripDefinition({required this.legs});

  final List<ManualTripLeg> legs;

  bool get isValid {
    if (legs.isEmpty) {
      return false;
    }

    var expectedIndex = 0;
    ManualTripLeg? previousLeg;
    for (final leg in legs) {
      if (leg.originId.isEmpty || leg.destinationId.isEmpty) {
        return false;
      }
      if (leg.originId == leg.destinationId) {
        return false;
      }
      if (leg.index != expectedIndex) {
        return false;
      }
      if (previousLeg != null && previousLeg.destinationId != leg.originId) {
        return false;
      }
      previousLeg = leg;
      expectedIndex += 1;
    }

    return true;
  }

  List<ManualTripStop> get orderedStops {
    final firstLeg = legs.isEmpty ? null : legs.first;
    if (firstLeg == null) {
      return const [];
    }

    return [
      ManualTripStop(id: firstLeg.originId, name: firstLeg.originName),
      ...legs.map(
        (leg) =>
            ManualTripStop(id: leg.destinationId, name: leg.destinationName),
      ),
    ];
  }

  String toLegsJson() {
    return jsonEncode(legs.map((leg) => leg.toJson()).toList());
  }

  static Result<ManualTripDefinition, ManualTripDecodeFailure>
  tryDecodeFromLegsJson({
    required String legsJson,
    TransportMode? legacyMode,
    String? legacyLineId,
    String? legacyLineName,
  }) {
    final raw = tryDecodeJsonList(legsJson);
    if (raw == null) {
      return const Err(
        ManualTripDecodeFailure('Manual trip legs JSON must be a list'),
      );
    }

    final legs = <ManualTripLeg>[];
    for (final legJson in raw) {
      if (legJson is! Map<String, dynamic>) {
        return const Err(
          ManualTripDecodeFailure(
            'Manual trip legs JSON contains a non-object leg',
          ),
        );
      }

      final result = _tryDecodeLeg(legJson, fallbackMode: legacyMode);
      switch (result) {
        case Ok(:final v):
          var leg = v;
          if (leg.lineId == null && legacyLineId != null) {
            leg = ManualTripLeg(
              index: leg.index,
              originName: leg.originName,
              originId: leg.originId,
              destinationName: leg.destinationName,
              destinationId: leg.destinationId,
              mode: leg.mode,
              lineId: legacyLineId,
              lineName: legacyLineName,
              endpointKey: leg.endpointKey,
            );
          }
          legs.add(leg);
        case Err(:final e):
          return Err(e);
      }
    }

    legs.sort((a, b) => a.index.compareTo(b.index));
    return Ok(ManualTripDefinition(legs: legs));
  }
}

extension ManualTripDefinitionX on ManualTripDefinition {
  ManualTripDefinition reversed() {
    final reversedStops = orderedStops.reversed.toList();
    if (reversedStops.length < 2) {
      return const ManualTripDefinition(legs: []);
    }

    final reversedLegs = <ManualTripLeg>[];
    final stopIterator = reversedStops.iterator;
    final legIterator = legs.reversed.iterator;
    if (!stopIterator.moveNext()) {
      return const ManualTripDefinition(legs: []);
    }
    var origin = stopIterator.current;
    var index = 0;
    while (stopIterator.moveNext() && legIterator.moveNext()) {
      final destination = stopIterator.current;
      final currentLeg = legIterator.current;
      reversedLegs.add(
        ManualTripLeg(
          index: index,
          originName: origin.name,
          originId: origin.id,
          destinationName: destination.name,
          destinationId: destination.id,
          mode: currentLeg.mode,
          lineId: currentLeg.lineId,
          lineName: currentLeg.lineName,
          endpointKey: currentLeg.endpointKey,
        ),
      );
      origin = destination;
      index += 1;
    }

    return ManualTripDefinition(legs: reversedLegs);
  }
}

class ManualTripStop {
  const ManualTripStop({required this.id, required this.name});

  final String id;
  final String name;
}

extension JourneySavedTripX on Journey {
  SavedTripType get savedTripType => SavedTripType.fromStorage(tripType);

  TransportMode? get savedMode => transportModeFromStorage(mode);

  bool get isManualMultiLeg => savedTripType == SavedTripType.manualMultiLeg;

  ManualTripDefinition? get manualTripDefinition {
    if (!isManualMultiLeg) {
      return null;
    }

    final resolvedLegsJson = legsJson;
    if (resolvedLegsJson == null) {
      return null;
    }

    final result = _tryDecodeManualTripDefinition(
      legsJson: resolvedLegsJson,
      legacyMode: savedMode,
      legacyLineId: lineId,
      legacyLineName: lineName,
    );
    switch (result) {
      case Ok(:final v):
        return v.isValid ? v : null;
      case Err(:final e):
        _safeLogWarning(
          'Failed to decode manual trip definition for journey $id: $e',
        );
        return null;
    }
  }

  Journey reversedPreviewJourney() {
    final manualDefinition = manualTripDefinition;
    return Journey(
      id: id,
      origin: destination,
      originId: destinationId,
      destination: origin,
      destinationId: originId,
      tripType: tripType,
      mode: mode,
      lineId: lineId,
      lineName: lineName,
      legsJson: _reversedLegsJsonOrFallback(manualDefinition, legsJson),
      isPinned: isPinned,
    );
  }
}

Result<ManualTripLeg, ManualTripDecodeFailure> _tryDecodeLeg(
  Map<String, dynamic> json, {
  TransportMode? fallbackMode,
}) {
  try {
    return ManualTripLeg.tryDecode(json, fallbackMode: fallbackMode);
  } catch (e) {
    return Err(ManualTripDecodeFailure('Failed to decode manual trip leg: $e'));
  }
}

Result<ManualTripDefinition, ManualTripDecodeFailure>
_tryDecodeManualTripDefinition({
  required String legsJson,
  TransportMode? legacyMode,
  String? legacyLineId,
  String? legacyLineName,
}) {
  try {
    return ManualTripDefinition.tryDecodeFromLegsJson(
      legsJson: legsJson,
      legacyMode: legacyMode,
      legacyLineId: legacyLineId,
      legacyLineName: legacyLineName,
    );
  } catch (e) {
    return Err(
      ManualTripDecodeFailure('Failed to decode manual trip definition: $e'),
    );
  }
}
