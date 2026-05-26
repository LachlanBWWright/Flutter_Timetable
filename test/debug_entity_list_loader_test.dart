// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_list_loader.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_resolver.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';

void main() {
  db.Stop buildDbStop({
    required String stopId,
    required String stopName,
    required String endpoint,
    String? stopDesc,
    String? parentStation,
  }) {
    return db.Stop(
      stopId: stopId,
      stopName: stopName,
      stopCode: '2000',
      stopDesc: stopDesc,
      stopLat: 0.0,
      stopLon: 0.0,
      parentStation: parentStation,
      endpoint: endpoint,
    );
  }

  db.Route buildDbRoute({
    String endpoint = 'buses',
    String routeId = 'ROUTE-1',
    String lineId = 'buses|ROUTE-1',
  }) {
    return db.Route(
      endpoint: endpoint,
      routeId: routeId,
      lineId: lineId,
      routeShortName: 'R1',
      routeLongName: 'Route 1 Long Name',
      routeType: '3',
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
        preloadedDbStops: [
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
            parentStation: 'PARENT-1',
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
      expect(page.filterGroups.any((group) => group.key == 'coverage'), isTrue);
      final parentStatusGroup = page.filterGroups.singleWhere(
        (group) => group.key == 'parent_status',
      );
      expect(
        parentStatusGroup.options.map((option) => option.label),
        containsAll(['Has Parent', 'No Parent']),
      );
      expect(central.filterValues['coverage'], ['multi_endpoint']);
      expect(central.filterValues['parent_status'], ['no_parent']);
      expect(central.filterValues['locality'], ['Sydney']);
      expect(central.request.context.dbStops?.length, 2);

      final townHall = page.items.firstWhere(
        (item) => item.entityId == 'STOP-2',
      );
      expect(townHall.filterValues['parent_status'], ['has_parent']);
      expect(townHall.filterValues['parent'], ['PARENT-1']);
    },
  );

  test(
    'route list loader merges GTFS catalog entries with active realtime data',
    () async {
      final loader = DebugEntityListLoader(
        resolver: buildResolver(
          vehicles: [buildVehicle()],
          tripUpdates: [buildTripUpdate()],
        ),
        preloadedDbRoutes: [buildDbRoute()],
      );

      final page = await loader.load(DebugEntityType.route);

      final route = page.items.singleWhere(
        (item) => item.entityId == 'ROUTE-1',
      );
      expect(route.title, 'Route 1 Long Name');
      expect(route.sources, contains(DebugDataSource.localDb));
      expect(route.sources, contains(DebugDataSource.realtime));
      expect(route.filterValues['endpoint'], contains(StopsEndpoint.buses.key));
      expect(route.filterValues['mode'], contains(TransportMode.bus.name));
      expect(route.filterValues['activity'], ['active_trips_and_vehicles']);
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
      expect(trip.filterValues['service_date'], ['20260429']);
      expect(trip.filterValues['vehicle'], ['matched_vehicle']);
      expect(trip.filterValues['stop'], ['STOP-1']);

      final vehicleItem = vehiclePage.items.single;
      expect(vehicleItem.entityId, 'VEH-1');
      expect(vehicleItem.request.context.vehiclePosition, same(vehicle));
      expect(vehicleItem.filterValues['route'], ['ROUTE-1']);
      expect(vehicleItem.filterValues['trip'], ['TRIP-1']);
      expect(vehicleItem.filterValues['status'], ['IN_TRANSIT_TO']);
    },
  );
}
