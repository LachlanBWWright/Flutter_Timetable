import 'package:latlong2/latlong.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';

List<LatLng> legPointsForMap(Leg leg) {
  final points = <LatLng>[];
  final stopSequence = leg.stopSequence;
  if (stopSequence != null && stopSequence.isNotEmpty) {
    for (final stop in stopSequence) {
      final point = tryParseLatLng(stop.coord);
      if (point != null) {
        points.add(point);
      }
    }
  }

  final legCoords = leg.coords;
  if (points.length < 2 && legCoords != null && legCoords.length >= 2) {
    for (final coord in legCoords) {
      final point = tryParseLatLng(coord);
      if (point != null) {
        points.add(point);
      }
    }
  }

  if (points.length < 2) {
    final originPoint = tryParseLatLng(leg.origin.coord);
    final destinationPoint = tryParseLatLng(leg.destination.coord);
    if (originPoint != null && destinationPoint != null) {
      points.add(originPoint);
      points.add(destinationPoint);
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
