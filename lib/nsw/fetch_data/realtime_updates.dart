import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

import 'realtime_feed_fetcher.dart';

//https://opendata.transport.nsw.gov.au/data/dataset/public-transport-realtime-trip-update
//https://opendata.transport.nsw.gov.au/dataset/public-transport-realtime-trip-update-v2

Future<FeedMessage?> fetchBusesUpdates({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/buses',
    logLabel: 'bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchFerriesSydneyFerriesUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/ferries/sydneyferries',
    logLabel: 'Sydney Ferries updates',
    query: query,
  );
}

Future<FeedMessage?> fetchFerriesMFFUpdates({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/ferries/MFF',
    logLabel: 'MFF updates',
    query: query,
  );
}

Future<FeedMessage?> fetchLightRailCbdAndSoutheastUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/cbdandsoutheast',
    logLabel: 'CBD and Southeast light rail updates',
    query: query,
  );
}

Future<FeedMessage?> fetchLightRailInnerWestUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/innerwest',
    logLabel: 'Inner West light rail updates',
    query: query,
  );
}

Future<FeedMessage?> fetchLightRailNewcastleUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/newcastle',
    logLabel: 'Newcastle light rail updates',
    query: query,
  );
}

Future<FeedMessage?> fetchLightRailParramattaUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/parramatta',
    logLabel: 'Parramatta light rail updates',
    query: query,
  );
}

Future<FeedMessage?> fetchNswTrainsUpdates({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/nswtrains',
    logLabel: 'NSW Trains updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/centralwestandorana',
    logLabel: 'Central West and Orana bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Updates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/centralwestandorana2',
    logLabel: 'Central West and Orana 2 bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesFarWestUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/farwest',
    logLabel: 'Far West bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/newcastlehunter',
    logLabel: 'Newcastle Hunter bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/newenglandnorthwest',
    logLabel: 'New England North West bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoastUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast',
    logLabel: 'North Coast bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Updates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast2',
    logLabel: 'North Coast 2 bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Updates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast3',
    logLabel: 'North Coast 3 bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/riverinamurray',
    logLabel: 'Riverina Murray bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Updates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/riverinamurray2',
    logLabel: 'Riverina Murray 2 bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/southeasttablelands',
    logLabel: 'South East Tablelands bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Updates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/southeasttablelands2',
    logLabel: 'South East Tablelands 2 bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsUpdates({
  RealtimeQuery? query,
}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/sydneysurrounds',
    logLabel: 'Sydney Surrounds bus updates',
    query: query,
  );
}

Future<FeedMessage?> fetchSydneyTrainsUpdates({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v2/gtfs/realtime/sydneytrains',
    logLabel: 'Sydney Trains updates',
    query: query,
  );
}

Future<FeedMessage?> fetchSydneyMetroUpdates({RealtimeQuery? query}) async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v2/gtfs/realtime/metro',
    logLabel: 'Sydney Metro updates',
    query: query,
  );
}

Future<List<FeedMessage?>> fetchAllLightRail({RealtimeQuery? query}) async {
  return await Future.wait([
    fetchLightRailCbdAndSoutheastUpdates(query: query).catchError((_) => null),
    fetchLightRailInnerWestUpdates(query: query).catchError((_) => null),
    fetchLightRailNewcastleUpdates(query: query).catchError((_) => null),
    fetchLightRailParramattaUpdates(query: query).catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> fetchAllFerries({RealtimeQuery? query}) async {
  return await Future.wait([
    fetchFerriesSydneyFerriesUpdates(query: query).catchError((_) => null),
    fetchFerriesMFFUpdates(query: query).catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> fetchAllRegionBuses({RealtimeQuery? query}) async {
  return await Future.wait([
    fetchRegionBusesCentralWestAndOranaUpdates(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesCentralWestAndOrana2Updates(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesFarWestUpdates(query: query).catchError((_) => null),
    fetchRegionBusesNewcastleHunterUpdates(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesNewEnglandNorthWestUpdates(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesNorthCoastUpdates(query: query).catchError((_) => null),
    fetchRegionBusesNorthCoast2Updates(query: query).catchError((_) => null),
    fetchRegionBusesNorthCoast3Updates(query: query).catchError((_) => null),
    fetchRegionBusesRiverinaMurrayUpdates(query: query).catchError((_) => null),
    fetchRegionBusesRiverinaMurray2Updates(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesSouthEastTablelandsUpdates(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesSouthEastTablelands2Updates(
      query: query,
    ).catchError((_) => null),
    fetchRegionBusesSydneySurroundsUpdates(
      query: query,
    ).catchError((_) => null),
  ]);
}
