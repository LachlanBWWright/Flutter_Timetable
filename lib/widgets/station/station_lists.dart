import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../constants/transport_modes.dart';
import 'station.dart';
import 'station_view.dart';

/// Enhanced widget for displaying a list of stations with distance support
class EnhancedStationList extends StatelessWidget {
  final List<Station> listItems;
  final StationSelectionCallback setStation;
  final SortMode sortMode;
  final TransportMode? mode;

  const EnhancedStationList({
    super.key,
    required this.listItems,
    required this.setStation,
    required this.sortMode,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        final station = listItems.elementAtOrNull(index);
        if (station == null) {
          return const SizedBox.shrink();
        }
        return StationView(
          station: station,
          setStation: setStation,
          sortMode: sortMode,
          mode: mode,
        );
      },
    );
  }
}

/// Widget for displaying a list of stations
class StationList extends StatelessWidget {
  final List<Station> listItems;
  final StationSelectionCallback setStation;

  const StationList({
    super.key,
    required this.listItems,
    required this.setStation,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        // Default to alphabetical if not specified
        final station = listItems.elementAtOrNull(index);
        if (station == null) {
          return const SizedBox.shrink();
        }
        return StationView(
          station: station,
          setStation: setStation,
          sortMode: SortMode.alphabetical,
        );
      },
    );
  }
}

/// Widget for displaying selected station with cancel option
class SelectedStationCard extends StatelessWidget {
  final String label;
  final String stationName;
  final VoidCallback onCancel;

  const SelectedStationCard({
    super.key,
    required this.label,
    required this.stationName,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(child: Text('$label: $stationName', textAlign: TextAlign.center)),
        Positioned(
          right: 0,
          child: InkWell(
            onTap: onCancel,
            child: const Icon(Icons.cancel, size: 12),
          ),
        ),
      ],
    );
  }
}
