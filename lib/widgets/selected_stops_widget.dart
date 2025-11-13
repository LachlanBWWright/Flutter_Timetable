import 'package:flutter/material.dart';
import '../constants/transport_colors.dart';
import '../constants/transport_modes.dart';

/// Widget for displaying selected stops at the bottom of the new trip screen
/// with mode-specific accents and two-column layout
class SelectedStopsWidget extends StatelessWidget {
  final String firstStation;
  final String firstStationId;
  final String secondStation;
  final String secondStationId;
  final TransportMode currentMode;
  final TransportMode? firstMode;
  final TransportMode? secondMode;
  final VoidCallback onClearFirst;
  final VoidCallback onClearSecond;
  final VoidCallback? onConfirm;
  final bool canSave;

  const SelectedStopsWidget({
    super.key,
    required this.firstStation,
    required this.firstStationId,
    required this.secondStation,
    required this.secondStationId,
    required this.currentMode,
    this.firstMode,
    this.secondMode,
    required this.onClearFirst,
    required this.onClearSecond,
    this.onConfirm,
    this.canSave = false,
  });

  Color _getModeColor() {
    return TransportColors.getColorByTransportMode(currentMode);
  }

  Color _getAccentColor() {
    // Determine header/accent color based on selected stop modes and current tab
    final bothSelected = firstStation.isNotEmpty && secondStation.isNotEmpty;

    // Helper to check equality
    bool sameModes(TransportMode? a, TransportMode? b) =>
        a != null && b != null && a == b;

    if (bothSelected) {
      if (sameModes(firstMode, secondMode) && firstMode == currentMode) {
        return TransportColors.getColorByTransportMode(currentMode);
      }
      return Colors.grey;
    }

    // Only one selected
    final selectedMode = firstStation.isNotEmpty
        ? firstMode
        : secondStation.isNotEmpty
            ? secondMode
            : null;
    if (selectedMode != null && selectedMode == currentMode) {
      return TransportColors.getColorByTransportMode(currentMode);
    }

    // Default to current mode color when no selection, otherwise neutral
    if (!bothSelected && selectedMode == null)
      return TransportColors.getColorByTransportMode(currentMode);
    return Colors.grey;
  }

  bool _showHeaderIcon() {
    // Icon shown only when accent color is the current mode color
    final accent = _getAccentColor();
    return accent != Colors.grey;
  }

  IconData _getModeIcon() {
    switch (currentMode) {
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
    final bool hasAnyStop = firstStation.isNotEmpty || secondStation.isNotEmpty;

    if (!hasAnyStop) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: _getAccentColor(),
            width: 3.0,
          ),
        ),
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
        children: [
          // Header with mode icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _getAccentColor(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _showHeaderIcon()
                    ? Icon(
                        _getModeIcon(),
                        color: Colors.white,
                        size: 20.0,
                      )
                    : const SizedBox(width: 20.0, height: 20.0),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Selected Stops',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Two-column layout for stops
          Row(
            children: [
              // First stop (Origin)
              Expanded(
                child: _buildStopCard(
                  context: context,
                  label: 'From',
                  stationName: firstStation,
                  isEmpty: firstStation.isEmpty,
                  onClear: onClearFirst,
                  isOrigin: true,
                  stopMode: firstMode,
                ),
              ),
              const SizedBox(width: 12.0),

              // Second stop (Destination)
              Expanded(
                child: _buildStopCard(
                  context: context,
                  label: 'To',
                  stationName: secondStation,
                  isEmpty: secondStation.isEmpty,
                  onClear: onClearSecond,
                  isOrigin: false,
                  stopMode: secondMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Confirm / Save button placed under the selected stops (full width)
          if (canSave && onConfirm != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check),
                label: const Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAccentColor(),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStopCard({
    required BuildContext context,
    required String label,
    required String stationName,
    required bool isEmpty,
    required VoidCallback onClear,
    required bool isOrigin,
    TransportMode? stopMode,
  }) {
    // If a specific mode for this stop is provided, use its color; otherwise
    // fall back to the current tab mode color.
    final modeColor = stopMode != null
        ? TransportColors.getColorByTransportMode(stopMode)
        : _getModeColor();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isEmpty
              ? Colors.grey.withValues(alpha: 0.3)
              : modeColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: isEmpty
            ? Colors.grey.withValues(alpha: 0.05)
            : modeColor.withValues(alpha: 0.05),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and clear button row
          Row(
            children: [
              Icon(
                isOrigin ? Icons.radio_button_checked : Icons.location_on,
                color: isEmpty ? Colors.grey : modeColor,
                size: 16.0,
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isEmpty ? Colors.grey : modeColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (!isEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
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

          // Station name or placeholder
          Text(
            isEmpty ? 'Select ${label.toLowerCase()} stop' : stationName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isEmpty ? Colors.grey.shade600 : null,
                  fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
