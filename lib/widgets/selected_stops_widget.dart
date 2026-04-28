import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../services/new_trip_service.dart';
import '../services/trip_line_service.dart';
import '../utils/button_styles.dart';
import 'station_widgets.dart';

class SelectedStopsWidget extends StatelessWidget {
  const SelectedStopsWidget({
    super.key,
    required this.origin,
    required this.destination,
    required this.currentMode,
    required this.sharedLines,
    required this.selectedLine,
    required this.interchanges,
    required this.isResolvingSharedLines,
    required this.isManualBuilderEnabled,
    required this.pendingInterchangeInsertIndex,
    required this.statusMessage,
    required this.manualValidationMessage,
    required this.onClearOrigin,
    required this.onClearDestination,
    required this.onLineSelected,
    required this.onSaveDirect,
    this.onStartManualBuilder,
    this.onCancelManualBuilder,
    this.onSaveManual,
    required this.onAddInterchange,
    required this.onRemoveInterchange,
    required this.onMoveInterchange,
    required this.canSaveDirect,
    required this.canSaveManual,
  });

  final Station? origin;
  final Station? destination;
  final TransportMode currentMode;
  final List<StopLineMatch> sharedLines;
  final StopLineMatch? selectedLine;
  final List<Station> interchanges;
  final bool isResolvingSharedLines;
  final bool isManualBuilderEnabled;
  final int? pendingInterchangeInsertIndex;
  final String? statusMessage;
  final String? manualValidationMessage;
  final VoidCallback onClearOrigin;
  final VoidCallback onClearDestination;
  final ValueChanged<StopLineMatch> onLineSelected;
  final VoidCallback onSaveDirect;
  final VoidCallback? onStartManualBuilder;
  final VoidCallback? onCancelManualBuilder;
  final VoidCallback? onSaveManual;
  final void Function(int insertIndex) onAddInterchange;
  final void Function(int interchangeIndex) onRemoveInterchange;
  final void Function(int interchangeIndex, int delta) onMoveInterchange;
  final bool canSaveDirect;
  final bool canSaveManual;

  TransportMode get _accentMode => selectedLine?.mode ?? currentMode;

  List<Station> get _orderedStops {
    final currentOrigin = origin;
    final currentDestination = destination;
    if (currentOrigin == null || currentDestination == null) {
      return const [];
    }

    return NewTripService.buildOrderedTripStops(
      origin: currentOrigin,
      destination: currentDestination,
      interchanges: interchanges,
    );
  }

  Color _accentColor() {
    return TransportColors.getColorByTransportMode(_accentMode);
  }

  IconData _modeIcon() {
    switch (_accentMode) {
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

  @override
  Widget build(BuildContext context) {
    if (origin == null && destination == null) {
      return const SizedBox.shrink();
    }

    final accentColor = _accentColor();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: accentColor, width: 3.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(_modeIcon(), color: Colors.white, size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  isManualBuilderEnabled ? 'Trip Composer' : 'Selected Stops',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: _buildStopCard(
                  context: context,
                  label: 'From',
                  station: origin,
                  onClear: onClearOrigin,
                  isOrigin: true,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildStopCard(
                  context: context,
                  label: 'To',
                  station: destination,
                  onClear: onClearDestination,
                  isOrigin: false,
                ),
              ),
            ],
          ),
          if (isResolvingSharedLines) ...[
            const SizedBox(height: 12.0),
            const LinearProgressIndicator(),
          ],
          if (sharedLines.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Text('Shared Line', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: sharedLines.map((line) {
                return ChoiceChip(
                  label: Text(line.lineName),
                  selected: selectedLine?.lineId == line.lineId,
                  onSelected: (_) => onLineSelected(line),
                );
              }).toList(),
            ),
          ],
          if (statusMessage != null) ...[
            const SizedBox(height: 12.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: accentColor.withValues(alpha: 0.2)),
              ),
              child: Text(statusMessage!),
            ),
          ],
          if (!isManualBuilderEnabled) ...[
            const SizedBox(height: 12.0),
            Wrap(
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
            ),
          ],
          if (isManualBuilderEnabled) ...[
            const SizedBox(height: 16.0),
            Text(
              'Stop Sequence',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ..._buildStopSequence(context, accentColor),
            const SizedBox(height: 16.0),
            Text(
              'Derived Legs',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ..._buildDerivedLegs(context, accentColor),
            if (manualValidationMessage != null) ...[
              const SizedBox(height: 12.0),
              Text(
                manualValidationMessage!,
                style: TextStyle(color: Colors.orange.shade300),
              ),
            ],
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                OutlinedButton.icon(
                  onPressed: onCancelManualBuilder,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel Manual Builder'),
                ),
                ElevatedButton.icon(
                  onPressed: canSaveManual ? onSaveManual : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Manual Trip'),
                  style: ButtonStyles.elevated(accentColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildStopSequence(BuildContext context, Color accentColor) {
    final orderedStops = _orderedStops;
    if (orderedStops.isEmpty) {
      return const [SizedBox.shrink()];
    }

    final widgets = <Widget>[];
    for (var index = 0; index < orderedStops.length; index++) {
      final stop = orderedStops[index];
      final isOrigin = index == 0;
      final isDestination = index == orderedStops.length - 1;
      final interchangeIndex = index - 1;
      final isInterchange = !isOrigin && !isDestination;
      final canMoveUp = interchangeIndex > 0;
      final canMoveDown =
          interchangeIndex >= 0 && interchangeIndex < interchanges.length - 1;

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
              Icon(
                isOrigin
                    ? Icons.play_arrow
                    : isDestination
                    ? Icons.stop
                    : Icons.swap_horiz,
                color: accentColor,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOrigin
                          ? 'Origin'
                          : isDestination
                          ? 'Destination'
                          : 'Interchange ${interchangeIndex + 1}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      stop.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (isInterchange) ...[
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
            ],
          ),
        ),
      );

      if (index < orderedStops.length - 1) {
        final insertIndex = index + 1;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => onAddInterchange(insertIndex),
                icon: Icon(
                  pendingInterchangeInsertIndex == insertIndex
                      ? Icons.radio_button_checked
                      : Icons.add_circle_outline,
                ),
                label: Text(
                  pendingInterchangeInsertIndex == insertIndex
                      ? 'Selecting interchange here'
                      : 'Add interchange here',
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> _buildDerivedLegs(BuildContext context, Color accentColor) {
    final currentOrigin = origin;
    final currentDestination = destination;
    final line = selectedLine;
    if (currentOrigin == null || currentDestination == null || line == null) {
      return const [SizedBox.shrink()];
    }

    final legs = NewTripService.buildManualTripLegs(
      origin: currentOrigin,
      destination: currentDestination,
      interchanges: interchanges,
      selectedLine: line,
    );

    return legs.map((leg) {
      return Card(
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
      );
    }).toList();
  }

  Widget _buildStopCard({
    required BuildContext context,
    required String label,
    required Station? station,
    required VoidCallback onClear,
    required bool isOrigin,
  }) {
    final modeColor = station?.lineId != null
        ? _accentColor()
        : TransportColors.getColorByTransportMode(_accentMode);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: station == null
              ? Colors.grey.withValues(alpha: 0.3)
              : modeColor.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: station == null
            ? Colors.grey.withValues(alpha: 0.05)
            : modeColor.withValues(alpha: 0.05),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOrigin ? Icons.radio_button_checked : Icons.location_on,
                color: station == null ? Colors.grey : modeColor,
                size: 16.0,
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: station == null ? Colors.grey : modeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (station != null)
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
            station?.name ?? 'Select ${label.toLowerCase()} stop',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: station == null ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
