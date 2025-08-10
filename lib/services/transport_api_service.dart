import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/backends/TripPlannerApi.dart';
import 'package:lbww_flutter/swagger_output/trip_planner.swagger.dart';

/// Service class for handling NSW Transport API requests
class TransportApiService {
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

      final uri =
          Uri.https('api.transport.nsw.gov.au', '/v1/tp/stop_finder/', params);
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
  static Future<List<StopFinderLocation>> searchStations(String query) async {
    try {
      final res = await tripPlannerApi.stopFinderGet(
        outputFormat: StopFinderGetOutputFormat.rapidjson,
        typeSf: StopFinderGetTypeSf.any,
        nameSf: query,
        coordOutputFormat: StopFinderGetCoordOutputFormat.epsg4326,
        tfNSWSF: StopFinderGetTfNSWSF.$true,
        version: '10.2.1.42',
      );
      final body = res.body;
      final bodyLocations = body?.locations;
      if (body == null || bodyLocations == null) return [];
      return bodyLocations;
    } catch (e) {
      print('Error searching stations: $e');
      return [];
    }
  }

  /// Get trip information between two stations
  static Future<List<TripRequestResponseJourney>> getTrips({
    required String originId,
    required String destinationId,
  }) async {
    try {
      final res = await tripPlannerApi.tripGet(
        outputFormat: TripGetOutputFormat.rapidjson,
        coordOutputFormat: TripGetCoordOutputFormat.epsg4326,
        depArrMacro: TripGetDepArrMacro.dep,
        typeOrigin: TripGetTypeOrigin.any,
        nameOrigin: originId,
        typeDestination: TripGetTypeDestination.any,
        nameDestination: destinationId,
        calcNumberOfTrips: 20,
        excludedMeans: TripGetExcludedMeans.checkbox,
        exclMOT7: TripGetExclMOT7.value_1,
        exclMOT11: TripGetExclMOT11.value_1,
        tfNSWTR: TripGetTfNSWTR.$true,
        version: '10.2.1.42',
        itOptionsActive: 0,
      );
      final body = res.body;
      final bodyJourneys = body?.journeys;
      if (body == null || bodyJourneys == null) return [];
      return bodyJourneys;
    } catch (e) {
      print('Error getting trips: $e');
      return [];
    }
  }
}
