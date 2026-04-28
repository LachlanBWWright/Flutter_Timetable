import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import '../constants/transport_colors.dart';
import '../services/debug_service.dart';

/// A model class for station data
class Station {
  final String name;
  final String id;
  final String? lineId;
  final String? lineName;
  final bool isWithinLinePriorityRadius;
  final int? lineStopOrder;

  // Optional metadata from GTFS/stop endpoints
  final String? stopCode;
  final String? stopDesc;
  final String? zoneId;
  final String? stopUrl;
  final String? stopTimezone;
  final String? levelId;
  final String? parentStation;
  final int? wheelchairBoarding;
  final String? platformCode;

  final double? latitude;
  final double? longitude;
  final double? distance; // Distance from user location in km

  Station({
    required this.name,
    required this.id,
    this.lineId,
    this.lineName,
    this.isWithinLinePriorityRadius = false,
    this.lineStopOrder,
    this.stopCode,
    this.stopDesc,
    this.zoneId,
    this.stopUrl,
    this.stopTimezone,
    this.levelId,
    this.parentStation,
    this.wheelchairBoarding,
    this.platformCode,
    this.latitude,
    this.longitude,
    this.distance,
  });

  /// Create a new Station with updated distance
  Station copyWith({
    String? name,
    String? id,
    String? lineId,
    String? lineName,
    bool? isWithinLinePriorityRadius,
    int? lineStopOrder,
    String? stopCode,
    String? stopDesc,
    String? zoneId,
    String? stopUrl,
    String? stopTimezone,
    String? levelId,
    String? parentStation,
    int? wheelchairBoarding,
    String? platformCode,
    double? latitude,
    double? longitude,
    double? distance,
  }) {
    return Station(
      name: name ?? this.name,
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      lineName: lineName ?? this.lineName,
      isWithinLinePriorityRadius:
          isWithinLinePriorityRadius ?? this.isWithinLinePriorityRadius,
      lineStopOrder: lineStopOrder ?? this.lineStopOrder,
      stopCode: stopCode ?? this.stopCode,
      stopDesc: stopDesc ?? this.stopDesc,
      zoneId: zoneId ?? this.zoneId,
      stopUrl: stopUrl ?? this.stopUrl,
      stopTimezone: stopTimezone ?? this.stopTimezone,
      levelId: levelId ?? this.levelId,
      parentStation: parentStation ?? this.parentStation,
      wheelchairBoarding: wheelchairBoarding ?? this.wheelchairBoarding,
      platformCode: platformCode ?? this.platformCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
    );
  }
}

/// Widget for displaying a single station item with optional distance
class StationView extends StatelessWidget {
  final Station station;
  final Function(String, String) setStation;
  final SortMode sortMode;
  final TransportMode? mode;

  const StationView({
    super.key,
    required this.station,
    required this.setStation,
    required this.sortMode,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final transportMode = mode;
    final accentColor = transportMode != null
        ? TransportColors.getColorByTransportMode(transportMode)
        : Colors.grey;
    return Container(
      margin: const EdgeInsets.all(1.0),
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: InkWell(
          onTap: () {
            setStation(station.name, station.id);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(title: Text(station.name), subtitle: _buildSubtitle()),
              Container(height: 6, width: double.infinity, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return ValueListenableBuilder<bool>(
      valueListenable: DebugService.showDebugData,
      builder: (context, showDebug, _) {
        final items = <Widget>[];
        final dist = station.distance;

        // Always show distance when available
        if (dist != null && !showDebug) {
          items.add(
            Text(
              '${dist.toStringAsFixed(1)} km away',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }

        if (showDebug) {
          items.addAll([
            Text(
              'ID: ${station.id}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'Code: ${station.stopCode ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'Parent: ${station.parentStation ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'Desc: ${station.stopDesc ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'Zone: ${station.zoneId ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'URL: ${station.stopUrl ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'TZ: ${station.stopTimezone ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'Level: ${station.levelId ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'Wheelchair: ${station.wheelchairBoarding ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'Platform: ${station.platformCode ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'Lat/Lon: ${station.latitude?.toStringAsFixed(5) ?? '-'}, ${station.longitude?.toStringAsFixed(5) ?? '-'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            if (dist != null)
              Text(
                'Distance: ${dist.toStringAsFixed(2)} km',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ]);
        }

        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        );
      },
    );
  }
}

/// Enhanced widget for displaying a list of stations with distance support
class EnhancedStationList extends StatelessWidget {
  final List<Station> listItems;
  final Function(String, String) setStation;
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
        return StationView(
          station: listItems[index],
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
  final Function(String, String) setStation;

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
        return StationView(
          station: listItems[index],
          setStation: setStation,
          sortMode: SortMode.alphabetical,
        );
      },
    );
  }
}

/// Sort mode for station lists
enum SortMode { alphabetical, distance }

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

/// Custom app bar for the new trip screen
class NewTripAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode? searchFocusNode;
  final Function(String) onSearch;
  final VoidCallback onToggleSearch;
  final VoidCallback? onSaveTrip;
  final bool canSave;
  final VoidCallback onOpenMap;
  final VoidCallback onToggleSort;
  final SortMode sortMode;
  final bool showMapView;
  final TabController? tabController;

  const NewTripAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onSearch,
    required this.onToggleSearch,
    this.searchFocusNode,
    this.onSaveTrip,
    required this.canSave,
    required this.onOpenMap,
    required this.onToggleSort,
    required this.sortMode,
    this.showMapView = false,
    this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? TextField(
              focusNode: searchFocusNode,
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search for a station',
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: onSearch,
            )
          : const Text('Add New Trip'),
      actions: [
        if (!canSave) ...[
          // Sort button (only show when not searching, not in map view, and not ready to save)
          if (!isSearching && !showMapView)
            IconButton(
              onPressed: onToggleSort,
              icon: Icon(
                sortMode == SortMode.alphabetical
                    ? Icons.sort_by_alpha
                    : Icons.near_me,
              ),
              tooltip: sortMode == SortMode.alphabetical
                  ? 'Sort by distance'
                  : 'Sort alphabetically',
            ),
          // Map/list toggle button (only show when not searching)
          if (!isSearching)
            IconButton(
              onPressed: onOpenMap,
              icon: Icon(showMapView ? Icons.list : Icons.map),
              tooltip: showMapView ? 'Show list' : 'Open stops map',
            ),
          // Search/cancel button (only visible when not in map view)
          if (!showMapView) ...[
            if (isSearching)
              IconButton(
                onPressed: onToggleSearch,
                icon: const Icon(Icons.cancel),
              )
            else
              IconButton(
                onPressed: onToggleSearch,
                icon: const Icon(Icons.search),
              ),
          ],
        ],
      ],
      bottom: TabBar(
        controller: tabController,
        tabs: const [
          Tab(
            icon: Icon(
              Icons.directions_train,
              color: Color.fromARGB(255, 255, 97, 35),
            ),
          ),
          Tab(icon: Icon(Icons.tram, color: Color.fromARGB(255, 255, 82, 82))),
          Tab(icon: Icon(Icons.subway, color: TransportColors.metro)),
          Tab(
            icon: Icon(
              Icons.directions_bus,
              color: Color.fromARGB(255, 82, 186, 255),
            ),
          ),
          Tab(
            icon: Icon(
              Icons.directions_ferry,
              color: Color.fromARGB(255, 68, 240, 91),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}
