import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/debug/screens/debug_entity_list_screen.dart';

void main() {
  Future<DebugEntityListPageData> listLoader(DebugEntityType entityType) async {
    return DebugEntityListPageData(
      entityType: entityType,
      title: '${entityType.label} Debug Browser',
      description: 'Test browser',
      emptyMessage: 'No items',
      items: [
        const DebugEntityListItem(
          entityType: DebugEntityType.stop,
          entityId: 'STOP-1',
          title: 'Alpha',
          subtitle: 'First stop',
          filterValues: {
            'mode': ['bus'],
          },
          searchTerms: ['central'],
          request: DebugEntityRequest(
            entityType: DebugEntityType.stop,
            entityId: 'STOP-1',
          ),
        ),
        DebugEntityListItem(
          entityType: DebugEntityType.stop,
          entityId: 'STOP-2',
          title: 'Beta',
          subtitle: 'Second stop',
          filterValues: {
            'mode': ['train'],
          },
          timestamp: DateTime(2026, 4, 29, 12),
          request: const DebugEntityRequest(
            entityType: DebugEntityType.stop,
            entityId: 'STOP-2',
          ),
        ),
        DebugEntityListItem(
          entityType: DebugEntityType.stop,
          entityId: 'STOP-3',
          title: 'Gamma',
          subtitle: 'Third stop',
          filterValues: {
            'mode': ['bus'],
          },
          timestamp: DateTime(2026, 4, 29, 13),
          request: const DebugEntityRequest(
            entityType: DebugEntityType.stop,
            entityId: 'STOP-3',
          ),
        ),
      ],
      filterGroups: const [
        DebugEntityListFilterGroup(
          key: 'mode',
          label: 'Mode',
          options: [
            DebugEntityListFilterOption(id: 'bus', label: 'Bus', count: 2),
            DebugEntityListFilterOption(id: 'train', label: 'Train', count: 1),
          ],
        ),
      ],
      sortOptions: const [
        DebugEntityListSort.titleAsc,
        DebugEntityListSort.titleDesc,
      ],
      defaultSort: DebugEntityListSort.titleAsc,
    );
  }

  Future<DebugPageData> pageLoader(DebugEntityRequest request) async {
    return DebugPageData(
      entityType: request.entityType,
      title: request.entityId,
      canonicalId: request.entityId,
      sections: const [
        DebugSectionData(
          title: 'Identity',
          fields: [DebugFieldRow(label: 'Loaded', value: 'true')],
        ),
      ],
    );
  }

  Widget appFor() {
    return MaterialApp(
      onGenerateRoute: DebugNavigation.onGenerateRoute,
      home: DebugEntityListScreen(
        args: DebugBrowserNavigationArgs(
          entityType: DebugEntityType.stop,
          listLoader: listLoader,
          pageLoader: pageLoader,
        ),
      ),
    );
  }

  List<String> visibleTitles(WidgetTester tester) {
    return tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title as Text).data!)
        .toList(growable: false);
  }

  testWidgets('debug browser supports search, filter, and sort', (
    tester,
  ) async {
    await tester.pumpWidget(appFor());
    await tester.pumpAndSettle();

    expect(visibleTitles(tester), ['Alpha', 'Beta', 'Gamma']);

    await tester.enterText(find.byType(TextField), 'gamma');
    await tester.pumpAndSettle();
    expect(visibleTitles(tester), ['Gamma']);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('debug-list-filter-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bus (2)').last);
    await tester.pumpAndSettle();
    expect(visibleTitles(tester), ['Alpha', 'Gamma']);

    await tester.tap(find.byKey(const ValueKey('debug-list-sort')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title Z-A').last);
    await tester.pumpAndSettle();
    expect(visibleTitles(tester), ['Gamma', 'Alpha']);
  });

  testWidgets('tapping a browser entry opens the entity debug page', (
    tester,
  ) async {
    await tester.pumpWidget(appFor());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(find.text('Stop Debug'), findsOneWidget);
    expect(find.text('STOP-1'), findsAtLeastNWidgets(1));
    expect(find.text('Loaded'), findsOneWidget);
  });
}
