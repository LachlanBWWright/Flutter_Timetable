import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';
import '../utils/color_utils.dart';
import '../widgets/station/stop_accent_card.dart';
import '../widgets/station_widgets.dart';

/// Station results and selection status for a home stop tab.
class HomeStopStationTab extends StatelessWidget {
  const HomeStopStationTab({
    super.key,
    required this.stationList,
    required this.isLoading,
    required this.currentHomeStop,
    required this.selectedStationName,
    required this.sortMode,
    required this.onStationSelected,
    required this.onClearSelection,
  });

  final List<Station> stationList;
  final bool isLoading;
  final String? currentHomeStop;
  final String selectedStationName;
  final SortMode sortMode;
  final void Function(Station) onStationSelected;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final colors = Theme.of(context).colorScheme;
    final pending = selectedStationName.isNotEmpty;
    final stopName = pending ? selectedStationName : currentHomeStop;

    final modes = {
      for (final station in stationList)
        if (station.name == stopName && station.mode != null) station.mode!,
    };
    final accent = modes.length == 1
        ? TransportColors.getColorByTransportMode(modes.single)
        : colors.primary;

    return Column(
      children: [
        if (stopName != null)
          StopAccentCard(
            accent: accent,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: accent,
                foregroundColor: getContrastingForeground(accent),
                child: Icon(
                  pending ? Icons.location_on_outlined : Icons.home_outlined,
                ),
              ),
              title: Text(
                pending ? 'New home stop' : 'Current home stop',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              subtitle: Text(
                stopName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: pending
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClearSelection,
                      tooltip: 'Clear selected home stop',
                    )
                  : null,
            ),
          ),
        Expanded(
          child: stationList.isEmpty
              ? const Center(child: Text('No stations found'))
              : EnhancedStationList(
                  listItems: stationList,
                  setStation: onStationSelected,
                  sortMode: sortMode,
                ),
        ),
      ],
    );
  }
}
