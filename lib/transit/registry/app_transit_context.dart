import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/northern_territory/nt_gtfs.dart';
import 'package:lbww_flutter/nsw/adapters/tfnsw_transit_adapter.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/tasmania/tasmania_gtfs.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';
import 'package:lbww_flutter/western_australia/transperth_gtfs.dart';

class AppTransitContext {
  AppTransitContext._();

  static final AppTransitContext instance = AppTransitContext._();

  late final TransitRegistry _registry;
  bool _initialized = false;

  ValueListenable<TransitRegion> get selectedRegionListenable =>
      TransportPreferencesService.selectedRegion;

  ValueListenable<Set<TransitRegion>> get enabledRegionsListenable =>
      TransportPreferencesService.enabledRegions;

  TransitRegion get selectedRegion =>
      TransportPreferencesService.selectedRegion.value;

  Set<TransitRegion> get enabledRegions =>
      Set.unmodifiable(TransportPreferencesService.enabledRegions.value);

  List<TransitRegionServices> get enabledServices =>
      enabledRegions.map(servicesFor).toList(growable: false);

  TransitRegionServices get currentServices {
    _ensureInitialized();
    return _registry.servicesFor(selectedRegion);
  }

  void _ensureInitialized() {
    if (_initialized) return;
    _registry = InMemoryTransitRegistry([
      buildTfnswRegionServices(),
      buildPtvRegionServices(),
      buildTranslinkRegionServices(),
      buildAdelaideMetroRegionServices(),
      buildTasmaniaRegionServices(),
      buildNorthernTerritoryRegionServices(),
      buildWesternAustraliaRegionServices(),
    ]);
    _initialized = true;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    currentServices;
  }

  TransitRegionServices servicesFor(TransitRegion region) {
    _ensureInitialized();
    return _registry.servicesFor(region);
  }

  Future<void> setSelectedRegion(TransitRegion region) async {
    await TransportPreferencesService.setSelectedRegion(region);
  }

  Future<void> setEnabledRegions(Set<TransitRegion> regions) async {
    await TransportPreferencesService.setEnabledRegions(regions);
  }
}
