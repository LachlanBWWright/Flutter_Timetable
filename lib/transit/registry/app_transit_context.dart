import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/northern_territory/nt_gtfs.dart';
import 'package:lbww_flutter/nsw/adapters/tfnsw_transit_adapter.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/tasmania/tasmania_gtfs.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/registry/region_feature_flags.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';
import 'package:lbww_flutter/western_australia/transperth_gtfs.dart';

import '../errors/transit_failure.dart';
import '../gtfs/gtfs_journey_planner.dart';
import '../gtfs/gtfs_network_planner.dart';
import '../interfaces/transit_interfaces.dart';

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

  Set<TransitRegion> get enabledRegions => Set.unmodifiable(
    TransportPreferencesService.enabledRegions.value.intersection(
      RegionFeatureFlags.enabledRegions,
    ),
  );

  List<TransitRegionServices> get enabledServices =>
      enabledRegions.map(servicesFor).toList(growable: false);

  TransitRegionServices get currentServices {
    _ensureInitialized();
    return _registry.servicesFor(selectedRegion);
  }

  void _ensureInitialized() {
    if (_initialized) return;
    _registry = InMemoryTransitRegistry([
      if (RegionFeatureFlags.isEnabled(TransitRegion.nsw))
        buildTfnswRegionServices(),
      if (RegionFeatureFlags.victoria) buildPtvRegionServices(),
      if (RegionFeatureFlags.queensland) buildTranslinkRegionServices(),
      if (RegionFeatureFlags.southAustralia) buildAdelaideMetroRegionServices(),
      if (RegionFeatureFlags.tasmania) buildTasmaniaRegionServices(),
      if (RegionFeatureFlags.northernTerritory)
        buildNorthernTerritoryRegionServices(),
      if (RegionFeatureFlags.westernAustralia)
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

  Future<JourneyPlan> planJourney(JourneyPlanRequest request) {
    if (!RegionFeatureFlags.isEnabled(request.origin.region) ||
        !RegionFeatureFlags.isEnabled(request.destination.region)) {
      throw const UnsupportedCapability(
        message: 'A selected region is unavailable in this build.',
      );
    }
    if (request.origin.region != request.destination.region ||
        request.origin.provider != request.destination.provider ||
        request.origin.sourceId != request.destination.sourceId) {
      return GtfsNetworkPlanner(servicesFor: servicesFor).planJourney(request);
    }
    final service = servicesFor(request.origin.region);
    if (request.origin.region == TransitRegion.nsw &&
        request.walkingLimit != null &&
        service.timetableLoader != null) {
      return GtfsJourneyPlanner(
        region: service.region,
        provider: service.provider,
        loadData: service.timetableLoader!,
        loadCancellableData: service.cancellableTimetableLoader,
      ).planJourney(request);
    }
    final planner = service.journeyPlanner;
    if (planner == null) {
      throw const UnsupportedCapability(
        message: 'The selected provider has no journey planner.',
      );
    }
    return planner.planJourney(request);
  }

  Future<void> setSelectedRegion(TransitRegion region) async {
    if (!RegionFeatureFlags.isEnabled(region)) return;
    await TransportPreferencesService.setSelectedRegion(region);
  }

  Future<void> setEnabledRegions(Set<TransitRegion> regions) async {
    final allowed = regions.where(RegionFeatureFlags.isEnabled).toSet();
    await TransportPreferencesService.setEnabledRegions(
      allowed.isEmpty ? RegionFeatureFlags.enabledRegions : allowed,
    );
  }
}
