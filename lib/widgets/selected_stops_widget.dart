import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';
import '../services/trip_line_service.dart';
import '../utils/button_styles.dart';
import 'selected_stops/selected_stops_controls.dart';
import 'selected_stops/selected_stops_helpers.dart';
import 'selected_stops/selected_stops_parts.dart';
import 'station_widgets.dart';

export 'selected_stops/selected_stops_summary_bar.dart';

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
              SelectedStopsHeader(
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
                SameLineFilterToggle(
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
                SelectedStopsStatusCard(
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
