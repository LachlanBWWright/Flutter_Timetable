import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/schema/database.dart';

const journeyAccentColors = [
  TransportColors.train,
  TransportColors.bus,
  TransportColors.metro,
  TransportColors.ferry,
  TransportColors.lightRail,
  TransportColors.coach,
  TransportColors.trainsT2,
  TransportColors.trainsT9,
  TransportColors.trainsT5,
  TransportColors.trainsT8,
];

Color _firstJourneyAccentColor() {
  final firstColor = journeyAccentColors.firstOrNull;
  return firstColor ?? TransportColors.bus;
}

Color accentColorForJourneyFallback(Journey journey) {
  final accentCount = journeyAccentColors.length;
  if (accentCount <= 0) {
    return TransportColors.bus;
  }

  final accentIndex = journey.id.abs() % accentCount;
  var currentIndex = 0;
  for (final accentColor in journeyAccentColors) {
    if (currentIndex == accentIndex) {
      return accentColor;
    }
    currentIndex += 1;
  }

  return _firstJourneyAccentColor();
}

Color accentColorForModeOrFallback(TransportMode? mode, Journey journey) {
  if (mode != null) {
    return TransportColors.getColorByTransportMode(mode);
  }
  try {
    return accentColorForJourneyFallback(journey);
  } catch (_) {
    return _firstJourneyAccentColor();
  }
}
