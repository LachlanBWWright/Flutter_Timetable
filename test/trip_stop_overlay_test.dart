import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/debug_service.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/trip_leg_detail_screen.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';

const _planned = '2024-01-01T10:00:00Z';

Stop _stop(String id, String label, {bool arrival = false, String? estimate}) =>
    Stop(
      id: id,
      name: label,
      type: 'stop',
      arrivalTimePlanned: arrival ? _planned : null,
      arrivalTimeEstimated: arrival ? estimate : null,
      departureTimePlanned: arrival ? null : _planned,
      departureTimeEstimated: arrival ? null : estimate,
    );

TripUpdate_StopTimeUpdate _update({
  String? id,
  int? sequence,
  int? delay,
  int? time,
  bool arrival = false,
  bool emptyEvent = false,
  bool skipped = false,
}) {
  final update = TripUpdate_StopTimeUpdate();
  if (id != null) update.stopId = id;
  if (sequence != null) update.stopSequence = sequence;
  if (delay != null || time != null || emptyEvent) {
    final event = TripUpdate_StopTimeEvent();
    if (delay != null) event.delay = delay;
    if (time != null) event.time = Int64(time);
    if (arrival) {
      update.arrival = event;
    } else {
      update.departure = event;
    }
  }
  if (skipped) {
    update.scheduleRelationship =
        TripUpdate_StopTimeUpdate_ScheduleRelationship.SKIPPED;
  }
  return update;
}

Future<void> _showLiveStops(
  WidgetTester tester,
  List<Stop> stops,
  List<TripUpdate_StopTimeUpdate> updates, {
  bool canceled = false,
  bool showAll = true,
}) async {
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
  final trip = TripDescriptor()
    ..tripId = 'trip'
    ..routeId = 'route';
  if (canceled) {
    trip.scheduleRelationship = TripDescriptor_ScheduleRelationship.CANCELED;
  }
  final update = TripUpdate()..trip = trip;
  update.stopTimeUpdate.addAll(updates);
  final leg = Leg(
    origin: stops.first,
    destination: stops.last,
    stopSequence: stops,
    transportation: Transportation(
      id: 'route',
      name: 'Route',
      product: Product(classField: 5),
    ),
    rawJson: {
      'transportation': {
        'properties': {'RealtimeTripId': 'trip'},
      },
    },
  );
  await tester.pumpWidget(
    MaterialApp(
      home: TripLegDetailScreen(
        leg: leg,
        skipInitialLoad: showAll,
        skipInitialLoadDelay: !showAll,
        debugPageLoader: (_) async => throw UnimplementedError(),
        debugListLoader: (_) async => throw UnimplementedError(),
        getGtfsDataForEndpoint: (_) async => null,
        getAllVehiclesAggregated: () async =>
            const VehiclePositionAggregationResult(vehicles: [], breakdown: {}),
        getAllTripUpdatesAggregated: () async =>
            TripUpdateAggregationResult(tripUpdates: [update], breakdown: {}),
      ),
    ),
  );
  if (showAll) {
    await tester.tap(find.text('Show all stops'));
  }
  await tester.pump();
  await tester.pump();
}

Finder _row(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(ListTile));

void _expectRowText(String label, String text) {
  expect(
    find.descendant(of: _row(label), matching: find.text(text)),
    findsOneWidget,
  );
}

