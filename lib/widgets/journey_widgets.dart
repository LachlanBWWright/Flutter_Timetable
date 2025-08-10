import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/schema/database.dart';

/// A reusable card widget for displaying journey information with two-column layout
class JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback onTap;
  final VoidCallback onReverseTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final bool isEditingMode;

  const JourneyCard({
    super.key,
    required this.journey,
    required this.onTap,
    required this.onReverseTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.isEditingMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          // Origin column (left) with accent strip
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: const BorderSide(
                      color: TransportColors.train,
                      width: 4.0,
                    ),
                    right: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.origin,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Destination column (right) with accent strip
          Expanded(
            child: InkWell(
              onTap: onReverseTap,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: TransportColors.train,
                      width: 4.0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.destination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Action buttons (pin/delete)
          if (isEditingMode) ...[
            IconButton(
              icon: Icon(
                journey.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: journey.isPinned ? Colors.blue : Colors.grey,
              ),
              onPressed: onTogglePin,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

/// A widget that displays a list of journeys
class JourneyList extends StatelessWidget {
  final List<Journey> journeys;
  final void Function(Journey) onJourneyTap;
  final void Function(Journey) onReverseJourneyTap;
  final void Function(int) onDeleteJourney;
  final void Function(int, bool) onTogglePin;
  final bool isEditingMode;
  final bool isPinnedSection;

  const JourneyList({
    super.key,
    required this.journeys,
    required this.onJourneyTap,
    required this.onReverseJourneyTap,
    required this.onDeleteJourney,
    required this.onTogglePin,
    required this.isEditingMode,
    required this.isPinnedSection,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: journeys.length,
      itemBuilder: (context, index) {
        return JourneyCard(
          journey: journeys[index],
          onTap: () => onJourneyTap(journeys[index]),
          onReverseTap: () => onReverseJourneyTap(journeys[index]),
          onDelete: () => onDeleteJourney(journeys[index].id),
          onTogglePin: () =>
              onTogglePin(journeys[index].id, journeys[index].isPinned),
          isEditingMode: isEditingMode,
        );
      },
    );
  }
}

/// Custom app bar for the home screen
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool hasApiKey;
  final bool isSearching;
  final bool isEditingMode;
  final VoidCallback onAddTrip;
  final VoidCallback onSettings;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleEdit;
  final Function(String) onSearchChanged;
  final TextEditingController searchController;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.hasApiKey,
    required this.isSearching,
    required this.isEditingMode,
    required this.onAddTrip,
    required this.onSettings,
    required this.onToggleSearch,
    required this.onToggleEdit,
    required this.onSearchChanged,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search trips...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            )
          : Text(title),
      actions: <Widget>[
        if (!isSearching) ...[
          IconButton(
            onPressed: onToggleSearch,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: onToggleEdit,
            icon: Icon(isEditingMode ? Icons.done : Icons.edit),
          ),
          if (hasApiKey)
            IconButton(
              onPressed: onAddTrip,
              icon: const Icon(Icons.add),
            ),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings),
          ),
        ] else ...[
          IconButton(
            onPressed: onToggleSearch,
            icon: const Icon(Icons.close),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
