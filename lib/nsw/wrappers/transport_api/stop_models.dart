part of '../transport_api_service_impl.dart';

class Stop {
  final String? arrivalTimeEstimated;
  final String? arrivalTimePlanned;
  final List<double>? coord;
  final String? departureTimeEstimated;
  final String? departureTimePlanned;
  final String? disassembledName;
  final String id;
  final String name;
  final Parent? parent;
  final StopProperties? properties;
  final String type;
  // Raw JSON that was used to populate this Stop (if available).
  final Map<String, dynamic> rawJson;

  Stop({
    this.arrivalTimeEstimated,
    this.arrivalTimePlanned,
    this.coord,
    this.departureTimeEstimated,
    this.departureTimePlanned,
    this.disassembledName,
    required this.id,
    required this.name,
    this.parent,
    this.properties,
    required this.type,
    this.rawJson = const <String, dynamic>{},
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    // --- coord (often nullable; some API responses omit it) ---
    final stopId = _readStringOrEmpty(json, 'id');
    List<double>? coord;
    final rawCoord = tryReadMapValue(json, 'coord');
    if (rawCoord != null) {
      if (rawCoord is! List) {
        logger.w(
          'Stop.fromJson: "coord" is not a List, type=${rawCoord.runtimeType} '
          'for stop id=$stopId',
        );
      } else {
        final parsedCoord = tryParseCoordinatePair(rawCoord);
        if (parsedCoord == null) {
          logger.w('Stop.fromJson: failed to parse coord for stop id=$stopId');
        } else {
          coord = parsedCoord;
        }
      }
    }

    // --- parent ---
    Parent? parent;
    final rawParent = tryReadMapValue(json, 'parent');
    if (rawParent != null) {
      if (rawParent is! Map<String, dynamic>) {
        logger.w(
          'Stop.fromJson: "parent" is not a Map, type=${rawParent.runtimeType} '
          'for stop id=$stopId',
        );
      } else {
        parent = Parent.fromJson(rawParent);
      }
    }

    // --- properties ---
    StopProperties? properties;
    final rawProps = tryReadMapValue(json, 'properties');
    if (rawProps != null) {
      if (rawProps is! Map<String, dynamic>) {
        logger.w(
          'Stop.fromJson: "properties" is not a Map, type=${rawProps.runtimeType} '
          'for stop id=$stopId',
        );
      } else {
        properties = StopProperties.fromJson(rawProps);
      }
    }

    return Stop(
      arrivalTimeEstimated: tryReadStringValue(json, 'arrivalTimeEstimated'),
      arrivalTimePlanned: tryReadStringValue(json, 'arrivalTimePlanned'),
      coord: coord,
      departureTimeEstimated: tryReadStringValue(
        json,
        'departureTimeEstimated',
      ),
      departureTimePlanned: tryReadStringValue(json, 'departureTimePlanned'),
      disassembledName: tryReadStringValue(json, 'disassembledName'),
      id: stopId,
      name: _readStringOrEmpty(json, 'name'),
      parent: parent,
      properties: properties,
      type: _readStringOrEmpty(json, 'type'),
      rawJson: json,
    );
  }
}

class Parent {
  final String? disassembledName;
  final String id;
  final String name;
  final Object? parent; // can be nested Parent or a simple id/string
  final String? type;

  Parent({
    this.disassembledName,
    required this.id,
    required this.name,
    this.parent,
    this.type,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    // If it's already a Parent instance, return it

    final rawParent = tryReadMapValue(json, 'parent');
    Object? parsedParent;
    if (rawParent != null) {
      if (rawParent is Map<String, dynamic>) {
        parsedParent = Parent.fromJson(rawParent);
      } else {
        parsedParent = rawParent.toString();
      }
    }
    // default
    return Parent(
      disassembledName: tryReadStringValue(json, 'disassembledName'),
      id: _readStringOrEmpty(json, 'id'),
      name: _readStringOrEmpty(json, 'name'),
      parent: parsedParent,
      type: tryReadStringValue(json, 'type'),
    );
  }
}

class StopProperties {
  final String? wheelchairAccess;
  final List<Download>? downloads;

  StopProperties({this.wheelchairAccess, this.downloads});

  factory StopProperties.fromJson(Map<String, dynamic> json) {
    final downloadsRaw = tryReadListValue(json, 'downloads');
    return StopProperties(
      wheelchairAccess: tryReadStringValue(json, 'WheelchairAccess'),
      downloads: _parseJsonList(downloadsRaw, Download.fromJson),
    );
  }
}

class Download {
  final String type;
  final String url;

  Download({required this.type, required this.url});

  factory Download.fromJson(Map<String, dynamic> json) {
    return Download(
      type: _readStringOrEmpty(json, 'type'),
      url: _readStringOrEmpty(json, 'url'),
    );
  }
}
