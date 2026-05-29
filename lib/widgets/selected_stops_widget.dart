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
    required this.isLoadingLineCandidates,
    required this.originLineCandidates,
    required this.isSameLineFilterEnabled,
    required this.onSameLineFilterChanged,
    required this.selectedLine,
    required this.interchanges,
    required this.isResolvingSharedLines,
    required this.isManualBuilderEnabled,
    required this.pendingInterchangeInsertIndex,
    required this.statusMessage,
    required this.manualValidationMessage,
    required this.onClearOrigin,
    required this.onClearDestination,
    required this.onSaveDirect,
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
  final bool isLoadingLineCandidates;
  final List<StopLineMatch> originLineCandidates;
  final bool isSameLineFilterEnabled;
  final ValueChanged<bool>? onSameLineFilterChanged;
  final StopLineMatch? selectedLine;
  final List<Station> interchanges;
  final bool isResolvingSharedLines;
  final bool isManualBuilderEnabled;
  final int? pendingInterchangeInsertIndex;
  final String? statusMessage;
  final String? manualValidationMessage;
  final VoidCallback onClearOrigin;
  final VoidCallback onClearDestination;
  final VoidCallback onSaveDirect;
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
    final hasInterchanges = interchanges.isNotEmpty;
    final canSaveTrip = hasInterchanges ? canSaveManual : canSaveDirect;
    final onSaveTrip = hasInterchanges ? onSaveManual : onSaveDirect;
    final showSameLineFilter =
        !isManualBuilderEnabled && origin != null && destination == null;

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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        child: SingleChildScrollView(
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
              if (showSameLineFilter) ...[
                const SizedBox(height: 12.0),
                _SameLineFilterToggle(
                  isEnabled: isSameLineFilterEnabled,
                  isLoading: isLoadingLineCandidates,
                  lineCount: originLineCandidates.length,
                  onChanged: onSameLineFilterChanged,
                  accentColor: accentColor,
                ),
              ],
              if (isResolvingSharedLines) ...[
                const SizedBox(height: 12.0),
                const LinearProgressIndicator(),
              ],
              if (statusMessage != null) ...[
                const SizedBox(height: 12.0),
                _StatusCard(
                  message: statusMessage ?? '',
                  accentColor: accentColor,
                ),
              ],
              if (origin != null && destination != null) ...[
                const SizedBox(height: 16.0),
                Text(
                  'Stops',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                StopSequenceSection(
                  descriptors: sequenceDescriptors,
                  accentColor: accentColor,
                  allowAddingInterchanges:
                      isManualBuilderEnabled || hasInterchanges,
                  pendingInterchangeInsertIndex: pendingInterchangeInsertIndex,
                  onAddInterchange: onAddInterchange,
                  onRemoveInterchange: onRemoveInterchange,
                  onMoveInterchange: onMoveInterchange,
                ),
                if (isManualBuilderEnabled) ...[
                  const SizedBox(height: 12.0),
                  DerivedLegsSection(
                    origin: origin,
                    destination: destination,
                    interchanges: interchanges,
                    fallbackMode: currentMode,
                    accentColor: accentColor,
                  ),
                ],
                if (manualValidationMessage != null) ...[
                  const SizedBox(height: 12.0),
                  Text(
                    manualValidationMessage ?? '',
                    style: TextStyle(color: Colors.orange.shade300),
                  ),
                ],
                const SizedBox(height: 12.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canSaveTrip ? onSaveTrip : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Trip'),
                    style: ButtonStyles.elevated(accentColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedStopsSummaryBar extends StatelessWidget {
  const SelectedStopsSummaryBar({
    super.key,
    required this.origin,
    required this.destination,
    required this.currentMode,
    required this.originMode,
    required this.destinationMode,
    required this.selectedLine,
    required this.isLoadingLineCandidates,
    required this.originLineCount,
    required this.statusMessage,
    required this.onClearOrigin,
    required this.onClearDestination,
    required this.onSaveDirect,
    required this.onOpenComposer,
    required this.canSaveDirect,
    required this.canComposeManual,
    this.allowClearing = true,
  });

  final Station? origin;
  final Station? destination;
  final TransportMode currentMode;
  final TransportMode? originMode;
  final TransportMode? destinationMode;
  final StopLineMatch? selectedLine;
  final bool isLoadingLineCandidates;
  final int originLineCount;
  final String? statusMessage;
  final VoidCallback onClearOrigin;
  final VoidCallback onClearDestination;
  final VoidCallback onSaveDirect;
  final VoidCallback onOpenComposer;
  final bool canSaveDirect;
  final bool canComposeManual;
  final bool allowClearing;

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
    final lineMessage = _compactStatusMessage;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: accentColor, width: 3.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final useRows = constraints.maxWidth < 520;
                final from = _CompactStopTile(
                  label: 'From',
                  station: origin,
                  onClear: allowClearing ? onClearOrigin : null,
                  icon: Icons.radio_button_checked,
                  color: originColor,
                );
                final to = _CompactStopTile(
                  label: 'To',
                  station: destination,
                  onClear: allowClearing ? onClearDestination : null,
                  icon: Icons.location_on,
                  color: destinationColor,
                );

                if (useRows) {
                  return Column(
                    children: [from, const SizedBox(height: 6.0), to],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: from),
                    const SizedBox(width: 8.0),
                    Expanded(child: to),
                  ],
                );
              },
            ),
            if (lineMessage != null) ...[
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lineMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (isLoadingLineCandidates) ...[
              const SizedBox(height: 8.0),
              const LinearProgressIndicator(),
            ],
            if (canSaveDirect || canComposeManual) ...[
              const SizedBox(height: 10.0),
              Row(
                children: [
                  if (canComposeManual) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenComposer,
                        icon: const Icon(Icons.edit_location_alt),
                        label: const Text('Edit Stops'),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                  if (canSaveDirect)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSaveDirect,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Trip'),
                        style: ButtonStyles.elevated(accentColor),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? get _compactStatusMessage {
    if (origin != null && destination == null) {
      return 'Choose destination';
    }
    if (destination != null && origin == null) {
      return 'Choose origin';
    }
    if (origin != null && destination != null) {
      if (selectedLine != null) {
        if (canComposeManual) {
          return 'Multi-mode manual trip ready';
        }
        return 'Ready to build on ${selectedLine?.lineName}';
      }
      if (statusMessage?.contains('No shared line found') == true) {
        return canComposeManual
            ? 'Multi-mode manual trip ready'
            : 'No shared line found';
      }
      return canSaveDirect ? 'Ready to save' : statusMessage;
    }
    return statusMessage;
  }
}

class _CompactStopTile extends StatelessWidget {
  const _CompactStopTile({
    required this.label,
    required this.station,
    required this.onClear,
    required this.icon,
    required this.color,
  });

  final String label;
  final Station? station;
  final VoidCallback? onClear;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final selected = station != null;

    return Container(
      constraints: const BoxConstraints(minHeight: 42.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: selected
            ? color.withValues(alpha: 0.06)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: selected
              ? color.withValues(alpha: 0.22)
              : Colors.grey.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.0, color: selected ? color : Colors.grey),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? color : Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              station?.name ?? 'Not selected',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (selected && onClear != null)
            IconButton(
              tooltip: 'Clear $label',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(
                width: 32.0,
                height: 32.0,
              ),
              padding: EdgeInsets.zero,
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 16.0),
            ),
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

class _SameLineFilterToggle extends StatelessWidget {
  const _SameLineFilterToggle({
    required this.isEnabled,
    required this.isLoading,
    required this.lineCount,
    required this.onChanged,
    required this.accentColor,
  });

  final bool isEnabled;
  final bool isLoading;
  final int lineCount;
  final ValueChanged<bool>? onChanged;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final message = isLoading
        ? 'Loading same-line stops...'
        : lineCount == 0
        ? 'No same-line filter available'
        : 'Only show stops on the same line';

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
          Switch(
            value: isEnabled,
            onChanged: isLoading || lineCount == 0 ? null : onChanged,
          ),
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
