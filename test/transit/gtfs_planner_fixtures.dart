import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/nsw/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/transit.dart';

const plannerSource = TransitSourceId('qld:SEQ');

TransitStopRef plannerStop(String id) => TransitStopRef(
  region: TransitRegion.queensland,
  provider: TransitProviderId.translink,
  sourceId: plannerSource,
  stopId: id,
);

GtfsData plannerData({
  String timezone = 'Australia/Brisbane',
  String? serviceDate,
  String routeType = '3',
  String tripRows = 'R1,daily,T1,Gamma\n',
  String times =
      'T1,10:00:00,10:00:00,A,1,0,0\n'
      'T1,10:10:00,10:11:00,B,2,0,0\n'
      'T1,10:20:00,10:20:00,C,3,0,0\n',
}) => parseGtfsFiles({
  'agency.txt':
      'agency_id,agency_name,agency_url,agency_timezone\n'
      'test,Test,https://example.com,$timezone\n',
  if (serviceDate == null)
    'calendar.txt':
        'service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date\n'
        'daily,1,1,1,1,1,1,1,20260101,20261231\n'
  else
    'calendar_dates.txt':
        'service_id,date,exception_type\ndaily,$serviceDate,1\n',
  'routes.txt':
      'route_id,route_short_name,route_long_name,route_type\n'
      'R1,10,Test Line,$routeType\n',
  'stops.txt':
      'stop_id,stop_name,stop_lat,stop_lon\n'
      'A,Alpha,-27.4,153.0\nB,Beta,-27.5,153.1\nC,Gamma,-27.6,153.2\n',
  'trips.txt': 'route_id,service_id,trip_id,trip_headsign\n$tripRows',
  'stop_times.txt':
      'trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type,drop_off_type\n'
      '$times',
});

GtfsJourneyPlanner fixturePlanner(GtfsData data) => GtfsJourneyPlanner(
  region: TransitRegion.queensland,
  provider: TransitProviderId.translink,
  loadData: (_) async => data,
);

JourneyPlanRequest plannerRequest({
  DateTime? when,
  String origin = 'A',
  String destination = 'C',
  bool arrivalBased = false,
  List<TransportMode>? modes,
  Duration? walkingLimit,
  TransitAccessibility accessibility = TransitAccessibility.none,
}) => JourneyPlanRequest(
  origin: plannerStop(origin),
  destination: plannerStop(destination),
  when: when ?? DateTime.utc(2026, 8, 12, 23, 55),
  arrivalBased: arrivalBased,
  enabledModes: modes,
  walkingLimit: walkingLimit,
  accessibility: accessibility,
);
