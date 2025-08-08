import 'package:flutter/material.dart';
import 'package:lbww_flutter/schema/database.dart';

import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/schema/database.dart';

/// A reusable card widget for displaying journey information with two-column layout
class JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback onTap;
  final VoidCallback onReverseTap;
  final VoidCallback onDelete;

  const JourneyCard({
    super.key,
    required this.journey,
    required this.onTap,
    required this.onReverseTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          // Origin column (left)
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: TransportColors.getColorByMode('train'),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
          // Destination column (right)
          Expanded(
            child: InkWell(
              onTap: onReverseTap,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// A widget that displays a list of journeys
class JourneyList extends StatelessWidget {
  final List<Journey> journeys;
  final Function(Journey) onJourneyTap;
  final Function(Journey) onReverseJourneyTap;
  final Function(int) onDeleteJourney;

  const JourneyList({
    super.key,
    required this.journeys,
    required this.onJourneyTap,
    required this.onReverseJourneyTap,
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
            onReverseTap: () => onReverseJourneyTap(journeys[index]),
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
