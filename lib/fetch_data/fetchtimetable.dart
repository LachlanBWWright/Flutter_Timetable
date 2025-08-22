import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Fetches the complete GTFS timetable as JSON from Transport for NSW Open Data.
///
/// Requires API key in .env as API_KEY.
/// Returns the parsed JSON as a Map, or null on error.
Future<Map<String, dynamic>?> fetchTimetable() async {
  final apiKey = dotenv.env['API_KEY'] ?? 'YOUR_API_KEY';
  final url = Uri.parse(
    'https://api.transport.nsw.gov.au/v1/publictransport/timetables/complete/gtfs',
  );
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'apikey $apiKey',
      'Accept': 'application/json',
    },
  );
  if (response.statusCode != 200) {
    print('Failed to fetch timetable: \\${response.statusCode}');
    return null;
  }
  return json.decode(response.body) as Map<String, dynamic>;
}
