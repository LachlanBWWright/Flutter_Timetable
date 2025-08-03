//V1
//https://opendata.transport.nsw.gov.au/data/dataset/public-transport-timetables-realtime
//Metro on v2
//https://opendata.transport.nsw.gov.au/dataset/public-transport-timetables-realtime-v2

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

Map<String, String> getHeaders() {
  final apiKey = dotenv.env['API_KEY'] ?? 'YOUR_API_KEY';
  return {
    'Authorization': 'apikey $apiKey',
    //'Accept': 'application/x-protobuf', WRONG!
  };
}

/// Fetches the Metro GTFS schedule zip, extracts CSV files, and returns a map of filename to CSV string.
Future<Map<String, String>?> fetchMetroScheduleRealtime() async {
  final url =
      Uri.parse('https://api.transport.nsw.gov.au/v2/gtfs/schedule/metro');
  final response = await http.get(
    url,
    headers: getHeaders(),
  );
  if (response.statusCode != 200) {
    print('Failed to fetch Metro schedule realtime: ${response.statusCode}');
    return null;
  }

  // Unzip the response body in memory
  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  final Map<String, String> csvFiles = {};
  for (final file in archive) {
    print(file.name);
    if (file.isFile && file.name.endsWith('.txt')) {
      //csvFiles[file.name] = String.fromCharCodes(file.content as List<int>);
    }
  }
  return csvFiles;
}
