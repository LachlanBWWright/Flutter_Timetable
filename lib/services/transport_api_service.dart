import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../logs/logger.dart';
import '../swagger_generated/trip_planner.swagger.dart';
import '../swagger_clients/swagger_backend.dart';

/// Service class for handling NSW Transport API requests
class TransportApiService {
  static const String _baseUrl = 'api.transport.nsw.gov.au';
  static TripPlanner? _tripPlannerClient;

  /// Get or create TripPlanner client
  static Future<TripPlanner> _getTripPlannerClient() async {
    if (_tripPlannerClient != null) {
      return _tripPlannerClient!;
    }

    final chopperClient = await createChopperClient(
      baseUrl: 'https://$_baseUrl/v1/tp',
    );

    _tripPlannerClient = TripPlanner.create(client: chopperClient);
    return _tripPlannerClient!;
  }

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
      // Error validating API key
      return false;
    }
  }

  /// Search for stations/stops using Swagger-generated client
  static Future<List<Map<String, dynamic>>> searchStations(String query) async {
    try {
      final client = await _getTripPlannerClient();

      final response = await client.stopFinderGet(
        outputFormat: StopFinderGetOutputFormat.rapidjson,
        nameSf: query,
        typeSf: StopFinderGetTypeSf.any,
        coordOutputFormat: StopFinderGetCoordOutputFormat.epsg4326,
        tfNswsf: true,
        version: '10.2.1.42',
      );

      if (!response.isSuccessful || response.body == null) {
        throw Exception(
            'Failed to search stations: ${response.statusCode}, ${response.error}');
      }

      final locations = response.body!.locations ?? [];

      return locations.map((location) {
        final name = (location.disassembledName ?? location.name) ?? '';
        final id = location.id ?? '';
        return {'name': name, 'id': id};
      }).toList();
    } catch (e) {
      logger.e('Error searching stations: $e');
      return [];
    }
  }

  /// Get trip information between two stations using Swagger-generated client
  static Future<TripRequestResponse> getTrips({
    required String originId,
    required String destinationId,
  }) async {
    try {
      final client = await _getTripPlannerClient();

      final response = await client.tripGet(
        outputFormat: TripGetOutputFormat.rapidjson,
        coordOutputFormat: TripGetCoordOutputFormat.epsg4326,
        depArrMacro: TripGetDepArrMacro.dep,
        typeOrigin: TripGetTypeOrigin.any,
        nameOrigin: originId,
        typeDestination: TripGetTypeDestination.any,
        nameDestination: destinationId,
        calcNumberOfTrips: 20,
        excludedMeans: TripGetExcludedMeans.checkbox,
        exclMOT7: TripGetExclMOT7.$1,  // Exclude coach
        exclMOT11: TripGetExclMOT11.$1,  // Exclude school bus
        tfNswtr: TripGetTfNSWTR.$true,
        version: '10.2.1.42',
        itOptionsActive: 0,
      );

      logger.i('Response code ${response.statusCode}');

      if (!response.isSuccessful || response.body == null) {
        throw Exception(
            'Failed to get trips: ${response.statusCode}, ${response.error}');
      }

      final journeysCount = response.body!.journeys?.length ?? 0;
      logger.i(
          'TransportApiService.getTrips: received $journeysCount journeys for origin=$originId destination=$destinationId');
      
      return response.body!;
    } catch (e) {
      logger.e('Error getting trips: $e');
      return const TripRequestResponse(
        journeys: [],
        systemMessages: TripRequestResponse$SystemMessages(responseMessages: []),
        version: '',
      );
    }
  }
}

// Export Swagger-generated types for easier access
typedef GetTripsResponse = TripRequestResponse;
typedef TripJourney = TripRequestResponseJourney;
typedef Leg = TripRequestResponseJourneyLeg;
typedef Stop = TripRequestResponseJourneyLegStop;
typedef SystemMessages = TripRequestResponse$SystemMessages;
typedef ResponseMessage = TripRequestResponseMessage;
typedef Transportation = TripTransportation;
typedef LegProperties = TripRequestResponseJourneyLeg$Properties;
typedef StopProperties = TripRequestResponseJourneyLegStop$Properties;
typedef Parent = TripRequestResponseJourneyLegStop$Parent;
typedef FootPathInfo = TripRequestResponseJourneyLegStopFootpathInfo;
typedef FootPathElem = TripRequestResponseJourneyLegStopFootpathInfoFootpathElem;
typedef Hint = TripRequestResponseJourneyLeg$Hints$Item;
typedef Info = TripRequestResponseJourneyLegStopInfo;
typedef PathDescription = TripRequestResponseJourneyLegPathDescription;
typedef Interchange = TripRequestResponseJourneyLegInterchange;
typedef Download = TripRequestResponseJourneyLegStopDownload;

// Extensions to provide non-nullable access to required fields
extension TripRequestResponseExtension on TripRequestResponse {
  /// Get journeys list (never null, defaults to empty list)
  List<TripJourney> get tripJourneys => journeys ?? [];
}

extension TripJourneyExtension on TripRequestResponseJourney {
  /// Get legs list (never null, defaults to empty list)
  List<Leg> get legsList => legs ?? [];
  
  /// Check if trip has valid legs
  bool get hasLegs => legs != null && legs!.isNotEmpty;
}

extension LegExtension on TripRequestResponseJourneyLeg {
  /// Get origin stop (throws if null - indicates invalid data)
  Stop get originStop => origin ?? (throw StateError('Leg has no origin'));
  
  /// Get destination stop (throws if null - indicates invalid data)
  Stop get destinationStop => destination ?? (throw StateError('Leg has no destination'));
  
  /// Check if leg has valid origin and destination
  bool get isValid => origin != null && destination != null;
}

extension StopExtension on TripRequestResponseJourneyLegStop {
  /// Get display name (prefers disassembled name, falls back to name or 'Unknown')
  String get displayName => disassembledName ?? name ?? 'Unknown';
  
  /// Get stop ID (falls back to empty string if null)
  String get stopId => id ?? '';
}
