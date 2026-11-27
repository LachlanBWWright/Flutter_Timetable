import 'package:flutter/material.dart';

import '../../constants/transport_modes.dart';
import '../../services/new_trip_service.dart';
import '../station_widgets.dart';

export 'stop_sequence_section.dart';

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
                IconButton(
                  onPressed: onClear,
                  tooltip:
                      'Clear ${label.toLowerCase()} stop ${currentStation.name}',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: Icon(
                    Icons.close,
                    size: 14.0,
                    color: Colors.grey.shade600,
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
