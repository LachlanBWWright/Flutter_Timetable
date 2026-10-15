import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/widgets/stops/stops_search_controller.dart';

TransitStop _stop(String name) => TransitStop(
  ref: TransitStopRef(
    region: TransitRegion.nsw,
    provider: TransitProviderId.tfnsw,
    sourceId: const TransitSourceId('test'),
    stopId: name,
  ),
  name: name,
);

void main() {
  test('debounces and clear invalidates pending work', () {
    fakeAsync((async) {
      final queries = <String>[];
      final controller = StopsSearchController(
        repository: (query) async {
          queries.add(query);
          return [];
        },
      );
      controller.search(' C ');
      async.elapse(const Duration(milliseconds: 200));
      controller.search('Central');
      async.elapse(const Duration(milliseconds: 299));
      expect(queries, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      expect(queries, ['Central']);

      controller.search('Museum');
      controller.search('');
      async.elapse(const Duration(milliseconds: 400));
      expect(queries, ['Central']);
      expect(controller.state.isSearching, isFalse);
      controller.dispose();
    });
  });

  test('stale completion cannot replace current results or loading state', () {
    fakeAsync((async) {
      final requests = <String, Completer<List<TransitStop>>>{};
      final controller = StopsSearchController(
        repository: (query) =>
            (requests[query] = Completer<List<TransitStop>>()).future,
      );
      controller.search('Old');
      async.elapse(const Duration(milliseconds: 300));
      controller.search('New');
      async.elapse(const Duration(milliseconds: 300));
      requests['Old']!.complete([_stop('Old')]);
      async.flushMicrotasks();
      expect(controller.state.isSearching, isTrue);
      expect(controller.state.results, isEmpty);
      requests['New']!.complete([_stop('New')]);
      async.flushMicrotasks();
      expect(controller.state.isSearching, isFalse);
      expect(controller.state.results.single.name, 'New');
      controller.dispose();
    });
  });

  test('repository replacement reschedules and dispose ignores completion', () {
    fakeAsync((async) {
      final oldRequest = Completer<List<TransitStop>>();
      final newRequest = Completer<List<TransitStop>>();
      final calls = <String>[];
      final controller = StopsSearchController(
        repository: (query) {
          calls.add('old:$query');
          return oldRequest.future;
        },
      );
      controller.search('Central');
      async.elapse(const Duration(milliseconds: 300));
      controller.updateRepository((query) {
        calls.add('new:$query');
        return newRequest.future;
      }, 'Central');
      oldRequest.complete([_stop('Old source')]);
      async.flushMicrotasks();
      expect(controller.state.isSearching, isTrue);
      async.elapse(const Duration(milliseconds: 300));
      expect(calls, ['old:Central', 'new:Central']);
      controller.dispose();
      newRequest.complete([_stop('Late')]);
      async.flushMicrotasks();
      expect(controller.state.results, isEmpty);
    });
  });

  test('failure state can be retried and success clears failure', () {
    fakeAsync((async) {
      var calls = 0;
      final controller = StopsSearchController(
        repository: (_) async {
          if (++calls == 1) throw Exception('offline');
          return [];
        },
      );
      controller.search('Central');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(controller.state.hasFailed, isTrue);
      controller.retry('Central');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(controller.state.hasFailed, isFalse);
      expect(controller.state.isSearching, isFalse);
      controller.dispose();
    });
  });

  test('search after disposal does not schedule repository work', () {
    fakeAsync((async) {
      var calls = 0;
      final controller = StopsSearchController(
        repository: (_) async {
          calls++;
          return [];
        },
      );
      controller.dispose();
      controller.search('Central');
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(calls, 0);
    });
  });

  test('ordinary Exceptions become failure state while Errors escape', () {
    fakeAsync((async) {
      final controller = StopsSearchController(
        repository: (_) async => throw Exception('offline'),
      );
      controller.search('Central');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(controller.state.hasFailed, isTrue);
      controller.dispose();
    });

    Object? uncaught;
    fakeAsync((async) {
      runZonedGuarded(
        () {
          final controller = StopsSearchController(
            repository: (_) async => throw StateError('programming error'),
          );
          controller.search('Central');
          async.elapse(const Duration(milliseconds: 300));
          async.flushMicrotasks();
          expect(controller.state.hasFailed, isFalse);
          controller.dispose();
        },
        (error, _) {
          uncaught = error;
        },
      );
      async.flushMicrotasks();
      expect(uncaught, isA<StateError>());
    });
  });
}
