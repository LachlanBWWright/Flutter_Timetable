import 'package:flutter/material.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/trip_leg_card.dart';

class TripLegScreen extends StatefulWidget {
  const TripLegScreen({super.key, required this.trip});
  final TripJourney trip;

  @override
  State<TripLegScreen> createState() => _TripLegScreenState();
}

class _TripLegScreenState extends State<TripLegScreen> {
  String _calculateWaitTime(Leg currentLeg, Leg nextLeg) {
    try {
      // Get arrival time of current leg
      final currentDestination = currentLeg.destination;
      final currentArrival = currentDestination.arrivalTimeEstimated ??
          currentDestination.arrivalTimePlanned;

      // Get departure time of next leg
      final nextOrigin = nextLeg.origin;
      final nextDeparture =
          nextOrigin.departureTimeEstimated ?? nextOrigin.departureTimePlanned;

      if (currentArrival == null || nextDeparture == null) {
        return 'Wait time unknown';
      }

      final arrivalTime = DateTimeUtils.parseTimeToDateTime(currentArrival);
      final departureTime = DateTimeUtils.parseTimeToDateTime(nextDeparture);

      if (arrivalTime == null || departureTime == null) {
        return 'Wait time unknown';
      }

      final waitDuration = departureTime.difference(arrivalTime);
      final minutes = waitDuration.inMinutes;

      if (minutes <= 0) {
        return 'No wait time';
      } else if (minutes < 60) {
        return 'Wait ${minutes}m';
      } else {
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        return 'Wait ${hours}h ${remainingMinutes}m';
      }
    } catch (e) {
      return 'Wait time unknown';
    }
  }

  Widget _buildSeparator(int index, List<Leg> legs) {
    if (index >= legs.length - 1) {
      return const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16);
    }

    final waitTime = _calculateWaitTime(legs[index], legs[index + 1]);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          const Divider(thickness: 1),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withAlpha((255 * 0.3).round())),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  waitTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final legs = widget.trip.legs;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Legs')),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final legByIdx = legs[index];

          return TripLegCard(leg: legByIdx);
        },
        separatorBuilder: (context, index) {
          return _buildSeparator(index, legs);
        },
        itemCount: legs.length,
      ),
    );
  }
}
