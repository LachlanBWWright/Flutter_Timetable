import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:option_result/option_result.dart';

import '../logs/logger.dart' as app_logger;
import '../services/api_key_service.dart';
import '../services/app_http_client.dart';
import '../utils/safe_value_utils.dart';

final logger = app_logger.safeLogger;

bool? _readBoolValue(Map<String, dynamic> json, String key) {
  final value = tryReadMapValue(json, key);
  if (value is bool) {
    return value;
  }
  if (value is String) {
    if (value.toLowerCase() == 'true') {
      return true;
    }
    if (value.toLowerCase() == 'false') {
      return false;
    }
  }
  return null;
}

String _readStringOrEmpty(Map<String, dynamic>? json, String key) {
  final value = tryReadStringValue(json, key);
  if (value == null) {
    return '';
  }
  return value;
}

int _listLength(Iterable<Object?>? values) {
  if (values == null) {
    return 0;
  }
  return values.length;
}

List<dynamic> _listOrEmpty(List<dynamic>? values) {
  if (values == null) {
    return const <dynamic>[];
  }
  return values;
}

List<String>? _stringListOrNull(List<dynamic>? values) {
  if (values == null) {
    return null;
  }
  return values.map((value) => value.toString()).toList();
}

List<T> _parseJsonList<T>(
  List<dynamic>? values,
  T? Function(Map<String, dynamic> json) parse,
) {
  if (values == null) {
    return <T>[];
  }

  return values
      .whereType<Map<String, dynamic>>()
      .map(parse)
      .whereType<T>()
      .toList();
}

T? _firstNonNull<T>(T? primary, T? fallback) {
  if (primary != null) {
    return primary;
  }
  return fallback;
}

Stop _unknownStop() {
  return Stop(
    id: '',
    name: 'Unknown',
    type: '',
    rawJson: const <String, dynamic>{},
  );
}

/// Service class for handling NSW Transport API requests
class TransportApiService {
  static const String _baseUrl = 'api.transport.nsw.gov.au';

  static const Map<String, String> _rapidJsonBaseParams = {
    'outputFormat': 'rapidJSON',
    'coordOutputFormat': 'EPSG:4326',
    'version': '10.2.1.42',
  };

  /// Get the effective API key (user override or built-in .env key).
  static Future<String?> _getApiKey() async {
    try {
      final key = ApiKeyService.getEffectiveApiKey();
      if (key.isEmpty) return null;
      return key;
    } catch (e, st) {
      logger.e('ApiKeyService.getEffectiveApiKey failed: $e');
      logger.e(st);
      return null;
    }
  }

  static Future<http.Response?> _authorizedGet(
    String path,
    Map<String, String> params,
  ) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      final uri = Uri.https(_baseUrl, path, params);
      return AppHttpClient.get(
        uri,
        headers: {'authorization': 'apikey $apiKey'},
      );
    } catch (e, st) {
      logger.w('Transport API request failed for $path: $e');
      logger.w(st);
      return null;
    }
  }

  /// Test if API key is valid
  static Future<bool> isApiKeyValid() async {
    try {
      final params = {
        ..._rapidJsonBaseParams,
        'type_sf': 'stop',
        'name_sf': '',
        'TfNSWSF': 'true',
      };

      final response = await _authorizedGet('/v1/tp/stop_finder/', params);
      if (response == null) return false;

      return response.statusCode == 200;
    } catch (e) {
      // Error validating API key
      return false;
    }
  }

  /// Search for stations/stops
  static Future<Result<List<Map<String, dynamic>>, String>> searchStations(
    String query,
  ) async {
    final params = {
      ..._rapidJsonBaseParams,
      'type_sf': 'any',
      'name_sf': query,
      'TfNSWSF': 'true',
    };

    final response = await _authorizedGet('/v1/tp/stop_finder/', params);
    if (response == null) {
      return const Err('API key not set');
    }

    try {
      if (response.statusCode != 200) {
        return Err(
          'Failed to search stations: ${response.statusCode}, ${response.body}',
        );
      }

      final data = tryDecodeJsonMap(response.body);
      if (data == null) {
        return const Err(
          'Failed to search stations: response was not a JSON object',
        );
      }
      final locations = _listOrEmpty(tryReadListValue(data, 'locations'));

      return Ok(
        locations.map((location) {
          final loc = location is Map<String, dynamic> ? location : null;
          final disassembledName = tryReadStringValue(loc, 'disassembledName');
          final fallbackName = _readStringOrEmpty(loc, 'name');
          final name = (disassembledName != null && disassembledName.isNotEmpty)
              ? disassembledName
              : fallbackName;
          final id = _readStringOrEmpty(loc, 'id');
          final type = tryReadStringValue(loc, 'type');
          return {
            'name': name,
            'displayName': fallbackName,
            'id': id,
            'type': type,
          };
        }).toList(),
      );
    } catch (e, st) {
      logger.e('Error searching stations: $e');
      logger.e(st);
      return Err(e.toString());
    }
  }

  /// Get trip information between two stations
  static Future<Result<GetTripsResponse, String>> getTrips({
    required String originId,
    required String destinationId,
  }) async {
    final params = {
      ..._rapidJsonBaseParams,
      'depArrMacro': 'dep',
      'type_origin': 'any',
      'name_origin': originId,
      'type_destination': 'any',
      'name_destination': destinationId,
      'calcNumberOfTrips': '20',
      'excludedMeans': 'checkbox',
      'exclMOT_7': '1',
      'exclMOT_11': '1',
      'TfNSWTR': 'true',
      'itOptionsActive': '0',
    };

    final response = await _authorizedGet('/v1/tp/trip/', params);
    if (response == null) {
      return const Err('API key not set');
    }

    try {
      logger.i('Response code ${response.statusCode}');

      if (response.statusCode != 200) {
        return Err(
          'Failed to get trips: ${response.statusCode}, ${response.body}',
        );
      }

      final data = tryDecodeJsonMap(response.body);
      if (data == null) {
        return const Err('Failed to get trips: response was not a JSON object');
      }
      final journeysCount = _listLength(tryReadListValue(data, 'journeys'));
      logger.i(
        'TransportApiService.getTrips: received $journeysCount journeys for origin=$originId destination=$destinationId',
      );
      return Ok(GetTripsResponse.fromJson(data));
    } catch (e, st) {
      logger.e('getTrips error: $e');
      logger.e(st);
      return Err(e.toString());
    }
  }
}

