//https://opendata.transport.nsw.gov.au/data/dataset/public-transport-realtime-trip-update
//https://opendata.transport.nsw.gov.au/dataset/public-transport-realtime-trip-update-v2

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

Map<String, String> getHeaders() {
  final apiKey = dotenv.env['API_KEY'] ?? 'YOUR_API_KEY';
  return {
    'Authorization': 'apikey $apiKey',
    'Accept': 'application/x-protobuf',
  };
}

Future<FeedMessage?> fetchBusesUpdates() async {
  final url =
      Uri.parse('https://api.transport.nsw.gov.au/v1/gtfs/realtime/buses');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchFerriesSydneyFerriesUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/ferries/sydneyferries');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchFerriesMFFUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/ferries/MFF');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchLightRailCbdAndSoutheastUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/cbdandsoutheast');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchLightRailInnerWestUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/innerwest');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchLightRailNewcastleUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/newcastle');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchLightRailParramattaUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/parramatta');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchNswTrainsUpdates() async {
  final url =
      Uri.parse('https://api.transport.nsw.gov.au/v1/gtfs/realtime/nswtrains');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/centralwestandorana');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Updates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/centralwestandorana2');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesFarWestUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/farwest');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/newcastlehunter');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/newenglandnorthwest');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNorthCoastUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Updates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast2');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Updates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast3');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/riverinamurray');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Updates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/riverinamurray2');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/southeasttablelands');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Updates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/southeasttablelands2');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/sydneysurrounds');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchSydneyTrainsUpdates() async {
  final url = Uri.parse(
      'https://api.transport.nsw.gov.au/v2/gtfs/realtime/sydneytrains');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<FeedMessage?> fetchSydneyMetroUpdates() async {
  final url =
      Uri.parse('https://api.transport.nsw.gov.au/v2/gtfs/realtime/metro');
  final response = await http.get(url, headers: getHeaders());
  if (response.statusCode != 200) return null;
  return FeedMessage.fromBuffer(response.bodyBytes);
}

Future<List<FeedMessage?>> fetchAllLightRail() async {
  return await Future.wait([
    fetchLightRailCbdAndSoutheastUpdates(),
    fetchLightRailInnerWestUpdates(),
    fetchLightRailNewcastleUpdates(),
    fetchLightRailParramattaUpdates(),
  ]);
}

Future<List<FeedMessage?>> fetchAllFerries() async {
  return await Future.wait([
    fetchFerriesSydneyFerriesUpdates(),
    fetchFerriesMFFUpdates(),
  ]);
}

Future<List<FeedMessage?>> fetchAllRegionBuses() async {
  return await Future.wait([
    fetchRegionBusesCentralWestAndOranaUpdates(),
    fetchRegionBusesCentralWestAndOrana2Updates(),
    fetchRegionBusesFarWestUpdates(),
    fetchRegionBusesNewcastleHunterUpdates(),
    fetchRegionBusesNewEnglandNorthWestUpdates(),
    fetchRegionBusesNorthCoastUpdates(),
    fetchRegionBusesNorthCoast2Updates(),
    fetchRegionBusesNorthCoast3Updates(),
    fetchRegionBusesRiverinaMurrayUpdates(),
    fetchRegionBusesRiverinaMurray2Updates(),
    fetchRegionBusesSouthEastTablelandsUpdates(),
    fetchRegionBusesSouthEastTablelands2Updates(),
    fetchRegionBusesSydneySurroundsUpdates(),
  ]);
}
