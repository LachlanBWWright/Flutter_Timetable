import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:option_result/option_result.dart';
import '../logs/logger.dart';
import 'api_key_service.dart';

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
    final key = ApiKeyService.getEffectiveApiKey();
    return key.isEmpty ? null : key;
  }

  static Future<http.Response?> _authorizedGet(
    String path,
    Map<String, String> params,
  ) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    final uri = Uri.https(_baseUrl, path, params);
    return http.get(uri, headers: {'authorization': 'apikey $apiKey'});
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final locations = (data['locations'] as List?) ?? [];

      return Ok(
        locations.map((location) {
          final Map<String, dynamic>? loc = location as Map<String, dynamic>?;
          final name =
              (loc?['disassembledName'] ?? loc?['name'])?.toString() ?? '';
          final id = loc?['id']?.toString() ?? '';
          return {'name': name, 'id': id};
        }).toList(),
      );
    } catch (e) {
      logger.e('Error searching stations: $e');
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final journeys = data['journeys'];
      final journeysCount = journeys is List ? journeys.length : 0;
      logger.i(
        'TransportApiService.getTrips: received $journeysCount journeys for origin=$originId destination=$destinationId',
      );
      return Ok(GetTripsResponse.fromJson(data));
    } catch (e, st) {
      logger.e(e);
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
    final journeysJson = json['journeys'];
    if (journeysJson == null) {
      logger.w('GetTripsResponse.fromJson: "journeys" key is null or missing');
    } else if (journeysJson is! List) {
      logger.w(
        'GetTripsResponse.fromJson: "journeys" is not a List, type=${journeysJson.runtimeType}',
      );
    } else {
      tripJourneys = [];
      for (var idx = 0; idx < journeysJson.length; idx++) {
        final journey = journeysJson[idx];
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
      final systemMessagesJson = json['systemMessages'];
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
      version = json['version'];
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
    final legsJson = json['legs'];
    if (legsJson == null) {
      logger.w(
        'TripJourney.fromJson: "legs" is null or missing for journey keys=${json.keys.toList()}',
      );
    } else if (legsJson is! List) {
      logger.w(
        'TripJourney.fromJson: "legs" is not a List, type=${legsJson.runtimeType}',
      );
    }

    final List<Leg> legsList = [];
    if (legsJson is List) {
      for (var i = 0; i < legsJson.length; i++) {
        final legJson = legsJson[i];
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
      isAdditional: json['isAdditional'],
      legs: legsList,
      rating: json['rating'],
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
      final rawCoords = json['coords'];
      if (rawCoords != null) {
        if (rawCoords is! List) {
          logger.w(
            'Leg.fromJson: "coords" is not a List, type=${rawCoords.runtimeType}',
          );
        } else {
          coords = [];
          for (var ci = 0; ci < rawCoords.length; ci++) {
            final coord = rawCoords[ci];
            if (coord is! List) {
              logger.w(
                'Leg.fromJson: coords[$ci] is not a List, type=${coord.runtimeType}; skipping',
              );
              continue;
            }
            try {
              coords.add(coord.map((c) => (c as num).toDouble()).toList());
            } catch (e) {
              logger.w('Leg.fromJson: failed to parse coords[$ci]: $e');
            }
          }
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
      final raw = json['footPathInfo'];
      if (raw != null) {
        if (raw is! List) {
          logger.w(
            'Leg.fromJson: "footPathInfo" is not a List, type=${raw.runtimeType}',
          );
        } else {
          footPathInfo = [];
          for (var i = 0; i < raw.length; i++) {
            try {
              if (raw[i] is! Map<String, dynamic>) {
                logger.w(
                  'Leg.fromJson: footPathInfo[$i] is not a Map; skipping',
                );
                continue;
              }
              footPathInfo.add(FootPathInfo.fromJson(raw[i]));
            } catch (e) {
              logger.w('Leg.fromJson: failed to parse footPathInfo[$i]: $e');
            }
          }
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: unexpected error parsing "footPathInfo": $e');
    }

    // --- hints ---
    List<Hint>? hints;
    try {
      final raw = json['hints'];
      if (raw != null) {
        if (raw is! List) {
          logger.w(
            'Leg.fromJson: "hints" is not a List, type=${raw.runtimeType}',
          );
        } else {
          hints = [];
          for (var i = 0; i < raw.length; i++) {
            try {
              if (raw[i] is! Map<String, dynamic>) {
                logger.w('Leg.fromJson: hints[$i] is not a Map; skipping');
                continue;
              }
              hints.add(Hint.fromJson(raw[i]));
            } catch (e) {
              logger.w('Leg.fromJson: failed to parse hints[$i]: $e');
            }
          }
        }
      }
    } catch (e) {
      logger.w('Leg.fromJson: unexpected error parsing "hints": $e');
    }

    // --- infos ---
    List<Info>? infos;
    try {
      final raw = json['infos'];
      if (raw != null) {
        if (raw is! List) {
          logger.w(
            'Leg.fromJson: "infos" is not a List, type=${raw.runtimeType}',
          );
        } else {
          infos = [];
          for (var i = 0; i < raw.length; i++) {
            try {
              if (raw[i] is! Map<String, dynamic>) {
                logger.w('Leg.fromJson: infos[$i] is not a Map; skipping');
                continue;
              }
              infos.add(Info.fromJson(raw[i]));
            } catch (e) {
              logger.w('Leg.fromJson: failed to parse infos[$i]: $e');
            }
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
      final raw = json['pathDescriptions'];
      if (raw != null) {
        if (raw is! List) {
          logger.w(
            'Leg.fromJson: "pathDescriptions" is not a List, type=${raw.runtimeType}',
          );
        } else {
          pathDescriptions = [];
          for (var i = 0; i < raw.length; i++) {
            try {
              if (raw[i] is! Map<String, dynamic>) {
                logger.w(
                  'Leg.fromJson: pathDescriptions[$i] is not a Map; skipping',
                );
                continue;
              }
              pathDescriptions.add(PathDescription.fromJson(raw[i]));
            } catch (e) {
              logger.w(
                'Leg.fromJson: failed to parse pathDescriptions[$i]: $e',
              );
            }
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
      final raw = json['stopSequence'];
      if (raw != null) {
        if (raw is! List) {
          logger.w(
            'Leg.fromJson: "stopSequence" is not a List, type=${raw.runtimeType}',
          );
        } else {
          stopSequence = [];
          for (var i = 0; i < raw.length; i++) {
            final stopJson = raw[i];
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
    List<double>? coord;
    try {
      final rawCoord = json['coord'];
      if (rawCoord != null) {
        if (rawCoord is! List) {
          logger.w(
            'Stop.fromJson: "coord" is not a List, type=${rawCoord.runtimeType} '
            'for stop id=${json['id']}',
          );
        } else {
          coord = [];
          for (var i = 0; i < rawCoord.length; i++) {
            try {
              coord.add((rawCoord[i] as num).toDouble());
            } catch (e) {
              logger.w(
                'Stop.fromJson: failed to parse coord[$i]=${rawCoord[i]}: $e '
                'for stop id=${json['id']}',
              );
            }
          }
        }
      }
    } catch (e) {
      logger.w(
        'Stop.fromJson: unexpected error parsing "coord": $e for stop id=${json['id']}',
      );
    }

    // --- parent ---
    Parent? parent;
    try {
      final rawParent = json['parent'];
      if (rawParent != null) {
        if (rawParent is! Map<String, dynamic>) {
          logger.w(
            'Stop.fromJson: "parent" is not a Map, type=${rawParent.runtimeType} '
            'for stop id=${json['id']}',
          );
        } else {
          parent = Parent.fromJson(rawParent);
        }
      }
    } catch (e) {
      logger.w(
        'Stop.fromJson: failed to parse "parent": $e for stop id=${json['id']}',
      );
    }

    // --- properties ---
    StopProperties? properties;
    try {
      final rawProps = json['properties'];
      if (rawProps != null) {
        if (rawProps is! Map<String, dynamic>) {
          logger.w(
            'Stop.fromJson: "properties" is not a Map, type=${rawProps.runtimeType} '
            'for stop id=${json['id']}',
          );
        } else {
          properties = StopProperties.fromJson(rawProps);
        }
      }
    } catch (e) {
      logger.w(
        'Stop.fromJson: failed to parse "properties": $e for stop id=${json['id']}',
      );
    }

    return Stop(
      arrivalTimeEstimated: json['arrivalTimeEstimated']?.toString(),
      arrivalTimePlanned: json['arrivalTimePlanned']?.toString(),
      coord: coord,
      departureTimeEstimated: json['departureTimeEstimated']?.toString(),
      departureTimePlanned: json['departureTimePlanned']?.toString(),
      disassembledName: json['disassembledName']?.toString(),
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      parent: parent,
      properties: properties,
      type: json['type']?.toString() ?? '',
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

    final rawParent = json['parent'];
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
      disassembledName: json['disassembledName']?.toString(),
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      parent: parsedParent,
      type: json['type']?.toString(),
    );
  }
}

class StopProperties {
  final String? wheelchairAccess;
  final List<Download>? downloads;

  StopProperties({this.wheelchairAccess, this.downloads});

  factory StopProperties.fromJson(Map<String, dynamic> json) {
    return StopProperties(
      wheelchairAccess: json['WheelchairAccess'],
      downloads: (json['downloads'] as List<dynamic>?)
          ?.map((download) => Download.fromJson(download))
          .toList(),
    );
  }
}

class Download {
  final String type;
  final String url;

  Download({required this.type, required this.url});

  factory Download.fromJson(Map<String, dynamic> json) {
    return Download(type: json['type'], url: json['url']);
  }
}

class FootPathInfo {
  final int? duration;
  final List<FootPathElem>? footPathElem;
  final String? position;

  FootPathInfo({this.duration, this.footPathElem, this.position});

  factory FootPathInfo.fromJson(Map<String, dynamic> json) {
    return FootPathInfo(
      duration: json['duration'] is int
          ? json['duration'] as int
          : (json['duration'] is String
                ? int.tryParse(json['duration'])
                : null),
      footPathElem: (json['footPathElem'] as List<dynamic>?)
          ?.map((elem) => FootPathElem.fromJson(elem))
          .toList(),
      position: json['position'],
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
    return FootPathElem(
      description: json['description'],
      destination: json['destination'] != null
          ? FootpathElemDestination.fromJson(json['destination'])
          : null,
      level: json['level'],
      levelFrom: json['levelFrom'] is int
          ? json['levelFrom'] as int
          : (json['levelFrom'] is String
                ? int.tryParse(json['levelFrom'])
                : null),
      levelTo: json['levelTo'] is int
          ? json['levelTo'] as int
          : (json['levelTo'] is String ? int.tryParse(json['levelTo']) : null),
      origin: json['origin'] != null
          ? FootpathElemOrigin.fromJson(json['origin'])
          : null,
      type: json['type'],
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
    return FootpathElemDestination(
      area: json['area'] is int
          ? json['area'] as int
          : (json['area'] is String ? int.tryParse(json['area']) : null),
      georef: json['georef'],
      location: json['location'] != null
          ? FootpathElemLocation.fromJson(json['location'])
          : null,
      platform: json['platform'] is int
          ? json['platform'] as int
          : (json['platform'] is String
                ? int.tryParse(json['platform'])
                : null),
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
    return FootpathElemOrigin(
      area: json['area'] is int
          ? json['area'] as int
          : (json['area'] is String ? int.tryParse(json['area']) : null),
      georef: json['georef'],
      location: json['location'] != null
          ? FootpathElemLocation.fromJson(json['location'])
          : null,
      platform: json['platform'] is int
          ? json['platform'] as int
          : (json['platform'] is String
                ? int.tryParse(json['platform'])
                : null),
    );
  }
}

class FootpathElemLocation {
  final List<double>? coord;
  final String? id;
  final String? type;

  FootpathElemLocation({this.coord, this.id, this.type});

  factory FootpathElemLocation.fromJson(Map<String, dynamic> json) {
    return FootpathElemLocation(
      coord: (json['coord'] as List<dynamic>?)
          ?.map((c) => (c as num).toDouble())
          .toList(),
      id: json['id'],
      type: json['type'],
    );
  }
}

class Hint {
  final String? infoText;

  Hint({this.infoText});

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(infoText: json['infoText']);
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
    // info (removed)
    return Info(
      content: json['content'],
      id: json['id'],
      priority: json['priority'],
      subtitle: json['subtitle'],
      timestamps: json['timestamps'] != null
          ? Timestamps.fromJson(json['timestamps'])
          : null,
      url: json['url'],
      urlText: json['urlText'],
      // Parse version as int when possible. Accept numeric or numeric string.
      version: (() {
        final v = json['version'];
        if (v == null) return null;
        if (v is int) return v;
        if (v is String) {
          final parsed = int.tryParse(v);
          if (parsed == null) {
            logger.w(
              'Info.fromJson: could not parse version string to int: "$v"',
            );
          }
          return parsed;
        }
        logger.w(
          'Info.fromJson: unexpected type for version: ${v.runtimeType}',
        );
        return null;
      })(),
    );
  }
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
    return Timestamps(
      availability: json['availability'] != null
          ? Validity.fromJson(json['availability'])
          : null,
      creation: json['creation'],
      lastModification: json['lastModification'],
      validity: (json['validity'] as List<dynamic>?)
          ?.map((v) => Validity.fromJson(v))
          .toList(),
    );
  }
}

class Validity {
  final String? from;
  final String? to;

  Validity({this.from, this.to});

  factory Validity.fromJson(Map<String, dynamic> json) {
    return Validity(from: json['from'], to: json['to']);
  }
}

class Interchange {
  final List<List<double>>? coords;
  final String? desc;
  final int? type;

  Interchange({this.coords, this.desc, this.type});

  factory Interchange.fromJson(Map<String, dynamic> json) {
    return Interchange(
      coords: (json['coords'] as List<dynamic>?)
          ?.map(
            (coord) => (coord as List<dynamic>)
                .map((c) => (c as num).toDouble())
                .toList(),
          )
          .toList(),
      desc: json['desc'],
      type: json['type'],
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
    return PathDescription(
      coord: (json['coord'] as List<dynamic>?)
          ?.map((c) => (c as num).toDouble())
          .toList(),
      cumDistance: json['cumDistance'],
      cumDuration: json['cumDuration'],
      distance: json['distance'],
      distanceDown: json['distanceDown'],
      distanceUp: json['distanceUp'],
      duration: json['duration'],
      fromCoordsIndex: json['fromCoordsIndex'],
      manoeuvre: json['manoeuvre'],
      name: json['name'],
      skyDirection: json['skyDirection'],
      toCoordsIndex: json['toCoordsIndex'],
      turnDirection: json['turnDirection'],
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
    return LegProperties(
      differentFares: json['DIFFERENT_FARES'],
      planLowFloorVehicle: json['PlanLowFloorVehicle'],
      planWheelChairAccess: json['PlanWheelChairAccess'],
      //TODO: Fix
      lineType: json['lineType']?.toString(),
      vehicleAccess: (json['vehicleAccess'] as List<dynamic>?)
          ?.map((v) => v.toString())
          .toList(),
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
    try {
      final raw = json['destination'];
      if (raw != null) {
        if (raw is! Map<String, dynamic>) {
          logger.w(
            'Transportation.fromJson: "destination" is not a Map, type=${raw.runtimeType}',
          );
        } else {
          destination = TransportationDestination.fromJson(raw);
        }
      }
    } catch (e) {
      logger.w('Transportation.fromJson: failed to parse "destination": $e');
    }

    Operator? operator;
    try {
      final raw = json['operator'];
      if (raw != null) {
        if (raw is! Map<String, dynamic>) {
          logger.w(
            'Transportation.fromJson: "operator" is not a Map, type=${raw.runtimeType}',
          );
        } else {
          operator = Operator.fromJson(raw);
        }
      }
    } catch (e) {
      logger.w('Transportation.fromJson: failed to parse "operator": $e');
    }

    Product? product;
    try {
      final raw = json['product'];
      if (raw != null) {
        if (raw is! Map<String, dynamic>) {
          logger.w(
            'Transportation.fromJson: "product" is not a Map, type=${raw.runtimeType}',
          );
        } else {
          product = Product.fromJson(raw);
        }
      }
    } catch (e) {
      logger.w('Transportation.fromJson: failed to parse "product": $e');
    }

    TransportationProperties? properties;
    try {
      final raw = json['properties'];
      if (raw != null) {
        if (raw is! Map<String, dynamic>) {
          logger.w(
            'Transportation.fromJson: "properties" is not a Map, type=${raw.runtimeType}',
          );
        } else {
          properties = TransportationProperties.fromJson(raw);
        }
      }
    } catch (e) {
      logger.w('Transportation.fromJson: failed to parse "properties": $e');
    }

    return Transportation(
      description: json['description']?.toString(),
      destination: destination,
      disassembledName: json['disassembledName']?.toString(),
      iconId: json['iconId'] is int ? json['iconId'] as int : null,
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      number: json['number']?.toString(),
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
    return TransportationDestination(id: json['id'], name: json['name']);
  }
}

class Operator {
  final String? id;
  final String? name;

  Operator({this.id, this.name});

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(id: json['id'], name: json['name']);
  }
}

class Product {
  final int? classField;
  final int? iconId;
  final String? name;

  Product({this.classField, this.iconId, this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      classField: json['class'],
      iconId: json['iconId'],
      name: json['name'],
    );
  }
}

class TransportationProperties {
  final bool? isTTB;
  final int? tripCode;

  TransportationProperties({this.isTTB, this.tripCode});

  factory TransportationProperties.fromJson(Map<String, dynamic> json) {
    return TransportationProperties(
      isTTB: json['isTTB'],
      tripCode: json['tripCode'],
    );
  }
}

class SystemMessages {
  final List<ResponseMessage>? responseMessages;

  SystemMessages({this.responseMessages});

  factory SystemMessages.fromJson(Object json) {
    // If json is a List, treat it as the list of messages directly
    if (json is List) {
      // systemMessages is a List, using as responseMessages
      return SystemMessages(
        responseMessages: json
            .map((msg) => ResponseMessage.fromJson(msg))
            .toList(),
      );
    }
    // If json is a Map and has responseMessages, use that
    if (json is Map<String, dynamic>) {
      if (json.containsKey('responseMessages')) {
        // systemMessages is an object with responseMessages
        return SystemMessages(
          responseMessages: (json['responseMessages'] as List<dynamic>?)
              ?.map((message) => ResponseMessage.fromJson(message))
              .toList(),
        );
      } else {
        // Sometimes the API may return a single message as an object
        // systemMessages is a single object, wrapping in a list
        return SystemMessages(
          responseMessages: [ResponseMessage.fromJson(json)],
        );
      }
    }
    // systemMessages is of unexpected type: ${json.runtimeType}
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
    // The API sometimes uses 'text' instead of 'error', and 'subType' for
    // additional categorisation. Use 'error' when present, otherwise fall
    // back to 'text'. Keep both fields available.
    final rawText = json['text']?.toString();
    final rawError = json['error']?.toString();
    return ResponseMessage(
      code: json['code'],
      // prefer explicit 'error' but fall back to 'text' to capture messages
      error: rawError ?? rawText,
      module: json['module']?.toString(),
      type: json['type']?.toString(),
      text: rawText,
      subType: json['subType']?.toString(),
    );
  }
}
