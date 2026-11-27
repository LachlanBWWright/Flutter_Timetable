// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ptv_timetable_v3.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

V3CacheKeysRemoveResponse _$V3CacheKeysRemoveResponseFromJson(
  Map<String, dynamic> json,
) => V3CacheKeysRemoveResponse(
  keys: json['keys'] as Map<String, dynamic>?,
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3CacheKeysRemoveResponseToJson(
  V3CacheKeysRemoveResponse instance,
) => <String, dynamic>{
  'keys': instance.keys,
  'status': instance.status?.toJson(),
};

V3CacheKeyRemoved _$V3CacheKeyRemovedFromJson(Map<String, dynamic> json) =>
    V3CacheKeyRemoved(removed: json['Removed'] as bool?);

Map<String, dynamic> _$V3CacheKeyRemovedToJson(V3CacheKeyRemoved instance) =>
    <String, dynamic>{'Removed': instance.removed};

V3Status _$V3StatusFromJson(Map<String, dynamic> json) => V3Status(
  version: json['version'] as String?,
  health: (json['health'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3StatusToJson(V3Status instance) => <String, dynamic>{
  'version': instance.version,
  'health': instance.health,
};

V3ErrorResponse _$V3ErrorResponseFromJson(Map<String, dynamic> json) =>
    V3ErrorResponse(
      message: json['message'] as String?,
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3ErrorResponseToJson(V3ErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status?.toJson(),
    };

V3CacheKeyResponse _$V3CacheKeyResponseFromJson(Map<String, dynamic> json) =>
    V3CacheKeyResponse(
      keys: json['keys'] as Map<String, dynamic>?,
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3CacheKeyResponseToJson(V3CacheKeyResponse instance) =>
    <String, dynamic>{
      'keys': instance.keys,
      'status': instance.status?.toJson(),
    };

V3CacheItem _$V3CacheItemFromJson(Map<String, dynamic> json) =>
    V3CacheItem(type: json['Type'] as String?, value: json['Value']);

Map<String, dynamic> _$V3CacheItemToJson(V3CacheItem instance) =>
    <String, dynamic>{'Type': instance.type, 'Value': instance.value};

V3DeparturesBroadParameters _$V3DeparturesBroadParametersFromJson(
  Map<String, dynamic> json,
) => V3DeparturesBroadParameters(
  platformNumbers:
      (json['platform_numbers'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  directionId: (json['direction_id'] as num?)?.toInt(),
  gtfs: json['gtfs'] as bool?,
  dateUtc: json['date_utc'] == null
      ? null
      : DateTime.parse(json['date_utc'] as String),
  maxResults: (json['max_results'] as num?)?.toInt(),
  includeCancelled: json['include_cancelled'] as bool?,
  lookBackwards: json['look_backwards'] as bool?,
  expand:
      (json['expand'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  includeGeopath: json['include_geopath'] as bool?,
);

Map<String, dynamic> _$V3DeparturesBroadParametersToJson(
  V3DeparturesBroadParameters instance,
) => <String, dynamic>{
  'platform_numbers': instance.platformNumbers,
  'direction_id': instance.directionId,
  'gtfs': instance.gtfs,
  'date_utc': instance.dateUtc?.toIso8601String(),
  'max_results': instance.maxResults,
  'include_cancelled': instance.includeCancelled,
  'look_backwards': instance.lookBackwards,
  'expand': instance.expand,
  'include_geopath': instance.includeGeopath,
};

V3DeparturesResponse _$V3DeparturesResponseFromJson(
  Map<String, dynamic> json,
) => V3DeparturesResponse(
  departures:
      (json['departures'] as List<dynamic>?)
          ?.map((e) => V3Departure.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  stops: json['stops'] as Map<String, dynamic>?,
  routes: json['routes'] as Map<String, dynamic>?,
  runs: json['runs'] as Map<String, dynamic>?,
  directions: json['directions'] as Map<String, dynamic>?,
  disruptions: json['disruptions'] as Map<String, dynamic>?,
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3DeparturesResponseToJson(
  V3DeparturesResponse instance,
) => <String, dynamic>{
  'departures': instance.departures?.map((e) => e.toJson()).toList(),
  'stops': instance.stops,
  'routes': instance.routes,
  'runs': instance.runs,
  'directions': instance.directions,
  'disruptions': instance.disruptions,
  'status': instance.status?.toJson(),
};

V3Departure _$V3DepartureFromJson(Map<String, dynamic> json) => V3Departure(
  stopId: (json['stop_id'] as num?)?.toInt(),
  routeId: (json['route_id'] as num?)?.toInt(),
  runId: (json['run_id'] as num?)?.toInt(),
  runRef: json['run_ref'] as String?,
  directionId: (json['direction_id'] as num?)?.toInt(),
  disruptionIds:
      (json['disruption_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  scheduledDepartureUtc: json['scheduled_departure_utc'] == null
      ? null
      : DateTime.parse(json['scheduled_departure_utc'] as String),
  estimatedDepartureUtc: json['estimated_departure_utc'] == null
      ? null
      : DateTime.parse(json['estimated_departure_utc'] as String),
  atPlatform: json['at_platform'] as bool?,
  platformNumber: json['platform_number'] as String?,
  flags: json['flags'] as String?,
  departureSequence: (json['departure_sequence'] as num?)?.toInt(),
  departureNote: json['departure_note'] as String?,
);

Map<String, dynamic> _$V3DepartureToJson(
  V3Departure instance,
) => <String, dynamic>{
  'stop_id': instance.stopId,
  'route_id': instance.routeId,
  'run_id': instance.runId,
  'run_ref': instance.runRef,
  'direction_id': instance.directionId,
  'disruption_ids': instance.disruptionIds,
  'scheduled_departure_utc': instance.scheduledDepartureUtc?.toIso8601String(),
  'estimated_departure_utc': instance.estimatedDepartureUtc?.toIso8601String(),
  'at_platform': instance.atPlatform,
  'platform_number': instance.platformNumber,
  'flags': instance.flags,
  'departure_sequence': instance.departureSequence,
  'departure_note': instance.departureNote,
};

V3StopModel _$V3StopModelFromJson(Map<String, dynamic> json) => V3StopModel(
  stopDistance: (json['stop_distance'] as num?)?.toDouble(),
  stopSuburb: json['stop_suburb'] as String?,
  stopName: json['stop_name'] as String?,
  stopId: (json['stop_id'] as num?)?.toInt(),
  routeType: (json['route_type'] as num?)?.toInt(),
  stopLatitude: (json['stop_latitude'] as num?)?.toDouble(),
  stopLongitude: (json['stop_longitude'] as num?)?.toDouble(),
  stopLandmark: json['stop_landmark'] as String?,
  stopSequence: (json['stop_sequence'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3StopModelToJson(V3StopModel instance) =>
    <String, dynamic>{
      'stop_distance': instance.stopDistance,
      'stop_suburb': instance.stopSuburb,
      'stop_name': instance.stopName,
      'stop_id': instance.stopId,
      'route_type': instance.routeType,
      'stop_latitude': instance.stopLatitude,
      'stop_longitude': instance.stopLongitude,
      'stop_landmark': instance.stopLandmark,
      'stop_sequence': instance.stopSequence,
    };

V3Run _$V3RunFromJson(Map<String, dynamic> json) => V3Run(
  runId: (json['run_id'] as num?)?.toInt(),
  runRef: json['run_ref'] as String?,
  routeId: (json['route_id'] as num?)?.toInt(),
  routeType: (json['route_type'] as num?)?.toInt(),
  finalStopId: (json['final_stop_id'] as num?)?.toInt(),
  destinationName: json['destination_name'] as String?,
  status: json['status'] as String?,
  directionId: (json['direction_id'] as num?)?.toInt(),
  runSequence: (json['run_sequence'] as num?)?.toInt(),
  expressStopCount: (json['express_stop_count'] as num?)?.toInt(),
  vehiclePosition: json['vehicle_position'] == null
      ? null
      : V3VehiclePosition.fromJson(
          json['vehicle_position'] as Map<String, dynamic>,
        ),
  vehicleDescriptor: json['vehicle_descriptor'] == null
      ? null
      : V3VehicleDescriptor.fromJson(
          json['vehicle_descriptor'] as Map<String, dynamic>,
        ),
  geopath:
      (json['geopath'] as List<dynamic>?)?.map((e) => e as Object).toList() ??
      [],
  interchange: json['interchange'] == null
      ? null
      : V3Interchange.fromJson(json['interchange'] as Map<String, dynamic>),
  runNote: json['run_note'] as String?,
  externalService: (json['externalService'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3RunToJson(V3Run instance) => <String, dynamic>{
  'run_id': instance.runId,
  'run_ref': instance.runRef,
  'route_id': instance.routeId,
  'route_type': instance.routeType,
  'final_stop_id': instance.finalStopId,
  'destination_name': instance.destinationName,
  'status': instance.status,
  'direction_id': instance.directionId,
  'run_sequence': instance.runSequence,
  'express_stop_count': instance.expressStopCount,
  'vehicle_position': instance.vehiclePosition?.toJson(),
  'vehicle_descriptor': instance.vehicleDescriptor?.toJson(),
  'geopath': instance.geopath,
  'interchange': instance.interchange?.toJson(),
  'run_note': instance.runNote,
  'externalService': instance.externalService,
};

V3Direction _$V3DirectionFromJson(Map<String, dynamic> json) => V3Direction(
  directionId: (json['direction_id'] as num?)?.toInt(),
  directionName: json['direction_name'] as String?,
  routeId: (json['route_id'] as num?)?.toInt(),
  routeType: (json['route_type'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3DirectionToJson(V3Direction instance) =>
    <String, dynamic>{
      'direction_id': instance.directionId,
      'direction_name': instance.directionName,
      'route_id': instance.routeId,
      'route_type': instance.routeType,
    };

V3Disruption _$V3DisruptionFromJson(Map<String, dynamic> json) => V3Disruption(
  disruptionId: (json['disruption_id'] as num?)?.toInt(),
  title: json['title'] as String?,
  url: json['url'] as String?,
  description: json['description'] as String?,
  disruptionStatus: json['disruption_status'] as String?,
  disruptionType: json['disruption_type'] as String?,
  publishedOn: json['published_on'] == null
      ? null
      : DateTime.parse(json['published_on'] as String),
  lastUpdated: json['last_updated'] == null
      ? null
      : DateTime.parse(json['last_updated'] as String),
  fromDate: json['from_date'] == null
      ? null
      : DateTime.parse(json['from_date'] as String),
  toDate: json['to_date'] == null
      ? null
      : DateTime.parse(json['to_date'] as String),
  routes:
      (json['routes'] as List<dynamic>?)
          ?.map((e) => V3DisruptionRoute.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  stops:
      (json['stops'] as List<dynamic>?)
          ?.map((e) => V3DisruptionStop.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  colour: json['colour'] as String?,
  displayOnBoard: json['display_on_board'] as bool?,
  displayStatus: json['display_status'] as bool?,
);

Map<String, dynamic> _$V3DisruptionToJson(V3Disruption instance) =>
    <String, dynamic>{
      'disruption_id': instance.disruptionId,
      'title': instance.title,
      'url': instance.url,
      'description': instance.description,
      'disruption_status': instance.disruptionStatus,
      'disruption_type': instance.disruptionType,
      'published_on': instance.publishedOn?.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'from_date': instance.fromDate?.toIso8601String(),
      'to_date': instance.toDate?.toIso8601String(),
      'routes': instance.routes?.map((e) => e.toJson()).toList(),
      'stops': instance.stops?.map((e) => e.toJson()).toList(),
      'colour': instance.colour,
      'display_on_board': instance.displayOnBoard,
      'display_status': instance.displayStatus,
    };

V3VehiclePosition _$V3VehiclePositionFromJson(Map<String, dynamic> json) =>
    V3VehiclePosition(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      easting: (json['easting'] as num?)?.toDouble(),
      northing: (json['northing'] as num?)?.toDouble(),
      direction: json['direction'] as String?,
      bearing: (json['bearing'] as num?)?.toDouble(),
      supplier: json['supplier'] as String?,
      datetimeUtc: json['datetime_utc'] == null
          ? null
          : DateTime.parse(json['datetime_utc'] as String),
      expiryTime: json['expiry_time'] == null
          ? null
          : DateTime.parse(json['expiry_time'] as String),
    );

Map<String, dynamic> _$V3VehiclePositionToJson(V3VehiclePosition instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'easting': instance.easting,
      'northing': instance.northing,
      'direction': instance.direction,
      'bearing': instance.bearing,
      'supplier': instance.supplier,
      'datetime_utc': instance.datetimeUtc?.toIso8601String(),
      'expiry_time': instance.expiryTime?.toIso8601String(),
    };

V3VehicleDescriptor _$V3VehicleDescriptorFromJson(Map<String, dynamic> json) =>
    V3VehicleDescriptor(
      $operator: json['operator'] as String?,
      id: json['id'] as String?,
      lowFloor: json['low_floor'] as bool?,
      airConditioned: json['air_conditioned'] as bool?,
      description: json['description'] as String?,
      supplier: json['supplier'] as String?,
      length: json['length'] as String?,
    );

Map<String, dynamic> _$V3VehicleDescriptorToJson(
  V3VehicleDescriptor instance,
) => <String, dynamic>{
  'operator': instance.$operator,
  'id': instance.id,
  'low_floor': instance.lowFloor,
  'air_conditioned': instance.airConditioned,
  'description': instance.description,
  'supplier': instance.supplier,
  'length': instance.length,
};

V3Interchange _$V3InterchangeFromJson(Map<String, dynamic> json) =>
    V3Interchange(
      feeder: json['feeder'] == null
          ? null
          : V3InterchangeRun.fromJson(json['feeder'] as Map<String, dynamic>),
      distributor: json['distributor'] == null
          ? null
          : V3InterchangeRun.fromJson(
              json['distributor'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$V3InterchangeToJson(V3Interchange instance) =>
    <String, dynamic>{
      'feeder': instance.feeder?.toJson(),
      'distributor': instance.distributor?.toJson(),
    };

V3DisruptionRoute _$V3DisruptionRouteFromJson(Map<String, dynamic> json) =>
    V3DisruptionRoute(
      routeType: (json['route_type'] as num?)?.toInt(),
      routeId: (json['route_id'] as num?)?.toInt(),
      routeName: json['route_name'] as String?,
      routeNumber: json['route_number'] as String?,
      routeGtfsId: json['route_gtfs_id'] as String?,
      direction: json['direction'] == null
          ? null
          : V3DisruptionDirection.fromJson(
              json['direction'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$V3DisruptionRouteToJson(V3DisruptionRoute instance) =>
    <String, dynamic>{
      'route_type': instance.routeType,
      'route_id': instance.routeId,
      'route_name': instance.routeName,
      'route_number': instance.routeNumber,
      'route_gtfs_id': instance.routeGtfsId,
      'direction': instance.direction?.toJson(),
    };

V3DisruptionStop _$V3DisruptionStopFromJson(Map<String, dynamic> json) =>
    V3DisruptionStop(
      stopId: (json['stop_id'] as num?)?.toInt(),
      stopName: json['stop_name'] as String?,
    );

Map<String, dynamic> _$V3DisruptionStopToJson(V3DisruptionStop instance) =>
    <String, dynamic>{
      'stop_id': instance.stopId,
      'stop_name': instance.stopName,
    };

V3InterchangeRun _$V3InterchangeRunFromJson(Map<String, dynamic> json) =>
    V3InterchangeRun(
      runRef: json['run_ref'] as String?,
      routeId: (json['route_id'] as num?)?.toInt(),
      stopId: (json['stop_id'] as num?)?.toInt(),
      advertised: json['advertised'] as bool?,
      directionId: (json['direction_id'] as num?)?.toInt(),
      destinationName: json['destination_name'] as String?,
    );

Map<String, dynamic> _$V3InterchangeRunToJson(V3InterchangeRun instance) =>
    <String, dynamic>{
      'run_ref': instance.runRef,
      'route_id': instance.routeId,
      'stop_id': instance.stopId,
      'advertised': instance.advertised,
      'direction_id': instance.directionId,
      'destination_name': instance.destinationName,
    };

V3DisruptionDirection _$V3DisruptionDirectionFromJson(
  Map<String, dynamic> json,
) => V3DisruptionDirection(
  routeDirectionId: (json['route_direction_id'] as num?)?.toInt(),
  directionId: (json['direction_id'] as num?)?.toInt(),
  directionName: json['direction_name'] as String?,
  serviceTime: json['service_time'] as String?,
);

Map<String, dynamic> _$V3DisruptionDirectionToJson(
  V3DisruptionDirection instance,
) => <String, dynamic>{
  'route_direction_id': instance.routeDirectionId,
  'direction_id': instance.directionId,
  'direction_name': instance.directionName,
  'service_time': instance.serviceTime,
};

V3DeparturesSpecificParameters _$V3DeparturesSpecificParametersFromJson(
  Map<String, dynamic> json,
) => V3DeparturesSpecificParameters(
  directionId: (json['direction_id'] as num?)?.toInt(),
  gtfs: json['gtfs'] as bool?,
  dateUtc: json['date_utc'] == null
      ? null
      : DateTime.parse(json['date_utc'] as String),
  maxResults: (json['max_results'] as num?)?.toInt(),
  includeCancelled: json['include_cancelled'] as bool?,
  lookBackwards: json['look_backwards'] as bool?,
  expand:
      (json['expand'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  includeGeopath: json['include_geopath'] as bool?,
);

Map<String, dynamic> _$V3DeparturesSpecificParametersToJson(
  V3DeparturesSpecificParameters instance,
) => <String, dynamic>{
  'direction_id': instance.directionId,
  'gtfs': instance.gtfs,
  'date_utc': instance.dateUtc?.toIso8601String(),
  'max_results': instance.maxResults,
  'include_cancelled': instance.includeCancelled,
  'look_backwards': instance.lookBackwards,
  'expand': instance.expand,
  'include_geopath': instance.includeGeopath,
};

V3RouteDeparturesSpecificParameters
_$V3RouteDeparturesSpecificParametersFromJson(Map<String, dynamic> json) =>
    V3RouteDeparturesSpecificParameters(
      trainScheduledTimetables: json['train_scheduled_timetables'] as bool?,
      scheduledTimetables: json['scheduled_timetables'] as bool?,
      includeAdvertisedInterchange:
          json['include_advertised_interchange'] as bool?,
      dateUtc: json['date_utc'] == null
          ? null
          : DateTime.parse(json['date_utc'] as String),
      maxResults: (json['max_results'] as num?)?.toInt(),
      includeCancelled: json['include_cancelled'] as bool?,
      lookBackwards: json['look_backwards'] as bool?,
      expand:
          (json['expand'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      includeGeopath: json['include_geopath'] as bool?,
    );

Map<String, dynamic> _$V3RouteDeparturesSpecificParametersToJson(
  V3RouteDeparturesSpecificParameters instance,
) => <String, dynamic>{
  'train_scheduled_timetables': instance.trainScheduledTimetables,
  'scheduled_timetables': instance.scheduledTimetables,
  'include_advertised_interchange': instance.includeAdvertisedInterchange,
  'date_utc': instance.dateUtc?.toIso8601String(),
  'max_results': instance.maxResults,
  'include_cancelled': instance.includeCancelled,
  'look_backwards': instance.lookBackwards,
  'expand': instance.expand,
  'include_geopath': instance.includeGeopath,
};

V3BulkDeparturesRequest _$V3BulkDeparturesRequestFromJson(
  Map<String, dynamic> json,
) => V3BulkDeparturesRequest(
  requests:
      (json['requests'] as List<dynamic>?)
          ?.map(
            (e) => V3StopDepartureRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  dateUtc: json['date_utc'] == null
      ? null
      : DateTime.parse(json['date_utc'] as String),
  lookBackwards: json['look_backwards'] as bool?,
  includeCancelled: json['include_cancelled'] as bool?,
  includeGeopath: json['include_geopath'] as bool?,
  expand:
      (json['expand'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  includeAdvertisedInterchange: json['include_advertised_interchange'] as bool?,
);

Map<String, dynamic> _$V3BulkDeparturesRequestToJson(
  V3BulkDeparturesRequest instance,
) => <String, dynamic>{
  'requests': instance.requests.map((e) => e.toJson()).toList(),
  'date_utc': instance.dateUtc?.toIso8601String(),
  'look_backwards': instance.lookBackwards,
  'include_cancelled': instance.includeCancelled,
  'include_geopath': instance.includeGeopath,
  'expand': instance.expand,
  'include_advertised_interchange': instance.includeAdvertisedInterchange,
};

V3StopDepartureRequest _$V3StopDepartureRequestFromJson(
  Map<String, dynamic> json,
) => V3StopDepartureRequest(
  routeType: (json['route_type'] as num?)?.toInt(),
  stopId: (json['stop_id'] as num?)?.toInt(),
  maxResults: (json['max_results'] as num?)?.toInt(),
  gtfs: json['gtfs'] as bool?,
  routeDirections:
      (json['route_directions'] as List<dynamic>?)
          ?.map(
            (e) => V3StopDepartureRequestRouteDirection.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$V3StopDepartureRequestToJson(
  V3StopDepartureRequest instance,
) => <String, dynamic>{
  'route_type': instance.routeType,
  'stop_id': instance.stopId,
  'max_results': instance.maxResults,
  'gtfs': instance.gtfs,
  'route_directions': instance.routeDirections.map((e) => e.toJson()).toList(),
};

V3StopDepartureRequestRouteDirection
_$V3StopDepartureRequestRouteDirectionFromJson(Map<String, dynamic> json) =>
    V3StopDepartureRequestRouteDirection(
      routeId: json['route_id'] as String?,
      directionId: (json['direction_id'] as num?)?.toInt(),
      directionName: json['direction_name'] as String,
    );

Map<String, dynamic> _$V3StopDepartureRequestRouteDirectionToJson(
  V3StopDepartureRequestRouteDirection instance,
) => <String, dynamic>{
  'route_id': instance.routeId,
  'direction_id': instance.directionId,
  'direction_name': instance.directionName,
};

V3BulkDeparturesResponse _$V3BulkDeparturesResponseFromJson(
  Map<String, dynamic> json,
) => V3BulkDeparturesResponse(
  responses:
      (json['responses'] as List<dynamic>?)
          ?.map(
            (e) => V3BulkDeparturesUpdateResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [],
  stops: json['stops'] as Map<String, dynamic>?,
  routes:
      (json['routes'] as List<dynamic>?)?.map((e) => e as Object).toList() ??
      [],
  runs:
      (json['runs'] as List<dynamic>?)
          ?.map((e) => V3Run.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  directions:
      (json['directions'] as List<dynamic>?)
          ?.map((e) => V3Direction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  disruptions: json['disruptions'] as Map<String, dynamic>?,
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3BulkDeparturesResponseToJson(
  V3BulkDeparturesResponse instance,
) => <String, dynamic>{
  'responses': instance.responses?.map((e) => e.toJson()).toList(),
  'stops': instance.stops,
  'routes': instance.routes,
  'runs': instance.runs?.map((e) => e.toJson()).toList(),
  'directions': instance.directions?.map((e) => e.toJson()).toList(),
  'disruptions': instance.disruptions,
  'status': instance.status?.toJson(),
};

V3BulkDeparturesUpdateResponse _$V3BulkDeparturesUpdateResponseFromJson(
  Map<String, dynamic> json,
) => V3BulkDeparturesUpdateResponse(
  departures:
      (json['departures'] as List<dynamic>?)
          ?.map((e) => V3Departure.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  routeType: (json['route_type'] as num?)?.toInt(),
  stopId: (json['stop_id'] as num?)?.toInt(),
  requestedRouteDirection: json['requested_route_direction'] == null
      ? null
      : V3BulkDeparturesRouteDirectionResponse.fromJson(
          json['requested_route_direction'] as Map<String, dynamic>,
        ),
  routeDirectionStatus: json['route_direction_status'] as String?,
  routeDirection: json['route_direction'] == null
      ? null
      : V3BulkDeparturesRouteDirectionResponse.fromJson(
          json['route_direction'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$V3BulkDeparturesUpdateResponseToJson(
  V3BulkDeparturesUpdateResponse instance,
) => <String, dynamic>{
  'departures': instance.departures?.map((e) => e.toJson()).toList(),
  'route_type': instance.routeType,
  'stop_id': instance.stopId,
  'requested_route_direction': instance.requestedRouteDirection?.toJson(),
  'route_direction_status': instance.routeDirectionStatus,
  'route_direction': instance.routeDirection?.toJson(),
};

V3BulkDeparturesStopResponse _$V3BulkDeparturesStopResponseFromJson(
  Map<String, dynamic> json,
) => V3BulkDeparturesStopResponse(
  stopName: json['stop_name'] as String?,
  stopId: (json['stop_id'] as num?)?.toInt(),
  stopLatitude: (json['stop_latitude'] as num?)?.toDouble(),
  stopLongitude: (json['stop_longitude'] as num?)?.toDouble(),
  stopSuburb: json['stop_suburb'] as String?,
  stopLandmark: json['stop_landmark'] as String?,
);

Map<String, dynamic> _$V3BulkDeparturesStopResponseToJson(
  V3BulkDeparturesStopResponse instance,
) => <String, dynamic>{
  'stop_name': instance.stopName,
  'stop_id': instance.stopId,
  'stop_latitude': instance.stopLatitude,
  'stop_longitude': instance.stopLongitude,
  'stop_suburb': instance.stopSuburb,
  'stop_landmark': instance.stopLandmark,
};

V3BulkDeparturesRouteDirectionResponse
_$V3BulkDeparturesRouteDirectionResponseFromJson(Map<String, dynamic> json) =>
    V3BulkDeparturesRouteDirectionResponse(
      routeId: json['route_id'] as String?,
      directionId: (json['direction_id'] as num?)?.toInt(),
      directionName: json['direction_name'] as String?,
    );

Map<String, dynamic> _$V3BulkDeparturesRouteDirectionResponseToJson(
  V3BulkDeparturesRouteDirectionResponse instance,
) => <String, dynamic>{
  'route_id': instance.routeId,
  'direction_id': instance.directionId,
  'direction_name': instance.directionName,
};

V3DirectionsResponse _$V3DirectionsResponseFromJson(
  Map<String, dynamic> json,
) => V3DirectionsResponse(
  directions:
      (json['directions'] as List<dynamic>?)
          ?.map(
            (e) =>
                V3DirectionWithDescription.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3DirectionsResponseToJson(
  V3DirectionsResponse instance,
) => <String, dynamic>{
  'directions': instance.directions?.map((e) => e.toJson()).toList(),
  'status': instance.status?.toJson(),
};

V3DirectionWithDescription _$V3DirectionWithDescriptionFromJson(
  Map<String, dynamic> json,
) => V3DirectionWithDescription(
  routeDirectionDescription: json['route_direction_description'] as String?,
  directionId: (json['direction_id'] as num?)?.toInt(),
  directionName: json['direction_name'] as String?,
  routeId: (json['route_id'] as num?)?.toInt(),
  routeType: (json['route_type'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3DirectionWithDescriptionToJson(
  V3DirectionWithDescription instance,
) => <String, dynamic>{
  'route_direction_description': instance.routeDirectionDescription,
  'direction_id': instance.directionId,
  'direction_name': instance.directionName,
  'route_id': instance.routeId,
  'route_type': instance.routeType,
};

V3DisruptionsResponse _$V3DisruptionsResponseFromJson(
  Map<String, dynamic> json,
) => V3DisruptionsResponse(
  disruptions: json['disruptions'] == null
      ? null
      : V3Disruptions.fromJson(json['disruptions'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3DisruptionsResponseToJson(
  V3DisruptionsResponse instance,
) => <String, dynamic>{
  'disruptions': instance.disruptions?.toJson(),
  'status': instance.status?.toJson(),
};

V3Disruptions _$V3DisruptionsFromJson(Map<String, dynamic> json) =>
    V3Disruptions(
      general:
          (json['general'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metroTrain:
          (json['metro_train'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metroTram:
          (json['metro_tram'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metroBus:
          (json['metro_bus'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      regionalTrain:
          (json['regional_train'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      regionalCoach:
          (json['regional_coach'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      regionalBus:
          (json['regional_bus'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      schoolBus:
          (json['school_bus'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      telebus:
          (json['telebus'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nightBus:
          (json['night_bus'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ferry:
          (json['ferry'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      interstateTrain:
          (json['interstate_train'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      skybus:
          (json['skybus'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      taxi:
          (json['taxi'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$V3DisruptionsToJson(
  V3Disruptions instance,
) => <String, dynamic>{
  'general': instance.general?.map((e) => e.toJson()).toList(),
  'metro_train': instance.metroTrain?.map((e) => e.toJson()).toList(),
  'metro_tram': instance.metroTram?.map((e) => e.toJson()).toList(),
  'metro_bus': instance.metroBus?.map((e) => e.toJson()).toList(),
  'regional_train': instance.regionalTrain?.map((e) => e.toJson()).toList(),
  'regional_coach': instance.regionalCoach?.map((e) => e.toJson()).toList(),
  'regional_bus': instance.regionalBus?.map((e) => e.toJson()).toList(),
  'school_bus': instance.schoolBus?.map((e) => e.toJson()).toList(),
  'telebus': instance.telebus?.map((e) => e.toJson()).toList(),
  'night_bus': instance.nightBus?.map((e) => e.toJson()).toList(),
  'ferry': instance.ferry?.map((e) => e.toJson()).toList(),
  'interstate_train': instance.interstateTrain?.map((e) => e.toJson()).toList(),
  'skybus': instance.skybus?.map((e) => e.toJson()).toList(),
  'taxi': instance.taxi?.map((e) => e.toJson()).toList(),
};

V3DisruptionResponse _$V3DisruptionResponseFromJson(
  Map<String, dynamic> json,
) => V3DisruptionResponse(
  disruption: json['disruption'] == null
      ? null
      : V3Disruption.fromJson(json['disruption'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3DisruptionResponseToJson(
  V3DisruptionResponse instance,
) => <String, dynamic>{
  'disruption': instance.disruption?.toJson(),
  'status': instance.status?.toJson(),
};

V3StopToStopDisruptionsResponse _$V3StopToStopDisruptionsResponseFromJson(
  Map<String, dynamic> json,
) => V3StopToStopDisruptionsResponse(
  disruptions:
      (json['disruptions'] as List<dynamic>?)
          ?.map(
            (e) => V3StopToStopDisruption.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3StopToStopDisruptionsResponseToJson(
  V3StopToStopDisruptionsResponse instance,
) => <String, dynamic>{
  'disruptions': instance.disruptions?.map((e) => e.toJson()).toList(),
  'status': instance.status?.toJson(),
};

V3StopToStopDisruption _$V3StopToStopDisruptionFromJson(
  Map<String, dynamic> json,
) => V3StopToStopDisruption(
  end: json['end'] == null
      ? null
      : V3StopBasic.fromJson(json['end'] as Map<String, dynamic>),
  start: json['start'] == null
      ? null
      : V3StopBasic.fromJson(json['start'] as Map<String, dynamic>),
  region: json['region'] as String?,
  alternateTransport: json['alternate_transport'] as String?,
  status: json['status'] as String?,
  publishedOn: json['published_on'] == null
      ? null
      : DateTime.parse(json['published_on'] as String),
  directionName: json['direction_name'] as String?,
);

Map<String, dynamic> _$V3StopToStopDisruptionToJson(
  V3StopToStopDisruption instance,
) => <String, dynamic>{
  'end': instance.end?.toJson(),
  'start': instance.start?.toJson(),
  'region': instance.region,
  'alternate_transport': instance.alternateTransport,
  'status': instance.status,
  'published_on': instance.publishedOn?.toIso8601String(),
  'direction_name': instance.directionName,
};

V3StopBasic _$V3StopBasicFromJson(Map<String, dynamic> json) => V3StopBasic(
  stopId: (json['stop_id'] as num?)?.toInt(),
  stopName: json['stop_name'] as String?,
);

Map<String, dynamic> _$V3StopBasicToJson(V3StopBasic instance) =>
    <String, dynamic>{
      'stop_id': instance.stopId,
      'stop_name': instance.stopName,
    };

V3DisruptionModesResponse _$V3DisruptionModesResponseFromJson(
  Map<String, dynamic> json,
) => V3DisruptionModesResponse(
  disruptionModes:
      (json['disruption_modes'] as List<dynamic>?)
          ?.map((e) => V3DisruptionMode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3DisruptionModesResponseToJson(
  V3DisruptionModesResponse instance,
) => <String, dynamic>{
  'disruption_modes': instance.disruptionModes?.map((e) => e.toJson()).toList(),
  'status': instance.status?.toJson(),
};

V3DisruptionMode _$V3DisruptionModeFromJson(Map<String, dynamic> json) =>
    V3DisruptionMode(
      disruptionModeName: json['disruption_mode_name'] as String?,
      disruptionMode: (json['disruption_mode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V3DisruptionModeToJson(V3DisruptionMode instance) =>
    <String, dynamic>{
      'disruption_mode_name': instance.disruptionModeName,
      'disruption_mode': instance.disruptionMode,
    };

V3FareEstimateParameters _$V3FareEstimateParametersFromJson(
  Map<String, dynamic> json,
) => V3FareEstimateParameters(
  journeyTouchOnUtc: json['journey_touch_on_utc'] == null
      ? null
      : DateTime.parse(json['journey_touch_on_utc'] as String),
  journeyTouchOffUtc: json['journey_touch_off_utc'] == null
      ? null
      : DateTime.parse(json['journey_touch_off_utc'] as String),
  isJourneyInFreeTramZone: json['is_journey_in_free_tram_zone'] as bool?,
  isJourneyInOverlapZone: json['is_journey_in_overlap_zone'] as bool?,
  travelledRouteTypes:
      (json['travelled_route_types'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
);

Map<String, dynamic> _$V3FareEstimateParametersToJson(
  V3FareEstimateParameters instance,
) => <String, dynamic>{
  'journey_touch_on_utc': instance.journeyTouchOnUtc?.toIso8601String(),
  'journey_touch_off_utc': instance.journeyTouchOffUtc?.toIso8601String(),
  'is_journey_in_free_tram_zone': instance.isJourneyInFreeTramZone,
  'is_journey_in_overlap_zone': instance.isJourneyInOverlapZone,
  'travelled_route_types': instance.travelledRouteTypes,
};

V3FareEstimateResponse _$V3FareEstimateResponseFromJson(
  Map<String, dynamic> json,
) => V3FareEstimateResponse(
  fareEstimateResultStatus: json['FareEstimateResultStatus'] == null
      ? null
      : V3FareEstimateResultStatus.fromJson(
          json['FareEstimateResultStatus'] as Map<String, dynamic>,
        ),
  fareEstimateResult: json['FareEstimateResult'] == null
      ? null
      : V3FareEstimateResult.fromJson(
          json['FareEstimateResult'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$V3FareEstimateResponseToJson(
  V3FareEstimateResponse instance,
) => <String, dynamic>{
  'FareEstimateResultStatus': instance.fareEstimateResultStatus?.toJson(),
  'FareEstimateResult': instance.fareEstimateResult?.toJson(),
};

V3FareEstimateResultStatus _$V3FareEstimateResultStatusFromJson(
  Map<String, dynamic> json,
) => V3FareEstimateResultStatus(
  statusCode: (json['StatusCode'] as num?)?.toInt(),
  message: json['Message'] as String?,
);

Map<String, dynamic> _$V3FareEstimateResultStatusToJson(
  V3FareEstimateResultStatus instance,
) => <String, dynamic>{
  'StatusCode': instance.statusCode,
  'Message': instance.message,
};

V3FareEstimateResult _$V3FareEstimateResultFromJson(
  Map<String, dynamic> json,
) => V3FareEstimateResult(
  isEarlyBird: json['IsEarlyBird'] as bool?,
  isJourneyInFreeTramZone: json['IsJourneyInFreeTramZone'] as bool?,
  isThisWeekendJourney: json['IsThisWeekendJourney'] as bool?,
  zoneInfo: json['ZoneInfo'] == null
      ? null
      : V3ZoneInfo.fromJson(json['ZoneInfo'] as Map<String, dynamic>),
  passengerFares:
      (json['PassengerFares'] as List<dynamic>?)
          ?.map((e) => V3PassengerFare.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$V3FareEstimateResultToJson(
  V3FareEstimateResult instance,
) => <String, dynamic>{
  'IsEarlyBird': instance.isEarlyBird,
  'IsJourneyInFreeTramZone': instance.isJourneyInFreeTramZone,
  'IsThisWeekendJourney': instance.isThisWeekendJourney,
  'ZoneInfo': instance.zoneInfo?.toJson(),
  'PassengerFares': instance.passengerFares?.map((e) => e.toJson()).toList(),
};

V3ZoneInfo _$V3ZoneInfoFromJson(Map<String, dynamic> json) => V3ZoneInfo(
  minZone: (json['MinZone'] as num?)?.toInt(),
  maxZone: (json['MaxZone'] as num?)?.toInt(),
  uniqueZones:
      (json['UniqueZones'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
);

Map<String, dynamic> _$V3ZoneInfoToJson(V3ZoneInfo instance) =>
    <String, dynamic>{
      'MinZone': instance.minZone,
      'MaxZone': instance.maxZone,
      'UniqueZones': instance.uniqueZones,
    };

V3PassengerFare _$V3PassengerFareFromJson(Map<String, dynamic> json) =>
    V3PassengerFare(
      passengerType: json['PassengerType'] as String?,
      fare2HourPeak: (json['Fare2HourPeak'] as num?)?.toDouble(),
      fare2HourOffPeak: (json['Fare2HourOffPeak'] as num?)?.toDouble(),
      fareDailyPeak: (json['FareDailyPeak'] as num?)?.toDouble(),
      fareDailyOffPeak: (json['FareDailyOffPeak'] as num?)?.toDouble(),
      pass7Days: (json['Pass7Days'] as num?)?.toDouble(),
      pass28To69DayPerDay: (json['Pass28To69DayPerDay'] as num?)?.toDouble(),
      pass70PlusDayPerDay: (json['Pass70PlusDayPerDay'] as num?)?.toDouble(),
      weekendCap: (json['WeekendCap'] as num?)?.toDouble(),
      holidayCap: (json['HolidayCap'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$V3PassengerFareToJson(V3PassengerFare instance) =>
    <String, dynamic>{
      'PassengerType': instance.passengerType,
      'Fare2HourPeak': instance.fare2HourPeak,
      'Fare2HourOffPeak': instance.fare2HourOffPeak,
      'FareDailyPeak': instance.fareDailyPeak,
      'FareDailyOffPeak': instance.fareDailyOffPeak,
      'Pass7Days': instance.pass7Days,
      'Pass28To69DayPerDay': instance.pass28To69DayPerDay,
      'Pass70PlusDayPerDay': instance.pass70PlusDayPerDay,
      'WeekendCap': instance.weekendCap,
      'HolidayCap': instance.holidayCap,
    };

V3JourneyPlannerParameters _$V3JourneyPlannerParametersFromJson(
  Map<String, dynamic> json,
) => V3JourneyPlannerParameters(
  timeUtc: json['TimeUtc'] == null
      ? null
      : DateTime.parse(json['TimeUtc'] as String),
  departFrom: json['DepartFrom'] as bool?,
  transferSpeed: json['TransferSpeed'] as String?,
  transferMaxTime: (json['TransferMaxTime'] as num?)?.toInt(),
  transferMethod: json['TransferMethod'] as String?,
  inclTrain: json['InclTrain'] as bool?,
  inclTram: json['InclTram'] as bool?,
  inclBus: json['InclBus'] as bool?,
  inclVline: json['InclVline'] as bool?,
  inclRegCoach: json['InclRegCoach'] as bool?,
  inclSkybus: json['InclSkybus'] as bool?,
  routeType: json['RouteType'] as String?,
  inclPathCoords: json['InclPathCoords'] as bool?,
  inclFareEstimate: json['InclFareEstimate'] as bool?,
  wheelchair: json['Wheelchair'] as bool?,
  noSolidStairs: json['NoSolidStairs'] as bool?,
  efaEngine: json['EfaEngine'] as String?,
  useRealtime: json['UseRealtime'] as bool?,
);

Map<String, dynamic> _$V3JourneyPlannerParametersToJson(
  V3JourneyPlannerParameters instance,
) => <String, dynamic>{
  'TimeUtc': instance.timeUtc?.toIso8601String(),
  'DepartFrom': instance.departFrom,
  'TransferSpeed': instance.transferSpeed,
  'TransferMaxTime': instance.transferMaxTime,
  'TransferMethod': instance.transferMethod,
  'InclTrain': instance.inclTrain,
  'InclTram': instance.inclTram,
  'InclBus': instance.inclBus,
  'InclVline': instance.inclVline,
  'InclRegCoach': instance.inclRegCoach,
  'InclSkybus': instance.inclSkybus,
  'RouteType': instance.routeType,
  'InclPathCoords': instance.inclPathCoords,
  'InclFareEstimate': instance.inclFareEstimate,
  'Wheelchair': instance.wheelchair,
  'NoSolidStairs': instance.noSolidStairs,
  'EfaEngine': instance.efaEngine,
  'UseRealtime': instance.useRealtime,
};

V3JourneyPlannerResponse _$V3JourneyPlannerResponseFromJson(
  Map<String, dynamic> json,
) => V3JourneyPlannerResponse(
  journey: json['Journey'] == null
      ? null
      : V3JourneyResponse.fromJson(json['Journey'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3JourneyPlannerResponseToJson(
  V3JourneyPlannerResponse instance,
) => <String, dynamic>{
  'Journey': instance.journey?.toJson(),
  'status': instance.status?.toJson(),
};

V3JourneyResponse _$V3JourneyResponseFromJson(Map<String, dynamic> json) =>
    V3JourneyResponse(
      status: json['Status'] as String?,
      originOptions:
          (json['OriginOptions'] as List<dynamic>?)
              ?.map((e) => V3LocationOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      destinationOptions:
          (json['DestinationOptions'] as List<dynamic>?)
              ?.map((e) => V3LocationOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      chronosLog:
          (json['ChronosLog'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      chronosTimings:
          (json['ChronosTimings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      chronosStart: json['ChronosStart'] == null
          ? null
          : DateTime.parse(json['ChronosStart'] as String),
      itinerary:
          (json['Itinerary'] as List<dynamic>?)
              ?.map((e) => V3Journey.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requestUrl: json['RequestUrl'] as String?,
    );

Map<String, dynamic> _$V3JourneyResponseToJson(V3JourneyResponse instance) =>
    <String, dynamic>{
      'Status': instance.status,
      'OriginOptions': instance.originOptions?.map((e) => e.toJson()).toList(),
      'DestinationOptions': instance.destinationOptions
          ?.map((e) => e.toJson())
          .toList(),
      'ChronosLog': instance.chronosLog,
      'ChronosTimings': instance.chronosTimings,
      'ChronosStart': instance.chronosStart?.toIso8601String(),
      'Itinerary': instance.itinerary?.map((e) => e.toJson()).toList(),
      'RequestUrl': instance.requestUrl,
    };

V3LocationOption _$V3LocationOptionFromJson(Map<String, dynamic> json) =>
    V3LocationOption(
      name: json['Name'] as String?,
      url: json['Url'] as String?,
    );

Map<String, dynamic> _$V3LocationOptionToJson(V3LocationOption instance) =>
    <String, dynamic>{'Name': instance.name, 'Url': instance.url};

V3Journey _$V3JourneyFromJson(Map<String, dynamic> json) => V3Journey(
  timeDeparture: json['TimeDeparture'] == null
      ? null
      : DateTime.parse(json['TimeDeparture'] as String),
  timeArrival: json['TimeArrival'] == null
      ? null
      : DateTime.parse(json['TimeArrival'] as String),
  estimatedTimeDeparture: json['EstimatedTimeDeparture'] == null
      ? null
      : DateTime.parse(json['EstimatedTimeDeparture'] as String),
  estimatedTimeArrival: json['EstimatedTimeArrival'] == null
      ? null
      : DateTime.parse(json['EstimatedTimeArrival'] as String),
  chronosJourneyLog:
      (json['ChronosJourneyLog'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  realTimeMessage: json['RealTimeMessage'] as String?,
  timeDepartureStr: json['TimeDepartureStr'] as String?,
  dateDepartureStr: json['DateDepartureStr'] as String?,
  timeArrivalStr: json['TimeArrivalStr'] as String?,
  dateArrivalStr: json['DateArrivalStr'] as String?,
  durationMins: (json['DurationMins'] as num?)?.toInt(),
  estimatedDurationMins: (json['EstimatedDurationMins'] as num?)?.toInt(),
  legs:
      (json['Legs'] as List<dynamic>?)
          ?.map((e) => V3JourneyLeg.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  zones:
      (json['Zones'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  fareEstimate: json['FareEstimate'] == null
      ? null
      : V3FareEstimateResponse.fromJson(
          json['FareEstimate'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$V3JourneyToJson(V3Journey instance) => <String, dynamic>{
  'TimeDeparture': instance.timeDeparture?.toIso8601String(),
  'TimeArrival': instance.timeArrival?.toIso8601String(),
  'EstimatedTimeDeparture': instance.estimatedTimeDeparture?.toIso8601String(),
  'EstimatedTimeArrival': instance.estimatedTimeArrival?.toIso8601String(),
  'ChronosJourneyLog': instance.chronosJourneyLog,
  'RealTimeMessage': instance.realTimeMessage,
  'TimeDepartureStr': instance.timeDepartureStr,
  'DateDepartureStr': instance.dateDepartureStr,
  'TimeArrivalStr': instance.timeArrivalStr,
  'DateArrivalStr': instance.dateArrivalStr,
  'DurationMins': instance.durationMins,
  'EstimatedDurationMins': instance.estimatedDurationMins,
  'Legs': instance.legs?.map((e) => e.toJson()).toList(),
  'Zones': instance.zones,
  'FareEstimate': instance.fareEstimate?.toJson(),
};

V3JourneyLeg _$V3JourneyLegFromJson(Map<String, dynamic> json) => V3JourneyLeg(
  type: json['Type'] as String?,
  lineName: json['LineName'] as String?,
  directionName: json['DirectionName'] as String?,
  operatedBy: json['OperatedBy'] as String?,
  alternateLines:
      (json['AlternateLines'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  sequence: (json['Sequence'] as num?)?.toInt(),
  lineId: json['LineId'] as String?,
  directionCode: json['DirectionCode'] as String?,
  directionId: json['DirectionId'] as String?,
  direction: json['Direction'] == null
      ? null
      : V3Direction.fromJson(json['Direction'] as Map<String, dynamic>),
  timeDeparture: json['TimeDeparture'] == null
      ? null
      : DateTime.parse(json['TimeDeparture'] as String),
  timeArrival: json['TimeArrival'] == null
      ? null
      : DateTime.parse(json['TimeArrival'] as String),
  estimatedTimeDeparture: json['EstimatedTimeDeparture'] == null
      ? null
      : DateTime.parse(json['EstimatedTimeDeparture'] as String),
  estimatedTimeArrival: json['EstimatedTimeArrival'] == null
      ? null
      : DateTime.parse(json['EstimatedTimeArrival'] as String),
  timeRealtime: json['TimeRealtime'] == null
      ? null
      : DateTime.parse(json['TimeRealtime'] as String),
  instructions: json['Instructions'] as String?,
  instructionDetails:
      (json['InstructionDetails'] as List<dynamic>?)
          ?.map((e) => V3LegDirection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  information:
      (json['Information'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  zones:
      (json['Zones'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  timeDepartureStr: json['TimeDepartureStr'] as String?,
  dateDepartureStr: json['DateDepartureStr'] as String?,
  timeArrivalStr: json['TimeArrivalStr'] as String?,
  dateArrivalStr: json['DateArrivalStr'] as String?,
  stopDeparture: json['StopDeparture'] == null
      ? null
      : V3JourneyPlannerLocation.fromJson(
          json['StopDeparture'] as Map<String, dynamic>,
        ),
  stopArrival: json['StopArrival'] == null
      ? null
      : V3JourneyPlannerLocation.fromJson(
          json['StopArrival'] as Map<String, dynamic>,
        ),
  stoppingPattern:
      (json['StoppingPattern'] as List<dynamic>?)
          ?.map((e) => V3JourneyPlannerStop.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  isRealtime: json['IsRealtime'] as bool?,
  disruptions:
      (json['Disruptions'] as List<dynamic>?)
          ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  pathCoordinates:
      (json['PathCoordinates'] as List<dynamic>?)
          ?.map(
            (e) =>
                V3JourneyLegPathCoordinate.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  planLowFloorVehicle: json['PlanLowFloorVehicle'] as String?,
  planWheelChairAccess: json['PlanWheelChairAccess'] as String?,
  realtimeStatus:
      (json['RealtimeStatus'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$V3JourneyLegToJson(
  V3JourneyLeg instance,
) => <String, dynamic>{
  'Type': instance.type,
  'LineName': instance.lineName,
  'DirectionName': instance.directionName,
  'OperatedBy': instance.operatedBy,
  'AlternateLines': instance.alternateLines,
  'Sequence': instance.sequence,
  'LineId': instance.lineId,
  'DirectionCode': instance.directionCode,
  'DirectionId': instance.directionId,
  'Direction': instance.direction?.toJson(),
  'TimeDeparture': instance.timeDeparture?.toIso8601String(),
  'TimeArrival': instance.timeArrival?.toIso8601String(),
  'EstimatedTimeDeparture': instance.estimatedTimeDeparture?.toIso8601String(),
  'EstimatedTimeArrival': instance.estimatedTimeArrival?.toIso8601String(),
  'TimeRealtime': instance.timeRealtime?.toIso8601String(),
  'Instructions': instance.instructions,
  'InstructionDetails': instance.instructionDetails
      ?.map((e) => e.toJson())
      .toList(),
  'Information': instance.information,
  'Zones': instance.zones,
  'TimeDepartureStr': instance.timeDepartureStr,
  'DateDepartureStr': instance.dateDepartureStr,
  'TimeArrivalStr': instance.timeArrivalStr,
  'DateArrivalStr': instance.dateArrivalStr,
  'StopDeparture': instance.stopDeparture?.toJson(),
  'StopArrival': instance.stopArrival?.toJson(),
  'StoppingPattern': instance.stoppingPattern?.map((e) => e.toJson()).toList(),
  'IsRealtime': instance.isRealtime,
  'Disruptions': instance.disruptions?.map((e) => e.toJson()).toList(),
  'PathCoordinates': instance.pathCoordinates?.map((e) => e.toJson()).toList(),
  'PlanLowFloorVehicle': instance.planLowFloorVehicle,
  'PlanWheelChairAccess': instance.planWheelChairAccess,
  'RealtimeStatus': instance.realtimeStatus,
};

V3LegDirection _$V3LegDirectionFromJson(Map<String, dynamic> json) =>
    V3LegDirection(
      turnDirection: json['TurnDirection'] as String?,
      turningManoeuvre: json['TurningManoeuvre'] as String?,
      lon: (json['Lon'] as num?)?.toDouble(),
      lat: (json['Lat'] as num?)?.toDouble(),
      streetName: json['StreetName'] as String?,
      fromPathLinkIdx: json['FromPathLinkIdx'] as String?,
      toPathLinkIdx: json['ToPathLinkIdx'] as String?,
      skyDirection: json['SkyDirection'] as String?,
      travelTime: (json['TravelTime'] as num?)?.toInt(),
      cumTravelTime: (json['CumTravelTime'] as num?)?.toInt(),
      distance: (json['Distance'] as num?)?.toInt(),
      cumDistance: (json['CumDistance'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V3LegDirectionToJson(V3LegDirection instance) =>
    <String, dynamic>{
      'TurnDirection': instance.turnDirection,
      'TurningManoeuvre': instance.turningManoeuvre,
      'Lon': instance.lon,
      'Lat': instance.lat,
      'StreetName': instance.streetName,
      'FromPathLinkIdx': instance.fromPathLinkIdx,
      'ToPathLinkIdx': instance.toPathLinkIdx,
      'SkyDirection': instance.skyDirection,
      'TravelTime': instance.travelTime,
      'CumTravelTime': instance.cumTravelTime,
      'Distance': instance.distance,
      'CumDistance': instance.cumDistance,
    };

V3JourneyPlannerLocation _$V3JourneyPlannerLocationFromJson(
  Map<String, dynamic> json,
) => V3JourneyPlannerLocation(
  locationName: json['LocationName'] as String?,
  stopId: (json['StopId'] as num?)?.toInt(),
  placeId: (json['PlaceId'] as num?)?.toInt(),
  locality: json['Locality'] as String?,
  platform: json['Platform'] as String?,
  lat: (json['Lat'] as num?)?.toDouble(),
  lon: (json['Lon'] as num?)?.toDouble(),
  routeTypes:
      (json['RouteTypes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  disruptionIds:
      (json['DisruptionIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  stopTicket: json['StopTicket'] == null
      ? null
      : V3StopTicket.fromJson(json['StopTicket'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3JourneyPlannerLocationToJson(
  V3JourneyPlannerLocation instance,
) => <String, dynamic>{
  'LocationName': instance.locationName,
  'StopId': instance.stopId,
  'PlaceId': instance.placeId,
  'Locality': instance.locality,
  'Platform': instance.platform,
  'Lat': instance.lat,
  'Lon': instance.lon,
  'RouteTypes': instance.routeTypes,
  'DisruptionIds': instance.disruptionIds,
  'StopTicket': instance.stopTicket?.toJson(),
};

V3JourneyPlannerStop _$V3JourneyPlannerStopFromJson(
  Map<String, dynamic> json,
) => V3JourneyPlannerStop(
  location: json['Location'] == null
      ? null
      : V3JourneyPlannerLocation.fromJson(
          json['Location'] as Map<String, dynamic>,
        ),
  timeTimetableUtc: json['TimeTimetableUtc'] == null
      ? null
      : DateTime.parse(json['TimeTimetableUtc'] as String),
  timeStr: json['TimeStr'] as String?,
  isRealtime: json['IsRealtime'] as bool?,
  timeRealtimeUtc: json['TimeRealtimeUtc'] == null
      ? null
      : DateTime.parse(json['TimeRealtimeUtc'] as String),
  estimatedTimeArrival: json['EstimatedTimeArrival'] == null
      ? null
      : DateTime.parse(json['EstimatedTimeArrival'] as String),
  estimatedTimeDeparture: json['EstimatedTimeDeparture'] == null
      ? null
      : DateTime.parse(json['EstimatedTimeDeparture'] as String),
);

Map<String, dynamic> _$V3JourneyPlannerStopToJson(
  V3JourneyPlannerStop instance,
) => <String, dynamic>{
  'Location': instance.location?.toJson(),
  'TimeTimetableUtc': instance.timeTimetableUtc?.toIso8601String(),
  'TimeStr': instance.timeStr,
  'IsRealtime': instance.isRealtime,
  'TimeRealtimeUtc': instance.timeRealtimeUtc?.toIso8601String(),
  'EstimatedTimeArrival': instance.estimatedTimeArrival?.toIso8601String(),
  'EstimatedTimeDeparture': instance.estimatedTimeDeparture?.toIso8601String(),
};

V3JourneyLegPathCoordinate _$V3JourneyLegPathCoordinateFromJson(
  Map<String, dynamic> json,
) => V3JourneyLegPathCoordinate(
  lat: (json['Lat'] as num?)?.toDouble(),
  lon: (json['Lon'] as num?)?.toDouble(),
);

Map<String, dynamic> _$V3JourneyLegPathCoordinateToJson(
  V3JourneyLegPathCoordinate instance,
) => <String, dynamic>{'Lat': instance.lat, 'Lon': instance.lon};

V3StopTicket _$V3StopTicketFromJson(Map<String, dynamic> json) => V3StopTicket(
  ticketType: json['ticket_type'] as String?,
  zone: json['zone'] as String?,
  isFreeFareZone: json['is_free_fare_zone'] as bool?,
  ticketMachine: json['ticket_machine'] as bool?,
  ticketChecks: json['ticket_checks'] as bool?,
  vlineReservation: json['vline_reservation'] as bool?,
  ticketZones:
      (json['ticket_zones'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
);

Map<String, dynamic> _$V3StopTicketToJson(V3StopTicket instance) =>
    <String, dynamic>{
      'ticket_type': instance.ticketType,
      'zone': instance.zone,
      'is_free_fare_zone': instance.isFreeFareZone,
      'ticket_machine': instance.ticketMachine,
      'ticket_checks': instance.ticketChecks,
      'vline_reservation': instance.vlineReservation,
      'ticket_zones': instance.ticketZones,
    };

V3NetworkMapsResponse _$V3NetworkMapsResponseFromJson(
  Map<String, dynamic> json,
) => V3NetworkMapsResponse(
  maps:
      (json['maps'] as List<dynamic>?)
          ?.map((e) => V3NetworkMap.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3NetworkMapsResponseToJson(
  V3NetworkMapsResponse instance,
) => <String, dynamic>{
  'maps': instance.maps?.map((e) => e.toJson()).toList(),
  'status': instance.status?.toJson(),
};

V3NetworkMap _$V3NetworkMapFromJson(Map<String, dynamic> json) => V3NetworkMap(
  version: json['version'] as String?,
  url: json['url'] as String?,
  size: json['size'] as String?,
);

Map<String, dynamic> _$V3NetworkMapToJson(V3NetworkMap instance) =>
    <String, dynamic>{
      'version': instance.version,
      'url': instance.url,
      'size': instance.size,
    };

V3OperatorsSocialFeedsResponse _$V3OperatorsSocialFeedsResponseFromJson(
  Map<String, dynamic> json,
) => V3OperatorsSocialFeedsResponse(
  operators: json['operators'] == null
      ? null
      : V3OperatorsSocialMediaModes.fromJson(
          json['operators'] as Map<String, dynamic>,
        ),
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3OperatorsSocialFeedsResponseToJson(
  V3OperatorsSocialFeedsResponse instance,
) => <String, dynamic>{
  'operators': instance.operators?.toJson(),
  'status': instance.status?.toJson(),
};

V3OperatorsSocialMediaModes _$V3OperatorsSocialMediaModesFromJson(
  Map<String, dynamic> json,
) => V3OperatorsSocialMediaModes(
  metroTrain:
      (json['metro_train'] as List<dynamic>?)
          ?.map(
            (e) => V3OperatorSocialMedia.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  metroBus:
      (json['metro_bus'] as List<dynamic>?)
          ?.map(
            (e) => V3OperatorSocialMedia.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  metroTram:
      (json['metro_tram'] as List<dynamic>?)
          ?.map(
            (e) => V3OperatorSocialMedia.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  regionalTrain:
      (json['regional_train'] as List<dynamic>?)
          ?.map(
            (e) => V3OperatorSocialMedia.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  regionalCoach:
      (json['regional_coach'] as List<dynamic>?)
          ?.map(
            (e) => V3OperatorSocialMedia.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  regionalBus:
      (json['regional_bus'] as List<dynamic>?)
          ?.map(
            (e) => V3OperatorSocialMedia.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$V3OperatorsSocialMediaModesToJson(
  V3OperatorsSocialMediaModes instance,
) => <String, dynamic>{
  'metro_train': instance.metroTrain?.map((e) => e.toJson()).toList(),
  'metro_bus': instance.metroBus?.map((e) => e.toJson()).toList(),
  'metro_tram': instance.metroTram?.map((e) => e.toJson()).toList(),
  'regional_train': instance.regionalTrain?.map((e) => e.toJson()).toList(),
  'regional_coach': instance.regionalCoach?.map((e) => e.toJson()).toList(),
  'regional_bus': instance.regionalBus?.map((e) => e.toJson()).toList(),
};

V3OperatorSocialMedia _$V3OperatorSocialMediaFromJson(
  Map<String, dynamic> json,
) => V3OperatorSocialMedia(
  name: json['name'] as String?,
  accounts:
      (json['accounts'] as List<dynamic>?)
          ?.map(
            (e) => V3OperatorSocialMediaAccount.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$V3OperatorSocialMediaToJson(
  V3OperatorSocialMedia instance,
) => <String, dynamic>{
  'name': instance.name,
  'accounts': instance.accounts?.map((e) => e.toJson()).toList(),
};

V3OperatorSocialMediaAccount _$V3OperatorSocialMediaAccountFromJson(
  Map<String, dynamic> json,
) => V3OperatorSocialMediaAccount(
  type: json['type'] as String?,
  accountName: json['account_name'] as String?,
  url: json['url'] as String?,
  iOSUrl: json['iOS_url'] as String?,
);

Map<String, dynamic> _$V3OperatorSocialMediaAccountToJson(
  V3OperatorSocialMediaAccount instance,
) => <String, dynamic>{
  'type': instance.type,
  'account_name': instance.accountName,
  'url': instance.url,
  'iOS_url': instance.iOSUrl,
};

V3OperatorsResponse _$V3OperatorsResponseFromJson(Map<String, dynamic> json) =>
    V3OperatorsResponse(
      operators:
          (json['operators'] as List<dynamic>?)
              ?.map((e) => e as Object)
              .toList() ??
          [],
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3OperatorsResponseToJson(
  V3OperatorsResponse instance,
) => <String, dynamic>{
  'operators': instance.operators,
  'status': instance.status?.toJson(),
};

V3OutletParameters _$V3OutletParametersFromJson(Map<String, dynamic> json) =>
    V3OutletParameters(maxResults: (json['max_results'] as num?)?.toInt());

Map<String, dynamic> _$V3OutletParametersToJson(V3OutletParameters instance) =>
    <String, dynamic>{'max_results': instance.maxResults};

V3OutletResponse _$V3OutletResponseFromJson(Map<String, dynamic> json) =>
    V3OutletResponse(
      outlets:
          (json['outlets'] as List<dynamic>?)
              ?.map((e) => V3Outlet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3OutletResponseToJson(V3OutletResponse instance) =>
    <String, dynamic>{
      'outlets': instance.outlets?.map((e) => e.toJson()).toList(),
      'status': instance.status?.toJson(),
    };

V3Outlet _$V3OutletFromJson(Map<String, dynamic> json) => V3Outlet(
  outletSlidSpid: json['outlet_slid_spid'] as String?,
  outletName: json['outlet_name'] as String?,
  outletBusiness: json['outlet_business'] as String?,
  outletLatitude: (json['outlet_latitude'] as num?)?.toDouble(),
  outletLongitude: (json['outlet_longitude'] as num?)?.toDouble(),
  outletSuburb: json['outlet_suburb'] as String?,
  outletPostcode: (json['outlet_postcode'] as num?)?.toInt(),
  outletBusinessHourMon: json['outlet_business_hour_mon'] as String?,
  outletBusinessHourTue: json['outlet_business_hour_tue'] as String?,
  outletBusinessHourWed: json['outlet_business_hour_wed'] as String?,
  outletBusinessHourThur: json['outlet_business_hour_thur'] as String?,
  outletBusinessHourFri: json['outlet_business_hour_fri'] as String?,
  outletBusinessHourSat: json['outlet_business_hour_sat'] as String?,
  outletBusinessHourSun: json['outlet_business_hour_sun'] as String?,
  outletNotes: json['outlet_notes'] as String?,
);

Map<String, dynamic> _$V3OutletToJson(V3Outlet instance) => <String, dynamic>{
  'outlet_slid_spid': instance.outletSlidSpid,
  'outlet_name': instance.outletName,
  'outlet_business': instance.outletBusiness,
  'outlet_latitude': instance.outletLatitude,
  'outlet_longitude': instance.outletLongitude,
  'outlet_suburb': instance.outletSuburb,
  'outlet_postcode': instance.outletPostcode,
  'outlet_business_hour_mon': instance.outletBusinessHourMon,
  'outlet_business_hour_tue': instance.outletBusinessHourTue,
  'outlet_business_hour_wed': instance.outletBusinessHourWed,
  'outlet_business_hour_thur': instance.outletBusinessHourThur,
  'outlet_business_hour_fri': instance.outletBusinessHourFri,
  'outlet_business_hour_sat': instance.outletBusinessHourSat,
  'outlet_business_hour_sun': instance.outletBusinessHourSun,
  'outlet_notes': instance.outletNotes,
};

V3OutletGeolocationParameters _$V3OutletGeolocationParametersFromJson(
  Map<String, dynamic> json,
) => V3OutletGeolocationParameters(
  maxDistance: (json['max_distance'] as num?)?.toDouble(),
  maxResults: (json['max_results'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3OutletGeolocationParametersToJson(
  V3OutletGeolocationParameters instance,
) => <String, dynamic>{
  'max_distance': instance.maxDistance,
  'max_results': instance.maxResults,
};

V3OutletGeolocationResponse _$V3OutletGeolocationResponseFromJson(
  Map<String, dynamic> json,
) => V3OutletGeolocationResponse(
  outlets:
      (json['outlets'] as List<dynamic>?)
          ?.map((e) => V3OutletGeolocation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3OutletGeolocationResponseToJson(
  V3OutletGeolocationResponse instance,
) => <String, dynamic>{
  'outlets': instance.outlets?.map((e) => e.toJson()).toList(),
  'status': instance.status?.toJson(),
};

V3OutletGeolocation _$V3OutletGeolocationFromJson(Map<String, dynamic> json) =>
    V3OutletGeolocation(
      outletDistance: (json['outlet_distance'] as num?)?.toDouble(),
      outletSlidSpid: json['outlet_slid_spid'] as String?,
      outletName: json['outlet_name'] as String?,
      outletBusiness: json['outlet_business'] as String?,
      outletLatitude: (json['outlet_latitude'] as num?)?.toDouble(),
      outletLongitude: (json['outlet_longitude'] as num?)?.toDouble(),
      outletSuburb: json['outlet_suburb'] as String?,
      outletPostcode: (json['outlet_postcode'] as num?)?.toInt(),
      outletBusinessHourMon: json['outlet_business_hour_mon'] as String?,
      outletBusinessHourTue: json['outlet_business_hour_tue'] as String?,
      outletBusinessHourWed: json['outlet_business_hour_wed'] as String?,
      outletBusinessHourThur: json['outlet_business_hour_thur'] as String?,
      outletBusinessHourFri: json['outlet_business_hour_fri'] as String?,
      outletBusinessHourSat: json['outlet_business_hour_sat'] as String?,
      outletBusinessHourSun: json['outlet_business_hour_sun'] as String?,
      outletNotes: json['outlet_notes'] as String?,
    );

Map<String, dynamic> _$V3OutletGeolocationToJson(
  V3OutletGeolocation instance,
) => <String, dynamic>{
  'outlet_distance': instance.outletDistance,
  'outlet_slid_spid': instance.outletSlidSpid,
  'outlet_name': instance.outletName,
  'outlet_business': instance.outletBusiness,
  'outlet_latitude': instance.outletLatitude,
  'outlet_longitude': instance.outletLongitude,
  'outlet_suburb': instance.outletSuburb,
  'outlet_postcode': instance.outletPostcode,
  'outlet_business_hour_mon': instance.outletBusinessHourMon,
  'outlet_business_hour_tue': instance.outletBusinessHourTue,
  'outlet_business_hour_wed': instance.outletBusinessHourWed,
  'outlet_business_hour_thur': instance.outletBusinessHourThur,
  'outlet_business_hour_fri': instance.outletBusinessHourFri,
  'outlet_business_hour_sat': instance.outletBusinessHourSat,
  'outlet_business_hour_sun': instance.outletBusinessHourSun,
  'outlet_notes': instance.outletNotes,
};

V3PatternsParameters _$V3PatternsParametersFromJson(
  Map<String, dynamic> json,
) => V3PatternsParameters(
  expand:
      (json['expand'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  stopId: (json['stop_id'] as num?)?.toInt(),
  dateUtc: json['date_utc'] == null
      ? null
      : DateTime.parse(json['date_utc'] as String),
  includeSkippedStops: json['include_skipped_stops'] as bool?,
  includeGeopath: json['include_geopath'] as bool?,
  includeAdvertisedInterchange: json['include_advertised_interchange'] as bool?,
);

Map<String, dynamic> _$V3PatternsParametersToJson(
  V3PatternsParameters instance,
) => <String, dynamic>{
  'expand': instance.expand,
  'stop_id': instance.stopId,
  'date_utc': instance.dateUtc?.toIso8601String(),
  'include_skipped_stops': instance.includeSkippedStops,
  'include_geopath': instance.includeGeopath,
  'include_advertised_interchange': instance.includeAdvertisedInterchange,
};

V3StoppingPattern _$V3StoppingPatternFromJson(Map<String, dynamic> json) =>
    V3StoppingPattern(
      disruptions:
          (json['disruptions'] as List<dynamic>?)
              ?.map((e) => V3Disruption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      departures:
          (json['departures'] as List<dynamic>?)
              ?.map(
                (e) => V3PatternDeparture.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      stops: json['stops'] as Map<String, dynamic>?,
      routes: json['routes'] as Map<String, dynamic>?,
      runs: json['runs'] as Map<String, dynamic>?,
      directions: json['directions'] as Map<String, dynamic>?,
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3StoppingPatternToJson(V3StoppingPattern instance) =>
    <String, dynamic>{
      'disruptions': instance.disruptions?.map((e) => e.toJson()).toList(),
      'departures': instance.departures?.map((e) => e.toJson()).toList(),
      'stops': instance.stops,
      'routes': instance.routes,
      'runs': instance.runs,
      'directions': instance.directions,
      'status': instance.status?.toJson(),
    };

V3PatternDeparture _$V3PatternDepartureFromJson(Map<String, dynamic> json) =>
    V3PatternDeparture(
      skippedStops:
          (json['skipped_stops'] as List<dynamic>?)
              ?.map((e) => V3StopModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stopId: (json['stop_id'] as num?)?.toInt(),
      routeId: (json['route_id'] as num?)?.toInt(),
      runId: (json['run_id'] as num?)?.toInt(),
      runRef: json['run_ref'] as String?,
      directionId: (json['direction_id'] as num?)?.toInt(),
      disruptionIds:
          (json['disruption_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      scheduledDepartureUtc: json['scheduled_departure_utc'] == null
          ? null
          : DateTime.parse(json['scheduled_departure_utc'] as String),
      estimatedDepartureUtc: json['estimated_departure_utc'] == null
          ? null
          : DateTime.parse(json['estimated_departure_utc'] as String),
      atPlatform: json['at_platform'] as bool?,
      platformNumber: json['platform_number'] as String?,
      flags: json['flags'] as String?,
      departureSequence: (json['departure_sequence'] as num?)?.toInt(),
      departureNote: json['departure_note'] as String?,
    );

Map<String, dynamic> _$V3PatternDepartureToJson(
  V3PatternDeparture instance,
) => <String, dynamic>{
  'skipped_stops': instance.skippedStops?.map((e) => e.toJson()).toList(),
  'stop_id': instance.stopId,
  'route_id': instance.routeId,
  'run_id': instance.runId,
  'run_ref': instance.runRef,
  'direction_id': instance.directionId,
  'disruption_ids': instance.disruptionIds,
  'scheduled_departure_utc': instance.scheduledDepartureUtc?.toIso8601String(),
  'estimated_departure_utc': instance.estimatedDepartureUtc?.toIso8601String(),
  'at_platform': instance.atPlatform,
  'platform_number': instance.platformNumber,
  'flags': instance.flags,
  'departure_sequence': instance.departureSequence,
  'departure_note': instance.departureNote,
};

V3StoppingPatternStop _$V3StoppingPatternStopFromJson(
  Map<String, dynamic> json,
) => V3StoppingPatternStop(
  stopTicket: json['stop_ticket'] == null
      ? null
      : V3StopTicket.fromJson(json['stop_ticket'] as Map<String, dynamic>),
  stopDistance: (json['stop_distance'] as num?)?.toDouble(),
  stopSuburb: json['stop_suburb'] as String?,
  stopName: json['stop_name'] as String?,
  stopId: (json['stop_id'] as num?)?.toInt(),
  routeType: (json['route_type'] as num?)?.toInt(),
  stopLatitude: (json['stop_latitude'] as num?)?.toDouble(),
  stopLongitude: (json['stop_longitude'] as num?)?.toDouble(),
  stopLandmark: json['stop_landmark'] as String?,
  stopSequence: (json['stop_sequence'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3StoppingPatternStopToJson(
  V3StoppingPatternStop instance,
) => <String, dynamic>{
  'stop_ticket': instance.stopTicket?.toJson(),
  'stop_distance': instance.stopDistance,
  'stop_suburb': instance.stopSuburb,
  'stop_name': instance.stopName,
  'stop_id': instance.stopId,
  'route_type': instance.routeType,
  'stop_latitude': instance.stopLatitude,
  'stop_longitude': instance.stopLongitude,
  'stop_landmark': instance.stopLandmark,
  'stop_sequence': instance.stopSequence,
};

V3PeriodsResponse _$V3PeriodsResponseFromJson(Map<String, dynamic> json) =>
    V3PeriodsResponse(
      periods:
          (json['periods'] as List<dynamic>?)
              ?.map((e) => e as Object)
              .toList() ??
          [],
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3PeriodsResponseToJson(V3PeriodsResponse instance) =>
    <String, dynamic>{
      'periods': instance.periods,
      'status': instance.status?.toJson(),
    };

V3RouteResponse _$V3RouteResponseFromJson(Map<String, dynamic> json) =>
    V3RouteResponse(
      route: json['route'] == null
          ? null
          : V3RouteWithStatus.fromJson(json['route'] as Map<String, dynamic>),
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3RouteResponseToJson(V3RouteResponse instance) =>
    <String, dynamic>{
      'route': instance.route?.toJson(),
      'status': instance.status?.toJson(),
    };

V3RouteWithStatus _$V3RouteWithStatusFromJson(Map<String, dynamic> json) =>
    V3RouteWithStatus(
      routeServiceStatus: json['route_service_status'] == null
          ? null
          : V3RouteServiceStatus.fromJson(
              json['route_service_status'] as Map<String, dynamic>,
            ),
      routeType: (json['route_type'] as num?)?.toInt(),
      routeId: (json['route_id'] as num?)?.toInt(),
      routeName: json['route_name'] as String?,
      routeNumber: json['route_number'] as String?,
      routeGtfsId: json['route_gtfs_id'] as String?,
      geopath:
          (json['geopath'] as List<dynamic>?)
              ?.map((e) => e as Object)
              .toList() ??
          [],
    );

Map<String, dynamic> _$V3RouteWithStatusToJson(V3RouteWithStatus instance) =>
    <String, dynamic>{
      'route_service_status': instance.routeServiceStatus?.toJson(),
      'route_type': instance.routeType,
      'route_id': instance.routeId,
      'route_name': instance.routeName,
      'route_number': instance.routeNumber,
      'route_gtfs_id': instance.routeGtfsId,
      'geopath': instance.geopath,
    };

V3RouteServiceStatus _$V3RouteServiceStatusFromJson(
  Map<String, dynamic> json,
) => V3RouteServiceStatus(
  description: json['description'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$V3RouteServiceStatusToJson(
  V3RouteServiceStatus instance,
) => <String, dynamic>{
  'description': instance.description,
  'timestamp': instance.timestamp?.toIso8601String(),
};

V3RouteTypesResponse _$V3RouteTypesResponseFromJson(
  Map<String, dynamic> json,
) => V3RouteTypesResponse(
  routeTypes:
      (json['route_types'] as List<dynamic>?)
          ?.map((e) => V3RouteType.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3RouteTypesResponseToJson(
  V3RouteTypesResponse instance,
) => <String, dynamic>{
  'route_types': instance.routeTypes?.map((e) => e.toJson()).toList(),
  'status': instance.status?.toJson(),
};

V3RouteType _$V3RouteTypeFromJson(Map<String, dynamic> json) => V3RouteType(
  routeTypeName: json['route_type_name'] as String?,
  routeType: (json['route_type'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3RouteTypeToJson(V3RouteType instance) =>
    <String, dynamic>{
      'route_type_name': instance.routeTypeName,
      'route_type': instance.routeType,
    };

V3RunsBroadParameters _$V3RunsBroadParametersFromJson(
  Map<String, dynamic> json,
) => V3RunsBroadParameters(
  expand:
      (json['expand'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  dateUtc: json['date_utc'] == null
      ? null
      : DateTime.parse(json['date_utc'] as String),
  includeAdvertisedInterchange: json['include_advertised_interchange'] as bool?,
);

Map<String, dynamic> _$V3RunsBroadParametersToJson(
  V3RunsBroadParameters instance,
) => <String, dynamic>{
  'expand': instance.expand,
  'date_utc': instance.dateUtc?.toIso8601String(),
  'include_advertised_interchange': instance.includeAdvertisedInterchange,
};

V3RunsResponse _$V3RunsResponseFromJson(Map<String, dynamic> json) =>
    V3RunsResponse(
      runs:
          (json['runs'] as List<dynamic>?)
              ?.map((e) => V3Run.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3RunsResponseToJson(V3RunsResponse instance) =>
    <String, dynamic>{
      'runs': instance.runs?.map((e) => e.toJson()).toList(),
      'status': instance.status?.toJson(),
    };

V3RunsSpecificParameters _$V3RunsSpecificParametersFromJson(
  Map<String, dynamic> json,
) => V3RunsSpecificParameters(
  includeGeopath: json['include_geopath'] as bool?,
  expand:
      (json['expand'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  dateUtc: json['date_utc'] == null
      ? null
      : DateTime.parse(json['date_utc'] as String),
  includeAdvertisedInterchange: json['include_advertised_interchange'] as bool?,
);

Map<String, dynamic> _$V3RunsSpecificParametersToJson(
  V3RunsSpecificParameters instance,
) => <String, dynamic>{
  'include_geopath': instance.includeGeopath,
  'expand': instance.expand,
  'date_utc': instance.dateUtc?.toIso8601String(),
  'include_advertised_interchange': instance.includeAdvertisedInterchange,
};

V3RunAndRouteTypeParameters _$V3RunAndRouteTypeParametersFromJson(
  Map<String, dynamic> json,
) => V3RunAndRouteTypeParameters(
  expand:
      (json['expand'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  dateUtc: json['date_utc'] == null
      ? null
      : DateTime.parse(json['date_utc'] as String),
  includeGeopath: json['include_geopath'] as bool?,
);

Map<String, dynamic> _$V3RunAndRouteTypeParametersToJson(
  V3RunAndRouteTypeParameters instance,
) => <String, dynamic>{
  'expand': instance.expand,
  'date_utc': instance.dateUtc?.toIso8601String(),
  'include_geopath': instance.includeGeopath,
};

V3RunResponse _$V3RunResponseFromJson(Map<String, dynamic> json) =>
    V3RunResponse(
      run: json['run'] == null
          ? null
          : V3Run.fromJson(json['run'] as Map<String, dynamic>),
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3RunResponseToJson(V3RunResponse instance) =>
    <String, dynamic>{
      'run': instance.run?.toJson(),
      'status': instance.status?.toJson(),
    };

V3SearchParameters _$V3SearchParametersFromJson(Map<String, dynamic> json) =>
    V3SearchParameters(
      routeTypes:
          (json['route_types'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      maxDistance: (json['max_distance'] as num?)?.toDouble(),
      includeAddresses: json['include_addresses'] as bool?,
      includeOutlets: json['include_outlets'] as bool?,
      matchStopBySuburb: json['match_stop_by_suburb'] as bool?,
      matchRouteBySuburb: json['match_route_by_suburb'] as bool?,
      matchStopByGtfsStopId: json['match_stop_by_gtfs_stop_id'] as bool?,
    );

Map<String, dynamic> _$V3SearchParametersToJson(V3SearchParameters instance) =>
    <String, dynamic>{
      'route_types': instance.routeTypes,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'max_distance': instance.maxDistance,
      'include_addresses': instance.includeAddresses,
      'include_outlets': instance.includeOutlets,
      'match_stop_by_suburb': instance.matchStopBySuburb,
      'match_route_by_suburb': instance.matchRouteBySuburb,
      'match_stop_by_gtfs_stop_id': instance.matchStopByGtfsStopId,
    };

V3SearchResult _$V3SearchResultFromJson(Map<String, dynamic> json) =>
    V3SearchResult(
      stops:
          (json['stops'] as List<dynamic>?)
              ?.map((e) => V3ResultStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      routes:
          (json['routes'] as List<dynamic>?)
              ?.map((e) => V3ResultRoute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      outlets:
          (json['outlets'] as List<dynamic>?)
              ?.map((e) => V3ResultOutlet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3SearchResultToJson(V3SearchResult instance) =>
    <String, dynamic>{
      'stops': instance.stops?.map((e) => e.toJson()).toList(),
      'routes': instance.routes?.map((e) => e.toJson()).toList(),
      'outlets': instance.outlets?.map((e) => e.toJson()).toList(),
      'status': instance.status?.toJson(),
    };

V3ResultStop _$V3ResultStopFromJson(Map<String, dynamic> json) => V3ResultStop(
  stopDistance: (json['stop_distance'] as num?)?.toDouble(),
  stopSuburb: json['stop_suburb'] as String?,
  routeType: (json['route_type'] as num?)?.toInt(),
  routes:
      (json['routes'] as List<dynamic>?)
          ?.map((e) => V3ResultRoute.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  stopLatitude: (json['stop_latitude'] as num?)?.toDouble(),
  stopLongitude: (json['stop_longitude'] as num?)?.toDouble(),
  stopSequence: (json['stop_sequence'] as num?)?.toInt(),
  stopId: (json['stop_id'] as num?)?.toInt(),
  stopName: json['stop_name'] as String?,
  stopLandmark: json['stop_landmark'] as String?,
);

Map<String, dynamic> _$V3ResultStopToJson(V3ResultStop instance) =>
    <String, dynamic>{
      'stop_distance': instance.stopDistance,
      'stop_suburb': instance.stopSuburb,
      'route_type': instance.routeType,
      'routes': instance.routes?.map((e) => e.toJson()).toList(),
      'stop_latitude': instance.stopLatitude,
      'stop_longitude': instance.stopLongitude,
      'stop_sequence': instance.stopSequence,
      'stop_id': instance.stopId,
      'stop_name': instance.stopName,
      'stop_landmark': instance.stopLandmark,
    };

V3ResultRoute _$V3ResultRouteFromJson(Map<String, dynamic> json) =>
    V3ResultRoute(
      routeName: json['route_name'] as String?,
      routeNumber: json['route_number'] as String?,
      routeType: (json['route_type'] as num?)?.toInt(),
      routeId: (json['route_id'] as num?)?.toInt(),
      routeGtfsId: json['route_gtfs_id'] as String?,
      routeServiceStatus: json['route_service_status'] == null
          ? null
          : V3RouteServiceStatus.fromJson(
              json['route_service_status'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$V3ResultRouteToJson(V3ResultRoute instance) =>
    <String, dynamic>{
      'route_name': instance.routeName,
      'route_number': instance.routeNumber,
      'route_type': instance.routeType,
      'route_id': instance.routeId,
      'route_gtfs_id': instance.routeGtfsId,
      'route_service_status': instance.routeServiceStatus?.toJson(),
    };

V3ResultOutlet _$V3ResultOutletFromJson(Map<String, dynamic> json) =>
    V3ResultOutlet(
      outletDistance: (json['outlet_distance'] as num?)?.toDouble(),
      outletSlidSpid: json['outlet_slid_spid'] as String?,
      outletName: json['outlet_name'] as String?,
      outletBusiness: json['outlet_business'] as String?,
      outletLatitude: (json['outlet_latitude'] as num?)?.toDouble(),
      outletLongitude: (json['outlet_longitude'] as num?)?.toDouble(),
      outletSuburb: json['outlet_suburb'] as String?,
      outletPostcode: (json['outlet_postcode'] as num?)?.toInt(),
      outletBusinessHourMon: json['outlet_business_hour_mon'] as String?,
      outletBusinessHourTue: json['outlet_business_hour_tue'] as String?,
      outletBusinessHourWed: json['outlet_business_hour_wed'] as String?,
      outletBusinessHourThur: json['outlet_business_hour_thur'] as String?,
      outletBusinessHourFri: json['outlet_business_hour_fri'] as String?,
      outletBusinessHourSat: json['outlet_business_hour_sat'] as String?,
      outletBusinessHourSun: json['outlet_business_hour_sun'] as String?,
      outletNotes: json['outlet_notes'] as String?,
    );

Map<String, dynamic> _$V3ResultOutletToJson(V3ResultOutlet instance) =>
    <String, dynamic>{
      'outlet_distance': instance.outletDistance,
      'outlet_slid_spid': instance.outletSlidSpid,
      'outlet_name': instance.outletName,
      'outlet_business': instance.outletBusiness,
      'outlet_latitude': instance.outletLatitude,
      'outlet_longitude': instance.outletLongitude,
      'outlet_suburb': instance.outletSuburb,
      'outlet_postcode': instance.outletPostcode,
      'outlet_business_hour_mon': instance.outletBusinessHourMon,
      'outlet_business_hour_tue': instance.outletBusinessHourTue,
      'outlet_business_hour_wed': instance.outletBusinessHourWed,
      'outlet_business_hour_thur': instance.outletBusinessHourThur,
      'outlet_business_hour_fri': instance.outletBusinessHourFri,
      'outlet_business_hour_sat': instance.outletBusinessHourSat,
      'outlet_business_hour_sun': instance.outletBusinessHourSun,
      'outlet_notes': instance.outletNotes,
    };

V3GenerateDivaMappingResponse _$V3GenerateDivaMappingResponseFromJson(
  Map<String, dynamic> json,
) => V3GenerateDivaMappingResponse(
  mappingVersion: json['mapping_version'] as String?,
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3GenerateDivaMappingResponseToJson(
  V3GenerateDivaMappingResponse instance,
) => <String, dynamic>{
  'mapping_version': instance.mappingVersion,
  'status': instance.status?.toJson(),
};

V3SiriReferenceDataRequest _$V3SiriReferenceDataRequestFromJson(
  Map<String, dynamic> json,
) => V3SiriReferenceDataRequest(
  lineRefs:
      (json['line_refs'] as List<dynamic>?)
          ?.map(
            (e) => V3SiriLineRefDirectionRefStopPointRef.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [],
  stopPointRefs:
      (json['stop_point_refs'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  dateUtc: json['date_utc'] == null
      ? null
      : DateTime.parse(json['date_utc'] as String),
  mappingVersion: json['mapping_version'] as String,
);

Map<String, dynamic> _$V3SiriReferenceDataRequestToJson(
  V3SiriReferenceDataRequest instance,
) => <String, dynamic>{
  'line_refs': instance.lineRefs.map((e) => e.toJson()).toList(),
  'stop_point_refs': instance.stopPointRefs,
  'date_utc': instance.dateUtc?.toIso8601String(),
  'mapping_version': instance.mappingVersion,
};

V3SiriLineRefDirectionRefStopPointRef
_$V3SiriLineRefDirectionRefStopPointRefFromJson(Map<String, dynamic> json) =>
    V3SiriLineRefDirectionRefStopPointRef(
      lineRef: json['line_ref'] as String,
      directionRef: (json['direction_ref'] as num).toInt(),
      stopPointRef: (json['stop_point_ref'] as num).toInt(),
    );

Map<String, dynamic> _$V3SiriLineRefDirectionRefStopPointRefToJson(
  V3SiriLineRefDirectionRefStopPointRef instance,
) => <String, dynamic>{
  'line_ref': instance.lineRef,
  'direction_ref': instance.directionRef,
  'stop_point_ref': instance.stopPointRef,
};

V3SiriReferenceDataMappingsResponse
_$V3SiriReferenceDataMappingsResponseFromJson(Map<String, dynamic> json) =>
    V3SiriReferenceDataMappingsResponse(
      mappingVersion: json['mapping_version'] as String?,
      lineRefs: json['line_refs'] as Map<String, dynamic>?,
      stopPointRefs: json['stop_point_refs'] as Map<String, dynamic>?,
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3SiriReferenceDataMappingsResponseToJson(
  V3SiriReferenceDataMappingsResponse instance,
) => <String, dynamic>{
  'mapping_version': instance.mappingVersion,
  'line_refs': instance.lineRefs,
  'stop_point_refs': instance.stopPointRefs,
  'status': instance.status?.toJson(),
};

V3SiriDirectionRefsDictionary _$V3SiriDirectionRefsDictionaryFromJson(
  Map<String, dynamic> json,
) => V3SiriDirectionRefsDictionary(
  directionRefs: json['direction_refs'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$V3SiriDirectionRefsDictionaryToJson(
  V3SiriDirectionRefsDictionary instance,
) => <String, dynamic>{'direction_refs': instance.directionRefs};

V3StopPoint _$V3StopPointFromJson(Map<String, dynamic> json) =>
    V3StopPoint(stopId: (json['stop_id'] as num?)?.toInt());

Map<String, dynamic> _$V3StopPointToJson(V3StopPoint instance) =>
    <String, dynamic>{'stop_id': instance.stopId};

V3SiriStopsRefsDictionary _$V3SiriStopsRefsDictionaryFromJson(
  Map<String, dynamic> json,
) => V3SiriStopsRefsDictionary(
  stopPointRefs: json['stop_point_refs'] as Map<String, dynamic>?,
  unmatchedStopPointRefs:
      json['unmatched_stop_point_refs'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$V3SiriStopsRefsDictionaryToJson(
  V3SiriStopsRefsDictionary instance,
) => <String, dynamic>{
  'stop_point_refs': instance.stopPointRefs,
  'unmatched_stop_point_refs': instance.unmatchedStopPointRefs,
};

V3SiriReferenceDataDetail _$V3SiriReferenceDataDetailFromJson(
  Map<String, dynamic> json,
) => V3SiriReferenceDataDetail(
  noMatchReason: (json['NoMatchReason'] as num?)?.toInt(),
  routeId: (json['route_id'] as num?)?.toInt(),
  routeNumberShort: json['route_number_short'] as String?,
  directionId: (json['direction_id'] as num?)?.toInt(),
  trackingSupplierId: (json['tracking_supplier_id'] as num?)?.toInt(),
  routeType: (json['route_type'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3SiriReferenceDataDetailToJson(
  V3SiriReferenceDataDetail instance,
) => <String, dynamic>{
  'NoMatchReason': instance.noMatchReason,
  'route_id': instance.routeId,
  'route_number_short': instance.routeNumberShort,
  'direction_id': instance.directionId,
  'tracking_supplier_id': instance.trackingSupplierId,
  'route_type': instance.routeType,
};

V3SiriLineRefsRequest _$V3SiriLineRefsRequestFromJson(
  Map<String, dynamic> json,
) => V3SiriLineRefsRequest(
  lineRefs:
      (json['line_refs'] as List<dynamic>?)
          ?.map((e) => V3SiriLineRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  mappingVersion: json['mapping_version'] as String,
);

Map<String, dynamic> _$V3SiriLineRefsRequestToJson(
  V3SiriLineRefsRequest instance,
) => <String, dynamic>{
  'line_refs': instance.lineRefs?.map((e) => e.toJson()).toList(),
  'mapping_version': instance.mappingVersion,
};

V3SiriLineRef _$V3SiriLineRefFromJson(Map<String, dynamic> json) =>
    V3SiriLineRef(
      lineRef: json['line_ref'] as String,
      directionRef: (json['direction_ref'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V3SiriLineRefToJson(V3SiriLineRef instance) =>
    <String, dynamic>{
      'line_ref': instance.lineRef,
      'direction_ref': instance.directionRef,
    };

V3SiriLineRefMappingsResponse _$V3SiriLineRefMappingsResponseFromJson(
  Map<String, dynamic> json,
) => V3SiriLineRefMappingsResponse(
  mappingVersion: json['mapping_version'] as String?,
  lineRefs: json['line_refs'] as Map<String, dynamic>?,
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3SiriLineRefMappingsResponseToJson(
  V3SiriLineRefMappingsResponse instance,
) => <String, dynamic>{
  'mapping_version': instance.mappingVersion,
  'line_refs': instance.lineRefs,
  'status': instance.status?.toJson(),
};

V3SiriLineRefDirectionRefsDictionary
_$V3SiriLineRefDirectionRefsDictionaryFromJson(Map<String, dynamic> json) =>
    V3SiriLineRefDirectionRefsDictionary(
      directionRefs: json['direction_refs'] as Map<String, dynamic>?,
      unmatchedDirectionRefs:
          json['unmatched_direction_refs'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$V3SiriLineRefDirectionRefsDictionaryToJson(
  V3SiriLineRefDirectionRefsDictionary instance,
) => <String, dynamic>{
  'direction_refs': instance.directionRefs,
  'unmatched_direction_refs': instance.unmatchedDirectionRefs,
};

V3DynamoDbTimetablesReponse _$V3DynamoDbTimetablesReponseFromJson(
  Map<String, dynamic> json,
) => V3DynamoDbTimetablesReponse(
  timetables:
      (json['timetables'] as List<dynamic>?)
          ?.map((e) => V3DynamoDbTimetable.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3DynamoDbTimetablesReponseToJson(
  V3DynamoDbTimetablesReponse instance,
) => <String, dynamic>{
  'timetables': instance.timetables?.map((e) => e.toJson()).toList(),
  'status': instance.status?.toJson(),
};

V3DynamoDbTimetable _$V3DynamoDbTimetableFromJson(Map<String, dynamic> json) =>
    V3DynamoDbTimetable(
      tableName: json['table_name'] as String?,
      parserVersion: (json['parser_version'] as num?)?.toInt(),
      parserMappingVersion: json['parser_mapping_version'] as String?,
      ptVersion: (json['pt_version'] as num?)?.toInt(),
      ptMappingVersion: json['pt_mapping_version'] as String?,
      transportType: (json['transport_type'] as num?)?.toInt(),
      applicableDate: json['applicable_date'] == null
          ? null
          : DateTime.parse(json['applicable_date'] as String),
      applicableLocalDate: json['applicable_local_date'] as String?,
      exists: json['exists'] as bool?,
    );

Map<String, dynamic> _$V3DynamoDbTimetableToJson(
  V3DynamoDbTimetable instance,
) => <String, dynamic>{
  'table_name': instance.tableName,
  'parser_version': instance.parserVersion,
  'parser_mapping_version': instance.parserMappingVersion,
  'pt_version': instance.ptVersion,
  'pt_mapping_version': instance.ptMappingVersion,
  'transport_type': instance.transportType,
  'applicable_date': instance.applicableDate?.toIso8601String(),
  'applicable_local_date': instance.applicableLocalDate,
  'exists': instance.exists,
};

V3SiriDownstreamSubscription _$V3SiriDownstreamSubscriptionFromJson(
  Map<String, dynamic> json,
) => V3SiriDownstreamSubscription(
  subscriberRef: json['subscriber_ref'] as String?,
  subscriptionRef: json['subscription_ref'] as String?,
  messageType: (json['message_type'] as num?)?.toInt(),
  siriFormat: (json['siri_format'] as num?)?.toInt(),
  siriVersion: json['siri_version'] as String?,
  consumerAddress: json['consumer_address'] as String?,
  initialTerminationTime: json['initial_termination_time'] == null
      ? null
      : DateTime.parse(json['initial_termination_time'] as String),
  validityPeriodStart: json['validity_period_start'] == null
      ? null
      : DateTime.parse(json['validity_period_start'] as String),
  validityPeriodEnd: json['validity_period_end'] == null
      ? null
      : DateTime.parse(json['validity_period_end'] as String),
  previewInterval: json['preview_interval'] as String?,
  topics:
      (json['topics'] as List<dynamic>?)
          ?.map(
            (e) => V3SiriDownstreamSubscriptionTopic.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$V3SiriDownstreamSubscriptionToJson(
  V3SiriDownstreamSubscription instance,
) => <String, dynamic>{
  'subscriber_ref': instance.subscriberRef,
  'subscription_ref': instance.subscriptionRef,
  'message_type': instance.messageType,
  'siri_format': instance.siriFormat,
  'siri_version': instance.siriVersion,
  'consumer_address': instance.consumerAddress,
  'initial_termination_time': instance.initialTerminationTime
      ?.toIso8601String(),
  'validity_period_start': instance.validityPeriodStart?.toIso8601String(),
  'validity_period_end': instance.validityPeriodEnd?.toIso8601String(),
  'preview_interval': instance.previewInterval,
  'topics': instance.topics?.map((e) => e.toJson()).toList(),
};

V3SiriDownstreamSubscriptionTopic _$V3SiriDownstreamSubscriptionTopicFromJson(
  Map<String, dynamic> json,
) => V3SiriDownstreamSubscriptionTopic(
  lineRef: json['line_ref'] as String?,
  directionRef: (json['direction_ref'] as num?)?.toInt(),
  routeType: (json['route_type'] as num?)?.toInt(),
);

Map<String, dynamic> _$V3SiriDownstreamSubscriptionTopicToJson(
  V3SiriDownstreamSubscriptionTopic instance,
) => <String, dynamic>{
  'line_ref': instance.lineRef,
  'direction_ref': instance.directionRef,
  'route_type': instance.routeType,
};

V3SiriProductionTimetableSubscriptionRequest
_$V3SiriProductionTimetableSubscriptionRequestFromJson(
  Map<String, dynamic> json,
) => V3SiriProductionTimetableSubscriptionRequest(
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  subscriberRef: json['subscriber_ref'] as String,
  subscriptionRef: json['subscription_ref'] as String,
  siriFormat: (json['siri_format'] as num).toInt(),
  siriVersion: json['siri_version'] as String,
  consumerAddress: json['consumer_address'] as String,
  initialTerminationTime: DateTime.parse(
    json['initial_termination_time'] as String,
  ),
  topics:
      (json['topics'] as List<dynamic>?)
          ?.map(
            (e) => V3SiriSubscriptionTopic.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$V3SiriProductionTimetableSubscriptionRequestToJson(
  V3SiriProductionTimetableSubscriptionRequest instance,
) => <String, dynamic>{
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'subscriber_ref': instance.subscriberRef,
  'subscription_ref': instance.subscriptionRef,
  'siri_format': instance.siriFormat,
  'siri_version': instance.siriVersion,
  'consumer_address': instance.consumerAddress,
  'initial_termination_time': instance.initialTerminationTime.toIso8601String(),
  'topics': instance.topics.map((e) => e.toJson()).toList(),
};

V3SiriSubscriptionTopic _$V3SiriSubscriptionTopicFromJson(
  Map<String, dynamic> json,
) => V3SiriSubscriptionTopic(
  lineRef: json['line_ref'] as String,
  directionRef: (json['direction_ref'] as num?)?.toInt(),
  routeType: (json['route_type'] as num).toInt(),
);

Map<String, dynamic> _$V3SiriSubscriptionTopicToJson(
  V3SiriSubscriptionTopic instance,
) => <String, dynamic>{
  'line_ref': instance.lineRef,
  'direction_ref': instance.directionRef,
  'route_type': instance.routeType,
};

V3SiriDownstreamSubscriptionResponse
_$V3SiriDownstreamSubscriptionResponseFromJson(Map<String, dynamic> json) =>
    V3SiriDownstreamSubscriptionResponse(
      validUntil: json['valid_until'] == null
          ? null
          : DateTime.parse(json['valid_until'] as String),
    );

Map<String, dynamic> _$V3SiriDownstreamSubscriptionResponseToJson(
  V3SiriDownstreamSubscriptionResponse instance,
) => <String, dynamic>{'valid_until': instance.validUntil?.toIso8601String()};

V3SiriEstimatedTimetableSubscriptionRequest
_$V3SiriEstimatedTimetableSubscriptionRequestFromJson(
  Map<String, dynamic> json,
) => V3SiriEstimatedTimetableSubscriptionRequest(
  previewInterval: json['preview_interval'] as String,
  subscriberRef: json['subscriber_ref'] as String,
  subscriptionRef: json['subscription_ref'] as String,
  siriFormat: (json['siri_format'] as num).toInt(),
  siriVersion: json['siri_version'] as String,
  consumerAddress: json['consumer_address'] as String,
  initialTerminationTime: DateTime.parse(
    json['initial_termination_time'] as String,
  ),
  topics:
      (json['topics'] as List<dynamic>?)
          ?.map(
            (e) => V3SiriSubscriptionTopic.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$V3SiriEstimatedTimetableSubscriptionRequestToJson(
  V3SiriEstimatedTimetableSubscriptionRequest instance,
) => <String, dynamic>{
  'preview_interval': instance.previewInterval,
  'subscriber_ref': instance.subscriberRef,
  'subscription_ref': instance.subscriptionRef,
  'siri_format': instance.siriFormat,
  'siri_version': instance.siriVersion,
  'consumer_address': instance.consumerAddress,
  'initial_termination_time': instance.initialTerminationTime.toIso8601String(),
  'topics': instance.topics.map((e) => e.toJson()).toList(),
};

V3SiriDownstreamSubscriptionDeleteRequest
_$V3SiriDownstreamSubscriptionDeleteRequestFromJson(
  Map<String, dynamic> json,
) => V3SiriDownstreamSubscriptionDeleteRequest(
  subscriberRef: json['subscriber_ref'] as String,
  subscriptionRef:
      (json['subscription_ref'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$V3SiriDownstreamSubscriptionDeleteRequestToJson(
  V3SiriDownstreamSubscriptionDeleteRequest instance,
) => <String, dynamic>{
  'subscriber_ref': instance.subscriberRef,
  'subscription_ref': instance.subscriptionRef,
};

V3Void _$V3VoidFromJson(Map<String, dynamic> json) => V3Void();

Map<String, dynamic> _$V3VoidToJson(V3Void instance) => <String, dynamic>{};

V3StopResponse _$V3StopResponseFromJson(Map<String, dynamic> json) =>
    V3StopResponse(
      stop: json['stop'] == null
          ? null
          : V3StopDetails.fromJson(json['stop'] as Map<String, dynamic>),
      disruptions: json['disruptions'] as Map<String, dynamic>?,
      status: json['status'] == null
          ? null
          : V3Status.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3StopResponseToJson(V3StopResponse instance) =>
    <String, dynamic>{
      'stop': instance.stop?.toJson(),
      'disruptions': instance.disruptions,
      'status': instance.status?.toJson(),
    };

V3StopDetails _$V3StopDetailsFromJson(
  Map<String, dynamic> json,
) => V3StopDetails(
  disruptionIds:
      (json['disruption_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  stationType: json['station_type'] as String?,
  stationDescription: json['station_description'] as String?,
  routeType: (json['route_type'] as num?)?.toInt(),
  stopLocation: json['stop_location'] == null
      ? null
      : V3StopLocation.fromJson(json['stop_location'] as Map<String, dynamic>),
  stopAmenities: json['stop_amenities'] == null
      ? null
      : V3StopAmenityDetails.fromJson(
          json['stop_amenities'] as Map<String, dynamic>,
        ),
  stopAccessibility: json['stop_accessibility'] == null
      ? null
      : V3StopAccessibility.fromJson(
          json['stop_accessibility'] as Map<String, dynamic>,
        ),
  stopStaffing: json['stop_staffing'] == null
      ? null
      : V3StopStaffing.fromJson(json['stop_staffing'] as Map<String, dynamic>),
  routes:
      (json['routes'] as List<dynamic>?)?.map((e) => e as Object).toList() ??
      [],
  stopId: (json['stop_id'] as num?)?.toInt(),
  stopName: json['stop_name'] as String?,
  stopLandmark: json['stop_landmark'] as String?,
);

Map<String, dynamic> _$V3StopDetailsToJson(V3StopDetails instance) =>
    <String, dynamic>{
      'disruption_ids': instance.disruptionIds,
      'station_type': instance.stationType,
      'station_description': instance.stationDescription,
      'route_type': instance.routeType,
      'stop_location': instance.stopLocation?.toJson(),
      'stop_amenities': instance.stopAmenities?.toJson(),
      'stop_accessibility': instance.stopAccessibility?.toJson(),
      'stop_staffing': instance.stopStaffing?.toJson(),
      'routes': instance.routes,
      'stop_id': instance.stopId,
      'stop_name': instance.stopName,
      'stop_landmark': instance.stopLandmark,
    };

V3StopLocation _$V3StopLocationFromJson(Map<String, dynamic> json) =>
    V3StopLocation(
      gps: json['gps'] == null
          ? null
          : V3StopGps.fromJson(json['gps'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$V3StopLocationToJson(V3StopLocation instance) =>
    <String, dynamic>{'gps': instance.gps?.toJson()};

V3StopAmenityDetails _$V3StopAmenityDetailsFromJson(
  Map<String, dynamic> json,
) => V3StopAmenityDetails(
  toilet: json['toilet'] as bool?,
  taxiRank: json['taxi_rank'] as bool?,
  carParking: json['car_parking'] as String?,
  cctv: json['cctv'] as bool?,
);

Map<String, dynamic> _$V3StopAmenityDetailsToJson(
  V3StopAmenityDetails instance,
) => <String, dynamic>{
  'toilet': instance.toilet,
  'taxi_rank': instance.taxiRank,
  'car_parking': instance.carParking,
  'cctv': instance.cctv,
};

V3StopAccessibility _$V3StopAccessibilityFromJson(Map<String, dynamic> json) =>
    V3StopAccessibility(
      lighting: json['lighting'] as bool?,
      platformNumber: (json['platform_number'] as num?)?.toInt(),
      audioCustomerInformation: json['audio_customer_information'] as bool?,
      escalator: json['escalator'] as bool?,
      hearingLoop: json['hearing_loop'] as bool?,
      lift: json['lift'] as bool?,
      stairs: json['stairs'] as bool?,
      stopAccessible: json['stop_accessible'] as bool?,
      tactileGroundSurfaceIndicator:
          json['tactile_ground_surface_indicator'] as bool?,
      waitingRoom: json['waiting_room'] as bool?,
      wheelchair: json['wheelchair'] == null
          ? null
          : V3StopAccessibilityWheelchair.fromJson(
              json['wheelchair'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$V3StopAccessibilityToJson(
  V3StopAccessibility instance,
) => <String, dynamic>{
  'lighting': instance.lighting,
  'platform_number': instance.platformNumber,
  'audio_customer_information': instance.audioCustomerInformation,
  'escalator': instance.escalator,
  'hearing_loop': instance.hearingLoop,
  'lift': instance.lift,
  'stairs': instance.stairs,
  'stop_accessible': instance.stopAccessible,
  'tactile_ground_surface_indicator': instance.tactileGroundSurfaceIndicator,
  'waiting_room': instance.waitingRoom,
  'wheelchair': instance.wheelchair?.toJson(),
};

V3StopStaffing _$V3StopStaffingFromJson(Map<String, dynamic> json) =>
    V3StopStaffing(
      friAmFrom: json['fri_am_from'] as String?,
      friAmTo: json['fri_am_to'] as String?,
      friPmFrom: json['fri_pm_from'] as String?,
      friPmTo: json['fri_pm_to'] as String?,
      monAmFrom: json['mon_am_from'] as String?,
      monAmTo: json['mon_am_to'] as String?,
      monPmFrom: json['mon_pm_from'] as String?,
      monPmTo: json['mon_pm_to'] as String?,
      phAdditionalText: json['ph_additional_text'] as String?,
      phFrom: json['ph_from'] as String?,
      phTo: json['ph_to'] as String?,
      satAmFrom: json['sat_am_from'] as String?,
      satAmTo: json['sat_am_to'] as String?,
      satPmFrom: json['sat_pm_from'] as String?,
      satPmTo: json['sat_pm_to'] as String?,
      sunAmFrom: json['sun_am_from'] as String?,
      sunAmTo: json['sun_am_to'] as String?,
      sunPmFrom: json['sun_pm_from'] as String?,
      sunPmTo: json['sun_pm_to'] as String?,
      thuAmFrom: json['thu_am_from'] as String?,
      thuAmTo: json['thu_am_to'] as String?,
      thuPmFrom: json['thu_pm_from'] as String?,
      thuPmTo: json['thu_pm_to'] as String?,
      tueAmFrom: json['tue_am_from'] as String?,
      tueAmTo: json['tue_am_to'] as String?,
      tuePmFrom: json['tue_pm_from'] as String?,
      tuePmTo: json['tue_pm_to'] as String?,
      wedAmFrom: json['wed_am_from'] as String?,
      wedAmTo: json['wed_am_to'] as String?,
      wedPmFrom: json['wed_pm_from'] as String?,
      wedPmTo: json['wed_pm_To'] as String?,
    );

Map<String, dynamic> _$V3StopStaffingToJson(V3StopStaffing instance) =>
    <String, dynamic>{
      'fri_am_from': instance.friAmFrom,
      'fri_am_to': instance.friAmTo,
      'fri_pm_from': instance.friPmFrom,
      'fri_pm_to': instance.friPmTo,
      'mon_am_from': instance.monAmFrom,
      'mon_am_to': instance.monAmTo,
      'mon_pm_from': instance.monPmFrom,
      'mon_pm_to': instance.monPmTo,
      'ph_additional_text': instance.phAdditionalText,
      'ph_from': instance.phFrom,
      'ph_to': instance.phTo,
      'sat_am_from': instance.satAmFrom,
      'sat_am_to': instance.satAmTo,
      'sat_pm_from': instance.satPmFrom,
      'sat_pm_to': instance.satPmTo,
      'sun_am_from': instance.sunAmFrom,
      'sun_am_to': instance.sunAmTo,
      'sun_pm_from': instance.sunPmFrom,
      'sun_pm_to': instance.sunPmTo,
      'thu_am_from': instance.thuAmFrom,
      'thu_am_to': instance.thuAmTo,
      'thu_pm_from': instance.thuPmFrom,
      'thu_pm_to': instance.thuPmTo,
      'tue_am_from': instance.tueAmFrom,
      'tue_am_to': instance.tueAmTo,
      'tue_pm_from': instance.tuePmFrom,
      'tue_pm_to': instance.tuePmTo,
      'wed_am_from': instance.wedAmFrom,
      'wed_am_to': instance.wedAmTo,
      'wed_pm_from': instance.wedPmFrom,
      'wed_pm_To': instance.wedPmTo,
    };

V3StopGps _$V3StopGpsFromJson(Map<String, dynamic> json) => V3StopGps(
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$V3StopGpsToJson(V3StopGps instance) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

V3StopAccessibilityWheelchair _$V3StopAccessibilityWheelchairFromJson(
  Map<String, dynamic> json,
) => V3StopAccessibilityWheelchair(
  accessibleRamp: json['accessible_ramp'] as bool?,
  parking: json['parking'] as bool?,
  telephone: json['telephone'] as bool?,
  toilet: json['toilet'] as bool?,
  lowTicketCounter: json['low_ticket_counter'] as bool?,
  manouvering: json['manouvering'] as bool?,
  raisedPlatform: json['raised_platform'] as bool?,
  ramp: json['ramp'] as bool?,
  secondaryPath: json['secondary_path'] as bool?,
  raisedPlatformShelther: json['raised_platform_shelther'] as bool?,
  steepRamp: json['steep_ramp'] as bool?,
);

Map<String, dynamic> _$V3StopAccessibilityWheelchairToJson(
  V3StopAccessibilityWheelchair instance,
) => <String, dynamic>{
  'accessible_ramp': instance.accessibleRamp,
  'parking': instance.parking,
  'telephone': instance.telephone,
  'toilet': instance.toilet,
  'low_ticket_counter': instance.lowTicketCounter,
  'manouvering': instance.manouvering,
  'raised_platform': instance.raisedPlatform,
  'ramp': instance.ramp,
  'secondary_path': instance.secondaryPath,
  'raised_platform_shelther': instance.raisedPlatformShelther,
  'steep_ramp': instance.steepRamp,
};

V3StopsByRouteIdParameters _$V3StopsByRouteIdParametersFromJson(
  Map<String, dynamic> json,
) => V3StopsByRouteIdParameters(
  directionId: (json['direction_id'] as num?)?.toInt(),
  stopDisruptions: json['stop_disruptions'] as bool?,
  includeGeopath: json['include_geopath'] as bool?,
  geopathUtc: json['geopath_utc'] == null
      ? null
      : DateTime.parse(json['geopath_utc'] as String),
  includeAdvertisedInterchange: json['include_advertised_interchange'] as bool?,
);

Map<String, dynamic> _$V3StopsByRouteIdParametersToJson(
  V3StopsByRouteIdParameters instance,
) => <String, dynamic>{
  'direction_id': instance.directionId,
  'stop_disruptions': instance.stopDisruptions,
  'include_geopath': instance.includeGeopath,
  'geopath_utc': instance.geopathUtc?.toIso8601String(),
  'include_advertised_interchange': instance.includeAdvertisedInterchange,
};

V3StopsOnRouteResponse _$V3StopsOnRouteResponseFromJson(
  Map<String, dynamic> json,
) => V3StopsOnRouteResponse(
  stops:
      (json['stops'] as List<dynamic>?)
          ?.map((e) => V3StopOnRoute.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  disruptions: json['disruptions'] as Map<String, dynamic>?,
  geopath:
      (json['geopath'] as List<dynamic>?)?.map((e) => e as Object).toList() ??
      [],
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3StopsOnRouteResponseToJson(
  V3StopsOnRouteResponse instance,
) => <String, dynamic>{
  'stops': instance.stops?.map((e) => e.toJson()).toList(),
  'disruptions': instance.disruptions,
  'geopath': instance.geopath,
  'status': instance.status?.toJson(),
};

V3StopOnRoute _$V3StopOnRouteFromJson(Map<String, dynamic> json) =>
    V3StopOnRoute(
      disruptionIds:
          (json['disruption_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      stopSuburb: json['stop_suburb'] as String?,
      routeType: (json['route_type'] as num?)?.toInt(),
      stopLatitude: (json['stop_latitude'] as num?)?.toDouble(),
      stopLongitude: (json['stop_longitude'] as num?)?.toDouble(),
      stopSequence: (json['stop_sequence'] as num?)?.toInt(),
      stopTicket: json['stop_ticket'] == null
          ? null
          : V3StopTicket.fromJson(json['stop_ticket'] as Map<String, dynamic>),
      interchange:
          (json['interchange'] as List<dynamic>?)
              ?.map(
                (e) => V3InterchangeRoute.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      stopId: (json['stop_id'] as num?)?.toInt(),
      stopName: json['stop_name'] as String?,
      stopLandmark: json['stop_landmark'] as String?,
    );

Map<String, dynamic> _$V3StopOnRouteToJson(V3StopOnRoute instance) =>
    <String, dynamic>{
      'disruption_ids': instance.disruptionIds,
      'stop_suburb': instance.stopSuburb,
      'route_type': instance.routeType,
      'stop_latitude': instance.stopLatitude,
      'stop_longitude': instance.stopLongitude,
      'stop_sequence': instance.stopSequence,
      'stop_ticket': instance.stopTicket?.toJson(),
      'interchange': instance.interchange?.map((e) => e.toJson()).toList(),
      'stop_id': instance.stopId,
      'stop_name': instance.stopName,
      'stop_landmark': instance.stopLandmark,
    };

V3InterchangeRoute _$V3InterchangeRouteFromJson(Map<String, dynamic> json) =>
    V3InterchangeRoute(
      routeId: (json['route_id'] as num?)?.toInt(),
      advertised: json['advertised'] as bool?,
    );

Map<String, dynamic> _$V3InterchangeRouteToJson(V3InterchangeRoute instance) =>
    <String, dynamic>{
      'route_id': instance.routeId,
      'advertised': instance.advertised,
    };

V3StopsByDistanceResponse _$V3StopsByDistanceResponseFromJson(
  Map<String, dynamic> json,
) => V3StopsByDistanceResponse(
  stops:
      (json['stops'] as List<dynamic>?)
          ?.map((e) => V3StopGeosearch.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  disruptions: json['disruptions'] as Map<String, dynamic>?,
  status: json['status'] == null
      ? null
      : V3Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V3StopsByDistanceResponseToJson(
  V3StopsByDistanceResponse instance,
) => <String, dynamic>{
  'stops': instance.stops?.map((e) => e.toJson()).toList(),
  'disruptions': instance.disruptions,
  'status': instance.status?.toJson(),
};

V3StopGeosearch _$V3StopGeosearchFromJson(Map<String, dynamic> json) =>
    V3StopGeosearch(
      disruptionIds:
          (json['disruption_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      stopDistance: (json['stop_distance'] as num?)?.toDouble(),
      stopSuburb: json['stop_suburb'] as String?,
      stopName: json['stop_name'] as String?,
      stopId: (json['stop_id'] as num?)?.toInt(),
      routeType: (json['route_type'] as num?)?.toInt(),
      routes:
          (json['routes'] as List<dynamic>?)
              ?.map((e) => e as Object)
              .toList() ??
          [],
      stopLatitude: (json['stop_latitude'] as num?)?.toDouble(),
      stopLongitude: (json['stop_longitude'] as num?)?.toDouble(),
      stopLandmark: json['stop_landmark'] as String?,
      stopSequence: (json['stop_sequence'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V3StopGeosearchToJson(V3StopGeosearch instance) =>
    <String, dynamic>{
      'disruption_ids': instance.disruptionIds,
      'stop_distance': instance.stopDistance,
      'stop_suburb': instance.stopSuburb,
      'stop_name': instance.stopName,
      'stop_id': instance.stopId,
      'route_type': instance.routeType,
      'routes': instance.routes,
      'stop_latitude': instance.stopLatitude,
      'stop_longitude': instance.stopLongitude,
      'stop_landmark': instance.stopLandmark,
      'stop_sequence': instance.stopSequence,
    };
