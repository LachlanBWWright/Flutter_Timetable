import 'package:flutter/material.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';
import 'package:lbww_flutter/widgets/trip_leg_card.dart';

class TripLegScreen extends StatefulWidget {
  const TripLegScreen({super.key, required this.trip});
  final Map<String, dynamic> trip;

  @override
  State<TripLegScreen> createState() => _TripLegScreenState();
}

class _TripLegScreenState extends State<TripLegScreen> {
  String _calculateWaitTime(Map<String, dynamic> currentLeg,
      Map<String, dynamic> nextLeg) {
    try {
      // Get arrival time of current leg
      final currentDestination = currentLeg['destination'] as Map<String, dynamic>?;
      final currentArrival = currentDestination?['arrivalTimeEstimated'] ??
          currentDestination?['arrivalTimePlanned'];

      // Get departure time of next leg
      final nextOrigin = nextLeg['origin'] as Map<String, dynamic>?;
      final nextDeparture = nextOrigin?['departureTimeEstimated'] ??
          nextOrigin?['departureTimePlanned'];

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

  Widget _buildSeparator(int index, List<Map<String, dynamic>> legs) {
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
              color: Colors.orange.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: .3)),
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
    final legs = (widget.trip['legs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Legs')),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final legByIdx = legs?[index];

          if (legByIdx == null) {
            return const Text('Leg not found.');
          }

          return TripLegCard(leg: legByIdx);
        },
        separatorBuilder: (context, index) {
          return _buildSeparator(index, legs ?? []);
        },
        itemCount: legs?.length ?? 0,
      ),
    );
  }
}
