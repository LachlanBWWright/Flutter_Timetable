part of '../trip_line_service_impl.dart';

typedef TripLineStopLookup =
    Future<List<TripLineLookupStop>> Function(String stopId);

typedef TripLineGtfsLoader = Future<GtfsData?> Function(StopsEndpoint endpoint);

class TripLineLookupStop {
  const TripLineLookupStop({
    required this.stopId,
    required this.stopName,
    required this.endpointKey,
    this.latitude,
    this.longitude,
  });

  final String stopId;
  final String stopName;
  final String endpointKey;
  final double? latitude;
  final double? longitude;
}

class StopLineMatch {
  const StopLineMatch({
    required this.mode,
    required this.lineId,
    required this.lineName,
    required this.endpointKey,
  });

  final TransportMode mode;
  final String lineId;
  final String lineName;
  final String endpointKey;
}

class LineScopedStop {
  const LineScopedStop({
    required this.stopId,
    required this.stopName,
    required this.mode,
    required this.lineId,
    required this.lineName,
    required this.endpointKey,
    required this.stopOrder,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isWithinAnchorRadius = false,
  });

  final String stopId;
  final String stopName;
  final TransportMode mode;
  final String lineId;
  final String lineName;
  final String endpointKey;
  final int stopOrder;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool isWithinAnchorRadius;

  Station toStation() {
    return Station(
      name: stopName,
      id: stopId,
      mode: mode,
      latitude: latitude,
      longitude: longitude,
      distance: distanceKm,
      lineId: lineId,
      lineName: lineName,
      isPreferredNearby: isWithinAnchorRadius,
      lineStopOrder: stopOrder,
    );
  }

  LineScopedStop copyWith({double? distanceKm, bool? isWithinAnchorRadius}) {
    return LineScopedStop(
      stopId: stopId,
      stopName: stopName,
      mode: mode,
      lineId: lineId,
      lineName: lineName,
      endpointKey: endpointKey,
      stopOrder: stopOrder,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      isWithinAnchorRadius: isWithinAnchorRadius ?? this.isWithinAnchorRadius,
    );
  }
}

class _StopCoordinate {
  const _StopCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
