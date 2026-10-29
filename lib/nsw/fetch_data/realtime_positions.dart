import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

import 'realtime_feed_fetcher.dart';

Future<FeedMessage?> fetchSydneyTrainsPositions({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos/sydneytrains',
    logLabel: 'Sydney Trains positions',
    query: query,
  );
}

Future<FeedMessage?> fetchSydneyMetroPositions({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v2/gtfs/vehiclepos/metro',
    logLabel: 'Sydney Metro positions',
    query: query,
  );
}

Future<FeedMessage?> fetchBusesPositions({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/buses',
    logLabel: 'bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchNswTrainsPositions({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/nswtrains',
    logLabel: 'NSW Trains positions',
    query: query,
  );
}

// --- Ferries ---
Future<FeedMessage?> fetchFerriesSydneyFerriesPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/ferries/sydneyferries',
    logLabel: 'Sydney Ferries positions',
    query: query,
  );
}

Future<FeedMessage?> fetchFerriesMFFPositions({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/ferries/MFF',
    logLabel: 'MFF positions',
    query: query,
  );
}

// --- Lightrail ---
Future<FeedMessage?> fetchLightRailCbdAndSoutheastPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/cbdandsoutheast',
    logLabel: 'CBD and Southeast light rail positions',
    query: query,
  );
}

Future<FeedMessage?> fetchLightRailInnerWestPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/innerwest',
    logLabel: 'Inner West light rail positions',
    query: query,
  );
}

Future<FeedMessage?> fetchLightRailNewcastlePositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/newcastle',
    logLabel: 'Newcastle light rail positions',
    query: query,
  );
}

Future<FeedMessage?> fetchLightRailParramattaPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/lightrail/parramatta',
    logLabel: 'Parramatta light rail positions',
    query: query,
  );
}

// --- Region Buses ---
Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/centralwestandorana',
    logLabel: 'Central West and Orana bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Positions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/centralwestandorana2',
    logLabel: 'Central West and Orana 2 bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/newenglandnorthwest',
    logLabel: 'New England North West bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoastPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast',
    logLabel: 'North Coast bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Positions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast2',
    logLabel: 'North Coast 2 bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Positions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/northcoast3',
    logLabel: 'North Coast 3 bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/riverinamurray',
    logLabel: 'Riverina Murray bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Positions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/riverinamurray2',
    logLabel: 'Riverina Murray 2 bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/southeasttablelands',
    logLabel: 'South East Tablelands bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Positions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/southeasttablelands2',
    logLabel: 'South East Tablelands 2 bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/sydneysurrounds',
    logLabel: 'Sydney Surrounds bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/newcastlehunter',
    logLabel: 'Newcastle Hunter bus positions',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesFarWestPositions({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/regionbuses/farwest',
    logLabel: 'Far West bus positions',
    query: query,
  );
}

Future<List<FeedMessage?>> getAllFerries({RealtimeQuery? query}) async {
  return await Future.wait([
    fetchFerriesSydneyFerriesPositions(query: query).catchError((_) => null),
    fetchFerriesMFFPositions(query: query).catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> getAllLightRail({RealtimeQuery? query}) async {
  return await Future.wait([
    fetchLightRailCbdAndSoutheastPositions(
      query: query,
    ).catchError((_) => null),
    fetchLightRailInnerWestPositions(query: query).catchError((_) => null),
    fetchLightRailNewcastlePositions(query: query).catchError((_) => null),
    fetchLightRailParramattaPositions(query: query).catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> getAllRegionBuses({RealtimeQuery? query}) async {
  return await Future.wait([
    fetchRegionBusesCentralWestAndOranaPositions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesCentralWestAndOrana2Positions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesNewEnglandNorthWestPositions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesNorthCoastPositions(query: query).catchError((_) => null),
    fetchRegionBusesNorthCoast2Positions(query: query).catchError((_) => null),
    fetchRegionBusesNorthCoast3Positions(query: query).catchError((_) => null),
    fetchRegionBusesRiverinaMurrayPositions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesRiverinaMurray2Positions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesSouthEastTablelandsPositions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesSouthEastTablelands2Positions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesSydneySurroundsPositions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesNewcastleHunterPositions(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesFarWestPositions(query: query).catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> fetchRegionBusesPositions({
  RealtimeQuery? query,
}) async {
  final futures = [
    fetchRegionBusesCentralWestAndOranaPositions(query: query),
    fetchRegionBusesCentralWestAndOrana2Positions(query: query),
    fetchRegionBusesNewEnglandNorthWestPositions(query: query),
    fetchRegionBusesNorthCoastPositions(query: query),
    fetchRegionBusesNorthCoast2Positions(query: query),
    fetchRegionBusesNorthCoast3Positions(query: query),
    fetchRegionBusesRiverinaMurrayPositions(query: query),
    fetchRegionBusesRiverinaMurray2Positions(query: query),
    fetchRegionBusesSouthEastTablelandsPositions(query: query),
    fetchRegionBusesSouthEastTablelands2Positions(query: query),
    fetchRegionBusesSydneySurroundsPositions(query: query),
    fetchRegionBusesNewcastleHunterPositions(query: query),
    fetchRegionBusesFarWestPositions(query: query),
  ];
  final results = await Future.wait(futures);
  return results;
}
