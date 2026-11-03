import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/utils/visible_realtime_refresh.dart';

void main() {
  testWidgets('polling pauses in background and resumes immediately', (
    tester,
  ) async {
    var refreshes = 0;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        home: _RefreshHost(
          onRefresh: () async {
            refreshes++;
          },
        ),
      ),
    );
    await tester.pump(Duration.zero);
    expect(refreshes, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(minutes: 2));
    expect(refreshes, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(Duration.zero);
    expect(refreshes, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 2));
    expect(refreshes, 2);
  });

  testWidgets('covered routes pause polling and refresh when uncovered', (
    tester,
  ) async {
    var refreshes = 0;
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: _RefreshHost(
          onRefresh: () async {
            refreshes++;
          },
        ),
      ),
    );
    await tester.pump(Duration.zero);
    expect(refreshes, 1);

    unawaited(
      navigator.currentState!.push<void>(
        PageRouteBuilder<void>(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, _, _) => const Scaffold(body: Text('Covered')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(minutes: 2));
    expect(refreshes, 1);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(refreshes, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 2));
    expect(refreshes, 2);
  });

  testWidgets('visibility changes coalesce without overlapping refreshes', (
    tester,
  ) async {
    final pending = <Completer<void>>[];
    var active = 0;
    var maximumActive = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: _RefreshHost(
          onRefresh: () async {
            active++;
            if (active > maximumActive) maximumActive = active;
            final completion = Completer<void>();
            pending.add(completion);
            await completion.future;
            active--;
          },
        ),
      ),
    );
    await tester.pump(Duration.zero);
    expect(pending, hasLength(1));

    for (var i = 0; i < 3; i++) {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }
    await tester.pump(const Duration(minutes: 2));
    expect(pending, hasLength(1));
    pending.first.complete();
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);
    expect(pending, hasLength(2));
    expect(maximumActive, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    pending.last.complete();
    await tester.pump(const Duration(minutes: 2));
    expect(pending, hasLength(2));
    expect(active, 0);
  });

  testWidgets('refreshOnStart false waits for the first interval', (
    tester,
  ) async {
    var refreshes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: _RefreshHost(
          refreshOnStart: false,
          onRefresh: () async {
            refreshes++;
          },
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 29));
    expect(refreshes, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(refreshes, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _RefreshHost extends StatefulWidget {
  const _RefreshHost({required this.onRefresh, this.refreshOnStart = true});

  final Future<void> Function() onRefresh;
  final bool refreshOnStart;

  @override
  State<_RefreshHost> createState() => _RefreshHostState();
}

class _RefreshHostState extends State<_RefreshHost> {
  late final VisibleRealtimeRefresh refresh;

  @override
  void initState() {
    super.initState();
    refresh = VisibleRealtimeRefresh(
      onRefresh: widget.onRefresh,
      refreshOnStart: widget.refreshOnStart,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refresh.updateRoute(context);
  }

  @override
  void dispose() {
    refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('Refreshing'));
}
