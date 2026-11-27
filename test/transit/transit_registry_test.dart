import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/transit.dart';

class _FakeStops implements StopRepository {
  const _FakeStops();

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async => null;

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async =>
      const <TransitStop>[];
}

class _FakePlanner implements JourneyPlanner {
  const _FakePlanner();

  @override
  Future<JourneyPlan> planJourney(JourneyPlanRequest request) async =>
      const JourneyPlan(journeys: <TransitJourney>[]);
}

void main() {
  test('registry returns configured services for each region', () {
    final registry = InMemoryTransitRegistry([
      const TransitRegionServices(
        region: TransitRegion.nsw,
        provider: TransitProviderId.tfnsw,
        stops: _FakeStops(),
        journeyPlanner: _FakePlanner(),
        attribution: TransitProviderAttribution(
          provider: TransitProviderId.tfnsw,
          name: 'TfNSW',
          licenseName: 'terms',
          url: 'https://example.com',
        ),
      ),
      const TransitRegionServices(
        region: TransitRegion.victoria,
        provider: TransitProviderId.ptv,
        stops: _FakeStops(),
        attribution: TransitProviderAttribution(
          provider: TransitProviderId.ptv,
          name: 'PTV',
          licenseName: 'terms',
          url: 'https://example.com',
        ),
      ),
      const TransitRegionServices(
        region: TransitRegion.queensland,
        provider: TransitProviderId.translink,
        stops: _FakeStops(),
        attribution: TransitProviderAttribution(
          provider: TransitProviderId.translink,
          name: 'TransLink',
          licenseName: 'terms',
          url: 'https://example.com',
        ),
      ),
    ]);

    expect(
      registry.servicesFor(TransitRegion.nsw).supportsJourneyPlanning,
      isTrue,
    );
    expect(
      registry.servicesFor(TransitRegion.victoria).supportsJourneyPlanning,
      isFalse,
    );
    expect(
      registry.servicesFor(TransitRegion.queensland).supportsJourneyPlanning,
      isFalse,
    );
    expect(registry.allServices, hasLength(3));
  });
}
