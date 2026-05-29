import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/stops_service.dart';

import 'journey_accent_utils.dart';

class JourneyAccentStrip extends StatelessWidget {
  const JourneyAccentStrip({super.key, required this.journey});

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    final savedMode = journey.savedMode;
    if (savedMode != null) {
      final accentColor = accentColorForModeOrFallback(savedMode, journey);
      return _strip(accentColor, accentColor);
    }

    return FutureBuilder<List<TransportMode?>>(
      future: Future.wait(
        [
          StopsService.getModeForStopId(journey.originId),
          StopsService.getModeForStopId(journey.destinationId),
        ].map((future) => future.catchError((_) => null)),
      ),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final originMode = data?.firstOrNull;
        final destinationMode = data?.skip(1).firstOrNull;
        final originColor = accentColorForModeOrFallback(originMode, journey);
        final destinationColor = accentColorForModeOrFallback(
          destinationMode,
          journey,
        );

        return _strip(originColor, destinationColor);
      },
    );
  }

  Widget _strip(Color leftColor, Color rightColor) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(child: Container(height: 6, color: leftColor)),
          Expanded(child: Container(height: 6, color: rightColor)),
        ],
      ),
    );
  }
}
