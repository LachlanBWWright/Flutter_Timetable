import 'package:flutter/material.dart';

import 'selected_stops_helpers.dart';

class StopSequenceSection extends StatelessWidget {
  const StopSequenceSection({
    super.key,
    required this.descriptors,
    required this.accentColor,
    required this.allowAddingInterchanges,
    required this.pendingInterchangeInsertIndex,
    required this.onAddInterchange,
    required this.onRemoveInterchange,
    required this.onMoveInterchange,
  });

  final List<SequenceStopDescriptor> descriptors;
  final Color accentColor;
  final bool allowAddingInterchanges;
  final int? pendingInterchangeInsertIndex;
  final void Function(int insertIndex) onAddInterchange;
  final void Function(int interchangeIndex) onRemoveInterchange;
  final void Function(int interchangeIndex, int delta) onMoveInterchange;

  IconData _iconForKind(SequenceStopKind kind) {
    switch (kind) {
      case SequenceStopKind.origin:
        return Icons.play_arrow;
      case SequenceStopKind.destination:
        return Icons.stop;
      case SequenceStopKind.interchange:
        return Icons.swap_horiz;
    }
  }

  void _addInterchangeAt(int insertIndex) {
    try {
      onAddInterchange.call(insertIndex);
    } catch (_) {}
  }

  void _removeInterchangeAt(int interchangeIndex) {
    try {
      onRemoveInterchange.call(interchangeIndex);
    } catch (_) {}
  }

  void _moveInterchangeBy(int interchangeIndex, int delta) {
    try {
      onMoveInterchange.call(interchangeIndex, delta);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (descriptors.isEmpty) {
      return const SizedBox.shrink();
    }

    final widgets = <Widget>[];

    for (final (index, descriptor) in descriptors.indexed) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(12.0),
            color: accentColor.withValues(alpha: 0.04),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconForKind(descriptor.kind), color: accentColor),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      descriptor.kindLabel,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      descriptor.stop.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (descriptor.isInterchange &&
                  descriptor.interchangeIndex != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _InterchangeActions(
                    interchangeIndex: descriptor.interchangeIndex ?? 0,
                    canMoveUp: descriptor.canMoveUp,
                    canMoveDown: descriptor.canMoveDown,
                    onMoveInterchange: _moveInterchangeBy,
                    onRemoveInterchange: _removeInterchangeAt,
                  ),
                ),
            ],
          ),
        ),
      );

      if (allowAddingInterchanges && index < descriptors.length - 1) {
        final insertIndex = descriptor.insertIndex;
        final isPending = pendingInterchangeInsertIndex == insertIndex;
        widgets.add(
          _AddStopButton(
            insertIndex: insertIndex,
            label: 'Add leg here',
            isPending: isPending,
            onAddInterchange: _addInterchangeAt,
          ),
        );
      }
    }

    return Column(children: widgets);
  }
}

class _AddStopButton extends StatelessWidget {
  const _AddStopButton({
    required this.insertIndex,
    required this.label,
    required this.isPending,
    required this.onAddInterchange,
  });

  final int insertIndex;
  final String label;
  final bool isPending;
  final void Function(int insertIndex) onAddInterchange;

  void _handlePressed() {
    try {
      onAddInterchange.call(insertIndex);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Tooltip(
          message: isPending ? 'Selecting stop here' : label,
          child: TextButton.icon(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: _handlePressed,
            icon: Icon(
              isPending ? Icons.radio_button_checked : Icons.add_circle_outline,
            ),
            label: Text(isPending ? 'Selecting stop here' : label),
          ),
        ),
      ),
    );
  }
}

class _InterchangeActions extends StatelessWidget {
  const _InterchangeActions({
    required this.interchangeIndex,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveInterchange,
    required this.onRemoveInterchange,
  });

  final int interchangeIndex;
  final bool canMoveUp;
  final bool canMoveDown;
  final void Function(int interchangeIndex, int delta) onMoveInterchange;
  final void Function(int interchangeIndex) onRemoveInterchange;

  void _moveUp() {
    try {
      onMoveInterchange.call(interchangeIndex, -1);
    } catch (_) {}
  }

  void _moveDown() {
    try {
      onMoveInterchange.call(interchangeIndex, 1);
    } catch (_) {}
  }

  void _remove() {
    try {
      onRemoveInterchange.call(interchangeIndex);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.0,
      runSpacing: 2.0,
      children: [
        IconButton(
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          tooltip: 'Move interchange up',
          onPressed: canMoveUp ? _moveUp : null,
          icon: const Icon(Icons.arrow_upward),
        ),
        IconButton(
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          tooltip: 'Move interchange down',
          onPressed: canMoveDown ? _moveDown : null,
          icon: const Icon(Icons.arrow_downward),
        ),
        IconButton(
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          tooltip: 'Remove interchange',
          onPressed: _remove,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
