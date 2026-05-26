import 'package:latlong2/latlong.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/utils/safe_value_utils.dart';

LatLng? _tryParseLatLngSafe(Object? raw) {
  try {
    return tryParseLatLng(raw);
  } catch (_) {
    return null;
  }
}

List<LatLng> legPointsForMap(Leg leg) {
  final points = <LatLng>[];
  final stopSequence = leg.stopSequence;
  if (stopSequence != null && stopSequence.isNotEmpty) {
    for (final stop in stopSequence) {
      final point = _tryParseLatLngSafe(stop.coord);
      if (point != null) {
        points.add(point);
      }
    }
  }

  final legCoords = leg.coords;
  if (points.length < 2 && legCoords != null && legCoords.length >= 2) {
    for (final coord in legCoords) {
      final point = _tryParseLatLngSafe(coord);
      if (point != null) {
        points.add(point);
      }
    }
  }

  if (points.length < 2) {
    final originPoint = _tryParseLatLngSafe(leg.origin.coord);
    final destinationPoint = _tryParseLatLngSafe(leg.destination.coord);
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
