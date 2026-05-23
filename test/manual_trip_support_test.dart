import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';
import 'package:option_result/option_result.dart';

void main() {
  group('ManualTripDefinition', () {
    test('reversed keeps the leg modes and reverses stop order', () {
      const definition = ManualTripDefinition(
        legs: [
          ManualTripLeg(
            index: 0,
            originName: 'Central',
            originId: 'central',
            destinationName: 'Redfern',
            destinationId: 'redfern',
            mode: TransportMode.train,
            lineId: 'sydneytrains|T1',
            lineName: 'T1 North Shore Line',
          ),
          ManualTripLeg(
            index: 1,
            originName: 'Redfern',
            originId: 'redfern',
            destinationName: 'Strathfield',
            destinationId: 'strathfield',
            mode: TransportMode.train,
            lineId: 'sydneytrains|T1',
            lineName: 'T1 North Shore Line',
          ),
        ],
      );

      final reversed = definition.reversed();

      expect(reversed.isValid, isTrue);
      expect(reversed.orderedStops.map((stop) => stop.id), [
        'strathfield',
        'redfern',
        'central',
      ]);
      expect(reversed.legs.first.originId, 'strathfield');
      expect(reversed.legs.first.destinationId, 'redfern');
      expect(reversed.legs.last.originId, 'redfern');
      expect(reversed.legs.last.destinationId, 'central');
    });

    test('journey reverse preview swaps endpoints and reversed legs json', () {
      const definition = ManualTripDefinition(
        legs: [
          ManualTripLeg(
            index: 0,
            originName: 'Central',
            originId: 'central',
            destinationName: 'Redfern',
            destinationId: 'redfern',
            mode: TransportMode.train,
            lineId: 'sydneytrains|T1',
            lineName: 'T1 North Shore Line',
          ),
          ManualTripLeg(
            index: 1,
            originName: 'Redfern',
            originId: 'redfern',
            destinationName: 'Strathfield',
            destinationId: 'strathfield',
            mode: TransportMode.train,
            lineId: 'sydneytrains|T1',
            lineName: 'T1 North Shore Line',
          ),
        ],
      );
      final journey = Journey(
        id: 7,
        origin: 'Central',
        originId: 'central',
        destination: 'Strathfield',
        destinationId: 'strathfield',
        tripType: SavedTripType.manualMultiLeg.storageValue,
        mode: TransportMode.train.id,
        lineId: definition.legs.first.lineId,
        lineName: definition.legs.first.lineName,
        legsJson: definition.toLegsJson(),
        isPinned: true,
      );

      final reversedJourney = journey.reversedPreviewJourney();
      final reversedDefinition = reversedJourney.manualTripDefinition;

      expect(reversedJourney.origin, 'Strathfield');
      expect(reversedJourney.destination, 'Central');
      expect(reversedJourney.isPinned, isTrue);
      expect(reversedDefinition, isNotNull);
      expect(reversedDefinition?.orderedStops.map((stop) => stop.id), [
        'strathfield',
        'redfern',
        'central',
      ]);
    });

    test('a manual trip with train and bus legs is valid', () {
      const definition = ManualTripDefinition(
        legs: [
          ManualTripLeg(
            index: 0,
            originName: 'Central',
            originId: 'central',
            destinationName: 'Redfern',
            destinationId: 'redfern',
            mode: TransportMode.train,
            lineId: 'sydneytrains|T1',
            lineName: 'T1 North Shore Line',
          ),
          ManualTripLeg(
            index: 1,
            originName: 'Redfern',
            originId: 'redfern',
            destinationName: 'Marrickville',
            destinationId: 'marrickville',
            mode: TransportMode.bus,
            lineId: 'busco|392',
            lineName: 'Route 392',
          ),
        ],
      );

      expect(definition.isValid, isTrue);
      expect(definition.legs[0].mode, TransportMode.train);
      expect(definition.legs[1].mode, TransportMode.bus);
    });

    test('manual trip with unresolved leg metadata is valid', () {
      const definition = ManualTripDefinition(
        legs: [
          ManualTripLeg(
            index: 0,
            originName: 'Central',
            originId: 'central',
            destinationName: 'Redfern',
            destinationId: 'redfern',
            mode: TransportMode.train,
            lineId: null,
            lineName: null,
          ),
          ManualTripLeg(
            index: 1,
            originName: 'Redfern',
            originId: 'redfern',
            destinationName: 'Marrickville',
            destinationId: 'marrickville',
            mode: TransportMode.bus,
            lineId: null,
            lineName: null,
          ),
        ],
      );

      expect(definition.isValid, isTrue);
      expect(definition.legs[0].lineId, isNull);
      expect(definition.legs[1].lineId, isNull);
    });

    test('multi-mode trip reversal preserves per-leg mode metadata', () {
      const definition = ManualTripDefinition(
        legs: [
          ManualTripLeg(
            index: 0,
            originName: 'Central',
            originId: 'central',
            destinationName: 'Redfern',
            destinationId: 'redfern',
            mode: TransportMode.train,
            lineId: 'sydneytrains|T1',
            lineName: 'T1 North Shore Line',
          ),
          ManualTripLeg(
            index: 1,
            originName: 'Redfern',
            originId: 'redfern',
            destinationName: 'Marrickville',
            destinationId: 'marrickville',
            mode: TransportMode.bus,
            lineId: 'busco|392',
            lineName: 'Route 392',
          ),
        ],
      );

      final reversed = definition.reversed();

      expect(reversed.isValid, isTrue);
      expect(reversed.legs[0].mode, TransportMode.bus);
      expect(reversed.legs[0].originId, 'marrickville');
      expect(reversed.legs[0].destinationId, 'redfern');
      expect(reversed.legs[0].lineId, 'busco|392');
      expect(reversed.legs[1].mode, TransportMode.train);
      expect(reversed.legs[1].originId, 'redfern');
      expect(reversed.legs[1].destinationId, 'central');
      expect(reversed.legs[1].lineId, 'sydneytrains|T1');
    });

    test('tryDecodeFromLegsJson returns failure for malformed JSON shape', () {
      final result = ManualTripDefinition.tryDecodeFromLegsJson(
        legsJson: '{"legs":[]}',
      );

      expect(result, isA<Err<ManualTripDefinition, ManualTripDecodeFailure>>());
    });

    test('manualTripDefinition ignores malformed persisted legs json', () {
      final journey = Journey(
        id: 99,
        origin: 'Central',
        originId: 'central',
        destination: 'Town Hall',
        destinationId: 'townhall',
        tripType: SavedTripType.manualMultiLeg.storageValue,
        mode: TransportMode.train.id,
        lineId: null,
        lineName: null,
        legsJson: '{"invalid":true}',
        isPinned: false,
      );

      expect(journey.manualTripDefinition, isNull);
    });
  });

  group('NewTripService manual helpers', () {
    const selectedLine = StopLineMatch(
      mode: TransportMode.train,
      lineId: 'sydneytrains|T1',
      lineName: 'T1 North Shore Line',
      endpointKey: 'sydneytrains',
    );

    Station station(
      String id,
      String name, {
      String? lineId,
      String? lineName,
    }) {
      return Station(id: id, name: name, lineId: lineId, lineName: lineName);
    }

    test('buildManualTripLegs converts ordered stops into continuous legs', () {
      final origin = station('central', 'Central');
      final interchange = station(
        'redfern',
        'Redfern',
        lineId: selectedLine.lineId,
        lineName: selectedLine.lineName,
      );
      final destination = station('strathfield', 'Strathfield');

      final legs = NewTripService.buildManualTripLegs(
        origin: origin,
        destination: destination,
        interchanges: [interchange],
        fallbackMode: selectedLine.mode,
      );

      expect(legs.length, 2);
      expect(legs[0].originId, 'central');
      expect(legs[0].destinationId, 'redfern');
      expect(legs[1].originId, 'redfern');
      expect(legs[1].destinationId, 'strathfield');
      expect(legs.map((leg) => leg.index), [0, 1]);
    });

    test('validateManualTrip allows direct two-stop manual trip', () {
      final validation = NewTripService.validateManualTrip(
        origin: station('central', 'Central'),
        destination: station('strathfield', 'Strathfield'),
        interchanges: const [],
        fallbackMode: selectedLine.mode,
      );

      expect(validation, isNull);
    });

    test('validateManualTrip rejects duplicate adjacent stops', () {
      final origin = station('central', 'Central');
      final duplicate = station(
        'central',
        'Central',
        lineId: selectedLine.lineId,
        lineName: selectedLine.lineName,
      );

      final validation = NewTripService.validateManualTrip(
        origin: origin,
        destination: station('strathfield', 'Strathfield'),
        interchanges: [duplicate],
        fallbackMode: selectedLine.mode,
      );

      expect(validation, 'Adjacent stops cannot be the same.');
    });

    test('validateManualTrip accepts interchanges from another line', () {
      final validation = NewTripService.validateManualTrip(
        origin: station('central', 'Central'),
        destination: station('strathfield', 'Strathfield'),
        interchanges: [
          station(
            'redfern',
            'Redfern',
            lineId: 'sydneytrains|T2',
            lineName: 'T2 Inner West Line',
          ),
        ],
        fallbackMode: selectedLine.mode,
      );

      expect(validation, isNull);
    });

    test('validateManualTrip accepts a continuous same-line trip', () {
      final validation = NewTripService.validateManualTrip(
        origin: station('central', 'Central'),
        destination: station('strathfield', 'Strathfield'),
        interchanges: [
          station(
            'redfern',
            'Redfern',
            lineId: selectedLine.lineId,
            lineName: selectedLine.lineName,
          ),
        ],
        fallbackMode: selectedLine.mode,
      );

      expect(validation, isNull);
    });
  });
}
