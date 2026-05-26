import 'package:flutter/material.dart';

import '../../constants/transport_modes.dart';
import '../../services/new_trip_service.dart';
import '../station_widgets.dart';
import 'selected_stops_helpers.dart';

class StopCard extends StatelessWidget {
  const StopCard({
    super.key,
    required this.label,
    required this.station,
    required this.onClear,
    required this.isOrigin,
    required this.modeColor,
  });

  final String label;
  final Station? station;
  final VoidCallback onClear;
  final bool isOrigin;
  final Color modeColor;

  @override
  Widget build(BuildContext context) {
    final currentStation = station;
    final borderColor = currentStation == null
        ? Colors.grey.withValues(alpha: 0.3)
        : modeColor.withValues(alpha: 0.3);
    final backgroundColor = currentStation == null
        ? Colors.grey.withValues(alpha: 0.05)
        : modeColor.withValues(alpha: 0.05);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8.0),
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOrigin ? Icons.radio_button_checked : Icons.location_on,
                color: currentStation == null ? Colors.grey : modeColor,
                size: 16.0,
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: currentStation == null ? Colors.grey : modeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (currentStation != null)
                GestureDetector(
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.close,
                      size: 14.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            currentStation?.name ?? 'Select ${label.toLowerCase()} stop',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: currentStation == null
                  ? FontWeight.normal
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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
      onAddInterchange(insertIndex);
    } catch (_) {}
  }

  void _removeInterchangeAt(int interchangeIndex) {
    try {
      onRemoveInterchange(interchangeIndex);
    } catch (_) {}
  }

  void _moveInterchangeBy(int interchangeIndex, int delta) {
    try {
      onMoveInterchange(interchangeIndex, delta);
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
      onAddInterchange(insertIndex);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _handlePressed,
          icon: Icon(
            isPending ? Icons.radio_button_checked : Icons.add_circle_outline,
          ),
          label: Text(isPending ? 'Selecting stop here' : label),
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
      onMoveInterchange(interchangeIndex, -1);
    } catch (_) {}
  }

  void _moveDown() {
    try {
      onMoveInterchange(interchangeIndex, 1);
    } catch (_) {}
  }

  void _remove() {
    try {
      onRemoveInterchange(interchangeIndex);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.0,
      runSpacing: 2.0,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          onPressed: canMoveUp ? _moveUp : null,
          icon: const Icon(Icons.arrow_upward),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          onPressed: canMoveDown ? _moveDown : null,
          icon: const Icon(Icons.arrow_downward),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          onPressed: _remove,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

class DerivedLegsSection extends StatelessWidget {
  const DerivedLegsSection({
    super.key,
    required this.origin,
    required this.destination,
    required this.interchanges,
    required this.fallbackMode,
    required this.accentColor,
  });

  final Station? origin;
  final Station? destination;
  final List<Station> interchanges;
  final TransportMode fallbackMode;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final currentOrigin = origin;
    final currentDestination = destination;

    if (currentOrigin == null || currentDestination == null) {
      return const SizedBox.shrink();
    }

    final legs = NewTripService.buildManualTripLegs(
      origin: currentOrigin,
      destination: currentDestination,
      interchanges: interchanges,
      fallbackMode: fallbackMode,
    );

    if (legs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: legs
          .map(
            (leg) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8.0),
                color: accentColor.withValues(alpha: 0.04),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14.0,
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    child: Text('${leg.index + 1}'),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${leg.originName} to ${leg.destinationName}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${leg.mode.displayName} - ${leg.lineName ?? 'Service not selected'}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

IconData modeIconForTransportMode(TransportMode mode) {
  switch (mode) {
    case TransportMode.train:
      return Icons.directions_train;
    case TransportMode.lightrail:
      return Icons.tram;
    case TransportMode.bus:
      return Icons.directions_bus;
    case TransportMode.ferry:
      return Icons.directions_ferry;
    case TransportMode.metro:
      return Icons.subway;
  }
}
