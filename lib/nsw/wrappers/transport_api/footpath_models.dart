part of '../transport_api_service_impl.dart';

class FootPathInfo {
  final int? duration;
  final List<FootPathElem>? footPathElem;
  final String? position;

  FootPathInfo({this.duration, this.footPathElem, this.position});

  factory FootPathInfo.fromJson(Map<String, dynamic> json) {
    final footPathElemRaw = tryReadListValue(json, 'footPathElem');
    return FootPathInfo(
      duration: tryParseIntValue(tryReadMapValue(json, 'duration')),
      footPathElem: _parseJsonList(footPathElemRaw, FootPathElem.fromJson),
      position: tryReadStringValue(json, 'position'),
    );
  }
}

class FootPathElem {
  final String? description;
  final FootpathElemDestination? destination;
  final String? level;
  final int? levelFrom;
  final int? levelTo;
  final FootpathElemOrigin? origin;
  final String? type;

  FootPathElem({
    this.description,
    this.destination,
    this.level,
    this.levelFrom,
    this.levelTo,
    this.origin,
    this.type,
  });

  factory FootPathElem.fromJson(Map<String, dynamic> json) {
    final destinationJson = tryReadJsonMap(json, 'destination');
    final originJson = tryReadJsonMap(json, 'origin');
    FootpathElemDestination? destination;
    if (destinationJson != null) {
      destination = FootpathElemDestination.fromJson(destinationJson);
    }
    FootpathElemOrigin? origin;
    if (originJson != null) {
      origin = FootpathElemOrigin.fromJson(originJson);
    }
    return FootPathElem(
      description: tryReadStringValue(json, 'description'),
      destination: destination,
      level: tryReadStringValue(json, 'level'),
      levelFrom: tryParseIntValue(tryReadMapValue(json, 'levelFrom')),
      levelTo: tryParseIntValue(tryReadMapValue(json, 'levelTo')),
      origin: origin,
      type: tryReadStringValue(json, 'type'),
    );
  }
}

class FootpathElemDestination {
  final int? area;
  final String? georef;
  final FootpathElemLocation? location;
  final int? platform;

  FootpathElemDestination({
    this.area,
    this.georef,
    this.location,
    this.platform,
  });

  factory FootpathElemDestination.fromJson(Map<String, dynamic> json) {
    final locationJson = tryReadJsonMap(json, 'location');
    FootpathElemLocation? location;
    if (locationJson != null) {
      location = FootpathElemLocation.fromJson(locationJson);
    }
    return FootpathElemDestination(
      area: tryParseIntValue(tryReadMapValue(json, 'area')),
      georef: tryReadStringValue(json, 'georef'),
      location: location,
      platform: tryParseIntValue(tryReadMapValue(json, 'platform')),
    );
  }
}

class FootpathElemOrigin {
  final int? area;
  final String? georef;
  final FootpathElemLocation? location;
  final int? platform;

  FootpathElemOrigin({this.area, this.georef, this.location, this.platform});

  factory FootpathElemOrigin.fromJson(Map<String, dynamic> json) {
    final locationJson = tryReadJsonMap(json, 'location');
    FootpathElemLocation? location;
    if (locationJson != null) {
      location = FootpathElemLocation.fromJson(locationJson);
    }
    return FootpathElemOrigin(
      area: tryParseIntValue(tryReadMapValue(json, 'area')),
      georef: tryReadStringValue(json, 'georef'),
      location: location,
      platform: tryParseIntValue(tryReadMapValue(json, 'platform')),
    );
  }
}

class FootpathElemLocation {
  final List<double>? coord;
  final String? id;
  final String? type;

  FootpathElemLocation({this.coord, this.id, this.type});

  factory FootpathElemLocation.fromJson(Map<String, dynamic> json) {
    final coord = tryParseCoordinatePair(tryReadMapValue(json, 'coord'));
    return FootpathElemLocation(
      coord: coord,
      id: tryReadStringValue(json, 'id'),
      type: tryReadStringValue(json, 'type'),
    );
  }
}
