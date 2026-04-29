import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/debug/widgets/debug_status_banner.dart';

class DebugEntityListScreen extends StatefulWidget {
  final DebugBrowserNavigationArgs args;

  const DebugEntityListScreen({super.key, required this.args});

  @override
  State<DebugEntityListScreen> createState() => _DebugEntityListScreenState();
}

class _DebugEntityListScreenState extends State<DebugEntityListScreen> {
  late final Future<DebugEntityListPageData> _pageFuture = widget.args
      .listLoader(widget.args.entityType);

  @override
  Widget build(BuildContext context) {
    final title = '${widget.args.entityType.label} Browser';
    return FutureBuilder<DebugEntityListPageData>(
      future: _pageFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: switch (snapshot.connectionState) {
            ConnectionState.waiting || ConnectionState.active => const Center(
              child: CircularProgressIndicator(),
            ),
            _ when snapshot.hasError => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load debug browser: ${snapshot.error}'),
              ),
            ),
            _ when snapshot.hasData => _DebugEntityListView(
              pageData: snapshot.data!,
              pageLoader: widget.args.pageLoader,
              initialSearchQuery: widget.args.initialSearchQuery,
              initialFilters: widget.args.initialFilters,
            ),
            _ => const Center(child: Text('No debug list data available.')),
          },
        );
      },
    );
  }
}

class _DebugEntityListView extends StatefulWidget {
  final DebugEntityListPageData pageData;
  final DebugEntityPageLoader pageLoader;
  final String? initialSearchQuery;
  final Map<String, String> initialFilters;

  const _DebugEntityListView({
    required this.pageData,
    required this.pageLoader,
    this.initialSearchQuery,
    this.initialFilters = const {},
  });

  @override
  State<_DebugEntityListView> createState() => _DebugEntityListViewState();
}

class _DebugEntityListViewState extends State<_DebugEntityListView> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialSearchQuery ?? '',
  );
  late DebugEntityListSort _selectedSort = widget.pageData.defaultSort;
  late final Map<String, String?> _selectedFilters = {
    for (final group in widget.pageData.filterGroups)
      group.key: _initialFilterValueFor(group),
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _initialFilterValueFor(DebugEntityListFilterGroup group) {
    final requestedValue = widget.initialFilters[group.key];
    if (requestedValue == null) {
      return null;
    }
    for (final option in group.options) {
      if (option.id == requestedValue) {
        return requestedValue;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _applyFilters(widget.pageData.items);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pageData.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(widget.pageData.description),
          if (widget.pageData.sourceBadges.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.pageData.sourceBadges
                  .map(
                    (source) => Chip(
                      label: Text(source.label),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (widget.pageData.banners.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...widget.pageData.banners.map(
              (banner) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DebugStatusBanner(banner: banner),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText:
                  'Search ${widget.pageData.entityType.label.toLowerCase()}s',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: DropdownButtonFormField<DebugEntityListSort>(
                  isExpanded: true,
                  key: const ValueKey('debug-list-sort'),
                  initialValue: _selectedSort,
                  decoration: const InputDecoration(
                    labelText: 'Sort',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.pageData.sortOptions
                      .map(
                        (sort) => DropdownMenuItem(
                          value: sort,
                          child: Text(sort.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (sort) {
                    if (sort == null) {
                      return;
                    }
                    setState(() {
                      _selectedSort = sort;
                    });
                  },
                ),
              ),
              ...widget.pageData.filterGroups.map((group) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    key: ValueKey('debug-list-filter-${group.key}'),
                    initialValue: _selectedFilters[group.key],
                    decoration: InputDecoration(
                      labelText: group.label,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...group.options.map(
                        (option) => DropdownMenuItem<String>(
                          value: option.id,
                          child: Text('${option.label} (${option.count})'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilters[group.key] = value;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${visibleItems.length} result${visibleItems.length == 1 ? '' : 's'} of ${widget.pageData.items.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: visibleItems.isEmpty
                ? Center(child: Text(widget.pageData.emptyMessage))
                : ListView.separated(
                    itemCount: visibleItems.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.entityId),
                            if (item.subtitle != null &&
                                item.subtitle!.isNotEmpty)
                              Text(item.subtitle!),
                            if (item.description != null &&
                                item.description!.isNotEmpty)
                              Text(item.description!),
                            if (item.sources.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: item.sources
                                    .map(
                                      (source) => Chip(
                                        label: Text(source.label),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            ],
                          ],
                        ),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () {
                          DebugNavigation.pushEntity(
                            context,
                            request: item.request,
                            loader: widget.pageLoader,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<DebugEntityListItem> _applyFilters(List<DebugEntityListItem> items) {
    final queryTerms = _searchController.text
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList(growable: false);

    final filtered = items
        .where((item) {
          for (final entry in _selectedFilters.entries) {
            final value = entry.value;
            if (value == null) {
              continue;
            }
            final itemValues = item.filterValues[entry.key] ?? const <String>[];
            if (!itemValues.contains(value)) {
              return false;
            }
          }

          if (queryTerms.isEmpty) {
            return true;
          }

          final haystack = [
            item.entityId,
            item.title,
            item.subtitle,
            item.description,
            ...item.searchTerms,
            ...item.filterValues.values.expand((values) => values),
          ].whereType<String>().join(' ').toLowerCase();

          return queryTerms.every(haystack.contains);
        })
        .toList(growable: false);

    filtered.sort((left, right) => _compareItems(left, right));
    return filtered;
  }

  int _compareItems(DebugEntityListItem left, DebugEntityListItem right) {
    switch (_selectedSort) {
      case DebugEntityListSort.titleAsc:
        return left.title.toLowerCase().compareTo(right.title.toLowerCase());
      case DebugEntityListSort.titleDesc:
        return right.title.toLowerCase().compareTo(left.title.toLowerCase());
      case DebugEntityListSort.idAsc:
        return left.entityId.toLowerCase().compareTo(
          right.entityId.toLowerCase(),
        );
      case DebugEntityListSort.idDesc:
        return right.entityId.toLowerCase().compareTo(
          left.entityId.toLowerCase(),
        );
      case DebugEntityListSort.recentFirst:
        return _compareDates(right.timestamp, left.timestamp);
      case DebugEntityListSort.recentLast:
        return _compareDates(left.timestamp, right.timestamp);
    }
  }

  int _compareDates(DateTime? left, DateTime? right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }
    return left.compareTo(right);
  }
}
