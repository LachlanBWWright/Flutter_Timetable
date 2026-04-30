import 'package:latlong2/latlong.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';

List<LatLng> legPointsForMap(Leg leg) {
  final points = <LatLng>[];
  final stopSequence = leg.stopSequence;
  if (stopSequence != null && stopSequence.isNotEmpty) {
    for (final stop in stopSequence) {
      final coord = stop.coord;
      if (coord != null && coord.length >= 2) {
        points.add(LatLng(coord[0], coord[1]));
      }
    }
  }

  final legCoords = leg.coords;
  if (points.length < 2 && legCoords != null && legCoords.length >= 2) {
    for (final coord in legCoords) {
      if (coord.length >= 2) {
        points.add(LatLng(coord[0], coord[1]));
      }
    }
  }

  return points;
}

String realtimeMapPageTitle({required TransportMode? mode, required Leg? leg}) {
  if (mode != null) {
    return '$mode Map';
  }
  if (leg != null) {
    return 'Trip Leg Map';
  }
  return 'Realtime Map';
}

String vehicleNotFoundMessage(String vehicleId) {
  return 'No vehicle found for id $vehicleId';
}
