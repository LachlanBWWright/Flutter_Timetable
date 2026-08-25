// ignore_for_file: catch_async_error_sources, catch_inferred_throwing_calls, catch_runtime_throw_sources, catch_unknown_dynamic_calls, no_null_assertion

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/settings.dart';
import 'package:lbww_flutter/services/transport_preferences_service.dart';
import 'package:lbww_flutter/transit/transit.dart';
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

  testWidgets(
    'settings shows credentials and attribution for enabled regions',
    (tester) async {
      addTearDown(() {
        TransportPreferencesService.enabledRegions.value = {TransitRegion.nsw};
        TransportPreferencesService.selectedRegion.value = TransitRegion.nsw;
      });
      TransportPreferencesService.enabledRegions.value = {
        TransitRegion.nsw,
        TransitRegion.victoria,
        TransitRegion.queensland,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            stopsManagementWidget: const SizedBox.shrink(),
            stopsSearchWidget: const SizedBox.shrink(),
            realtimeInfoWidget: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Transport for NSW Open Data'), findsWidgets);
      expect(find.text('Public Transport Victoria'), findsWidgets);
      expect(find.text('Queensland TransLink GTFS'), findsWidgets);
      expect(find.text('PTV developer ID'), findsOneWidget);
      expect(
        find.textContaining('No API credentials are required'),
        findsOneWidget,
      );
    },
  );

  testWidgets('settings screen debug buttons open entity browsers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: DebugNavigation.onGenerateRoute,
        home: SettingsScreen(
          debugPageLoader: pageLoader,
          debugListLoader: listLoader,
          hasUserApiKey: false,
          hasBuiltInApiKey: false,
          stopsManagementWidget: const SizedBox.shrink(),
          stopsSearchWidget: const SizedBox.shrink(),
          realtimeInfoWidget: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Browse route debug pages'),
      500,
      scrollable: find.byType(Scrollable).first,
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
