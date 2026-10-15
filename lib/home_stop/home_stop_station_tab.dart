import 'package:flutter/material.dart';
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

    if (stationList.isEmpty) {
      return const Center(child: Text('No stations found'));
    }

    return Column(
      children: [
        if (currentHomeStop != null)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.home, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current home stop: $currentHomeStop',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        if (selectedStationName.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: $selectedStationName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClearSelection,
                  tooltip: 'Clear selected home stop',
                ),
              ],
            ),
          ),
        Expanded(
          child: EnhancedStationList(
            listItems: stationList,
            setStation: onStationSelected,
            sortMode: sortMode,
          ),
        ),
      ],
    );
  }
}
