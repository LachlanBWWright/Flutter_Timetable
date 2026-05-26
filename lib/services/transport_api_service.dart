import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart' show Logger;
import 'package:option_result/option_result.dart';
import '../logs/logger.dart' as app_logger;
import '../utils/safe_value_utils.dart';
import 'api_key_service.dart';

final logger = _SafeLogger(app_logger.logger);

class _SafeLogger {
  const _SafeLogger(this._logger);

  final Logger _logger;

  void d(Object? message) {
    try {
      _logger.d(message);
    } catch (_) {}
  }

  void e(Object? message) {
    try {
      _logger.e(message);
    } catch (_) {}
  }

  void i(Object? message) {
    try {
      _logger.i(message);
    } catch (_) {}
  }

  void w(Object? message) {
    try {
      _logger.w(message);
    } catch (_) {}
  }
}

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
      return http.get(uri, headers: {'authorization': 'apikey $apiKey'});
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
      final locationsRaw = tryReadListValue(data, 'locations');
      final locations = locationsRaw ?? const [];

      return Ok(
        locations.map((location) {
          final loc = location is Map<String, dynamic> ? location : null;
          final disassembledName = tryReadStringValue(loc, 'disassembledName');
          final fallbackName = tryReadStringValue(loc, 'name') ?? '';
          final name = (disassembledName != null && disassembledName.isNotEmpty)
              ? disassembledName
              : fallbackName;
          final id = tryReadStringValue(loc, 'id') ?? '';
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
      final journeys = tryReadListValue(data, 'journeys');
      final journeysCount = journeys?.length ?? 0;
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

    List<TripJourney> tripJourneys = [];
    SystemMessages? systemMessages;
    String? version;

    // Parse tripJourneys
    final journeysJson = tryReadListValue(json, 'journeys');
    if (journeysJson == null) {
      logger.w('GetTripsResponse.fromJson: "journeys" key is null or missing');
    } else {
      tripJourneys = [];
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
    try {
      final systemMessagesJson = tryReadMapValue(json, 'systemMessages');
      if (systemMessagesJson == null) {
        // systemMessages is null or missing
        // systemMessages type: ${systemMessagesJson.runtimeType}
      } else {
        // systemMessages type: ${systemMessagesJson.runtimeType}
        systemMessages = SystemMessages.fromJson(systemMessagesJson);
      }
    } catch (e) {
      // Exception while parsing systemMessages: $e
    }

    // Parse version
    try {
      version = tryReadStringValue(json, 'version');
      // version: $version
      if (version == null) {
        // version is null or missing
      }
    } catch (e) {
      // Exception while parsing version: $e
    }

    // Defensive: if systemMessages is still null, use an empty one
    systemMessages ??= SystemMessages(responseMessages: []);
    return GetTripsResponse(
      tripJourneys: tripJourneys,
      systemMessages: systemMessages,
      version: version ?? '',
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
  final Map<String, dynamic>? rawJson;

  TripJourney({
    this.isAdditional,
    required this.legs,
    this.rating,
    this.rawJson,
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
  final Map<String, dynamic>? rawJson;

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
    this.rawJson,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    // Each field is parsed independently so that a malformed value for one
    // field never silently drops an entire leg. Failures are logged with the
    // field name, expected/actual type, and raw value to aid debugging.

    // --- coords ---
    List<List<double>>? coords;
    try {
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
    } catch (e) {
      logger.w('Leg.fromJson: unexpected error parsing "coords": $e');
    }

    // --- origin (required) ---
    Stop origin;
    try {
      final rawOrigin = json['origin'];
      if (rawOrigin is! Map<String, dynamic>) {
        logger.e(
          'Leg.fromJson: "origin" is not a Map, type=${rawOrigin?.runtimeType}; using placeholder',
        );
        origin = Stop(id: '', name: 'Unknown', type: '');
      } else {
        origin = Stop.fromJson(rawOrigin);
      }
    } catch (e) {
      logger.e('Leg.fromJson: failed to parse "origin": $e; using placeholder');
      origin = Stop(id: '', name: 'Unknown', type: '');
    }

    // --- destination (required) ---
    Stop destination;
    try {
      final rawDest = json['destination'];
      if (rawDest is! Map<String, dynamic>) {
        logger.e(
          'Leg.fromJson: "destination" is not a Map, type=${rawDest?.runtimeType}; using placeholder',
        );
        destination = Stop(id: '', name: 'Unknown', type: '');
      } else {
        destination = Stop.fromJson(rawDest);
      }
    } catch (e) {
      logger.e(
        'Leg.fromJson: failed to parse "destination": $e; using placeholder',
      );
      destination = Stop(id: '', name: 'Unknown', type: '');
    }

    // --- distance ---
    int? distance;
    try {
      final raw = json['distance'];
      if (raw is int) {
        distance = raw;
      } else if (raw is String) {
        distance = int.tryParse(raw);
      } else if (raw != null) {
        logger.w(
          'Leg.fromJson: "distance" has unexpected type ${raw.runtimeType}',
        );
      }
    } catch (e) {
      logger.w('Leg.fromJson: failed to parse "distance": $e');
    }

    // --- duration ---
    int? duration;
    try {
      final raw = json['duration'];
      if (raw is int) {
        duration = raw;
      } else if (raw is String) {
        duration = int.tryParse(raw);
      } else if (raw != null) {
        logger.w(
          'Leg.fromJson: "duration" has unexpected type ${raw.runtimeType}',
        );
      }
    } catch (e) {
      logger.w('Leg.fromJson: failed to parse "duration": $e');
    }

    // --- footPathInfo ---
    List<FootPathInfo>? footPathInfo;
    try {
      final raw = tryReadListValue(json, 'footPathInfo');
      if (raw != null) {
        footPathInfo = [];
        for (final entry in raw.indexed) {
          final i = entry.$1;
          final rawValue = entry.$2;
          try {
            if (rawValue is! Map<String, dynamic>) {
              logger.w('Leg.fromJson: footPathInfo[$i] is not a Map; skipping');
              continue;
            }
            footPathInfo.add(FootPathInfo.fromJson(rawValue));
          } catch (e) {
            logger.w('Leg.fromJson: failed to parse footPathInfo[$i]: $e');
          }
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: unexpected error parsing "footPathInfo": $e');
    }

    // --- hints ---
    List<Hint>? hints;
    try {
      final raw = tryReadListValue(json, 'hints');
      if (raw != null) {
        hints = [];
        for (final entry in raw.indexed) {
          final i = entry.$1;
          final rawValue = entry.$2;
          try {
            if (rawValue is! Map<String, dynamic>) {
              logger.w('Leg.fromJson: hints[$i] is not a Map; skipping');
              continue;
            }
            hints.add(Hint.fromJson(rawValue));
          } catch (e) {
            logger.w('Leg.fromJson: failed to parse hints[$i]: $e');
          }
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: unexpected error parsing "hints": $e');
    }

    // --- infos ---
    List<Info>? infos;
    try {
      final raw = tryReadListValue(json, 'infos');
      if (raw != null) {
        infos = [];
        for (final entry in raw.indexed) {
          final i = entry.$1;
          final rawValue = entry.$2;
          try {
            if (rawValue is! Map<String, dynamic>) {
              logger.w('Leg.fromJson: infos[$i] is not a Map; skipping');
              continue;
            }
            infos.add(Info.fromJson(rawValue));
          } catch (e) {
            logger.w('Leg.fromJson: failed to parse infos[$i]: $e');
          }
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: unexpected error parsing "infos": $e');
    }

    // --- interchange ---
    Interchange? interchange;
    try {
      final raw = json['interchange'];
      if (raw != null) {
        if (raw is! Map<String, dynamic>) {
          logger.w(
            'Leg.fromJson: "interchange" is not a Map, type=${raw.runtimeType}',
          );
        } else {
          interchange = Interchange.fromJson(raw);
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: failed to parse "interchange": $e');
    }

    // --- isRealtimeControlled ---
    bool? isRealtimeControlled;
    try {
      isRealtimeControlled = json['isRealtimeControlled'] as bool?;
    } catch (e) {
      logger.w('Leg.fromJson: failed to parse "isRealtimeControlled": $e');
    }

    // --- pathDescriptions ---
    List<PathDescription>? pathDescriptions;
    try {
      final raw = tryReadListValue(json, 'pathDescriptions');
      if (raw != null) {
        pathDescriptions = [];
        for (final entry in raw.indexed) {
          final i = entry.$1;
          final rawValue = entry.$2;
          try {
            if (rawValue is! Map<String, dynamic>) {
              logger.w(
                'Leg.fromJson: pathDescriptions[$i] is not a Map; skipping',
              );
              continue;
            }
            pathDescriptions.add(PathDescription.fromJson(rawValue));
          } catch (e) {
            logger.w('Leg.fromJson: failed to parse pathDescriptions[$i]: $e');
          }
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: unexpected error parsing "pathDescriptions": $e');
    }

    // --- properties ---
    LegProperties? properties;
    try {
      final raw = json['properties'];
      if (raw != null) {
        if (raw is! Map<String, dynamic>) {
          logger.w(
            'Leg.fromJson: "properties" is not a Map, type=${raw.runtimeType}',
          );
        } else {
          properties = LegProperties.fromJson(raw);
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: failed to parse "properties": $e');
    }

    // --- stopSequence ---
    List<Stop>? stopSequence;
    try {
      final raw = tryReadListValue(json, 'stopSequence');
      if (raw != null) {
        stopSequence = [];
        for (final entry in raw.indexed) {
          final i = entry.$1;
          final stopJson = entry.$2;
          if (stopJson is! Map<String, dynamic>) {
            logger.w(
              'Leg.fromJson: stopSequence[$i] is not a Map, type=${stopJson.runtimeType}; skipping',
            );
            continue;
          }
          try {
            stopSequence.add(Stop.fromJson(stopJson));
          } catch (e) {
            logger.w('Leg.fromJson: failed to parse stopSequence[$i]: $e');
          }
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: unexpected error parsing "stopSequence": $e');
    }

    // --- transportation ---
    Transportation? transportation;
    try {
      final raw = json['transportation'];
      if (raw != null) {
        if (raw is! Map<String, dynamic>) {
          logger.w(
            'Leg.fromJson: "transportation" is not a Map, type=${raw.runtimeType}',
          );
        } else {
          transportation = Transportation.fromJson(raw);
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: failed to parse "transportation": $e');
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
  final Map<String, dynamic>? rawJson;

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
    this.rawJson,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    // --- coord (often nullable; some API responses omit it) ---
    final stopId = tryReadStringValue(json, 'id') ?? '';
    List<double>? coord;
    try {
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
            logger.w(
              'Stop.fromJson: failed to parse coord for stop id=$stopId',
            );
          } else {
            coord = parsedCoord;
          }
        }
      }
    } catch (e) {
      logger.w(
        'Stop.fromJson: unexpected error parsing "coord": $e for stop id=$stopId',
      );
    }

    // --- parent ---
    Parent? parent;
    try {
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
    } catch (e) {
      logger.w(
        'Stop.fromJson: failed to parse "parent": $e for stop id=$stopId',
      );
    }

    // --- properties ---
    StopProperties? properties;
    try {
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
    } catch (e) {
      logger.w(
        'Stop.fromJson: failed to parse "properties": $e for stop id=$stopId',
      );
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
      name: tryReadStringValue(json, 'name') ?? '',
      parent: parent,
      properties: properties,
      type: tryReadStringValue(json, 'type') ?? '',
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
      id: tryReadStringValue(json, 'id') ?? '',
      name: tryReadStringValue(json, 'name') ?? '',
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
      downloads: downloadsRaw
          ?.whereType<Map<String, dynamic>>()
          .map((download) {
            try {
              return Download.fromJson(download);
            } catch (e) {
              logger.w('StopProperties.fromJson: failed to parse download: $e');
              return null;
            }
          })
          .whereType<Download>()
          .toList(),
    );
  }
}

class Download {
  final String type;
  final String url;

  Download({required this.type, required this.url});

  factory Download.fromJson(Map<String, dynamic> json) {
    return Download(
      type: tryReadStringValue(json, 'type') ?? '',
      url: tryReadStringValue(json, 'url') ?? '',
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
      footPathElem: footPathElemRaw
          ?.whereType<Map<String, dynamic>>()
          .map((elem) {
            try {
              return FootPathElem.fromJson(elem);
            } catch (e) {
              logger.w(
                'FootPathInfo.fromJson: failed to parse footPathElem: $e',
              );
              return null;
            }
          })
          .whereType<FootPathElem>()
          .toList(),
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
      try {
        destination = FootpathElemDestination.fromJson(destinationJson);
      } catch (e) {
        logger.w('FootPathElem.fromJson: failed to parse destination: $e');
      }
    }
    FootpathElemOrigin? origin;
    if (originJson != null) {
      try {
        origin = FootpathElemOrigin.fromJson(originJson);
      } catch (e) {
        logger.w('FootPathElem.fromJson: failed to parse origin: $e');
      }
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
      try {
        location = FootpathElemLocation.fromJson(locationJson);
      } catch (e) {
        logger.w(
          'FootpathElemDestination.fromJson: failed to parse location: $e',
        );
      }
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
      try {
        location = FootpathElemLocation.fromJson(locationJson);
      } catch (e) {
        logger.w('FootpathElemOrigin.fromJson: failed to parse location: $e');
      }
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
    List<double>? coord;
    try {
      coord = tryParseCoordinatePair(tryReadMapValue(json, 'coord'));
    } catch (e) {
      logger.w('FootpathElemLocation.fromJson: failed to parse coord: $e');
    }
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
      try {
        timestamps = Timestamps.fromJson(timestampsJson);
      } catch (e) {
        logger.w('Info.fromJson: failed to parse timestamps: $e');
      }
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
      try {
        availability = Validity.fromJson(availabilityJson);
      } catch (e) {
        logger.w('Timestamps.fromJson: failed to parse availability: $e');
      }
    }
    return Timestamps(
      availability: availability,
      creation: tryReadStringValue(json, 'creation'),
      lastModification: tryReadStringValue(json, 'lastModification'),
      validity: validityRaw
          ?.whereType<Map<String, dynamic>>()
          .map((v) {
            try {
              return Validity.fromJson(v);
            } catch (e) {
              logger.w('Timestamps.fromJson: failed to parse validity: $e');
              return null;
            }
          })
          .whereType<Validity>()
          .toList(),
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
    List<List<double>>? coords;
    try {
      coords = tryParseDoubleMatrix(
        tryReadMapValue(json, 'coords'),
        minLengthPerRow: 2,
      );
    } catch (e) {
      logger.w('Interchange.fromJson: failed to parse coords: $e');
    }
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
    List<double>? coord;
    try {
      coord = tryParseCoordinatePair(tryReadMapValue(json, 'coord'));
    } catch (e) {
      logger.w('PathDescription.fromJson: failed to parse coord: $e');
    }
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
      vehicleAccess: vehicleAccessRaw?.map((v) => v.toString()).toList(),
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
  final Map<String, dynamic>? rawJson;

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
    this.rawJson,
  });

  factory Transportation.fromJson(Map<String, dynamic> json) {
    TransportationDestination? destination;
    final destinationJson = tryReadJsonMap(json, 'destination');
    if (destinationJson != null) {
      try {
        destination = TransportationDestination.fromJson(destinationJson);
      } catch (e) {
        logger.w('Transportation.fromJson: failed to parse destination: $e');
      }
    }

    Operator? operator;
    final operatorJson = tryReadJsonMap(json, 'operator');
    if (operatorJson != null) {
      try {
        operator = Operator.fromJson(operatorJson);
      } catch (e) {
        logger.w('Transportation.fromJson: failed to parse operator: $e');
      }
    }

    Product? product;
    final productJson = tryReadJsonMap(json, 'product');
    if (productJson != null) {
      try {
        product = Product.fromJson(productJson);
      } catch (e) {
        logger.w('Transportation.fromJson: failed to parse product: $e');
      }
    }

    TransportationProperties? properties;
    final propertiesJson = tryReadJsonMap(json, 'properties');
    if (propertiesJson != null) {
      try {
        properties = TransportationProperties.fromJson(propertiesJson);
      } catch (e) {
        logger.w('Transportation.fromJson: failed to parse properties: $e');
      }
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
  final List<ResponseMessage>? responseMessages;

  SystemMessages({this.responseMessages});

  factory SystemMessages.fromJson(Object json) {
    // If json is a List, treat it as the list of messages directly
    if (json is List) {
      return SystemMessages(
        responseMessages: json
            .whereType<Map<String, dynamic>>()
            .map((msg) {
              try {
                return ResponseMessage.fromJson(msg);
              } catch (e) {
                logger.w(
                  'SystemMessages.fromJson: failed to parse message: $e',
                );
                return null;
              }
            })
            .whereType<ResponseMessage>()
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      if (json.containsKey('responseMessages')) {
        final responseMessagesRaw = tryReadListValue(json, 'responseMessages');
        return SystemMessages(
          responseMessages: responseMessagesRaw
              ?.whereType<Map<String, dynamic>>()
              .map((message) {
                try {
                  return ResponseMessage.fromJson(message);
                } catch (e) {
                  logger.w(
                    'SystemMessages.fromJson: failed to parse message: $e',
                  );
                  return null;
                }
              })
              .whereType<ResponseMessage>()
              .toList(),
        );
      } else {
        try {
          return SystemMessages(
            responseMessages: [ResponseMessage.fromJson(json)],
          );
        } catch (e) {
          logger.w(
            'SystemMessages.fromJson: failed to parse single message: $e',
          );
          return SystemMessages(responseMessages: []);
        }
      }
    }
    return SystemMessages(responseMessages: []);
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
      error: rawError ?? rawText,
      module: tryReadStringValue(json, 'module'),
      type: tryReadStringValue(json, 'type'),
      text: rawText,
      subType: tryReadStringValue(json, 'subType'),
    );
  }
}
