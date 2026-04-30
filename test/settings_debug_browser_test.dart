import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/widgets/stops_widgets.dart';

void main() {
  Future<DebugEntityListPageData> listLoader(DebugEntityType entityType) async {
    return DebugEntityListPageData(
      entityType: entityType,
      title: '${entityType.label} Debug Browser',
      description: 'Mock browser',
      emptyMessage: 'No items',
      items: const [],
    );
  }

  Future<DebugPageData> pageLoader(DebugEntityRequest request) async {
    return DebugPageData(
      entityType: request.entityType,
      title: request.entityId,
      canonicalId: request.entityId,
    );
  }

  testWidgets('settings screen debug buttons open entity browsers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: DebugNavigation.onGenerateRoute,
        home: SettingsScreen(
          debugPageLoader: pageLoader,
          debugListLoader: listLoader,
          hasUserApiKey: () => false,
          hasBuiltInApiKey: () => false,
          stopsManagementWidget: const SizedBox.shrink(),
          stopsSearchWidget: const SizedBox.shrink(),
          realtimeInfoWidget: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, -1200),
      1000,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browse route debug pages').last);
    await tester.pumpAndSettle();

    expect(find.text('Route Browser'), findsOneWidget);
    expect(find.text('Route Debug Browser'), findsOneWidget);
  });

  testWidgets('stops management debug button opens stop browser', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: DebugNavigation.onGenerateRoute,
        home: Scaffold(
          body: StopsManagementWidget(
            getTotalStopsCount: () async => 2,
            getStopsCountByEndpoint: () async => {
              TransportMode.bus: {'buses': 2},
            },
            debugPageLoader: pageLoader,
            debugListLoader: listLoader,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Browse stop debug pages'));
    await tester.pumpAndSettle();

    expect(find.text('Stop Browser'), findsOneWidget);
    expect(find.text('Stop Debug Browser'), findsOneWidget);
  });
}
