import 'package:flutter/material.dart';
import 'package:lbww_flutter/schema/database.dart';

import '../../active_journey/indicator.dart';
import 'journey_next_trip_subtitle.dart';

class JourneyDirectionButton extends StatelessWidget {
  const JourneyDirectionButton({
    super.key,
    required this.journey,
    required this.onTap,
    required this.showNextTripTimes,
    this.reverse = false,
  });

  final Journey journey;
  final VoidCallback onTap;
  final bool showNextTripTimes;
  final bool reverse;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        reverse ? 10 : 16,
        14,
        reverse ? 16 : 10,
        14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reverse ? journey.destination : journey.origin,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          if (showNextTripTimes)
            JourneyNextTripSubtitle(journey: journey, reverse: reverse),
          ActiveJourneyIndicator(journey: journey, reverse: reverse),
        ],
      ),
    ),
  );
}