// Classes for getTrips response

class GetTripsResponse {
  final List<TripJourney> tripJourneys;
  final SystemMessages systemMessages;
  final String version;

  /// Raw JSON response as returned by the transport API.
  ///
  /// This is useful for debug/diagnostic features when the parsed model
  /// doesn't contain enough context.
  final Map<String, dynamic> rawJson;

  GetTripsResponse({
    required this.tripJourneys,
    required this.systemMessages,
    required this.version,
    required this.rawJson,
  });

  factory GetTripsResponse.fromJson(Map<String, dynamic> json) {
    // GetTripsResponse raw json keys logged (removed)

    final tripJourneys = <TripJourney>[];
    var systemMessages = const SystemMessages();
    var version = '';

    // Parse tripJourneys
    final journeysJson = tryReadListValue(json, 'journeys');
    if (journeysJson == null) {
      logger.w('GetTripsResponse.fromJson: "journeys" key is null or missing');
    } else {
      for (final entry in journeysJson.indexed) {
        final idx = entry.$1;
        final journey = entry.$2;
        if (journey is! Map<String, dynamic>) {
          logger.w(
            'GetTripsResponse.fromJson: journey #$idx is not a Map, type=${journey.runtimeType}',
          );
          logger.d('raw journey #$idx: ${jsonEncode(journey)}');
          continue;
        }
        try {
          final parsed = TripJourney.fromJson(journey);
          tripJourneys.add(parsed);
        } catch (e, st) {
          logger.e(
            'GetTripsResponse.fromJson: error parsing journey #$idx: $e',
          );
          logger.d('Stack: $st');
          logger.d('raw journey #$idx: ${jsonEncode(journey)}');
        }
      }
    }

    // Parse systemMessages (handle both list and object)
    final systemMessagesJson = tryReadMapValue(json, 'systemMessages');
    if (systemMessagesJson == null) {
      // systemMessages is null or missing
      // systemMessages type: ${systemMessagesJson.runtimeType}
    } else {
      // systemMessages type: ${systemMessagesJson.runtimeType}
      systemMessages = SystemMessages.fromJson(systemMessagesJson);
    }

    // Parse version
    version = _readStringOrEmpty(json, 'version');
    // version: $version
    if (version.isEmpty) {
      // version is null or missing
    }

    return GetTripsResponse(
      tripJourneys: tripJourneys,
      systemMessages: systemMessages,
      version: version,
      rawJson: json,
    );
  }
}

class TripJourney {
  final bool? isAdditional;
  final List<Leg> legs;
  final int? rating;
  // Keep the original raw JSON for this TripJourney as returned by the API.
  // This ensures that any unmapped or subsequently-added fields are retained
  // and accessible for debug/diagnostic features.
  final Map<String, dynamic> rawJson;

  TripJourney({
    this.isAdditional,
    required this.legs,
    this.rating,
    this.rawJson = const <String, dynamic>{},
  });

