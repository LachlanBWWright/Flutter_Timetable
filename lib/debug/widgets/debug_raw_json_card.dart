import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lbww_flutter/debug/debug_entity_models.dart';
import 'package:lbww_flutter/debug/widgets/debug_section_card.dart';

class DebugRawJsonCard extends StatelessWidget {
  final DebugJsonBlock block;

  const DebugRawJsonCard({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return DebugSectionCard(
      title: block.title,
      sources: block.sources,
      child: Container(
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
