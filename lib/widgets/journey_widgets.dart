import 'package:flutter/material.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/widgets/journey/journey_accent_strip.dart';

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
    final manualDefinition = journey.manualTripDefinition;
    final interchangeCount = manualDefinition == null
        ? null
        : manualDefinition.legs.length - 1;

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Origin column
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
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
              // Vertical divider between origin and destination
              VerticalDivider(
                width: 12,
                thickness: 1,
                color: Colors.grey.shade400,
                indent: 8,
                endIndent: 8,
              ),
              // Destination column
              Expanded(
                child: InkWell(
                  onTap: onReverseTap,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
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
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
              ],
            ],
          ),
          if (journey.isManualMultiLeg)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                [
                  'Manual multi-leg',
                  if (journey.lineName != null && journey.lineName!.isNotEmpty)
                    journey.lineName!,
                  if (interchangeCount != null)
                    '$interchangeCount interchange${interchangeCount == 1 ? '' : 's'}',
                ].join(' • '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          JourneyAccentStrip(journey: journey),
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
  final bool hasTrips;
  final bool isAlphabeticalSorting;
  final VoidCallback onAddTrip;
  final VoidCallback onSettings;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleEdit;
  final VoidCallback onToggleSort;
  final Function(String) onSearchChanged;
  final TextEditingController searchController;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.hasApiKey,
    required this.isSearching,
    required this.isEditingMode,
    required this.hasTrips,
    required this.isAlphabeticalSorting,
    required this.onAddTrip,
    required this.onSettings,
    required this.onToggleSearch,
    required this.onToggleEdit,
    required this.onToggleSort,
    required this.onSearchChanged,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    // The AppBar sometimes receives absurdly small width constraints (e.g.,
    // during the very first layout after a hot restart or inside certain
    // tests). When the max width is 0 or 1 pixel the internal row that
    // arranges icons overflows, generating the errors you've been seeing.
    //
    // To stop the framework complaining we peek at the available space with a
    // LayoutBuilder and, if it's below a reasonable minimum, return a
    // stripped‑down bar with no children. It still obeys the preferred size but
    // cannot overflow because there is nothing to lay out.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        // when the bar is given almost no horizontal space (common during
        // first layout on hot restart or in focused widget tests) we simply emit
        // a placeholder app bar with no children. 100px is far less than any
        // real device width but safely above the combined minimum width of two
        // icon buttons so that we never try to lay them out into a 1px box.
        if (maxWidth < 100.0) {
          return AppBar(
            automaticallyImplyLeading: false,
            title: const SizedBox.shrink(),
          );
        }

        if (isSearching) {
          // when searching we use a simplified app bar: no actions, the close
          // button on the leading slot and the text field as the title.
          return AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: onToggleSearch,
              icon: const Icon(Icons.close),
            ),
            title: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search trips...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // normal (non-search) app bar
        return AppBar(
          title: Text(title),
          actions: <Widget>[
            if (hasTrips)
              IconButton(
                onPressed: onToggleSearch,
                icon: const Icon(Icons.search),
              ),
            if (hasTrips)
              IconButton(
                onPressed: onToggleEdit,
                icon: Icon(isEditingMode ? Icons.done : Icons.edit),
              ),
            if (hasTrips)
              PopupMenuButton<bool>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Sort trips',
                onSelected: (isAlphabetical) {
                  if (isAlphabetical != isAlphabeticalSorting) {
                    onToggleSort();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<bool>(
                    value: true,
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_by_alpha,
                          color: isAlphabeticalSorting ? null : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text('A–Z'),
                      ],
                    ),
                  ),
                  PopupMenuItem<bool>(
                    value: false,
                    child: Row(
                      children: [
                        Icon(
                          Icons.near_me,
                          color: !isAlphabeticalSorting ? null : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text('Nearest first'),
                      ],
                    ),
                  ),
                ],
              ),
            if (hasApiKey)
              IconButton(onPressed: onAddTrip, icon: const Icon(Icons.add)),
            IconButton(onPressed: onSettings, icon: const Icon(Icons.settings)),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
