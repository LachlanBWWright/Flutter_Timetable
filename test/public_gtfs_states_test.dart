import 'package:test/test.dart';

import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/northern_territory/nt_gtfs.dart';
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/tasmania/tasmania_gtfs.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/western_australia/transperth_gtfs.dart';

void main() {
  test('credential-free state feed catalog has stable official URLs', () {
    expect(tasmaniaGtfsUrl, startsWith('https://'));
    expect(ntDarwinGtfsUrl, startsWith('https://'));
    expect(ntAliceSpringsGtfsUrl, startsWith('https://'));
    expect(transperthGtfsUrl, startsWith('https://'));
  });

  test(
    'new region providers expose the full stop-to-journey capability set',
    () {
      final providers = [
        buildAdelaideMetroRegionServices(),
        buildTasmaniaRegionServices(),
        buildNorthernTerritoryRegionServices(),
        buildWesternAustraliaRegionServices(),
      ];
      expect(providers, hasLength(4));
      for (final services in providers) {
        expect(services.staticGtfs, isNotNull, reason: services.region.label);
        expect(services.departures, isNotNull, reason: services.region.label);
        expect(
          services.journeyPlanner,
          isNotNull,
          reason: services.region.label,
        );
        expect(services.stops, isNotNull, reason: services.region.label);
      }
      expect(
        TransportMode.values,
        containsAll(<TransportMode>[
          TransportMode.train,
          TransportMode.lightrail,
          TransportMode.metro,
          TransportMode.bus,
          TransportMode.ferry,
        ]),
      );
    },
  );
}
