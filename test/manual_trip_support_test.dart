import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

void main() {
  group('ManualTripDefinition', () {
    test('reversed keeps the same line and reverses stop order', () {
      final definition = const ManualTripDefinition(
        mode: TransportMode.train,
        lineId: 'sydneytrains|T1',
        lineName: 'T1 North Shore Line',
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
      final definition = const ManualTripDefinition(
        mode: TransportMode.train,
        lineId: 'sydneytrains|T1',
        lineName: 'T1 North Shore Line',
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
        lineId: definition.lineId,
        lineName: definition.lineName,
        legsJson: definition.toLegsJson(),
        isPinned: true,
      );

      final reversedJourney = journey.reversedPreviewJourney();
      final reversedDefinition = reversedJourney.manualTripDefinition;

      expect(reversedJourney.origin, 'Strathfield');
      expect(reversedJourney.destination, 'Central');
      expect(reversedJourney.isPinned, isTrue);
      expect(reversedDefinition, isNotNull);
      expect(reversedDefinition!.orderedStops.map((stop) => stop.id), [
        'strathfield',
        'redfern',
        'central',
      ]);
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
        selectedLine: selectedLine,
      );

      expect(legs.length, 2);
      expect(legs[0].originId, 'central');
      expect(legs[0].destinationId, 'redfern');
      expect(legs[1].originId, 'redfern');
      expect(legs[1].destinationId, 'strathfield');
      expect(legs.map((leg) => leg.index), [0, 1]);
    });

    test('validateManualTrip requires at least one interchange', () {
      final validation = NewTripService.validateManualTrip(
        origin: station('central', 'Central'),
        destination: station('strathfield', 'Strathfield'),
        interchanges: const [],
        selectedLine: selectedLine,
      );

      expect(
        validation,
        'A manual multi-leg trip needs at least one interchange.',
      );
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
        selectedLine: selectedLine,
      );

      expect(validation, 'Adjacent stops cannot be the same.');
    });

    test('validateManualTrip rejects interchanges from another line', () {
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
        selectedLine: selectedLine,
      );

      expect(validation, 'Each interchange must stay on the selected line.');
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
        selectedLine: selectedLine,
      );

      expect(validation, isNull);
    });
  });
}
