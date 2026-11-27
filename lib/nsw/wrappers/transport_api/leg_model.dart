part of '../transport_api_service_impl.dart';

class Leg {
  final List<List<double>>? coords;
  final Stop destination;
  final int? distance;
  final int? duration;
  final List<FootPathInfo>? footPathInfo;
  final List<Hint>? hints;
  final List<Info>? infos;
  final Interchange? interchange;
  final bool? isRealtimeControlled;
  final Stop origin;
  final List<PathDescription>? pathDescriptions;
  final LegProperties? properties;
  final List<Stop>? stopSequence;
  final Transportation? transportation;
  // Keep the raw API JSON for the leg to preserve any fields not mapped into
  // explicit model properties (e.g., realtimeStatus, niveau, etc.).
  final Map<String, dynamic> rawJson;

  Leg({
    this.coords,
    required this.destination,
    this.distance,
    this.duration,
    this.footPathInfo,
    this.hints,
    this.infos,
    this.interchange,
    this.isRealtimeControlled,
    required this.origin,
    this.pathDescriptions,
    this.properties,
    this.stopSequence,
    this.transportation,
    this.rawJson = const <String, dynamic>{},
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    // Each field is parsed independently so that a malformed value for one
    // field never silently drops an entire leg. Failures are logged with the
    // field name, expected/actual type, and raw value to aid debugging.

    // --- coords ---
    List<List<double>>? coords;
    final rawCoords = tryReadListValue(json, 'coords');
    if (rawCoords != null) {
      coords = [];
      for (final entry in rawCoords.indexed) {
        final ci = entry.$1;
        final rawCoord = entry.$2;
        final parsedCoord = tryParseDoubleList(rawCoord, minLength: 2);
        if (parsedCoord == null) {
          logger.w('Leg.fromJson: failed to parse coords[$ci]');
          continue;
        }
        coords.add(parsedCoord);
      }
    }

    // --- origin (required) ---
    Stop origin;
    final rawOrigin = tryReadMapValue(json, 'origin');
    if (rawOrigin is! Map<String, dynamic>) {
      logger.e(
        'Leg.fromJson: "origin" is not a Map, type=${rawOrigin == null ? 'null' : rawOrigin.runtimeType}; using placeholder',
      );
      origin = _unknownStop();
    } else {
      origin = Stop.fromJson(rawOrigin);
    }

    // --- destination (required) ---
    Stop destination;
    final rawDestination = tryReadMapValue(json, 'destination');
    if (rawDestination is! Map<String, dynamic>) {
      logger.e(
        'Leg.fromJson: "destination" is not a Map, type=${rawDestination == null ? 'null' : rawDestination.runtimeType}; using placeholder',
      );
      destination = _unknownStop();
    } else {
      destination = Stop.fromJson(rawDestination);
    }

    // --- distance ---
    int? distance;
    final rawDistance = tryReadMapValue(json, 'distance');
    if (rawDistance is int) {
      distance = rawDistance;
    } else if (rawDistance is String) {
      distance = int.tryParse(rawDistance);
    } else if (rawDistance != null) {
      logger.w(
        'Leg.fromJson: "distance" has unexpected type ${rawDistance.runtimeType}',
      );
    }

    // --- duration ---
    int? duration;
    final rawDuration = tryReadMapValue(json, 'duration');
    if (rawDuration is int) {
      duration = rawDuration;
    } else if (rawDuration is String) {
      duration = int.tryParse(rawDuration);
    } else if (rawDuration != null) {
      logger.w(
        'Leg.fromJson: "duration" has unexpected type ${rawDuration.runtimeType}',
      );
    }

    // --- footPathInfo ---
    List<FootPathInfo>? footPathInfo;
    final rawFootPathInfo = tryReadListValue(json, 'footPathInfo');
    if (rawFootPathInfo != null) {
      footPathInfo = [];
      for (final entry in rawFootPathInfo.indexed) {
        final i = entry.$1;
        final rawValue = entry.$2;
        if (rawValue is! Map<String, dynamic>) {
          logger.w('Leg.fromJson: footPathInfo[$i] is not a Map; skipping');
          continue;
        }
        footPathInfo.add(FootPathInfo.fromJson(rawValue));
      }
    }

    // --- hints ---
    List<Hint>? hints;
    final rawHints = tryReadListValue(json, 'hints');
    if (rawHints != null) {
      hints = [];
      for (final entry in rawHints.indexed) {
        final i = entry.$1;
        final rawValue = entry.$2;
        if (rawValue is! Map<String, dynamic>) {
          logger.w('Leg.fromJson: hints[$i] is not a Map; skipping');
          continue;
        }
        hints.add(Hint.fromJson(rawValue));
      }
    }

    // --- infos ---
    List<Info>? infos;
    final rawInfos = tryReadListValue(json, 'infos');
    if (rawInfos != null) {
      infos = [];
      for (final entry in rawInfos.indexed) {
        final i = entry.$1;
        final rawValue = entry.$2;
        if (rawValue is! Map<String, dynamic>) {
          logger.w('Leg.fromJson: infos[$i] is not a Map; skipping');
          continue;
        }
        infos.add(Info.fromJson(rawValue));
      }
    }

    // --- interchange ---
    Interchange? interchange;
    final rawInterchange = tryReadMapValue(json, 'interchange');
    if (rawInterchange != null) {
      if (rawInterchange is! Map<String, dynamic>) {
        logger.w(
          'Leg.fromJson: "interchange" is not a Map, type=${rawInterchange.runtimeType}',
        );
      } else {
        interchange = Interchange.fromJson(rawInterchange);
      }
    }

    // --- isRealtimeControlled ---
    final isRealtimeControlled = _readBoolValue(json, 'isRealtimeControlled');

    // --- pathDescriptions ---
    List<PathDescription>? pathDescriptions;
    final rawPathDescriptions = tryReadListValue(json, 'pathDescriptions');
    if (rawPathDescriptions != null) {
      pathDescriptions = [];
      for (final entry in rawPathDescriptions.indexed) {
        final i = entry.$1;
        final rawValue = entry.$2;
        if (rawValue is! Map<String, dynamic>) {
          logger.w('Leg.fromJson: pathDescriptions[$i] is not a Map; skipping');
          continue;
        }
        pathDescriptions.add(PathDescription.fromJson(rawValue));
      }
    }

    // --- properties ---
    LegProperties? properties;
    final rawProperties = tryReadMapValue(json, 'properties');
    if (rawProperties != null) {
      if (rawProperties is! Map<String, dynamic>) {
        logger.w(
          'Leg.fromJson: "properties" is not a Map, type=${rawProperties.runtimeType}',
        );
      } else {
        properties = LegProperties.fromJson(rawProperties);
      }
    }

    // --- stopSequence ---
    List<Stop>? stopSequence;
    final rawStopSequence = tryReadListValue(json, 'stopSequence');
    if (rawStopSequence != null) {
      stopSequence = [];
      for (final entry in rawStopSequence.indexed) {
        final i = entry.$1;
        final stopJson = entry.$2;
        if (stopJson is! Map<String, dynamic>) {
          logger.w(
            'Leg.fromJson: stopSequence[$i] is not a Map, type=${stopJson.runtimeType}; skipping',
          );
          continue;
        }
        stopSequence.add(Stop.fromJson(stopJson));
      }
    }

    // --- transportation ---
    Transportation? transportation;
    final rawTransportation = tryReadMapValue(json, 'transportation');
    if (rawTransportation != null) {
      if (rawTransportation is! Map<String, dynamic>) {
        logger.w(
          'Leg.fromJson: "transportation" is not a Map, type=${rawTransportation.runtimeType}',
        );
      } else {
        transportation = Transportation.fromJson(rawTransportation);
      }
    }

    return Leg(
      coords: coords,
      destination: destination,
      distance: distance,
      duration: duration,
      footPathInfo: footPathInfo,
      hints: hints,
      infos: infos,
      interchange: interchange,
      isRealtimeControlled: isRealtimeControlled,
      origin: origin,
      pathDescriptions: pathDescriptions,
      properties: properties,
      stopSequence: stopSequence,
      transportation: transportation,
      rawJson: json,
    );
  }
}
