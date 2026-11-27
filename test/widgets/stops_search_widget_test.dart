import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/widgets/stops/stops_search_widget.dart';

TransitStop stop(String name) => TransitStop(
  ref: TransitStopRef(
    region: TransitRegion.nsw,
    provider: TransitProviderId.tfnsw,
    sourceId: const TransitSourceId('test'),
    stopId: name,
  ),
  name: name,
);

Future<void> mountSearch(
  WidgetTester tester,
  Future<List<TransitStop>> Function(String) search,
) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: StopsSearchWidget(searchStops: search)),
  ),
);

Future<void> search(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('debounces input and cancels pending work when cleared', (
    tester,
  ) async {
    final calls = <String>[];
    await mountSearch(tester, (query) async {
      calls.add(query);
      return [];
    });
    await tester.enterText(find.byType(TextField), 'C');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls, isEmpty);
    await tester.pump(const Duration(milliseconds: 100));
    expect(calls, ['Central']);
    await tester.enterText(find.byType(TextField), 'Museum');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump(const Duration(milliseconds: 400));
    expect(calls, ['Central']);
    expect(find.text('No stops found'), findsNothing);
  });

  testWidgets('old success cannot overwrite newer results', (tester) async {
    final requests = <String, Completer<List<TransitStop>>>{};
    await mountSearch(tester, (query) {
      return (requests[query] = Completer<List<TransitStop>>()).future;
    });
    await search(tester, 'Old');
    await search(tester, 'New');
    requests['New']!.complete([stop('New result')]);
    await tester.pump();
    requests['Old']!.complete([stop('Old result')]);
    await tester.pump();
    expect(find.text('New result'), findsOneWidget);
    expect(find.text('Old result'), findsNothing);
  });

  testWidgets('stale failures cannot stop the current loading state', (
    tester,
  ) async {
    final requests = <String, Completer<List<TransitStop>>>{};
    await mountSearch(tester, (query) {
      return (requests[query] = Completer<List<TransitStop>>()).future;
    });
    await search(tester, 'Old');
    await search(tester, 'New');
    requests['Old']!.completeError(Exception('Failed'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    requests['New']!.complete([]);
    await tester.pump();
    expect(find.text('No stops found'), findsOneWidget);
  });

  testWidgets('clearing invalidates an in-flight search', (tester) async {
    final request = Completer<List<TransitStop>>();
    await mountSearch(tester, (_) => request.future);
    await search(tester, 'Central');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.clear));
    request.complete([stop('Late result')]);
    await tester.pump();
    expect(find.text('Late result'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('changing the repository invalidates in-flight results', (
    tester,
  ) async {
    final oldRequest = Completer<List<TransitStop>>();
    final newRequest = Completer<List<TransitStop>>();
    await mountSearch(tester, (_) => oldRequest.future);
    await search(tester, 'Central');

    await mountSearch(tester, (_) => newRequest.future);
    oldRequest.complete([stop('Old source result')]);
    await tester.pump();
    expect(find.text('Old source result'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    newRequest.complete([stop('New source result')]);
    await tester.pump();
    expect(find.text('New source result'), findsOneWidget);
    expect(find.text('Old source result'), findsNothing);
  });

  testWidgets('changing the repository cancels its pending debounce', (
    tester,
  ) async {
    var oldCalls = 0;
    final newQueries = <String>[];
    await mountSearch(tester, (_) async {
      oldCalls++;
      return [];
    });
    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pump(const Duration(milliseconds: 100));

    await mountSearch(tester, (query) async {
      newQueries.add(query);
      return [stop('Replacement result')];
    });
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(oldCalls, 0);
    expect(newQueries, ['Central']);
    expect(find.text('Replacement result'), findsOneWidget);
  });

  testWidgets('failed search has retry and successful empty stays distinct', (
    tester,
  ) async {
    var calls = 0;
    await mountSearch(tester, (_) async {
      if (++calls == 1) throw Exception('Offline');
      return [];
    });
    await search(tester, 'Central');
    await tester.pump();
    expect(find.text('No stops found'), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(calls, 2);
    expect(find.text('No stops found'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('disposal cancels debounce and ignores in-flight completion', (
    tester,
  ) async {
    var calls = 0;
    final request = Completer<List<TransitStop>>();
    Future<List<TransitStop>> repository(String query) {
      calls++;
      return request.future;
    }

    await mountSearch(tester, repository);
    await tester.enterText(find.byType(TextField), 'Pending');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 400));
    expect(calls, 0);
    await mountSearch(tester, repository);
    await search(tester, 'Active');
    await tester.pumpWidget(const SizedBox());
    request.complete([stop('Late result')]);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
