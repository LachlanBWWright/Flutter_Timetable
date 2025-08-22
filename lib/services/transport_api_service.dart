import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service class for handling NSW Transport API requests
class TransportApiService {
  static const String _baseUrl = 'api.transport.nsw.gov.au';

  /// Get API key from .env
  static Future<String?> _getApiKey() async {
    // Ensure dotenv is loaded before calling this in main
    return dotenv.env['API_KEY'];
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
      print('Error validating API key: $e');
      return false;
    }
  }

  /// Search for stations/stops
  static Future<List<Map<String, dynamic>>> searchStations(String query) async {
    try {
      final apiKey = await _getApiKey();

/*       final res = await tripPlannerApi.stopFinderGet(
          outputFormat: StopFinderGetOutputFormat.rapidjson,
          nameSf: query,
          coordOutputFormat: StopFinderGetCoordOutputFormat.epsg426); */

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not set');
      }

      final params = {
        'outputFormat': 'rapidJSON',
        'type_sf': 'any',
        'name_sf': query,
        'coordOutputFormat': 'EPSG:4326',
        'TfNSWSF': 'true',
        'version': '10.2.1.42',
      };

      final uri = Uri.https(_baseUrl, '/v1/tp/stop_finder/', params);
      final response = await http.get(
        uri,
        headers: {'authorization': 'apikey $apiKey'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to search stations: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final locations = data['locations'] as List? ?? [];

      return locations
          .map((location) => {
                'name': location['disassembledName'] ?? location['name'] ?? '',
                'id': location['id']?.toString() ?? '',
              })
          .toList();
    } catch (e) {
      print('Error searching stations: $e');
      return [];
    }
  }

  /// Get trip information between two stations
  static Future<GetTripsResponse> getTrips({
    required String originId,
    required String destinationId,
  }) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not set');
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

      final uri = Uri.https(_baseUrl, '/v1/tp/trip/', params);
      final response = await http.get(
        uri,
        headers: {'authorization': 'apikey $apiKey'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get trips: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return GetTripsResponse.fromJson(data);
    } catch (e) {
      print('Error getting trips: $e');
      rethrow;
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
    return GetTripsResponse(
      tripJourneys: (json['journeys'] as List<dynamic>)
          .map((journey) => TripJourney.fromJson(journey))
          .toList(),
      systemMessages: SystemMessages.fromJson(json['systemMessages']),
      version: json['version'],
    );
  }
}

class TripJourney {
  final bool? isAdditional;
  final List<Leg> legs;
  final int? rating;

  TripJourney({
    this.isAdditional,
    required this.legs,
    this.rating,
  });

  factory TripJourney.fromJson(Map<String, dynamic> json) {
    return TripJourney(
      isAdditional: json['isAdditional'],
      legs: (json['legs'] as List<dynamic>)
          .map((leg) => Leg.fromJson(leg))
          .toList(),
      rating: json['rating'],
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
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      coords: (json['coords'] as List<dynamic>?)
          ?.map((coord) =>
              (coord as List<dynamic>).map((c) => (c as num).toDouble()).toList())
          .toList(),
      destination: Stop.fromJson(json['destination']),
      distance: json['distance'],
      duration: json['duration'],
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
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      arrivalTimeEstimated: json['arrivalTimeEstimated'],
      arrivalTimePlanned: json['arrivalTimePlanned'],
      coord: (json['coord'] as List<dynamic>?)
          ?.map((c) => (c as num).toDouble())
          .toList(),
      departureTimeEstimated: json['departureTimeEstimated'],
      departureTimePlanned: json['departureTimePlanned'],
      disassembledName: json['disassembledName'],
      id: json['id'],
      name: json['name'],
      parent: json['parent'] != null ? Parent.fromJson(json['parent']) : null,
      properties: json['properties'] != null
          ? StopProperties.fromJson(json['properties'])
          : null,
      type: json['type'],
    );
  }
}

class Parent {
  final String? disassembledName;
  final String id;
  final String name;
  final String? parent;
  final String? type;

  Parent({
    this.disassembledName,
    required this.id,
    required this.name,
    this.parent,
    this.type,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      disassembledName: json['disassembledName'],
      id: json['id'],
      name: json['name'],
      parent: json['parent'],
      type: json['type'],
    );
  }
}

class StopProperties {
  final String? wheelchairAccess;
  final List<Download>? downloads;

  StopProperties({
    this.wheelchairAccess,
    this.downloads,
  });

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

  Download({
    required this.type,
    required this.url,
  });

  factory Download.fromJson(Map<String, dynamic> json) {
    return Download(
      type: json['type'],
      url: json['url'],
    );
  }
}

class FootPathInfo {
  final int? duration;
  final List<FootPathElem>? footPathElem;
  final String? position;

  FootPathInfo({
    this.duration,
    this.footPathElem,
    this.position,
  });

  factory FootPathInfo.fromJson(Map<String, dynamic> json) {
    return FootPathInfo(
      duration: json['duration'],
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
      levelFrom: json['levelFrom'],
      levelTo: json['levelTo'],
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
      area: json['area'],
      georef: json['georef'],
      location: json['location'] != null
          ? FootpathElemLocation.fromJson(json['location'])
          : null,
      platform: json['platform'],
    );
  }
}

class FootpathElemOrigin {
  final int? area;
  final String? georef;
  final FootpathElemLocation? location;
  final int? platform;

  FootpathElemOrigin({
    this.area,
    this.georef,
    this.location,
    this.platform,
  });

  factory FootpathElemOrigin.fromJson(Map<String, dynamic> json) {
    return FootpathElemOrigin(
      area: json['area'],
      georef: json['georef'],
      location: json['location'] != null
          ? FootpathElemLocation.fromJson(json['location'])
          : null,
      platform: json['platform'],
    );
  }
}

class FootpathElemLocation {
  final List<double>? coord;
  final String? id;
  final String? type;

  FootpathElemLocation({
    this.coord,
    this.id,
    this.type,
  });

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

  Hint({
    this.infoText,
  });

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(
      infoText: json['infoText'],
    );
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
      version: json['version'],
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

  Validity({
    this.from,
    this.to,
  });

  factory Validity.fromJson(Map<String, dynamic> json) {
    return Validity(
      from: json['from'],
      to: json['to'],
    );
  }
}

class Interchange {
  final List<List<double>>? coords;
  final String? desc;
  final int? type;

  Interchange({
    this.coords,
    this.desc,
    this.type,
  });

  factory Interchange.fromJson(Map<String, dynamic> json) {
    return Interchange(
      coords: (json['coords'] as List<dynamic>?)
          ?.map((coord) =>
              (coord as List<dynamic>).map((c) => (c as num).toDouble()).toList())
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
      lineType: json['lineType'],
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
      operator:
          json['operator'] != null ? Operator.fromJson(json['operator']) : null,
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      properties: json['properties'] != null
          ? TransportationProperties.fromJson(json['properties'])
          : null,
    );
  }
}

class TransportationDestination {
  final String? id;
  final String? name;

  TransportationDestination({
    this.id,
    this.name,
  });

  factory TransportationDestination.fromJson(Map<String, dynamic> json) {
    return TransportationDestination(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Operator {
  final String? id;
  final String? name;

  Operator({
    this.id,
    this.name,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Product {
  final int? classField;
  final int? iconId;
  final String? name;

  Product({
    this.classField,
    this.iconId,
    this.name,
  });

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

  TransportationProperties({
    this.isTTB,
    this.tripCode,
  });

  factory TransportationProperties.fromJson(Map<String, dynamic> json) {
    return TransportationProperties(
      isTTB: json['isTTB'],
      tripCode: json['tripCode'],
    );
  }
}

class SystemMessages {
  final List<ResponseMessage>? responseMessages;

  SystemMessages({
    this.responseMessages,
  });

  factory SystemMessages.fromJson(Map<String, dynamic> json) {
    return SystemMessages(
      responseMessages: (json['responseMessages'] as List<dynamic>?)
          ?.map((message) => ResponseMessage.fromJson(message))
          .toList(),
    );
  }
}

class ResponseMessage {
  final int? code;
  final String? error;
  final String? module;
  final String? type;

  ResponseMessage({
    this.code,
    this.error,
    this.module,
    this.type,
  });

  factory ResponseMessage.fromJson(Map<String, dynamic> json) {
    return ResponseMessage(
      code: json['code'],
      error: json['error'],
      module: json['module'],
      type: json['type'],
    );
  }
}
