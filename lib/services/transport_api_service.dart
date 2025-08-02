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
  static Future<List<dynamic>> getTrips({
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
      return data['journeys'] as List? ?? [];
    } catch (e) {
      print('Error getting trips: $e');
      return [];
    }
  }
}
