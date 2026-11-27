import 'package:flutter/material.dart';

import '../constants/transport_colors.dart';

const List<Tab> homeStopModeTabs = [
  Tab(
    text: 'Train',
    icon: Icon(Icons.directions_train, color: Color.fromARGB(255, 255, 97, 35)),
  ),
  Tab(
    text: 'Light rail',
    icon: Icon(Icons.tram, color: Color.fromARGB(255, 255, 82, 82)),
  ),
  Tab(
    text: 'Metro',
    icon: Icon(Icons.subway, color: TransportColors.metro),
  ),
  Tab(
    text: 'Bus',
    icon: Icon(Icons.directions_bus, color: Color.fromARGB(255, 82, 186, 255)),
  ),
  Tab(
    text: 'Ferry',
    icon: Icon(Icons.directions_ferry, color: Color.fromARGB(255, 68, 240, 91)),
  ),
];