  factory TripJourney.fromJson(Map<String, dynamic> json) {
    // TripJourney raw json keys logged (removed)
    final legsJson = tryReadListValue(json, 'legs');
    if (legsJson == null) {
      logger.w(
        'TripJourney.fromJson: "legs" is null or missing for journey keys=${json.keys.toList()}',
      );
    }

    final List<Leg> legsList = [];
    if (legsJson != null) {
      for (final entry in legsJson.indexed) {
        final i = entry.$1;
        final legJson = entry.$2;
        if (legJson is! Map<String, dynamic>) {
          logger.w(
            'TripJourney.fromJson: leg #$i is not a Map, type=${legJson.runtimeType}',
          );
          logger.d('raw leg #$i: ${jsonEncode(legJson)}');
          // Skip malformed leg entries but preserve logging to aid debugging
          continue;
        }
        try {
          legsList.add(Leg.fromJson(legJson));
        } catch (e, st) {
          logger.e('TripJourney.fromJson: unhandled error parsing leg #$i: $e');
          logger.d('Stack: $st');
          logger.d('raw leg #$i keys: ${legJson.keys.toList()}');
        }
      }
    }
    return TripJourney(
      isAdditional: _readBoolValue(json, 'isAdditional'),
      legs: legsList,
      rating: tryParseIntValue(tryReadMapValue(json, 'rating')),
      rawJson: json,
    );
  }
}

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
  final dynamic parent; // can be nested Parent or a simple id/string
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
    dynamic parsedParent;
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

class Hint {
  final String? infoText;

  Hint({this.infoText});

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(infoText: tryReadStringValue(json, 'infoText'));
  }
}

class Info {
  final String? content;
  final String? id;
  final String? priority;
  final String? subtitle;
  final Timestamps? timestamps;
  final String? url;
  final String? urlText;
  // version is expected to be an integer (API often returns numeric versions).
  // Keep it as `int?` and coerce safely from string when necessary.
  final int? version;

  Info({
    this.content,
    this.id,
    this.priority,
    this.subtitle,
    this.timestamps,
    this.url,
    this.urlText,
    this.version,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    final timestampsJson = tryReadJsonMap(json, 'timestamps');
    Timestamps? timestamps;
    if (timestampsJson != null) {
      timestamps = Timestamps.fromJson(timestampsJson);
    }
    return Info(
      content: tryReadStringValue(json, 'content'),
      id: tryReadStringValue(json, 'id'),
      priority: tryReadStringValue(json, 'priority'),
      subtitle: tryReadStringValue(json, 'subtitle'),
      timestamps: timestamps,
      url: tryReadStringValue(json, 'url'),
      urlText: tryReadStringValue(json, 'urlText'),
      version: _parseInfoVersion(tryReadMapValue(json, 'version')),
    );
  }
}

int? _parseInfoVersion(Object? rawVersion) {
  if (rawVersion == null) {
    return null;
  }
  if (rawVersion is int) {
    return rawVersion;
  }
  if (rawVersion is String) {
    final parsed = int.tryParse(rawVersion);
    if (parsed == null) {
      logger.w(
        'Info.fromJson: could not parse version string to int: "$rawVersion"',
      );
    }
    return parsed;
  }
  logger.w(
    'Info.fromJson: unexpected type for version: ${rawVersion.runtimeType}',
  );
  return null;
}

class Timestamps {
  final Validity? availability;
  final String? creation;
  final String? lastModification;
  final List<Validity>? validity;

  Timestamps({
    this.availability,
    this.creation,
    this.lastModification,
    this.validity,
  });

  factory Timestamps.fromJson(Map<String, dynamic> json) {
    final validityRaw = tryReadListValue(json, 'validity');
    final availabilityJson = tryReadJsonMap(json, 'availability');
    Validity? availability;
    if (availabilityJson != null) {
      availability = Validity.fromJson(availabilityJson);
    }
    return Timestamps(
      availability: availability,
      creation: tryReadStringValue(json, 'creation'),
      lastModification: tryReadStringValue(json, 'lastModification'),
      validity: _parseJsonList(validityRaw, Validity.fromJson),
    );
  }
}

class Validity {
  final String? from;
  final String? to;

  Validity({this.from, this.to});

  factory Validity.fromJson(Map<String, dynamic> json) {
    return Validity(
      from: tryReadStringValue(json, 'from'),
      to: tryReadStringValue(json, 'to'),
    );
  }
}

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

class Transportation {
  final String? description;
  final TransportationDestination? destination;
  final String? disassembledName;
  final int? iconId;
  final String? id;
  final String? name;
  final String? number;
  final Operator? operator;
  final Product? product;
  final TransportationProperties? properties;
  // Raw JSON used to create this `Transportation` instance.
  final Map<String, dynamic> rawJson;

