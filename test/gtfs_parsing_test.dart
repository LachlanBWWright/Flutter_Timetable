import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/gtfs/agency.dart';
import 'package:lbww_flutter/gtfs/route.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart';

void main() {
  group('GTFS Standard Parsing Tests', () {
    late String agencyCsv;
    late String stopsCsv;
    late String routesCsv;
    late String tripsCsv;
    late String stopTimesCsv;

    setUpAll(() async {
      // Load sample GTFS files
      agencyCsv = await File('test/fixtures/sample_agency.txt').readAsString();
      stopsCsv = await File('test/fixtures/sample_stops.txt').readAsString();
      routesCsv = await File('test/fixtures/sample_routes.txt').readAsString();
      tripsCsv = await File('test/fixtures/sample_trips.txt').readAsString();
      stopTimesCsv = await File(
        'test/fixtures/sample_stop_times.txt',
      ).readAsString();
    });

    group('Agency Parsing', () {
      test('parseAgencyCsv returns correct number of agencies', () {
        final agencies = parseAgencyCsv(agencyCsv);
        expect(agencies.length, equals(1));
      });

      test('parseAgencyCsv correctly parses all fields', () {
        final agencies = parseAgencyCsv(agencyCsv);
        final agency = agencies[0];

        expect(agency.agencyId, equals('DTA'));
        expect(agency.agencyName, equals('Demo Transit Authority'));
        expect(agency.agencyUrl, equals('http://google.com'));
        expect(agency.agencyTimezone, equals('America/Los_Angeles'));
        expect(agency.agencyLang, equals('en'));
        expect(agency.agencyPhone, equals('555-1234'));
        expect(agency.agencyFareUrl, equals('http://google.com/fares'));
        expect(agency.agencyEmail, equals('support@example.com'));
      });

      test('Agency validates required fields', () {
        expect(
          Agency.validateCsvHeader([
            'agency_name',
            'agency_url',
            'agency_timezone',
          ]),
          isTrue,
        );
        expect(Agency.validateCsvHeader(['agency_name']), isFalse);
      });
    });

    group('Stops Parsing', () {
      test('parseStopsCsv returns correct number of stops', () {
        final stops = parseStopsCsv(stopsCsv);
        expect(stops.length, equals(3));
      });

      test('parseStopsCsv correctly parses all standard fields', () {
        final stops = parseStopsCsv(stopsCsv);
        final stop = stops[0];

        expect(stop.stopId, equals('S1'));
        expect(stop.stopCode, equals('1234'));
        expect(stop.stopName, equals('First Street Station'));
        expect(stop.ttsStopName, equals('First Street'));
        expect(stop.stopDesc, equals('A major transit hub'));
        expect(stop.stopLat, equals(37.7897));
        expect(stop.stopLon, equals(-122.4009));
        expect(stop.zoneId, equals('1'));
        expect(stop.stopUrl, equals('http://example.com/stops/s1'));
        expect(stop.locationType, equals(0));
        expect(stop.parentStation, isNull);
        expect(stop.stopTimezone, equals('America/Los_Angeles'));
        expect(stop.wheelchairBoarding, equals(1));
        expect(stop.levelId, isNull);
        expect(stop.platformCode, equals('A'));
      });

      test('parseStopsCsv handles optional fields correctly', () {
        final stops = parseStopsCsv(stopsCsv);
        final stop = stops[1]; // Second stop has fewer fields

        expect(stop.stopId, equals('S2'));
        expect(stop.stopCode, equals('5678'));
        expect(stop.stopName, equals('Second Avenue Stop'));
        expect(stop.stopDesc, equals('Near downtown'));
        expect(stop.parentStation, isNull);
        expect(stop.stopTimezone, isNull);
        expect(stop.platformCode, isNull);
      });

      test('parseStopsCsv handles station location_type', () {
        final stops = parseStopsCsv(stopsCsv);
        final station = stops[2];

        expect(station.stopId, equals('STATION1'));
        expect(station.locationType, equals(1)); // Station
        expect(station.stopName, equals('Main Station'));
        expect(station.stopDesc, equals('Central transit station'));
      });

      test('Stop validates required fields', () {
        expect(
          Stop.validateCsvHeader(['stop_id', 'stop_name', 'stop_lat']),
          isTrue,
        );
        expect(Stop.validateCsvHeader(['stop_name']), isFalse);
      });
    });

    group('Routes Parsing', () {
      test('parseRoutesCsv returns correct number of routes', () {
        final routes = parseRoutesCsv(routesCsv);
        expect(routes.length, equals(2));
      });

      test('parseRoutesCsv correctly parses all fields', () {
        final routes = parseRoutesCsv(routesCsv);
        final route = routes[0];

        expect(route.routeId, equals('R1'));
        expect(route.agencyId, equals('DTA'));
        expect(route.routeShortName, equals('10'));
        expect(route.routeLongName, equals('Downtown Express'));
        expect(route.routeDesc, equals('Fast service to downtown'));
        expect(route.routeType, equals('3')); // Bus
        expect(route.routeUrl, equals('http://example.com/routes/r1'));
        expect(route.routeColor, equals('FF0000'));
        expect(route.routeTextColor, equals('FFFFFF'));
        expect(route.routeSortOrder, equals('1'));
      });

      test('parseRoutesCsv handles optional fields correctly', () {
        final routes = parseRoutesCsv(routesCsv);
        final route = routes[1];

        expect(route.routeId, equals('R2'));
        expect(route.routeUrl, isNull);
        expect(route.routeSortOrder, equals('2'));
      });

      test('Route validates required fields', () {
        expect(
          Route.validateCsvHeader([
            'route_id',
            'route_short_name',
            'route_long_name',
            'route_type',
          ]),
          isTrue,
        );
        expect(Route.validateCsvHeader(['route_id']), isFalse);
      });
    });

    group('Trips Parsing', () {
      test('parseTripsCsv returns correct number of trips', () {
        final trips = parseTripsCsv(tripsCsv);
        expect(trips.length, equals(3));
      });

      test('parseTripsCsv correctly parses all standard fields', () {
        final trips = parseTripsCsv(tripsCsv);
        final trip = trips[0];

        expect(trip.routeId, equals('R1'));
        expect(trip.serviceId, equals('WD'));
        expect(trip.tripId, equals('TRIP1'));
        expect(trip.tripHeadsign, equals('Downtown'));
        expect(trip.tripShortName, equals('T1'));
        expect(trip.directionId, equals('0'));
        expect(trip.blockId, equals('B1'));
        expect(trip.shapeId, equals('SHAPE1'));
        expect(trip.wheelchairAccessible, equals('1'));
        expect(trip.bikesAllowed, equals('1'));
      });

      test('parseTripsCsv handles optional fields correctly', () {
        final trips = parseTripsCsv(tripsCsv);
        final trip = trips[1];

        expect(trip.tripId, equals('TRIP2'));
        expect(trip.tripShortName, isNull);
        expect(trip.blockId, isNull);
        expect(trip.wheelchairAccessible, equals('0'));
      });

      test('parseTripsCsv handles trips without shape_id', () {
        final trips = parseTripsCsv(tripsCsv);
        final trip = trips[2];

        expect(trip.tripId, equals('TRIP3'));
        expect(trip.shapeId, isNull);
      });

      test('Trip validates required fields', () {
        expect(
          Trip.validateCsvHeader(['route_id', 'service_id', 'trip_id']),
          isTrue,
        );
        expect(Trip.validateCsvHeader(['route_id', 'trip_id']), isFalse);
      });
    });

    group('StopTimes Parsing', () {
      test('parseStopTimesCsv returns correct number of stop times', () {
        final stopTimes = parseStopTimesCsv(stopTimesCsv);
        expect(stopTimes.length, equals(4));
      });

      test('parseStopTimesCsv correctly parses all standard fields', () {
        final stopTimes = parseStopTimesCsv(stopTimesCsv);
        final stopTime = stopTimes[0];

        expect(stopTime.tripId, equals('TRIP1'));
        expect(stopTime.arrivalTime, equals('08:00:00'));
        expect(stopTime.departureTime, equals('08:00:00'));
        expect(stopTime.stopId, equals('S1'));
        expect(stopTime.stopSequence, equals('1'));
        expect(stopTime.stopHeadsign, isNull);
        expect(stopTime.pickupType, equals('0'));
        expect(stopTime.dropOffType, equals('0'));
        expect(stopTime.continuousPickup, equals('1'));
        expect(stopTime.continuousDropOff, equals('1'));
        expect(stopTime.shapeDistTraveled, equals('0.0'));
        expect(stopTime.timepoint, equals('1'));
      });

      test('parseStopTimesCsv handles stop_headsign correctly', () {
        final stopTimes = parseStopTimesCsv(stopTimesCsv);
        final stopTime = stopTimes[1];

        expect(stopTime.stopHeadsign, equals('Final Stop'));
      });

      test(
        'parseStopTimesCsv handles trips without continuous pickup/dropoff',
        () {
          final stopTimes = parseStopTimesCsv(stopTimesCsv);
          final stopTime = stopTimes[2];

          expect(stopTime.tripId, equals('TRIP2'));
          expect(stopTime.continuousPickup, equals('0'));
          expect(stopTime.continuousDropOff, equals('0'));
        },
      );

      test('StopTime validates required fields', () {
        expect(
          StopTime.validateCsvHeader([
            'trip_id',
            'arrival_time',
            'departure_time',
            'stop_id',
            'stop_sequence',
          ]),
          isTrue,
        );
        expect(
          StopTime.validateCsvHeader(['trip_id', 'arrival_time']),
          isFalse,
        );
      });
    });

    group('Header-based Parsing Flexibility', () {
      test('Stops can be parsed with fields in different order', () {
        const csv =
            '''stop_name,stop_id,stop_lon,stop_lat,location_type,wheelchair_boarding,parent_station
Test Stop,TEST1,-122.4,37.8,0,1,''';
        final stops = parseStopsCsv(csv);

        expect(stops.length, equals(1));
        expect(stops[0].stopId, equals('TEST1'));
        expect(stops[0].stopName, equals('Test Stop'));
        expect(stops[0].stopLat, equals(37.8));
        expect(stops[0].stopLon, equals(-122.4));
      });

      test('Routes can be parsed with minimal required fields', () {
        const csv = '''route_id,route_short_name,route_long_name,route_type
R1,1,Main Route,3''';
        final routes = parseRoutesCsv(csv);

        expect(routes.length, equals(1));
        expect(routes[0].routeId, equals('R1'));
        expect(routes[0].agencyId, isNull);
        expect(routes[0].routeUrl, isNull);
      });

      test('Trips can be parsed without optional shape_id', () {
        const csv = '''route_id,service_id,trip_id,trip_headsign
R1,WD,T1,Downtown''';
        final trips = parseTripsCsv(csv);

        expect(trips.length, equals(1));
        expect(trips[0].tripId, equals('T1'));
        expect(trips[0].shapeId, isNull);
      });

      test('GTFS files can be parsed with UTF-8 BOM headers', () {
        final data = parseGtfsFiles({
          'routes.txt':
              '\uFEFFroute_id,agency_id,route_short_name,route_long_name,route_type\n'
              'SMNW_M1,SMNW,M1,Metro North West & Bankstown Line,401\n',
          'trips.txt':
              '\uFEFFroute_id,service_id,trip_id,trip_headsign,direction_id\n'
              'SMNW_M1,weekday,trip-1,Sydenham,1\n',
          'stops.txt':
              '\uFEFFstop_id,stop_name,stop_lat,stop_lon,location_type,wheelchair_boarding\n'
              '2155269,Tallawong,-33.6908,150.9067,0,1\n',
          'stop_times.txt':
              '\uFEFFtrip_id,arrival_time,departure_time,stop_id,stop_sequence\n'
              'trip-1,04:08:00,04:08:00,2155269,1\n',
        });

        expect(data.routes.single.routeId, equals('SMNW_M1'));
        expect(data.trips.single.tripId, equals('trip-1'));
        expect(data.stops.single.stopId, equals('2155269'));
        expect(data.stopTimes.single.tripId, equals('trip-1'));
      });
    });

    group('Edge Cases', () {
      test('Stops with missing optional fields parse correctly', () {
        const csv =
            '''stop_id,stop_name,stop_lat,stop_lon,location_type,wheelchair_boarding
S1,Test Stop,37.8,-122.4,0,1''';
        final stops = parseStopsCsv(csv);

        expect(stops.length, equals(1));
        expect(stops[0].stopId, equals('S1'));
        expect(stops[0].stopName, equals('Test Stop'));
        expect(stops[0].stopCode, isNull);
        expect(stops[0].stopDesc, isNull);
        expect(stops[0].platformCode, isNull);
      });

      test('Routes with empty optional fields parse correctly', () {
        const csv =
            '''route_id,agency_id,route_short_name,route_long_name,route_desc,route_type
R1,,10,Main Line,,3''';
        final routes = parseRoutesCsv(csv);

        expect(routes.length, equals(1));
        expect(routes[0].routeId, equals('R1'));
        expect(routes[0].agencyId, isNull);
        expect(routes[0].routeDesc, isNull);
        expect(routes[0].routeType, equals('3'));
      });
    });
  });
}
