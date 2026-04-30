import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/debug/builders/route_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/stop_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/trip_debug_page_builder.dart';
import 'package:lbww_flutter/debug/builders/vehicle_debug_page_builder.dart';
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
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

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
          parentStation: 'PARENT-1',
        ),
        gtfs_stop.Stop(
          stopId: 'STOP-2',
          stopName: 'Town Hall',
          stopLat: 0.1,
          stopLon: 0.1,
          locationType: 0,
          wheelchairBoarding: 1,
        ),
        gtfs_stop.Stop(
          stopId: 'STOP-3',
          stopName: 'Wynyard',
          stopLat: 0.2,
          stopLon: 0.2,
          locationType: 0,
          wheelchairBoarding: 1,
        ),
      ],
      stopTimes: [
        StopTime(
          tripId: 'TRIP-1',
          arrivalTime: '10:00:00',
          departureTime: '10:00:00',
          stopId: 'STOP-1',
          stopSequence: '1',
        ),
        StopTime(
          tripId: 'TRIP-1',
          arrivalTime: '10:05:00',
          departureTime: '10:05:00',
          stopId: 'STOP-2',
          stopSequence: '2',
        ),
        StopTime(
          tripId: 'TRIP-1',
          arrivalTime: '10:10:00',
          departureTime: '10:10:00',
          stopId: 'STOP-3',
          stopSequence: '3',
        ),
      ],
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

  api.Leg buildLeg() {
    return api.Leg(
      origin: api.Stop(
        id: 'STOP-1',
        name: 'Central',
        type: 'stop',
        coord: const [0.0, 0.0],
        parent: api.Parent(id: 'PARENT-1', name: 'Central Group'),
      ),
      destination: api.Stop(
        id: 'STOP-3',
        name: 'Wynyard',
        type: 'stop',
        coord: const [0.2, 0.2],
      ),
      transportation: api.Transportation(
        id: 'ROUTE-1',
        name: 'Route 1',
        number: 'R1',
        product: api.Product(classField: 5, name: 'Bus'),
        destination: api.TransportationDestination(
          id: 'STOP-3',
          name: 'Wynyard',
        ),
        operator: api.Operator(id: 'OP-1', name: 'Transit Co'),
        rawJson: const {'id': 'ROUTE-1', 'name': 'Route 1'},
      ),
      stopSequence: [
        api.Stop(id: 'STOP-1', name: 'Central', type: 'stop'),
        api.Stop(id: 'STOP-2', name: 'Town Hall', type: 'stop'),
        api.Stop(id: 'STOP-3', name: 'Wynyard', type: 'stop'),
      ],
      rawJson: const {
        'transportation': {
          'id': 'ROUTE-1',
          'properties': {'RealtimeTripId': 'TRIP-1'},
        },
      },
    );
  }

  api.TripJourney buildTrip(api.Leg leg) {
    return api.TripJourney(
      isAdditional: false,
      legs: [leg],
      rating: 9,
      rawJson: const {
        'legs': [
          {
            'transportation': {
              'id': 'ROUTE-1',
              'properties': {'RealtimeTripId': 'TRIP-1'},
            },
          },
        ],
      },
    );
  }

  db.Stop buildDbStop(String stopId) {
    return db.Stop(
      stopId: stopId,
      stopName: stopId == 'STOP-1' ? 'Central' : 'Derived Stop',
      stopCode: '2000',
      stopDesc: 'Sydney',
      stopLat: 0.0,
      stopLon: 0.0,
      parentStation: stopId == 'STOP-1' ? 'PARENT-1' : null,
      endpoint: 'buses',
    );
  }

  VehiclePosition buildVehicle() {
    final vehicle = VehiclePosition();
    vehicle.trip = TripDescriptor(tripId: 'TRIP-1', routeId: 'ROUTE-1');
    vehicle.vehicle = VehicleDescriptor(id: 'VEH-1', label: 'Bus 1');
    vehicle.position = Position(latitude: 0.0, longitude: 0.0, speed: 12);
    vehicle.timestamp = Int64(1700000000);
    vehicle.currentStopSequence = 2;
    vehicle.currentStatus = VehiclePosition_VehicleStopStatus.IN_TRANSIT_TO;
    return vehicle;
  }

  TripUpdate buildTripUpdate() {
    return TripUpdate(
      trip: TripDescriptor(tripId: 'TRIP-1', routeId: 'ROUTE-1'),
      stopTimeUpdate: [
        TripUpdate_StopTimeUpdate(stopSequence: 1, stopId: 'STOP-1'),
        TripUpdate_StopTimeUpdate(stopSequence: 2, stopId: 'STOP-2'),
        TripUpdate_StopTimeUpdate(stopSequence: 3, stopId: 'STOP-3'),
      ],
      timestamp: Int64(1700000000),
    );
  }

  DebugEntityResolver buildResolver({
    required GtfsData gtfsData,
    List<VehiclePosition> vehicles = const [],
    List<TripUpdate> tripUpdates = const [],
    List<db.Stop> Function(String stopId)? getDbStopsById,
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
      getDbStopsById: (stopId) async =>
          getDbStopsById?.call(stopId) ?? <db.Stop>[buildDbStop(stopId)],
    );
  }

  test('trip debug builder extracts trip ids and references', () async {
    final leg = buildLeg();
    final trip = buildTrip(leg);
    final resolver = buildResolver(
      gtfsData: buildGtfsData(),
      vehicles: [buildVehicle()],
      tripUpdates: [buildTripUpdate()],
    );
    final builder = TripDebugPageBuilder(resolver: resolver);

    final page = await builder.build(
      DebugEntityRequest(
        entityType: DebugEntityType.trip,
        entityId: 'TRIP-1',
        context: DebugEntityContext(tripJourney: trip, leg: leg),
      ),
    );

    expect(page.canonicalId, 'TRIP-1');
    final refs = page.sections
        .firstWhere((section) => section.title == 'References')
        .references;
    expect(refs.any((ref) => ref.entityType == DebugEntityType.stop), isTrue);
    expect(refs.any((ref) => ref.entityType == DebugEntityType.route), isTrue);
    expect(
      refs.any((ref) => ref.entityType == DebugEntityType.vehicle),
      isTrue,
    );
  });

  test('route debug builder resolves GTFS match and served stops', () async {
    final gtfsData = buildGtfsData();
    final leg = buildLeg();
    final resolver = buildResolver(
      gtfsData: gtfsData,
      vehicles: [buildVehicle()],
      tripUpdates: [buildTripUpdate()],
    );
    final builder = RouteDebugPageBuilder(resolver: resolver);

    final page = await builder.build(
      DebugEntityRequest(
        entityType: DebugEntityType.route,
        entityId: 'ROUTE-1',
        context: DebugEntityContext(
          leg: leg,
          transportation: leg.transportation,
        ),
      ),
    );

    final derived = page.sections.firstWhere(
      (section) => section.title == 'Derived data',
    );
    expect(
      derived.fields.any(
        (field) =>
            field.label == 'GTFS match reason' &&
            field.value != 'No GTFS match',
      ),
      isTrue,
    );
    final servedStops = page.sections.firstWhere(
      (section) => section.title == 'Served stops',
    );
    expect(servedStops.references.length, greaterThanOrEqualTo(3));
  });

  test('stop debug builder shows local DB and GTFS enrichment', () async {
    final gtfsData = buildGtfsData();
    final leg = buildLeg();
    final trip = buildTrip(leg);
    final resolver = buildResolver(
      gtfsData: gtfsData,
      tripUpdates: [buildTripUpdate()],
    );
    final builder = StopDebugPageBuilder(resolver: resolver);

    final page = await builder.build(
      DebugEntityRequest(
        entityType: DebugEntityType.stop,
        entityId: 'STOP-1',
        context: DebugEntityContext(
          apiStop: leg.origin,
          leg: leg,
          tripJourney: trip,
          gtfsData: gtfsData,
        ),
      ),
    );

    expect(page.sourceBadges, contains(DebugDataSource.localDb));
    expect(page.sourceBadges, contains(DebugDataSource.gtfs));
    final references = page.sections
        .firstWhere((section) => section.title == 'References')
        .references;
    expect(references.any((ref) => ref.title == 'Parent stop'), isTrue);
    expect(
      references.any((ref) => ref.entityType == DebugEntityType.route),
      isTrue,
    );
  });

  test('vehicle debug builder correlates route and next stop', () async {
    final gtfsData = buildGtfsData();
    final vehicle = buildVehicle();
    final tripUpdate = buildTripUpdate();
    final resolver = buildResolver(
      gtfsData: gtfsData,
      vehicles: [vehicle],
      tripUpdates: [tripUpdate],
    );
    final builder = VehicleDebugPageBuilder(resolver: resolver);

    final page = await builder.build(
      DebugEntityRequest(
        entityType: DebugEntityType.vehicle,
        entityId: 'VEH-1',
        context: DebugEntityContext(vehiclePosition: vehicle),
      ),
    );

    final references = page.sections
        .firstWhere((section) => section.title == 'References')
        .references;
    expect(
      references.any((ref) => ref.entityType == DebugEntityType.route),
      isTrue,
    );
    expect(
      references.any(
        (ref) => ref.title == 'Next stop' && ref.entityId == 'STOP-3',
      ),
      isTrue,
    );
  });
}
