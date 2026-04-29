import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/debug/widgets/debug_raw_json_card.dart';
import 'package:lbww_flutter/debug/widgets/debug_reference_tile.dart';
import 'package:lbww_flutter/debug/widgets/debug_section_card.dart';
import 'package:lbww_flutter/debug/widgets/debug_status_banner.dart';

class DebugEntityPage extends StatelessWidget {
  final DebugPageData pageData;

  const DebugEntityPage({super.key, required this.pageData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(pageData: pageData),
        if (pageData.banners.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...pageData.banners.map(
            (banner) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DebugStatusBanner(banner: banner),
            ),
          ),
        ],
        for (final section in pageData.sections) ...[
          const SizedBox(height: 16),
          if (section.rawJsonBlocks.isNotEmpty &&
              section.fields.isEmpty &&
              section.references.isEmpty)
            ...section.rawJsonBlocks.map(
              (block) => DebugRawJsonCard(block: block),
            )
          else
            DebugSectionCard(
              title: section.title,
              sources: section.sources,
              child: _buildSectionBody(context, section),
            ),
        ],
      ],
    );
  }

  Widget _buildSectionBody(BuildContext context, DebugSectionData section) {
    if (section.isEmpty) {
      return Text(section.emptyMessage ?? 'No data available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.fields.isNotEmpty)
          ...section.fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FieldRow(field: field),
            ),
          ),
        if (section.references.isNotEmpty) ...[
          if (section.fields.isNotEmpty) const Divider(height: 24),
          ...section.references.map(
            (reference) => DebugReferenceTile(reference: reference),
          ),
        ],
        if (section.rawJsonBlocks.isNotEmpty) ...[
          if (section.fields.isNotEmpty || section.references.isNotEmpty)
            const SizedBox(height: 8),
          ...section.rawJsonBlocks.map(
            (block) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _InlineRawJsonBlock(block: block),
            ),
          ),
        ],
      ],
    );
  }
}

class _InlineRawJsonBlock extends StatelessWidget {
  final DebugJsonBlock block;

  const _InlineRawJsonBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(block.title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            _format(block.data, block.emptyMessage),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _format(Object? data, String emptyMessage) {
    if (data == null) {
      return emptyMessage;
    }
    if (data is String) {
      return data;
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final DebugPageData pageData;

  const _HeaderCard({required this.pageData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pageData.entityType.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              pageData.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(pageData.canonicalId),
            if (pageData.aliases.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Aliases: ${pageData.aliases.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (pageData.sourceBadges.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pageData.sourceBadges
                    .map(
                      (source) => Chip(
                        label: Text(source.label),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final DebugFieldRow field;

  const _FieldRow({required this.field});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                field.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (field.badge != null)
              Chip(
                label: Text(field.badge!),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 4),
        SelectableText(field.value),
        if (field.sources.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: field.sources
                .map(
                  (source) => Chip(
                    label: Text(source.label),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
