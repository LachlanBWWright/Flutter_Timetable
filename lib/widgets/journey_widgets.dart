import 'package:flutter/material.dart';
import 'package:lbww_flutter/schema/database.dart';

/// A reusable card widget for displaying journey information
class JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const JourneyCard({
    super.key,
    required this.journey,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          '${journey.origin} - ${journey.destination}',
        ),
        subtitle: Text(
          'Trip from ${journey.origin} to ${journey.destination}',
        ),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
// Removed extra closing brace
}

/// A widget that displays a list of journeys
class JourneyList extends StatelessWidget {
  final List<Journey> journeys;
  final Function(Journey) onJourneyTap;
  final Function(int) onDeleteJourney;

  const JourneyList({
    super.key,
    required this.journeys,
    required this.onJourneyTap,
    required this.onDeleteJourney,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: journeys.length,
        itemBuilder: (context, index) {
          return JourneyCard(
            journey: journeys[index],
            onTap: () => onJourneyTap(journeys[index]),
            onDelete: () => onDeleteJourney(journeys[index].id),
          );
        },
      ),
    );
  }
}

/// Custom app bar for the home screen
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool hasApiKey;
  final VoidCallback onAddTrip;
  final VoidCallback onSettings;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.hasApiKey,
    required this.onAddTrip,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: <Widget>[
        if (hasApiKey)
          IconButton(
            onPressed: onAddTrip,
            icon: const Icon(Icons.add),
          ),
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
