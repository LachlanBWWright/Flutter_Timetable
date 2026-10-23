import 'package:flutter/material.dart';

import '../../constants/transport_colors.dart';
import 'station.dart';

const BoxConstraints _minimumActionTarget = BoxConstraints(
  minWidth: 48,
  minHeight: 48,
);

/// Icon-only trip mode tab with an accessible label and a full-size target.
class AccessibleModeTabIcon extends StatelessWidget {
  const AccessibleModeTabIcon({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    // Semantics below supplies the tab's accessible name. Keep the visual
    // tooltip without adding the same text as a second semantic property.
    excludeFromSemantics: true,
    child: Semantics(
      label: label,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(child: Icon(icon, color: color)),
      ),
    ),
  );
}

List<Tab> _tabsOrDefault(List<Tab>? tabs) {
  if (tabs != null) {
    return tabs;
  }
  return _defaultStationTabs;
}

double _stationTabBarHeight(List<Tab>? tabs) {
  final resolvedTabs = _tabsOrDefault(tabs);
  final hasTextTabs = resolvedTabs.any((tab) => tab.text != null);
  return hasTextTabs ? 72.0 : 48.0;
}

const List<Tab> _defaultStationTabs = <Tab>[
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Sydney Trains stops',
      icon: Icons.directions_train,
      color: Color.fromARGB(255, 255, 97, 35),
    ),
  ),
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Light rail stops',
      icon: Icons.tram,
      color: Color.fromARGB(255, 255, 82, 82),
    ),
  ),
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Metro stops',
      icon: Icons.subway,
      color: TransportColors.metro,
    ),
  ),
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Bus stops',
      icon: Icons.directions_bus,
      color: Color.fromARGB(255, 82, 186, 255),
    ),
  ),
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Ferry stops',
      icon: Icons.directions_ferry,
      color: Color.fromARGB(255, 68, 240, 91),
    ),
  ),
];

/// Custom app bar for the new trip screen
class NewTripAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode? searchFocusNode;
  final Function(String) onSearch;
  final VoidCallback onToggleSearch;
  final VoidCallback? onSaveTrip;
  final bool canSave;
  final VoidCallback? onOpenMap;
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
              constraints: _minimumActionTarget,
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
              constraints: _minimumActionTarget,
              icon: Icon(showMapView ? Icons.list : Icons.map),
              tooltip: onOpenMap == null
                  ? 'Stops map unavailable for this region'
                  : showMapView
                  ? 'Show list'
                  : 'Open stops map',
            ),
          // Search/cancel button (only visible when not in map view)
          if (!showMapView) ...[
            if (isSearching)
              IconButton(
                onPressed: onToggleSearch,
                constraints: _minimumActionTarget,
                icon: const Icon(Icons.cancel),
                tooltip: 'Cancel station search',
              )
            else
              IconButton(
                onPressed: onToggleSearch,
                constraints: _minimumActionTarget,
                icon: const Icon(Icons.search),
                tooltip: 'Search for a station',
              ),
          ],
        ],
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_stationTabBarHeight(tabs)),
        child: SizedBox(
          height: _stationTabBarHeight(tabs),
          child: TabBar(controller: tabController, tabs: _tabsOrDefault(tabs)),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(kToolbarHeight + _stationTabBarHeight(tabs));
  }
}
