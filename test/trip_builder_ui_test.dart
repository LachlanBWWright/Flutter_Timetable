// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
import 'package:lbww_flutter/trip_composer_screen.dart';
import 'package:lbww_flutter/widgets/selected_stops_widget.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

void main() {
  const line = StopLineMatch(
    mode: TransportMode.train,
    lineId: 'T1',
    lineName: 'T1 North Shore',
    endpointKey: 'sydneytrains',
  );

  Station station(String name, String id) {
    return Station(
      name: name,
      id: id,
      lineId: line.lineId,
      lineName: line.lineName,
    );
  }

  Widget app(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('SelectedStopsSummaryBar', () {
    testWidgets('empty state hides the bar', (tester) async {
      await tester.pumpWidget(
        app(
          SelectedStopsSummaryBar(
            origin: null,
            destination: null,
            currentMode: TransportMode.train,
            originMode: null,
            destinationMode: null,
            selectedLine: null,
            isLoadingLineCandidates: false,
            originLineCount: 0,
            statusMessage: null,
            onClearOrigin: () {},
            onClearDestination: () {},
            onSaveDirect: () {},
            onOpenComposer: () {},
            canSaveDirect: false,
            canComposeManual: false,
          ),
        ),
      );

      expect(find.text('From'), findsNothing);
      expect(find.text('To'), findsNothing);
    });

    testWidgets('origin-only state shows destination guidance', (tester) async {
      await tester.pumpWidget(
        app(
          SelectedStopsSummaryBar(
            origin: station('Central', '1'),
            destination: null,
            currentMode: TransportMode.train,
            originMode: TransportMode.train,
            destinationMode: null,
            selectedLine: null,
            isLoadingLineCandidates: false,
            originLineCount: 2,
            statusMessage: null,
            onClearOrigin: () {},
            onClearDestination: () {},
            onSaveDirect: () {},
            onOpenComposer: () {},
            canSaveDirect: false,
            canComposeManual: false,
          ),
        ),
      );

      expect(find.text('Central'), findsOneWidget);
      expect(find.text('Choose destination'), findsOneWidget);
      expect(find.text('Direct'), findsNothing);
    });

    testWidgets('origin and destination show save and edit actions', (
      tester,
    ) async {
      var saved = false;
      var opened = false;

      await tester.pumpWidget(
        app(
          SelectedStopsSummaryBar(
            origin: station('Central', '1'),
            destination: station('Town Hall', '2'),
            currentMode: TransportMode.train,
            originMode: TransportMode.train,
            destinationMode: TransportMode.train,
            selectedLine: line,
            isLoadingLineCandidates: false,
            originLineCount: 2,
            statusMessage: null,
            onClearOrigin: () {},
            onClearDestination: () {},
            onSaveDirect: () => saved = true,
            onOpenComposer: () => opened = true,
            canSaveDirect: true,
            canComposeManual: true,
          ),
        ),
      );

      expect(find.text('Central'), findsOneWidget);
      expect(find.text('Town Hall'), findsOneWidget);
      expect(find.text('Save Trip'), findsOneWidget);
      expect(find.text('Edit Stops'), findsOneWidget);

      await tester.tap(find.text('Save Trip'));
      await tester.tap(find.text('Edit Stops'));

      expect(saved, isTrue);
      expect(opened, isTrue);
    });
  });

  group('SelectedStopsWidget', () {
    testWidgets('origin-only state shows same-line filter toggle', (
      tester,
    ) async {
      var filterEnabled = false;

      await tester.pumpWidget(
        app(
          SelectedStopsWidget(
            origin: station('Central', '1'),
            destination: null,
            currentMode: TransportMode.train,
            originMode: TransportMode.train,
            destinationMode: null,
            isLoadingLineCandidates: false,
            originLineCandidates: const [line],
            isSameLineFilterEnabled: false,
            onSameLineFilterChanged: (value) => filterEnabled = value,
            selectedLine: null,
            interchanges: const [],
            isResolvingSharedLines: false,
            isManualBuilderEnabled: false,
            pendingInterchangeInsertIndex: null,
            statusMessage: null,
            manualValidationMessage: null,
            onClearOrigin: () {},
            onClearDestination: () {},
            onSaveDirect: () {},
            onAddInterchange: (_) {},
            onRemoveInterchange: (_) {},
            onMoveInterchange: (_, _) {},
            canSaveDirect: false,
            canSaveManual: false,
          ),
        ),
      );

      expect(find.text('Only show stops on the same line'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(filterEnabled, isTrue);
    });

    testWidgets('direct two-stop state hides add leg prompt', (tester) async {
      await tester.pumpWidget(
        app(
          SelectedStopsWidget(
            origin: station('Central', '1'),
            destination: station('Town Hall', '2'),
            currentMode: TransportMode.train,
            originMode: TransportMode.train,
            destinationMode: TransportMode.train,
            isLoadingLineCandidates: false,
            originLineCandidates: const [line],
            isSameLineFilterEnabled: false,
            onSameLineFilterChanged: null,
            selectedLine: line,
            interchanges: const [],
            isResolvingSharedLines: false,
            isManualBuilderEnabled: false,
            pendingInterchangeInsertIndex: null,
            statusMessage: null,
            manualValidationMessage: null,
            onClearOrigin: () {},
            onClearDestination: () {},
            onSaveDirect: () {},
            onAddInterchange: (_) {},
            onRemoveInterchange: (_) {},
            onMoveInterchange: (_, _) {},
            canSaveDirect: true,
            canSaveManual: false,
          ),
        ),
      );

      expect(find.text('Add leg here'), findsNothing);
      expect(find.text('Save Trip'), findsOneWidget);
    });
  });

  group('TripComposerScreen', () {
    testWidgets('renders stops in order with add controls', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TripComposerScreen(
            origin: station('Central', '1'),
            destination: station('Wynyard', '3'),
            currentMode: TransportMode.train,
            originMode: TransportMode.train,
            destinationMode: TransportMode.train,
            selectedLine: null,
            interchanges: [station('Town Hall', '2')],
            manualValidationMessage: null,
            canSaveManual: true,
            onLoadInterchangeCandidates: (_) async => const [],
            onInsertInterchange: (_, _) {},
            onRemoveInterchange: (_) {},
            onMoveInterchange: (_, _) {},
            onSaveManual: () {},
          ),
        ),
      );

      expect(find.text('Origin'), findsOneWidget);
      expect(find.text('Central'), findsWidgets);
      expect(find.text('Interchange 1'), findsOneWidget);
      expect(find.text('Town Hall'), findsOneWidget);
      expect(find.text('Destination'), findsOneWidget);
      expect(find.text('Wynyard'), findsWidgets);
      expect(find.text('Add leg here'), findsNWidgets(2));
    });

    testWidgets('move and remove controls update through callbacks', (
      tester,
    ) async {
      final moves = <String>[];
      final removals = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: TripComposerScreen(
            origin: station('Central', '1'),
            destination: station('North Sydney', '4'),
            currentMode: TransportMode.train,
            originMode: TransportMode.train,
            destinationMode: TransportMode.train,
            selectedLine: null,
            interchanges: [station('Town Hall', '2'), station('Wynyard', '3')],
            manualValidationMessage: null,
            canSaveManual: true,
            onLoadInterchangeCandidates: (_) async => const [],
            onInsertInterchange: (_, _) {},
            onRemoveInterchange: removals.add,
            onMoveInterchange: (index, delta) => moves.add('$index:$delta'),
            onSaveManual: () {},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_downward).first);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      expect(moves, ['0:1']);
      expect(removals, [0]);
    });

    testWidgets('add stop opens a standard stop selection page', (
      tester,
    ) async {
      var inserted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TripComposerScreen(
            origin: station('Central', '1'),
            destination: station('Wynyard', '3'),
            currentMode: TransportMode.train,
            originMode: TransportMode.train,
            destinationMode: TransportMode.train,
            selectedLine: null,
            interchanges: const [],
            manualValidationMessage:
                'A manual multi-leg trip needs at least one interchange.',
            canSaveManual: false,
            onLoadInterchangeCandidates: (_) async => [
              station('Town Hall', '2'),
            ],
            onInsertInterchange: (_, _) => inserted = true,
            onRemoveInterchange: (_) {},
            onMoveInterchange: (_, _) {},
            onSaveManual: () {},
          ),
        ),
      );

      await tester.tap(find.text('Add leg here'));
      await tester.pumpAndSettle();

      expect(find.text('Select Stop'), findsOneWidget);
      expect(
        find.textContaining('Adding between Central and Wynyard'),
        findsOneWidget,
      );
      expect(find.text('Town Hall'), findsOneWidget);
      expect(find.byType(StationView), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.near_me), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Town Hall'), findsNothing);
      expect(inserted, isFalse);

      await tester.tap(find.text('Add leg here'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Town Hall'));
      await tester.pumpAndSettle();

      expect(inserted, isTrue);
      expect(find.text('Interchange 1'), findsOneWidget);
    });
  });
}
