import 'package:flutter/material.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';

/// Utility class for transport mode colors and names
class TransportModeUtils {
  /// Get color for transport mode based on ID
  /// 1 = train, 4 = light rail, 5 = bus, 7 = coach, 9 = ferry, 11 = school bus, 100 = walking
  static Color getModeColor(int id) {
    switch (id) {
      case 1:
        return TransportColors.train; // Train
      case 4:
        return TransportColors.lightRail; // Light Rail
      case 5:
      case 11:
        return TransportColors.bus; // Bus/School Bus
      case 7:
        return TransportColors.coach; // Coach
      case 9:
        return TransportColors.ferry; // Ferry
      default:
        return Colors.grey; // Default grey
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
    final modeColor = TransportModeUtils.getModeColor(transportClass);

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: modeColor,
            width: 2.0,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 4.0,
            height: double.infinity,
            decoration: BoxDecoration(
              color: modeColor,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          title: Text(
            '(${TransportModeUtils.getModeName(transportClass)}) $originName to $destinationName',
            style: TextStyle(
              color: modeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (transportName.isNotEmpty) 
                Text(
                  transportName,
                  style: TextStyle(
                    color: modeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (transportName.isNotEmpty) const SizedBox(height: 4),
              ..._getStops(),
            ],
          ),
        ),
      ),
    );
  }
}
