import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewTripScreen(
          skipInitialLoad: true,
          initialStations: [
            for (final name in ['Central', 'Town Hall', 'Redfern'])
              Station(name: name, id: name, mode: TransportMode.train),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String target, String name) async {
    await tester.tap(find.byKey(ValueKey('trip-$target')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  testWidgets('form opens picker and cancellation preserves both endpoints', (
    tester,
  ) async {
    await open(tester);
    expect(find.byType(TabBar), findsNothing);
    await choose(tester, 'destination', 'Town Hall');
    expect(find.text('Town Hall'), findsOneWidget);
    await choose(tester, 'origin', 'Central');
    expect(find.text('Central'), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
    await tester.tap(find.byKey(const ValueKey('trip-origin')));
    await tester.pumpAndSettle();
    expect(find.text('Choose starting stop'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Central'), findsOneWidget);
    expect(find.text('Town Hall'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear starting stop'));
    await tester.pumpAndSettle();
    expect(find.text('Central'), findsNothing);
    expect(find.text('Town Hall'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picker retains list scroll when reopened', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const ValueKey('trip-origin')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -250));
    await tester.pumpAndSettle();
    final before = tester
        .state<ScrollableState>(find.byType(Scrollable).last)
        .position
        .pixels;
    expect(before, greaterThan(0));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('trip-destination')));
    await tester.pumpAndSettle();
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).last)
          .position
          .pixels,
      before,
    );
  });

  testWidgets('picker keeps its search when reopened', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const ValueKey('trip-origin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('trip-destination')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Central',
    );
    await tester.tap(find.text('Central').first);
    await tester.pumpAndSettle();
    expect(find.text('Central'), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
  });

  testWidgets('interchange uses same picker and endpoint changes preserve it', (
    tester,
  ) async {
    await open(tester);
    await choose(tester, 'origin', 'Central');
    await choose(tester, 'destination', 'Town Hall');
    await tester.tap(find.text('Add interchange'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Redfern'));
    await tester.pumpAndSettle();
    expect(find.text('Interchange 1'), findsOneWidget);
    expect(find.text('Redfern'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('trip-editInterchange-0')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear destination'));
    await tester.pumpAndSettle();
    expect(find.text('Redfern'), findsOneWidget);
    expect(find.text('Central'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
