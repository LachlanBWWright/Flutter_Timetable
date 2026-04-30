import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/debug_navigation.dart';
import 'package:lbww_flutter/debug/widgets/debug_entity_page.dart';

class DebugEntityScreen extends StatelessWidget {
  final DebugNavigationArgs args;

  const DebugEntityScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: args.loader(args.request),
      builder: (context, snapshot) {
        final title = args.request.entityType.label;
        return Scaffold(
          appBar: AppBar(title: Text('$title Debug')),
          body: switch (snapshot.connectionState) {
            ConnectionState.waiting || ConnectionState.active => const Center(
              child: CircularProgressIndicator(),
            ),
            _ when snapshot.hasError => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load debug page: ${snapshot.error}'),
              ),
            ),
            _ when snapshot.hasData => DebugEntityPage(
              pageData: snapshot.data!,
            ),
            _ => const Center(child: Text('No debug data available.')),
          },
        );
      },
    );
  }
}
