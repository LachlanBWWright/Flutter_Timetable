import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_list_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';

import 'entity_list/entity_list_view.dart';

class DebugEntityListScreen extends StatefulWidget {
  final DebugBrowserNavigationArgs args;

  const DebugEntityListScreen({super.key, required this.args});

  @override
  State<DebugEntityListScreen> createState() => _DebugEntityListScreenState();
}

class _DebugEntityListScreenState extends State<DebugEntityListScreen> {
  late final Future<DebugEntityListPageData> _pageFuture = _loadPage();

  Future<DebugEntityListPageData> _loadPage() async {
    final DebugEntityListPageLoader listLoader = widget.args.listLoader;
    try {
      return await listLoader.call(widget.args.entityType);
    } catch (_) {
      return DebugEntityListPageData(
        entityType: widget.args.entityType,
        title: '${widget.args.entityType.label} Browser',
        description: 'Failed to load debug browser data.',
        emptyMessage: 'No debug list data available.',
        items: const <DebugEntityListItem>[],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = '${widget.args.entityType.label} Browser';
    return FutureBuilder<DebugEntityListPageData>(
      future: _pageFuture,
      builder: (context, snapshot) {
        final pageData = snapshot.data;
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
            _ when snapshot.hasData && pageData != null => DebugEntityListView(
              pageData: pageData,
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
