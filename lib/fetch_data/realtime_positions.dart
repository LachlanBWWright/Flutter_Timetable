import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

import 'realtime_feed_fetcher.dart';

Future<FeedMessage?> fetchSydneyTrainsPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos/sydneytrains',
    logLabel: 'Sydney Trains positions',
  );
}

Future<FeedMessage?> fetchSydneyMetroPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos/metro',
    logLabel: 'Sydney Metro positions',
  );
}

Future<FeedMessage?> fetchBusesPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/buses',
    logLabel: 'bus positions',
  );
}

Future<FeedMessage?> fetchNswTrainsPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/nswtrains',
    logLabel: 'NSW Trains positions',
  );
}

// --- Ferries ---
Future<FeedMessage?> fetchFerriesSydneyFerriesPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/ferries/sydneyferries',
    logLabel: 'Sydney Ferries positions',
  );
}

Future<FeedMessage?> fetchFerriesMFFPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/ferries/MFF',
    logLabel: 'MFF positions',
  );
}

// --- Lightrail ---
Future<FeedMessage?> fetchLightRailCbdAndSoutheastPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/cbdandsoutheast',
    logLabel: 'CBD and Southeast light rail positions',
  );
}

Future<FeedMessage?> fetchLightRailInnerWestPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/innerwest',
    logLabel: 'Inner West light rail positions',
  );
}

Future<FeedMessage?> fetchLightRailNewcastlePositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/newcastle',
    logLabel: 'Newcastle light rail positions',
  );
}

Future<FeedMessage?> fetchLightRailParramattaPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/parramatta',
    logLabel: 'Parramatta light rail positions',
  );
}

// --- Region Buses ---
Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/centralwestandorana',
    logLabel: 'Central West and Orana bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Positions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/centralwestandorana2',
    logLabel: 'Central West and Orana 2 bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/newenglandnorthwest',
    logLabel: 'New England North West bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoastPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast',
    logLabel: 'North Coast bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Positions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast2',
    logLabel: 'North Coast 2 bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Positions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast3',
    logLabel: 'North Coast 3 bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/riverinamurray',
    logLabel: 'Riverina Murray bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Positions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/riverinamurray2',
    logLabel: 'Riverina Murray 2 bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/southeasttablelands',
    logLabel: 'South East Tablelands bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Positions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/southeasttablelands2',
    logLabel: 'South East Tablelands 2 bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/sydneysurrounds',
    logLabel: 'Sydney Surrounds bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/newcastlehunter',
    logLabel: 'Newcastle Hunter bus positions',
  );
}

Future<FeedMessage?> fetchRegionBusesFarWestPositions() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/farwest',
    logLabel: 'Far West bus positions',
  );
}

Future<List<FeedMessage?>> getAllFerries() async {
  return await Future.wait([
    fetchFerriesSydneyFerriesPositions().catchError((_) => null),
    fetchFerriesMFFPositions().catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> getAllLightRail() async {
  return await Future.wait([
    fetchLightRailCbdAndSoutheastPositions().catchError((_) => null),
    fetchLightRailInnerWestPositions().catchError((_) => null),
    fetchLightRailNewcastlePositions().catchError((_) => null),
    fetchLightRailParramattaPositions().catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> getAllRegionBuses() async {
  return await Future.wait([
    fetchRegionBusesCentralWestAndOranaPositions().catchError((_) => null),
    fetchRegionBusesCentralWestAndOrana2Positions().catchError((_) => null),
    fetchRegionBusesNewEnglandNorthWestPositions().catchError((_) => null),
    fetchRegionBusesNorthCoastPositions().catchError((_) => null),
    fetchRegionBusesNorthCoast2Positions().catchError((_) => null),
    fetchRegionBusesNorthCoast3Positions().catchError((_) => null),
    fetchRegionBusesRiverinaMurrayPositions().catchError((_) => null),
    fetchRegionBusesRiverinaMurray2Positions().catchError((_) => null),
    fetchRegionBusesSouthEastTablelandsPositions().catchError((_) => null),
    fetchRegionBusesSouthEastTablelands2Positions().catchError((_) => null),
    fetchRegionBusesSydneySurroundsPositions().catchError((_) => null),
    fetchRegionBusesNewcastleHunterPositions().catchError((_) => null),
    fetchRegionBusesFarWestPositions().catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> fetchRegionBusesPositions() async {
  final futures = [
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
  ];
  final results = await Future.wait(futures);
  return results;
}
