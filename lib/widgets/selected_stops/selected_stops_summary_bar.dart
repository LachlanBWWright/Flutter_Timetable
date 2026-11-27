import 'package:flutter/material.dart';

import '../../constants/transport_colors.dart';
import '../../constants/transport_modes.dart';
import '../../services/trip_line_service.dart';
import '../../utils/button_styles.dart';
import '../station_widgets.dart';
import 'selected_stops_helpers.dart';

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
      constraints: const BoxConstraints(minHeight: 48.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
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
              tooltip: 'Clear ${label.toLowerCase()} stop: ${station!.name}',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(
                width: 48.0,
                height: 48.0,
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
