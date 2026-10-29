import 'package:flutter/material.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/widgets/journey/journey_accent_strip.dart';
import 'package:lbww_flutter/widgets/journey/journey_direction_button.dart';

/// A reusable card widget for displaying journey information with two-column layout
class JourneyCard extends StatefulWidget {
  final Journey journey;
  final VoidCallback onTap;
  final VoidCallback onReverseTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final bool isEditingMode;
  final bool showNextTripTimes;
  final void Function(Journey)? onJourneyVisible;

  const JourneyCard({
    super.key,
    required this.journey,
    required this.onTap,
    required this.onReverseTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.isEditingMode,
    this.onJourneyVisible,
    this.showNextTripTimes = false,
  });

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard>
    with GuardedState<JourneyCard> {
  bool _didNotifyVisible = false;

  void _emitJourneyVisible() {
    final onJourneyVisible = widget.onJourneyVisible;
    if (onJourneyVisible == null) {
      return;
    }
    try {
      onJourneyVisible.call(widget.journey);
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant JourneyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journey.id != widget.journey.id) {
      _didNotifyVisible = false;
    }
  }

  void _notifyVisible() {
    if (_didNotifyVisible) return;
    _didNotifyVisible = true;
    addPostFrameCallbackSafely((_) {
      if (!mounted) return;
      _emitJourneyVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    _notifyVisible();

    final journey = widget.journey;
    final manualDefinition = journey.manualTripDefinition;
    final interchangeCount = manualDefinition == null
        ? null
        : manualDefinition.legs.length - 1;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Origin column
              Expanded(
                child: JourneyDirectionButton(
                  journey: journey,
                  onTap: widget.onTap,
                  showNextTripTimes: widget.showNextTripTimes,
                ),
              ),
              // Vertical divider between origin and destination
              VerticalDivider(
                width: 10,
                thickness: 1,
                color: Colors.grey.shade400,
                indent: 12,
                endIndent: 12,
              ),
              // Destination column
              Expanded(
                child: JourneyDirectionButton(
                  journey: journey,
                  onTap: widget.onReverseTap,
                  showNextTripTimes: widget.showNextTripTimes,
                  reverse: true,
                ),
              ),
              // Action buttons (pin/delete)
              if (widget.isEditingMode) ...[
                IconButton(
                  icon: Icon(
                    journey.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: journey.isPinned ? Colors.blue : Colors.grey,
                  ),
                  onPressed: widget.onTogglePin,
                  tooltip: journey.isPinned ? 'Unpin trip' : 'Pin trip',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete trip',
                ),
              ],
            ],
          ),
          if (journey.isManualMultiLeg)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                [
                  'Manual multi-leg',
                  if (journey.lineName case final lineName?
                      when lineName.isNotEmpty)
                    lineName,
                  if (interchangeCount != null)
                    '$interchangeCount interchange${interchangeCount == 1 ? '' : 's'}',
                ].join(' • '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 2),
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
  final void Function(Journey)? onJourneyVisible;
  final void Function(int) onDeleteJourney;
  final void Function(int, bool) onTogglePin;
  final bool isEditingMode;
  final bool showNextTripTimes;
  final bool isPinnedSection;

  /// Render in a parent CustomScrollView instead of owning a scrollable.
  final bool asSliver;

  const JourneyList({
    super.key,
    required this.journeys,
    required this.onJourneyTap,
    required this.onReverseJourneyTap,
    this.onJourneyVisible,
    this.showNextTripTimes = false,
    required this.onDeleteJourney,
    required this.onTogglePin,
    required this.isEditingMode,
    required this.isPinnedSection,
    this.asSliver = false,
  });

  void _handleJourneyTap(Journey journey) {
    try {
      onJourneyTap.call(journey);
    } catch (_) {}
  }

  void _handleReverseJourneyTap(Journey journey) {
    try {
      onReverseJourneyTap.call(journey);
    } catch (_) {}
  }

  void _handleDeleteJourney(Journey journey) {
    try {
      onDeleteJourney.call(journey.id);
    } catch (_) {}
  }

  void _handleTogglePin(Journey journey) {
    try {
      onTogglePin.call(journey.id, journey.isPinned);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final children = SliverChildBuilderDelegate(
      (context, index) {
        final journey = journeys[index];
        return JourneyCard(
          key: ValueKey(journey.id),
          journey: journey,
          onTap: () => _handleJourneyTap(journey),
          onReverseTap: () => _handleReverseJourneyTap(journey),
          onJourneyVisible: onJourneyVisible,
          onDelete: () => _handleDeleteJourney(journey),
          onTogglePin: () => _handleTogglePin(journey),
          isEditingMode: isEditingMode,
          showNextTripTimes: showNextTripTimes,
        );
      },
      childCount: journeys.length,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<int>) return null;
        final index = journeys.indexWhere((journey) => journey.id == key.value);
        return index < 0 ? null : index;
      },
    );
    if (asSliver) return SliverList(delegate: children);
    return ListView.custom(
      padding: EdgeInsets.zero,
      childrenDelegate: children,
    );
  }
}

/// Custom app bar for the home screen
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final bool isEditingMode;
  final bool hasTrips;
  final bool isAlphabeticalSorting;
  final VoidCallback onSettings;
  final VoidCallback? onFindVehicle;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleEdit;
  final VoidCallback onToggleSort;
  final void Function(String) onSearchChanged;
  final TextEditingController searchController;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.isSearching,
    required this.isEditingMode,
    required this.hasTrips,
    required this.isAlphabeticalSorting,
    required this.onSettings,
    this.onFindVehicle,
    required this.onToggleSearch,
    required this.onToggleEdit,
    required this.onToggleSort,
    required this.onSearchChanged,
    required this.searchController,
  });

  void _handleSortSelection(bool isAlphabetical) {
    if (isAlphabetical == isAlphabeticalSorting) {
      return;
    }
    try {
      onToggleSort.call();
    } catch (_) {}
  }

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
              tooltip: isSearching ? 'Close search' : 'Search trips',
              icon: const Icon(Icons.close),
            ),
            title: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search trips...',
                border: InputBorder.none,
              ),
            ),
          );
        }

        // normal (non-search) app bar
        return AppBar(
          title: Text(title),
          actions: <Widget>[
            if (onFindVehicle != null)
              IconButton(
                onPressed: onFindVehicle,
                tooltip: 'Find my vehicle (experimental)',
                icon: const Icon(Icons.radar),
              ),
            if (hasTrips)
              IconButton(
                onPressed: onToggleSearch,
                tooltip: isSearching ? 'Close search' : 'Search trips',
                icon: const Icon(Icons.search),
              ),
            if (hasTrips)
              IconButton(
                onPressed: onToggleEdit,
                tooltip: isEditingMode ? 'Finish editing' : 'Edit trips',
                icon: Icon(isEditingMode ? Icons.done : Icons.edit),
              ),
            if (hasTrips)
              PopupMenuButton<bool>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Sort trips',
                onSelected: _handleSortSelection,
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
            IconButton(
              onPressed: onSettings,
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
