import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:option_result/option_result.dart';
import '../logs/logger.dart';
import 'api_key_service.dart';

/// Service class for handling NSW Transport API requests
class TransportApiService {
  static const String _baseUrl = 'api.transport.nsw.gov.au';

  /// Get the effective API key (user override or built-in .env key).
  static Future<String?> _getApiKey() async {
    final key = ApiKeyService.getEffectiveApiKey();
    return key.isEmpty ? null : key;
  }

  /// Test if API key is valid
  static Future<bool> isApiKeyValid() async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) return false;

      final params = {
        'outputFormat': 'rapidJSON',
        'type_sf': 'stop',
        'name_sf': '',
        'coordOutputFormat': 'EPSG:4326',
        'TfNSWSF': 'true',
        'version': '10.2.1.42',
      };

      final uri = Uri.https(_baseUrl, '/v1/tp/stop_finder/', params);
      final response = await http.get(
        uri,
        headers: {'authorization': 'apikey $apiKey'},
      );

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
    final apiKey = await _getApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      return const Err('API key not set');
    }

    final params = {
      'outputFormat': 'rapidJSON',
      'type_sf': 'any',
      'name_sf': query,
      'coordOutputFormat': 'EPSG:4326',
      'TfNSWSF': 'true',
      'version': '10.2.1.42',
    };

    try {
      final uri = Uri.https(_baseUrl, '/v1/tp/stop_finder/', params);
      final response = await http.get(
        uri,
        headers: {'authorization': 'apikey $apiKey'},
      );

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
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return const Err('API key not set');
    }

    final params = {
      'outputFormat': 'rapidJSON',
      'coordOutputFormat': 'EPSG:4326',
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
      'version': '10.2.1.42',
      'itOptionsActive': '0',
    };

    try {
      final uri = Uri.https(_baseUrl, '/v1/tp/trip/', params);
      final response = await http.get(
        uri,
        headers: {'authorization': 'apikey $apiKey'},
      );
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

  GetTripsResponse({
    required this.tripJourneys,
    required this.systemMessages,
    required this.version,
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
        final parsed = TripJourney.fromJson(journey);
        tripJourneys.add(parsed);
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
        legsList.add(Leg.fromJson(legJson));
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
    // Leg raw json keys logged (removed)
    // Leg destination present: ${json['destination'] != null}
    // Leg origin present: ${json['origin'] != null}
    // Leg coords type: ${json['coords']?.runtimeType}
    return Leg(
      coords: (json['coords'] as List<dynamic>?)
          ?.map(
            (coord) => (coord as List<dynamic>)
                .map((c) => (c as num).toDouble())
                .toList(),
          )
          .toList(),
      destination: Stop.fromJson(json['destination']),
      distance: json['distance'] is int
          ? json['distance'] as int
          : (json['distance'] is String
                ? int.tryParse(json['distance'])
                : null),
      duration: json['duration'] is int
          ? json['duration'] as int
          : (json['duration'] is String
                ? int.tryParse(json['duration'])
                : null),
      footPathInfo: (json['footPathInfo'] as List<dynamic>?)
          ?.map((info) => FootPathInfo.fromJson(info))
          .toList(),
      hints: (json['hints'] as List<dynamic>?)
          ?.map((hint) => Hint.fromJson(hint))
          .toList(),
      infos: (json['infos'] as List<dynamic>?)
          ?.map((info) => Info.fromJson(info))
          .toList(),
      interchange: json['interchange'] != null
          ? Interchange.fromJson(json['interchange'])
          : null,
      isRealtimeControlled: json['isRealtimeControlled'],
      origin: Stop.fromJson(json['origin']),
      pathDescriptions: (json['pathDescriptions'] as List<dynamic>?)
          ?.map((desc) => PathDescription.fromJson(desc))
          .toList(),
      properties: json['properties'] != null
          ? LegProperties.fromJson(json['properties'])
          : null,
      stopSequence: (json['stopSequence'] as List<dynamic>?)
          ?.map((stop) => Stop.fromJson(stop))
          .toList(),
      transportation: json['transportation'] != null
          ? Transportation.fromJson(json['transportation'])
          : null,
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
    // stop parent present: ${json['parent'] != null}
    return Stop(
      arrivalTimeEstimated: json['arrivalTimeEstimated'],
      arrivalTimePlanned: json['arrivalTimePlanned'],
      coord: (json['coord'] as List<dynamic>?)
          ?.map((c) => (c as num).toDouble())
          .toList(),
      departureTimeEstimated: json['departureTimeEstimated'],
      departureTimePlanned: json['departureTimePlanned'],
      disassembledName: json['disassembledName'],
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      parent: json['parent'] != null ? Parent.fromJson(json['parent']) : null,
      properties: json['properties'] != null
          ? StopProperties.fromJson(json['properties'])
          : null,
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
    return Transportation(
      description: json['description'],
      destination: json['destination'] != null
          ? TransportationDestination.fromJson(json['destination'])
          : null,
      disassembledName: json['disassembledName'],
      iconId: json['iconId'],
      id: json['id'],
      name: json['name'],
      number: json['number'],
      operator: json['operator'] != null
          ? Operator.fromJson(json['operator'])
          : null,
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      properties: json['properties'] != null
          ? TransportationProperties.fromJson(json['properties'])
          : null,
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
