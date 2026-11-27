import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/realtime_service.dart';
import 'package:lbww_flutter/widgets/realtime_status_banner.dart';

void main() {
  Future<void> showBanner(
    WidgetTester tester,
    RealtimeSnapshotMetadata metadata, {
    bool isLoading = false,
    bool isEmpty = false,
    VoidCallback? onRetry,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RealtimeStatusBanner(
          metadata: metadata,
          isLoading: isLoading,
          isEmpty: isEmpty,
          onRetry: onRetry,
        ),
      ),
    ),
  );

  testWidgets('initial loading is announced without a timestamp', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await showBanner(
        tester,
        const RealtimeSnapshotMetadata(),
        isLoading: true,
      );
      expect(
        tester.getSemantics(find.text('Loading live data…')),
        matchesSemantics(label: 'Loading live data…', isLiveRegion: true),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('Updated'), findsNothing);
      expect(find.text('Retry'), findsNothing);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('valid empty data is distinct from an unavailable feed', (
    tester,
  ) async {
    await showBanner(
      tester,
      RealtimeSnapshotMetadata(fetchedAt: DateTime(2026, 10, 13, 12)),
      isEmpty: true,
    );
    expect(find.textContaining('No live vehicles available.'), findsOneWidget);
    expect(find.textContaining('Updated 13/10'), findsNothing);
    expect(find.text('Retry'), findsNothing);

    await showBanner(
      tester,
      const RealtimeSnapshotMetadata(failedSources: {'positions:train'}),
      isEmpty: true,
    );
    expect(find.text('Live data is unavailable right now.'), findsOneWidget);
    expect(find.textContaining('No live vehicles'), findsNothing);
  });

  testWidgets('outdated information warning supports retry', (tester) async {
    var retries = 0;
    await showBanner(
      tester,
      RealtimeSnapshotMetadata(
        fetchedAt: DateTime(2026, 10, 12, 23),
        failedSources: const {'positions:train'},
        staleSources: const {'positions:train'},
      ),
      onRetry: () => retries++,
    );
    expect(
      find.textContaining('Live information may be out of date'),
      findsOneWidget,
    );
    expect(find.textContaining('Updated 12/10'), findsNothing);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('refresh disables repeated retries', (tester) async {
    var retries = 0;
    await showBanner(
      tester,
      RealtimeSnapshotMetadata(
        fetchedAt: DateTime(2026, 10, 13, 12),
        staleSources: const {'positions:train'},
      ),
      isLoading: true,
      onRetry: () => retries++,
    );
    expect(find.textContaining('Refreshing live data…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 0);
  });

  testWidgets('partial feed failure is visible alongside successful data', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      var retries = 0;
      await showBanner(
        tester,
        RealtimeSnapshotMetadata(
          fetchedAt: DateTime(2026, 10, 13, 12),
          failedSources: const {'positions:bus'},
        ),
        onRetry: () => retries++,
      );
      expect(
        find.textContaining('Some live updates are unavailable.'),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(find.textContaining('Some live updates')),
        matchesSemantics(
          label: 'Some live updates are unavailable.',
          isLiveRegion: true,
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    } finally {
      semantics.dispose();
    }
  });
}
