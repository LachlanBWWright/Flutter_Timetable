import 'package:flutter/material.dart';
import 'package:lbww_flutter/trip_leg_screen.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

/// Widget for displaying trip leg information

class TripLegCard extends StatelessWidget {
  final dynamic leg;

  const TripLegCard({
    super.key,
    required this.leg,
  });

  String _formatTimeDifference(String? plannedTime, String? estimatedTime) {
    if (estimatedTime == null) {
      return plannedTime != null
          ? DateTimeUtils.parseTimeOnly(plannedTime)
          : 'TBD';
    }

    if (plannedTime == null) {
      return DateTimeUtils.parseTimeOnly(estimatedTime);
    }

    try {
      final planned = DateTimeUtils.parseTimeToDateTime(plannedTime);
      final estimated = DateTimeUtils.parseTimeToDateTime(estimatedTime);

      if (planned == null || estimated == null) {
        return DateTimeUtils.parseTimeOnly(estimatedTime);
      }

      final difference = estimated.difference(planned).inMinutes;

      if (difference == 0) {
        return DateTimeUtils.parseTimeOnly(estimatedTime);
      } else if (difference > 0) {
        return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (+${difference}m late)';
      } else {
        return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (${difference.abs()}m early)';
      }
    } catch (e) {
      return DateTimeUtils.parseTimeOnly(estimatedTime);
    }
  }

  Widget _buildTimingInfo() {
    final origin = leg['origin'];
    final destination = leg['destination'];

    // Get first stop timing info
    final originDeparturePlanned = origin?['departureTimePlanned'] as String?;
    final originDepartureEstimated =
        origin?['departureTimeEstimated'] as String?;

    // Get last stop timing info
    final destinationArrivalPlanned =
        destination?['arrivalTimePlanned'] as String?;
    final destinationArrivalEstimated =
        destination?['arrivalTimeEstimated'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (originDeparturePlanned != null || originDepartureEstimated != null)
          Row(
            children: [
              const Icon(Icons.departure_board, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Depart: ${_formatTimeDifference(originDeparturePlanned, originDepartureEstimated)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        if (destinationArrivalPlanned != null ||
            destinationArrivalEstimated != null)
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'Arrive: ${_formatTimeDifference(destinationArrivalPlanned, destinationArrivalEstimated)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
      ],
    );
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
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripLegDetailScreen(leg: leg),
            ),
          );
        },
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
              children: [
                if (transportName.isNotEmpty)
                  Text(
                    transportName,
                    style: TextStyle(
                      color: modeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                _buildTimingInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
