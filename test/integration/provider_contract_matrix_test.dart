import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/adapters/tfnsw_transit_adapter.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/tasmania/tasmania_gtfs.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';
import 'package:lbww_flutter/western_australia/transperth_gtfs.dart';
import 'package:lbww_flutter/northern_territory/nt_gtfs.dart';

void main() {
  test('every registered region exposes a coherent provider contract', () {
    final providers = <TransitRegionServices>[
      buildTfnswRegionServices(),
      buildPtvRegionServices(),
      buildTranslinkRegionServices(),
      buildAdelaideMetroRegionServices(),
      buildTasmaniaRegionServices(),
      buildNorthernTerritoryRegionServices(),
      buildWesternAustraliaRegionServices(),
    ];

    expect(providers.map((services) => services.region), hasLength(7));
    expect(providers.map((services) => services.region).toSet(), hasLength(7));
    for (final services in providers) {
      expect(services.stops, isNotNull, reason: services.region.label);
      expect(
        services.attribution.provider,
        services.provider,
        reason: services.region.label,
      );
      expect(services.attribution.url, startsWith('https://'));
    }

    final localGtfsProviders = providers.where(
      (services) => services.region != TransitRegion.nsw,
    );
    for (final services in localGtfsProviders) {
      expect(services.staticGtfs, isNotNull, reason: services.region.label);
      expect(services.departures, isNotNull, reason: services.region.label);
      expect(services.journeyPlanner, isNotNull, reason: services.region.label);
    }
  });

  test('static-only regions do not advertise unavailable realtime feeds', () {
    expect(buildTasmaniaRegionServices().realtime, isNull);
    expect(buildNorthernTerritoryRegionServices().realtime, isNull);
    expect(buildWesternAustraliaRegionServices().realtime, isNull);
  });
}
