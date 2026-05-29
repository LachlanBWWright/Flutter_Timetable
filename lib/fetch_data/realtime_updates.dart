//https://opendata.transport.nsw.gov.au/data/dataset/public-transport-realtime-trip-update
//https://opendata.transport.nsw.gov.au/dataset/public-transport-realtime-trip-update-v2

import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

import 'realtime_feed_fetcher.dart';

Future<FeedMessage?> fetchBusesUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/buses',
    logLabel: 'bus updates',
  );
}

Future<FeedMessage?> fetchFerriesSydneyFerriesUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/ferries/sydneyferries',
    logLabel: 'Sydney Ferries updates',
  );
}

Future<FeedMessage?> fetchFerriesMFFUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/ferries/MFF',
    logLabel: 'MFF updates',
  );
}

Future<FeedMessage?> fetchLightRailCbdAndSoutheastUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/cbdandsoutheast',
    logLabel: 'CBD and Southeast light rail updates',
  );
}

Future<FeedMessage?> fetchLightRailInnerWestUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/innerwest',
    logLabel: 'Inner West light rail updates',
  );
}

Future<FeedMessage?> fetchLightRailNewcastleUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/newcastle',
    logLabel: 'Newcastle light rail updates',
  );
}

Future<FeedMessage?> fetchLightRailParramattaUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/lightrail/parramatta',
    logLabel: 'Parramatta light rail updates',
  );
}

Future<FeedMessage?> fetchNswTrainsUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/nswtrains',
    logLabel: 'NSW Trains updates',
  );
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/centralwestandorana',
    logLabel: 'Central West and Orana bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Updates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/centralwestandorana2',
    logLabel: 'Central West and Orana 2 bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesFarWestUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/farwest',
    logLabel: 'Far West bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/newcastlehunter',
    logLabel: 'Newcastle Hunter bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/newenglandnorthwest',
    logLabel: 'New England North West bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoastUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast',
    logLabel: 'North Coast bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Updates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast2',
    logLabel: 'North Coast 2 bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Updates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/northcoast3',
    logLabel: 'North Coast 3 bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/riverinamurray',
    logLabel: 'Riverina Murray bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Updates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/riverinamurray2',
    logLabel: 'Riverina Murray 2 bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/southeasttablelands',
    logLabel: 'South East Tablelands bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Updates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/southeasttablelands2',
    logLabel: 'South East Tablelands 2 bus updates',
  );
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v1/gtfs/realtime/regionbuses/sydneysurrounds',
    logLabel: 'Sydney Surrounds bus updates',
  );
}

Future<FeedMessage?> fetchSydneyTrainsUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v2/gtfs/realtime/sydneytrains',
    logLabel: 'Sydney Trains updates',
  );
}

Future<FeedMessage?> fetchSydneyMetroUpdates() async {
  return fetchRealtimeFeed(
    'https://api.transport.nsw.gov.au/v2/gtfs/realtime/metro',
    logLabel: 'Sydney Metro updates',
  );
}

Future<List<FeedMessage?>> fetchAllLightRail() async {
  return await Future.wait([
    fetchLightRailCbdAndSoutheastUpdates().catchError((_) => null),
    fetchLightRailInnerWestUpdates().catchError((_) => null),
    fetchLightRailNewcastleUpdates().catchError((_) => null),
    fetchLightRailParramattaUpdates().catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> fetchAllFerries() async {
  return await Future.wait([
    fetchFerriesSydneyFerriesUpdates().catchError((_) => null),
    fetchFerriesMFFUpdates().catchError((_) => null),
  ]);
}

Future<List<FeedMessage?>> fetchAllRegionBuses() async {
  return await Future.wait([
    fetchRegionBusesCentralWestAndOranaUpdates().catchError((_) => null),
    fetchRegionBusesCentralWestAndOrana2Updates().catchError((_) => null),
    fetchRegionBusesFarWestUpdates().catchError((_) => null),
    fetchRegionBusesNewcastleHunterUpdates().catchError((_) => null),
    fetchRegionBusesNewEnglandNorthWestUpdates().catchError((_) => null),
    fetchRegionBusesNorthCoastUpdates().catchError((_) => null),
    fetchRegionBusesNorthCoast2Updates().catchError((_) => null),
    fetchRegionBusesNorthCoast3Updates().catchError((_) => null),
    fetchRegionBusesRiverinaMurrayUpdates().catchError((_) => null),
    fetchRegionBusesRiverinaMurray2Updates().catchError((_) => null),
    fetchRegionBusesSouthEastTablelandsUpdates().catchError((_) => null),
    fetchRegionBusesSouthEastTablelands2Updates().catchError((_) => null),
    fetchRegionBusesSydneySurroundsUpdates().catchError((_) => null),
  ]);
}
