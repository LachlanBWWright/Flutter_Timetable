import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/nsw/adapters/tfnsw_transit_adapter.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';

class AppTransitContext {
  AppTransitContext._();

  static final AppTransitContext instance = AppTransitContext._();

  late final TransitRegistry _registry;
  bool _initialized = false;

  ValueListenable<TransitRegion> get selectedRegionListenable =>
      TransportPreferencesService.selectedRegion;

  TransitRegion get selectedRegion => TransportPreferencesService.selectedRegion.value;

  TransitRegionServices get currentServices => _registry.servicesFor(selectedRegion);

  Future<void> initialize() async {
    if (_initialized) return;
    _registry = InMemoryTransitRegistry([
      buildTfnswRegionServices(),
      buildPtvRegionServices(),
      buildTranslinkRegionServices(),
    ]);
    _initialized = true;
  }

  TransitRegionServices servicesFor(TransitRegion region) => _registry.servicesFor(region);

  Future<void> setSelectedRegion(TransitRegion region) async {
    await TransportPreferencesService.setSelectedRegion(region);
  }
}
