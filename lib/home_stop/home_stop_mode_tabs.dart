import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';
import '../widgets/station_widgets.dart';

const List<Tab> homeStopModeTabs = [
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Train stops',
      icon: Icons.directions_train,
      color: Color.fromARGB(255, 255, 97, 35),
    ),
  ),
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Light rail stops',
      icon: Icons.tram,
      color: Color.fromARGB(255, 255, 82, 82),
    ),
  ),
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Metro stops',
      icon: Icons.subway,
      color: TransportColors.metro,
    ),
  ),
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Bus stops',
      icon: Icons.directions_bus,
      color: Color.fromARGB(255, 82, 186, 255),
    ),
  ),
  Tab(
    icon: AccessibleModeTabIcon(
      label: 'Ferry stops',
      icon: Icons.directions_ferry,
      color: Color.fromARGB(255, 68, 240, 91),
    ),
  ),
];
