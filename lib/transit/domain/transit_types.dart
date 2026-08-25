import 'package:collection/collection.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';

enum TransitRegion {
  nsw,
  victoria,
  queensland,
  southAustralia,
  tasmania,
  northernTerritory,
  westernAustralia,
}

extension TransitRegionX on TransitRegion {
  String get label {
    switch (this) {
      case TransitRegion.nsw:
        return 'New South Wales';
      case TransitRegion.victoria:
        return 'Victoria';
      case TransitRegion.queensland:
        return 'Queensland';
      case TransitRegion.southAustralia:
        return 'South Australia';
      case TransitRegion.tasmania:
        return 'Tasmania';
      case TransitRegion.northernTerritory:
        return 'Northern Territory';
      case TransitRegion.westernAustralia:
        return 'Western Australia';
    }
  }

  String get shortLabel {
    switch (this) {
      case TransitRegion.nsw:
        return 'NSW';
      case TransitRegion.victoria:
        return 'VIC';
      case TransitRegion.queensland:
        return 'QLD';
      case TransitRegion.southAustralia:
        return 'SA';
      case TransitRegion.tasmania:
        return 'TAS';
      case TransitRegion.northernTerritory:
        return 'NT';
      case TransitRegion.westernAustralia:
        return 'WA';
    }
  }

  static TransitRegion fromStorage(String? value) {
    return TransitRegion.values.firstWhere(
      (region) => region.name == value,
      orElse: () => TransitRegion.nsw,
    );
  }

  static TransitRegion? fromStorageOrNull(String value) =>
      TransitRegion.values.firstWhereOrNull((region) => region.name == value);
}

enum TransitProviderId {
  tfnsw,
  ptv,
  translink,
  adelaideMetro,
  tasmaniaPublicTransport,
  ntBus,
  transperth,
}

extension TransitProviderIdX on TransitProviderId {
  String get label {
    switch (this) {
      case TransitProviderId.tfnsw:
        return 'Transport for NSW';
      case TransitProviderId.ptv:
        return 'Public Transport Victoria';
      case TransitProviderId.translink:
        return 'TransLink';
      case TransitProviderId.adelaideMetro:
        return 'Adelaide Metro';
      case TransitProviderId.tasmaniaPublicTransport:
        return 'Tasmania Public Transport';
      case TransitProviderId.ntBus:
        return 'NT Bus';
      case TransitProviderId.transperth:
        return 'Transperth';
    }
  }
}

class TransitSourceId {
  const TransitSourceId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransitSourceId &&
          runtimeType == other.runtimeType &&
          other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class TransitStopRef {
  const TransitStopRef({
    required this.region,
    required this.provider,
    required this.sourceId,
    required this.stopId,
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final TransitSourceId sourceId;
  final String stopId;

  String get storageKey =>
      '${region.name}|${provider.name}|${sourceId.value}|$stopId';

  static TransitStopRef? tryParse(String value) {
    final parts = value.split('|');
    if (parts.length != 4) {
      return null;
    }
    final region = TransitRegion.values.firstWhereOrNull(
      (candidate) => candidate.name == parts[0],
    );
    final provider = TransitProviderId.values.firstWhereOrNull(
      (candidate) => candidate.name == parts[1],
    );
    if (region == null ||
        provider == null ||
        parts[2].isEmpty ||
        parts[3].isEmpty) {
      return null;
    }
    return TransitStopRef(
      region: region,
      provider: provider,
      sourceId: TransitSourceId(parts[2]),
      stopId: parts[3],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransitStopRef &&
          runtimeType == other.runtimeType &&
          other.region == region &&
          other.provider == provider &&
          other.sourceId == sourceId &&
          other.stopId == stopId;

  @override
  int get hashCode => Object.hash(region, provider, sourceId, stopId);
}

class TransitRouteRef {
  const TransitRouteRef({
    required this.region,
    required this.provider,
    required this.sourceId,
    required this.routeId,
  });

  final TransitRegion region;
  final TransitProviderId provider;
  final TransitSourceId sourceId;
  final String routeId;

  String get storageKey =>
      '${region.name}|${provider.name}|${sourceId.value}|$routeId';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransitRouteRef &&
          runtimeType == other.runtimeType &&
          other.region == region &&
          other.provider == provider &&
          other.sourceId == sourceId &&
          other.routeId == routeId;

  @override
  int get hashCode => Object.hash(region, provider, sourceId, routeId);
}

enum TransitAccessibility { none, wheelchairPreferred, stepFreeOnly }

class TransitStop {
  const TransitStop({
    required this.ref,
    required this.name,
    this.mode,
    this.platformCode,
    this.stopCode,
    this.description,
    this.suburb,
    this.latitude,
    this.longitude,
    this.accessibility = TransitAccessibility.none,
  });

  final TransitStopRef ref;
  final String name;
  final TransportMode? mode;
  final String? platformCode;
  final String? stopCode;
  final String? description;
  final String? suburb;
  final double? latitude;
  final double? longitude;
  final TransitAccessibility accessibility;
}

class TransitRoute {
  const TransitRoute({
    required this.ref,
    required this.name,
    this.shortName,
    this.mode,
    this.description,
    this.color,
    this.textColor,
  });

  final TransitRouteRef ref;
  final String name;
  final String? shortName;
  final TransportMode? mode;
  final String? description;
  final String? color;
  final String? textColor;
}

class TransitDeparture {
  const TransitDeparture({
    required this.stop,
    this.route,
    this.tripId,
    this.destinationName,
    this.platform,
    this.plannedTime,
    this.estimatedTime,
    this.cancelled = false,
    this.statusText,
  });

  final TransitStopRef stop;
  final TransitRoute? route;
  final String? tripId;
  final String? destinationName;
  final String? platform;
  final DateTime? plannedTime;
  final DateTime? estimatedTime;
  final bool cancelled;
  final String? statusText;
}

class TransitVehicle {
  const TransitVehicle({
    required this.id,
    this.route,
    this.tripId,
    this.label,
    this.latitude,
    this.longitude,
    this.bearing,
    this.statusText,
  });

  final String id;
  final TransitRoute? route;
  final String? tripId;
  final String? label;
  final double? latitude;
  final double? longitude;
  final double? bearing;
  final String? statusText;
}

class TransitTripUpdate {
  const TransitTripUpdate({
    required this.tripId,
    this.stop,
    this.plannedTime,
    this.estimatedTime,
    this.statusText,
  });

  final String tripId;
  final TransitStopRef? stop;
  final DateTime? plannedTime;
  final DateTime? estimatedTime;
  final String? statusText;
}

class TransitAlert {
  const TransitAlert({
    required this.id,
    required this.title,
    this.description,
    this.severity,
  });

  final String id;
  final String title;
  final String? description;
  final String? severity;
}

class TransitLeg {
  const TransitLeg({
    required this.origin,
    required this.destination,
    this.route,
    this.mode,
    this.departureTime,
    this.arrivalTime,
    this.label,
    this.rawPayload,
  });

  final TransitStop origin;
  final TransitStop destination;
  final TransitRoute? route;
  final TransportMode? mode;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String? label;
  final Object? rawPayload;
}

class TransitJourney {
  const TransitJourney({required this.legs, this.rawPayload});

  final List<TransitLeg> legs;
  final Object? rawPayload;
}

class TransitServiceDate {
  const TransitServiceDate(this.value);

  final DateTime value;
}

class TransitProviderAttribution {
  const TransitProviderAttribution({
    required this.provider,
    required this.name,
    required this.licenseName,
    required this.url,
  });

  final TransitProviderId provider;
  final String name;
  final String licenseName;
  final String url;
}
