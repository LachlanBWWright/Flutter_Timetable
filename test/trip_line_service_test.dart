import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart';
import 'package:lbww_flutter/gtfs/stop.dart';
import 'package:lbww_flutter/gtfs/stop_time.dart';
import 'package:lbww_flutter/gtfs/trip.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';

void main() {
  group('TripLineService', () {
    late TripLineService service;

    setUp(() {
      service = TripLineService(
        gtfsLoader: (endpoint) async {
          if (endpoint == StopsEndpoint.nswtrains) {
            return _sampleTrainGtfsData();
          }
          return null;
        },
        stopLookup: (stopId) async {
          final stop = _lookupStops[stopId];
          return stop == null ? const [] : [stop];
        },
      );
    });

    test('findSharedLines uses parent station membership', () async {
      final shared = await service.findSharedLines(
        'STA',
        'STC',
        mode: TransportMode.train,
      );

      expect(shared.map((line) => line.lineId), ['nswtrains|R1']);
      expect(shared.single.lineName, 'T1');
    });

    test('getLinesForStop returns multiple line memberships', () async {
      final lines = await service.getLinesForStop(
        'STA',
        mode: TransportMode.train,
      );

      expect(lines.map((line) => line.lineId), [
        'nswtrains|R1',
        'nswtrains|R2',
      ]);
    });

    test('getStopsForLine returns station-level ordered stops', () async {
      final stops = await service.getStopsForLine(
        'nswtrains|R1',
        TransportMode.train,
      );

      expect(stops.map((stop) => stop.stopId), ['STA', 'STB', 'STC']);
      expect(stops.map((stop) => stop.stopName), [
        'Central',
        'Town Hall',
        'Redfern',
      ]);
    });

    test('rankStopsForLine prioritises same-line stops within 5 km', () async {
      final ranked = await service.rankStopsForLine(
        lineId: 'nswtrains|R1',
        mode: TransportMode.train,
        anchorStopIds: const ['STA'],
      );

      expect(ranked.map((stop) => stop.stopId), ['STA', 'STB', 'STC']);
      expect(ranked[0].isWithinAnchorRadius, isTrue);
      expect(ranked[1].isWithinAnchorRadius, isTrue);
      expect(ranked[2].isWithinAnchorRadius, isFalse);
      expect(ranked[1].distanceKm, lessThan(5));
      expect(ranked[2].distanceKm, greaterThan(5));
    });
  });
}

final Map<String, TripLineLookupStop> _lookupStops = {
  'STA': const TripLineLookupStop(
    stopId: 'STA',
    stopName: 'Central',
    endpointKey: 'nswtrains',
    latitude: -33.8830,
    longitude: 151.2060,
  ),
  'STB': const TripLineLookupStop(
    stopId: 'STB',
    stopName: 'Town Hall',
    endpointKey: 'nswtrains',
    latitude: -33.8737,
    longitude: 151.2069,
  ),
  'STC': const TripLineLookupStop(
    stopId: 'STC',
    stopName: 'Redfern',
    endpointKey: 'nswtrains',
    latitude: -33.9630,
    longitude: 151.2060,
  ),
};

GtfsData _sampleTrainGtfsData() {
  return GtfsData(
    agencies: const [],
    calendars: const [],
    calendarDates: const [],
    routes: [
      Route(
        routeId: 'R1',
        routeShortName: 'T1',
        routeLongName: 'North Shore Line',
        routeType: '2',
      ),
      Route(
        routeId: 'R2',
        routeShortName: 'T2',
        routeLongName: 'Inner West Line',
        routeType: '2',
      ),
    ],
    stops: [
      Stop(
        stopId: 'STA',
        stopName: 'Central',
        stopLat: -33.8830,
        stopLon: 151.2060,
        locationType: 1,
        wheelchairBoarding: 1,
      ),
      Stop(
        stopId: 'STA-P1',
        stopName: 'Central Platform 1',
        stopLat: -33.8830,
        stopLon: 151.2060,
        locationType: 0,
        parentStation: 'STA',
        wheelchairBoarding: 1,
      ),
      Stop(
        stopId: 'STB',
        stopName: 'Town Hall',
        stopLat: -33.8737,
        stopLon: 151.2069,
        locationType: 1,
        wheelchairBoarding: 1,
      ),
      Stop(
        stopId: 'STB-P1',
        stopName: 'Town Hall Platform 1',
        stopLat: -33.8737,
        stopLon: 151.2069,
        locationType: 0,
        parentStation: 'STB',
        wheelchairBoarding: 1,
      ),
      Stop(
        stopId: 'STC',
        stopName: 'Redfern',
        stopLat: -33.9630,
        stopLon: 151.2060,
        locationType: 1,
        wheelchairBoarding: 1,
      ),
      Stop(
        stopId: 'STC-P1',
        stopName: 'Redfern Platform 1',
        stopLat: -33.9630,
        stopLon: 151.2060,
        locationType: 0,
        parentStation: 'STC',
        wheelchairBoarding: 1,
      ),
    ],
    stopTimes: [
      StopTime(
        tripId: 'TRIP1',
        arrivalTime: '08:00:00',
        departureTime: '08:00:00',
        stopId: 'STA-P1',
        stopSequence: '1',
      ),
      StopTime(
        tripId: 'TRIP1',
        arrivalTime: '08:05:00',
        departureTime: '08:05:00',
        stopId: 'STB-P1',
        stopSequence: '2',
      ),
      StopTime(
        tripId: 'TRIP1',
        arrivalTime: '08:12:00',
        departureTime: '08:12:00',
        stopId: 'STC-P1',
        stopSequence: '3',
      ),
      StopTime(
        tripId: 'TRIP2',
        arrivalTime: '09:00:00',
        departureTime: '09:00:00',
        stopId: 'STA-P1',
        stopSequence: '1',
      ),
      StopTime(
        tripId: 'TRIP2',
        arrivalTime: '09:06:00',
        departureTime: '09:06:00',
        stopId: 'STB-P1',
        stopSequence: '2',
      ),
    ],
    trips: [
      Trip(routeId: 'R1', serviceId: 'WD', tripId: 'TRIP1'),
      Trip(routeId: 'R2', serviceId: 'WD', tripId: 'TRIP2'),
    ],
    shapes: const [],
    notes: const [],
  );
}
