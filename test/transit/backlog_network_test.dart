import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_network_planner.dart';
import 'package:lbww_flutter/transit/transit.dart';

class _Stops implements StopRepository {
  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async => null;
  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) async => [];
}

GtfsData _feed(bool first) => parseGtfsFiles({
  'agency.txt': 'agency_id,agency_name,agency_url,agency_timezone\nx,Test,https://example.com,Australia/Brisbane\n',
  'stops.txt': first
      ? 'stop_id,stop_name,stop_lat,stop_lon\nA,Start,-27.0,153\nB,Interchange,-27.1,153\n'
      : 'stop_id,stop_name,stop_lat,stop_lon\nA,Interchange,-27.1001,153\nB,End,-27.2,153\n',
  'routes.txt':
      'route_id,route_short_name,route_long_name,route_type\nR,1,Route,3\n',
  'trips.txt': 'route_id,service_id,trip_id\nR,S,T\n',
  'calendar_dates.txt': 'service_id,date,exception_type\nS,20260813,1\n',
  'stop_times.txt': first
      ? 'trip_id,arrival_time,departure_time,stop_id,stop_sequence\nT,10:00:00,10:00:00,A,1\nT,10:10:00,10:10:00,B,2\n'
      : 'trip_id,arrival_time,departure_time,stop_id,stop_sequence\nT,10:15:00,10:15:00,A,1\nT,10:25:00,10:25:00,B,2\n',
});
void main() {
  test('cross-region planning namespaces equal IDs and preserves each provider identity', () async {
    const a = TransitSourceId('a'), b = TransitSourceId('b');
    TransitRegionServices service(
      TransitRegion region,
      TransitProviderId provider,
      TransitSourceId source,
      bool first,
    ) => TransitRegionServices(
      region: region,
      provider: provider,
      stops: _Stops(),
      timetableSources: [source],
      timetableLoader: (_) async => _feed(first),
      attribution: TransitProviderAttribution(
        provider: provider,
        name: 'Test',
        licenseName: 'Test',
        url: 'https://example.com',
      ),
    );
    final qld = service(
      TransitRegion.queensland,
      TransitProviderId.translink,
      a,
      true,
    );
    final vic = service(
      TransitRegion.victoria,
      TransitProviderId.ptv,
      b,
      false,
    );
    final planner = GtfsNetworkPlanner(
      servicesFor: (region) => region == TransitRegion.queensland ? qld : vic,
    );
    final request = JourneyPlanRequest(
      origin: const TransitStopRef(
        region: TransitRegion.queensland,
        provider: TransitProviderId.translink,
        sourceId: a,
        stopId: 'A',
      ),
      destination: const TransitStopRef(
        region: TransitRegion.victoria,
        provider: TransitProviderId.ptv,
        sourceId: b,
        stopId: 'B',
      ),
      when: DateTime.utc(2026, 8, 12, 23, 59),
      walkingLimit: const Duration(minutes: 5),
    );
    final plan = await planner.planJourney(request);
    final legs = plan.journeys.single.legs;
    expect(legs, hasLength(3));
    expect(legs.first.origin.ref, request.origin);
    expect(legs.last.destination.ref, request.destination);
    expect(legs.first.route!.ref.sourceId, a);
    expect(legs.last.route!.ref.sourceId, b);
    expect(legs[1].isWalking, isTrue);
    expect(legs[1].isApproximate, isTrue);
    expect(legs.last.arrivalTime, DateTime.utc(2026, 8, 13, 0, 25));
  });
}
