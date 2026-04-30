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

Color accentColorForJourneyFallback(Journey journey) {
  return journeyAccentColors[journey.id.abs() % journeyAccentColors.length];
}

Color accentColorForModeOrFallback(TransportMode? mode, Journey journey) {
  if (mode != null) {
    return TransportColors.getColorByTransportMode(mode);
  }
  return accentColorForJourneyFallback(journey);
}
