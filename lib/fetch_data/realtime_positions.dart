import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

Map<String, String> getHeaders() {
  final apiKey = dotenv.env['API_KEY'] ?? 'YOUR_API_KEY';
  return {
    'Authorization': 'apikey $apiKey',
    'Accept': 'application/x-protobuf',
  };
}

Future<FeedMessage?> fetchSydneyTrainsPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos/sydneytrains');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) {
    return null;
  }

  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchSydneyMetroPositions() async {
  final url =
      Uri.parse('https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos/metro');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) {
    print('Error fetching Sydney Metro positions: ${response.statusCode}');
    return null;
  }
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchBusesPositions() async {
  final url =
      Uri.parse('https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/buses');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) {
    return null;
  }
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchNswTrainsPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/nswtrains');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) {
    return null;
  }
  return FeedMessage.fromBuffer(response.bodyBytes);
}

// --- Ferries ---
Future<FeedMessage?> fetchFerriesSydneyFerriesPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/ferries/sydneyferries');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchFerriesMFFPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/ferries/MFF');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

// --- Lightrail ---
Future<FeedMessage?> fetchLightRailCbdAndSoutheastPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/cbdandsoutheast');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchLightRailInnerWestPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/innerwest');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchLightRailNewcastlePositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/newcastle');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchLightRailParramattaPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/parramatta');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

// --- Region Buses ---
Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/centralwestandorana');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Positions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/centralwestandorana2');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/newenglandnorthwest');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNorthCoastPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Positions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast2');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Positions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast3');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/riverinamurray');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Positions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/riverinamurray2');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/southeasttablelands');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Positions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/southeasttablelands2');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/sydneysurrounds');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/newcastlehunter');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesFarWestPositions() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/farwest');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<List<FeedMessage?>> getAllFerries() async {
  return await Future.wait([
    fetchFerriesSydneyFerriesPositions(),
    fetchFerriesMFFPositions(),
  ]);
}

Future<List<FeedMessage?>> getAllLightRail() async {
  return await Future.wait([
    fetchLightRailCbdAndSoutheastPositions(),
    fetchLightRailInnerWestPositions(),
    fetchLightRailNewcastlePositions(),
    fetchLightRailParramattaPositions(),
  ]);
}

Future<List<FeedMessage?>> getAllRegionBuses() async {
  return await Future.wait([
    fetchRegionBusesCentralWestAndOranaPositions(),
    fetchRegionBusesCentralWestAndOrana2Positions(),
    fetchRegionBusesNewEnglandNorthWestPositions(),
    fetchRegionBusesNorthCoastPositions(),
    fetchRegionBusesNorthCoast2Positions(),
    fetchRegionBusesNorthCoast3Positions(),
    fetchRegionBusesRiverinaMurrayPositions(),
    fetchRegionBusesRiverinaMurray2Positions(),
    fetchRegionBusesSouthEastTablelandsPositions(),
    fetchRegionBusesSouthEastTablelands2Positions(),
    fetchRegionBusesSydneySurroundsPositions(),
    fetchRegionBusesNewcastleHunterPositions(),
    fetchRegionBusesFarWestPositions(),
  ]);
}
