import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';

class DebugSectionCard extends StatelessWidget {
  final String title;
  final List<DebugDataSource> sources;
  final Widget child;

  const DebugSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.sources = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sources
                    .map(
                      (source) => Chip(
                        label: Text(source.label),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
