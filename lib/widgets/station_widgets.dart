import 'package:flutter/material.dart';

/// A model class for station data
class Station {
  final String name;
  final String id;
  final double? latitude;
  final double? longitude;

  Station({
    required this.name,
    required this.id,
    this.latitude,
    this.longitude,
  });
}

/// Widget for displaying a single station item
class StationView extends StatelessWidget {
  final Station station;
  final Function(String, String) setStation;

  const StationView({
    super.key,
    required this.station,
    required this.setStation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.0),
      child: Card(
        child: InkWell(
          onTap: () {
            setStation(station.name, station.id);
          },
          child: ListTile(
            title: Text(station.name),
          ),
        ),
      ),
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
        return StationView(
          station: listItems[index],
          setStation: setStation,
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
        Align(
          child: Text(
            '$label: $stationName',
            textAlign: TextAlign.center,
          ),
        ),
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
  final Function(String) onSearch;
  final VoidCallback onToggleSearch;
  final VoidCallback? onSaveTrip;
  final bool canSave;

  const NewTripAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onSearch,
    required this.onToggleSearch,
    this.onSaveTrip,
    required this.canSave,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? TextField(
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
        if (!canSave)
          if (isSearching)
            IconButton(
              onPressed: onToggleSearch,
              icon: const Icon(Icons.cancel),
            )
          else
            IconButton(
              onPressed: onToggleSearch,
              icon: const Icon(Icons.search),
            )
        else if (onSaveTrip != null)
          IconButton(
            onPressed: onSaveTrip,
            icon: const Icon(Icons.arrow_forward),
          ),
      ],
      bottom: const TabBar(
        tabs: [
          Tab(
            icon: Icon(
              Icons.directions_train,
              color: Color.fromARGB(255, 255, 97, 35),
            ),
          ),
          Tab(
            icon: Icon(
              Icons.tram,
              color: Color.fromARGB(255, 255, 82, 82),
            ),
          ),
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
          Tab(icon: Icon(Icons.map)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
