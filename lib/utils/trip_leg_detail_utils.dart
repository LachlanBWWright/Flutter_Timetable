import 'package:latlong2/latlong.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';

import 'date_time_utils.dart';

int? extractTransportClassFromLeg(Map<String, dynamic>? leg) {
  if (leg == null) return 5;
  final transportation = leg['transportation'];
  if (transportation is! Map<String, dynamic>) return 5;
  final product = transportation['product'];
  if (product is! Map<String, dynamic>) return 5;

  final raw = product['class'];
  if (raw == null) return null;
  if (raw is int) return raw;
  return int.tryParse('$raw');
}

String? extractTripId(Map<String, dynamic>? leg) {
  if (leg == null) return null;
  final transportationRaw = leg['transportation'];
  final transportation = transportationRaw is Map<String, dynamic>
      ? transportationRaw
      : null;
  if (transportation == null) return null;
  final id = transportation['id'];
  return id == null ? null : '$id';
}

TransportMode? realtimeModeFromClass(int transportClass) {
  switch (transportClass) {
    case 1:
      return TransportMode.train;
    case 4:
      return TransportMode.lightrail;
    case 5:
    case 11:
      return TransportMode.bus;
    case 9:
      return TransportMode.ferry;
    default:
      return null;
  }
}

LatLng? parseStopCoord(Map<String, dynamic>? stop) {
  if (stop == null || stop['coord'] == null) {
    return null;
  }

  final coord = stop['coord'] as List?;
  if (coord == null ||
      coord.length < 2 ||
      coord[0] == null ||
      coord[1] == null) {
    return null;
  }

  return LatLng((coord[0] as num).toDouble(), (coord[1] as num).toDouble());
}

String formatTimeDifference(String? plannedTime, String? estimatedTime) {
  if (estimatedTime == null) {
    return plannedTime != null
        ? DateTimeUtils.parseTimeOnly(plannedTime)
        : 'TBD';
  }

  if (plannedTime == null) {
    return DateTimeUtils.parseTimeOnly(estimatedTime);
  }

  final planned = DateTimeUtils.parseTimeToDateTime(plannedTime);
  final estimated = DateTimeUtils.parseTimeToDateTime(estimatedTime);

  if (planned == null || estimated == null) {
    return DateTimeUtils.parseTimeOnly(estimatedTime);
  }

  final difference = estimated.difference(planned).inMinutes;
  if (difference == 0) {
    return DateTimeUtils.parseTimeOnly(estimatedTime);
  }

  if (difference > 0) {
    return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (+${difference}m late)';
  }

  return '${DateTimeUtils.parseTimeOnly(estimatedTime)} (${difference.abs()}m early)';
}