  Transportation({
    this.description,
    this.destination,
    this.disassembledName,
    this.iconId,
    this.id,
    this.name,
    this.number,
    this.operator,
    this.product,
    this.properties,
    this.rawJson = const <String, dynamic>{},
  });

  factory Transportation.fromJson(Map<String, dynamic> json) {
    TransportationDestination? destination;
    final destinationJson = tryReadJsonMap(json, 'destination');
    if (destinationJson != null) {
      destination = TransportationDestination.fromJson(destinationJson);
    }

    Operator? operator;
    final operatorJson = tryReadJsonMap(json, 'operator');
    if (operatorJson != null) {
      operator = Operator.fromJson(operatorJson);
    }

    Product? product;
    final productJson = tryReadJsonMap(json, 'product');
    if (productJson != null) {
      product = Product.fromJson(productJson);
    }

    TransportationProperties? properties;
    final propertiesJson = tryReadJsonMap(json, 'properties');
    if (propertiesJson != null) {
      properties = TransportationProperties.fromJson(propertiesJson);
    }

    return Transportation(
      description: tryReadStringValue(json, 'description'),
      destination: destination,
      disassembledName: tryReadStringValue(json, 'disassembledName'),
      iconId: tryParseIntValue(tryReadMapValue(json, 'iconId')),
      id: tryReadStringValue(json, 'id'),
      name: tryReadStringValue(json, 'name'),
      number: tryReadStringValue(json, 'number'),
      operator: operator,
      product: product,
      properties: properties,
      rawJson: json,
    );
  }
}

class TransportationDestination {
  final String? id;
  final String? name;

  TransportationDestination({this.id, this.name});

  factory TransportationDestination.fromJson(Map<String, dynamic> json) {
    return TransportationDestination(
      id: tryReadStringValue(json, 'id'),
      name: tryReadStringValue(json, 'name'),
    );
  }
}

class Operator {
  final String? id;
  final String? name;

  Operator({this.id, this.name});

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: tryReadStringValue(json, 'id'),
      name: tryReadStringValue(json, 'name'),
    );
  }
}

class Product {
  final int? classField;
  final int? iconId;
  final String? name;

  Product({this.classField, this.iconId, this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      classField: tryParseIntValue(tryReadMapValue(json, 'class')),
      iconId: tryParseIntValue(tryReadMapValue(json, 'iconId')),
      name: tryReadStringValue(json, 'name'),
    );
  }
}

class TransportationProperties {
  final bool? isTTB;
  final int? tripCode;

  TransportationProperties({this.isTTB, this.tripCode});

  factory TransportationProperties.fromJson(Map<String, dynamic> json) {
    return TransportationProperties(
      isTTB: _readBoolValue(json, 'isTTB'),
      tripCode: tryParseIntValue(tryReadMapValue(json, 'tripCode')),
    );
  }
}

class SystemMessages {
  final List<ResponseMessage> responseMessages;

  const SystemMessages({this.responseMessages = const []});

  factory SystemMessages.fromJson(Object json) {
    // If json is a List, treat it as the list of messages directly
    if (json is List) {
      return SystemMessages(
        responseMessages: json
            .whereType<Map<String, dynamic>>()
            .map(ResponseMessage.fromJson)
            .whereType<ResponseMessage>()
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      if (json.containsKey('responseMessages')) {
        final responseMessagesRaw = tryReadListValue(json, 'responseMessages');
        return SystemMessages(
          responseMessages: _parseJsonList(
            responseMessagesRaw,
            ResponseMessage.fromJson,
          ),
        );
      } else {
        return SystemMessages(
          responseMessages: [ResponseMessage.fromJson(json)],
        );
      }
    }
    return const SystemMessages(responseMessages: []);
  }
}

class ResponseMessage {
  final int? code;
  final String? error;
  final String? module;
  final String? type;
  // Some API responses include 'text' and 'subType' instead of 'error'/'type'.
  // Keep these fields to preserve the raw values and provide backward-compatible
  // fallback when 'error' or 'type' are missing.
  final String? text;
  final String? subType;

  ResponseMessage({
    this.code,
    this.error,
    this.module,
    this.type,
    this.text,
    this.subType,
  });

  factory ResponseMessage.fromJson(Map<String, dynamic> json) {
    final rawText = tryReadStringValue(json, 'text');
    final rawError = tryReadStringValue(json, 'error');
    return ResponseMessage(
      code: tryParseIntValue(tryReadMapValue(json, 'code')),
      error: _firstNonNull(rawError, rawText),
      module: tryReadStringValue(json, 'module'),
      type: tryReadStringValue(json, 'type'),
      text: rawText,
      subType: tryReadStringValue(json, 'subType'),
    );
  }
}
