import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/debug/screens/debug_entity_screen.dart';

void main() {
  Future<DebugPageData> loader(DebugEntityRequest request) async {
    switch ((request.entityType, request.entityId)) {
      case (DebugEntityType.stop, 'STOP-1'):
        return const DebugPageData(
          entityType: DebugEntityType.stop,
          title: 'Central',
          canonicalId: 'STOP-1',
          sourceBadges: [DebugDataSource.api, DebugDataSource.localDb],
          sections: [
            DebugSectionData(
              title: 'Identity',
              fields: [DebugFieldRow(label: 'Stop Name', value: 'Central')],
            ),
          ],
        );
      case (DebugEntityType.route, 'ROUTE-1'):
        return const DebugPageData(
          entityType: DebugEntityType.route,
          title: 'T1 City',
          canonicalId: 'ROUTE-1',
          sourceBadges: [DebugDataSource.api, DebugDataSource.gtfs],
          sections: [
            DebugSectionData(
              title: 'Identity',
              fields: [DebugFieldRow(label: 'Route Name', value: 'T1 City')],
            ),
          ],
        );
      case (DebugEntityType.vehicle, 'VEH-1'):
        return const DebugPageData(
          entityType: DebugEntityType.vehicle,
          title: 'Vehicle 1',
          canonicalId: 'VEH-1',
          sourceBadges: [DebugDataSource.realtime],
          sections: [
            DebugSectionData(
              title: 'Identity',
              fields: [DebugFieldRow(label: 'Vehicle ID', value: 'VEH-1')],
            ),
          ],
        );
      case _:
        return DebugPageData(
          entityType: DebugEntityType.trip,
          title: 'Mock Trip',
          canonicalId: request.entityId,
          sourceBadges: const [DebugDataSource.api, DebugDataSource.derived],
          sections: const [
            DebugSectionData(
              title: 'References',
              references: [
                DebugEntityRef(
                  entityType: DebugEntityType.stop,
                  entityId: 'STOP-1',
                  title: 'Origin Stop',
                  subtitle: 'Trip origin',
                  request: DebugEntityRequest(
                    entityType: DebugEntityType.stop,
                    entityId: 'STOP-1',
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget appFor(DebugEntityRequest request) {
    return MaterialApp(
      onGenerateRoute: DebugNavigation.onGenerateRoute,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                DebugNavigation.pushEntity(
                  context,
                  request: request,
                  loader: loader,
                );
              },
              child: const Text('Open Debug'),
            ),
          ),
        ),
      ),
    );
  }

  Widget screenFor(DebugEntityRequest request) {
    return MaterialApp(
      home: DebugEntityScreen(
        args: DebugNavigationArgs(request: request, loader: loader),
      ),
    );
  }

  testWidgets(
    'generic debug screen renders static pages for all entity types',
    (tester) async {
      for (final request in const [
        DebugEntityRequest(
          entityType: DebugEntityType.trip,
          entityId: 'TRIP-1',
        ),
        DebugEntityRequest(
          entityType: DebugEntityType.stop,
          entityId: 'STOP-1',
        ),
        DebugEntityRequest(
          entityType: DebugEntityType.route,
          entityId: 'ROUTE-1',
        ),
        DebugEntityRequest(
          entityType: DebugEntityType.vehicle,
          entityId: 'VEH-1',
        ),
      ]) {
        await tester.pumpWidget(screenFor(request));
        await tester.pumpAndSettle();

        expect(find.text('${request.entityType.label} Debug'), findsOneWidget);
      }
    },
  );

  testWidgets('reference tiles open another debug page with mock data', (
    tester,
  ) async {
    await tester.pumpWidget(
      appFor(
        const DebugEntityRequest(
          entityType: DebugEntityType.trip,
          entityId: 'TRIP-1',
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Origin Stop'), findsOneWidget);

    await tester.tap(find.text('Origin Stop'));
    await tester.pumpAndSettle();

    expect(find.text('Stop Debug'), findsOneWidget);
    expect(find.text('STOP-1'), findsOneWidget);
  });
}
