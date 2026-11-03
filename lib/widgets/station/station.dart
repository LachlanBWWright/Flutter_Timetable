import '../../constants/transport_modes.dart';
import '../../transit/transit.dart';

typedef StationSelectionCallback = void Function(Station station);

/// Sort mode for station lists
enum SortMode { alphabetical, distance }

T _valueOr<T>(T? value, T fallback) {
  if (value != null) {
    return value;
  }
  return fallback;
}

/// A model class for station data
class Station {
  final String name;
  final String id;
  final TransportMode? mode;
  final String? lineId;
  final String? lineName;
  final bool isPreferredNearby;
  final String? nearbyBadgeLabel;
  final double? nearbyAnchorDistance;
  final int? lineStopOrder;
  final TransitStopRef? transitRef;

  // Optional metadata from GTFS/stop endpoints
  final String? stopCode;
  final String? stopDesc;
  final String? zoneId;
  final String? stopUrl;
  final String? stopTimezone;
  final String? levelId;
  final String? parentStation;
  final int? wheelchairBoarding;
  final String? platformCode;

  final double? latitude;
  final double? longitude;
  final double? distance; // Distance from user location in km

  const Station({
    required this.name,
    required this.id,
    this.mode,
    this.lineId,
    this.lineName,
    this.isPreferredNearby = false,
    this.nearbyBadgeLabel,
    this.nearbyAnchorDistance,
    this.lineStopOrder,
    this.transitRef,
    this.stopCode,
    this.stopDesc,
    this.zoneId,
    this.stopUrl,
    this.stopTimezone,
    this.levelId,
    this.parentStation,
    this.wheelchairBoarding,
    this.platformCode,
    this.latitude,
    this.longitude,
    this.distance,
  });

  /// Create a new Station with updated distance
  Station copyWith({
    String? name,
    String? id,
    TransportMode? mode,
    String? lineId,
    String? lineName,
    bool? isPreferredNearby,
    String? nearbyBadgeLabel,
    double? nearbyAnchorDistance,
    int? lineStopOrder,
    TransitStopRef? transitRef,
    String? stopCode,
    String? stopDesc,
    String? zoneId,
    String? stopUrl,
    String? stopTimezone,
    String? levelId,
    String? parentStation,
    int? wheelchairBoarding,
    String? platformCode,
    double? latitude,
    double? longitude,
    double? distance,
  }) {
    return Station(
      name: _valueOr(name, this.name),
      id: _valueOr(id, this.id),
      mode: _valueOr(mode, this.mode),
      lineId: _valueOr(lineId, this.lineId),
      lineName: _valueOr(lineName, this.lineName),
      isPreferredNearby: _valueOr(isPreferredNearby, this.isPreferredNearby),
      nearbyBadgeLabel: _valueOr(nearbyBadgeLabel, this.nearbyBadgeLabel),
      nearbyAnchorDistance: _valueOr(
        nearbyAnchorDistance,
        this.nearbyAnchorDistance,
      ),
      lineStopOrder: _valueOr(lineStopOrder, this.lineStopOrder),
      transitRef: _valueOr(transitRef, this.transitRef),
      stopCode: _valueOr(stopCode, this.stopCode),
      stopDesc: _valueOr(stopDesc, this.stopDesc),
      zoneId: _valueOr(zoneId, this.zoneId),
      stopUrl: _valueOr(stopUrl, this.stopUrl),
      stopTimezone: _valueOr(stopTimezone, this.stopTimezone),
      levelId: _valueOr(levelId, this.levelId),
      parentStation: _valueOr(parentStation, this.parentStation),
      wheelchairBoarding: _valueOr(wheelchairBoarding, this.wheelchairBoarding),
      platformCode: _valueOr(platformCode, this.platformCode),
      latitude: _valueOr(latitude, this.latitude),
      longitude: _valueOr(longitude, this.longitude),
      distance: _valueOr(distance, this.distance),
    );
  }
}
