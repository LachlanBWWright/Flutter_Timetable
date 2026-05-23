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
        transportModeFromStorage(json['mode']?.toString()) ?? fallbackMode;
    if (parsedMode == null) {
      return const Err(
        ManualTripDecodeFailure('Manual trip leg is missing a valid mode'),
      );
    }

    return Ok(
      ManualTripLeg(
        index: (json['index'] as num?)?.toInt() ?? 0,
        originName: json['originName']?.toString() ?? '',
        originId: json['originId']?.toString() ?? '',
        destinationName: json['destinationName']?.toString() ?? '',
        destinationId: json['destinationId']?.toString() ?? '',
        mode: parsedMode,
        lineId: json['lineId']?.toString(),
        lineName: json['lineName']?.toString(),
        endpointKey: json['endpointKey']?.toString(),
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

      final result = ManualTripLeg.tryDecode(legJson, fallbackMode: legacyMode);
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

    final result = ManualTripDefinition.tryDecodeFromLegsJson(
      legsJson: resolvedLegsJson,
      legacyMode: savedMode,
      legacyLineId: lineId,
      legacyLineName: lineName,
    );
    switch (result) {
      case Ok(:final v):
        return v.isValid ? v : null;
      case Err(:final e):
        logger.w('Failed to decode manual trip definition for journey $id: $e');
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
