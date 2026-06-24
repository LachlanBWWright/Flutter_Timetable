import 'package:lbww_flutter/schema/database.dart' as db;

class JourneySections {
  const JourneySections({
    required this.pinnedJourneys,
    required this.unpinnedJourneys,
  });

  final List<db.Journey> pinnedJourneys;
  final List<db.Journey> unpinnedJourneys;
}

List<db.Journey> filterJourneysByQuery(
  List<db.Journey> journeys,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return journeys;
  }

  return journeys.where((journey) {
    return journey.origin.toLowerCase().contains(normalizedQuery) ||
        journey.destination.toLowerCase().contains(normalizedQuery);
  }).toList();
}

JourneySections splitJourneySections(List<db.Journey> journeys) {
  final pinned = <db.Journey>[];
  final unpinned = <db.Journey>[];

  for (final journey in journeys) {
    if (journey.isPinned) {
      pinned.add(journey);
    } else {
      unpinned.add(journey);
    }
  }

  return JourneySections(pinnedJourneys: pinned, unpinnedJourneys: unpinned);
}
