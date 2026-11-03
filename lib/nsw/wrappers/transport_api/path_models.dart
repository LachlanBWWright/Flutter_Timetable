part of '../transport_api_service_impl.dart';

class Interchange {
  final List<List<double>>? coords;
  final String? desc;
  final int? type;

  Interchange({this.coords, this.desc, this.type});

  factory Interchange.fromJson(Map<String, dynamic> json) {
    final coords = tryParseDoubleMatrix(
      tryReadMapValue(json, 'coords'),
      minLengthPerRow: 2,
    );
    return Interchange(
      coords: coords,
      desc: tryReadStringValue(json, 'desc'),
      type: tryParseIntValue(tryReadMapValue(json, 'type')),
    );
  }
}

class PathDescription {
  final List<double>? coord;
  final int? cumDistance;
  final int? cumDuration;
  final int? distance;
  final int? distanceDown;
  final int? distanceUp;
  final int? duration;
  final int? fromCoordsIndex;
  final String? manoeuvre;
  final String? name;
  final int? skyDirection;
  final int? toCoordsIndex;
  final String? turnDirection;

  PathDescription({
    this.coord,
    this.cumDistance,
    this.cumDuration,
    this.distance,
    this.distanceDown,
    this.distanceUp,
    this.duration,
    this.fromCoordsIndex,
    this.manoeuvre,
    this.name,
    this.skyDirection,
    this.toCoordsIndex,
    this.turnDirection,
  });

  factory PathDescription.fromJson(Map<String, dynamic> json) {
    final coord = tryParseCoordinatePair(tryReadMapValue(json, 'coord'));
    return PathDescription(
      coord: coord,
      cumDistance: tryParseIntValue(tryReadMapValue(json, 'cumDistance')),
      cumDuration: tryParseIntValue(tryReadMapValue(json, 'cumDuration')),
      distance: tryParseIntValue(tryReadMapValue(json, 'distance')),
      distanceDown: tryParseIntValue(tryReadMapValue(json, 'distanceDown')),
      distanceUp: tryParseIntValue(tryReadMapValue(json, 'distanceUp')),
      duration: tryParseIntValue(tryReadMapValue(json, 'duration')),
      fromCoordsIndex: tryParseIntValue(
        tryReadMapValue(json, 'fromCoordsIndex'),
      ),
      manoeuvre: tryReadStringValue(json, 'manoeuvre'),
      name: tryReadStringValue(json, 'name'),
      skyDirection: tryParseIntValue(tryReadMapValue(json, 'skyDirection')),
      toCoordsIndex: tryParseIntValue(tryReadMapValue(json, 'toCoordsIndex')),
      turnDirection: tryReadStringValue(json, 'turnDirection'),
    );
  }
}

class LegProperties {
  final String? differentFares;
  final String? planLowFloorVehicle;
  final String? planWheelChairAccess;
  final String? lineType;
  final List<String>? vehicleAccess;

  LegProperties({
    this.differentFares,
    this.planLowFloorVehicle,
    this.planWheelChairAccess,
    this.lineType,
    this.vehicleAccess,
  });

  factory LegProperties.fromJson(Map<String, dynamic> json) {
    final vehicleAccessRaw = tryReadListValue(json, 'vehicleAccess');
    return LegProperties(
      differentFares: tryReadStringValue(json, 'DIFFERENT_FARES'),
      planLowFloorVehicle: tryReadStringValue(json, 'PlanLowFloorVehicle'),
      planWheelChairAccess: tryReadStringValue(json, 'PlanWheelChairAccess'),
      lineType: tryReadStringValue(json, 'lineType'),
      vehicleAccess: _stringListOrNull(vehicleAccessRaw),
    );
  }
}
