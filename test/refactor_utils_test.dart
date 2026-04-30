import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
import 'package:lbww_flutter/utils/new_trip_screen_utils.dart';
import 'package:lbww_flutter/utils/realtime_map_widget_utils.dart';
import 'package:lbww_flutter/utils/realtime_trip_id_utils.dart';
import 'package:lbww_flutter/utils/station_subtitle_utils.dart';
import 'package:lbww_flutter/utils/stops_map_utils.dart';
import 'package:lbww_flutter/utils/trip_screen_utils.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

void main() {
  group('new_trip_screen_utils', () {
    test('transportModeFromTabIndex maps tabs predictably', () {
      expect(transportModeFromTabIndex(0), TransportMode.train);
      expect(transportModeFromTabIndex(2), TransportMode.metro);
      expect(transportModeFromTabIndex(4), TransportMode.ferry);
      expect(transportModeFromTabIndex(99), TransportMode.train);
    });

    test('canSaveDirectTrip requires distinct populated stops', () {
      final origin = Station(name: 'Origin', id: '1');
      final destination = Station(name: 'Destination', id: '2');
      final duplicate = Station(name: 'Duplicate', id: '1');

      expect(
        canSaveDirectTrip(origin: origin, destination: destination),
        isTrue,
      );
      expect(
        canSaveDirectTrip(origin: origin, destination: duplicate),
        isFalse,
      );
      expect(canSaveDirectTrip(origin: origin, destination: null), isFalse);
    });

    test('filterStationsByQuery trims and matches case-insensitively', () {
      final stations = [
        Station(name: 'Central', id: '1'),
        Station(name: 'Town Hall', id: '2'),
      ];

      final filtered = filterStationsByQuery(stations, '  town ');
      expect(filtered.map((station) => station.name), ['Town Hall']);
    });

    test('build status message reports manual builder state', () {
      final origin = Station(name: 'Central', id: '1');
      final destination = Station(name: 'Town Hall', id: '2');
      final line = const StopLineMatch(
        lineId: 'T1',
        lineName: 'T1 North Shore',
        mode: TransportMode.train,
        endpointKey: 'sydneytrains',
      );

      final message = buildNewTripStatusMessage(
        origin: origin,
        destination: destination,
        isResolvingSharedLines: false,
        manualBuilderEnabled: true,
        pendingInterchangeInsertIndex: null,
        orderedStops: [origin, destination],
        manualValidationMessage: null,
        selectedLine: line,
        canSaveDirect: true,
        sharedLines: [line],
        originMode: TransportMode.train,
        destinationMode: TransportMode.train,
      );

      expect(message, contains('T1 North Shore'));
    });
  });

  group('realtime_trip_id_utils', () {
    test('collectTripIdsFromRawJson gathers direct and nested ids', () {
      final ids = collectTripIdsFromRawJson({
        'tripId': 'trip-1',
        'trip_id': 'trip-2',
        'transportation': {
          'properties': {'RealtimeTripId': 'trip-3', 'AVMSTripID': 'trip-4'},
        },
      });

      expect(ids, {'trip-1', 'trip-2', 'trip-3', 'trip-4'});
    });

    test('collectTripIdsForVehicleFiltering merges trip and leg ids', () {
      final ids = collectTripIdsForVehicleFiltering(
        tripRawJson: {
          'legs': [
            {'tripId': 'trip-a'},
          ],
        },
        legRawJson: {
          'transportation': {
            'properties': {'realtimeTripId': 'trip-b'},
          },
        },
      );

      expect(ids, {'trip-a', 'trip-b'});
    });
  });

  group('station_subtitle_utils', () {
    test('formatStationDistanceLine formats display and debug variants', () {
      expect(
        formatStationDistanceLine(1.234, debugFormat: false),
        '1.2 km away',
      );
      expect(
        formatStationDistanceLine(1.234, debugFormat: true),
        'Distance: 1.23 km',
      );
    });

    test('buildStationDebugLines includes station metadata lines', () {
      final station = Station(
        name: 'Central',
        id: '200060',
        stopCode: 'CEN',
        platformCode: '1',
      );

      final lines = buildStationDebugLines(station);
      expect(lines, contains('ID: 200060'));
      expect(lines, contains('Code: CEN'));
      expect(lines, contains('Platform: 1'));
    });
  });

  group('trip_screen_utils', () {
    TripJourney buildTrip(String plannedDeparture) {
      return TripJourney(
        legs: [
          Leg(
            origin: Stop(
              id: 'origin',
              name: 'Origin',
              type: 'station',
              departureTimePlanned: plannedDeparture,
            ),
            destination: Stop(
              id: 'destination',
              name: 'Destination',
              type: 'station',
            ),
          ),
        ],
      );
    }

    test('sortTripJourneysForDisplay keeps upcoming first and past after', () {
      final journeys = [
        buildTrip('2026-04-30T08:00:00Z'),
        buildTrip('2026-04-30T14:00:00Z'),
        buildTrip('2026-04-30T10:30:00Z'),
      ];

      final sorted = sortTripJourneysForDisplay(
        journeys,
        now: DateTime.parse('2026-04-30T11:00:00Z'),
      );

      expect(
        sorted.map((journey) => journey.legs.first.origin.departureTimePlanned),
        [
          '2026-04-30T14:00:00Z',
          '2026-04-30T10:30:00Z',
          '2026-04-30T08:00:00Z',
        ],
      );
    });

    test('prettyPrintRawJson returns null for null input', () {
      expect(prettyPrintRawJson(null), isNull);
    });
  });

  group('stops_map_utils', () {
    test('bus zoom warning only appears below threshold', () {
      expect(
        shouldShowBusZoomWarning(mode: TransportMode.bus, currentZoom: 12.5),
        isTrue,
      );
      expect(
        shouldShowBusZoomWarning(mode: TransportMode.bus, currentZoom: 13.0),
        isFalse,
      );
      expect(
        shouldShowBusZoomWarning(mode: TransportMode.train, currentZoom: 10),
        isFalse,
      );
    });

    test('endpointsForTransportMode returns metro endpoint', () {
      final endpoints = endpointsForTransportMode(TransportMode.metro);
      expect(endpoints.single.name, contains('metro'));
    });
  });

  group('realtime_map_widget_utils', () {
    test('realtimeMapPageTitle prefers mode over leg', () {
      expect(
        realtimeMapPageTitle(mode: TransportMode.bus, leg: null),
        'TransportMode.bus Map',
      );
      expect(realtimeMapPageTitle(mode: null, leg: null), 'Realtime Map');
    });

    test('vehicleNotFoundMessage includes requested id', () {
      expect(vehicleNotFoundMessage('veh-7'), contains('veh-7'));
    });
  });
}
