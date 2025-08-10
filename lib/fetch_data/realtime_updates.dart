//https://opendata.transport.nsw.gov.au/data/dataset/public-transport-realtime-trip-update
//https://opendata.transport.nsw.gov.au/dataset/public-transport-realtime-trip-update-v2

import 'package:lbww_flutter/backends/RealtimeTripUpdateV1Api.dart';
import 'package:lbww_flutter/backends/RealtimeTripUpdateV2Api.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

Future<FeedMessage?> fetchBusesUpdates() async {
  final res = await realtimeTripUpdateV1Api.busesGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchFerriesSydneyFerriesUpdates() async {
  final res = await realtimeTripUpdateV1Api.ferriesSydneyferriesGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchFerriesMFFUpdates() async {
  final res = await realtimeTripUpdateV1Api.ferriesMFFGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchLightRailCbdAndSoutheastUpdates() async {
  final res = await realtimeTripUpdateV1Api.lightrailCbdandsoutheastGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchLightRailInnerWestUpdates() async {
  final res = await realtimeTripUpdateV1Api.lightrailInnerwestGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchLightRailNewcastleUpdates() async {
  final res = await realtimeTripUpdateV1Api.lightrailNewcastleGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchLightRailParramattaUpdates() async {
  final res = await realtimeTripUpdateV1Api.lightrailParramattaGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchNswTrainsUpdates() async {
  final res = await realtimeTripUpdateV1Api.nswtrainsGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOranaUpdates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesCentralwestandoranaGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesCentralWestAndOrana2Updates() async {
  final res =
      await realtimeTripUpdateV1Api.regionbusesCentralwestandorana2Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesFarWestUpdates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesFarwestGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNewcastleHunterUpdates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesNewcastlehunterGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNewEnglandNorthWestUpdates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesNewenglandnorthwestGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNorthCoastUpdates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesNorthcoastGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNorthCoast2Updates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesNorthcoast2Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesNorthCoast3Updates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesNorthcoast3Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurrayUpdates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesRiverinamurrayGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesRiverinaMurray2Updates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesRiverinamurray2Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelandsUpdates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesSoutheasttablelandsGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesSouthEastTablelands2Updates() async {
  final res =
      await realtimeTripUpdateV1Api.regionbusesSoutheasttablelands2Get();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchRegionBusesSydneySurroundsUpdates() async {
  final res = await realtimeTripUpdateV1Api.regionbusesSydneysurroundsGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchSydneyTrainsUpdates() async {
  final res = await realtimeTripUpdateV2Api.sydneytrainsGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
}

Future<FeedMessage?> fetchSydneyMetroUpdates() async {
  final res = await realtimeTripUpdateV2Api.metroGet();
  if (!res.isSuccessful || res.body == null) return null;
  return FeedMessage.fromBuffer(res.body!);
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
