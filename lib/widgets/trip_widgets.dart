import 'package:flutter/material.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';

/// Utility class for transport mode colors and names
class TransportModeUtils {
  /// Get color for transport mode based on ID
  /// 1 = train, 4 = light rail, 5 = bus, 7 = coach, 9 = ferry, 11 = school bus, 100 = walking
  static Color getModeColor(int id) {
    switch (id) {
      case 1:
        return const Color.fromARGB(255, 255, 97, 35); // Train
      case 4:
        return const Color.fromARGB(255, 255, 82, 82); // Light Rail
      case 5:
      case 11:
        return const Color.fromARGB(255, 82, 186, 255); // Bus/School Bus
      case 7:
        return const Color.fromARGB(255, 161, 84, 47); // Coach
      case 9:
        return const Color.fromARGB(255, 68, 240, 91); // Ferry
      default:
        return const Color(0xFFFFFFFF); // Default white
    }
  }

  /// Get human-readable name for transport mode
  static String getModeName(int id) {
    switch (id) {
      case 1:
        return 'Train';
      case 4:
        return 'Light Rail';
      case 5:
        return 'Bus';
      case 11:
        return 'School Bus';
      case 7:
        return 'Coach';
      case 9:
        return 'Ferry';
      case 100:
        return 'Walk';
      default:
        return '(Unknown)';
    }
  }
}

/// Widget for displaying a single trip card
class TripCard extends StatelessWidget {
  final dynamic trip;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final legs = trip['legs'] as List;
    final firstLeg = legs.first;
    final lastLeg = legs.last;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          "${firstLeg['origin']['disassembledName']} to ${lastLeg['destination']['disassembledName']}",
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${DateTimeUtils.parseTime(firstLeg['origin']['departureTimePlanned'])} - ${DateTimeUtils.parseTime(lastLeg['destination']['arrivalTimePlanned'])} (Scheduled)",
            ),
            Text(
              "${DateTimeUtils.parseTime(firstLeg['origin']['departureTimeEstimated'])} - ${DateTimeUtils.parseTime(lastLeg['destination']['arrivalTimeEstimated'])} (Estimated)",
            ),
            Text('Number of legs: ${legs.length}'),
            Text("Number of interchanges: ${trip['interchanges']}"),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying trip leg information
class TripLegCard extends StatelessWidget {
  final dynamic leg;

  const TripLegCard({
    super.key,
    required this.leg,
  });

  List<Widget> _getStops() {
    final List<Widget> stops = [];
    try {
      final stopSequence = leg['stopSequence'] as List?;
      if (stopSequence != null) {
        for (dynamic stop in stopSequence) {
          stops.add(Text(
            "${stop['disassembledName'] ?? stop['name']} ${stop['departureTimePlanned'] != null ? DateTimeUtils.parseTime(stop['departureTimePlanned']) : "(TBD)"}",
          ));
        }
      }
    } catch (e) {
      stops.add(const Text('Walk!'));
    }
    return stops;
  }

  @override
  Widget build(BuildContext context) {
    final transportClass = leg['transportation']['product']['class'] as int;
    final originName =
        leg['origin']['disassembledName'] ?? leg['origin']['name'];
    final destinationName =
        leg['destination']['disassembledName'] ?? leg['destination']['name'];
    final transportName = leg['transportation']['name'] ??
        leg['transportation']['disassembledName'] ??
        '';

    return Card(
      color: TransportModeUtils.getModeColor(transportClass),
      child: ListTile(
        title: Text(
          '(${TransportModeUtils.getModeName(transportClass)}) $originName to $destinationName',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (transportName.isNotEmpty) Text(transportName),
            if (transportName.isNotEmpty) const Text(''),
            ..._getStops(),
          ],
        ),
      ),
    );
  }
}
