import '../../constants/transport_modes.dart';
import '../../gtfs/gtfs_data.dart';
import '../fetch_data/timetable_data.dart';
import 'stops_service_impl.dart';

/// One catalog drives static-feed fetching and every NSW mode stop list.
/// The exhaustive switch makes new endpoints require a loader and mode.
extension NswGtfsEndpointDefinition on StopsEndpoint {
  (TransportMode, Future<GtfsData?> Function()) get _definition =>
      switch (this) {
        StopsEndpoint.nswtrains => (
          TransportMode.train,
          fetchNswTrainsGtfsData,
        ),
        StopsEndpoint.sydneytrains => (
          TransportMode.train,
          fetchSydneyTrainsGtfsData,
        ),
        StopsEndpoint.metro => (TransportMode.metro, fetchMetroGtfsData),
        StopsEndpoint.lightrailInnerwest => (
          TransportMode.lightrail,
          fetchLightRailInnerWestGtfsData,
        ),
        StopsEndpoint.lightrailNewcastle => (
          TransportMode.lightrail,
          fetchLightRailNewcastleGtfsData,
        ),
        StopsEndpoint.lightrailCbdandsoutheast => (
          TransportMode.lightrail,
          fetchLightRailCbdAndSoutheastGtfsData,
        ),
        StopsEndpoint.lightrailParramatta => (
          TransportMode.lightrail,
          fetchLightRailParramattaGtfsData,
        ),
        StopsEndpoint.buses => (TransportMode.bus, fetchBusesGtfsData),
        StopsEndpoint.busesSbsc006 => (
          TransportMode.bus,
          fetchBusesSBSC006GtfsData,
        ),
        StopsEndpoint.busesGbsc001 => (
          TransportMode.bus,
          fetchBusesGSBC001GtfsData,
        ),
        StopsEndpoint.busesGsbc002 => (
          TransportMode.bus,
          fetchBusesGSBC002GtfsData,
        ),
        StopsEndpoint.busesGsbc003 => (
          TransportMode.bus,
          fetchBusesGSBC003GtfsData,
        ),
        StopsEndpoint.busesGsbc004 => (
          TransportMode.bus,
          fetchBusesGSBC004GtfsData,
        ),
        StopsEndpoint.busesGsbc007 => (
          TransportMode.bus,
          fetchBusesGSBC007GtfsData,
        ),
        StopsEndpoint.busesGsbc008 => (
          TransportMode.bus,
          fetchBusesGSBC008GtfsData,
        ),
        StopsEndpoint.busesGsbc009 => (
          TransportMode.bus,
          fetchBusesGSBC009GtfsData,
        ),
        StopsEndpoint.busesGsbc010 => (
          TransportMode.bus,
          fetchBusesGSBC010GtfsData,
        ),
        StopsEndpoint.busesGsbc014 => (
          TransportMode.bus,
          fetchBusesGSBC014GtfsData,
        ),
        StopsEndpoint.busesOsmbsc001 => (
          TransportMode.bus,
          fetchBusesOSMBSC001GtfsData,
        ),
        StopsEndpoint.busesOsmbsc002 => (
          TransportMode.bus,
          fetchBusesOSMBSC002GtfsData,
        ),
        StopsEndpoint.busesOsmbsc003 => (
          TransportMode.bus,
          fetchBusesOSMBSC003GtfsData,
        ),
        StopsEndpoint.busesOsmbsc004 => (
          TransportMode.bus,
          fetchBusesOSMBSC004GtfsData,
        ),
        StopsEndpoint.busesOmbsc006 => (
          TransportMode.bus,
          fetchBusesOMBSC006GtfsData,
        ),
        StopsEndpoint.busesOmbsc007 => (
          TransportMode.bus,
          fetchBusesOMBSC007GtfsData,
        ),
        StopsEndpoint.busesOsmbsc008 => (
          TransportMode.bus,
          fetchBusesOSMBSC008GtfsData,
        ),
        StopsEndpoint.busesOsmbsc009 => (
          TransportMode.bus,
          fetchBusesOSMBSC009GtfsData,
        ),
        StopsEndpoint.busesOsmbsc010 => (
          TransportMode.bus,
          fetchBusesOSMBSC010GtfsData,
        ),
        StopsEndpoint.busesOsmbsc011 => (
          TransportMode.bus,
          fetchBusesOSMBSC011GtfsData,
        ),
        StopsEndpoint.busesOsmbsc012 => (
          TransportMode.bus,
          fetchBusesOSMBSC012GtfsData,
        ),
        StopsEndpoint.busesNisc001 => (
          TransportMode.bus,
          fetchBusesNISC001GtfsData,
        ),
        StopsEndpoint.busesReplacementBus => (
          TransportMode.bus,
          fetchBusesReplacementBusGtfsData,
        ),
        StopsEndpoint.ferriesSydneyFerries => (
          TransportMode.ferry,
          fetchFerriesSydneyFerriesGtfsData,
        ),
        StopsEndpoint.ferriesMff => (
          TransportMode.ferry,
          fetchFerriesMFFGtfsData,
        ),
        StopsEndpoint.regionbusesSoutheastTablelands => (
          TransportMode.bus,
          fetchRegionBusesSouthEastTablelandsGtfsData,
        ),
        StopsEndpoint.regionbusesSoutheastTablelands2 => (
          TransportMode.bus,
          fetchRegionBusesSouthEastTablelands2GtfsData,
        ),
        StopsEndpoint.regionbusesNorthCoast => (
          TransportMode.bus,
          fetchRegionBusesNorthCoastGtfsData,
        ),
        StopsEndpoint.regionbusesNorthCoast2 => (
          TransportMode.bus,
          fetchRegionBusesNorthCoast2GtfsData,
        ),
        StopsEndpoint.regionbusesCentralWestAndOrana => (
          TransportMode.bus,
          fetchRegionBusesCentralWestAndOranaGtfsData,
        ),
        StopsEndpoint.regionbusesCentralWestAndOrana2 => (
          TransportMode.bus,
          fetchRegionBusesCentralWestAndOrana2GtfsData,
        ),
        StopsEndpoint.regionbusesRiverinaMurray => (
          TransportMode.bus,
          fetchRegionBusesRiverinaMurrayGtfsData,
        ),
        StopsEndpoint.regionbusesNewEnglandNorthWest => (
          TransportMode.bus,
          fetchRegionBusesNewEnglandNorthWestGtfsData,
        ),
        StopsEndpoint.regionbusesRiverinaMurray2 => (
          TransportMode.bus,
          fetchRegionBusesRiverinaMurray2GtfsData,
        ),
        StopsEndpoint.regionbusesNorthCoast3 => (
          TransportMode.bus,
          fetchRegionBusesNorthCoast3GtfsData,
        ),
        StopsEndpoint.regionbusesSydneySurrounds => (
          TransportMode.bus,
          fetchRegionBusesSydneySurroundsGtfsData,
        ),
        StopsEndpoint.regionbusesNewcastleHunter => (
          TransportMode.bus,
          fetchRegionBusesNewcastleHunterGtfsData,
        ),
        StopsEndpoint.regionbusesFarWest => (
          TransportMode.bus,
          fetchRegionBusesFarWestGtfsData,
        ),
      };

  TransportMode get transportMode => _definition.$1;

  Future<GtfsData?> fetchGtfsData() => _definition.$2();
}

class NswGtfsEndpointCatalog {
  const NswGtfsEndpointCatalog._();

  /// TrainLink remains opt-in for catalog views that load it separately.
  static List<StopsEndpoint> endpointsForMode(
    TransportMode mode, {
    bool includeTrainLink = true,
  }) => [
    for (final endpoint in StopsEndpoint.values)
      if (endpoint.transportMode == mode &&
          (includeTrainLink || endpoint != StopsEndpoint.nswtrains))
        endpoint,
  ];
}
