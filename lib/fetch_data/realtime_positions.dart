import 'package:lbww_flutter/backends/RealtimePositionsV1Api.dart';
import 'package:lbww_flutter/backends/RealtimePositionsV2Api.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

Future<FeedMessage?> fetchSydneyTrainsPositions() async {
  final res = await realtimePositionsV2Api.sydneytrainsGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchSydneyMetroPositions() async {
  final res = await realtimePositionsV2Api.metroGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchBusesPositions() async {
  final res = await realtimePositionsV1Api.busesGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchNswTrainsPositions() async {
  final res = await realtimePositionsV1Api.nswtrainsGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

// --- Ferries ---
Future<FeedMessage?> fetchFerriesSydneyFerriesPositions() async {
  final res = await realtimePositionsV1Api.ferriesSydneyferriesGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchFerriesMFFPositions() async {
  final res = await realtimePositionsV1Api.ferriesMFFGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

// --- Lightrail ---
Future<FeedMessage?> fetchLightRailCbdAndSoutheastPositions() async {
  final res = await realtimePositionsV1Api.lightrailCbdandsoutheastGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchLightRailInnerWestPositions() async {
  final res = await realtimePositionsV1Api.lightrailInnerwestGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchLightRailNewcastlePositions() async {
  final res = await realtimePositionsV1Api.lightrailNewcastleGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchLightRailParramattaPositions() async {
  final res = await realtimePositionsV1Api.lightrailParramattaGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

// --- Region Buses ---
Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaPositions() async {
  final res = await realtimePositionsV1Api.regionbusesCentralwestandoranaGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Positions() async {
  final res = await realtimePositionsV1Api.regionbusesCentralwestandorana2Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestPositions() async {
  final res = await realtimePositionsV1Api.regionbusesNewenglandnorthwestGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNorthCoastPositions() async {
  final res = await realtimePositionsV1Api.regionbusesNorthcoastGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Positions() async {
  final res = await realtimePositionsV1Api.regionbusesNorthcoast2Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Positions() async {
  final res = await realtimePositionsV1Api.regionbusesNorthcoast3Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayPositions() async {
  final res = await realtimePositionsV1Api.regionbusesRiverinamurrayGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Positions() async {
  final res = await realtimePositionsV1Api.regionbusesRiverinamurray2Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsPositions() async {
  final res = await realtimePositionsV1Api.regionbusesSoutheasttablelandsGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Positions() async {
  final res = await realtimePositionsV1Api.regionbusesSoutheasttablelands2Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsPositions() async {
  final res = await realtimePositionsV1Api.regionbusesSydneysurroundsGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterPositions() async {
  final res = await realtimePositionsV1Api.regionbusesNewcastlehunterGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesFarWestPositions() async {
  final res = await realtimePositionsV1Api.regionbusesFarwestGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
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