void main() {
  setUp(() => DebugService.showDebugData.value = false);

  testWidgets(
    'default stops and summary show matching live updates without a toggle',
    (tester) async {
      const arrivalEstimate = '2024-01-01T10:05:00Z';
      await _showLiveStops(
        tester,
        [_stop('a', 'Alpha'), _stop('b', 'Beta', arrival: true)],
        [
          _update(id: 'a', delay: 180),
          _update(
            id: 'b',
            arrival: true,
            time:
                DateTime.parse(arrivalEstimate).millisecondsSinceEpoch ~/ 1000,
          ),
          _update(id: 'outside-leg', delay: 60),
        ],
        showAll: false,
      );

      expect(find.text('Trip stops (2)'), findsOneWidget);
      expect(find.text('Show all stops'), findsOneWidget);
      expect(find.text('Show trip stops'), findsNothing);
      _expectRowText('Alpha', DateTimeUtils.parseTimeOnly(_planned));
      _expectRowText('Alpha', '+3m');
      _expectRowText('Beta', DateTimeUtils.parseTimeOnly(_planned));
      _expectRowText('Beta', '+5m');
      expect(
        find.text(
          '${DateTimeUtils.parseTimeOnly('2024-01-01T10:03:00Z')} (+3m late)',
        ),
        findsOneWidget,
      );
      expect(
        find.text('${DateTimeUtils.parseTimeOnly(arrivalEstimate)} (+5m late)'),
        findsOneWidget,
      );
      expect(find.text('outside-leg'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('partial updates retain scheduled stops and their order', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [_stop('a', 'Alpha'), _stop('b', 'Beta'), _stop('c', 'Gamma')],
      [_update(id: 'b', delay: 120)],
    );

    expect(find.text('All stops (3)'), findsOneWidget);
    _expectRowText('Alpha', DateTimeUtils.parseTimeOnly(_planned));
    _expectRowText('Beta', '+2m');
    _expectRowText('Gamma', DateTimeUtils.parseTimeOnly(_planned));
    expect(
      tester.getTopLeft(_row('Alpha')).dy,
      lessThan(tester.getTopLeft(_row('Beta')).dy),
    );
    expect(
      tester.getTopLeft(_row('Beta')).dy,
      lessThan(tester.getTopLeft(_row('Gamma')).dy),
    );
  });

  testWidgets('sequence matching advances past an unmatched scheduled row', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [_stop('a', 'Alpha'), _stop('b', 'Beta'), _stop('c', 'Gamma')],
      [_update(sequence: 2, delay: 180), _update(sequence: 3, delay: 240)],
    );

    expect(find.text('All stops (3)'), findsOneWidget);
    _expectRowText('Alpha', DateTimeUtils.parseTimeOnly(_planned));
    _expectRowText('Beta', '+3m');
    _expectRowText('Gamma', '+4m');
  });

  testWidgets('delay-only arrival and departure retain scheduled baselines', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [_stop('a', 'Arrival', arrival: true), _stop('b', 'Departure')],
      [
        _update(id: 'a', arrival: true, delay: 300),
        _update(id: 'b', delay: -120),
      ],
    );

    _expectRowText('Arrival', DateTimeUtils.parseTimeOnly(_planned));
    _expectRowText('Arrival', '+5m');
    _expectRowText('Departure', DateTimeUtils.parseTimeOnly(_planned));
    _expectRowText('Departure', '-2m');
  });

  testWidgets('events without time or delay preserve existing estimates', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [
        _stop('a', 'Alpha', estimate: '2024-01-01T10:07:00Z'),
        _stop('b', 'Beta'),
      ],
      [_update(id: 'a', emptyEvent: true), _update(id: 'b', emptyEvent: true)],
    );

    _expectRowText('Alpha', DateTimeUtils.parseTimeOnly(_planned));
    _expectRowText('Alpha', '+7m');
    _expectRowText('Beta', DateTimeUtils.parseTimeOnly(_planned));
    expect(find.text('All stops (2)'), findsOneWidget);
  });

  testWidgets('skipped stop remains alongside unmatched scheduled rows', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [_stop('a', 'Alpha'), _stop('b', 'Beta')],
      [_update(id: 'b', skipped: true)],
    );

    expect(find.text('All stops (2)'), findsOneWidget);
    expect(_row('Alpha'), findsOneWidget);
    _expectRowText('Beta', 'Skipped');
  });

  testWidgets('repeated stop IDs use sequence to distinguish visits', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [_stop('loop', 'First visit'), _stop('loop', 'Second visit')],
      [
        _update(id: 'loop', sequence: 2, delay: 480),
        _update(id: 'loop', sequence: 1, delay: 60),
      ],
    );

    expect(find.text('All stops (2)'), findsOneWidget);
    _expectRowText('First visit', '+1m');
    _expectRowText('Second visit', '+8m');
  });

  testWidgets('absolute realtime time keeps the scheduled planned baseline', (
    tester,
  ) async {
    final estimated = DateTime.parse('2024-01-01T10:06:00Z');
    await _showLiveStops(
      tester,
      [_stop('a', 'Alpha'), _stop('b', 'Beta')],
      [_update(id: 'a', time: estimated.millisecondsSinceEpoch ~/ 1000)],
    );

    _expectRowText('Alpha', DateTimeUtils.parseTimeOnly(_planned));
    _expectRowText('Alpha', '+6m');
  });

  testWidgets('canceled trips retain every scheduled row as cancelled', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [_stop('a', 'Alpha'), _stop('b', 'Beta')],
      [],
      canceled: true,
    );

    expect(find.text('All stops (2)'), findsOneWidget);
    _expectRowText('Alpha', 'Cancelled');
    _expectRowText('Beta', 'Cancelled');
  });

  testWidgets('NO_DATA clears obsolete estimates without dropping the stop', (
    tester,
  ) async {
    final noData = _update(id: 'a')
      ..scheduleRelationship =
          TripUpdate_StopTimeUpdate_ScheduleRelationship.NO_DATA;
    await _showLiveStops(
      tester,
      [
        _stop('a', 'Alpha', estimate: '2024-01-01T10:07:00Z'),
        _stop('b', 'Beta'),
      ],
      [noData],
    );

    _expectRowText('Alpha', DateTimeUtils.parseTimeOnly(_planned));
    expect(find.text('+7m'), findsNothing);
    expect(find.text('All stops (2)'), findsOneWidget);
  });

  testWidgets('known mismatched IDs cannot overlay by sequence alone', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [_stop('a', 'Alpha'), _stop('b', 'Beta')],
      [_update(id: 'other', sequence: 1, delay: 540)],
    );

    _expectRowText('Alpha', DateTimeUtils.parseTimeOnly(_planned));
    expect(
      find.descendant(of: _row('Alpha'), matching: find.text('+9m')),
      findsNothing,
    );
    expect(_row('Beta'), findsOneWidget);
    expect(_row('other'), findsOneWidget);
  });

  testWidgets('ID match anchors sequences for a leg beginning mid-trip', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [_stop('a', 'Alpha'), _stop('b', 'Beta'), _stop('c', 'Gamma')],
      [
        _update(id: 'a', sequence: 10, delay: 60),
        _update(sequence: 12, delay: 180),
      ],
    );

    expect(find.text('All stops (3)'), findsOneWidget);
    _expectRowText('Alpha', '+1m');
    _expectRowText('Beta', DateTimeUtils.parseTimeOnly(_planned));
    _expectRowText('Gamma', '+3m');
  });

  testWidgets('sparse repeated visits respect an inferred mid-trip offset', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [
        _stop('start', 'Start'),
        _stop('loop', 'First visit'),
        _stop('middle', 'Middle'),
        _stop('loop', 'Second visit'),
      ],
      [
        _update(id: 'start', sequence: 10),
        _update(id: 'loop', sequence: 13, delay: 480),
      ],
    );

    expect(find.text('All stops (4)'), findsOneWidget);
    _expectRowText('First visit', DateTimeUtils.parseTimeOnly(_planned));
    expect(
      find.descendant(of: _row('First visit'), matching: find.text('+8m')),
      findsNothing,
    );
    _expectRowText('Second visit', '+8m');
  });

  testWidgets('delay without a scheduled baseline does not invent a time', (
    tester,
  ) async {
    await _showLiveStops(
      tester,
      [Stop(id: 'a', name: 'Unknown time', type: 'stop'), _stop('b', 'Beta')],
      [_update(id: 'a', delay: 300)],
    );

    expect(find.text('All stops (2)'), findsOneWidget);
    expect(_row('Unknown time'), findsOneWidget);
    expect(tester.widget<ListTile>(_row('Unknown time')).trailing, isNull);
    _expectRowText('Beta', DateTimeUtils.parseTimeOnly(_planned));
  });
}
