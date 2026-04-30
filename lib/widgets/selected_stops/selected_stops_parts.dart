import 'package:flutter/material.dart';

import '../../constants/transport_modes.dart';
import '../../services/new_trip_service.dart';
import '../../services/trip_line_service.dart';
import '../../utils/button_styles.dart';
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

class DirectTripActions extends StatelessWidget {
  const DirectTripActions({
    super.key,
    required this.canSaveDirect,
    required this.sharedLines,
    required this.onSaveDirect,
    this.onStartManualBuilder,
    required this.accentColor,
  });

  final bool canSaveDirect;
  final List<StopLineMatch> sharedLines;
  final VoidCallback onSaveDirect;
  final VoidCallback? onStartManualBuilder;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        if (canSaveDirect)
          ElevatedButton.icon(
            onPressed: onSaveDirect,
            icon: const Icon(Icons.save),
            label: const Text('Save Direct Trip'),
            style: ButtonStyles.elevated(accentColor),
          ),
        if (sharedLines.isNotEmpty && onStartManualBuilder != null)
          OutlinedButton.icon(
            onPressed: onStartManualBuilder,
            icon: const Icon(Icons.alt_route),
            label: const Text('Build Multi-Leg Trip'),
          ),
      ],
    );
  }
}

class StopSequenceSection extends StatelessWidget {
  const StopSequenceSection({
    super.key,
    required this.descriptors,
    required this.accentColor,
    required this.pendingInterchangeInsertIndex,
    required this.onAddInterchange,
    required this.onRemoveInterchange,
    required this.onMoveInterchange,
  });

  final List<SequenceStopDescriptor> descriptors;
  final Color accentColor;
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

  @override
  Widget build(BuildContext context) {
    if (descriptors.isEmpty) {
      return const SizedBox.shrink();
    }

    final widgets = <Widget>[];
    for (var index = 0; index < descriptors.length; index++) {
      final descriptor = descriptors[index];
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
                _InterchangeActions(
                  interchangeIndex: descriptor.interchangeIndex!,
                  canMoveUp: descriptor.canMoveUp,
                  canMoveDown: descriptor.canMoveDown,
                  onMoveInterchange: onMoveInterchange,
                  onRemoveInterchange: onRemoveInterchange,
                ),
            ],
          ),
        ),
      );

      if (index < descriptors.length - 1) {
        final insertIndex = descriptor.insertIndex;
        final isPending = pendingInterchangeInsertIndex == insertIndex;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => onAddInterchange(insertIndex),
                icon: Icon(
                  isPending
                      ? Icons.radio_button_checked
                      : Icons.add_circle_outline,
                ),
                label: Text(
                  isPending
                      ? 'Selecting interchange here'
                      : 'Add interchange here',
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(children: widgets);
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: canMoveUp
              ? () => onMoveInterchange(interchangeIndex, -1)
              : null,
          icon: const Icon(Icons.arrow_upward),
        ),
        IconButton(
          onPressed: canMoveDown
              ? () => onMoveInterchange(interchangeIndex, 1)
              : null,
          icon: const Icon(Icons.arrow_downward),
        ),
        IconButton(
          onPressed: () => onRemoveInterchange(interchangeIndex),
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
    required this.selectedLine,
    required this.accentColor,
  });

  final Station? origin;
  final Station? destination;
  final List<Station> interchanges;
  final StopLineMatch? selectedLine;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final currentOrigin = origin;
    final currentDestination = destination;
    final line = selectedLine;

    if (currentOrigin == null || currentDestination == null || line == null) {
      return const SizedBox.shrink();
    }

    final legs = NewTripService.buildManualTripLegs(
      origin: currentOrigin,
      destination: currentDestination,
      interchanges: interchanges,
      selectedLine: line,
    );

    if (legs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: legs
          .map(
            (leg) => Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  child: Text('${leg.index + 1}'),
                ),
                title: Text('${leg.originName} to ${leg.destinationName}'),
                subtitle: Text('${line.mode.displayName} • ${leg.lineName}'),
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
