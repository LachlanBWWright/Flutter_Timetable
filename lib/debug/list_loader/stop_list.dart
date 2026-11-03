part of '../debug_entity_list_loader.dart';

extension _DebugStopList on DebugEntityListLoader {
  Future<DebugEntityListPageData> _loadStopList() async {
    final rows = await _loadDbStops();
    final grouped = <String, List<db.Stop>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.stopId, () => <db.Stop>[]).add(row);
    }

    final items = grouped.entries
        .map((entry) {
          final stopId = entry.key;
          final stopRows = entry.value;
          final primary = stopRows.first;
          final endpoints = stopRows.map((row) => row.endpoint).toSet().toList()
            ..sort();
          final modes =
              stopRows
                  .map(
                    (row) =>
                        StopsService.modeForEndpointKey(row.endpoint)?.name ??
                        'unknown',
                  )
                  .toSet()
                  .toList()
                ..sort();
          final localities = sortedStrings(stopRows.map((row) => row.stopDesc));
          final parentStations = sortedStrings(
            stopRows.map((row) => row.parentStation),
          );
          final parentStatus = parentStations.isEmpty
              ? 'no_parent'
              : 'has_parent';
          final coverage = endpoints.length > 1
              ? 'multi_endpoint'
              : 'single_endpoint';
          final searchTerms = <String>{
            primary.stopName,
            primary.stopCode ?? '',
            primary.stopDesc ?? '',
            primary.parentStation ?? '',
            ...endpoints,
            ...localities,
            ...parentStations,
          }..removeWhere((term) => term.isEmpty);

          final filterValues = <String, List<String>>{
            'mode': modes,
            'endpoint': endpoints,
            'coverage': [coverage],
            'parent_status': [parentStatus],
          };
          _putFilterValues(filterValues, 'locality', localities);
          _putFilterValues(filterValues, 'parent', parentStations);

          return DebugEntityListItem(
            entityType: DebugEntityType.stop,
            entityId: stopId,
            title: primary.stopName,
            subtitle: listSubtitleForEntity(
              DebugEntityType.stop,
              stopId,
              endpoints.length,
            ),
            description: primary.stopDesc,
            sources: const [DebugDataSource.localDb],
            filterValues: filterValues,
            searchTerms: searchTerms.toList()..sort(),
            request: DebugEntityRequest(
              entityType: DebugEntityType.stop,
              entityId: stopId,
              context: DebugEntityContext(dbStops: stopRows),
            ),
          );
        })
        .toList(growable: false);

    return DebugEntityListPageData(
      entityType: DebugEntityType.stop,
      title: 'Stop Debug Browser',
      description:
          'Browse locally managed stop records and open the standalone stop debug page for any stop ID.',
      emptyMessage:
          'No local stop data is available. Load stops data from Settings before browsing stop debug pages.',
      items: items,
      sourceBadges: const [DebugDataSource.localDb],
      filterGroups: _buildFilterGroups(items, const {
        'mode': 'Mode',
        'endpoint': 'Endpoint',
        'coverage': 'Coverage',
        'parent_status': 'Parent status',
        'locality': 'Locality',
        'parent': 'Parent stop',
      }),
      sortOptions: const [
        DebugEntityListSort.titleAsc,
        DebugEntityListSort.titleDesc,
        DebugEntityListSort.idAsc,
        DebugEntityListSort.idDesc,
      ],
      defaultSort: DebugEntityListSort.titleAsc,
      banners: items.isEmpty
          ? const [
              DebugStatusBannerData(
                tone: DebugStatusTone.warning,
                title: 'No managed stops',
                message:
                    'The stop browser uses the local stops database. Use the stops management tools to load data first.',
                sources: [DebugDataSource.localDb],
              ),
            ]
          : const [],
    );
  }
}
