import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/vehicle_finder/models.dart';

final epoch = DateTime.utc(2026, 10, 20, 1);
DateTime instant(int seconds) => epoch.add(Duration(seconds: seconds));
FinderLocation phone(
  int seconds, {
  double? longitude,
  double accuracy = 10,
  double? speed = 10,
  double? heading = 90,
}) => FinderLocation(
  latitude: -33.86,
  longitude: longitude ?? 151.2 + seconds * 0.0001,
  timestamp: instant(seconds),
  accuracy: accuracy,
  speed: speed,
  heading: heading,
);
FinderVehicle vehicle(
  int seconds, {
  String id = 'train-1',
  String trip = 'trip',
  double? longitude,
  double? speed = 10,
  double? heading = 90,
  TransportMode mode = TransportMode.train,
}) => FinderVehicle(
  id: id,
  mode: mode,
  latitude: -33.86,
  longitude: longitude ?? 151.2 + seconds * 0.0001,
  observedAt: instant(seconds),
  tripKey: trip,
  speed: speed,
  heading: heading,
);
