import 'dart:convert';

import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/schema/database.dart';

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

  factory ManualTripLeg.fromJson(
    Map<String, dynamic> json, {
    TransportMode? fallbackMode,
  }) {
    final parsedMode =
        transportModeFromStorage(json['mode']?.toString()) ?? fallbackMode;
    if (parsedMode == null) {
      throw const FormatException('Manual trip leg is missing a valid mode');
    }

    return ManualTripLeg(
      index: (json['index'] as num?)?.toInt() ?? 0,
      originName: json['originName']?.toString() ?? '',
      originId: json['originId']?.toString() ?? '',
      destinationName: json['destinationName']?.toString() ?? '',
      destinationId: json['destinationId']?.toString() ?? '',
      mode: parsedMode,
      lineId: json['lineId']?.toString(),
      lineName: json['lineName']?.toString(),
      endpointKey: json['endpointKey']?.toString(),
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

    for (var index = 0; index < legs.length; index++) {
      final leg = legs[index];
      if (leg.originId.isEmpty || leg.destinationId.isEmpty) {
        return false;
      }
      if (leg.originId == leg.destinationId) {
        return false;
      }
      if (leg.index != index) {
        return false;
      }
      if (index > 0 && legs[index - 1].destinationId != leg.originId) {
        return false;
      }
    }

    return true;
  }

  List<ManualTripStop> get orderedStops {
    if (legs.isEmpty) {
      return const [];
    }

    return [
      ManualTripStop(id: legs.first.originId, name: legs.first.originName),
      ...legs.map(
        (leg) =>
            ManualTripStop(id: leg.destinationId, name: leg.destinationName),
      ),
    ];
  }

  String toLegsJson() {
    return jsonEncode(legs.map((leg) => leg.toJson()).toList());
  }

  factory ManualTripDefinition.fromLegsJson({
    required String legsJson,
    // Legacy fields for backward compatibility
    TransportMode? legacyMode,
    String? legacyLineId,
    String? legacyLineName,
  }) {
    final raw = jsonDecode(legsJson);
    if (raw is! List) {
      throw const FormatException('Manual trip legs JSON must be a list');
    }

    final legs = raw
        .whereType<Map<String, dynamic>>()
        .map((legJson) {
          // Apply legacy fallbacks if leg is missing metadata
          final leg = ManualTripLeg.fromJson(
            legJson,
            fallbackMode: legacyMode,
          );
          if (leg.lineId == null && legacyLineId != null) {
            return ManualTripLeg(
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
          return leg;
        })
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return ManualTripDefinition(legs: legs);
  }
}

extension ManualTripDefinitionX on ManualTripDefinition {
  ManualTripDefinition reversed() {
    final reversedStops = orderedStops.reversed.toList();
    final reversedLegs = List<ManualTripLeg>.generate(
      reversedStops.length - 1,
      (index) {
        final origin = reversedStops[index];
        final destination = reversedStops[index + 1];
        final currentLeg = legs[legs.length - 1 - index];
        return ManualTripLeg(
          index: index,
          originName: origin.name,
          originId: origin.id,
          destinationName: destination.name,
          destinationId: destination.id,
          mode: currentLeg.mode,
          lineId: currentLeg.lineId,
          lineName: currentLeg.lineName,
          endpointKey: currentLeg.endpointKey,
        );
      },
    );

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

    try {
      final definition = ManualTripDefinition.fromLegsJson(
        legsJson: resolvedLegsJson,
        legacyMode: savedMode,
        legacyLineId: lineId,
        legacyLineName: lineName,
      );
      return definition.isValid ? definition : null;
    } catch (_) {
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
      legsJson: manualDefinition?.reversed().toLegsJson() ?? legsJson,
      isPinned: isPinned,
    );
  }
}
