import 'package:flutter/material.dart';
// import 'package:lbww_flutter/widgets/trip_leg_card.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';

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

  String _formatTimeDifference(String planned, String estimated) {
    try {
      final plannedTime = DateTimeUtils.parseTimeToDateTime(planned);
      final estimatedTime = DateTimeUtils.parseTimeToDateTime(estimated);

      if (plannedTime == null || estimatedTime == null) {
        return DateTimeUtils.parseTimeOnly(estimated);
      }

      final difference = estimatedTime.difference(plannedTime).inMinutes;

      if (difference == 0) {
        return DateTimeUtils.parseTimeOnly(estimated);
      } else if (difference > 0) {
        return '${DateTimeUtils.parseTimeOnly(estimated)} (+${difference}m late)';
      } else {
        return '${DateTimeUtils.parseTimeOnly(estimated)} (${difference.abs()}m early)';
      }
    } catch (e) {
      return DateTimeUtils.parseTimeOnly(estimated);
    }
  }

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
            Row(
              children: [
                Text(
                  _formatTimeDifference(
                    firstLeg['origin']['departureTimePlanned'],
                    firstLeg['origin']['departureTimeEstimated'],
                  ),
                ),
                const Text(' - '),
                Text(
                  _formatTimeDifference(
                    lastLeg['destination']['arrivalTimePlanned'],
                    lastLeg['destination']['arrivalTimeEstimated'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
