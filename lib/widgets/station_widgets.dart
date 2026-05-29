// ignore_for_file: catch_unknown_dynamic_calls

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import '../constants/transport_colors.dart';
import '../services/debug_service.dart';
import '../utils/station_subtitle_utils.dart';

typedef StationSelectionCallback =
    void Function(String stationName, String stationId, TransportMode? mode);

T _valueOr<T>(T? value, T fallback) {
  if (value != null) {
    return value;
  }
  return fallback;
}

String _nearbyBadgeLabelFor(Station station) {
  return _valueOr(station.nearbyBadgeLabel, 'Best nearby');
}

double? _preferredDistanceFor(Station station) {
  return _valueOr(station.nearbyAnchorDistance, station.distance);
}

List<Tab> _tabsOrDefault(List<Tab>? tabs) {
  if (tabs != null) {
    return tabs;
  }
  return _defaultStationTabs;
}

const List<Tab> _defaultStationTabs = <Tab>[
  Tab(
    icon: Icon(Icons.directions_train, color: Color.fromARGB(255, 255, 97, 35)),
  ),
  Tab(icon: Icon(Icons.tram, color: Color.fromARGB(255, 255, 82, 82))),
  Tab(icon: Icon(Icons.subway, color: TransportColors.metro)),
  Tab(
    icon: Icon(Icons.directions_bus, color: Color.fromARGB(255, 82, 186, 255)),
  ),
  Tab(
    icon: Icon(Icons.directions_ferry, color: Color.fromARGB(255, 68, 240, 91)),
  ),
];

/// A model class for station data
class Station {
  final String name;
  final String id;
  final TransportMode? mode;
  final String? lineId;
  final String? lineName;
  final bool isPreferredNearby;
  final String? nearbyBadgeLabel;
  final double? nearbyAnchorDistance;
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
    this.mode,
    this.lineId,
    this.lineName,
    this.isPreferredNearby = false,
    this.nearbyBadgeLabel,
    this.nearbyAnchorDistance,
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
    TransportMode? mode,
    String? lineId,
    String? lineName,
    bool? isPreferredNearby,
    String? nearbyBadgeLabel,
    double? nearbyAnchorDistance,
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
      name: _valueOr(name, this.name),
      id: _valueOr(id, this.id),
      mode: _valueOr(mode, this.mode),
      lineId: _valueOr(lineId, this.lineId),
      lineName: _valueOr(lineName, this.lineName),
      isPreferredNearby: _valueOr(isPreferredNearby, this.isPreferredNearby),
      nearbyBadgeLabel: _valueOr(nearbyBadgeLabel, this.nearbyBadgeLabel),
      nearbyAnchorDistance: _valueOr(
        nearbyAnchorDistance,
        this.nearbyAnchorDistance,
      ),
      lineStopOrder: _valueOr(lineStopOrder, this.lineStopOrder),
      stopCode: _valueOr(stopCode, this.stopCode),
      stopDesc: _valueOr(stopDesc, this.stopDesc),
      zoneId: _valueOr(zoneId, this.zoneId),
      stopUrl: _valueOr(stopUrl, this.stopUrl),
      stopTimezone: _valueOr(stopTimezone, this.stopTimezone),
      levelId: _valueOr(levelId, this.levelId),
      parentStation: _valueOr(parentStation, this.parentStation),
      wheelchairBoarding: _valueOr(wheelchairBoarding, this.wheelchairBoarding),
      platformCode: _valueOr(platformCode, this.platformCode),
      latitude: _valueOr(latitude, this.latitude),
      longitude: _valueOr(longitude, this.longitude),
      distance: _valueOr(distance, this.distance),
    );
  }
}

/// Widget for displaying a single station item with optional distance
class StationView extends StatelessWidget {
  final Station station;
  final StationSelectionCallback setStation;
  final SortMode sortMode;
  final TransportMode? mode;

  const StationView({
    super.key,
    required this.station,
    required this.setStation,
    required this.sortMode,
    this.mode,
  });

  void _selectStation() {
    setStation(station.name, station.id, mode);
  }

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
          onTap: _selectStation,
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

        if (station.isPreferredNearby) {
          items.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    _nearbyBadgeLabelFor(station),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ),
          );
        }

        final standardDistanceLine = formatStationDistanceLine(
          _preferredDistanceFor(station),
          debugFormat: false,
        );
        if (standardDistanceLine != null && !showDebug) {
          items.add(
            Text(
              standardDistanceLine,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }

        if (showDebug) {
          items.addAll(
            buildStationDebugLines(station).map(
              (line) => Text(
                line,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          );

          final debugDistanceLine = formatStationDistanceLine(
            _preferredDistanceFor(station),
            debugFormat: true,
          );
          if (debugDistanceLine != null) {
            items.add(
              Text(
                debugDistanceLine,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            );
          }
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
  final List<Tab>? tabs;

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
    this.tabs,
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
      bottom: TabBar(controller: tabController, tabs: _tabsOrDefault(tabs)),
    );
  }

  @override
  Size get preferredSize {
    final resolvedTabs = tabs;
    final hasTextTabs =
        resolvedTabs != null && resolvedTabs.any((tab) => tab.text != null);
    final tabBarHeight = hasTextTabs ? 72.0 : kTextTabBarHeight;
    return Size.fromHeight(kToolbarHeight + tabBarHeight);
  }
}
