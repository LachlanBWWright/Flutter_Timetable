import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';

typedef DebugEntityListPageLoader =
    Future<DebugEntityListPageData> Function(DebugEntityType entityType);

enum DebugEntityListSort {
  titleAsc,
  titleDesc,
  idAsc,
  idDesc,
  recentFirst,
  recentLast,
}

extension DebugEntityListSortX on DebugEntityListSort {
  String get label {
    switch (this) {
      case DebugEntityListSort.titleAsc:
        return 'Title A-Z';
      case DebugEntityListSort.titleDesc:
        return 'Title Z-A';
      case DebugEntityListSort.idAsc:
        return 'ID A-Z';
      case DebugEntityListSort.idDesc:
        return 'ID Z-A';
      case DebugEntityListSort.recentFirst:
        return 'Newest first';
      case DebugEntityListSort.recentLast:
        return 'Oldest first';
    }
  }
}

class DebugEntityListFilterOption {
  final String id;
  final String label;
  final int count;

  const DebugEntityListFilterOption({
    required this.id,
    required this.label,
    required this.count,
  });
}

class DebugEntityListFilterGroup {
  final String key;
  final String label;
  final List<DebugEntityListFilterOption> options;

  const DebugEntityListFilterGroup({
    required this.key,
    required this.label,
    required this.options,
  });
}

class DebugEntityListItem {
  final DebugEntityType entityType;
  final String entityId;
  final String title;
  final String? subtitle;
  final String? description;
  final List<DebugDataSource> sources;
  final Map<String, List<String>> filterValues;
  final List<String> searchTerms;
  final DateTime? timestamp;
  final DebugEntityRequest request;

  const DebugEntityListItem({
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.request,
    this.subtitle,
    this.description,
    this.sources = const [],
    this.filterValues = const {},
    this.searchTerms = const [],
    this.timestamp,
  });
}

class DebugEntityListPageData {
  final DebugEntityType entityType;
  final String title;
  final String description;
  final String emptyMessage;
  final List<DebugDataSource> sourceBadges;
  final List<DebugStatusBannerData> banners;
  final List<DebugEntityListFilterGroup> filterGroups;
  final List<DebugEntityListSort> sortOptions;
  final DebugEntityListSort defaultSort;
  final List<DebugEntityListItem> items;

  const DebugEntityListPageData({
    required this.entityType,
    required this.title,
    required this.description,
    required this.emptyMessage,
    required this.items,
    this.sourceBadges = const [],
    this.banners = const [],
    this.filterGroups = const [],
    this.sortOptions = const [
      DebugEntityListSort.titleAsc,
      DebugEntityListSort.idAsc,
    ],
    this.defaultSort = DebugEntityListSort.titleAsc,
  });
}
