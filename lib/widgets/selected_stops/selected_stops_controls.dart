import 'package:flutter/material.dart';

import '../../constants/transport_modes.dart';
import 'selected_stops_parts.dart';

class SelectedStopsHeader extends StatelessWidget {
  const SelectedStopsHeader({
    super.key,
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

class SameLineFilterToggle extends StatelessWidget {
  const SameLineFilterToggle({
    super.key,
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

class SelectedStopsStatusCard extends StatelessWidget {
  const SelectedStopsStatusCard({
    super.key,
    required this.message,
    required this.accentColor,
  });

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
