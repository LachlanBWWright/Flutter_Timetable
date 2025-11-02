import 'package:flutter/material.dart';
import '../constants/transport_colors.dart';

/// Widget for displaying selected stops at the bottom of the new trip screen
/// with mode-specific accents and two-column layout
class SelectedStopsWidget extends StatelessWidget {
  final String firstStation;
  final String firstStationId;
  final String secondStation;
  final String secondStationId;
  final String currentMode;
  final VoidCallback onClearFirst;
  final VoidCallback onClearSecond;

  const SelectedStopsWidget({
    super.key,
    required this.firstStation,
    required this.firstStationId,
    required this.secondStation,
    required this.secondStationId,
    required this.currentMode,
    required this.onClearFirst,
    required this.onClearSecond,
  });

  Color _getModeColor() {
    return TransportColors.getColorByMode(currentMode);
  }

  IconData _getModeIcon() {
    switch (currentMode) {
      case 'train':
        return Icons.directions_train;
      case 'lightrail':
        return Icons.tram;
      case 'bus':
        return Icons.directions_bus;
      case 'ferry':
        return Icons.directions_ferry;
      default:
        return Icons.location_on;
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
            color: _getModeColor(),
            width: 3.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  color: _getModeColor(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  _getModeIcon(),
                  color: Colors.white,
                  size: 20.0,
                ),
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
                ),
              ),
            ],
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
  }) {
    final modeColor = _getModeColor();
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isEmpty 
            ? Colors.grey.withOpacity(0.3)
            : modeColor.withOpacity(0.3),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: isEmpty 
          ? Colors.grey.withOpacity(0.05)
          : modeColor.withOpacity(0.05),
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