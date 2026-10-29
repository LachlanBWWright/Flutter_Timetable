import 'package:lbww_flutter/debug/debug_entity_type.dart';
import 'package:lbww_flutter/gtfs/agency.dart' as gtfs_agency;
import 'package:lbww_flutter/gtfs/gtfs_data.dart';
import 'package:lbww_flutter/gtfs/route.dart' as gtfs_route;
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart' as api;

typedef DebugEntityPageLoader =
    Future<DebugPageData> Function(DebugEntityRequest request);

enum DebugDataSource { api, realtime, gtfs, localDb, derived }

extension DebugDataSourceX on DebugDataSource {
  String get label {
    switch (this) {
      case DebugDataSource.api:
        return 'API';
      case DebugDataSource.realtime:
        return 'Realtime';
      case DebugDataSource.gtfs:
        return 'GTFS';
      case DebugDataSource.localDb:
        return 'Local DB';
      case DebugDataSource.derived:
        return 'Derived';
    }
  }
}

enum DebugReferenceState { openable, partial, unresolved }

enum DebugStatusTone { info, warning, error }

class DebugEntityContext {
  final api.TripJourney? tripJourney;
  final api.Leg? leg;
  final api.Stop? apiStop;
  final api.Transportation? transportation;
  final VehiclePosition? vehiclePosition;
  final TripUpdate? tripUpdate;
  final gtfs_route.Route? gtfsRoute;
  final gtfs_agency.Agency? gtfsAgency;
  final GtfsData? gtfsData;
  final List<VehiclePosition>? vehicles;
  final List<TripUpdate>? tripUpdates;
  final List<db.Stop>? dbStops;
  final StopsEndpoint? gtfsEndpoint;
  final String? gtfsMatchReason;
  final Map<String, dynamic>? rawPayload;
  final Map<String, Object?> extras;

  const DebugEntityContext({
    this.tripJourney,
    this.leg,
    this.apiStop,
    this.transportation,
    this.vehiclePosition,
    this.tripUpdate,
    this.gtfsRoute,
    this.gtfsAgency,
    this.gtfsData,
    this.vehicles,
    this.tripUpdates,
    this.dbStops,
    this.gtfsEndpoint,
    this.gtfsMatchReason,
    this.rawPayload,
    this.extras = const {},
  });

  DebugEntityContext copyWith({
    api.TripJourney? tripJourney,
    api.Leg? leg,
    api.Stop? apiStop,
    api.Transportation? transportation,
    VehiclePosition? vehiclePosition,
    TripUpdate? tripUpdate,
    gtfs_route.Route? gtfsRoute,
    gtfs_agency.Agency? gtfsAgency,
    GtfsData? gtfsData,
    List<VehiclePosition>? vehicles,
    List<TripUpdate>? tripUpdates,
    List<db.Stop>? dbStops,
    StopsEndpoint? gtfsEndpoint,
    String? gtfsMatchReason,
    Map<String, dynamic>? rawPayload,
    Map<String, Object?>? extras,
  }) {
    return DebugEntityContext(
      tripJourney: tripJourney ?? this.tripJourney,
      leg: leg ?? this.leg,
      apiStop: apiStop ?? this.apiStop,
      transportation: transportation ?? this.transportation,
      vehiclePosition: vehiclePosition ?? this.vehiclePosition,
      tripUpdate: tripUpdate ?? this.tripUpdate,
      gtfsRoute: gtfsRoute ?? this.gtfsRoute,
      gtfsAgency: gtfsAgency ?? this.gtfsAgency,
      gtfsData: gtfsData ?? this.gtfsData,
      vehicles: vehicles ?? this.vehicles,
      tripUpdates: tripUpdates ?? this.tripUpdates,
      dbStops: dbStops ?? this.dbStops,
      gtfsEndpoint: gtfsEndpoint ?? this.gtfsEndpoint,
      gtfsMatchReason: gtfsMatchReason ?? this.gtfsMatchReason,
      rawPayload: rawPayload ?? this.rawPayload,
      extras: extras ?? this.extras,
    );
  }
}

class DebugEntityRequest {
  final DebugEntityType entityType;
  final String entityId;
  final DebugEntityContext context;

  const DebugEntityRequest({
    required this.entityType,
    required this.entityId,
    this.context = const DebugEntityContext(),
  });

  DebugEntityRequest copyWith({
    DebugEntityType? entityType,
    String? entityId,
    DebugEntityContext? context,
  }) {
    return DebugEntityRequest(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      context: context ?? this.context,
    );
  }
}

class DebugFieldRow {
  final String label;
  final String value;
  final String? copyValue;
  final String? badge;
  final List<DebugDataSource> sources;

  const DebugFieldRow({
    required this.label,
    required this.value,
    this.copyValue,
    this.badge,
    this.sources = const [],
  });
}

class DebugStatusBannerData {
  final DebugStatusTone tone;
  final String message;
  final String? title;
  final List<DebugDataSource> sources;

  const DebugStatusBannerData({
    required this.tone,
    required this.message,
    this.title,
    this.sources = const [],
  });
}

class DebugJsonBlock {
  final String title;
  final Object? data;
  final String emptyMessage;
  final List<DebugDataSource> sources;

  const DebugJsonBlock({
    required this.title,
    required this.data,
    this.emptyMessage = 'No raw data available.',
    this.sources = const [],
  });
}

class DebugEntityRef {
  final DebugEntityType entityType;
  final String entityId;
  final String title;
  final String? subtitle;
  final DebugReferenceState state;
  final String? reason;
  final List<DebugDataSource> sources;
  final DebugEntityRequest? request;

  const DebugEntityRef({
    required this.entityType,
    required this.entityId,
    required this.title,
    this.subtitle,
    this.state = DebugReferenceState.openable,
    this.reason,
    this.sources = const [],
    this.request,
  });

  bool get canOpen =>
      request != null && state != DebugReferenceState.unresolved;
}

class DebugSectionData {
  final String title;
  final List<DebugFieldRow> fields;
  final List<DebugEntityRef> references;
  final List<DebugJsonBlock> rawJsonBlocks;
  final String? emptyMessage;
  final List<DebugDataSource> sources;

  const DebugSectionData({
    required this.title,
    this.fields = const [],
    this.references = const [],
    this.rawJsonBlocks = const [],
    this.emptyMessage,
    this.sources = const [],
  });

  bool get isEmpty =>
      fields.isEmpty && references.isEmpty && rawJsonBlocks.isEmpty;
}

class DebugPageData {
  final DebugEntityType entityType;
  final String title;
  final String canonicalId;
  final List<String> aliases;
  final List<DebugDataSource> sourceBadges;
  final List<DebugStatusBannerData> banners;
  final List<DebugSectionData> sections;

  const DebugPageData({
    required this.entityType,
    required this.title,
    required this.canonicalId,
    this.aliases = const [],
    this.sourceBadges = const [],
    this.banners = const [],
    this.sections = const [],
  });
}
