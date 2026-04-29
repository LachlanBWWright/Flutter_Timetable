import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_list_loader.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/note.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/gtfs/shape.dart';
import 'package:lbww_flutter/gtfs/stop.dart' as gtfs_stop;
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart' as gtfs_trip;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';

void main() {
  GtfsData buildGtfsData() {
    return GtfsData(
      agencies: [
        gtfs_agency.Agency(
          agencyId: 'A1',
          agencyName: 'Agency Name',
          agencyUrl: 'https://agency.example',
          agencyTimezone: 'Australia/Sydney',
        ),
      ],
      calendars: const [],
      calendarDates: const [],
      routes: [
        gtfs_route.Route(
          routeId: 'ROUTE-1',
          agencyId: 'A1',
          routeShortName: 'R1',
          routeLongName: 'Route 1 Long Name',
          routeType: '3',
        ),
      ],
      stops: [
        gtfs_stop.Stop(
          stopId: 'STOP-1',
          stopName: 'Central',
          stopLat: 0.0,
          stopLon: 0.0,
          locationType: 0,
          wheelchairBoarding: 1,
        ),
      ],
      stopTimes: const <StopTime>[],
      trips: [
        gtfs_trip.Trip(
          routeId: 'ROUTE-1',
          serviceId: 'SERVICE-1',
          tripId: 'TRIP-1',
        ),
      ],
      shapes: const <Shape>[],
      notes: const <Note>[],
    );
  }

  db.Stop buildDbStop({
    required String stopId,
    required String stopName,
    required String endpoint,
    String? stopDesc,
  }) {
    return db.Stop(
      stopId: stopId,
      stopName: stopName,
      stopCode: '2000',
      stopDesc: stopDesc,
      stopLat: 0.0,
      stopLon: 0.0,
      parentStation: null,
      endpoint: endpoint,
    );
  }

  VehiclePosition buildVehicle({
    String vehicleId = 'VEH-1',
    String tripId = 'TRIP-1',
    String routeId = 'ROUTE-1',
    int timestamp = 1700000000,
  }) {
    final vehicle = VehiclePosition();
    vehicle.trip = TripDescriptor(tripId: tripId, routeId: routeId);
    vehicle.vehicle = VehicleDescriptor(id: vehicleId, label: vehicleId);
    vehicle.position = Position(latitude: 0.0, longitude: 0.0, speed: 12);
    vehicle.timestamp = Int64(timestamp);
    vehicle.currentStatus = VehiclePosition_VehicleStopStatus.IN_TRANSIT_TO;
    return vehicle;
  }

  TripUpdate buildTripUpdate({
    String tripId = 'TRIP-1',
    String routeId = 'ROUTE-1',
    int timestamp = 1700000000,
  }) {
    return TripUpdate(
      trip: TripDescriptor(
        tripId: tripId,
        routeId: routeId,
        startDate: '20260429',
      ),
      stopTimeUpdate: [
        TripUpdate_StopTimeUpdate(stopSequence: 1, stopId: 'STOP-1'),
      ],
      timestamp: Int64(timestamp),
    );
  }

  DebugEntityResolver buildResolver({
    GtfsData? gtfsData,
    List<VehiclePosition> vehicles = const [],
    List<TripUpdate> tripUpdates = const [],
  }) {
    return DebugEntityResolver(
      getGtfsDataForEndpoint: (_) async => gtfsData,
      getAllVehiclesAggregated: () async => VehiclePositionAggregationResult(
        vehicles: vehicles,
        breakdown: {'test': vehicles.length},
      ),
      getAllTripUpdatesAggregated: () async => TripUpdateAggregationResult(
        tripUpdates: tripUpdates,
        breakdown: {'test': tripUpdates.length},
      ),
      getDbStopsById: (_) async => <db.Stop>[],
    );
  }

  test(
    'stop list loader groups stop rows and exposes mode and endpoint filters',
    () async {
      final loader = DebugEntityListLoader(
        resolver: buildResolver(),
        getAllDbStops: () async => [
          buildDbStop(
            stopId: 'STOP-1',
            stopName: 'Central',
            endpoint: StopsEndpoint.buses.key,
            stopDesc: 'Sydney',
          ),
          buildDbStop(
            stopId: 'STOP-1',
            stopName: 'Central',
            endpoint: StopsEndpoint.metro.key,
            stopDesc: 'Sydney',
          ),
          buildDbStop(
            stopId: 'STOP-2',
            stopName: 'Town Hall',
            endpoint: StopsEndpoint.buses.key,
            stopDesc: 'Sydney',
          ),
        ],
      );

      final page = await loader.load(DebugEntityType.stop);

      expect(page.items.length, 2);
      final central = page.items.firstWhere(
        (item) => item.entityId == 'STOP-1',
      );
      expect(
        central.filterValues['endpoint'],
        contains(StopsEndpoint.buses.key),
      );
      expect(
        central.filterValues['endpoint'],
        contains(StopsEndpoint.metro.key),
      );
      expect(central.filterValues['mode'], contains(TransportMode.bus.name));
      expect(central.filterValues['mode'], contains(TransportMode.metro.name));
      expect(page.filterGroups.any((group) => group.key == 'endpoint'), isTrue);
      expect(central.request.context.dbStops?.length, 2);
    },
  );

  test(
    'route list loader merges GTFS catalog entries with active realtime data',
    () async {
      final loader = DebugEntityListLoader(
        resolver: buildResolver(
          gtfsData: buildGtfsData(),
          vehicles: [buildVehicle()],
          tripUpdates: [buildTripUpdate()],
        ),
        getStopsCountByEndpoint: () async => {
          TransportMode.bus: {StopsEndpoint.buses.key: 10},
        },
      );

      final page = await loader.load(DebugEntityType.route);

      final route = page.items.singleWhere(
        (item) => item.entityId == 'ROUTE-1',
      );
      expect(route.title, 'Route 1 Long Name');
      expect(route.sources, contains(DebugDataSource.gtfs));
      expect(route.sources, contains(DebugDataSource.realtime));
      expect(route.filterValues['endpoint'], contains(StopsEndpoint.buses.key));
      expect(route.filterValues['mode'], contains(TransportMode.bus.name));
      expect(route.request.context.gtfsEndpoint, StopsEndpoint.buses);
    },
  );

  test(
    'trip and vehicle list loaders expose active realtime entities with context',
    () async {
      final vehicle = buildVehicle();
      final update = buildTripUpdate();
      final loader = DebugEntityListLoader(
        resolver: buildResolver(vehicles: [vehicle], tripUpdates: [update]),
      );

      final tripPage = await loader.load(DebugEntityType.trip);
      final vehiclePage = await loader.load(DebugEntityType.vehicle);

      final trip = tripPage.items.single;
      expect(trip.entityId, 'TRIP-1');
      expect(trip.request.context.tripUpdate, same(update));
      expect(trip.request.context.vehiclePosition, same(vehicle));

      final vehicleItem = vehiclePage.items.single;
      expect(vehicleItem.entityId, 'VEH-1');
      expect(vehicleItem.request.context.vehiclePosition, same(vehicle));
      expect(vehicleItem.filterValues['route'], ['ROUTE-1']);
    },
  );
}
