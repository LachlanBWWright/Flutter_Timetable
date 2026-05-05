import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../services/trip_line_service.dart';
import '../utils/button_styles.dart';
import 'selected_stops/selected_stops_helpers.dart';
import 'selected_stops/selected_stops_parts.dart';
import 'station_widgets.dart';

class SelectedStopsWidget extends StatelessWidget {
  const SelectedStopsWidget({
    super.key,
    required this.origin,
    required this.destination,
    required this.currentMode,
    required this.originMode,
    required this.destinationMode,
    required this.isDirectTripMode,
    required this.isLoadingLineCandidates,
    required this.originLineCandidates,
    required this.onDirectTripModeChanged,
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
  final TransportMode? originMode;
  final TransportMode? destinationMode;
  final bool isDirectTripMode;
  final bool isLoadingLineCandidates;
  final List<StopLineMatch> originLineCandidates;
  final ValueChanged<bool>? onDirectTripModeChanged;
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

  @override
  Widget build(BuildContext context) {
    if (origin == null && destination == null) {
      return const SizedBox.shrink();
    }

    final accentMode = resolveAccentMode(
      fallbackMode: currentMode,
      selectedLine: selectedLine,
    );
    final accentColor = TransportColors.getColorByTransportMode(accentMode);
    final originColor = TransportColors.getColorByTransportMode(
      originMode ?? accentMode,
    );
    final destinationColor = TransportColors.getColorByTransportMode(
      destinationMode ?? accentMode,
    );

    final orderedStops = buildOrderedStops(
      origin: origin,
      destination: destination,
      interchanges: interchanges,
    );
    final sequenceDescriptors = buildSequenceDescriptors(
      orderedStops: orderedStops,
      interchangeCount: interchanges.length,
    );

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
          _Header(
            isManualBuilderEnabled: isManualBuilderEnabled,
            accentColor: accentColor,
            accentMode: accentMode,
          ),
          const SizedBox(height: 12.0),
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumns = constraints.maxWidth < 520;
              final fromCard = StopCard(
                label: 'From',
                station: origin,
                onClear: onClearOrigin,
                isOrigin: true,
                modeColor: originColor,
              );
              final toCard = StopCard(
                label: 'To',
                station: destination,
                onClear: onClearDestination,
                isOrigin: false,
                modeColor: destinationColor,
              );

              if (useColumns) {
                return Column(
                  children: [fromCard, const SizedBox(height: 8.0), toCard],
                );
              }

              return Row(
                children: [
                  Expanded(child: fromCard),
                  const SizedBox(width: 12.0),
                  Expanded(child: toCard),
                ],
              );
            },
          ),
          if (!isManualBuilderEnabled &&
              origin != null &&
              destination == null) ...[
            const SizedBox(height: 12.0),
            _DestinationModeSelector(
              isDirectTripMode: isDirectTripMode,
              isLoadingLineCandidates: isLoadingLineCandidates,
              lineCount: originLineCandidates.length,
              onChanged: onDirectTripModeChanged,
              accentColor: accentColor,
            ),
          ],
          if (isResolvingSharedLines) ...[
            const SizedBox(height: 12.0),
            const LinearProgressIndicator(),
          ],
          if (sharedLines.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            _SharedLineChips(
              sharedLines: sharedLines,
              selectedLine: selectedLine,
              onLineSelected: onLineSelected,
            ),
          ],
          if (statusMessage != null) ...[
            const SizedBox(height: 12.0),
            _StatusCard(message: statusMessage ?? '', accentColor: accentColor),
          ],
          if (!isManualBuilderEnabled) ...[
            const SizedBox(height: 12.0),
            DirectTripActions(
              canSaveDirect: canSaveDirect,
              sharedLines: sharedLines,
              onSaveDirect: onSaveDirect,
              onStartManualBuilder: onStartManualBuilder,
              accentColor: accentColor,
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
            StopSequenceSection(
              descriptors: sequenceDescriptors,
              accentColor: accentColor,
              pendingInterchangeInsertIndex: pendingInterchangeInsertIndex,
              onAddInterchange: onAddInterchange,
              onRemoveInterchange: onRemoveInterchange,
              onMoveInterchange: onMoveInterchange,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Derived Legs',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            DerivedLegsSection(
              origin: origin,
              destination: destination,
              interchanges: interchanges,
              selectedLine: selectedLine,
              accentColor: accentColor,
            ),
            if (manualValidationMessage != null) ...[
              const SizedBox(height: 12.0),
              Text(
                manualValidationMessage ?? '',
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
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isManualBuilderEnabled,
    required this.accentColor,
    required this.accentMode,
  });

  final bool isManualBuilderEnabled;
  final Color accentColor;
  final TransportMode accentMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            modeIconForTransportMode(accentMode),
            color: Colors.white,
            size: 20.0,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            isManualBuilderEnabled ? 'Trip Composer' : 'Selected Stops',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _SharedLineChips extends StatelessWidget {
  const _SharedLineChips({
    required this.sharedLines,
    required this.selectedLine,
    required this.onLineSelected,
  });

  final List<StopLineMatch> sharedLines;
  final StopLineMatch? selectedLine;
  final ValueChanged<StopLineMatch> onLineSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shared Line', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: sharedLines
              .map(
                (line) => ChoiceChip(
                  label: Text(line.lineName),
                  selected: selectedLine?.lineId == line.lineId,
                  onSelected: (_) => onLineSelected(line),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DestinationModeSelector extends StatelessWidget {
  const _DestinationModeSelector({
    required this.isDirectTripMode,
    required this.isLoadingLineCandidates,
    required this.lineCount,
    required this.onChanged,
    required this.accentColor,
  });

  final bool isDirectTripMode;
  final bool isLoadingLineCandidates;
  final int lineCount;
  final ValueChanged<bool>? onChanged;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final message = isDirectTripMode
        ? 'Direct trip: choose any stop.'
        : isLoadingLineCandidates
        ? 'Finding stops on the same line...'
        : lineCount == 0
        ? 'No line match is available. Enable direct trip to choose any stop.'
        : 'Showing stops on $lineCount matching line${lineCount == 1 ? '' : 's'}.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.alt_route, color: accentColor, size: 20.0),
          const SizedBox(width: 8.0),
          Expanded(child: Text(message)),
          const SizedBox(width: 8.0),
          Switch(value: isDirectTripMode, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.message, required this.accentColor});

  final String message;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Text(message),
    );
  }
}
