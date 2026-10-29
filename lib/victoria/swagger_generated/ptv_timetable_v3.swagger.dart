// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element_parameter

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;
import 'ptv_timetable_v3.enums.swagger.dart' as enums;
import 'ptv_timetable_v3.metadata.swagger.dart';
export 'ptv_timetable_v3.enums.swagger.dart';

part 'ptv_timetable_v3.swagger.chopper.dart';
part 'ptv_timetable_v3.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class PtvTimetableV3 extends ChopperService {
  static PtvTimetableV3 create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$PtvTimetableV3(client);
    }

    final newClient = ChopperClient(
      services: [_$PtvTimetableV3()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl ?? Uri.parse('https://timetableapi.ptv.vic.gov.au'),
    );
    return _$PtvTimetableV3(newClient);
  }

  ///View departures for all routes from a stop
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param stop_id Identifier of stop; values returned by Stops API
  ///@param platform_numbers Filter by platform number at stop
  ///@param direction_id Filter by identifier of direction of travel; values returned by Directions API - /v3/directions/route/{route_id}
  ///@param gtfs Indicates that stop_id parameter will accept "GTFS stop_id" data
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param max_results Maximum number of results returned
  ///@param include_cancelled Indicates if cancelled services (if they exist) are returned (default = false) - metropolitan train only
  ///@param look_backwards Indicates if filtering runs (and their departures) to those that arrive at destination before date_utc (default = false). Requires max_results &gt; 0.
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, Stop, Route, Run, Direction, Disruption, VehiclePosition, VehicleDescriptor or None.  Run must be expanded to receive VehiclePosition and VehicleDescriptor information.
  ///@param include_geopath Indicates if the route geopath should be returned
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DeparturesResponse>>
  v3DeparturesRouteTypeRouteTypeStopStopIdGet({
    required enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
    routeType,
    required int stopId,
    List<int>? platformNumbers,
    int? directionId,
    bool? gtfs,
    DateTime? dateUtc,
    int? maxResults,
    bool? includeCancelled,
    bool? lookBackwards,
    List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand>? expand,
    bool? includeGeopath,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DeparturesResponse,
      () => V3DeparturesResponse.fromJsonFactory,
    );

    return _v3DeparturesRouteTypeRouteTypeStopStopIdGet(
      routeType: routeType?.value?.toString(),
      stopId: stopId,
      platformNumbers: platformNumbers,
      directionId: directionId,
      gtfs: gtfs,
      dateUtc: dateUtc,
      maxResults: maxResults,
      includeCancelled: includeCancelled,
      lookBackwards: lookBackwards,
      expand: v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandListToJson(
        expand,
      ),
      includeGeopath: includeGeopath,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View departures for all routes from a stop
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param stop_id Identifier of stop; values returned by Stops API
  ///@param platform_numbers Filter by platform number at stop
  ///@param direction_id Filter by identifier of direction of travel; values returned by Directions API - /v3/directions/route/{route_id}
  ///@param gtfs Indicates that stop_id parameter will accept "GTFS stop_id" data
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param max_results Maximum number of results returned
  ///@param include_cancelled Indicates if cancelled services (if they exist) are returned (default = false) - metropolitan train only
  ///@param look_backwards Indicates if filtering runs (and their departures) to those that arrive at destination before date_utc (default = false). Requires max_results &gt; 0.
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, Stop, Route, Run, Direction, Disruption, VehiclePosition, VehicleDescriptor or None.  Run must be expanded to receive VehiclePosition and VehicleDescriptor information.
  ///@param include_geopath Indicates if the route geopath should be returned
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/departures/route_type/{route_type}/stop/{stop_id}')
  Future<chopper.Response<V3DeparturesResponse>>
  _v3DeparturesRouteTypeRouteTypeStopStopIdGet({
    @Path('route_type') required String? routeType,
    @Path('stop_id') required int stopId,
    @Query('platform_numbers') List<int>? platformNumbers,
    @Query('direction_id') int? directionId,
    @Query('gtfs') bool? gtfs,
    @Query('date_utc') DateTime? dateUtc,
    @Query('max_results') int? maxResults,
    @Query('include_cancelled') bool? includeCancelled,
    @Query('look_backwards') bool? lookBackwards,
    @Query('expand') List<Object?>? expand,
    @Query('include_geopath') bool? includeGeopath,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View departures for all routes from a stop',
      operationId: 'Departures_GetForStop',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Departures"],
      deprecated: false,
    ),
  });

  ///View departures for a specific route from a stop
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param stop_id Identifier of stop; values returned by Stops API
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param direction_id Filter by identifier of direction of travel; values returned by Directions API - /v3/directions/route/{route_id}
  ///@param gtfs Indicates that stop_id parameter will accept "GTFS stop_id" data
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param max_results Maximum number of results returned
  ///@param include_cancelled Indicates if cancelled services (if they exist) are returned (default = false) - metropolitan train only
  ///@param look_backwards Indicates if filtering runs (and their departures) to those that arrive at destination before date_utc (default = false). Requires max_results &gt; 0.
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, Stop, Route, Run, Direction, Disruption, VehiclePosition, VehicleDescriptor or None.  Run must be expanded to receive VehiclePosition and VehicleDescriptor information.
  ///@param include_geopath Indicates if the route geopath should be returned
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DeparturesResponse>>
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGet({
    required enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
    routeType,
    required int stopId,
    required String routeId,
    int? directionId,
    bool? gtfs,
    DateTime? dateUtc,
    int? maxResults,
    bool? includeCancelled,
    bool? lookBackwards,
    List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand>?
    expand,
    bool? includeGeopath,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DeparturesResponse,
      () => V3DeparturesResponse.fromJsonFactory,
    );

    return _v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGet(
      routeType: routeType?.value?.toString(),
      stopId: stopId,
      routeId: routeId,
      directionId: directionId,
      gtfs: gtfs,
      dateUtc: dateUtc,
      maxResults: maxResults,
      includeCancelled: includeCancelled,
      lookBackwards: lookBackwards,
      expand:
          v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandListToJson(
            expand,
          ),
      includeGeopath: includeGeopath,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View departures for a specific route from a stop
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param stop_id Identifier of stop; values returned by Stops API
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param direction_id Filter by identifier of direction of travel; values returned by Directions API - /v3/directions/route/{route_id}
  ///@param gtfs Indicates that stop_id parameter will accept "GTFS stop_id" data
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param max_results Maximum number of results returned
  ///@param include_cancelled Indicates if cancelled services (if they exist) are returned (default = false) - metropolitan train only
  ///@param look_backwards Indicates if filtering runs (and their departures) to those that arrive at destination before date_utc (default = false). Requires max_results &gt; 0.
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, Stop, Route, Run, Direction, Disruption, VehiclePosition, VehicleDescriptor or None.  Run must be expanded to receive VehiclePosition and VehicleDescriptor information.
  ///@param include_geopath Indicates if the route geopath should be returned
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(
    path:
        '/v3/departures/route_type/{route_type}/stop/{stop_id}/route/{route_id}',
  )
  Future<chopper.Response<V3DeparturesResponse>>
  _v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGet({
    @Path('route_type') required String? routeType,
    @Path('stop_id') required int stopId,
    @Path('route_id') required String routeId,
    @Query('direction_id') int? directionId,
    @Query('gtfs') bool? gtfs,
    @Query('date_utc') DateTime? dateUtc,
    @Query('max_results') int? maxResults,
    @Query('include_cancelled') bool? includeCancelled,
    @Query('look_backwards') bool? lookBackwards,
    @Query('expand') List<Object?>? expand,
    @Query('include_geopath') bool? includeGeopath,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View departures for a specific route from a stop',
      operationId: 'Departures_GetForStopAndRoute',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Departures"],
      deprecated: false,
    ),
  });

  ///View directions that a route travels in
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DirectionsResponse>> v3DirectionsRouteRouteIdGet({
    required int routeId,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DirectionsResponse,
      () => V3DirectionsResponse.fromJsonFactory,
    );

    return _v3DirectionsRouteRouteIdGet(
      routeId: routeId,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View directions that a route travels in
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/directions/route/{route_id}')
  Future<chopper.Response<V3DirectionsResponse>> _v3DirectionsRouteRouteIdGet({
    @Path('route_id') required int routeId,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View directions that a route travels in',
      operationId: 'Directions_ForRoute',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Directions"],
      deprecated: false,
    ),
  });

  ///View all routes for a direction of travel
  ///@param direction_id Identifier of direction of travel; values returned by Directions API - /v3/directions/route/{route_id}
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DirectionsResponse>> v3DirectionsDirectionIdGet({
    required int directionId,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DirectionsResponse,
      () => V3DirectionsResponse.fromJsonFactory,
    );

    return _v3DirectionsDirectionIdGet(
      directionId: directionId,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all routes for a direction of travel
  ///@param direction_id Identifier of direction of travel; values returned by Directions API - /v3/directions/route/{route_id}
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/directions/{direction_id}')
  Future<chopper.Response<V3DirectionsResponse>> _v3DirectionsDirectionIdGet({
    @Path('direction_id') required int directionId,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all routes for a direction of travel',
      operationId: 'Directions_ForDirection',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Directions"],
      deprecated: false,
    ),
  });

  ///View all routes of a particular type for a direction of travel
  ///@param direction_id Identifier of direction of travel; values returned by Directions API - /v3/directions/route/{route_id}
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DirectionsResponse>>
  v3DirectionsDirectionIdRouteTypeRouteTypeGet({
    required int directionId,
    required enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType
    routeType,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DirectionsResponse,
      () => V3DirectionsResponse.fromJsonFactory,
    );

    return _v3DirectionsDirectionIdRouteTypeRouteTypeGet(
      directionId: directionId,
      routeType: routeType?.value?.toString(),
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all routes of a particular type for a direction of travel
  ///@param direction_id Identifier of direction of travel; values returned by Directions API - /v3/directions/route/{route_id}
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/directions/{direction_id}/route_type/{route_type}')
  Future<chopper.Response<V3DirectionsResponse>>
  _v3DirectionsDirectionIdRouteTypeRouteTypeGet({
    @Path('direction_id') required int directionId,
    @Path('route_type') required String? routeType,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all routes of a particular type for a direction of travel',
      operationId: 'Directions_ForDirectionAndType',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Directions"],
      deprecated: false,
    ),
  });

  ///View all disruptions for all route types
  ///@param route_types Filter by route_type; values returned via RouteTypes API
  ///@param disruption_modes Filter by disruption_mode; values returned via v3/disruptions/modes API
  ///@param disruption_status Filter by status of disruption
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DisruptionsResponse>> v3DisruptionsGet({
    List<enums.V3DisruptionsGetRouteTypes>? routeTypes,
    List<enums.V3DisruptionsGetDisruptionModes>? disruptionModes,
    enums.V3DisruptionsGetDisruptionStatus? disruptionStatus,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DisruptionsResponse,
      () => V3DisruptionsResponse.fromJsonFactory,
    );

    return _v3DisruptionsGet(
      routeTypes: v3DisruptionsGetRouteTypesListToJson(routeTypes),
      disruptionModes: v3DisruptionsGetDisruptionModesListToJson(
        disruptionModes,
      ),
      disruptionStatus: disruptionStatus?.value?.toString(),
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all disruptions for all route types
  ///@param route_types Filter by route_type; values returned via RouteTypes API
  ///@param disruption_modes Filter by disruption_mode; values returned via v3/disruptions/modes API
  ///@param disruption_status Filter by status of disruption
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/disruptions')
  Future<chopper.Response<V3DisruptionsResponse>> _v3DisruptionsGet({
    @Query('route_types') List<Object?>? routeTypes,
    @Query('disruption_modes') List<Object?>? disruptionModes,
    @Query('disruption_status') String? disruptionStatus,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all disruptions for all route types',
      operationId: 'Disruptions_GetAllDisruptions',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Disruptions"],
      deprecated: false,
    ),
  });

  ///View all disruptions for a particular route
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param disruption_status Filter by status of disruption
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DisruptionsResponse>> v3DisruptionsRouteRouteIdGet({
    required int routeId,
    enums.V3DisruptionsRouteRouteIdGetDisruptionStatus? disruptionStatus,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DisruptionsResponse,
      () => V3DisruptionsResponse.fromJsonFactory,
    );

    return _v3DisruptionsRouteRouteIdGet(
      routeId: routeId,
      disruptionStatus: disruptionStatus?.value?.toString(),
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all disruptions for a particular route
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param disruption_status Filter by status of disruption
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/disruptions/route/{route_id}')
  Future<chopper.Response<V3DisruptionsResponse>>
  _v3DisruptionsRouteRouteIdGet({
    @Path('route_id') required int routeId,
    @Query('disruption_status') String? disruptionStatus,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all disruptions for a particular route',
      operationId: 'Disruptions_GetDisruptionsByRoute',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Disruptions"],
      deprecated: false,
    ),
  });

  ///View all disruptions for a particular route and stop
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param stop_id Identifier of stop; values returned by Stops API - v3/stops
  ///@param disruption_status Filter by status of disruption
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DisruptionsResponse>>
  v3DisruptionsRouteRouteIdStopStopIdGet({
    required int routeId,
    required int stopId,
    enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus?
    disruptionStatus,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DisruptionsResponse,
      () => V3DisruptionsResponse.fromJsonFactory,
    );

    return _v3DisruptionsRouteRouteIdStopStopIdGet(
      routeId: routeId,
      stopId: stopId,
      disruptionStatus: disruptionStatus?.value?.toString(),
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all disruptions for a particular route and stop
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param stop_id Identifier of stop; values returned by Stops API - v3/stops
  ///@param disruption_status Filter by status of disruption
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/disruptions/route/{route_id}/stop/{stop_id}')
  Future<chopper.Response<V3DisruptionsResponse>>
  _v3DisruptionsRouteRouteIdStopStopIdGet({
    @Path('route_id') required int routeId,
    @Path('stop_id') required int stopId,
    @Query('disruption_status') String? disruptionStatus,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all disruptions for a particular route and stop',
      operationId: 'Disruptions_GetDisruptionsByRouteAndStop',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Disruptions"],
      deprecated: false,
    ),
  });

  ///View all disruptions for a particular stop
  ///@param stop_id Identifier of stop; values returned by Stops API - v3/stops
  ///@param disruption_status Filter by status of disruption
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DisruptionsResponse>> v3DisruptionsStopStopIdGet({
    required int stopId,
    enums.V3DisruptionsStopStopIdGetDisruptionStatus? disruptionStatus,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DisruptionsResponse,
      () => V3DisruptionsResponse.fromJsonFactory,
    );

    return _v3DisruptionsStopStopIdGet(
      stopId: stopId,
      disruptionStatus: disruptionStatus?.value?.toString(),
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all disruptions for a particular stop
  ///@param stop_id Identifier of stop; values returned by Stops API - v3/stops
  ///@param disruption_status Filter by status of disruption
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/disruptions/stop/{stop_id}')
  Future<chopper.Response<V3DisruptionsResponse>> _v3DisruptionsStopStopIdGet({
    @Path('stop_id') required int stopId,
    @Query('disruption_status') String? disruptionStatus,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all disruptions for a particular stop',
      operationId: 'Disruptions_GetDisruptionsByStop',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Disruptions"],
      deprecated: false,
    ),
  });

  ///View a specific disruption
  ///@param disruption_id Identifier of disruption; values returned by Disruptions API - /v3/disruptions OR /v3/disruptions/route/{route_id}
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DisruptionResponse>> v3DisruptionsDisruptionIdGet({
    required int disruptionId,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DisruptionResponse,
      () => V3DisruptionResponse.fromJsonFactory,
    );

    return _v3DisruptionsDisruptionIdGet(
      disruptionId: disruptionId,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View a specific disruption
  ///@param disruption_id Identifier of disruption; values returned by Disruptions API - /v3/disruptions OR /v3/disruptions/route/{route_id}
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/disruptions/{disruption_id}')
  Future<chopper.Response<V3DisruptionResponse>> _v3DisruptionsDisruptionIdGet({
    @Path('disruption_id') required int disruptionId,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View a specific disruption',
      operationId: 'Disruptions_GetDisruptionById',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Disruptions"],
      deprecated: false,
    ),
  });

  ///Get all disruption modes
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3DisruptionModesResponse>> v3DisruptionsModesGet({
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3DisruptionModesResponse,
      () => V3DisruptionModesResponse.fromJsonFactory,
    );

    return _v3DisruptionsModesGet(
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///Get all disruption modes
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/disruptions/modes')
  Future<chopper.Response<V3DisruptionModesResponse>> _v3DisruptionsModesGet({
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Get all disruption modes',
      operationId: 'Disruptions_GetDisruptionModes',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Disruptions"],
      deprecated: false,
    ),
  });

  ///Estimate a fare by zone
  ///@param minZone Minimum Zone travelled through ie. 1
  ///@param maxZone Maximum Zone travelled through id. 6
  ///@param journey_touch_on_utc JourneyTouchOnUtc in format yyyy-M-d h:m (e.g 2016-5-31 16:53).
  ///@param journey_touch_off_utc JourneyTouchOffUtc in format yyyy-M-d h:m (e.g 2016-5-31 16:53).
  ///@param is_journey_in_free_tram_zone
  ///@param is_journey_in_overlap_zone
  ///@param travelled_route_types
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3FareEstimateResponse>>
  v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGet({
    required int minZone,
    required int maxZone,
    DateTime? journeyTouchOnUtc,
    DateTime? journeyTouchOffUtc,
    bool? isJourneyInFreeTramZone,
    bool? isJourneyInOverlapZone,
    List<
      enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
    >?
    travelledRouteTypes,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3FareEstimateResponse,
      () => V3FareEstimateResponse.fromJsonFactory,
    );

    return _v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGet(
      minZone: minZone,
      maxZone: maxZone,
      journeyTouchOnUtc: journeyTouchOnUtc,
      journeyTouchOffUtc: journeyTouchOffUtc,
      isJourneyInFreeTramZone: isJourneyInFreeTramZone,
      isJourneyInOverlapZone: isJourneyInOverlapZone,
      travelledRouteTypes:
          v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesListToJson(
            travelledRouteTypes,
          ),
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///Estimate a fare by zone
  ///@param minZone Minimum Zone travelled through ie. 1
  ///@param maxZone Maximum Zone travelled through id. 6
  ///@param journey_touch_on_utc JourneyTouchOnUtc in format yyyy-M-d h:m (e.g 2016-5-31 16:53).
  ///@param journey_touch_off_utc JourneyTouchOffUtc in format yyyy-M-d h:m (e.g 2016-5-31 16:53).
  ///@param is_journey_in_free_tram_zone
  ///@param is_journey_in_overlap_zone
  ///@param travelled_route_types
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/fare_estimate/min_zone/{minZone}/max_zone/{maxZone}')
  Future<chopper.Response<V3FareEstimateResponse>>
  _v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGet({
    @Path('minZone') required int minZone,
    @Path('maxZone') required int maxZone,
    @Query('journey_touch_on_utc') DateTime? journeyTouchOnUtc,
    @Query('journey_touch_off_utc') DateTime? journeyTouchOffUtc,
    @Query('is_journey_in_free_tram_zone') bool? isJourneyInFreeTramZone,
    @Query('is_journey_in_overlap_zone') bool? isJourneyInOverlapZone,
    @Query('travelled_route_types') List<Object?>? travelledRouteTypes,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Estimate a fare by zone',
      operationId: 'FareEstimate_GetFareEstimateByZone',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["FareEstimate"],
      deprecated: false,
    ),
  });

  ///List all ticket outlets
  ///@param max_results Maximum number of results returned (default = 30)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3OutletResponse>> v3OutletsGet({
    int? maxResults,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3OutletResponse,
      () => V3OutletResponse.fromJsonFactory,
    );

    return _v3OutletsGet(
      maxResults: maxResults,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///List all ticket outlets
  ///@param max_results Maximum number of results returned (default = 30)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/outlets')
  Future<chopper.Response<V3OutletResponse>> _v3OutletsGet({
    @Query('max_results') int? maxResults,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List all ticket outlets',
      operationId: 'Outlets_GetAllOutlets',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Outlets"],
      deprecated: false,
    ),
  });

  ///List ticket outlets near a specific location
  ///@param latitude Geographic coordinate of latitude
  ///@param longitude Geographic coordinate of longitude
  ///@param max_distance Filter by maximum distance (in metres) from location specified via latitude and longitude parameters (default = 300)
  ///@param max_results Maximum number of results returned (default = 30)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3OutletGeolocationResponse>>
  v3OutletsLocationLatitudeLongitudeGet({
    required num latitude,
    required num longitude,
    num? maxDistance,
    int? maxResults,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3OutletGeolocationResponse,
      () => V3OutletGeolocationResponse.fromJsonFactory,
    );

    return _v3OutletsLocationLatitudeLongitudeGet(
      latitude: latitude,
      longitude: longitude,
      maxDistance: maxDistance,
      maxResults: maxResults,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///List ticket outlets near a specific location
  ///@param latitude Geographic coordinate of latitude
  ///@param longitude Geographic coordinate of longitude
  ///@param max_distance Filter by maximum distance (in metres) from location specified via latitude and longitude parameters (default = 300)
  ///@param max_results Maximum number of results returned (default = 30)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/outlets/location/{latitude},{longitude}')
  Future<chopper.Response<V3OutletGeolocationResponse>>
  _v3OutletsLocationLatitudeLongitudeGet({
    @Path('latitude') required num latitude,
    @Path('longitude') required num longitude,
    @Query('max_distance') num? maxDistance,
    @Query('max_results') int? maxResults,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'List ticket outlets near a specific location',
      operationId: 'Outlets_GetOutletsByGeolocation',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Outlets"],
      deprecated: false,
    ),
  });

  ///View the stopping pattern for a specific trip/service run
  ///@param run_ref The run_ref is the identifier of a run as returned by the departures/* and runs/* endpoints. WARNING, run_id is deprecated. Use run_ref instead.
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, Stop, Route, Run, Direction, Disruption, VehiclePosition, VehicleDescriptor and None. Default is Disruption. Run must be expanded to receive VehiclePosition and VehicleDescriptor information.
  ///@param stop_id Filter by stop_id; values returned by Stops API
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_skipped_stops Include any skipped stops in a stopping pattern. Defaults to false.
  ///@param include_geopath Indicates if geopath data will be returned (default = false)
  ///@param include_advertised_interchange Indicates whether data related to interchanges should be included in the response (default = false)  When set to true, this parameter enables API clients to retrieve additional exchange information (stops, routes, runs, directions and disruptions) in a single call instead of making multiple requests
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3StoppingPattern>>
  v3PatternRunRunRefRouteTypeRouteTypeGet({
    required String runRef,
    required enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType routeType,
    List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand>? expand,
    int? stopId,
    DateTime? dateUtc,
    bool? includeSkippedStops,
    bool? includeGeopath,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3StoppingPattern,
      () => V3StoppingPattern.fromJsonFactory,
    );

    return _v3PatternRunRunRefRouteTypeRouteTypeGet(
      runRef: runRef,
      routeType: routeType?.value?.toString(),
      expand: v3PatternRunRunRefRouteTypeRouteTypeGetExpandListToJson(expand),
      stopId: stopId,
      dateUtc: dateUtc,
      includeSkippedStops: includeSkippedStops,
      includeGeopath: includeGeopath,
      includeAdvertisedInterchange: includeAdvertisedInterchange,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View the stopping pattern for a specific trip/service run
  ///@param run_ref The run_ref is the identifier of a run as returned by the departures/* and runs/* endpoints. WARNING, run_id is deprecated. Use run_ref instead.
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, Stop, Route, Run, Direction, Disruption, VehiclePosition, VehicleDescriptor and None. Default is Disruption. Run must be expanded to receive VehiclePosition and VehicleDescriptor information.
  ///@param stop_id Filter by stop_id; values returned by Stops API
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_skipped_stops Include any skipped stops in a stopping pattern. Defaults to false.
  ///@param include_geopath Indicates if geopath data will be returned (default = false)
  ///@param include_advertised_interchange Indicates whether data related to interchanges should be included in the response (default = false)  When set to true, this parameter enables API clients to retrieve additional exchange information (stops, routes, runs, directions and disruptions) in a single call instead of making multiple requests
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/pattern/run/{run_ref}/route_type/{route_type}')
  Future<chopper.Response<V3StoppingPattern>>
  _v3PatternRunRunRefRouteTypeRouteTypeGet({
    @Path('run_ref') required String runRef,
    @Path('route_type') required String? routeType,
    @Query('expand') List<Object?>? expand,
    @Query('stop_id') int? stopId,
    @Query('date_utc') DateTime? dateUtc,
    @Query('include_skipped_stops') bool? includeSkippedStops,
    @Query('include_geopath') bool? includeGeopath,
    @Query('include_advertised_interchange') bool? includeAdvertisedInterchange,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View the stopping pattern for a specific trip/service run',
      operationId: 'Patterns_GetPatternByRun',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Patterns"],
      deprecated: false,
    ),
  });

  ///View route names and numbers for all routes
  ///@param route_types Filter by route_type; values returned via RouteTypes API
  ///@param route_name Filter by name  of route (accepts partial route name matches)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3RouteResponse>> v3RoutesGet({
    List<enums.V3RoutesGetRouteTypes>? routeTypes,
    String? routeName,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3RouteResponse,
      () => V3RouteResponse.fromJsonFactory,
    );

    return _v3RoutesGet(
      routeTypes: v3RoutesGetRouteTypesListToJson(routeTypes),
      routeName: routeName,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View route names and numbers for all routes
  ///@param route_types Filter by route_type; values returned via RouteTypes API
  ///@param route_name Filter by name  of route (accepts partial route name matches)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/routes')
  Future<chopper.Response<V3RouteResponse>> _v3RoutesGet({
    @Query('route_types') List<Object?>? routeTypes,
    @Query('route_name') String? routeName,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View route names and numbers for all routes',
      operationId: 'Routes_OneOrMoreRoutes',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Routes"],
      deprecated: false,
    ),
  });

  ///View route name and number for specific route ID
  ///@param route_id Identifier of route; values returned by Departures, Directions and Disruptions APIs
  ///@param include_geopath Indicates kif geopath data will be returned (default = false)
  ///@param geopath_utc Filter geopaths by date (ISO 8601 UTC format) (default = current date)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3RouteResponse>> v3RoutesRouteIdGet({
    required int routeId,
    bool? includeGeopath,
    DateTime? geopathUtc,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3RouteResponse,
      () => V3RouteResponse.fromJsonFactory,
    );

    return _v3RoutesRouteIdGet(
      routeId: routeId,
      includeGeopath: includeGeopath,
      geopathUtc: geopathUtc,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View route name and number for specific route ID
  ///@param route_id Identifier of route; values returned by Departures, Directions and Disruptions APIs
  ///@param include_geopath Indicates kif geopath data will be returned (default = false)
  ///@param geopath_utc Filter geopaths by date (ISO 8601 UTC format) (default = current date)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/routes/{route_id}')
  Future<chopper.Response<V3RouteResponse>> _v3RoutesRouteIdGet({
    @Path('route_id') required int routeId,
    @Query('include_geopath') bool? includeGeopath,
    @Query('geopath_utc') DateTime? geopathUtc,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View route name and number for specific route ID',
      operationId: 'Routes_RouteFromId',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Routes"],
      deprecated: false,
    ),
  });

  ///View all route types and their names
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3RouteTypesResponse>> v3RouteTypesGet({
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3RouteTypesResponse,
      () => V3RouteTypesResponse.fromJsonFactory,
    );

    return _v3RouteTypesGet(token: token, devid: devid, signature: signature);
  }

  ///View all route types and their names
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/route_types')
  Future<chopper.Response<V3RouteTypesResponse>> _v3RouteTypesGet({
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all route types and their names',
      operationId: 'RouteTypes_GetRouteTypes',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["RouteTypes"],
      deprecated: false,
    ),
  });

  ///View all trip/service runs for a specific route ID
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes.
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, VehiclePosition, VehicleDescriptor, or None. Default is None.
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_advertised_interchange Indicates whether data related to interchanges should be included in the response (default = false).  When set to true, this parameter enables API clients to retrieve additional exchange information (stops, routes, runs, directions and disruptions) in a single call instead of making multiple requests
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3RunsResponse>> v3RunsRouteRouteIdGet({
    required int routeId,
    List<enums.V3RunsRouteRouteIdGetExpand>? expand,
    DateTime? dateUtc,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3RunsResponse,
      () => V3RunsResponse.fromJsonFactory,
    );

    return _v3RunsRouteRouteIdGet(
      routeId: routeId,
      expand: v3RunsRouteRouteIdGetExpandListToJson(expand),
      dateUtc: dateUtc,
      includeAdvertisedInterchange: includeAdvertisedInterchange,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all trip/service runs for a specific route ID
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes.
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, VehiclePosition, VehicleDescriptor, or None. Default is None.
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_advertised_interchange Indicates whether data related to interchanges should be included in the response (default = false).  When set to true, this parameter enables API clients to retrieve additional exchange information (stops, routes, runs, directions and disruptions) in a single call instead of making multiple requests
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/runs/route/{route_id}')
  Future<chopper.Response<V3RunsResponse>> _v3RunsRouteRouteIdGet({
    @Path('route_id') required int routeId,
    @Query('expand') List<Object?>? expand,
    @Query('date_utc') DateTime? dateUtc,
    @Query('include_advertised_interchange') bool? includeAdvertisedInterchange,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all trip/service runs for a specific route ID',
      operationId: 'Runs_ForRoute',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Runs"],
      deprecated: false,
    ),
  });

  ///View all trip/service runs for a specific route ID and route type
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes.
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, VehiclePosition, VehicleDescriptor, or None. Default is None.
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_advertised_interchange Indicates whether data related to interchanges should be included in the response (default = false).  When set to true, this parameter enables API clients to retrieve additional exchange information (stops, routes, runs, directions and disruptions) in a single call instead of making multiple requests
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3RunsResponse>>
  v3RunsRouteRouteIdRouteTypeRouteTypeGet({
    required int routeId,
    required enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType routeType,
    List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand>? expand,
    DateTime? dateUtc,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3RunsResponse,
      () => V3RunsResponse.fromJsonFactory,
    );

    return _v3RunsRouteRouteIdRouteTypeRouteTypeGet(
      routeId: routeId,
      routeType: routeType?.value?.toString(),
      expand: v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandListToJson(expand),
      dateUtc: dateUtc,
      includeAdvertisedInterchange: includeAdvertisedInterchange,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all trip/service runs for a specific route ID and route type
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes.
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, VehiclePosition, VehicleDescriptor, or None. Default is None.
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_advertised_interchange Indicates whether data related to interchanges should be included in the response (default = false).  When set to true, this parameter enables API clients to retrieve additional exchange information (stops, routes, runs, directions and disruptions) in a single call instead of making multiple requests
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/runs/route/{route_id}/route_type/{route_type}')
  Future<chopper.Response<V3RunsResponse>>
  _v3RunsRouteRouteIdRouteTypeRouteTypeGet({
    @Path('route_id') required int routeId,
    @Path('route_type') required String? routeType,
    @Query('expand') List<Object?>? expand,
    @Query('date_utc') DateTime? dateUtc,
    @Query('include_advertised_interchange') bool? includeAdvertisedInterchange,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'View all trip/service runs for a specific route ID and route type',
      operationId: 'Runs_ForRouteAndRouteType',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Runs"],
      deprecated: false,
    ),
  });

  ///View all trip/service runs for a specific run_ref
  ///@param run_ref The run_ref is the identifier of a run as returned by the departures/* and runs/* endpoints. WARNING, run_id is deprecated. Use run_ref instead.
  ///@param include_geopath Indicates if geopath data will be returned (default = false)
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, VehiclePosition, VehicleDescriptor, or None. Default is None.
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_advertised_interchange Indicates whether data related to interchanges should be included in the response (default = false).  When set to true, this parameter enables API clients to retrieve additional exchange information (stops, routes, runs, directions and disruptions) in a single call instead of making multiple requests
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3RunsResponse>> v3RunsRunRefGet({
    required String runRef,
    bool? includeGeopath,
    List<enums.V3RunsRunRefGetExpand>? expand,
    DateTime? dateUtc,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3RunsResponse,
      () => V3RunsResponse.fromJsonFactory,
    );

    return _v3RunsRunRefGet(
      runRef: runRef,
      includeGeopath: includeGeopath,
      expand: v3RunsRunRefGetExpandListToJson(expand),
      dateUtc: dateUtc,
      includeAdvertisedInterchange: includeAdvertisedInterchange,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all trip/service runs for a specific run_ref
  ///@param run_ref The run_ref is the identifier of a run as returned by the departures/* and runs/* endpoints. WARNING, run_id is deprecated. Use run_ref instead.
  ///@param include_geopath Indicates if geopath data will be returned (default = false)
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, VehiclePosition, VehicleDescriptor, or None. Default is None.
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_advertised_interchange Indicates whether data related to interchanges should be included in the response (default = false).  When set to true, this parameter enables API clients to retrieve additional exchange information (stops, routes, runs, directions and disruptions) in a single call instead of making multiple requests
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/runs/{run_ref}')
  Future<chopper.Response<V3RunsResponse>> _v3RunsRunRefGet({
    @Path('run_ref') required String runRef,
    @Query('include_geopath') bool? includeGeopath,
    @Query('expand') List<Object?>? expand,
    @Query('date_utc') DateTime? dateUtc,
    @Query('include_advertised_interchange') bool? includeAdvertisedInterchange,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all trip/service runs for a specific run_ref',
      operationId: 'Runs_ForRun',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Runs"],
      deprecated: false,
    ),
  });

  ///View the trip/service run for a specific run_ref and route type
  ///@param run_ref The run_ref is the identifier of a run as returned by the departures/* and runs/* endpoints. WARNING, run_id is deprecated. Use run_ref instead.
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, VehiclePosition, VehicleDescriptor, or None. Default is None.
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_geopath Indicates if geopath data will be returned (default = false)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3RunResponse>> v3RunsRunRefRouteTypeRouteTypeGet({
    required String runRef,
    required enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType routeType,
    List<enums.V3RunsRunRefRouteTypeRouteTypeGetExpand>? expand,
    DateTime? dateUtc,
    bool? includeGeopath,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3RunResponse,
      () => V3RunResponse.fromJsonFactory,
    );

    return _v3RunsRunRefRouteTypeRouteTypeGet(
      runRef: runRef,
      routeType: routeType?.value?.toString(),
      expand: v3RunsRunRefRouteTypeRouteTypeGetExpandListToJson(expand),
      dateUtc: dateUtc,
      includeGeopath: includeGeopath,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View the trip/service run for a specific run_ref and route type
  ///@param run_ref The run_ref is the identifier of a run as returned by the departures/* and runs/* endpoints. WARNING, run_id is deprecated. Use run_ref instead.
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param expand List of objects to be returned in full (i.e. expanded) - options include: All, VehiclePosition, VehicleDescriptor, or None. Default is None.
  ///@param date_utc Filter by the date and time of the request (ISO 8601 UTC format) (default = current date and time)
  ///@param include_geopath Indicates if geopath data will be returned (default = false)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/runs/{run_ref}/route_type/{route_type}')
  Future<chopper.Response<V3RunResponse>> _v3RunsRunRefRouteTypeRouteTypeGet({
    @Path('run_ref') required String runRef,
    @Path('route_type') required String? routeType,
    @Query('expand') List<Object?>? expand,
    @Query('date_utc') DateTime? dateUtc,
    @Query('include_geopath') bool? includeGeopath,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'View the trip/service run for a specific run_ref and route type',
      operationId: 'Runs_ForRunAndRouteType',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Runs"],
      deprecated: false,
    ),
  });

  ///View stops, routes and myki ticket outlets that match the search term
  ///@param search_term Search text (note: if search text is numeric and/or less than 3 characters, the API will only return routes)
  ///@param route_types Filter by route_type; values returned via RouteTypes API (note: stops and routes are ordered by route_types specified)
  ///@param latitude Filter by geographic coordinate of latitude
  ///@param longitude Filter by geographic coordinate of longitude
  ///@param max_distance Filter by maximum distance (in metres) from location specified via latitude and longitude parameters
  ///@param include_addresses Placeholder for future development; currently unavailable
  ///@param include_outlets Indicates if outlets will be returned in response (default = true)
  ///@param match_stop_by_suburb Indicates whether to find stops by suburbs in the search term (default = true)
  ///@param match_route_by_suburb Indicates whether to find routes by suburbs in the search term (default = true)
  ///@param match_stop_by_gtfs_stop_id Indicates whether to search for stops according to a metlink stop ID (default = false)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3SearchResult>> v3SearchSearchTermGet({
    required String searchTerm,
    List<enums.V3SearchSearchTermGetRouteTypes>? routeTypes,
    num? latitude,
    num? longitude,
    num? maxDistance,
    bool? includeAddresses,
    bool? includeOutlets,
    bool? matchStopBySuburb,
    bool? matchRouteBySuburb,
    bool? matchStopByGtfsStopId,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3SearchResult,
      () => V3SearchResult.fromJsonFactory,
    );

    return _v3SearchSearchTermGet(
      searchTerm: searchTerm,
      routeTypes: v3SearchSearchTermGetRouteTypesListToJson(routeTypes),
      latitude: latitude,
      longitude: longitude,
      maxDistance: maxDistance,
      includeAddresses: includeAddresses,
      includeOutlets: includeOutlets,
      matchStopBySuburb: matchStopBySuburb,
      matchRouteBySuburb: matchRouteBySuburb,
      matchStopByGtfsStopId: matchStopByGtfsStopId,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View stops, routes and myki ticket outlets that match the search term
  ///@param search_term Search text (note: if search text is numeric and/or less than 3 characters, the API will only return routes)
  ///@param route_types Filter by route_type; values returned via RouteTypes API (note: stops and routes are ordered by route_types specified)
  ///@param latitude Filter by geographic coordinate of latitude
  ///@param longitude Filter by geographic coordinate of longitude
  ///@param max_distance Filter by maximum distance (in metres) from location specified via latitude and longitude parameters
  ///@param include_addresses Placeholder for future development; currently unavailable
  ///@param include_outlets Indicates if outlets will be returned in response (default = true)
  ///@param match_stop_by_suburb Indicates whether to find stops by suburbs in the search term (default = true)
  ///@param match_route_by_suburb Indicates whether to find routes by suburbs in the search term (default = true)
  ///@param match_stop_by_gtfs_stop_id Indicates whether to search for stops according to a metlink stop ID (default = false)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/search/{search_term}')
  Future<chopper.Response<V3SearchResult>> _v3SearchSearchTermGet({
    @Path('search_term') required String searchTerm,
    @Query('route_types') List<Object?>? routeTypes,
    @Query('latitude') num? latitude,
    @Query('longitude') num? longitude,
    @Query('max_distance') num? maxDistance,
    @Query('include_addresses') bool? includeAddresses,
    @Query('include_outlets') bool? includeOutlets,
    @Query('match_stop_by_suburb') bool? matchStopBySuburb,
    @Query('match_route_by_suburb') bool? matchRouteBySuburb,
    @Query('match_stop_by_gtfs_stop_id') bool? matchStopByGtfsStopId,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'View stops, routes and myki ticket outlets that match the search term',
      operationId: 'Search_Search',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Search"],
      deprecated: false,
    ),
  });

  ///View facilities at a specific stop (Metro and V/Line stations only)
  ///@param stop_id Identifier of stop; values returned by Stops API
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param stop_location Indicates if stop location information will be returned (default = false)
  ///@param stop_amenities Indicates if stop amenity information will be returned (default = false)
  ///@param stop_accessibility Indicates if stop accessibility information will be returned (default = false)
  ///@param stop_contact Indicates if stop contact information will be returned (default = false)
  ///@param stop_ticket Indicates if stop ticket information will be returned (default = false)
  ///@param gtfs Incdicates whether the stop_id is a GTFS ID or not
  ///@param stop_staffing Indicates if stop staffing information will be returned (default = false)
  ///@param stop_disruptions Indicates if stop disruption information will be returned (default = false)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3StopResponse>> v3StopsStopIdRouteTypeRouteTypeGet({
    required int stopId,
    required enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType routeType,
    bool? stopLocation,
    bool? stopAmenities,
    bool? stopAccessibility,
    bool? stopContact,
    bool? stopTicket,
    bool? gtfs,
    bool? stopStaffing,
    bool? stopDisruptions,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3StopResponse,
      () => V3StopResponse.fromJsonFactory,
    );

    return _v3StopsStopIdRouteTypeRouteTypeGet(
      stopId: stopId,
      routeType: routeType?.value?.toString(),
      stopLocation: stopLocation,
      stopAmenities: stopAmenities,
      stopAccessibility: stopAccessibility,
      stopContact: stopContact,
      stopTicket: stopTicket,
      gtfs: gtfs,
      stopStaffing: stopStaffing,
      stopDisruptions: stopDisruptions,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View facilities at a specific stop (Metro and V/Line stations only)
  ///@param stop_id Identifier of stop; values returned by Stops API
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param stop_location Indicates if stop location information will be returned (default = false)
  ///@param stop_amenities Indicates if stop amenity information will be returned (default = false)
  ///@param stop_accessibility Indicates if stop accessibility information will be returned (default = false)
  ///@param stop_contact Indicates if stop contact information will be returned (default = false)
  ///@param stop_ticket Indicates if stop ticket information will be returned (default = false)
  ///@param gtfs Incdicates whether the stop_id is a GTFS ID or not
  ///@param stop_staffing Indicates if stop staffing information will be returned (default = false)
  ///@param stop_disruptions Indicates if stop disruption information will be returned (default = false)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/stops/{stop_id}/route_type/{route_type}')
  Future<chopper.Response<V3StopResponse>> _v3StopsStopIdRouteTypeRouteTypeGet({
    @Path('stop_id') required int stopId,
    @Path('route_type') required String? routeType,
    @Query('stop_location') bool? stopLocation,
    @Query('stop_amenities') bool? stopAmenities,
    @Query('stop_accessibility') bool? stopAccessibility,
    @Query('stop_contact') bool? stopContact,
    @Query('stop_ticket') bool? stopTicket,
    @Query('gtfs') bool? gtfs,
    @Query('stop_staffing') bool? stopStaffing,
    @Query('stop_disruptions') bool? stopDisruptions,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'View facilities at a specific stop (Metro and V/Line stations only)',
      operationId: 'Stops_StopDetails',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Stops"],
      deprecated: false,
    ),
  });

  ///View all stops on a specific route
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param direction_id Direction for which the stops need to be returned
  ///@param stop_disruptions Flag to specify whether disruptions should be included in the response
  ///@param include_geopath Flag to specify whether geo_path should be included in the response
  ///@param geopath_utc Filter geopaths by date (ISO 8601 UTC format) (default = current date)
  ///@param include_advertised_interchange Flag to specify whether additional stops for interchanges should be included in the response. Note-: To make use of this flag please pass in direction_id.
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3StopsOnRouteResponse>>
  v3StopsRouteRouteIdRouteTypeRouteTypeGet({
    required int routeId,
    required enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType routeType,
    int? directionId,
    bool? stopDisruptions,
    bool? includeGeopath,
    DateTime? geopathUtc,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3StopsOnRouteResponse,
      () => V3StopsOnRouteResponse.fromJsonFactory,
    );

    return _v3StopsRouteRouteIdRouteTypeRouteTypeGet(
      routeId: routeId,
      routeType: routeType?.value?.toString(),
      directionId: directionId,
      stopDisruptions: stopDisruptions,
      includeGeopath: includeGeopath,
      geopathUtc: geopathUtc,
      includeAdvertisedInterchange: includeAdvertisedInterchange,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all stops on a specific route
  ///@param route_id Identifier of route; values returned by Routes API - v3/routes
  ///@param route_type Number identifying transport mode; values returned via RouteTypes API
  ///@param direction_id Direction for which the stops need to be returned
  ///@param stop_disruptions Flag to specify whether disruptions should be included in the response
  ///@param include_geopath Flag to specify whether geo_path should be included in the response
  ///@param geopath_utc Filter geopaths by date (ISO 8601 UTC format) (default = current date)
  ///@param include_advertised_interchange Flag to specify whether additional stops for interchanges should be included in the response. Note-: To make use of this flag please pass in direction_id.
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/stops/route/{route_id}/route_type/{route_type}')
  Future<chopper.Response<V3StopsOnRouteResponse>>
  _v3StopsRouteRouteIdRouteTypeRouteTypeGet({
    @Path('route_id') required int routeId,
    @Path('route_type') required String? routeType,
    @Query('direction_id') int? directionId,
    @Query('stop_disruptions') bool? stopDisruptions,
    @Query('include_geopath') bool? includeGeopath,
    @Query('geopath_utc') DateTime? geopathUtc,
    @Query('include_advertised_interchange') bool? includeAdvertisedInterchange,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all stops on a specific route',
      operationId: 'Stops_StopsForRoute',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Stops"],
      deprecated: false,
    ),
  });

  ///View all stops near a specific location
  ///@param latitude Geographic coordinate of latitude
  ///@param longitude Geographic coordinate of longitude
  ///@param route_types Filter by route_type; values returned via RouteTypes API
  ///@param max_results Maximum number of results returned (default = 30)
  ///@param max_distance Filter by maximum distance (in metres) from location specified via latitude and longitude parameters (default = 300)
  ///@param stop_disruptions Indicates if stop disruption information will be returned (default = false)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  Future<chopper.Response<V3StopsByDistanceResponse>>
  v3StopsLocationLatitudeLongitudeGet({
    required num latitude,
    required num longitude,
    List<enums.V3StopsLocationLatitudeLongitudeGetRouteTypes>? routeTypes,
    int? maxResults,
    num? maxDistance,
    bool? stopDisruptions,
    String? token,
    String? devid,
    String? signature,
  }) {
    generatedMapping.putIfAbsent(
      V3StopsByDistanceResponse,
      () => V3StopsByDistanceResponse.fromJsonFactory,
    );

    return _v3StopsLocationLatitudeLongitudeGet(
      latitude: latitude,
      longitude: longitude,
      routeTypes: v3StopsLocationLatitudeLongitudeGetRouteTypesListToJson(
        routeTypes,
      ),
      maxResults: maxResults,
      maxDistance: maxDistance,
      stopDisruptions: stopDisruptions,
      token: token,
      devid: devid,
      signature: signature,
    );
  }

  ///View all stops near a specific location
  ///@param latitude Geographic coordinate of latitude
  ///@param longitude Geographic coordinate of longitude
  ///@param route_types Filter by route_type; values returned via RouteTypes API
  ///@param max_results Maximum number of results returned (default = 30)
  ///@param max_distance Filter by maximum distance (in metres) from location specified via latitude and longitude parameters (default = 300)
  ///@param stop_disruptions Indicates if stop disruption information will be returned (default = false)
  ///@param token Please ignore
  ///@param devid Your developer id
  ///@param signature Authentication signature for request
  @GET(path: '/v3/stops/location/{latitude},{longitude}')
  Future<chopper.Response<V3StopsByDistanceResponse>>
  _v3StopsLocationLatitudeLongitudeGet({
    @Path('latitude') required num latitude,
    @Path('longitude') required num longitude,
    @Query('route_types') List<Object?>? routeTypes,
    @Query('max_results') int? maxResults,
    @Query('max_distance') num? maxDistance,
    @Query('stop_disruptions') bool? stopDisruptions,
    @Query('token') String? token,
    @Query('devid') String? devid,
    @Query('signature') String? signature,
    @chopper.Tag()
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'View all stops near a specific location',
      operationId: 'Stops_StopsByGeolocation',
      consumes: [],
      produces: ["application/json", "text/json"],
      security: [],
      tags: ["Stops"],
      deprecated: false,
    ),
  });
}

@JsonSerializable(explicitToJson: true)
class V3CacheKeysRemoveResponse {
  const V3CacheKeysRemoveResponse({this.keys, this.status});

  factory V3CacheKeysRemoveResponse.fromJson(Map<String, dynamic> json) =>
      _$V3CacheKeysRemoveResponseFromJson(json);

  static const toJsonFactory = _$V3CacheKeysRemoveResponseToJson;
  Map<String, dynamic> toJson() => _$V3CacheKeysRemoveResponseToJson(this);

  @JsonKey(name: 'keys')
  final Map<String, dynamic>? keys;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3CacheKeysRemoveResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3CacheKeysRemoveResponse &&
            (identical(other.keys, keys) ||
                const DeepCollectionEquality().equals(other.keys, keys)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(keys) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3CacheKeysRemoveResponseExtension on V3CacheKeysRemoveResponse {
  V3CacheKeysRemoveResponse copyWith({
    Map<String, dynamic>? keys,
    V3Status? status,
  }) {
    return V3CacheKeysRemoveResponse(
      keys: keys ?? this.keys,
      status: status ?? this.status,
    );
  }

  V3CacheKeysRemoveResponse copyWithWrapped({
    Wrapped<Map<String, dynamic>?>? keys,
    Wrapped<V3Status?>? status,
  }) {
    return V3CacheKeysRemoveResponse(
      keys: (keys != null ? keys.value : this.keys),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3CacheKeyRemoved {
  const V3CacheKeyRemoved({this.removed});

  factory V3CacheKeyRemoved.fromJson(Map<String, dynamic> json) =>
      _$V3CacheKeyRemovedFromJson(json);

  static const toJsonFactory = _$V3CacheKeyRemovedToJson;
  Map<String, dynamic> toJson() => _$V3CacheKeyRemovedToJson(this);

  @JsonKey(name: 'Removed')
  final bool? removed;
  static const fromJsonFactory = _$V3CacheKeyRemovedFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3CacheKeyRemoved &&
            (identical(other.removed, removed) ||
                const DeepCollectionEquality().equals(other.removed, removed)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(removed) ^ runtimeType.hashCode;
}

extension $V3CacheKeyRemovedExtension on V3CacheKeyRemoved {
  V3CacheKeyRemoved copyWith({bool? removed}) {
    return V3CacheKeyRemoved(removed: removed ?? this.removed);
  }

  V3CacheKeyRemoved copyWithWrapped({Wrapped<bool?>? removed}) {
    return V3CacheKeyRemoved(
      removed: (removed != null ? removed.value : this.removed),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Status {
  const V3Status({this.version, this.health});

  factory V3Status.fromJson(Map<String, dynamic> json) =>
      _$V3StatusFromJson(json);

  static const toJsonFactory = _$V3StatusToJson;
  Map<String, dynamic> toJson() => _$V3StatusToJson(this);

  @JsonKey(name: 'version')
  final String? version;
  @JsonKey(name: 'health')
  final int? health;
  static const fromJsonFactory = _$V3StatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Status &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.health, health) ||
                const DeepCollectionEquality().equals(other.health, health)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(health) ^
      runtimeType.hashCode;
}

extension $V3StatusExtension on V3Status {
  V3Status copyWith({String? version, int? health}) {
    return V3Status(
      version: version ?? this.version,
      health: health ?? this.health,
    );
  }

  V3Status copyWithWrapped({Wrapped<String?>? version, Wrapped<int?>? health}) {
    return V3Status(
      version: (version != null ? version.value : this.version),
      health: (health != null ? health.value : this.health),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3ErrorResponse {
  const V3ErrorResponse({this.message, this.status});

  factory V3ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$V3ErrorResponseFromJson(json);

  static const toJsonFactory = _$V3ErrorResponseToJson;
  Map<String, dynamic> toJson() => _$V3ErrorResponseToJson(this);

  @JsonKey(name: 'message')
  final String? message;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3ErrorResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3ErrorResponse &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3ErrorResponseExtension on V3ErrorResponse {
  V3ErrorResponse copyWith({String? message, V3Status? status}) {
    return V3ErrorResponse(
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }

  V3ErrorResponse copyWithWrapped({
    Wrapped<String?>? message,
    Wrapped<V3Status?>? status,
  }) {
    return V3ErrorResponse(
      message: (message != null ? message.value : this.message),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3CacheKeyResponse {
  const V3CacheKeyResponse({this.keys, this.status});

  factory V3CacheKeyResponse.fromJson(Map<String, dynamic> json) =>
      _$V3CacheKeyResponseFromJson(json);

  static const toJsonFactory = _$V3CacheKeyResponseToJson;
  Map<String, dynamic> toJson() => _$V3CacheKeyResponseToJson(this);

  @JsonKey(name: 'keys')
  final Map<String, dynamic>? keys;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3CacheKeyResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3CacheKeyResponse &&
            (identical(other.keys, keys) ||
                const DeepCollectionEquality().equals(other.keys, keys)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(keys) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3CacheKeyResponseExtension on V3CacheKeyResponse {
  V3CacheKeyResponse copyWith({Map<String, dynamic>? keys, V3Status? status}) {
    return V3CacheKeyResponse(
      keys: keys ?? this.keys,
      status: status ?? this.status,
    );
  }

  V3CacheKeyResponse copyWithWrapped({
    Wrapped<Map<String, dynamic>?>? keys,
    Wrapped<V3Status?>? status,
  }) {
    return V3CacheKeyResponse(
      keys: (keys != null ? keys.value : this.keys),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3CacheItem {
  const V3CacheItem({this.type, this.value});

  factory V3CacheItem.fromJson(Map<String, dynamic> json) =>
      _$V3CacheItemFromJson(json);

  static const toJsonFactory = _$V3CacheItemToJson;
  Map<String, dynamic> toJson() => _$V3CacheItemToJson(this);

  @JsonKey(name: 'Type')
  final String? type;
  @JsonKey(name: 'Value')
  final Object? value;
  static const fromJsonFactory = _$V3CacheItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3CacheItem &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.value, value) ||
                const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(value) ^
      runtimeType.hashCode;
}

extension $V3CacheItemExtension on V3CacheItem {
  V3CacheItem copyWith({String? type, Object? value}) {
    return V3CacheItem(type: type ?? this.type, value: value ?? this.value);
  }

  V3CacheItem copyWithWrapped({
    Wrapped<String?>? type,
    Wrapped<Object?>? value,
  }) {
    return V3CacheItem(
      type: (type != null ? type.value : this.type),
      value: (value != null ? value.value : this.value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DeparturesBroadParameters {
  const V3DeparturesBroadParameters({
    this.platformNumbers,
    this.directionId,
    this.gtfs,
    this.dateUtc,
    this.maxResults,
    this.includeCancelled,
    this.lookBackwards,
    this.expand,
    this.includeGeopath,
  });

  factory V3DeparturesBroadParameters.fromJson(Map<String, dynamic> json) =>
      _$V3DeparturesBroadParametersFromJson(json);

  static const toJsonFactory = _$V3DeparturesBroadParametersToJson;
  Map<String, dynamic> toJson() => _$V3DeparturesBroadParametersToJson(this);

  @JsonKey(name: 'platform_numbers', defaultValue: <int>[])
  final List<int>? platformNumbers;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'gtfs')
  final bool? gtfs;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'max_results')
  final int? maxResults;
  @JsonKey(name: 'include_cancelled')
  final bool? includeCancelled;
  @JsonKey(name: 'look_backwards')
  final bool? lookBackwards;
  @JsonKey(name: 'expand', defaultValue: <int>[])
  final List<int>? expand;
  @JsonKey(name: 'include_geopath')
  final bool? includeGeopath;
  static const fromJsonFactory = _$V3DeparturesBroadParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DeparturesBroadParameters &&
            (identical(other.platformNumbers, platformNumbers) ||
                const DeepCollectionEquality().equals(
                  other.platformNumbers,
                  platformNumbers,
                )) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.gtfs, gtfs) ||
                const DeepCollectionEquality().equals(other.gtfs, gtfs)) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(other.maxResults, maxResults) ||
                const DeepCollectionEquality().equals(
                  other.maxResults,
                  maxResults,
                )) &&
            (identical(other.includeCancelled, includeCancelled) ||
                const DeepCollectionEquality().equals(
                  other.includeCancelled,
                  includeCancelled,
                )) &&
            (identical(other.lookBackwards, lookBackwards) ||
                const DeepCollectionEquality().equals(
                  other.lookBackwards,
                  lookBackwards,
                )) &&
            (identical(other.expand, expand) ||
                const DeepCollectionEquality().equals(other.expand, expand)) &&
            (identical(other.includeGeopath, includeGeopath) ||
                const DeepCollectionEquality().equals(
                  other.includeGeopath,
                  includeGeopath,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(platformNumbers) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(gtfs) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(maxResults) ^
      const DeepCollectionEquality().hash(includeCancelled) ^
      const DeepCollectionEquality().hash(lookBackwards) ^
      const DeepCollectionEquality().hash(expand) ^
      const DeepCollectionEquality().hash(includeGeopath) ^
      runtimeType.hashCode;
}

extension $V3DeparturesBroadParametersExtension on V3DeparturesBroadParameters {
  V3DeparturesBroadParameters copyWith({
    List<int>? platformNumbers,
    int? directionId,
    bool? gtfs,
    DateTime? dateUtc,
    int? maxResults,
    bool? includeCancelled,
    bool? lookBackwards,
    List<int>? expand,
    bool? includeGeopath,
  }) {
    return V3DeparturesBroadParameters(
      platformNumbers: platformNumbers ?? this.platformNumbers,
      directionId: directionId ?? this.directionId,
      gtfs: gtfs ?? this.gtfs,
      dateUtc: dateUtc ?? this.dateUtc,
      maxResults: maxResults ?? this.maxResults,
      includeCancelled: includeCancelled ?? this.includeCancelled,
      lookBackwards: lookBackwards ?? this.lookBackwards,
      expand: expand ?? this.expand,
      includeGeopath: includeGeopath ?? this.includeGeopath,
    );
  }

  V3DeparturesBroadParameters copyWithWrapped({
    Wrapped<List<int>?>? platformNumbers,
    Wrapped<int?>? directionId,
    Wrapped<bool?>? gtfs,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<int?>? maxResults,
    Wrapped<bool?>? includeCancelled,
    Wrapped<bool?>? lookBackwards,
    Wrapped<List<int>?>? expand,
    Wrapped<bool?>? includeGeopath,
  }) {
    return V3DeparturesBroadParameters(
      platformNumbers: (platformNumbers != null
          ? platformNumbers.value
          : this.platformNumbers),
      directionId: (directionId != null ? directionId.value : this.directionId),
      gtfs: (gtfs != null ? gtfs.value : this.gtfs),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      maxResults: (maxResults != null ? maxResults.value : this.maxResults),
      includeCancelled: (includeCancelled != null
          ? includeCancelled.value
          : this.includeCancelled),
      lookBackwards: (lookBackwards != null
          ? lookBackwards.value
          : this.lookBackwards),
      expand: (expand != null ? expand.value : this.expand),
      includeGeopath: (includeGeopath != null
          ? includeGeopath.value
          : this.includeGeopath),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DeparturesResponse {
  const V3DeparturesResponse({
    this.departures,
    this.stops,
    this.routes,
    this.runs,
    this.directions,
    this.disruptions,
    this.status,
  });

  factory V3DeparturesResponse.fromJson(Map<String, dynamic> json) =>
      _$V3DeparturesResponseFromJson(json);

  static const toJsonFactory = _$V3DeparturesResponseToJson;
  Map<String, dynamic> toJson() => _$V3DeparturesResponseToJson(this);

  @JsonKey(name: 'departures', defaultValue: <V3Departure>[])
  final List<V3Departure>? departures;
  @JsonKey(name: 'stops')
  final Map<String, dynamic>? stops;
  @JsonKey(name: 'routes')
  final Map<String, dynamic>? routes;
  @JsonKey(name: 'runs')
  final Map<String, dynamic>? runs;
  @JsonKey(name: 'directions')
  final Map<String, dynamic>? directions;
  @JsonKey(name: 'disruptions')
  final Map<String, dynamic>? disruptions;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3DeparturesResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DeparturesResponse &&
            (identical(other.departures, departures) ||
                const DeepCollectionEquality().equals(
                  other.departures,
                  departures,
                )) &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)) &&
            (identical(other.routes, routes) ||
                const DeepCollectionEquality().equals(other.routes, routes)) &&
            (identical(other.runs, runs) ||
                const DeepCollectionEquality().equals(other.runs, runs)) &&
            (identical(other.directions, directions) ||
                const DeepCollectionEquality().equals(
                  other.directions,
                  directions,
                )) &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(departures) ^
      const DeepCollectionEquality().hash(stops) ^
      const DeepCollectionEquality().hash(routes) ^
      const DeepCollectionEquality().hash(runs) ^
      const DeepCollectionEquality().hash(directions) ^
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3DeparturesResponseExtension on V3DeparturesResponse {
  V3DeparturesResponse copyWith({
    List<V3Departure>? departures,
    Map<String, dynamic>? stops,
    Map<String, dynamic>? routes,
    Map<String, dynamic>? runs,
    Map<String, dynamic>? directions,
    Map<String, dynamic>? disruptions,
    V3Status? status,
  }) {
    return V3DeparturesResponse(
      departures: departures ?? this.departures,
      stops: stops ?? this.stops,
      routes: routes ?? this.routes,
      runs: runs ?? this.runs,
      directions: directions ?? this.directions,
      disruptions: disruptions ?? this.disruptions,
      status: status ?? this.status,
    );
  }

  V3DeparturesResponse copyWithWrapped({
    Wrapped<List<V3Departure>?>? departures,
    Wrapped<Map<String, dynamic>?>? stops,
    Wrapped<Map<String, dynamic>?>? routes,
    Wrapped<Map<String, dynamic>?>? runs,
    Wrapped<Map<String, dynamic>?>? directions,
    Wrapped<Map<String, dynamic>?>? disruptions,
    Wrapped<V3Status?>? status,
  }) {
    return V3DeparturesResponse(
      departures: (departures != null ? departures.value : this.departures),
      stops: (stops != null ? stops.value : this.stops),
      routes: (routes != null ? routes.value : this.routes),
      runs: (runs != null ? runs.value : this.runs),
      directions: (directions != null ? directions.value : this.directions),
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Departure {
  const V3Departure({
    this.stopId,
    this.routeId,
    this.runId,
    this.runRef,
    this.directionId,
    this.disruptionIds,
    this.scheduledDepartureUtc,
    this.estimatedDepartureUtc,
    this.atPlatform,
    this.platformNumber,
    this.flags,
    this.departureSequence,
    this.departureNote,
  });

  factory V3Departure.fromJson(Map<String, dynamic> json) =>
      _$V3DepartureFromJson(json);

  static const toJsonFactory = _$V3DepartureToJson;
  Map<String, dynamic> toJson() => _$V3DepartureToJson(this);

  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'run_id')
  final int? runId;
  @JsonKey(name: 'run_ref')
  final String? runRef;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'disruption_ids', defaultValue: <int>[])
  final List<int>? disruptionIds;
  @JsonKey(name: 'scheduled_departure_utc')
  final DateTime? scheduledDepartureUtc;
  @JsonKey(name: 'estimated_departure_utc')
  final DateTime? estimatedDepartureUtc;
  @JsonKey(name: 'at_platform')
  final bool? atPlatform;
  @JsonKey(name: 'platform_number')
  final String? platformNumber;
  @JsonKey(name: 'flags')
  final String? flags;
  @JsonKey(name: 'departure_sequence')
  final int? departureSequence;
  @JsonKey(name: 'departure_note')
  final String? departureNote;
  static const fromJsonFactory = _$V3DepartureFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Departure &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.runId, runId) ||
                const DeepCollectionEquality().equals(other.runId, runId)) &&
            (identical(other.runRef, runRef) ||
                const DeepCollectionEquality().equals(other.runRef, runRef)) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.disruptionIds, disruptionIds) ||
                const DeepCollectionEquality().equals(
                  other.disruptionIds,
                  disruptionIds,
                )) &&
            (identical(other.scheduledDepartureUtc, scheduledDepartureUtc) ||
                const DeepCollectionEquality().equals(
                  other.scheduledDepartureUtc,
                  scheduledDepartureUtc,
                )) &&
            (identical(other.estimatedDepartureUtc, estimatedDepartureUtc) ||
                const DeepCollectionEquality().equals(
                  other.estimatedDepartureUtc,
                  estimatedDepartureUtc,
                )) &&
            (identical(other.atPlatform, atPlatform) ||
                const DeepCollectionEquality().equals(
                  other.atPlatform,
                  atPlatform,
                )) &&
            (identical(other.platformNumber, platformNumber) ||
                const DeepCollectionEquality().equals(
                  other.platformNumber,
                  platformNumber,
                )) &&
            (identical(other.flags, flags) ||
                const DeepCollectionEquality().equals(other.flags, flags)) &&
            (identical(other.departureSequence, departureSequence) ||
                const DeepCollectionEquality().equals(
                  other.departureSequence,
                  departureSequence,
                )) &&
            (identical(other.departureNote, departureNote) ||
                const DeepCollectionEquality().equals(
                  other.departureNote,
                  departureNote,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(runId) ^
      const DeepCollectionEquality().hash(runRef) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(disruptionIds) ^
      const DeepCollectionEquality().hash(scheduledDepartureUtc) ^
      const DeepCollectionEquality().hash(estimatedDepartureUtc) ^
      const DeepCollectionEquality().hash(atPlatform) ^
      const DeepCollectionEquality().hash(platformNumber) ^
      const DeepCollectionEquality().hash(flags) ^
      const DeepCollectionEquality().hash(departureSequence) ^
      const DeepCollectionEquality().hash(departureNote) ^
      runtimeType.hashCode;
}

extension $V3DepartureExtension on V3Departure {
  V3Departure copyWith({
    int? stopId,
    int? routeId,
    int? runId,
    String? runRef,
    int? directionId,
    List<int>? disruptionIds,
    DateTime? scheduledDepartureUtc,
    DateTime? estimatedDepartureUtc,
    bool? atPlatform,
    String? platformNumber,
    String? flags,
    int? departureSequence,
    String? departureNote,
  }) {
    return V3Departure(
      stopId: stopId ?? this.stopId,
      routeId: routeId ?? this.routeId,
      runId: runId ?? this.runId,
      runRef: runRef ?? this.runRef,
      directionId: directionId ?? this.directionId,
      disruptionIds: disruptionIds ?? this.disruptionIds,
      scheduledDepartureUtc:
          scheduledDepartureUtc ?? this.scheduledDepartureUtc,
      estimatedDepartureUtc:
          estimatedDepartureUtc ?? this.estimatedDepartureUtc,
      atPlatform: atPlatform ?? this.atPlatform,
      platformNumber: platformNumber ?? this.platformNumber,
      flags: flags ?? this.flags,
      departureSequence: departureSequence ?? this.departureSequence,
      departureNote: departureNote ?? this.departureNote,
    );
  }

  V3Departure copyWithWrapped({
    Wrapped<int?>? stopId,
    Wrapped<int?>? routeId,
    Wrapped<int?>? runId,
    Wrapped<String?>? runRef,
    Wrapped<int?>? directionId,
    Wrapped<List<int>?>? disruptionIds,
    Wrapped<DateTime?>? scheduledDepartureUtc,
    Wrapped<DateTime?>? estimatedDepartureUtc,
    Wrapped<bool?>? atPlatform,
    Wrapped<String?>? platformNumber,
    Wrapped<String?>? flags,
    Wrapped<int?>? departureSequence,
    Wrapped<String?>? departureNote,
  }) {
    return V3Departure(
      stopId: (stopId != null ? stopId.value : this.stopId),
      routeId: (routeId != null ? routeId.value : this.routeId),
      runId: (runId != null ? runId.value : this.runId),
      runRef: (runRef != null ? runRef.value : this.runRef),
      directionId: (directionId != null ? directionId.value : this.directionId),
      disruptionIds: (disruptionIds != null
          ? disruptionIds.value
          : this.disruptionIds),
      scheduledDepartureUtc: (scheduledDepartureUtc != null
          ? scheduledDepartureUtc.value
          : this.scheduledDepartureUtc),
      estimatedDepartureUtc: (estimatedDepartureUtc != null
          ? estimatedDepartureUtc.value
          : this.estimatedDepartureUtc),
      atPlatform: (atPlatform != null ? atPlatform.value : this.atPlatform),
      platformNumber: (platformNumber != null
          ? platformNumber.value
          : this.platformNumber),
      flags: (flags != null ? flags.value : this.flags),
      departureSequence: (departureSequence != null
          ? departureSequence.value
          : this.departureSequence),
      departureNote: (departureNote != null
          ? departureNote.value
          : this.departureNote),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopModel {
  const V3StopModel({
    this.stopDistance,
    this.stopSuburb,
    this.stopName,
    this.stopId,
    this.routeType,
    this.stopLatitude,
    this.stopLongitude,
    this.stopLandmark,
    this.stopSequence,
  });

  factory V3StopModel.fromJson(Map<String, dynamic> json) =>
      _$V3StopModelFromJson(json);

  static const toJsonFactory = _$V3StopModelToJson;
  Map<String, dynamic> toJson() => _$V3StopModelToJson(this);

  @JsonKey(name: 'stop_distance')
  final double? stopDistance;
  @JsonKey(name: 'stop_suburb')
  final String? stopSuburb;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'stop_latitude')
  final double? stopLatitude;
  @JsonKey(name: 'stop_longitude')
  final double? stopLongitude;
  @JsonKey(name: 'stop_landmark')
  final String? stopLandmark;
  @JsonKey(name: 'stop_sequence')
  final int? stopSequence;
  static const fromJsonFactory = _$V3StopModelFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopModel &&
            (identical(other.stopDistance, stopDistance) ||
                const DeepCollectionEquality().equals(
                  other.stopDistance,
                  stopDistance,
                )) &&
            (identical(other.stopSuburb, stopSuburb) ||
                const DeepCollectionEquality().equals(
                  other.stopSuburb,
                  stopSuburb,
                )) &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.stopLatitude, stopLatitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLatitude,
                  stopLatitude,
                )) &&
            (identical(other.stopLongitude, stopLongitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLongitude,
                  stopLongitude,
                )) &&
            (identical(other.stopLandmark, stopLandmark) ||
                const DeepCollectionEquality().equals(
                  other.stopLandmark,
                  stopLandmark,
                )) &&
            (identical(other.stopSequence, stopSequence) ||
                const DeepCollectionEquality().equals(
                  other.stopSequence,
                  stopSequence,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopDistance) ^
      const DeepCollectionEquality().hash(stopSuburb) ^
      const DeepCollectionEquality().hash(stopName) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(stopLatitude) ^
      const DeepCollectionEquality().hash(stopLongitude) ^
      const DeepCollectionEquality().hash(stopLandmark) ^
      const DeepCollectionEquality().hash(stopSequence) ^
      runtimeType.hashCode;
}

extension $V3StopModelExtension on V3StopModel {
  V3StopModel copyWith({
    double? stopDistance,
    String? stopSuburb,
    String? stopName,
    int? stopId,
    int? routeType,
    double? stopLatitude,
    double? stopLongitude,
    String? stopLandmark,
    int? stopSequence,
  }) {
    return V3StopModel(
      stopDistance: stopDistance ?? this.stopDistance,
      stopSuburb: stopSuburb ?? this.stopSuburb,
      stopName: stopName ?? this.stopName,
      stopId: stopId ?? this.stopId,
      routeType: routeType ?? this.routeType,
      stopLatitude: stopLatitude ?? this.stopLatitude,
      stopLongitude: stopLongitude ?? this.stopLongitude,
      stopLandmark: stopLandmark ?? this.stopLandmark,
      stopSequence: stopSequence ?? this.stopSequence,
    );
  }

  V3StopModel copyWithWrapped({
    Wrapped<double?>? stopDistance,
    Wrapped<String?>? stopSuburb,
    Wrapped<String?>? stopName,
    Wrapped<int?>? stopId,
    Wrapped<int?>? routeType,
    Wrapped<double?>? stopLatitude,
    Wrapped<double?>? stopLongitude,
    Wrapped<String?>? stopLandmark,
    Wrapped<int?>? stopSequence,
  }) {
    return V3StopModel(
      stopDistance: (stopDistance != null
          ? stopDistance.value
          : this.stopDistance),
      stopSuburb: (stopSuburb != null ? stopSuburb.value : this.stopSuburb),
      stopName: (stopName != null ? stopName.value : this.stopName),
      stopId: (stopId != null ? stopId.value : this.stopId),
      routeType: (routeType != null ? routeType.value : this.routeType),
      stopLatitude: (stopLatitude != null
          ? stopLatitude.value
          : this.stopLatitude),
      stopLongitude: (stopLongitude != null
          ? stopLongitude.value
          : this.stopLongitude),
      stopLandmark: (stopLandmark != null
          ? stopLandmark.value
          : this.stopLandmark),
      stopSequence: (stopSequence != null
          ? stopSequence.value
          : this.stopSequence),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Run {
  const V3Run({
    this.runId,
    this.runRef,
    this.routeId,
    this.routeType,
    this.finalStopId,
    this.destinationName,
    this.status,
    this.directionId,
    this.runSequence,
    this.expressStopCount,
    this.vehiclePosition,
    this.vehicleDescriptor,
    this.geopath,
    this.interchange,
    this.runNote,
    this.externalService,
  });

  factory V3Run.fromJson(Map<String, dynamic> json) => _$V3RunFromJson(json);

  static const toJsonFactory = _$V3RunToJson;
  Map<String, dynamic> toJson() => _$V3RunToJson(this);

  @JsonKey(name: 'run_id')
  final int? runId;
  @JsonKey(name: 'run_ref')
  final String? runRef;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'final_stop_id')
  final int? finalStopId;
  @JsonKey(name: 'destination_name')
  final String? destinationName;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'run_sequence')
  final int? runSequence;
  @JsonKey(name: 'express_stop_count')
  final int? expressStopCount;
  @JsonKey(name: 'vehicle_position')
  final V3VehiclePosition? vehiclePosition;
  @JsonKey(name: 'vehicle_descriptor')
  final V3VehicleDescriptor? vehicleDescriptor;
  @JsonKey(name: 'geopath', defaultValue: <Object>[])
  final List<Object>? geopath;
  @JsonKey(name: 'interchange')
  final V3Interchange? interchange;
  @JsonKey(name: 'run_note')
  final String? runNote;
  @JsonKey(name: 'externalService')
  final int? externalService;
  static const fromJsonFactory = _$V3RunFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Run &&
            (identical(other.runId, runId) ||
                const DeepCollectionEquality().equals(other.runId, runId)) &&
            (identical(other.runRef, runRef) ||
                const DeepCollectionEquality().equals(other.runRef, runRef)) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.finalStopId, finalStopId) ||
                const DeepCollectionEquality().equals(
                  other.finalStopId,
                  finalStopId,
                )) &&
            (identical(other.destinationName, destinationName) ||
                const DeepCollectionEquality().equals(
                  other.destinationName,
                  destinationName,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.runSequence, runSequence) ||
                const DeepCollectionEquality().equals(
                  other.runSequence,
                  runSequence,
                )) &&
            (identical(other.expressStopCount, expressStopCount) ||
                const DeepCollectionEquality().equals(
                  other.expressStopCount,
                  expressStopCount,
                )) &&
            (identical(other.vehiclePosition, vehiclePosition) ||
                const DeepCollectionEquality().equals(
                  other.vehiclePosition,
                  vehiclePosition,
                )) &&
            (identical(other.vehicleDescriptor, vehicleDescriptor) ||
                const DeepCollectionEquality().equals(
                  other.vehicleDescriptor,
                  vehicleDescriptor,
                )) &&
            (identical(other.geopath, geopath) ||
                const DeepCollectionEquality().equals(
                  other.geopath,
                  geopath,
                )) &&
            (identical(other.interchange, interchange) ||
                const DeepCollectionEquality().equals(
                  other.interchange,
                  interchange,
                )) &&
            (identical(other.runNote, runNote) ||
                const DeepCollectionEquality().equals(
                  other.runNote,
                  runNote,
                )) &&
            (identical(other.externalService, externalService) ||
                const DeepCollectionEquality().equals(
                  other.externalService,
                  externalService,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(runId) ^
      const DeepCollectionEquality().hash(runRef) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(finalStopId) ^
      const DeepCollectionEquality().hash(destinationName) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(runSequence) ^
      const DeepCollectionEquality().hash(expressStopCount) ^
      const DeepCollectionEquality().hash(vehiclePosition) ^
      const DeepCollectionEquality().hash(vehicleDescriptor) ^
      const DeepCollectionEquality().hash(geopath) ^
      const DeepCollectionEquality().hash(interchange) ^
      const DeepCollectionEquality().hash(runNote) ^
      const DeepCollectionEquality().hash(externalService) ^
      runtimeType.hashCode;
}

extension $V3RunExtension on V3Run {
  V3Run copyWith({
    int? runId,
    String? runRef,
    int? routeId,
    int? routeType,
    int? finalStopId,
    String? destinationName,
    String? status,
    int? directionId,
    int? runSequence,
    int? expressStopCount,
    V3VehiclePosition? vehiclePosition,
    V3VehicleDescriptor? vehicleDescriptor,
    List<Object>? geopath,
    V3Interchange? interchange,
    String? runNote,
    int? externalService,
  }) {
    return V3Run(
      runId: runId ?? this.runId,
      runRef: runRef ?? this.runRef,
      routeId: routeId ?? this.routeId,
      routeType: routeType ?? this.routeType,
      finalStopId: finalStopId ?? this.finalStopId,
      destinationName: destinationName ?? this.destinationName,
      status: status ?? this.status,
      directionId: directionId ?? this.directionId,
      runSequence: runSequence ?? this.runSequence,
      expressStopCount: expressStopCount ?? this.expressStopCount,
      vehiclePosition: vehiclePosition ?? this.vehiclePosition,
      vehicleDescriptor: vehicleDescriptor ?? this.vehicleDescriptor,
      geopath: geopath ?? this.geopath,
      interchange: interchange ?? this.interchange,
      runNote: runNote ?? this.runNote,
      externalService: externalService ?? this.externalService,
    );
  }

  V3Run copyWithWrapped({
    Wrapped<int?>? runId,
    Wrapped<String?>? runRef,
    Wrapped<int?>? routeId,
    Wrapped<int?>? routeType,
    Wrapped<int?>? finalStopId,
    Wrapped<String?>? destinationName,
    Wrapped<String?>? status,
    Wrapped<int?>? directionId,
    Wrapped<int?>? runSequence,
    Wrapped<int?>? expressStopCount,
    Wrapped<V3VehiclePosition?>? vehiclePosition,
    Wrapped<V3VehicleDescriptor?>? vehicleDescriptor,
    Wrapped<List<Object>?>? geopath,
    Wrapped<V3Interchange?>? interchange,
    Wrapped<String?>? runNote,
    Wrapped<int?>? externalService,
  }) {
    return V3Run(
      runId: (runId != null ? runId.value : this.runId),
      runRef: (runRef != null ? runRef.value : this.runRef),
      routeId: (routeId != null ? routeId.value : this.routeId),
      routeType: (routeType != null ? routeType.value : this.routeType),
      finalStopId: (finalStopId != null ? finalStopId.value : this.finalStopId),
      destinationName: (destinationName != null
          ? destinationName.value
          : this.destinationName),
      status: (status != null ? status.value : this.status),
      directionId: (directionId != null ? directionId.value : this.directionId),
      runSequence: (runSequence != null ? runSequence.value : this.runSequence),
      expressStopCount: (expressStopCount != null
          ? expressStopCount.value
          : this.expressStopCount),
      vehiclePosition: (vehiclePosition != null
          ? vehiclePosition.value
          : this.vehiclePosition),
      vehicleDescriptor: (vehicleDescriptor != null
          ? vehicleDescriptor.value
          : this.vehicleDescriptor),
      geopath: (geopath != null ? geopath.value : this.geopath),
      interchange: (interchange != null ? interchange.value : this.interchange),
      runNote: (runNote != null ? runNote.value : this.runNote),
      externalService: (externalService != null
          ? externalService.value
          : this.externalService),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Direction {
  const V3Direction({
    this.directionId,
    this.directionName,
    this.routeId,
    this.routeType,
  });

  factory V3Direction.fromJson(Map<String, dynamic> json) =>
      _$V3DirectionFromJson(json);

  static const toJsonFactory = _$V3DirectionToJson;
  Map<String, dynamic> toJson() => _$V3DirectionToJson(this);

  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'direction_name')
  final String? directionName;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'route_type')
  final int? routeType;
  static const fromJsonFactory = _$V3DirectionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Direction &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.directionName, directionName) ||
                const DeepCollectionEquality().equals(
                  other.directionName,
                  directionName,
                )) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(directionName) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(routeType) ^
      runtimeType.hashCode;
}

extension $V3DirectionExtension on V3Direction {
  V3Direction copyWith({
    int? directionId,
    String? directionName,
    int? routeId,
    int? routeType,
  }) {
    return V3Direction(
      directionId: directionId ?? this.directionId,
      directionName: directionName ?? this.directionName,
      routeId: routeId ?? this.routeId,
      routeType: routeType ?? this.routeType,
    );
  }

  V3Direction copyWithWrapped({
    Wrapped<int?>? directionId,
    Wrapped<String?>? directionName,
    Wrapped<int?>? routeId,
    Wrapped<int?>? routeType,
  }) {
    return V3Direction(
      directionId: (directionId != null ? directionId.value : this.directionId),
      directionName: (directionName != null
          ? directionName.value
          : this.directionName),
      routeId: (routeId != null ? routeId.value : this.routeId),
      routeType: (routeType != null ? routeType.value : this.routeType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Disruption {
  const V3Disruption({
    this.disruptionId,
    this.title,
    this.url,
    this.description,
    this.disruptionStatus,
    this.disruptionType,
    this.publishedOn,
    this.lastUpdated,
    this.fromDate,
    this.toDate,
    this.routes,
    this.stops,
    this.colour,
    this.displayOnBoard,
    this.displayStatus,
  });

  factory V3Disruption.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionFromJson(json);

  static const toJsonFactory = _$V3DisruptionToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionToJson(this);

  @JsonKey(name: 'disruption_id')
  final int? disruptionId;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'url')
  final String? url;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'disruption_status')
  final String? disruptionStatus;
  @JsonKey(name: 'disruption_type')
  final String? disruptionType;
  @JsonKey(name: 'published_on')
  final DateTime? publishedOn;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  @JsonKey(name: 'from_date')
  final DateTime? fromDate;
  @JsonKey(name: 'to_date')
  final DateTime? toDate;
  @JsonKey(name: 'routes', defaultValue: <V3DisruptionRoute>[])
  final List<V3DisruptionRoute>? routes;
  @JsonKey(name: 'stops', defaultValue: <V3DisruptionStop>[])
  final List<V3DisruptionStop>? stops;
  @JsonKey(name: 'colour')
  final String? colour;
  @JsonKey(name: 'display_on_board')
  final bool? displayOnBoard;
  @JsonKey(name: 'display_status')
  final bool? displayStatus;
  static const fromJsonFactory = _$V3DisruptionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Disruption &&
            (identical(other.disruptionId, disruptionId) ||
                const DeepCollectionEquality().equals(
                  other.disruptionId,
                  disruptionId,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.url, url) ||
                const DeepCollectionEquality().equals(other.url, url)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.disruptionStatus, disruptionStatus) ||
                const DeepCollectionEquality().equals(
                  other.disruptionStatus,
                  disruptionStatus,
                )) &&
            (identical(other.disruptionType, disruptionType) ||
                const DeepCollectionEquality().equals(
                  other.disruptionType,
                  disruptionType,
                )) &&
            (identical(other.publishedOn, publishedOn) ||
                const DeepCollectionEquality().equals(
                  other.publishedOn,
                  publishedOn,
                )) &&
            (identical(other.lastUpdated, lastUpdated) ||
                const DeepCollectionEquality().equals(
                  other.lastUpdated,
                  lastUpdated,
                )) &&
            (identical(other.fromDate, fromDate) ||
                const DeepCollectionEquality().equals(
                  other.fromDate,
                  fromDate,
                )) &&
            (identical(other.toDate, toDate) ||
                const DeepCollectionEquality().equals(other.toDate, toDate)) &&
            (identical(other.routes, routes) ||
                const DeepCollectionEquality().equals(other.routes, routes)) &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)) &&
            (identical(other.colour, colour) ||
                const DeepCollectionEquality().equals(other.colour, colour)) &&
            (identical(other.displayOnBoard, displayOnBoard) ||
                const DeepCollectionEquality().equals(
                  other.displayOnBoard,
                  displayOnBoard,
                )) &&
            (identical(other.displayStatus, displayStatus) ||
                const DeepCollectionEquality().equals(
                  other.displayStatus,
                  displayStatus,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptionId) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(url) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(disruptionStatus) ^
      const DeepCollectionEquality().hash(disruptionType) ^
      const DeepCollectionEquality().hash(publishedOn) ^
      const DeepCollectionEquality().hash(lastUpdated) ^
      const DeepCollectionEquality().hash(fromDate) ^
      const DeepCollectionEquality().hash(toDate) ^
      const DeepCollectionEquality().hash(routes) ^
      const DeepCollectionEquality().hash(stops) ^
      const DeepCollectionEquality().hash(colour) ^
      const DeepCollectionEquality().hash(displayOnBoard) ^
      const DeepCollectionEquality().hash(displayStatus) ^
      runtimeType.hashCode;
}

extension $V3DisruptionExtension on V3Disruption {
  V3Disruption copyWith({
    int? disruptionId,
    String? title,
    String? url,
    String? description,
    String? disruptionStatus,
    String? disruptionType,
    DateTime? publishedOn,
    DateTime? lastUpdated,
    DateTime? fromDate,
    DateTime? toDate,
    List<V3DisruptionRoute>? routes,
    List<V3DisruptionStop>? stops,
    String? colour,
    bool? displayOnBoard,
    bool? displayStatus,
  }) {
    return V3Disruption(
      disruptionId: disruptionId ?? this.disruptionId,
      title: title ?? this.title,
      url: url ?? this.url,
      description: description ?? this.description,
      disruptionStatus: disruptionStatus ?? this.disruptionStatus,
      disruptionType: disruptionType ?? this.disruptionType,
      publishedOn: publishedOn ?? this.publishedOn,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      routes: routes ?? this.routes,
      stops: stops ?? this.stops,
      colour: colour ?? this.colour,
      displayOnBoard: displayOnBoard ?? this.displayOnBoard,
      displayStatus: displayStatus ?? this.displayStatus,
    );
  }

  V3Disruption copyWithWrapped({
    Wrapped<int?>? disruptionId,
    Wrapped<String?>? title,
    Wrapped<String?>? url,
    Wrapped<String?>? description,
    Wrapped<String?>? disruptionStatus,
    Wrapped<String?>? disruptionType,
    Wrapped<DateTime?>? publishedOn,
    Wrapped<DateTime?>? lastUpdated,
    Wrapped<DateTime?>? fromDate,
    Wrapped<DateTime?>? toDate,
    Wrapped<List<V3DisruptionRoute>?>? routes,
    Wrapped<List<V3DisruptionStop>?>? stops,
    Wrapped<String?>? colour,
    Wrapped<bool?>? displayOnBoard,
    Wrapped<bool?>? displayStatus,
  }) {
    return V3Disruption(
      disruptionId: (disruptionId != null
          ? disruptionId.value
          : this.disruptionId),
      title: (title != null ? title.value : this.title),
      url: (url != null ? url.value : this.url),
      description: (description != null ? description.value : this.description),
      disruptionStatus: (disruptionStatus != null
          ? disruptionStatus.value
          : this.disruptionStatus),
      disruptionType: (disruptionType != null
          ? disruptionType.value
          : this.disruptionType),
      publishedOn: (publishedOn != null ? publishedOn.value : this.publishedOn),
      lastUpdated: (lastUpdated != null ? lastUpdated.value : this.lastUpdated),
      fromDate: (fromDate != null ? fromDate.value : this.fromDate),
      toDate: (toDate != null ? toDate.value : this.toDate),
      routes: (routes != null ? routes.value : this.routes),
      stops: (stops != null ? stops.value : this.stops),
      colour: (colour != null ? colour.value : this.colour),
      displayOnBoard: (displayOnBoard != null
          ? displayOnBoard.value
          : this.displayOnBoard),
      displayStatus: (displayStatus != null
          ? displayStatus.value
          : this.displayStatus),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3VehiclePosition {
  const V3VehiclePosition({
    this.latitude,
    this.longitude,
    this.easting,
    this.northing,
    this.direction,
    this.bearing,
    this.supplier,
    this.datetimeUtc,
    this.expiryTime,
  });

  factory V3VehiclePosition.fromJson(Map<String, dynamic> json) =>
      _$V3VehiclePositionFromJson(json);

  static const toJsonFactory = _$V3VehiclePositionToJson;
  Map<String, dynamic> toJson() => _$V3VehiclePositionToJson(this);

  @JsonKey(name: 'latitude')
  final double? latitude;
  @JsonKey(name: 'longitude')
  final double? longitude;
  @JsonKey(name: 'easting')
  final double? easting;
  @JsonKey(name: 'northing')
  final double? northing;
  @JsonKey(name: 'direction')
  final String? direction;
  @JsonKey(name: 'bearing')
  final double? bearing;
  @JsonKey(name: 'supplier')
  final String? supplier;
  @JsonKey(name: 'datetime_utc')
  final DateTime? datetimeUtc;
  @JsonKey(name: 'expiry_time')
  final DateTime? expiryTime;
  static const fromJsonFactory = _$V3VehiclePositionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3VehiclePosition &&
            (identical(other.latitude, latitude) ||
                const DeepCollectionEquality().equals(
                  other.latitude,
                  latitude,
                )) &&
            (identical(other.longitude, longitude) ||
                const DeepCollectionEquality().equals(
                  other.longitude,
                  longitude,
                )) &&
            (identical(other.easting, easting) ||
                const DeepCollectionEquality().equals(
                  other.easting,
                  easting,
                )) &&
            (identical(other.northing, northing) ||
                const DeepCollectionEquality().equals(
                  other.northing,
                  northing,
                )) &&
            (identical(other.direction, direction) ||
                const DeepCollectionEquality().equals(
                  other.direction,
                  direction,
                )) &&
            (identical(other.bearing, bearing) ||
                const DeepCollectionEquality().equals(
                  other.bearing,
                  bearing,
                )) &&
            (identical(other.supplier, supplier) ||
                const DeepCollectionEquality().equals(
                  other.supplier,
                  supplier,
                )) &&
            (identical(other.datetimeUtc, datetimeUtc) ||
                const DeepCollectionEquality().equals(
                  other.datetimeUtc,
                  datetimeUtc,
                )) &&
            (identical(other.expiryTime, expiryTime) ||
                const DeepCollectionEquality().equals(
                  other.expiryTime,
                  expiryTime,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(latitude) ^
      const DeepCollectionEquality().hash(longitude) ^
      const DeepCollectionEquality().hash(easting) ^
      const DeepCollectionEquality().hash(northing) ^
      const DeepCollectionEquality().hash(direction) ^
      const DeepCollectionEquality().hash(bearing) ^
      const DeepCollectionEquality().hash(supplier) ^
      const DeepCollectionEquality().hash(datetimeUtc) ^
      const DeepCollectionEquality().hash(expiryTime) ^
      runtimeType.hashCode;
}

extension $V3VehiclePositionExtension on V3VehiclePosition {
  V3VehiclePosition copyWith({
    double? latitude,
    double? longitude,
    double? easting,
    double? northing,
    String? direction,
    double? bearing,
    String? supplier,
    DateTime? datetimeUtc,
    DateTime? expiryTime,
  }) {
    return V3VehiclePosition(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      easting: easting ?? this.easting,
      northing: northing ?? this.northing,
      direction: direction ?? this.direction,
      bearing: bearing ?? this.bearing,
      supplier: supplier ?? this.supplier,
      datetimeUtc: datetimeUtc ?? this.datetimeUtc,
      expiryTime: expiryTime ?? this.expiryTime,
    );
  }

  V3VehiclePosition copyWithWrapped({
    Wrapped<double?>? latitude,
    Wrapped<double?>? longitude,
    Wrapped<double?>? easting,
    Wrapped<double?>? northing,
    Wrapped<String?>? direction,
    Wrapped<double?>? bearing,
    Wrapped<String?>? supplier,
    Wrapped<DateTime?>? datetimeUtc,
    Wrapped<DateTime?>? expiryTime,
  }) {
    return V3VehiclePosition(
      latitude: (latitude != null ? latitude.value : this.latitude),
      longitude: (longitude != null ? longitude.value : this.longitude),
      easting: (easting != null ? easting.value : this.easting),
      northing: (northing != null ? northing.value : this.northing),
      direction: (direction != null ? direction.value : this.direction),
      bearing: (bearing != null ? bearing.value : this.bearing),
      supplier: (supplier != null ? supplier.value : this.supplier),
      datetimeUtc: (datetimeUtc != null ? datetimeUtc.value : this.datetimeUtc),
      expiryTime: (expiryTime != null ? expiryTime.value : this.expiryTime),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3VehicleDescriptor {
  const V3VehicleDescriptor({
    this.$operator,
    this.id,
    this.lowFloor,
    this.airConditioned,
    this.description,
    this.supplier,
    this.length,
  });

  factory V3VehicleDescriptor.fromJson(Map<String, dynamic> json) =>
      _$V3VehicleDescriptorFromJson(json);

  static const toJsonFactory = _$V3VehicleDescriptorToJson;
  Map<String, dynamic> toJson() => _$V3VehicleDescriptorToJson(this);

  @JsonKey(name: 'operator')
  final String? $operator;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'low_floor')
  final bool? lowFloor;
  @JsonKey(name: 'air_conditioned')
  final bool? airConditioned;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'supplier')
  final String? supplier;
  @JsonKey(name: 'length')
  final String? length;
  static const fromJsonFactory = _$V3VehicleDescriptorFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3VehicleDescriptor &&
            (identical(other.$operator, $operator) ||
                const DeepCollectionEquality().equals(
                  other.$operator,
                  $operator,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.lowFloor, lowFloor) ||
                const DeepCollectionEquality().equals(
                  other.lowFloor,
                  lowFloor,
                )) &&
            (identical(other.airConditioned, airConditioned) ||
                const DeepCollectionEquality().equals(
                  other.airConditioned,
                  airConditioned,
                )) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.supplier, supplier) ||
                const DeepCollectionEquality().equals(
                  other.supplier,
                  supplier,
                )) &&
            (identical(other.length, length) ||
                const DeepCollectionEquality().equals(other.length, length)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($operator) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(lowFloor) ^
      const DeepCollectionEquality().hash(airConditioned) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(supplier) ^
      const DeepCollectionEquality().hash(length) ^
      runtimeType.hashCode;
}

extension $V3VehicleDescriptorExtension on V3VehicleDescriptor {
  V3VehicleDescriptor copyWith({
    String? $operator,
    String? id,
    bool? lowFloor,
    bool? airConditioned,
    String? description,
    String? supplier,
    String? length,
  }) {
    return V3VehicleDescriptor(
      $operator: $operator ?? this.$operator,
      id: id ?? this.id,
      lowFloor: lowFloor ?? this.lowFloor,
      airConditioned: airConditioned ?? this.airConditioned,
      description: description ?? this.description,
      supplier: supplier ?? this.supplier,
      length: length ?? this.length,
    );
  }

  V3VehicleDescriptor copyWithWrapped({
    Wrapped<String?>? $operator,
    Wrapped<String?>? id,
    Wrapped<bool?>? lowFloor,
    Wrapped<bool?>? airConditioned,
    Wrapped<String?>? description,
    Wrapped<String?>? supplier,
    Wrapped<String?>? length,
  }) {
    return V3VehicleDescriptor(
      $operator: ($operator != null ? $operator.value : this.$operator),
      id: (id != null ? id.value : this.id),
      lowFloor: (lowFloor != null ? lowFloor.value : this.lowFloor),
      airConditioned: (airConditioned != null
          ? airConditioned.value
          : this.airConditioned),
      description: (description != null ? description.value : this.description),
      supplier: (supplier != null ? supplier.value : this.supplier),
      length: (length != null ? length.value : this.length),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Interchange {
  const V3Interchange({this.feeder, this.distributor});

  factory V3Interchange.fromJson(Map<String, dynamic> json) =>
      _$V3InterchangeFromJson(json);

  static const toJsonFactory = _$V3InterchangeToJson;
  Map<String, dynamic> toJson() => _$V3InterchangeToJson(this);

  @JsonKey(name: 'feeder')
  final V3InterchangeRun? feeder;
  @JsonKey(name: 'distributor')
  final V3InterchangeRun? distributor;
  static const fromJsonFactory = _$V3InterchangeFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Interchange &&
            (identical(other.feeder, feeder) ||
                const DeepCollectionEquality().equals(other.feeder, feeder)) &&
            (identical(other.distributor, distributor) ||
                const DeepCollectionEquality().equals(
                  other.distributor,
                  distributor,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(feeder) ^
      const DeepCollectionEquality().hash(distributor) ^
      runtimeType.hashCode;
}

extension $V3InterchangeExtension on V3Interchange {
  V3Interchange copyWith({
    V3InterchangeRun? feeder,
    V3InterchangeRun? distributor,
  }) {
    return V3Interchange(
      feeder: feeder ?? this.feeder,
      distributor: distributor ?? this.distributor,
    );
  }

  V3Interchange copyWithWrapped({
    Wrapped<V3InterchangeRun?>? feeder,
    Wrapped<V3InterchangeRun?>? distributor,
  }) {
    return V3Interchange(
      feeder: (feeder != null ? feeder.value : this.feeder),
      distributor: (distributor != null ? distributor.value : this.distributor),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DisruptionRoute {
  const V3DisruptionRoute({
    this.routeType,
    this.routeId,
    this.routeName,
    this.routeNumber,
    this.routeGtfsId,
    this.direction,
  });

  factory V3DisruptionRoute.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionRouteFromJson(json);

  static const toJsonFactory = _$V3DisruptionRouteToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionRouteToJson(this);

  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'route_name')
  final String? routeName;
  @JsonKey(name: 'route_number')
  final String? routeNumber;
  @JsonKey(name: 'route_gtfs_id')
  final String? routeGtfsId;
  @JsonKey(name: 'direction')
  final V3DisruptionDirection? direction;
  static const fromJsonFactory = _$V3DisruptionRouteFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DisruptionRoute &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.routeName, routeName) ||
                const DeepCollectionEquality().equals(
                  other.routeName,
                  routeName,
                )) &&
            (identical(other.routeNumber, routeNumber) ||
                const DeepCollectionEquality().equals(
                  other.routeNumber,
                  routeNumber,
                )) &&
            (identical(other.routeGtfsId, routeGtfsId) ||
                const DeepCollectionEquality().equals(
                  other.routeGtfsId,
                  routeGtfsId,
                )) &&
            (identical(other.direction, direction) ||
                const DeepCollectionEquality().equals(
                  other.direction,
                  direction,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(routeName) ^
      const DeepCollectionEquality().hash(routeNumber) ^
      const DeepCollectionEquality().hash(routeGtfsId) ^
      const DeepCollectionEquality().hash(direction) ^
      runtimeType.hashCode;
}

extension $V3DisruptionRouteExtension on V3DisruptionRoute {
  V3DisruptionRoute copyWith({
    int? routeType,
    int? routeId,
    String? routeName,
    String? routeNumber,
    String? routeGtfsId,
    V3DisruptionDirection? direction,
  }) {
    return V3DisruptionRoute(
      routeType: routeType ?? this.routeType,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      routeNumber: routeNumber ?? this.routeNumber,
      routeGtfsId: routeGtfsId ?? this.routeGtfsId,
      direction: direction ?? this.direction,
    );
  }

  V3DisruptionRoute copyWithWrapped({
    Wrapped<int?>? routeType,
    Wrapped<int?>? routeId,
    Wrapped<String?>? routeName,
    Wrapped<String?>? routeNumber,
    Wrapped<String?>? routeGtfsId,
    Wrapped<V3DisruptionDirection?>? direction,
  }) {
    return V3DisruptionRoute(
      routeType: (routeType != null ? routeType.value : this.routeType),
      routeId: (routeId != null ? routeId.value : this.routeId),
      routeName: (routeName != null ? routeName.value : this.routeName),
      routeNumber: (routeNumber != null ? routeNumber.value : this.routeNumber),
      routeGtfsId: (routeGtfsId != null ? routeGtfsId.value : this.routeGtfsId),
      direction: (direction != null ? direction.value : this.direction),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DisruptionStop {
  const V3DisruptionStop({this.stopId, this.stopName});

  factory V3DisruptionStop.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionStopFromJson(json);

  static const toJsonFactory = _$V3DisruptionStopToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionStopToJson(this);

  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  static const fromJsonFactory = _$V3DisruptionStopFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DisruptionStop &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(stopName) ^
      runtimeType.hashCode;
}

extension $V3DisruptionStopExtension on V3DisruptionStop {
  V3DisruptionStop copyWith({int? stopId, String? stopName}) {
    return V3DisruptionStop(
      stopId: stopId ?? this.stopId,
      stopName: stopName ?? this.stopName,
    );
  }

  V3DisruptionStop copyWithWrapped({
    Wrapped<int?>? stopId,
    Wrapped<String?>? stopName,
  }) {
    return V3DisruptionStop(
      stopId: (stopId != null ? stopId.value : this.stopId),
      stopName: (stopName != null ? stopName.value : this.stopName),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3InterchangeRun {
  const V3InterchangeRun({
    this.runRef,
    this.routeId,
    this.stopId,
    this.advertised,
    this.directionId,
    this.destinationName,
  });

  factory V3InterchangeRun.fromJson(Map<String, dynamic> json) =>
      _$V3InterchangeRunFromJson(json);

  static const toJsonFactory = _$V3InterchangeRunToJson;
  Map<String, dynamic> toJson() => _$V3InterchangeRunToJson(this);

  @JsonKey(name: 'run_ref')
  final String? runRef;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'advertised')
  final bool? advertised;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'destination_name')
  final String? destinationName;
  static const fromJsonFactory = _$V3InterchangeRunFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3InterchangeRun &&
            (identical(other.runRef, runRef) ||
                const DeepCollectionEquality().equals(other.runRef, runRef)) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.advertised, advertised) ||
                const DeepCollectionEquality().equals(
                  other.advertised,
                  advertised,
                )) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.destinationName, destinationName) ||
                const DeepCollectionEquality().equals(
                  other.destinationName,
                  destinationName,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(runRef) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(advertised) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(destinationName) ^
      runtimeType.hashCode;
}

extension $V3InterchangeRunExtension on V3InterchangeRun {
  V3InterchangeRun copyWith({
    String? runRef,
    int? routeId,
    int? stopId,
    bool? advertised,
    int? directionId,
    String? destinationName,
  }) {
    return V3InterchangeRun(
      runRef: runRef ?? this.runRef,
      routeId: routeId ?? this.routeId,
      stopId: stopId ?? this.stopId,
      advertised: advertised ?? this.advertised,
      directionId: directionId ?? this.directionId,
      destinationName: destinationName ?? this.destinationName,
    );
  }

  V3InterchangeRun copyWithWrapped({
    Wrapped<String?>? runRef,
    Wrapped<int?>? routeId,
    Wrapped<int?>? stopId,
    Wrapped<bool?>? advertised,
    Wrapped<int?>? directionId,
    Wrapped<String?>? destinationName,
  }) {
    return V3InterchangeRun(
      runRef: (runRef != null ? runRef.value : this.runRef),
      routeId: (routeId != null ? routeId.value : this.routeId),
      stopId: (stopId != null ? stopId.value : this.stopId),
      advertised: (advertised != null ? advertised.value : this.advertised),
      directionId: (directionId != null ? directionId.value : this.directionId),
      destinationName: (destinationName != null
          ? destinationName.value
          : this.destinationName),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DisruptionDirection {
  const V3DisruptionDirection({
    this.routeDirectionId,
    this.directionId,
    this.directionName,
    this.serviceTime,
  });

  factory V3DisruptionDirection.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionDirectionFromJson(json);

  static const toJsonFactory = _$V3DisruptionDirectionToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionDirectionToJson(this);

  @JsonKey(name: 'route_direction_id')
  final int? routeDirectionId;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'direction_name')
  final String? directionName;
  @JsonKey(name: 'service_time')
  final String? serviceTime;
  static const fromJsonFactory = _$V3DisruptionDirectionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DisruptionDirection &&
            (identical(other.routeDirectionId, routeDirectionId) ||
                const DeepCollectionEquality().equals(
                  other.routeDirectionId,
                  routeDirectionId,
                )) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.directionName, directionName) ||
                const DeepCollectionEquality().equals(
                  other.directionName,
                  directionName,
                )) &&
            (identical(other.serviceTime, serviceTime) ||
                const DeepCollectionEquality().equals(
                  other.serviceTime,
                  serviceTime,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeDirectionId) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(directionName) ^
      const DeepCollectionEquality().hash(serviceTime) ^
      runtimeType.hashCode;
}

extension $V3DisruptionDirectionExtension on V3DisruptionDirection {
  V3DisruptionDirection copyWith({
    int? routeDirectionId,
    int? directionId,
    String? directionName,
    String? serviceTime,
  }) {
    return V3DisruptionDirection(
      routeDirectionId: routeDirectionId ?? this.routeDirectionId,
      directionId: directionId ?? this.directionId,
      directionName: directionName ?? this.directionName,
      serviceTime: serviceTime ?? this.serviceTime,
    );
  }

  V3DisruptionDirection copyWithWrapped({
    Wrapped<int?>? routeDirectionId,
    Wrapped<int?>? directionId,
    Wrapped<String?>? directionName,
    Wrapped<String?>? serviceTime,
  }) {
    return V3DisruptionDirection(
      routeDirectionId: (routeDirectionId != null
          ? routeDirectionId.value
          : this.routeDirectionId),
      directionId: (directionId != null ? directionId.value : this.directionId),
      directionName: (directionName != null
          ? directionName.value
          : this.directionName),
      serviceTime: (serviceTime != null ? serviceTime.value : this.serviceTime),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DeparturesSpecificParameters {
  const V3DeparturesSpecificParameters({
    this.directionId,
    this.gtfs,
    this.dateUtc,
    this.maxResults,
    this.includeCancelled,
    this.lookBackwards,
    this.expand,
    this.includeGeopath,
  });

  factory V3DeparturesSpecificParameters.fromJson(Map<String, dynamic> json) =>
      _$V3DeparturesSpecificParametersFromJson(json);

  static const toJsonFactory = _$V3DeparturesSpecificParametersToJson;
  Map<String, dynamic> toJson() => _$V3DeparturesSpecificParametersToJson(this);

  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'gtfs')
  final bool? gtfs;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'max_results')
  final int? maxResults;
  @JsonKey(name: 'include_cancelled')
  final bool? includeCancelled;
  @JsonKey(name: 'look_backwards')
  final bool? lookBackwards;
  @JsonKey(name: 'expand', defaultValue: <int>[])
  final List<int>? expand;
  @JsonKey(name: 'include_geopath')
  final bool? includeGeopath;
  static const fromJsonFactory = _$V3DeparturesSpecificParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DeparturesSpecificParameters &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.gtfs, gtfs) ||
                const DeepCollectionEquality().equals(other.gtfs, gtfs)) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(other.maxResults, maxResults) ||
                const DeepCollectionEquality().equals(
                  other.maxResults,
                  maxResults,
                )) &&
            (identical(other.includeCancelled, includeCancelled) ||
                const DeepCollectionEquality().equals(
                  other.includeCancelled,
                  includeCancelled,
                )) &&
            (identical(other.lookBackwards, lookBackwards) ||
                const DeepCollectionEquality().equals(
                  other.lookBackwards,
                  lookBackwards,
                )) &&
            (identical(other.expand, expand) ||
                const DeepCollectionEquality().equals(other.expand, expand)) &&
            (identical(other.includeGeopath, includeGeopath) ||
                const DeepCollectionEquality().equals(
                  other.includeGeopath,
                  includeGeopath,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(gtfs) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(maxResults) ^
      const DeepCollectionEquality().hash(includeCancelled) ^
      const DeepCollectionEquality().hash(lookBackwards) ^
      const DeepCollectionEquality().hash(expand) ^
      const DeepCollectionEquality().hash(includeGeopath) ^
      runtimeType.hashCode;
}

extension $V3DeparturesSpecificParametersExtension
    on V3DeparturesSpecificParameters {
  V3DeparturesSpecificParameters copyWith({
    int? directionId,
    bool? gtfs,
    DateTime? dateUtc,
    int? maxResults,
    bool? includeCancelled,
    bool? lookBackwards,
    List<int>? expand,
    bool? includeGeopath,
  }) {
    return V3DeparturesSpecificParameters(
      directionId: directionId ?? this.directionId,
      gtfs: gtfs ?? this.gtfs,
      dateUtc: dateUtc ?? this.dateUtc,
      maxResults: maxResults ?? this.maxResults,
      includeCancelled: includeCancelled ?? this.includeCancelled,
      lookBackwards: lookBackwards ?? this.lookBackwards,
      expand: expand ?? this.expand,
      includeGeopath: includeGeopath ?? this.includeGeopath,
    );
  }

  V3DeparturesSpecificParameters copyWithWrapped({
    Wrapped<int?>? directionId,
    Wrapped<bool?>? gtfs,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<int?>? maxResults,
    Wrapped<bool?>? includeCancelled,
    Wrapped<bool?>? lookBackwards,
    Wrapped<List<int>?>? expand,
    Wrapped<bool?>? includeGeopath,
  }) {
    return V3DeparturesSpecificParameters(
      directionId: (directionId != null ? directionId.value : this.directionId),
      gtfs: (gtfs != null ? gtfs.value : this.gtfs),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      maxResults: (maxResults != null ? maxResults.value : this.maxResults),
      includeCancelled: (includeCancelled != null
          ? includeCancelled.value
          : this.includeCancelled),
      lookBackwards: (lookBackwards != null
          ? lookBackwards.value
          : this.lookBackwards),
      expand: (expand != null ? expand.value : this.expand),
      includeGeopath: (includeGeopath != null
          ? includeGeopath.value
          : this.includeGeopath),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RouteDeparturesSpecificParameters {
  const V3RouteDeparturesSpecificParameters({
    this.trainScheduledTimetables,
    this.scheduledTimetables,
    this.includeAdvertisedInterchange,
    this.dateUtc,
    this.maxResults,
    this.includeCancelled,
    this.lookBackwards,
    this.expand,
    this.includeGeopath,
  });

  factory V3RouteDeparturesSpecificParameters.fromJson(
    Map<String, dynamic> json,
  ) => _$V3RouteDeparturesSpecificParametersFromJson(json);

  static const toJsonFactory = _$V3RouteDeparturesSpecificParametersToJson;
  Map<String, dynamic> toJson() =>
      _$V3RouteDeparturesSpecificParametersToJson(this);

  @JsonKey(name: 'train_scheduled_timetables')
  final bool? trainScheduledTimetables;
  @JsonKey(name: 'scheduled_timetables')
  final bool? scheduledTimetables;
  @JsonKey(name: 'include_advertised_interchange')
  final bool? includeAdvertisedInterchange;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'max_results')
  final int? maxResults;
  @JsonKey(name: 'include_cancelled')
  final bool? includeCancelled;
  @JsonKey(name: 'look_backwards')
  final bool? lookBackwards;
  @JsonKey(name: 'expand', defaultValue: <int>[])
  final List<int>? expand;
  @JsonKey(name: 'include_geopath')
  final bool? includeGeopath;
  static const fromJsonFactory = _$V3RouteDeparturesSpecificParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RouteDeparturesSpecificParameters &&
            (identical(
                  other.trainScheduledTimetables,
                  trainScheduledTimetables,
                ) ||
                const DeepCollectionEquality().equals(
                  other.trainScheduledTimetables,
                  trainScheduledTimetables,
                )) &&
            (identical(other.scheduledTimetables, scheduledTimetables) ||
                const DeepCollectionEquality().equals(
                  other.scheduledTimetables,
                  scheduledTimetables,
                )) &&
            (identical(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                ) ||
                const DeepCollectionEquality().equals(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                )) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(other.maxResults, maxResults) ||
                const DeepCollectionEquality().equals(
                  other.maxResults,
                  maxResults,
                )) &&
            (identical(other.includeCancelled, includeCancelled) ||
                const DeepCollectionEquality().equals(
                  other.includeCancelled,
                  includeCancelled,
                )) &&
            (identical(other.lookBackwards, lookBackwards) ||
                const DeepCollectionEquality().equals(
                  other.lookBackwards,
                  lookBackwards,
                )) &&
            (identical(other.expand, expand) ||
                const DeepCollectionEquality().equals(other.expand, expand)) &&
            (identical(other.includeGeopath, includeGeopath) ||
                const DeepCollectionEquality().equals(
                  other.includeGeopath,
                  includeGeopath,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(trainScheduledTimetables) ^
      const DeepCollectionEquality().hash(scheduledTimetables) ^
      const DeepCollectionEquality().hash(includeAdvertisedInterchange) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(maxResults) ^
      const DeepCollectionEquality().hash(includeCancelled) ^
      const DeepCollectionEquality().hash(lookBackwards) ^
      const DeepCollectionEquality().hash(expand) ^
      const DeepCollectionEquality().hash(includeGeopath) ^
      runtimeType.hashCode;
}

extension $V3RouteDeparturesSpecificParametersExtension
    on V3RouteDeparturesSpecificParameters {
  V3RouteDeparturesSpecificParameters copyWith({
    bool? trainScheduledTimetables,
    bool? scheduledTimetables,
    bool? includeAdvertisedInterchange,
    DateTime? dateUtc,
    int? maxResults,
    bool? includeCancelled,
    bool? lookBackwards,
    List<int>? expand,
    bool? includeGeopath,
  }) {
    return V3RouteDeparturesSpecificParameters(
      trainScheduledTimetables:
          trainScheduledTimetables ?? this.trainScheduledTimetables,
      scheduledTimetables: scheduledTimetables ?? this.scheduledTimetables,
      includeAdvertisedInterchange:
          includeAdvertisedInterchange ?? this.includeAdvertisedInterchange,
      dateUtc: dateUtc ?? this.dateUtc,
      maxResults: maxResults ?? this.maxResults,
      includeCancelled: includeCancelled ?? this.includeCancelled,
      lookBackwards: lookBackwards ?? this.lookBackwards,
      expand: expand ?? this.expand,
      includeGeopath: includeGeopath ?? this.includeGeopath,
    );
  }

  V3RouteDeparturesSpecificParameters copyWithWrapped({
    Wrapped<bool?>? trainScheduledTimetables,
    Wrapped<bool?>? scheduledTimetables,
    Wrapped<bool?>? includeAdvertisedInterchange,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<int?>? maxResults,
    Wrapped<bool?>? includeCancelled,
    Wrapped<bool?>? lookBackwards,
    Wrapped<List<int>?>? expand,
    Wrapped<bool?>? includeGeopath,
  }) {
    return V3RouteDeparturesSpecificParameters(
      trainScheduledTimetables: (trainScheduledTimetables != null
          ? trainScheduledTimetables.value
          : this.trainScheduledTimetables),
      scheduledTimetables: (scheduledTimetables != null
          ? scheduledTimetables.value
          : this.scheduledTimetables),
      includeAdvertisedInterchange: (includeAdvertisedInterchange != null
          ? includeAdvertisedInterchange.value
          : this.includeAdvertisedInterchange),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      maxResults: (maxResults != null ? maxResults.value : this.maxResults),
      includeCancelled: (includeCancelled != null
          ? includeCancelled.value
          : this.includeCancelled),
      lookBackwards: (lookBackwards != null
          ? lookBackwards.value
          : this.lookBackwards),
      expand: (expand != null ? expand.value : this.expand),
      includeGeopath: (includeGeopath != null
          ? includeGeopath.value
          : this.includeGeopath),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3BulkDeparturesRequest {
  const V3BulkDeparturesRequest({
    required this.requests,
    this.dateUtc,
    this.lookBackwards,
    this.includeCancelled,
    this.includeGeopath,
    this.expand,
    this.includeAdvertisedInterchange,
  });

  factory V3BulkDeparturesRequest.fromJson(Map<String, dynamic> json) =>
      _$V3BulkDeparturesRequestFromJson(json);

  static const toJsonFactory = _$V3BulkDeparturesRequestToJson;
  Map<String, dynamic> toJson() => _$V3BulkDeparturesRequestToJson(this);

  @JsonKey(name: 'requests', defaultValue: <V3StopDepartureRequest>[])
  final List<V3StopDepartureRequest> requests;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'look_backwards')
  final bool? lookBackwards;
  @JsonKey(name: 'include_cancelled')
  final bool? includeCancelled;
  @JsonKey(name: 'include_geopath')
  final bool? includeGeopath;
  @JsonKey(name: 'expand', defaultValue: <int>[])
  final List<int>? expand;
  @JsonKey(name: 'include_advertised_interchange')
  final bool? includeAdvertisedInterchange;
  static const fromJsonFactory = _$V3BulkDeparturesRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3BulkDeparturesRequest &&
            (identical(other.requests, requests) ||
                const DeepCollectionEquality().equals(
                  other.requests,
                  requests,
                )) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(other.lookBackwards, lookBackwards) ||
                const DeepCollectionEquality().equals(
                  other.lookBackwards,
                  lookBackwards,
                )) &&
            (identical(other.includeCancelled, includeCancelled) ||
                const DeepCollectionEquality().equals(
                  other.includeCancelled,
                  includeCancelled,
                )) &&
            (identical(other.includeGeopath, includeGeopath) ||
                const DeepCollectionEquality().equals(
                  other.includeGeopath,
                  includeGeopath,
                )) &&
            (identical(other.expand, expand) ||
                const DeepCollectionEquality().equals(other.expand, expand)) &&
            (identical(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                ) ||
                const DeepCollectionEquality().equals(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(requests) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(lookBackwards) ^
      const DeepCollectionEquality().hash(includeCancelled) ^
      const DeepCollectionEquality().hash(includeGeopath) ^
      const DeepCollectionEquality().hash(expand) ^
      const DeepCollectionEquality().hash(includeAdvertisedInterchange) ^
      runtimeType.hashCode;
}

extension $V3BulkDeparturesRequestExtension on V3BulkDeparturesRequest {
  V3BulkDeparturesRequest copyWith({
    List<V3StopDepartureRequest>? requests,
    DateTime? dateUtc,
    bool? lookBackwards,
    bool? includeCancelled,
    bool? includeGeopath,
    List<int>? expand,
    bool? includeAdvertisedInterchange,
  }) {
    return V3BulkDeparturesRequest(
      requests: requests ?? this.requests,
      dateUtc: dateUtc ?? this.dateUtc,
      lookBackwards: lookBackwards ?? this.lookBackwards,
      includeCancelled: includeCancelled ?? this.includeCancelled,
      includeGeopath: includeGeopath ?? this.includeGeopath,
      expand: expand ?? this.expand,
      includeAdvertisedInterchange:
          includeAdvertisedInterchange ?? this.includeAdvertisedInterchange,
    );
  }

  V3BulkDeparturesRequest copyWithWrapped({
    Wrapped<List<V3StopDepartureRequest>>? requests,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<bool?>? lookBackwards,
    Wrapped<bool?>? includeCancelled,
    Wrapped<bool?>? includeGeopath,
    Wrapped<List<int>?>? expand,
    Wrapped<bool?>? includeAdvertisedInterchange,
  }) {
    return V3BulkDeparturesRequest(
      requests: (requests != null ? requests.value : this.requests),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      lookBackwards: (lookBackwards != null
          ? lookBackwards.value
          : this.lookBackwards),
      includeCancelled: (includeCancelled != null
          ? includeCancelled.value
          : this.includeCancelled),
      includeGeopath: (includeGeopath != null
          ? includeGeopath.value
          : this.includeGeopath),
      expand: (expand != null ? expand.value : this.expand),
      includeAdvertisedInterchange: (includeAdvertisedInterchange != null
          ? includeAdvertisedInterchange.value
          : this.includeAdvertisedInterchange),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopDepartureRequest {
  const V3StopDepartureRequest({
    this.routeType,
    this.stopId,
    this.maxResults,
    this.gtfs,
    required this.routeDirections,
  });

  factory V3StopDepartureRequest.fromJson(Map<String, dynamic> json) =>
      _$V3StopDepartureRequestFromJson(json);

  static const toJsonFactory = _$V3StopDepartureRequestToJson;
  Map<String, dynamic> toJson() => _$V3StopDepartureRequestToJson(this);

  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'max_results')
  final int? maxResults;
  @JsonKey(name: 'gtfs')
  final bool? gtfs;
  @JsonKey(
    name: 'route_directions',
    defaultValue: <V3StopDepartureRequestRouteDirection>[],
  )
  final List<V3StopDepartureRequestRouteDirection> routeDirections;
  static const fromJsonFactory = _$V3StopDepartureRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopDepartureRequest &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.maxResults, maxResults) ||
                const DeepCollectionEquality().equals(
                  other.maxResults,
                  maxResults,
                )) &&
            (identical(other.gtfs, gtfs) ||
                const DeepCollectionEquality().equals(other.gtfs, gtfs)) &&
            (identical(other.routeDirections, routeDirections) ||
                const DeepCollectionEquality().equals(
                  other.routeDirections,
                  routeDirections,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(maxResults) ^
      const DeepCollectionEquality().hash(gtfs) ^
      const DeepCollectionEquality().hash(routeDirections) ^
      runtimeType.hashCode;
}

extension $V3StopDepartureRequestExtension on V3StopDepartureRequest {
  V3StopDepartureRequest copyWith({
    int? routeType,
    int? stopId,
    int? maxResults,
    bool? gtfs,
    List<V3StopDepartureRequestRouteDirection>? routeDirections,
  }) {
    return V3StopDepartureRequest(
      routeType: routeType ?? this.routeType,
      stopId: stopId ?? this.stopId,
      maxResults: maxResults ?? this.maxResults,
      gtfs: gtfs ?? this.gtfs,
      routeDirections: routeDirections ?? this.routeDirections,
    );
  }

  V3StopDepartureRequest copyWithWrapped({
    Wrapped<int?>? routeType,
    Wrapped<int?>? stopId,
    Wrapped<int?>? maxResults,
    Wrapped<bool?>? gtfs,
    Wrapped<List<V3StopDepartureRequestRouteDirection>>? routeDirections,
  }) {
    return V3StopDepartureRequest(
      routeType: (routeType != null ? routeType.value : this.routeType),
      stopId: (stopId != null ? stopId.value : this.stopId),
      maxResults: (maxResults != null ? maxResults.value : this.maxResults),
      gtfs: (gtfs != null ? gtfs.value : this.gtfs),
      routeDirections: (routeDirections != null
          ? routeDirections.value
          : this.routeDirections),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopDepartureRequestRouteDirection {
  const V3StopDepartureRequestRouteDirection({
    this.routeId,
    this.directionId,
    required this.directionName,
  });

  factory V3StopDepartureRequestRouteDirection.fromJson(
    Map<String, dynamic> json,
  ) => _$V3StopDepartureRequestRouteDirectionFromJson(json);

  static const toJsonFactory = _$V3StopDepartureRequestRouteDirectionToJson;
  Map<String, dynamic> toJson() =>
      _$V3StopDepartureRequestRouteDirectionToJson(this);

  @JsonKey(name: 'route_id')
  final String? routeId;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'direction_name')
  final String directionName;
  static const fromJsonFactory = _$V3StopDepartureRequestRouteDirectionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopDepartureRequestRouteDirection &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.directionName, directionName) ||
                const DeepCollectionEquality().equals(
                  other.directionName,
                  directionName,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(directionName) ^
      runtimeType.hashCode;
}

extension $V3StopDepartureRequestRouteDirectionExtension
    on V3StopDepartureRequestRouteDirection {
  V3StopDepartureRequestRouteDirection copyWith({
    String? routeId,
    int? directionId,
    String? directionName,
  }) {
    return V3StopDepartureRequestRouteDirection(
      routeId: routeId ?? this.routeId,
      directionId: directionId ?? this.directionId,
      directionName: directionName ?? this.directionName,
    );
  }

  V3StopDepartureRequestRouteDirection copyWithWrapped({
    Wrapped<String?>? routeId,
    Wrapped<int?>? directionId,
    Wrapped<String>? directionName,
  }) {
    return V3StopDepartureRequestRouteDirection(
      routeId: (routeId != null ? routeId.value : this.routeId),
      directionId: (directionId != null ? directionId.value : this.directionId),
      directionName: (directionName != null
          ? directionName.value
          : this.directionName),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3BulkDeparturesResponse {
  const V3BulkDeparturesResponse({
    this.responses,
    this.stops,
    this.routes,
    this.runs,
    this.directions,
    this.disruptions,
    this.status,
  });

  factory V3BulkDeparturesResponse.fromJson(Map<String, dynamic> json) =>
      _$V3BulkDeparturesResponseFromJson(json);

  static const toJsonFactory = _$V3BulkDeparturesResponseToJson;
  Map<String, dynamic> toJson() => _$V3BulkDeparturesResponseToJson(this);

  @JsonKey(name: 'responses', defaultValue: <V3BulkDeparturesUpdateResponse>[])
  final List<V3BulkDeparturesUpdateResponse>? responses;
  @JsonKey(name: 'stops')
  final Map<String, dynamic>? stops;
  @JsonKey(name: 'routes', defaultValue: <Object>[])
  final List<Object>? routes;
  @JsonKey(name: 'runs', defaultValue: <V3Run>[])
  final List<V3Run>? runs;
  @JsonKey(name: 'directions', defaultValue: <V3Direction>[])
  final List<V3Direction>? directions;
  @JsonKey(name: 'disruptions')
  final Map<String, dynamic>? disruptions;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3BulkDeparturesResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3BulkDeparturesResponse &&
            (identical(other.responses, responses) ||
                const DeepCollectionEquality().equals(
                  other.responses,
                  responses,
                )) &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)) &&
            (identical(other.routes, routes) ||
                const DeepCollectionEquality().equals(other.routes, routes)) &&
            (identical(other.runs, runs) ||
                const DeepCollectionEquality().equals(other.runs, runs)) &&
            (identical(other.directions, directions) ||
                const DeepCollectionEquality().equals(
                  other.directions,
                  directions,
                )) &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(responses) ^
      const DeepCollectionEquality().hash(stops) ^
      const DeepCollectionEquality().hash(routes) ^
      const DeepCollectionEquality().hash(runs) ^
      const DeepCollectionEquality().hash(directions) ^
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3BulkDeparturesResponseExtension on V3BulkDeparturesResponse {
  V3BulkDeparturesResponse copyWith({
    List<V3BulkDeparturesUpdateResponse>? responses,
    Map<String, dynamic>? stops,
    List<Object>? routes,
    List<V3Run>? runs,
    List<V3Direction>? directions,
    Map<String, dynamic>? disruptions,
    V3Status? status,
  }) {
    return V3BulkDeparturesResponse(
      responses: responses ?? this.responses,
      stops: stops ?? this.stops,
      routes: routes ?? this.routes,
      runs: runs ?? this.runs,
      directions: directions ?? this.directions,
      disruptions: disruptions ?? this.disruptions,
      status: status ?? this.status,
    );
  }

  V3BulkDeparturesResponse copyWithWrapped({
    Wrapped<List<V3BulkDeparturesUpdateResponse>?>? responses,
    Wrapped<Map<String, dynamic>?>? stops,
    Wrapped<List<Object>?>? routes,
    Wrapped<List<V3Run>?>? runs,
    Wrapped<List<V3Direction>?>? directions,
    Wrapped<Map<String, dynamic>?>? disruptions,
    Wrapped<V3Status?>? status,
  }) {
    return V3BulkDeparturesResponse(
      responses: (responses != null ? responses.value : this.responses),
      stops: (stops != null ? stops.value : this.stops),
      routes: (routes != null ? routes.value : this.routes),
      runs: (runs != null ? runs.value : this.runs),
      directions: (directions != null ? directions.value : this.directions),
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3BulkDeparturesUpdateResponse {
  const V3BulkDeparturesUpdateResponse({
    this.departures,
    this.routeType,
    this.stopId,
    this.requestedRouteDirection,
    this.routeDirectionStatus,
    this.routeDirection,
  });

  factory V3BulkDeparturesUpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$V3BulkDeparturesUpdateResponseFromJson(json);

  static const toJsonFactory = _$V3BulkDeparturesUpdateResponseToJson;
  Map<String, dynamic> toJson() => _$V3BulkDeparturesUpdateResponseToJson(this);

  @JsonKey(name: 'departures', defaultValue: <V3Departure>[])
  final List<V3Departure>? departures;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'requested_route_direction')
  final V3BulkDeparturesRouteDirectionResponse? requestedRouteDirection;
  @JsonKey(name: 'route_direction_status')
  final String? routeDirectionStatus;
  @JsonKey(name: 'route_direction')
  final V3BulkDeparturesRouteDirectionResponse? routeDirection;
  static const fromJsonFactory = _$V3BulkDeparturesUpdateResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3BulkDeparturesUpdateResponse &&
            (identical(other.departures, departures) ||
                const DeepCollectionEquality().equals(
                  other.departures,
                  departures,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(
                  other.requestedRouteDirection,
                  requestedRouteDirection,
                ) ||
                const DeepCollectionEquality().equals(
                  other.requestedRouteDirection,
                  requestedRouteDirection,
                )) &&
            (identical(other.routeDirectionStatus, routeDirectionStatus) ||
                const DeepCollectionEquality().equals(
                  other.routeDirectionStatus,
                  routeDirectionStatus,
                )) &&
            (identical(other.routeDirection, routeDirection) ||
                const DeepCollectionEquality().equals(
                  other.routeDirection,
                  routeDirection,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(departures) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(requestedRouteDirection) ^
      const DeepCollectionEquality().hash(routeDirectionStatus) ^
      const DeepCollectionEquality().hash(routeDirection) ^
      runtimeType.hashCode;
}

extension $V3BulkDeparturesUpdateResponseExtension
    on V3BulkDeparturesUpdateResponse {
  V3BulkDeparturesUpdateResponse copyWith({
    List<V3Departure>? departures,
    int? routeType,
    int? stopId,
    V3BulkDeparturesRouteDirectionResponse? requestedRouteDirection,
    String? routeDirectionStatus,
    V3BulkDeparturesRouteDirectionResponse? routeDirection,
  }) {
    return V3BulkDeparturesUpdateResponse(
      departures: departures ?? this.departures,
      routeType: routeType ?? this.routeType,
      stopId: stopId ?? this.stopId,
      requestedRouteDirection:
          requestedRouteDirection ?? this.requestedRouteDirection,
      routeDirectionStatus: routeDirectionStatus ?? this.routeDirectionStatus,
      routeDirection: routeDirection ?? this.routeDirection,
    );
  }

  V3BulkDeparturesUpdateResponse copyWithWrapped({
    Wrapped<List<V3Departure>?>? departures,
    Wrapped<int?>? routeType,
    Wrapped<int?>? stopId,
    Wrapped<V3BulkDeparturesRouteDirectionResponse?>? requestedRouteDirection,
    Wrapped<String?>? routeDirectionStatus,
    Wrapped<V3BulkDeparturesRouteDirectionResponse?>? routeDirection,
  }) {
    return V3BulkDeparturesUpdateResponse(
      departures: (departures != null ? departures.value : this.departures),
      routeType: (routeType != null ? routeType.value : this.routeType),
      stopId: (stopId != null ? stopId.value : this.stopId),
      requestedRouteDirection: (requestedRouteDirection != null
          ? requestedRouteDirection.value
          : this.requestedRouteDirection),
      routeDirectionStatus: (routeDirectionStatus != null
          ? routeDirectionStatus.value
          : this.routeDirectionStatus),
      routeDirection: (routeDirection != null
          ? routeDirection.value
          : this.routeDirection),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3BulkDeparturesStopResponse {
  const V3BulkDeparturesStopResponse({
    this.stopName,
    this.stopId,
    this.stopLatitude,
    this.stopLongitude,
    this.stopSuburb,
    this.stopLandmark,
  });

  factory V3BulkDeparturesStopResponse.fromJson(Map<String, dynamic> json) =>
      _$V3BulkDeparturesStopResponseFromJson(json);

  static const toJsonFactory = _$V3BulkDeparturesStopResponseToJson;
  Map<String, dynamic> toJson() => _$V3BulkDeparturesStopResponseToJson(this);

  @JsonKey(name: 'stop_name')
  final String? stopName;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'stop_latitude')
  final double? stopLatitude;
  @JsonKey(name: 'stop_longitude')
  final double? stopLongitude;
  @JsonKey(name: 'stop_suburb')
  final String? stopSuburb;
  @JsonKey(name: 'stop_landmark')
  final String? stopLandmark;
  static const fromJsonFactory = _$V3BulkDeparturesStopResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3BulkDeparturesStopResponse &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.stopLatitude, stopLatitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLatitude,
                  stopLatitude,
                )) &&
            (identical(other.stopLongitude, stopLongitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLongitude,
                  stopLongitude,
                )) &&
            (identical(other.stopSuburb, stopSuburb) ||
                const DeepCollectionEquality().equals(
                  other.stopSuburb,
                  stopSuburb,
                )) &&
            (identical(other.stopLandmark, stopLandmark) ||
                const DeepCollectionEquality().equals(
                  other.stopLandmark,
                  stopLandmark,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopName) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(stopLatitude) ^
      const DeepCollectionEquality().hash(stopLongitude) ^
      const DeepCollectionEquality().hash(stopSuburb) ^
      const DeepCollectionEquality().hash(stopLandmark) ^
      runtimeType.hashCode;
}

extension $V3BulkDeparturesStopResponseExtension
    on V3BulkDeparturesStopResponse {
  V3BulkDeparturesStopResponse copyWith({
    String? stopName,
    int? stopId,
    double? stopLatitude,
    double? stopLongitude,
    String? stopSuburb,
    String? stopLandmark,
  }) {
    return V3BulkDeparturesStopResponse(
      stopName: stopName ?? this.stopName,
      stopId: stopId ?? this.stopId,
      stopLatitude: stopLatitude ?? this.stopLatitude,
      stopLongitude: stopLongitude ?? this.stopLongitude,
      stopSuburb: stopSuburb ?? this.stopSuburb,
      stopLandmark: stopLandmark ?? this.stopLandmark,
    );
  }

  V3BulkDeparturesStopResponse copyWithWrapped({
    Wrapped<String?>? stopName,
    Wrapped<int?>? stopId,
    Wrapped<double?>? stopLatitude,
    Wrapped<double?>? stopLongitude,
    Wrapped<String?>? stopSuburb,
    Wrapped<String?>? stopLandmark,
  }) {
    return V3BulkDeparturesStopResponse(
      stopName: (stopName != null ? stopName.value : this.stopName),
      stopId: (stopId != null ? stopId.value : this.stopId),
      stopLatitude: (stopLatitude != null
          ? stopLatitude.value
          : this.stopLatitude),
      stopLongitude: (stopLongitude != null
          ? stopLongitude.value
          : this.stopLongitude),
      stopSuburb: (stopSuburb != null ? stopSuburb.value : this.stopSuburb),
      stopLandmark: (stopLandmark != null
          ? stopLandmark.value
          : this.stopLandmark),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3BulkDeparturesRouteDirectionResponse {
  const V3BulkDeparturesRouteDirectionResponse({
    this.routeId,
    this.directionId,
    this.directionName,
  });

  factory V3BulkDeparturesRouteDirectionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$V3BulkDeparturesRouteDirectionResponseFromJson(json);

  static const toJsonFactory = _$V3BulkDeparturesRouteDirectionResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V3BulkDeparturesRouteDirectionResponseToJson(this);

  @JsonKey(name: 'route_id')
  final String? routeId;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'direction_name')
  final String? directionName;
  static const fromJsonFactory =
      _$V3BulkDeparturesRouteDirectionResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3BulkDeparturesRouteDirectionResponse &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.directionName, directionName) ||
                const DeepCollectionEquality().equals(
                  other.directionName,
                  directionName,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(directionName) ^
      runtimeType.hashCode;
}

extension $V3BulkDeparturesRouteDirectionResponseExtension
    on V3BulkDeparturesRouteDirectionResponse {
  V3BulkDeparturesRouteDirectionResponse copyWith({
    String? routeId,
    int? directionId,
    String? directionName,
  }) {
    return V3BulkDeparturesRouteDirectionResponse(
      routeId: routeId ?? this.routeId,
      directionId: directionId ?? this.directionId,
      directionName: directionName ?? this.directionName,
    );
  }

  V3BulkDeparturesRouteDirectionResponse copyWithWrapped({
    Wrapped<String?>? routeId,
    Wrapped<int?>? directionId,
    Wrapped<String?>? directionName,
  }) {
    return V3BulkDeparturesRouteDirectionResponse(
      routeId: (routeId != null ? routeId.value : this.routeId),
      directionId: (directionId != null ? directionId.value : this.directionId),
      directionName: (directionName != null
          ? directionName.value
          : this.directionName),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DirectionsResponse {
  const V3DirectionsResponse({this.directions, this.status});

  factory V3DirectionsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3DirectionsResponseFromJson(json);

  static const toJsonFactory = _$V3DirectionsResponseToJson;
  Map<String, dynamic> toJson() => _$V3DirectionsResponseToJson(this);

  @JsonKey(name: 'directions', defaultValue: <V3DirectionWithDescription>[])
  final List<V3DirectionWithDescription>? directions;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3DirectionsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DirectionsResponse &&
            (identical(other.directions, directions) ||
                const DeepCollectionEquality().equals(
                  other.directions,
                  directions,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(directions) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3DirectionsResponseExtension on V3DirectionsResponse {
  V3DirectionsResponse copyWith({
    List<V3DirectionWithDescription>? directions,
    V3Status? status,
  }) {
    return V3DirectionsResponse(
      directions: directions ?? this.directions,
      status: status ?? this.status,
    );
  }

  V3DirectionsResponse copyWithWrapped({
    Wrapped<List<V3DirectionWithDescription>?>? directions,
    Wrapped<V3Status?>? status,
  }) {
    return V3DirectionsResponse(
      directions: (directions != null ? directions.value : this.directions),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DirectionWithDescription {
  const V3DirectionWithDescription({
    this.routeDirectionDescription,
    this.directionId,
    this.directionName,
    this.routeId,
    this.routeType,
  });

  factory V3DirectionWithDescription.fromJson(Map<String, dynamic> json) =>
      _$V3DirectionWithDescriptionFromJson(json);

  static const toJsonFactory = _$V3DirectionWithDescriptionToJson;
  Map<String, dynamic> toJson() => _$V3DirectionWithDescriptionToJson(this);

  @JsonKey(name: 'route_direction_description')
  final String? routeDirectionDescription;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'direction_name')
  final String? directionName;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'route_type')
  final int? routeType;
  static const fromJsonFactory = _$V3DirectionWithDescriptionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DirectionWithDescription &&
            (identical(
                  other.routeDirectionDescription,
                  routeDirectionDescription,
                ) ||
                const DeepCollectionEquality().equals(
                  other.routeDirectionDescription,
                  routeDirectionDescription,
                )) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.directionName, directionName) ||
                const DeepCollectionEquality().equals(
                  other.directionName,
                  directionName,
                )) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeDirectionDescription) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(directionName) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(routeType) ^
      runtimeType.hashCode;
}

extension $V3DirectionWithDescriptionExtension on V3DirectionWithDescription {
  V3DirectionWithDescription copyWith({
    String? routeDirectionDescription,
    int? directionId,
    String? directionName,
    int? routeId,
    int? routeType,
  }) {
    return V3DirectionWithDescription(
      routeDirectionDescription:
          routeDirectionDescription ?? this.routeDirectionDescription,
      directionId: directionId ?? this.directionId,
      directionName: directionName ?? this.directionName,
      routeId: routeId ?? this.routeId,
      routeType: routeType ?? this.routeType,
    );
  }

  V3DirectionWithDescription copyWithWrapped({
    Wrapped<String?>? routeDirectionDescription,
    Wrapped<int?>? directionId,
    Wrapped<String?>? directionName,
    Wrapped<int?>? routeId,
    Wrapped<int?>? routeType,
  }) {
    return V3DirectionWithDescription(
      routeDirectionDescription: (routeDirectionDescription != null
          ? routeDirectionDescription.value
          : this.routeDirectionDescription),
      directionId: (directionId != null ? directionId.value : this.directionId),
      directionName: (directionName != null
          ? directionName.value
          : this.directionName),
      routeId: (routeId != null ? routeId.value : this.routeId),
      routeType: (routeType != null ? routeType.value : this.routeType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DisruptionsResponse {
  const V3DisruptionsResponse({this.disruptions, this.status});

  factory V3DisruptionsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionsResponseFromJson(json);

  static const toJsonFactory = _$V3DisruptionsResponseToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionsResponseToJson(this);

  @JsonKey(name: 'disruptions')
  final V3Disruptions? disruptions;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3DisruptionsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DisruptionsResponse &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3DisruptionsResponseExtension on V3DisruptionsResponse {
  V3DisruptionsResponse copyWith({
    V3Disruptions? disruptions,
    V3Status? status,
  }) {
    return V3DisruptionsResponse(
      disruptions: disruptions ?? this.disruptions,
      status: status ?? this.status,
    );
  }

  V3DisruptionsResponse copyWithWrapped({
    Wrapped<V3Disruptions?>? disruptions,
    Wrapped<V3Status?>? status,
  }) {
    return V3DisruptionsResponse(
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Disruptions {
  const V3Disruptions({
    this.general,
    this.metroTrain,
    this.metroTram,
    this.metroBus,
    this.regionalTrain,
    this.regionalCoach,
    this.regionalBus,
    this.schoolBus,
    this.telebus,
    this.nightBus,
    this.ferry,
    this.interstateTrain,
    this.skybus,
    this.taxi,
  });

  factory V3Disruptions.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionsFromJson(json);

  static const toJsonFactory = _$V3DisruptionsToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionsToJson(this);

  @JsonKey(name: 'general', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? general;
  @JsonKey(name: 'metro_train', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? metroTrain;
  @JsonKey(name: 'metro_tram', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? metroTram;
  @JsonKey(name: 'metro_bus', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? metroBus;
  @JsonKey(name: 'regional_train', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? regionalTrain;
  @JsonKey(name: 'regional_coach', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? regionalCoach;
  @JsonKey(name: 'regional_bus', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? regionalBus;
  @JsonKey(name: 'school_bus', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? schoolBus;
  @JsonKey(name: 'telebus', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? telebus;
  @JsonKey(name: 'night_bus', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? nightBus;
  @JsonKey(name: 'ferry', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? ferry;
  @JsonKey(name: 'interstate_train', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? interstateTrain;
  @JsonKey(name: 'skybus', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? skybus;
  @JsonKey(name: 'taxi', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? taxi;
  static const fromJsonFactory = _$V3DisruptionsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Disruptions &&
            (identical(other.general, general) ||
                const DeepCollectionEquality().equals(
                  other.general,
                  general,
                )) &&
            (identical(other.metroTrain, metroTrain) ||
                const DeepCollectionEquality().equals(
                  other.metroTrain,
                  metroTrain,
                )) &&
            (identical(other.metroTram, metroTram) ||
                const DeepCollectionEquality().equals(
                  other.metroTram,
                  metroTram,
                )) &&
            (identical(other.metroBus, metroBus) ||
                const DeepCollectionEquality().equals(
                  other.metroBus,
                  metroBus,
                )) &&
            (identical(other.regionalTrain, regionalTrain) ||
                const DeepCollectionEquality().equals(
                  other.regionalTrain,
                  regionalTrain,
                )) &&
            (identical(other.regionalCoach, regionalCoach) ||
                const DeepCollectionEquality().equals(
                  other.regionalCoach,
                  regionalCoach,
                )) &&
            (identical(other.regionalBus, regionalBus) ||
                const DeepCollectionEquality().equals(
                  other.regionalBus,
                  regionalBus,
                )) &&
            (identical(other.schoolBus, schoolBus) ||
                const DeepCollectionEquality().equals(
                  other.schoolBus,
                  schoolBus,
                )) &&
            (identical(other.telebus, telebus) ||
                const DeepCollectionEquality().equals(
                  other.telebus,
                  telebus,
                )) &&
            (identical(other.nightBus, nightBus) ||
                const DeepCollectionEquality().equals(
                  other.nightBus,
                  nightBus,
                )) &&
            (identical(other.ferry, ferry) ||
                const DeepCollectionEquality().equals(other.ferry, ferry)) &&
            (identical(other.interstateTrain, interstateTrain) ||
                const DeepCollectionEquality().equals(
                  other.interstateTrain,
                  interstateTrain,
                )) &&
            (identical(other.skybus, skybus) ||
                const DeepCollectionEquality().equals(other.skybus, skybus)) &&
            (identical(other.taxi, taxi) ||
                const DeepCollectionEquality().equals(other.taxi, taxi)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(general) ^
      const DeepCollectionEquality().hash(metroTrain) ^
      const DeepCollectionEquality().hash(metroTram) ^
      const DeepCollectionEquality().hash(metroBus) ^
      const DeepCollectionEquality().hash(regionalTrain) ^
      const DeepCollectionEquality().hash(regionalCoach) ^
      const DeepCollectionEquality().hash(regionalBus) ^
      const DeepCollectionEquality().hash(schoolBus) ^
      const DeepCollectionEquality().hash(telebus) ^
      const DeepCollectionEquality().hash(nightBus) ^
      const DeepCollectionEquality().hash(ferry) ^
      const DeepCollectionEquality().hash(interstateTrain) ^
      const DeepCollectionEquality().hash(skybus) ^
      const DeepCollectionEquality().hash(taxi) ^
      runtimeType.hashCode;
}

extension $V3DisruptionsExtension on V3Disruptions {
  V3Disruptions copyWith({
    List<V3Disruption>? general,
    List<V3Disruption>? metroTrain,
    List<V3Disruption>? metroTram,
    List<V3Disruption>? metroBus,
    List<V3Disruption>? regionalTrain,
    List<V3Disruption>? regionalCoach,
    List<V3Disruption>? regionalBus,
    List<V3Disruption>? schoolBus,
    List<V3Disruption>? telebus,
    List<V3Disruption>? nightBus,
    List<V3Disruption>? ferry,
    List<V3Disruption>? interstateTrain,
    List<V3Disruption>? skybus,
    List<V3Disruption>? taxi,
  }) {
    return V3Disruptions(
      general: general ?? this.general,
      metroTrain: metroTrain ?? this.metroTrain,
      metroTram: metroTram ?? this.metroTram,
      metroBus: metroBus ?? this.metroBus,
      regionalTrain: regionalTrain ?? this.regionalTrain,
      regionalCoach: regionalCoach ?? this.regionalCoach,
      regionalBus: regionalBus ?? this.regionalBus,
      schoolBus: schoolBus ?? this.schoolBus,
      telebus: telebus ?? this.telebus,
      nightBus: nightBus ?? this.nightBus,
      ferry: ferry ?? this.ferry,
      interstateTrain: interstateTrain ?? this.interstateTrain,
      skybus: skybus ?? this.skybus,
      taxi: taxi ?? this.taxi,
    );
  }

  V3Disruptions copyWithWrapped({
    Wrapped<List<V3Disruption>?>? general,
    Wrapped<List<V3Disruption>?>? metroTrain,
    Wrapped<List<V3Disruption>?>? metroTram,
    Wrapped<List<V3Disruption>?>? metroBus,
    Wrapped<List<V3Disruption>?>? regionalTrain,
    Wrapped<List<V3Disruption>?>? regionalCoach,
    Wrapped<List<V3Disruption>?>? regionalBus,
    Wrapped<List<V3Disruption>?>? schoolBus,
    Wrapped<List<V3Disruption>?>? telebus,
    Wrapped<List<V3Disruption>?>? nightBus,
    Wrapped<List<V3Disruption>?>? ferry,
    Wrapped<List<V3Disruption>?>? interstateTrain,
    Wrapped<List<V3Disruption>?>? skybus,
    Wrapped<List<V3Disruption>?>? taxi,
  }) {
    return V3Disruptions(
      general: (general != null ? general.value : this.general),
      metroTrain: (metroTrain != null ? metroTrain.value : this.metroTrain),
      metroTram: (metroTram != null ? metroTram.value : this.metroTram),
      metroBus: (metroBus != null ? metroBus.value : this.metroBus),
      regionalTrain: (regionalTrain != null
          ? regionalTrain.value
          : this.regionalTrain),
      regionalCoach: (regionalCoach != null
          ? regionalCoach.value
          : this.regionalCoach),
      regionalBus: (regionalBus != null ? regionalBus.value : this.regionalBus),
      schoolBus: (schoolBus != null ? schoolBus.value : this.schoolBus),
      telebus: (telebus != null ? telebus.value : this.telebus),
      nightBus: (nightBus != null ? nightBus.value : this.nightBus),
      ferry: (ferry != null ? ferry.value : this.ferry),
      interstateTrain: (interstateTrain != null
          ? interstateTrain.value
          : this.interstateTrain),
      skybus: (skybus != null ? skybus.value : this.skybus),
      taxi: (taxi != null ? taxi.value : this.taxi),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DisruptionResponse {
  const V3DisruptionResponse({this.disruption, this.status});

  factory V3DisruptionResponse.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionResponseFromJson(json);

  static const toJsonFactory = _$V3DisruptionResponseToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionResponseToJson(this);

  @JsonKey(name: 'disruption')
  final V3Disruption? disruption;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3DisruptionResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DisruptionResponse &&
            (identical(other.disruption, disruption) ||
                const DeepCollectionEquality().equals(
                  other.disruption,
                  disruption,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruption) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3DisruptionResponseExtension on V3DisruptionResponse {
  V3DisruptionResponse copyWith({V3Disruption? disruption, V3Status? status}) {
    return V3DisruptionResponse(
      disruption: disruption ?? this.disruption,
      status: status ?? this.status,
    );
  }

  V3DisruptionResponse copyWithWrapped({
    Wrapped<V3Disruption?>? disruption,
    Wrapped<V3Status?>? status,
  }) {
    return V3DisruptionResponse(
      disruption: (disruption != null ? disruption.value : this.disruption),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopToStopDisruptionsResponse {
  const V3StopToStopDisruptionsResponse({this.disruptions, this.status});

  factory V3StopToStopDisruptionsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3StopToStopDisruptionsResponseFromJson(json);

  static const toJsonFactory = _$V3StopToStopDisruptionsResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V3StopToStopDisruptionsResponseToJson(this);

  @JsonKey(name: 'disruptions', defaultValue: <V3StopToStopDisruption>[])
  final List<V3StopToStopDisruption>? disruptions;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3StopToStopDisruptionsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopToStopDisruptionsResponse &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3StopToStopDisruptionsResponseExtension
    on V3StopToStopDisruptionsResponse {
  V3StopToStopDisruptionsResponse copyWith({
    List<V3StopToStopDisruption>? disruptions,
    V3Status? status,
  }) {
    return V3StopToStopDisruptionsResponse(
      disruptions: disruptions ?? this.disruptions,
      status: status ?? this.status,
    );
  }

  V3StopToStopDisruptionsResponse copyWithWrapped({
    Wrapped<List<V3StopToStopDisruption>?>? disruptions,
    Wrapped<V3Status?>? status,
  }) {
    return V3StopToStopDisruptionsResponse(
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopToStopDisruption {
  const V3StopToStopDisruption({
    this.end,
    this.start,
    this.region,
    this.alternateTransport,
    this.status,
    this.publishedOn,
    this.directionName,
  });

  factory V3StopToStopDisruption.fromJson(Map<String, dynamic> json) =>
      _$V3StopToStopDisruptionFromJson(json);

  static const toJsonFactory = _$V3StopToStopDisruptionToJson;
  Map<String, dynamic> toJson() => _$V3StopToStopDisruptionToJson(this);

  @JsonKey(name: 'end')
  final V3StopBasic? end;
  @JsonKey(name: 'start')
  final V3StopBasic? start;
  @JsonKey(name: 'region')
  final String? region;
  @JsonKey(name: 'alternate_transport')
  final String? alternateTransport;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'published_on')
  final DateTime? publishedOn;
  @JsonKey(name: 'direction_name')
  final String? directionName;
  static const fromJsonFactory = _$V3StopToStopDisruptionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopToStopDisruption &&
            (identical(other.end, end) ||
                const DeepCollectionEquality().equals(other.end, end)) &&
            (identical(other.start, start) ||
                const DeepCollectionEquality().equals(other.start, start)) &&
            (identical(other.region, region) ||
                const DeepCollectionEquality().equals(other.region, region)) &&
            (identical(other.alternateTransport, alternateTransport) ||
                const DeepCollectionEquality().equals(
                  other.alternateTransport,
                  alternateTransport,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.publishedOn, publishedOn) ||
                const DeepCollectionEquality().equals(
                  other.publishedOn,
                  publishedOn,
                )) &&
            (identical(other.directionName, directionName) ||
                const DeepCollectionEquality().equals(
                  other.directionName,
                  directionName,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(end) ^
      const DeepCollectionEquality().hash(start) ^
      const DeepCollectionEquality().hash(region) ^
      const DeepCollectionEquality().hash(alternateTransport) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(publishedOn) ^
      const DeepCollectionEquality().hash(directionName) ^
      runtimeType.hashCode;
}

extension $V3StopToStopDisruptionExtension on V3StopToStopDisruption {
  V3StopToStopDisruption copyWith({
    V3StopBasic? end,
    V3StopBasic? start,
    String? region,
    String? alternateTransport,
    String? status,
    DateTime? publishedOn,
    String? directionName,
  }) {
    return V3StopToStopDisruption(
      end: end ?? this.end,
      start: start ?? this.start,
      region: region ?? this.region,
      alternateTransport: alternateTransport ?? this.alternateTransport,
      status: status ?? this.status,
      publishedOn: publishedOn ?? this.publishedOn,
      directionName: directionName ?? this.directionName,
    );
  }

  V3StopToStopDisruption copyWithWrapped({
    Wrapped<V3StopBasic?>? end,
    Wrapped<V3StopBasic?>? start,
    Wrapped<String?>? region,
    Wrapped<String?>? alternateTransport,
    Wrapped<String?>? status,
    Wrapped<DateTime?>? publishedOn,
    Wrapped<String?>? directionName,
  }) {
    return V3StopToStopDisruption(
      end: (end != null ? end.value : this.end),
      start: (start != null ? start.value : this.start),
      region: (region != null ? region.value : this.region),
      alternateTransport: (alternateTransport != null
          ? alternateTransport.value
          : this.alternateTransport),
      status: (status != null ? status.value : this.status),
      publishedOn: (publishedOn != null ? publishedOn.value : this.publishedOn),
      directionName: (directionName != null
          ? directionName.value
          : this.directionName),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopBasic {
  const V3StopBasic({this.stopId, this.stopName});

  factory V3StopBasic.fromJson(Map<String, dynamic> json) =>
      _$V3StopBasicFromJson(json);

  static const toJsonFactory = _$V3StopBasicToJson;
  Map<String, dynamic> toJson() => _$V3StopBasicToJson(this);

  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  static const fromJsonFactory = _$V3StopBasicFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopBasic &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(stopName) ^
      runtimeType.hashCode;
}

extension $V3StopBasicExtension on V3StopBasic {
  V3StopBasic copyWith({int? stopId, String? stopName}) {
    return V3StopBasic(
      stopId: stopId ?? this.stopId,
      stopName: stopName ?? this.stopName,
    );
  }

  V3StopBasic copyWithWrapped({
    Wrapped<int?>? stopId,
    Wrapped<String?>? stopName,
  }) {
    return V3StopBasic(
      stopId: (stopId != null ? stopId.value : this.stopId),
      stopName: (stopName != null ? stopName.value : this.stopName),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DisruptionModesResponse {
  const V3DisruptionModesResponse({this.disruptionModes, this.status});

  factory V3DisruptionModesResponse.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionModesResponseFromJson(json);

  static const toJsonFactory = _$V3DisruptionModesResponseToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionModesResponseToJson(this);

  @JsonKey(name: 'disruption_modes', defaultValue: <V3DisruptionMode>[])
  final List<V3DisruptionMode>? disruptionModes;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3DisruptionModesResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DisruptionModesResponse &&
            (identical(other.disruptionModes, disruptionModes) ||
                const DeepCollectionEquality().equals(
                  other.disruptionModes,
                  disruptionModes,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptionModes) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3DisruptionModesResponseExtension on V3DisruptionModesResponse {
  V3DisruptionModesResponse copyWith({
    List<V3DisruptionMode>? disruptionModes,
    V3Status? status,
  }) {
    return V3DisruptionModesResponse(
      disruptionModes: disruptionModes ?? this.disruptionModes,
      status: status ?? this.status,
    );
  }

  V3DisruptionModesResponse copyWithWrapped({
    Wrapped<List<V3DisruptionMode>?>? disruptionModes,
    Wrapped<V3Status?>? status,
  }) {
    return V3DisruptionModesResponse(
      disruptionModes: (disruptionModes != null
          ? disruptionModes.value
          : this.disruptionModes),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DisruptionMode {
  const V3DisruptionMode({this.disruptionModeName, this.disruptionMode});

  factory V3DisruptionMode.fromJson(Map<String, dynamic> json) =>
      _$V3DisruptionModeFromJson(json);

  static const toJsonFactory = _$V3DisruptionModeToJson;
  Map<String, dynamic> toJson() => _$V3DisruptionModeToJson(this);

  @JsonKey(name: 'disruption_mode_name')
  final String? disruptionModeName;
  @JsonKey(name: 'disruption_mode')
  final int? disruptionMode;
  static const fromJsonFactory = _$V3DisruptionModeFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DisruptionMode &&
            (identical(other.disruptionModeName, disruptionModeName) ||
                const DeepCollectionEquality().equals(
                  other.disruptionModeName,
                  disruptionModeName,
                )) &&
            (identical(other.disruptionMode, disruptionMode) ||
                const DeepCollectionEquality().equals(
                  other.disruptionMode,
                  disruptionMode,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptionModeName) ^
      const DeepCollectionEquality().hash(disruptionMode) ^
      runtimeType.hashCode;
}

extension $V3DisruptionModeExtension on V3DisruptionMode {
  V3DisruptionMode copyWith({String? disruptionModeName, int? disruptionMode}) {
    return V3DisruptionMode(
      disruptionModeName: disruptionModeName ?? this.disruptionModeName,
      disruptionMode: disruptionMode ?? this.disruptionMode,
    );
  }

  V3DisruptionMode copyWithWrapped({
    Wrapped<String?>? disruptionModeName,
    Wrapped<int?>? disruptionMode,
  }) {
    return V3DisruptionMode(
      disruptionModeName: (disruptionModeName != null
          ? disruptionModeName.value
          : this.disruptionModeName),
      disruptionMode: (disruptionMode != null
          ? disruptionMode.value
          : this.disruptionMode),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3FareEstimateParameters {
  const V3FareEstimateParameters({
    this.journeyTouchOnUtc,
    this.journeyTouchOffUtc,
    this.isJourneyInFreeTramZone,
    this.isJourneyInOverlapZone,
    this.travelledRouteTypes,
  });

  factory V3FareEstimateParameters.fromJson(Map<String, dynamic> json) =>
      _$V3FareEstimateParametersFromJson(json);

  static const toJsonFactory = _$V3FareEstimateParametersToJson;
  Map<String, dynamic> toJson() => _$V3FareEstimateParametersToJson(this);

  @JsonKey(name: 'journey_touch_on_utc')
  final DateTime? journeyTouchOnUtc;
  @JsonKey(name: 'journey_touch_off_utc')
  final DateTime? journeyTouchOffUtc;
  @JsonKey(name: 'is_journey_in_free_tram_zone')
  final bool? isJourneyInFreeTramZone;
  @JsonKey(name: 'is_journey_in_overlap_zone')
  final bool? isJourneyInOverlapZone;
  @JsonKey(name: 'travelled_route_types', defaultValue: <int>[])
  final List<int>? travelledRouteTypes;
  static const fromJsonFactory = _$V3FareEstimateParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3FareEstimateParameters &&
            (identical(other.journeyTouchOnUtc, journeyTouchOnUtc) ||
                const DeepCollectionEquality().equals(
                  other.journeyTouchOnUtc,
                  journeyTouchOnUtc,
                )) &&
            (identical(other.journeyTouchOffUtc, journeyTouchOffUtc) ||
                const DeepCollectionEquality().equals(
                  other.journeyTouchOffUtc,
                  journeyTouchOffUtc,
                )) &&
            (identical(
                  other.isJourneyInFreeTramZone,
                  isJourneyInFreeTramZone,
                ) ||
                const DeepCollectionEquality().equals(
                  other.isJourneyInFreeTramZone,
                  isJourneyInFreeTramZone,
                )) &&
            (identical(other.isJourneyInOverlapZone, isJourneyInOverlapZone) ||
                const DeepCollectionEquality().equals(
                  other.isJourneyInOverlapZone,
                  isJourneyInOverlapZone,
                )) &&
            (identical(other.travelledRouteTypes, travelledRouteTypes) ||
                const DeepCollectionEquality().equals(
                  other.travelledRouteTypes,
                  travelledRouteTypes,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(journeyTouchOnUtc) ^
      const DeepCollectionEquality().hash(journeyTouchOffUtc) ^
      const DeepCollectionEquality().hash(isJourneyInFreeTramZone) ^
      const DeepCollectionEquality().hash(isJourneyInOverlapZone) ^
      const DeepCollectionEquality().hash(travelledRouteTypes) ^
      runtimeType.hashCode;
}

extension $V3FareEstimateParametersExtension on V3FareEstimateParameters {
  V3FareEstimateParameters copyWith({
    DateTime? journeyTouchOnUtc,
    DateTime? journeyTouchOffUtc,
    bool? isJourneyInFreeTramZone,
    bool? isJourneyInOverlapZone,
    List<int>? travelledRouteTypes,
  }) {
    return V3FareEstimateParameters(
      journeyTouchOnUtc: journeyTouchOnUtc ?? this.journeyTouchOnUtc,
      journeyTouchOffUtc: journeyTouchOffUtc ?? this.journeyTouchOffUtc,
      isJourneyInFreeTramZone:
          isJourneyInFreeTramZone ?? this.isJourneyInFreeTramZone,
      isJourneyInOverlapZone:
          isJourneyInOverlapZone ?? this.isJourneyInOverlapZone,
      travelledRouteTypes: travelledRouteTypes ?? this.travelledRouteTypes,
    );
  }

  V3FareEstimateParameters copyWithWrapped({
    Wrapped<DateTime?>? journeyTouchOnUtc,
    Wrapped<DateTime?>? journeyTouchOffUtc,
    Wrapped<bool?>? isJourneyInFreeTramZone,
    Wrapped<bool?>? isJourneyInOverlapZone,
    Wrapped<List<int>?>? travelledRouteTypes,
  }) {
    return V3FareEstimateParameters(
      journeyTouchOnUtc: (journeyTouchOnUtc != null
          ? journeyTouchOnUtc.value
          : this.journeyTouchOnUtc),
      journeyTouchOffUtc: (journeyTouchOffUtc != null
          ? journeyTouchOffUtc.value
          : this.journeyTouchOffUtc),
      isJourneyInFreeTramZone: (isJourneyInFreeTramZone != null
          ? isJourneyInFreeTramZone.value
          : this.isJourneyInFreeTramZone),
      isJourneyInOverlapZone: (isJourneyInOverlapZone != null
          ? isJourneyInOverlapZone.value
          : this.isJourneyInOverlapZone),
      travelledRouteTypes: (travelledRouteTypes != null
          ? travelledRouteTypes.value
          : this.travelledRouteTypes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3FareEstimateResponse {
  const V3FareEstimateResponse({
    this.fareEstimateResultStatus,
    this.fareEstimateResult,
  });

  factory V3FareEstimateResponse.fromJson(Map<String, dynamic> json) =>
      _$V3FareEstimateResponseFromJson(json);

  static const toJsonFactory = _$V3FareEstimateResponseToJson;
  Map<String, dynamic> toJson() => _$V3FareEstimateResponseToJson(this);

  @JsonKey(name: 'FareEstimateResultStatus')
  final V3FareEstimateResultStatus? fareEstimateResultStatus;
  @JsonKey(name: 'FareEstimateResult')
  final V3FareEstimateResult? fareEstimateResult;
  static const fromJsonFactory = _$V3FareEstimateResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3FareEstimateResponse &&
            (identical(
                  other.fareEstimateResultStatus,
                  fareEstimateResultStatus,
                ) ||
                const DeepCollectionEquality().equals(
                  other.fareEstimateResultStatus,
                  fareEstimateResultStatus,
                )) &&
            (identical(other.fareEstimateResult, fareEstimateResult) ||
                const DeepCollectionEquality().equals(
                  other.fareEstimateResult,
                  fareEstimateResult,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(fareEstimateResultStatus) ^
      const DeepCollectionEquality().hash(fareEstimateResult) ^
      runtimeType.hashCode;
}

extension $V3FareEstimateResponseExtension on V3FareEstimateResponse {
  V3FareEstimateResponse copyWith({
    V3FareEstimateResultStatus? fareEstimateResultStatus,
    V3FareEstimateResult? fareEstimateResult,
  }) {
    return V3FareEstimateResponse(
      fareEstimateResultStatus:
          fareEstimateResultStatus ?? this.fareEstimateResultStatus,
      fareEstimateResult: fareEstimateResult ?? this.fareEstimateResult,
    );
  }

  V3FareEstimateResponse copyWithWrapped({
    Wrapped<V3FareEstimateResultStatus?>? fareEstimateResultStatus,
    Wrapped<V3FareEstimateResult?>? fareEstimateResult,
  }) {
    return V3FareEstimateResponse(
      fareEstimateResultStatus: (fareEstimateResultStatus != null
          ? fareEstimateResultStatus.value
          : this.fareEstimateResultStatus),
      fareEstimateResult: (fareEstimateResult != null
          ? fareEstimateResult.value
          : this.fareEstimateResult),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3FareEstimateResultStatus {
  const V3FareEstimateResultStatus({this.statusCode, this.message});

  factory V3FareEstimateResultStatus.fromJson(Map<String, dynamic> json) =>
      _$V3FareEstimateResultStatusFromJson(json);

  static const toJsonFactory = _$V3FareEstimateResultStatusToJson;
  Map<String, dynamic> toJson() => _$V3FareEstimateResultStatusToJson(this);

  @JsonKey(name: 'StatusCode')
  final int? statusCode;
  @JsonKey(name: 'Message')
  final String? message;
  static const fromJsonFactory = _$V3FareEstimateResultStatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3FareEstimateResultStatus &&
            (identical(other.statusCode, statusCode) ||
                const DeepCollectionEquality().equals(
                  other.statusCode,
                  statusCode,
                )) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(statusCode) ^
      const DeepCollectionEquality().hash(message) ^
      runtimeType.hashCode;
}

extension $V3FareEstimateResultStatusExtension on V3FareEstimateResultStatus {
  V3FareEstimateResultStatus copyWith({int? statusCode, String? message}) {
    return V3FareEstimateResultStatus(
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
    );
  }

  V3FareEstimateResultStatus copyWithWrapped({
    Wrapped<int?>? statusCode,
    Wrapped<String?>? message,
  }) {
    return V3FareEstimateResultStatus(
      statusCode: (statusCode != null ? statusCode.value : this.statusCode),
      message: (message != null ? message.value : this.message),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3FareEstimateResult {
  const V3FareEstimateResult({
    this.isEarlyBird,
    this.isJourneyInFreeTramZone,
    this.isThisWeekendJourney,
    this.zoneInfo,
    this.passengerFares,
  });

  factory V3FareEstimateResult.fromJson(Map<String, dynamic> json) =>
      _$V3FareEstimateResultFromJson(json);

  static const toJsonFactory = _$V3FareEstimateResultToJson;
  Map<String, dynamic> toJson() => _$V3FareEstimateResultToJson(this);

  @JsonKey(name: 'IsEarlyBird')
  final bool? isEarlyBird;
  @JsonKey(name: 'IsJourneyInFreeTramZone')
  final bool? isJourneyInFreeTramZone;
  @JsonKey(name: 'IsThisWeekendJourney')
  final bool? isThisWeekendJourney;
  @JsonKey(name: 'ZoneInfo')
  final V3ZoneInfo? zoneInfo;
  @JsonKey(name: 'PassengerFares', defaultValue: <V3PassengerFare>[])
  final List<V3PassengerFare>? passengerFares;
  static const fromJsonFactory = _$V3FareEstimateResultFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3FareEstimateResult &&
            (identical(other.isEarlyBird, isEarlyBird) ||
                const DeepCollectionEquality().equals(
                  other.isEarlyBird,
                  isEarlyBird,
                )) &&
            (identical(
                  other.isJourneyInFreeTramZone,
                  isJourneyInFreeTramZone,
                ) ||
                const DeepCollectionEquality().equals(
                  other.isJourneyInFreeTramZone,
                  isJourneyInFreeTramZone,
                )) &&
            (identical(other.isThisWeekendJourney, isThisWeekendJourney) ||
                const DeepCollectionEquality().equals(
                  other.isThisWeekendJourney,
                  isThisWeekendJourney,
                )) &&
            (identical(other.zoneInfo, zoneInfo) ||
                const DeepCollectionEquality().equals(
                  other.zoneInfo,
                  zoneInfo,
                )) &&
            (identical(other.passengerFares, passengerFares) ||
                const DeepCollectionEquality().equals(
                  other.passengerFares,
                  passengerFares,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(isEarlyBird) ^
      const DeepCollectionEquality().hash(isJourneyInFreeTramZone) ^
      const DeepCollectionEquality().hash(isThisWeekendJourney) ^
      const DeepCollectionEquality().hash(zoneInfo) ^
      const DeepCollectionEquality().hash(passengerFares) ^
      runtimeType.hashCode;
}

extension $V3FareEstimateResultExtension on V3FareEstimateResult {
  V3FareEstimateResult copyWith({
    bool? isEarlyBird,
    bool? isJourneyInFreeTramZone,
    bool? isThisWeekendJourney,
    V3ZoneInfo? zoneInfo,
    List<V3PassengerFare>? passengerFares,
  }) {
    return V3FareEstimateResult(
      isEarlyBird: isEarlyBird ?? this.isEarlyBird,
      isJourneyInFreeTramZone:
          isJourneyInFreeTramZone ?? this.isJourneyInFreeTramZone,
      isThisWeekendJourney: isThisWeekendJourney ?? this.isThisWeekendJourney,
      zoneInfo: zoneInfo ?? this.zoneInfo,
      passengerFares: passengerFares ?? this.passengerFares,
    );
  }

  V3FareEstimateResult copyWithWrapped({
    Wrapped<bool?>? isEarlyBird,
    Wrapped<bool?>? isJourneyInFreeTramZone,
    Wrapped<bool?>? isThisWeekendJourney,
    Wrapped<V3ZoneInfo?>? zoneInfo,
    Wrapped<List<V3PassengerFare>?>? passengerFares,
  }) {
    return V3FareEstimateResult(
      isEarlyBird: (isEarlyBird != null ? isEarlyBird.value : this.isEarlyBird),
      isJourneyInFreeTramZone: (isJourneyInFreeTramZone != null
          ? isJourneyInFreeTramZone.value
          : this.isJourneyInFreeTramZone),
      isThisWeekendJourney: (isThisWeekendJourney != null
          ? isThisWeekendJourney.value
          : this.isThisWeekendJourney),
      zoneInfo: (zoneInfo != null ? zoneInfo.value : this.zoneInfo),
      passengerFares: (passengerFares != null
          ? passengerFares.value
          : this.passengerFares),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3ZoneInfo {
  const V3ZoneInfo({this.minZone, this.maxZone, this.uniqueZones});

  factory V3ZoneInfo.fromJson(Map<String, dynamic> json) =>
      _$V3ZoneInfoFromJson(json);

  static const toJsonFactory = _$V3ZoneInfoToJson;
  Map<String, dynamic> toJson() => _$V3ZoneInfoToJson(this);

  @JsonKey(name: 'MinZone')
  final int? minZone;
  @JsonKey(name: 'MaxZone')
  final int? maxZone;
  @JsonKey(name: 'UniqueZones', defaultValue: <int>[])
  final List<int>? uniqueZones;
  static const fromJsonFactory = _$V3ZoneInfoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3ZoneInfo &&
            (identical(other.minZone, minZone) ||
                const DeepCollectionEquality().equals(
                  other.minZone,
                  minZone,
                )) &&
            (identical(other.maxZone, maxZone) ||
                const DeepCollectionEquality().equals(
                  other.maxZone,
                  maxZone,
                )) &&
            (identical(other.uniqueZones, uniqueZones) ||
                const DeepCollectionEquality().equals(
                  other.uniqueZones,
                  uniqueZones,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(minZone) ^
      const DeepCollectionEquality().hash(maxZone) ^
      const DeepCollectionEquality().hash(uniqueZones) ^
      runtimeType.hashCode;
}

extension $V3ZoneInfoExtension on V3ZoneInfo {
  V3ZoneInfo copyWith({int? minZone, int? maxZone, List<int>? uniqueZones}) {
    return V3ZoneInfo(
      minZone: minZone ?? this.minZone,
      maxZone: maxZone ?? this.maxZone,
      uniqueZones: uniqueZones ?? this.uniqueZones,
    );
  }

  V3ZoneInfo copyWithWrapped({
    Wrapped<int?>? minZone,
    Wrapped<int?>? maxZone,
    Wrapped<List<int>?>? uniqueZones,
  }) {
    return V3ZoneInfo(
      minZone: (minZone != null ? minZone.value : this.minZone),
      maxZone: (maxZone != null ? maxZone.value : this.maxZone),
      uniqueZones: (uniqueZones != null ? uniqueZones.value : this.uniqueZones),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3PassengerFare {
  const V3PassengerFare({
    this.passengerType,
    this.fare2HourPeak,
    this.fare2HourOffPeak,
    this.fareDailyPeak,
    this.fareDailyOffPeak,
    this.pass7Days,
    this.pass28To69DayPerDay,
    this.pass70PlusDayPerDay,
    this.weekendCap,
    this.holidayCap,
  });

  factory V3PassengerFare.fromJson(Map<String, dynamic> json) =>
      _$V3PassengerFareFromJson(json);

  static const toJsonFactory = _$V3PassengerFareToJson;
  Map<String, dynamic> toJson() => _$V3PassengerFareToJson(this);

  @JsonKey(name: 'PassengerType')
  final String? passengerType;
  @JsonKey(name: 'Fare2HourPeak')
  final double? fare2HourPeak;
  @JsonKey(name: 'Fare2HourOffPeak')
  final double? fare2HourOffPeak;
  @JsonKey(name: 'FareDailyPeak')
  final double? fareDailyPeak;
  @JsonKey(name: 'FareDailyOffPeak')
  final double? fareDailyOffPeak;
  @JsonKey(name: 'Pass7Days')
  final double? pass7Days;
  @JsonKey(name: 'Pass28To69DayPerDay')
  final double? pass28To69DayPerDay;
  @JsonKey(name: 'Pass70PlusDayPerDay')
  final double? pass70PlusDayPerDay;
  @JsonKey(name: 'WeekendCap')
  final double? weekendCap;
  @JsonKey(name: 'HolidayCap')
  final double? holidayCap;
  static const fromJsonFactory = _$V3PassengerFareFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3PassengerFare &&
            (identical(other.passengerType, passengerType) ||
                const DeepCollectionEquality().equals(
                  other.passengerType,
                  passengerType,
                )) &&
            (identical(other.fare2HourPeak, fare2HourPeak) ||
                const DeepCollectionEquality().equals(
                  other.fare2HourPeak,
                  fare2HourPeak,
                )) &&
            (identical(other.fare2HourOffPeak, fare2HourOffPeak) ||
                const DeepCollectionEquality().equals(
                  other.fare2HourOffPeak,
                  fare2HourOffPeak,
                )) &&
            (identical(other.fareDailyPeak, fareDailyPeak) ||
                const DeepCollectionEquality().equals(
                  other.fareDailyPeak,
                  fareDailyPeak,
                )) &&
            (identical(other.fareDailyOffPeak, fareDailyOffPeak) ||
                const DeepCollectionEquality().equals(
                  other.fareDailyOffPeak,
                  fareDailyOffPeak,
                )) &&
            (identical(other.pass7Days, pass7Days) ||
                const DeepCollectionEquality().equals(
                  other.pass7Days,
                  pass7Days,
                )) &&
            (identical(other.pass28To69DayPerDay, pass28To69DayPerDay) ||
                const DeepCollectionEquality().equals(
                  other.pass28To69DayPerDay,
                  pass28To69DayPerDay,
                )) &&
            (identical(other.pass70PlusDayPerDay, pass70PlusDayPerDay) ||
                const DeepCollectionEquality().equals(
                  other.pass70PlusDayPerDay,
                  pass70PlusDayPerDay,
                )) &&
            (identical(other.weekendCap, weekendCap) ||
                const DeepCollectionEquality().equals(
                  other.weekendCap,
                  weekendCap,
                )) &&
            (identical(other.holidayCap, holidayCap) ||
                const DeepCollectionEquality().equals(
                  other.holidayCap,
                  holidayCap,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(passengerType) ^
      const DeepCollectionEquality().hash(fare2HourPeak) ^
      const DeepCollectionEquality().hash(fare2HourOffPeak) ^
      const DeepCollectionEquality().hash(fareDailyPeak) ^
      const DeepCollectionEquality().hash(fareDailyOffPeak) ^
      const DeepCollectionEquality().hash(pass7Days) ^
      const DeepCollectionEquality().hash(pass28To69DayPerDay) ^
      const DeepCollectionEquality().hash(pass70PlusDayPerDay) ^
      const DeepCollectionEquality().hash(weekendCap) ^
      const DeepCollectionEquality().hash(holidayCap) ^
      runtimeType.hashCode;
}

extension $V3PassengerFareExtension on V3PassengerFare {
  V3PassengerFare copyWith({
    String? passengerType,
    double? fare2HourPeak,
    double? fare2HourOffPeak,
    double? fareDailyPeak,
    double? fareDailyOffPeak,
    double? pass7Days,
    double? pass28To69DayPerDay,
    double? pass70PlusDayPerDay,
    double? weekendCap,
    double? holidayCap,
  }) {
    return V3PassengerFare(
      passengerType: passengerType ?? this.passengerType,
      fare2HourPeak: fare2HourPeak ?? this.fare2HourPeak,
      fare2HourOffPeak: fare2HourOffPeak ?? this.fare2HourOffPeak,
      fareDailyPeak: fareDailyPeak ?? this.fareDailyPeak,
      fareDailyOffPeak: fareDailyOffPeak ?? this.fareDailyOffPeak,
      pass7Days: pass7Days ?? this.pass7Days,
      pass28To69DayPerDay: pass28To69DayPerDay ?? this.pass28To69DayPerDay,
      pass70PlusDayPerDay: pass70PlusDayPerDay ?? this.pass70PlusDayPerDay,
      weekendCap: weekendCap ?? this.weekendCap,
      holidayCap: holidayCap ?? this.holidayCap,
    );
  }

  V3PassengerFare copyWithWrapped({
    Wrapped<String?>? passengerType,
    Wrapped<double?>? fare2HourPeak,
    Wrapped<double?>? fare2HourOffPeak,
    Wrapped<double?>? fareDailyPeak,
    Wrapped<double?>? fareDailyOffPeak,
    Wrapped<double?>? pass7Days,
    Wrapped<double?>? pass28To69DayPerDay,
    Wrapped<double?>? pass70PlusDayPerDay,
    Wrapped<double?>? weekendCap,
    Wrapped<double?>? holidayCap,
  }) {
    return V3PassengerFare(
      passengerType: (passengerType != null
          ? passengerType.value
          : this.passengerType),
      fare2HourPeak: (fare2HourPeak != null
          ? fare2HourPeak.value
          : this.fare2HourPeak),
      fare2HourOffPeak: (fare2HourOffPeak != null
          ? fare2HourOffPeak.value
          : this.fare2HourOffPeak),
      fareDailyPeak: (fareDailyPeak != null
          ? fareDailyPeak.value
          : this.fareDailyPeak),
      fareDailyOffPeak: (fareDailyOffPeak != null
          ? fareDailyOffPeak.value
          : this.fareDailyOffPeak),
      pass7Days: (pass7Days != null ? pass7Days.value : this.pass7Days),
      pass28To69DayPerDay: (pass28To69DayPerDay != null
          ? pass28To69DayPerDay.value
          : this.pass28To69DayPerDay),
      pass70PlusDayPerDay: (pass70PlusDayPerDay != null
          ? pass70PlusDayPerDay.value
          : this.pass70PlusDayPerDay),
      weekendCap: (weekendCap != null ? weekendCap.value : this.weekendCap),
      holidayCap: (holidayCap != null ? holidayCap.value : this.holidayCap),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3JourneyPlannerParameters {
  const V3JourneyPlannerParameters({
    this.timeUtc,
    this.departFrom,
    this.transferSpeed,
    this.transferMaxTime,
    this.transferMethod,
    this.inclTrain,
    this.inclTram,
    this.inclBus,
    this.inclVline,
    this.inclRegCoach,
    this.inclSkybus,
    this.routeType,
    this.inclPathCoords,
    this.inclFareEstimate,
    this.wheelchair,
    this.noSolidStairs,
    this.efaEngine,
    this.useRealtime,
  });

  factory V3JourneyPlannerParameters.fromJson(Map<String, dynamic> json) =>
      _$V3JourneyPlannerParametersFromJson(json);

  static const toJsonFactory = _$V3JourneyPlannerParametersToJson;
  Map<String, dynamic> toJson() => _$V3JourneyPlannerParametersToJson(this);

  @JsonKey(name: 'TimeUtc')
  final DateTime? timeUtc;
  @JsonKey(name: 'DepartFrom')
  final bool? departFrom;
  @JsonKey(name: 'TransferSpeed')
  final String? transferSpeed;
  @JsonKey(name: 'TransferMaxTime')
  final int? transferMaxTime;
  @JsonKey(name: 'TransferMethod')
  final String? transferMethod;
  @JsonKey(name: 'InclTrain')
  final bool? inclTrain;
  @JsonKey(name: 'InclTram')
  final bool? inclTram;
  @JsonKey(name: 'InclBus')
  final bool? inclBus;
  @JsonKey(name: 'InclVline')
  final bool? inclVline;
  @JsonKey(name: 'InclRegCoach')
  final bool? inclRegCoach;
  @JsonKey(name: 'InclSkybus')
  final bool? inclSkybus;
  @JsonKey(name: 'RouteType')
  final String? routeType;
  @JsonKey(name: 'InclPathCoords')
  final bool? inclPathCoords;
  @JsonKey(name: 'InclFareEstimate')
  final bool? inclFareEstimate;
  @JsonKey(name: 'Wheelchair')
  final bool? wheelchair;
  @JsonKey(name: 'NoSolidStairs')
  final bool? noSolidStairs;
  @JsonKey(name: 'EfaEngine')
  final String? efaEngine;
  @JsonKey(name: 'UseRealtime')
  final bool? useRealtime;
  static const fromJsonFactory = _$V3JourneyPlannerParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3JourneyPlannerParameters &&
            (identical(other.timeUtc, timeUtc) ||
                const DeepCollectionEquality().equals(
                  other.timeUtc,
                  timeUtc,
                )) &&
            (identical(other.departFrom, departFrom) ||
                const DeepCollectionEquality().equals(
                  other.departFrom,
                  departFrom,
                )) &&
            (identical(other.transferSpeed, transferSpeed) ||
                const DeepCollectionEquality().equals(
                  other.transferSpeed,
                  transferSpeed,
                )) &&
            (identical(other.transferMaxTime, transferMaxTime) ||
                const DeepCollectionEquality().equals(
                  other.transferMaxTime,
                  transferMaxTime,
                )) &&
            (identical(other.transferMethod, transferMethod) ||
                const DeepCollectionEquality().equals(
                  other.transferMethod,
                  transferMethod,
                )) &&
            (identical(other.inclTrain, inclTrain) ||
                const DeepCollectionEquality().equals(
                  other.inclTrain,
                  inclTrain,
                )) &&
            (identical(other.inclTram, inclTram) ||
                const DeepCollectionEquality().equals(
                  other.inclTram,
                  inclTram,
                )) &&
            (identical(other.inclBus, inclBus) ||
                const DeepCollectionEquality().equals(
                  other.inclBus,
                  inclBus,
                )) &&
            (identical(other.inclVline, inclVline) ||
                const DeepCollectionEquality().equals(
                  other.inclVline,
                  inclVline,
                )) &&
            (identical(other.inclRegCoach, inclRegCoach) ||
                const DeepCollectionEquality().equals(
                  other.inclRegCoach,
                  inclRegCoach,
                )) &&
            (identical(other.inclSkybus, inclSkybus) ||
                const DeepCollectionEquality().equals(
                  other.inclSkybus,
                  inclSkybus,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.inclPathCoords, inclPathCoords) ||
                const DeepCollectionEquality().equals(
                  other.inclPathCoords,
                  inclPathCoords,
                )) &&
            (identical(other.inclFareEstimate, inclFareEstimate) ||
                const DeepCollectionEquality().equals(
                  other.inclFareEstimate,
                  inclFareEstimate,
                )) &&
            (identical(other.wheelchair, wheelchair) ||
                const DeepCollectionEquality().equals(
                  other.wheelchair,
                  wheelchair,
                )) &&
            (identical(other.noSolidStairs, noSolidStairs) ||
                const DeepCollectionEquality().equals(
                  other.noSolidStairs,
                  noSolidStairs,
                )) &&
            (identical(other.efaEngine, efaEngine) ||
                const DeepCollectionEquality().equals(
                  other.efaEngine,
                  efaEngine,
                )) &&
            (identical(other.useRealtime, useRealtime) ||
                const DeepCollectionEquality().equals(
                  other.useRealtime,
                  useRealtime,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(timeUtc) ^
      const DeepCollectionEquality().hash(departFrom) ^
      const DeepCollectionEquality().hash(transferSpeed) ^
      const DeepCollectionEquality().hash(transferMaxTime) ^
      const DeepCollectionEquality().hash(transferMethod) ^
      const DeepCollectionEquality().hash(inclTrain) ^
      const DeepCollectionEquality().hash(inclTram) ^
      const DeepCollectionEquality().hash(inclBus) ^
      const DeepCollectionEquality().hash(inclVline) ^
      const DeepCollectionEquality().hash(inclRegCoach) ^
      const DeepCollectionEquality().hash(inclSkybus) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(inclPathCoords) ^
      const DeepCollectionEquality().hash(inclFareEstimate) ^
      const DeepCollectionEquality().hash(wheelchair) ^
      const DeepCollectionEquality().hash(noSolidStairs) ^
      const DeepCollectionEquality().hash(efaEngine) ^
      const DeepCollectionEquality().hash(useRealtime) ^
      runtimeType.hashCode;
}

extension $V3JourneyPlannerParametersExtension on V3JourneyPlannerParameters {
  V3JourneyPlannerParameters copyWith({
    DateTime? timeUtc,
    bool? departFrom,
    String? transferSpeed,
    int? transferMaxTime,
    String? transferMethod,
    bool? inclTrain,
    bool? inclTram,
    bool? inclBus,
    bool? inclVline,
    bool? inclRegCoach,
    bool? inclSkybus,
    String? routeType,
    bool? inclPathCoords,
    bool? inclFareEstimate,
    bool? wheelchair,
    bool? noSolidStairs,
    String? efaEngine,
    bool? useRealtime,
  }) {
    return V3JourneyPlannerParameters(
      timeUtc: timeUtc ?? this.timeUtc,
      departFrom: departFrom ?? this.departFrom,
      transferSpeed: transferSpeed ?? this.transferSpeed,
      transferMaxTime: transferMaxTime ?? this.transferMaxTime,
      transferMethod: transferMethod ?? this.transferMethod,
      inclTrain: inclTrain ?? this.inclTrain,
      inclTram: inclTram ?? this.inclTram,
      inclBus: inclBus ?? this.inclBus,
      inclVline: inclVline ?? this.inclVline,
      inclRegCoach: inclRegCoach ?? this.inclRegCoach,
      inclSkybus: inclSkybus ?? this.inclSkybus,
      routeType: routeType ?? this.routeType,
      inclPathCoords: inclPathCoords ?? this.inclPathCoords,
      inclFareEstimate: inclFareEstimate ?? this.inclFareEstimate,
      wheelchair: wheelchair ?? this.wheelchair,
      noSolidStairs: noSolidStairs ?? this.noSolidStairs,
      efaEngine: efaEngine ?? this.efaEngine,
      useRealtime: useRealtime ?? this.useRealtime,
    );
  }

  V3JourneyPlannerParameters copyWithWrapped({
    Wrapped<DateTime?>? timeUtc,
    Wrapped<bool?>? departFrom,
    Wrapped<String?>? transferSpeed,
    Wrapped<int?>? transferMaxTime,
    Wrapped<String?>? transferMethod,
    Wrapped<bool?>? inclTrain,
    Wrapped<bool?>? inclTram,
    Wrapped<bool?>? inclBus,
    Wrapped<bool?>? inclVline,
    Wrapped<bool?>? inclRegCoach,
    Wrapped<bool?>? inclSkybus,
    Wrapped<String?>? routeType,
    Wrapped<bool?>? inclPathCoords,
    Wrapped<bool?>? inclFareEstimate,
    Wrapped<bool?>? wheelchair,
    Wrapped<bool?>? noSolidStairs,
    Wrapped<String?>? efaEngine,
    Wrapped<bool?>? useRealtime,
  }) {
    return V3JourneyPlannerParameters(
      timeUtc: (timeUtc != null ? timeUtc.value : this.timeUtc),
      departFrom: (departFrom != null ? departFrom.value : this.departFrom),
      transferSpeed: (transferSpeed != null
          ? transferSpeed.value
          : this.transferSpeed),
      transferMaxTime: (transferMaxTime != null
          ? transferMaxTime.value
          : this.transferMaxTime),
      transferMethod: (transferMethod != null
          ? transferMethod.value
          : this.transferMethod),
      inclTrain: (inclTrain != null ? inclTrain.value : this.inclTrain),
      inclTram: (inclTram != null ? inclTram.value : this.inclTram),
      inclBus: (inclBus != null ? inclBus.value : this.inclBus),
      inclVline: (inclVline != null ? inclVline.value : this.inclVline),
      inclRegCoach: (inclRegCoach != null
          ? inclRegCoach.value
          : this.inclRegCoach),
      inclSkybus: (inclSkybus != null ? inclSkybus.value : this.inclSkybus),
      routeType: (routeType != null ? routeType.value : this.routeType),
      inclPathCoords: (inclPathCoords != null
          ? inclPathCoords.value
          : this.inclPathCoords),
      inclFareEstimate: (inclFareEstimate != null
          ? inclFareEstimate.value
          : this.inclFareEstimate),
      wheelchair: (wheelchair != null ? wheelchair.value : this.wheelchair),
      noSolidStairs: (noSolidStairs != null
          ? noSolidStairs.value
          : this.noSolidStairs),
      efaEngine: (efaEngine != null ? efaEngine.value : this.efaEngine),
      useRealtime: (useRealtime != null ? useRealtime.value : this.useRealtime),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3JourneyPlannerResponse {
  const V3JourneyPlannerResponse({this.journey, this.status});

  factory V3JourneyPlannerResponse.fromJson(Map<String, dynamic> json) =>
      _$V3JourneyPlannerResponseFromJson(json);

  static const toJsonFactory = _$V3JourneyPlannerResponseToJson;
  Map<String, dynamic> toJson() => _$V3JourneyPlannerResponseToJson(this);

  @JsonKey(name: 'Journey')
  final V3JourneyResponse? journey;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3JourneyPlannerResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3JourneyPlannerResponse &&
            (identical(other.journey, journey) ||
                const DeepCollectionEquality().equals(
                  other.journey,
                  journey,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(journey) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3JourneyPlannerResponseExtension on V3JourneyPlannerResponse {
  V3JourneyPlannerResponse copyWith({
    V3JourneyResponse? journey,
    V3Status? status,
  }) {
    return V3JourneyPlannerResponse(
      journey: journey ?? this.journey,
      status: status ?? this.status,
    );
  }

  V3JourneyPlannerResponse copyWithWrapped({
    Wrapped<V3JourneyResponse?>? journey,
    Wrapped<V3Status?>? status,
  }) {
    return V3JourneyPlannerResponse(
      journey: (journey != null ? journey.value : this.journey),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3JourneyResponse {
  const V3JourneyResponse({
    this.status,
    this.originOptions,
    this.destinationOptions,
    this.chronosLog,
    this.chronosTimings,
    this.chronosStart,
    this.itinerary,
    this.requestUrl,
  });

  factory V3JourneyResponse.fromJson(Map<String, dynamic> json) =>
      _$V3JourneyResponseFromJson(json);

  static const toJsonFactory = _$V3JourneyResponseToJson;
  Map<String, dynamic> toJson() => _$V3JourneyResponseToJson(this);

  @JsonKey(name: 'Status')
  final String? status;
  @JsonKey(name: 'OriginOptions', defaultValue: <V3LocationOption>[])
  final List<V3LocationOption>? originOptions;
  @JsonKey(name: 'DestinationOptions', defaultValue: <V3LocationOption>[])
  final List<V3LocationOption>? destinationOptions;
  @JsonKey(name: 'ChronosLog', defaultValue: <String>[])
  final List<String>? chronosLog;
  @JsonKey(name: 'ChronosTimings', defaultValue: <String>[])
  final List<String>? chronosTimings;
  @JsonKey(name: 'ChronosStart')
  final DateTime? chronosStart;
  @JsonKey(name: 'Itinerary', defaultValue: <V3Journey>[])
  final List<V3Journey>? itinerary;
  @JsonKey(name: 'RequestUrl')
  final String? requestUrl;
  static const fromJsonFactory = _$V3JourneyResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3JourneyResponse &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.originOptions, originOptions) ||
                const DeepCollectionEquality().equals(
                  other.originOptions,
                  originOptions,
                )) &&
            (identical(other.destinationOptions, destinationOptions) ||
                const DeepCollectionEquality().equals(
                  other.destinationOptions,
                  destinationOptions,
                )) &&
            (identical(other.chronosLog, chronosLog) ||
                const DeepCollectionEquality().equals(
                  other.chronosLog,
                  chronosLog,
                )) &&
            (identical(other.chronosTimings, chronosTimings) ||
                const DeepCollectionEquality().equals(
                  other.chronosTimings,
                  chronosTimings,
                )) &&
            (identical(other.chronosStart, chronosStart) ||
                const DeepCollectionEquality().equals(
                  other.chronosStart,
                  chronosStart,
                )) &&
            (identical(other.itinerary, itinerary) ||
                const DeepCollectionEquality().equals(
                  other.itinerary,
                  itinerary,
                )) &&
            (identical(other.requestUrl, requestUrl) ||
                const DeepCollectionEquality().equals(
                  other.requestUrl,
                  requestUrl,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(originOptions) ^
      const DeepCollectionEquality().hash(destinationOptions) ^
      const DeepCollectionEquality().hash(chronosLog) ^
      const DeepCollectionEquality().hash(chronosTimings) ^
      const DeepCollectionEquality().hash(chronosStart) ^
      const DeepCollectionEquality().hash(itinerary) ^
      const DeepCollectionEquality().hash(requestUrl) ^
      runtimeType.hashCode;
}

extension $V3JourneyResponseExtension on V3JourneyResponse {
  V3JourneyResponse copyWith({
    String? status,
    List<V3LocationOption>? originOptions,
    List<V3LocationOption>? destinationOptions,
    List<String>? chronosLog,
    List<String>? chronosTimings,
    DateTime? chronosStart,
    List<V3Journey>? itinerary,
    String? requestUrl,
  }) {
    return V3JourneyResponse(
      status: status ?? this.status,
      originOptions: originOptions ?? this.originOptions,
      destinationOptions: destinationOptions ?? this.destinationOptions,
      chronosLog: chronosLog ?? this.chronosLog,
      chronosTimings: chronosTimings ?? this.chronosTimings,
      chronosStart: chronosStart ?? this.chronosStart,
      itinerary: itinerary ?? this.itinerary,
      requestUrl: requestUrl ?? this.requestUrl,
    );
  }

  V3JourneyResponse copyWithWrapped({
    Wrapped<String?>? status,
    Wrapped<List<V3LocationOption>?>? originOptions,
    Wrapped<List<V3LocationOption>?>? destinationOptions,
    Wrapped<List<String>?>? chronosLog,
    Wrapped<List<String>?>? chronosTimings,
    Wrapped<DateTime?>? chronosStart,
    Wrapped<List<V3Journey>?>? itinerary,
    Wrapped<String?>? requestUrl,
  }) {
    return V3JourneyResponse(
      status: (status != null ? status.value : this.status),
      originOptions: (originOptions != null
          ? originOptions.value
          : this.originOptions),
      destinationOptions: (destinationOptions != null
          ? destinationOptions.value
          : this.destinationOptions),
      chronosLog: (chronosLog != null ? chronosLog.value : this.chronosLog),
      chronosTimings: (chronosTimings != null
          ? chronosTimings.value
          : this.chronosTimings),
      chronosStart: (chronosStart != null
          ? chronosStart.value
          : this.chronosStart),
      itinerary: (itinerary != null ? itinerary.value : this.itinerary),
      requestUrl: (requestUrl != null ? requestUrl.value : this.requestUrl),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3LocationOption {
  const V3LocationOption({this.name, this.url});

  factory V3LocationOption.fromJson(Map<String, dynamic> json) =>
      _$V3LocationOptionFromJson(json);

  static const toJsonFactory = _$V3LocationOptionToJson;
  Map<String, dynamic> toJson() => _$V3LocationOptionToJson(this);

  @JsonKey(name: 'Name')
  final String? name;
  @JsonKey(name: 'Url')
  final String? url;
  static const fromJsonFactory = _$V3LocationOptionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3LocationOption &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.url, url) ||
                const DeepCollectionEquality().equals(other.url, url)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(url) ^
      runtimeType.hashCode;
}

extension $V3LocationOptionExtension on V3LocationOption {
  V3LocationOption copyWith({String? name, String? url}) {
    return V3LocationOption(name: name ?? this.name, url: url ?? this.url);
  }

  V3LocationOption copyWithWrapped({
    Wrapped<String?>? name,
    Wrapped<String?>? url,
  }) {
    return V3LocationOption(
      name: (name != null ? name.value : this.name),
      url: (url != null ? url.value : this.url),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Journey {
  const V3Journey({
    this.timeDeparture,
    this.timeArrival,
    this.estimatedTimeDeparture,
    this.estimatedTimeArrival,
    this.chronosJourneyLog,
    this.realTimeMessage,
    this.timeDepartureStr,
    this.dateDepartureStr,
    this.timeArrivalStr,
    this.dateArrivalStr,
    this.durationMins,
    this.estimatedDurationMins,
    this.legs,
    this.zones,
    this.fareEstimate,
  });

  factory V3Journey.fromJson(Map<String, dynamic> json) =>
      _$V3JourneyFromJson(json);

  static const toJsonFactory = _$V3JourneyToJson;
  Map<String, dynamic> toJson() => _$V3JourneyToJson(this);

  @JsonKey(name: 'TimeDeparture')
  final DateTime? timeDeparture;
  @JsonKey(name: 'TimeArrival')
  final DateTime? timeArrival;
  @JsonKey(name: 'EstimatedTimeDeparture')
  final DateTime? estimatedTimeDeparture;
  @JsonKey(name: 'EstimatedTimeArrival')
  final DateTime? estimatedTimeArrival;
  @JsonKey(name: 'ChronosJourneyLog', defaultValue: <String>[])
  final List<String>? chronosJourneyLog;
  @JsonKey(name: 'RealTimeMessage')
  final String? realTimeMessage;
  @JsonKey(name: 'TimeDepartureStr')
  final String? timeDepartureStr;
  @JsonKey(name: 'DateDepartureStr')
  final String? dateDepartureStr;
  @JsonKey(name: 'TimeArrivalStr')
  final String? timeArrivalStr;
  @JsonKey(name: 'DateArrivalStr')
  final String? dateArrivalStr;
  @JsonKey(name: 'DurationMins')
  final int? durationMins;
  @JsonKey(name: 'EstimatedDurationMins')
  final int? estimatedDurationMins;
  @JsonKey(name: 'Legs', defaultValue: <V3JourneyLeg>[])
  final List<V3JourneyLeg>? legs;
  @JsonKey(name: 'Zones', defaultValue: <String>[])
  final List<String>? zones;
  @JsonKey(name: 'FareEstimate')
  final V3FareEstimateResponse? fareEstimate;
  static const fromJsonFactory = _$V3JourneyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Journey &&
            (identical(other.timeDeparture, timeDeparture) ||
                const DeepCollectionEquality().equals(
                  other.timeDeparture,
                  timeDeparture,
                )) &&
            (identical(other.timeArrival, timeArrival) ||
                const DeepCollectionEquality().equals(
                  other.timeArrival,
                  timeArrival,
                )) &&
            (identical(other.estimatedTimeDeparture, estimatedTimeDeparture) ||
                const DeepCollectionEquality().equals(
                  other.estimatedTimeDeparture,
                  estimatedTimeDeparture,
                )) &&
            (identical(other.estimatedTimeArrival, estimatedTimeArrival) ||
                const DeepCollectionEquality().equals(
                  other.estimatedTimeArrival,
                  estimatedTimeArrival,
                )) &&
            (identical(other.chronosJourneyLog, chronosJourneyLog) ||
                const DeepCollectionEquality().equals(
                  other.chronosJourneyLog,
                  chronosJourneyLog,
                )) &&
            (identical(other.realTimeMessage, realTimeMessage) ||
                const DeepCollectionEquality().equals(
                  other.realTimeMessage,
                  realTimeMessage,
                )) &&
            (identical(other.timeDepartureStr, timeDepartureStr) ||
                const DeepCollectionEquality().equals(
                  other.timeDepartureStr,
                  timeDepartureStr,
                )) &&
            (identical(other.dateDepartureStr, dateDepartureStr) ||
                const DeepCollectionEquality().equals(
                  other.dateDepartureStr,
                  dateDepartureStr,
                )) &&
            (identical(other.timeArrivalStr, timeArrivalStr) ||
                const DeepCollectionEquality().equals(
                  other.timeArrivalStr,
                  timeArrivalStr,
                )) &&
            (identical(other.dateArrivalStr, dateArrivalStr) ||
                const DeepCollectionEquality().equals(
                  other.dateArrivalStr,
                  dateArrivalStr,
                )) &&
            (identical(other.durationMins, durationMins) ||
                const DeepCollectionEquality().equals(
                  other.durationMins,
                  durationMins,
                )) &&
            (identical(other.estimatedDurationMins, estimatedDurationMins) ||
                const DeepCollectionEquality().equals(
                  other.estimatedDurationMins,
                  estimatedDurationMins,
                )) &&
            (identical(other.legs, legs) ||
                const DeepCollectionEquality().equals(other.legs, legs)) &&
            (identical(other.zones, zones) ||
                const DeepCollectionEquality().equals(other.zones, zones)) &&
            (identical(other.fareEstimate, fareEstimate) ||
                const DeepCollectionEquality().equals(
                  other.fareEstimate,
                  fareEstimate,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(timeDeparture) ^
      const DeepCollectionEquality().hash(timeArrival) ^
      const DeepCollectionEquality().hash(estimatedTimeDeparture) ^
      const DeepCollectionEquality().hash(estimatedTimeArrival) ^
      const DeepCollectionEquality().hash(chronosJourneyLog) ^
      const DeepCollectionEquality().hash(realTimeMessage) ^
      const DeepCollectionEquality().hash(timeDepartureStr) ^
      const DeepCollectionEquality().hash(dateDepartureStr) ^
      const DeepCollectionEquality().hash(timeArrivalStr) ^
      const DeepCollectionEquality().hash(dateArrivalStr) ^
      const DeepCollectionEquality().hash(durationMins) ^
      const DeepCollectionEquality().hash(estimatedDurationMins) ^
      const DeepCollectionEquality().hash(legs) ^
      const DeepCollectionEquality().hash(zones) ^
      const DeepCollectionEquality().hash(fareEstimate) ^
      runtimeType.hashCode;
}

extension $V3JourneyExtension on V3Journey {
  V3Journey copyWith({
    DateTime? timeDeparture,
    DateTime? timeArrival,
    DateTime? estimatedTimeDeparture,
    DateTime? estimatedTimeArrival,
    List<String>? chronosJourneyLog,
    String? realTimeMessage,
    String? timeDepartureStr,
    String? dateDepartureStr,
    String? timeArrivalStr,
    String? dateArrivalStr,
    int? durationMins,
    int? estimatedDurationMins,
    List<V3JourneyLeg>? legs,
    List<String>? zones,
    V3FareEstimateResponse? fareEstimate,
  }) {
    return V3Journey(
      timeDeparture: timeDeparture ?? this.timeDeparture,
      timeArrival: timeArrival ?? this.timeArrival,
      estimatedTimeDeparture:
          estimatedTimeDeparture ?? this.estimatedTimeDeparture,
      estimatedTimeArrival: estimatedTimeArrival ?? this.estimatedTimeArrival,
      chronosJourneyLog: chronosJourneyLog ?? this.chronosJourneyLog,
      realTimeMessage: realTimeMessage ?? this.realTimeMessage,
      timeDepartureStr: timeDepartureStr ?? this.timeDepartureStr,
      dateDepartureStr: dateDepartureStr ?? this.dateDepartureStr,
      timeArrivalStr: timeArrivalStr ?? this.timeArrivalStr,
      dateArrivalStr: dateArrivalStr ?? this.dateArrivalStr,
      durationMins: durationMins ?? this.durationMins,
      estimatedDurationMins:
          estimatedDurationMins ?? this.estimatedDurationMins,
      legs: legs ?? this.legs,
      zones: zones ?? this.zones,
      fareEstimate: fareEstimate ?? this.fareEstimate,
    );
  }

  V3Journey copyWithWrapped({
    Wrapped<DateTime?>? timeDeparture,
    Wrapped<DateTime?>? timeArrival,
    Wrapped<DateTime?>? estimatedTimeDeparture,
    Wrapped<DateTime?>? estimatedTimeArrival,
    Wrapped<List<String>?>? chronosJourneyLog,
    Wrapped<String?>? realTimeMessage,
    Wrapped<String?>? timeDepartureStr,
    Wrapped<String?>? dateDepartureStr,
    Wrapped<String?>? timeArrivalStr,
    Wrapped<String?>? dateArrivalStr,
    Wrapped<int?>? durationMins,
    Wrapped<int?>? estimatedDurationMins,
    Wrapped<List<V3JourneyLeg>?>? legs,
    Wrapped<List<String>?>? zones,
    Wrapped<V3FareEstimateResponse?>? fareEstimate,
  }) {
    return V3Journey(
      timeDeparture: (timeDeparture != null
          ? timeDeparture.value
          : this.timeDeparture),
      timeArrival: (timeArrival != null ? timeArrival.value : this.timeArrival),
      estimatedTimeDeparture: (estimatedTimeDeparture != null
          ? estimatedTimeDeparture.value
          : this.estimatedTimeDeparture),
      estimatedTimeArrival: (estimatedTimeArrival != null
          ? estimatedTimeArrival.value
          : this.estimatedTimeArrival),
      chronosJourneyLog: (chronosJourneyLog != null
          ? chronosJourneyLog.value
          : this.chronosJourneyLog),
      realTimeMessage: (realTimeMessage != null
          ? realTimeMessage.value
          : this.realTimeMessage),
      timeDepartureStr: (timeDepartureStr != null
          ? timeDepartureStr.value
          : this.timeDepartureStr),
      dateDepartureStr: (dateDepartureStr != null
          ? dateDepartureStr.value
          : this.dateDepartureStr),
      timeArrivalStr: (timeArrivalStr != null
          ? timeArrivalStr.value
          : this.timeArrivalStr),
      dateArrivalStr: (dateArrivalStr != null
          ? dateArrivalStr.value
          : this.dateArrivalStr),
      durationMins: (durationMins != null
          ? durationMins.value
          : this.durationMins),
      estimatedDurationMins: (estimatedDurationMins != null
          ? estimatedDurationMins.value
          : this.estimatedDurationMins),
      legs: (legs != null ? legs.value : this.legs),
      zones: (zones != null ? zones.value : this.zones),
      fareEstimate: (fareEstimate != null
          ? fareEstimate.value
          : this.fareEstimate),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3JourneyLeg {
  const V3JourneyLeg({
    this.type,
    this.lineName,
    this.directionName,
    this.operatedBy,
    this.alternateLines,
    this.sequence,
    this.lineId,
    this.directionCode,
    this.directionId,
    this.direction,
    this.timeDeparture,
    this.timeArrival,
    this.estimatedTimeDeparture,
    this.estimatedTimeArrival,
    this.timeRealtime,
    this.instructions,
    this.instructionDetails,
    this.information,
    this.zones,
    this.timeDepartureStr,
    this.dateDepartureStr,
    this.timeArrivalStr,
    this.dateArrivalStr,
    this.stopDeparture,
    this.stopArrival,
    this.stoppingPattern,
    this.isRealtime,
    this.disruptions,
    this.pathCoordinates,
    this.planLowFloorVehicle,
    this.planWheelChairAccess,
    this.realtimeStatus,
  });

  factory V3JourneyLeg.fromJson(Map<String, dynamic> json) =>
      _$V3JourneyLegFromJson(json);

  static const toJsonFactory = _$V3JourneyLegToJson;
  Map<String, dynamic> toJson() => _$V3JourneyLegToJson(this);

  @JsonKey(name: 'Type')
  final String? type;
  @JsonKey(name: 'LineName')
  final String? lineName;
  @JsonKey(name: 'DirectionName')
  final String? directionName;
  @JsonKey(name: 'OperatedBy')
  final String? operatedBy;
  @JsonKey(name: 'AlternateLines', defaultValue: <String>[])
  final List<String>? alternateLines;
  @JsonKey(name: 'Sequence')
  final int? sequence;
  @JsonKey(name: 'LineId')
  final String? lineId;
  @JsonKey(name: 'DirectionCode')
  final String? directionCode;
  @JsonKey(name: 'DirectionId')
  final String? directionId;
  @JsonKey(name: 'Direction')
  final V3Direction? direction;
  @JsonKey(name: 'TimeDeparture')
  final DateTime? timeDeparture;
  @JsonKey(name: 'TimeArrival')
  final DateTime? timeArrival;
  @JsonKey(name: 'EstimatedTimeDeparture')
  final DateTime? estimatedTimeDeparture;
  @JsonKey(name: 'EstimatedTimeArrival')
  final DateTime? estimatedTimeArrival;
  @JsonKey(name: 'TimeRealtime')
  final DateTime? timeRealtime;
  @JsonKey(name: 'Instructions')
  final String? instructions;
  @JsonKey(name: 'InstructionDetails', defaultValue: <V3LegDirection>[])
  final List<V3LegDirection>? instructionDetails;
  @JsonKey(name: 'Information', defaultValue: <String>[])
  final List<String>? information;
  @JsonKey(name: 'Zones', defaultValue: <String>[])
  final List<String>? zones;
  @JsonKey(name: 'TimeDepartureStr')
  final String? timeDepartureStr;
  @JsonKey(name: 'DateDepartureStr')
  final String? dateDepartureStr;
  @JsonKey(name: 'TimeArrivalStr')
  final String? timeArrivalStr;
  @JsonKey(name: 'DateArrivalStr')
  final String? dateArrivalStr;
  @JsonKey(name: 'StopDeparture')
  final V3JourneyPlannerLocation? stopDeparture;
  @JsonKey(name: 'StopArrival')
  final V3JourneyPlannerLocation? stopArrival;
  @JsonKey(name: 'StoppingPattern', defaultValue: <V3JourneyPlannerStop>[])
  final List<V3JourneyPlannerStop>? stoppingPattern;
  @JsonKey(name: 'IsRealtime')
  final bool? isRealtime;
  @JsonKey(name: 'Disruptions', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? disruptions;
  @JsonKey(
    name: 'PathCoordinates',
    defaultValue: <V3JourneyLegPathCoordinate>[],
  )
  final List<V3JourneyLegPathCoordinate>? pathCoordinates;
  @JsonKey(name: 'PlanLowFloorVehicle')
  final String? planLowFloorVehicle;
  @JsonKey(name: 'PlanWheelChairAccess')
  final String? planWheelChairAccess;
  @JsonKey(name: 'RealtimeStatus', defaultValue: <String>[])
  final List<String>? realtimeStatus;
  static const fromJsonFactory = _$V3JourneyLegFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3JourneyLeg &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.lineName, lineName) ||
                const DeepCollectionEquality().equals(
                  other.lineName,
                  lineName,
                )) &&
            (identical(other.directionName, directionName) ||
                const DeepCollectionEquality().equals(
                  other.directionName,
                  directionName,
                )) &&
            (identical(other.operatedBy, operatedBy) ||
                const DeepCollectionEquality().equals(
                  other.operatedBy,
                  operatedBy,
                )) &&
            (identical(other.alternateLines, alternateLines) ||
                const DeepCollectionEquality().equals(
                  other.alternateLines,
                  alternateLines,
                )) &&
            (identical(other.sequence, sequence) ||
                const DeepCollectionEquality().equals(
                  other.sequence,
                  sequence,
                )) &&
            (identical(other.lineId, lineId) ||
                const DeepCollectionEquality().equals(other.lineId, lineId)) &&
            (identical(other.directionCode, directionCode) ||
                const DeepCollectionEquality().equals(
                  other.directionCode,
                  directionCode,
                )) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.direction, direction) ||
                const DeepCollectionEquality().equals(
                  other.direction,
                  direction,
                )) &&
            (identical(other.timeDeparture, timeDeparture) ||
                const DeepCollectionEquality().equals(
                  other.timeDeparture,
                  timeDeparture,
                )) &&
            (identical(other.timeArrival, timeArrival) ||
                const DeepCollectionEquality().equals(
                  other.timeArrival,
                  timeArrival,
                )) &&
            (identical(other.estimatedTimeDeparture, estimatedTimeDeparture) ||
                const DeepCollectionEquality().equals(
                  other.estimatedTimeDeparture,
                  estimatedTimeDeparture,
                )) &&
            (identical(other.estimatedTimeArrival, estimatedTimeArrival) ||
                const DeepCollectionEquality().equals(
                  other.estimatedTimeArrival,
                  estimatedTimeArrival,
                )) &&
            (identical(other.timeRealtime, timeRealtime) ||
                const DeepCollectionEquality().equals(
                  other.timeRealtime,
                  timeRealtime,
                )) &&
            (identical(other.instructions, instructions) ||
                const DeepCollectionEquality().equals(
                  other.instructions,
                  instructions,
                )) &&
            (identical(other.instructionDetails, instructionDetails) ||
                const DeepCollectionEquality().equals(
                  other.instructionDetails,
                  instructionDetails,
                )) &&
            (identical(other.information, information) ||
                const DeepCollectionEquality().equals(
                  other.information,
                  information,
                )) &&
            (identical(other.zones, zones) ||
                const DeepCollectionEquality().equals(other.zones, zones)) &&
            (identical(other.timeDepartureStr, timeDepartureStr) ||
                const DeepCollectionEquality().equals(
                  other.timeDepartureStr,
                  timeDepartureStr,
                )) &&
            (identical(other.dateDepartureStr, dateDepartureStr) ||
                const DeepCollectionEquality().equals(
                  other.dateDepartureStr,
                  dateDepartureStr,
                )) &&
            (identical(other.timeArrivalStr, timeArrivalStr) ||
                const DeepCollectionEquality().equals(
                  other.timeArrivalStr,
                  timeArrivalStr,
                )) &&
            (identical(other.dateArrivalStr, dateArrivalStr) ||
                const DeepCollectionEquality().equals(
                  other.dateArrivalStr,
                  dateArrivalStr,
                )) &&
            (identical(other.stopDeparture, stopDeparture) ||
                const DeepCollectionEquality().equals(
                  other.stopDeparture,
                  stopDeparture,
                )) &&
            (identical(other.stopArrival, stopArrival) ||
                const DeepCollectionEquality().equals(
                  other.stopArrival,
                  stopArrival,
                )) &&
            (identical(other.stoppingPattern, stoppingPattern) ||
                const DeepCollectionEquality().equals(
                  other.stoppingPattern,
                  stoppingPattern,
                )) &&
            (identical(other.isRealtime, isRealtime) ||
                const DeepCollectionEquality().equals(
                  other.isRealtime,
                  isRealtime,
                )) &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.pathCoordinates, pathCoordinates) ||
                const DeepCollectionEquality().equals(
                  other.pathCoordinates,
                  pathCoordinates,
                )) &&
            (identical(other.planLowFloorVehicle, planLowFloorVehicle) ||
                const DeepCollectionEquality().equals(
                  other.planLowFloorVehicle,
                  planLowFloorVehicle,
                )) &&
            (identical(other.planWheelChairAccess, planWheelChairAccess) ||
                const DeepCollectionEquality().equals(
                  other.planWheelChairAccess,
                  planWheelChairAccess,
                )) &&
            (identical(other.realtimeStatus, realtimeStatus) ||
                const DeepCollectionEquality().equals(
                  other.realtimeStatus,
                  realtimeStatus,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(lineName) ^
      const DeepCollectionEquality().hash(directionName) ^
      const DeepCollectionEquality().hash(operatedBy) ^
      const DeepCollectionEquality().hash(alternateLines) ^
      const DeepCollectionEquality().hash(sequence) ^
      const DeepCollectionEquality().hash(lineId) ^
      const DeepCollectionEquality().hash(directionCode) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(direction) ^
      const DeepCollectionEquality().hash(timeDeparture) ^
      const DeepCollectionEquality().hash(timeArrival) ^
      const DeepCollectionEquality().hash(estimatedTimeDeparture) ^
      const DeepCollectionEquality().hash(estimatedTimeArrival) ^
      const DeepCollectionEquality().hash(timeRealtime) ^
      const DeepCollectionEquality().hash(instructions) ^
      const DeepCollectionEquality().hash(instructionDetails) ^
      const DeepCollectionEquality().hash(information) ^
      const DeepCollectionEquality().hash(zones) ^
      const DeepCollectionEquality().hash(timeDepartureStr) ^
      const DeepCollectionEquality().hash(dateDepartureStr) ^
      const DeepCollectionEquality().hash(timeArrivalStr) ^
      const DeepCollectionEquality().hash(dateArrivalStr) ^
      const DeepCollectionEquality().hash(stopDeparture) ^
      const DeepCollectionEquality().hash(stopArrival) ^
      const DeepCollectionEquality().hash(stoppingPattern) ^
      const DeepCollectionEquality().hash(isRealtime) ^
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(pathCoordinates) ^
      const DeepCollectionEquality().hash(planLowFloorVehicle) ^
      const DeepCollectionEquality().hash(planWheelChairAccess) ^
      const DeepCollectionEquality().hash(realtimeStatus) ^
      runtimeType.hashCode;
}

extension $V3JourneyLegExtension on V3JourneyLeg {
  V3JourneyLeg copyWith({
    String? type,
    String? lineName,
    String? directionName,
    String? operatedBy,
    List<String>? alternateLines,
    int? sequence,
    String? lineId,
    String? directionCode,
    String? directionId,
    V3Direction? direction,
    DateTime? timeDeparture,
    DateTime? timeArrival,
    DateTime? estimatedTimeDeparture,
    DateTime? estimatedTimeArrival,
    DateTime? timeRealtime,
    String? instructions,
    List<V3LegDirection>? instructionDetails,
    List<String>? information,
    List<String>? zones,
    String? timeDepartureStr,
    String? dateDepartureStr,
    String? timeArrivalStr,
    String? dateArrivalStr,
    V3JourneyPlannerLocation? stopDeparture,
    V3JourneyPlannerLocation? stopArrival,
    List<V3JourneyPlannerStop>? stoppingPattern,
    bool? isRealtime,
    List<V3Disruption>? disruptions,
    List<V3JourneyLegPathCoordinate>? pathCoordinates,
    String? planLowFloorVehicle,
    String? planWheelChairAccess,
    List<String>? realtimeStatus,
  }) {
    return V3JourneyLeg(
      type: type ?? this.type,
      lineName: lineName ?? this.lineName,
      directionName: directionName ?? this.directionName,
      operatedBy: operatedBy ?? this.operatedBy,
      alternateLines: alternateLines ?? this.alternateLines,
      sequence: sequence ?? this.sequence,
      lineId: lineId ?? this.lineId,
      directionCode: directionCode ?? this.directionCode,
      directionId: directionId ?? this.directionId,
      direction: direction ?? this.direction,
      timeDeparture: timeDeparture ?? this.timeDeparture,
      timeArrival: timeArrival ?? this.timeArrival,
      estimatedTimeDeparture:
          estimatedTimeDeparture ?? this.estimatedTimeDeparture,
      estimatedTimeArrival: estimatedTimeArrival ?? this.estimatedTimeArrival,
      timeRealtime: timeRealtime ?? this.timeRealtime,
      instructions: instructions ?? this.instructions,
      instructionDetails: instructionDetails ?? this.instructionDetails,
      information: information ?? this.information,
      zones: zones ?? this.zones,
      timeDepartureStr: timeDepartureStr ?? this.timeDepartureStr,
      dateDepartureStr: dateDepartureStr ?? this.dateDepartureStr,
      timeArrivalStr: timeArrivalStr ?? this.timeArrivalStr,
      dateArrivalStr: dateArrivalStr ?? this.dateArrivalStr,
      stopDeparture: stopDeparture ?? this.stopDeparture,
      stopArrival: stopArrival ?? this.stopArrival,
      stoppingPattern: stoppingPattern ?? this.stoppingPattern,
      isRealtime: isRealtime ?? this.isRealtime,
      disruptions: disruptions ?? this.disruptions,
      pathCoordinates: pathCoordinates ?? this.pathCoordinates,
      planLowFloorVehicle: planLowFloorVehicle ?? this.planLowFloorVehicle,
      planWheelChairAccess: planWheelChairAccess ?? this.planWheelChairAccess,
      realtimeStatus: realtimeStatus ?? this.realtimeStatus,
    );
  }

  V3JourneyLeg copyWithWrapped({
    Wrapped<String?>? type,
    Wrapped<String?>? lineName,
    Wrapped<String?>? directionName,
    Wrapped<String?>? operatedBy,
    Wrapped<List<String>?>? alternateLines,
    Wrapped<int?>? sequence,
    Wrapped<String?>? lineId,
    Wrapped<String?>? directionCode,
    Wrapped<String?>? directionId,
    Wrapped<V3Direction?>? direction,
    Wrapped<DateTime?>? timeDeparture,
    Wrapped<DateTime?>? timeArrival,
    Wrapped<DateTime?>? estimatedTimeDeparture,
    Wrapped<DateTime?>? estimatedTimeArrival,
    Wrapped<DateTime?>? timeRealtime,
    Wrapped<String?>? instructions,
    Wrapped<List<V3LegDirection>?>? instructionDetails,
    Wrapped<List<String>?>? information,
    Wrapped<List<String>?>? zones,
    Wrapped<String?>? timeDepartureStr,
    Wrapped<String?>? dateDepartureStr,
    Wrapped<String?>? timeArrivalStr,
    Wrapped<String?>? dateArrivalStr,
    Wrapped<V3JourneyPlannerLocation?>? stopDeparture,
    Wrapped<V3JourneyPlannerLocation?>? stopArrival,
    Wrapped<List<V3JourneyPlannerStop>?>? stoppingPattern,
    Wrapped<bool?>? isRealtime,
    Wrapped<List<V3Disruption>?>? disruptions,
    Wrapped<List<V3JourneyLegPathCoordinate>?>? pathCoordinates,
    Wrapped<String?>? planLowFloorVehicle,
    Wrapped<String?>? planWheelChairAccess,
    Wrapped<List<String>?>? realtimeStatus,
  }) {
    return V3JourneyLeg(
      type: (type != null ? type.value : this.type),
      lineName: (lineName != null ? lineName.value : this.lineName),
      directionName: (directionName != null
          ? directionName.value
          : this.directionName),
      operatedBy: (operatedBy != null ? operatedBy.value : this.operatedBy),
      alternateLines: (alternateLines != null
          ? alternateLines.value
          : this.alternateLines),
      sequence: (sequence != null ? sequence.value : this.sequence),
      lineId: (lineId != null ? lineId.value : this.lineId),
      directionCode: (directionCode != null
          ? directionCode.value
          : this.directionCode),
      directionId: (directionId != null ? directionId.value : this.directionId),
      direction: (direction != null ? direction.value : this.direction),
      timeDeparture: (timeDeparture != null
          ? timeDeparture.value
          : this.timeDeparture),
      timeArrival: (timeArrival != null ? timeArrival.value : this.timeArrival),
      estimatedTimeDeparture: (estimatedTimeDeparture != null
          ? estimatedTimeDeparture.value
          : this.estimatedTimeDeparture),
      estimatedTimeArrival: (estimatedTimeArrival != null
          ? estimatedTimeArrival.value
          : this.estimatedTimeArrival),
      timeRealtime: (timeRealtime != null
          ? timeRealtime.value
          : this.timeRealtime),
      instructions: (instructions != null
          ? instructions.value
          : this.instructions),
      instructionDetails: (instructionDetails != null
          ? instructionDetails.value
          : this.instructionDetails),
      information: (information != null ? information.value : this.information),
      zones: (zones != null ? zones.value : this.zones),
      timeDepartureStr: (timeDepartureStr != null
          ? timeDepartureStr.value
          : this.timeDepartureStr),
      dateDepartureStr: (dateDepartureStr != null
          ? dateDepartureStr.value
          : this.dateDepartureStr),
      timeArrivalStr: (timeArrivalStr != null
          ? timeArrivalStr.value
          : this.timeArrivalStr),
      dateArrivalStr: (dateArrivalStr != null
          ? dateArrivalStr.value
          : this.dateArrivalStr),
      stopDeparture: (stopDeparture != null
          ? stopDeparture.value
          : this.stopDeparture),
      stopArrival: (stopArrival != null ? stopArrival.value : this.stopArrival),
      stoppingPattern: (stoppingPattern != null
          ? stoppingPattern.value
          : this.stoppingPattern),
      isRealtime: (isRealtime != null ? isRealtime.value : this.isRealtime),
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      pathCoordinates: (pathCoordinates != null
          ? pathCoordinates.value
          : this.pathCoordinates),
      planLowFloorVehicle: (planLowFloorVehicle != null
          ? planLowFloorVehicle.value
          : this.planLowFloorVehicle),
      planWheelChairAccess: (planWheelChairAccess != null
          ? planWheelChairAccess.value
          : this.planWheelChairAccess),
      realtimeStatus: (realtimeStatus != null
          ? realtimeStatus.value
          : this.realtimeStatus),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3LegDirection {
  const V3LegDirection({
    this.turnDirection,
    this.turningManoeuvre,
    this.lon,
    this.lat,
    this.streetName,
    this.fromPathLinkIdx,
    this.toPathLinkIdx,
    this.skyDirection,
    this.travelTime,
    this.cumTravelTime,
    this.distance,
    this.cumDistance,
  });

  factory V3LegDirection.fromJson(Map<String, dynamic> json) =>
      _$V3LegDirectionFromJson(json);

  static const toJsonFactory = _$V3LegDirectionToJson;
  Map<String, dynamic> toJson() => _$V3LegDirectionToJson(this);

  @JsonKey(name: 'TurnDirection')
  final String? turnDirection;
  @JsonKey(name: 'TurningManoeuvre')
  final String? turningManoeuvre;
  @JsonKey(name: 'Lon')
  final double? lon;
  @JsonKey(name: 'Lat')
  final double? lat;
  @JsonKey(name: 'StreetName')
  final String? streetName;
  @JsonKey(name: 'FromPathLinkIdx')
  final String? fromPathLinkIdx;
  @JsonKey(name: 'ToPathLinkIdx')
  final String? toPathLinkIdx;
  @JsonKey(name: 'SkyDirection')
  final String? skyDirection;
  @JsonKey(name: 'TravelTime')
  final int? travelTime;
  @JsonKey(name: 'CumTravelTime')
  final int? cumTravelTime;
  @JsonKey(name: 'Distance')
  final int? distance;
  @JsonKey(name: 'CumDistance')
  final int? cumDistance;
  static const fromJsonFactory = _$V3LegDirectionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3LegDirection &&
            (identical(other.turnDirection, turnDirection) ||
                const DeepCollectionEquality().equals(
                  other.turnDirection,
                  turnDirection,
                )) &&
            (identical(other.turningManoeuvre, turningManoeuvre) ||
                const DeepCollectionEquality().equals(
                  other.turningManoeuvre,
                  turningManoeuvre,
                )) &&
            (identical(other.lon, lon) ||
                const DeepCollectionEquality().equals(other.lon, lon)) &&
            (identical(other.lat, lat) ||
                const DeepCollectionEquality().equals(other.lat, lat)) &&
            (identical(other.streetName, streetName) ||
                const DeepCollectionEquality().equals(
                  other.streetName,
                  streetName,
                )) &&
            (identical(other.fromPathLinkIdx, fromPathLinkIdx) ||
                const DeepCollectionEquality().equals(
                  other.fromPathLinkIdx,
                  fromPathLinkIdx,
                )) &&
            (identical(other.toPathLinkIdx, toPathLinkIdx) ||
                const DeepCollectionEquality().equals(
                  other.toPathLinkIdx,
                  toPathLinkIdx,
                )) &&
            (identical(other.skyDirection, skyDirection) ||
                const DeepCollectionEquality().equals(
                  other.skyDirection,
                  skyDirection,
                )) &&
            (identical(other.travelTime, travelTime) ||
                const DeepCollectionEquality().equals(
                  other.travelTime,
                  travelTime,
                )) &&
            (identical(other.cumTravelTime, cumTravelTime) ||
                const DeepCollectionEquality().equals(
                  other.cumTravelTime,
                  cumTravelTime,
                )) &&
            (identical(other.distance, distance) ||
                const DeepCollectionEquality().equals(
                  other.distance,
                  distance,
                )) &&
            (identical(other.cumDistance, cumDistance) ||
                const DeepCollectionEquality().equals(
                  other.cumDistance,
                  cumDistance,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(turnDirection) ^
      const DeepCollectionEquality().hash(turningManoeuvre) ^
      const DeepCollectionEquality().hash(lon) ^
      const DeepCollectionEquality().hash(lat) ^
      const DeepCollectionEquality().hash(streetName) ^
      const DeepCollectionEquality().hash(fromPathLinkIdx) ^
      const DeepCollectionEquality().hash(toPathLinkIdx) ^
      const DeepCollectionEquality().hash(skyDirection) ^
      const DeepCollectionEquality().hash(travelTime) ^
      const DeepCollectionEquality().hash(cumTravelTime) ^
      const DeepCollectionEquality().hash(distance) ^
      const DeepCollectionEquality().hash(cumDistance) ^
      runtimeType.hashCode;
}

extension $V3LegDirectionExtension on V3LegDirection {
  V3LegDirection copyWith({
    String? turnDirection,
    String? turningManoeuvre,
    double? lon,
    double? lat,
    String? streetName,
    String? fromPathLinkIdx,
    String? toPathLinkIdx,
    String? skyDirection,
    int? travelTime,
    int? cumTravelTime,
    int? distance,
    int? cumDistance,
  }) {
    return V3LegDirection(
      turnDirection: turnDirection ?? this.turnDirection,
      turningManoeuvre: turningManoeuvre ?? this.turningManoeuvre,
      lon: lon ?? this.lon,
      lat: lat ?? this.lat,
      streetName: streetName ?? this.streetName,
      fromPathLinkIdx: fromPathLinkIdx ?? this.fromPathLinkIdx,
      toPathLinkIdx: toPathLinkIdx ?? this.toPathLinkIdx,
      skyDirection: skyDirection ?? this.skyDirection,
      travelTime: travelTime ?? this.travelTime,
      cumTravelTime: cumTravelTime ?? this.cumTravelTime,
      distance: distance ?? this.distance,
      cumDistance: cumDistance ?? this.cumDistance,
    );
  }

  V3LegDirection copyWithWrapped({
    Wrapped<String?>? turnDirection,
    Wrapped<String?>? turningManoeuvre,
    Wrapped<double?>? lon,
    Wrapped<double?>? lat,
    Wrapped<String?>? streetName,
    Wrapped<String?>? fromPathLinkIdx,
    Wrapped<String?>? toPathLinkIdx,
    Wrapped<String?>? skyDirection,
    Wrapped<int?>? travelTime,
    Wrapped<int?>? cumTravelTime,
    Wrapped<int?>? distance,
    Wrapped<int?>? cumDistance,
  }) {
    return V3LegDirection(
      turnDirection: (turnDirection != null
          ? turnDirection.value
          : this.turnDirection),
      turningManoeuvre: (turningManoeuvre != null
          ? turningManoeuvre.value
          : this.turningManoeuvre),
      lon: (lon != null ? lon.value : this.lon),
      lat: (lat != null ? lat.value : this.lat),
      streetName: (streetName != null ? streetName.value : this.streetName),
      fromPathLinkIdx: (fromPathLinkIdx != null
          ? fromPathLinkIdx.value
          : this.fromPathLinkIdx),
      toPathLinkIdx: (toPathLinkIdx != null
          ? toPathLinkIdx.value
          : this.toPathLinkIdx),
      skyDirection: (skyDirection != null
          ? skyDirection.value
          : this.skyDirection),
      travelTime: (travelTime != null ? travelTime.value : this.travelTime),
      cumTravelTime: (cumTravelTime != null
          ? cumTravelTime.value
          : this.cumTravelTime),
      distance: (distance != null ? distance.value : this.distance),
      cumDistance: (cumDistance != null ? cumDistance.value : this.cumDistance),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3JourneyPlannerLocation {
  const V3JourneyPlannerLocation({
    this.locationName,
    this.stopId,
    this.placeId,
    this.locality,
    this.platform,
    this.lat,
    this.lon,
    this.routeTypes,
    this.disruptionIds,
    this.stopTicket,
  });

  factory V3JourneyPlannerLocation.fromJson(Map<String, dynamic> json) =>
      _$V3JourneyPlannerLocationFromJson(json);

  static const toJsonFactory = _$V3JourneyPlannerLocationToJson;
  Map<String, dynamic> toJson() => _$V3JourneyPlannerLocationToJson(this);

  @JsonKey(name: 'LocationName')
  final String? locationName;
  @JsonKey(name: 'StopId')
  final int? stopId;
  @JsonKey(name: 'PlaceId')
  final int? placeId;
  @JsonKey(name: 'Locality')
  final String? locality;
  @JsonKey(name: 'Platform')
  final String? platform;
  @JsonKey(name: 'Lat')
  final double? lat;
  @JsonKey(name: 'Lon')
  final double? lon;
  @JsonKey(name: 'RouteTypes', defaultValue: <int>[])
  final List<int>? routeTypes;
  @JsonKey(name: 'DisruptionIds', defaultValue: <int>[])
  final List<int>? disruptionIds;
  @JsonKey(name: 'StopTicket')
  final V3StopTicket? stopTicket;
  static const fromJsonFactory = _$V3JourneyPlannerLocationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3JourneyPlannerLocation &&
            (identical(other.locationName, locationName) ||
                const DeepCollectionEquality().equals(
                  other.locationName,
                  locationName,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.placeId, placeId) ||
                const DeepCollectionEquality().equals(
                  other.placeId,
                  placeId,
                )) &&
            (identical(other.locality, locality) ||
                const DeepCollectionEquality().equals(
                  other.locality,
                  locality,
                )) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality().equals(
                  other.platform,
                  platform,
                )) &&
            (identical(other.lat, lat) ||
                const DeepCollectionEquality().equals(other.lat, lat)) &&
            (identical(other.lon, lon) ||
                const DeepCollectionEquality().equals(other.lon, lon)) &&
            (identical(other.routeTypes, routeTypes) ||
                const DeepCollectionEquality().equals(
                  other.routeTypes,
                  routeTypes,
                )) &&
            (identical(other.disruptionIds, disruptionIds) ||
                const DeepCollectionEquality().equals(
                  other.disruptionIds,
                  disruptionIds,
                )) &&
            (identical(other.stopTicket, stopTicket) ||
                const DeepCollectionEquality().equals(
                  other.stopTicket,
                  stopTicket,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(locationName) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(placeId) ^
      const DeepCollectionEquality().hash(locality) ^
      const DeepCollectionEquality().hash(platform) ^
      const DeepCollectionEquality().hash(lat) ^
      const DeepCollectionEquality().hash(lon) ^
      const DeepCollectionEquality().hash(routeTypes) ^
      const DeepCollectionEquality().hash(disruptionIds) ^
      const DeepCollectionEquality().hash(stopTicket) ^
      runtimeType.hashCode;
}

extension $V3JourneyPlannerLocationExtension on V3JourneyPlannerLocation {
  V3JourneyPlannerLocation copyWith({
    String? locationName,
    int? stopId,
    int? placeId,
    String? locality,
    String? platform,
    double? lat,
    double? lon,
    List<int>? routeTypes,
    List<int>? disruptionIds,
    V3StopTicket? stopTicket,
  }) {
    return V3JourneyPlannerLocation(
      locationName: locationName ?? this.locationName,
      stopId: stopId ?? this.stopId,
      placeId: placeId ?? this.placeId,
      locality: locality ?? this.locality,
      platform: platform ?? this.platform,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      routeTypes: routeTypes ?? this.routeTypes,
      disruptionIds: disruptionIds ?? this.disruptionIds,
      stopTicket: stopTicket ?? this.stopTicket,
    );
  }

  V3JourneyPlannerLocation copyWithWrapped({
    Wrapped<String?>? locationName,
    Wrapped<int?>? stopId,
    Wrapped<int?>? placeId,
    Wrapped<String?>? locality,
    Wrapped<String?>? platform,
    Wrapped<double?>? lat,
    Wrapped<double?>? lon,
    Wrapped<List<int>?>? routeTypes,
    Wrapped<List<int>?>? disruptionIds,
    Wrapped<V3StopTicket?>? stopTicket,
  }) {
    return V3JourneyPlannerLocation(
      locationName: (locationName != null
          ? locationName.value
          : this.locationName),
      stopId: (stopId != null ? stopId.value : this.stopId),
      placeId: (placeId != null ? placeId.value : this.placeId),
      locality: (locality != null ? locality.value : this.locality),
      platform: (platform != null ? platform.value : this.platform),
      lat: (lat != null ? lat.value : this.lat),
      lon: (lon != null ? lon.value : this.lon),
      routeTypes: (routeTypes != null ? routeTypes.value : this.routeTypes),
      disruptionIds: (disruptionIds != null
          ? disruptionIds.value
          : this.disruptionIds),
      stopTicket: (stopTicket != null ? stopTicket.value : this.stopTicket),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3JourneyPlannerStop {
  const V3JourneyPlannerStop({
    this.location,
    this.timeTimetableUtc,
    this.timeStr,
    this.isRealtime,
    this.timeRealtimeUtc,
    this.estimatedTimeArrival,
    this.estimatedTimeDeparture,
  });

  factory V3JourneyPlannerStop.fromJson(Map<String, dynamic> json) =>
      _$V3JourneyPlannerStopFromJson(json);

  static const toJsonFactory = _$V3JourneyPlannerStopToJson;
  Map<String, dynamic> toJson() => _$V3JourneyPlannerStopToJson(this);

  @JsonKey(name: 'Location')
  final V3JourneyPlannerLocation? location;
  @JsonKey(name: 'TimeTimetableUtc')
  final DateTime? timeTimetableUtc;
  @JsonKey(name: 'TimeStr')
  final String? timeStr;
  @JsonKey(name: 'IsRealtime')
  final bool? isRealtime;
  @JsonKey(name: 'TimeRealtimeUtc')
  final DateTime? timeRealtimeUtc;
  @JsonKey(name: 'EstimatedTimeArrival')
  final DateTime? estimatedTimeArrival;
  @JsonKey(name: 'EstimatedTimeDeparture')
  final DateTime? estimatedTimeDeparture;
  static const fromJsonFactory = _$V3JourneyPlannerStopFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3JourneyPlannerStop &&
            (identical(other.location, location) ||
                const DeepCollectionEquality().equals(
                  other.location,
                  location,
                )) &&
            (identical(other.timeTimetableUtc, timeTimetableUtc) ||
                const DeepCollectionEquality().equals(
                  other.timeTimetableUtc,
                  timeTimetableUtc,
                )) &&
            (identical(other.timeStr, timeStr) ||
                const DeepCollectionEquality().equals(
                  other.timeStr,
                  timeStr,
                )) &&
            (identical(other.isRealtime, isRealtime) ||
                const DeepCollectionEquality().equals(
                  other.isRealtime,
                  isRealtime,
                )) &&
            (identical(other.timeRealtimeUtc, timeRealtimeUtc) ||
                const DeepCollectionEquality().equals(
                  other.timeRealtimeUtc,
                  timeRealtimeUtc,
                )) &&
            (identical(other.estimatedTimeArrival, estimatedTimeArrival) ||
                const DeepCollectionEquality().equals(
                  other.estimatedTimeArrival,
                  estimatedTimeArrival,
                )) &&
            (identical(other.estimatedTimeDeparture, estimatedTimeDeparture) ||
                const DeepCollectionEquality().equals(
                  other.estimatedTimeDeparture,
                  estimatedTimeDeparture,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(location) ^
      const DeepCollectionEquality().hash(timeTimetableUtc) ^
      const DeepCollectionEquality().hash(timeStr) ^
      const DeepCollectionEquality().hash(isRealtime) ^
      const DeepCollectionEquality().hash(timeRealtimeUtc) ^
      const DeepCollectionEquality().hash(estimatedTimeArrival) ^
      const DeepCollectionEquality().hash(estimatedTimeDeparture) ^
      runtimeType.hashCode;
}

extension $V3JourneyPlannerStopExtension on V3JourneyPlannerStop {
  V3JourneyPlannerStop copyWith({
    V3JourneyPlannerLocation? location,
    DateTime? timeTimetableUtc,
    String? timeStr,
    bool? isRealtime,
    DateTime? timeRealtimeUtc,
    DateTime? estimatedTimeArrival,
    DateTime? estimatedTimeDeparture,
  }) {
    return V3JourneyPlannerStop(
      location: location ?? this.location,
      timeTimetableUtc: timeTimetableUtc ?? this.timeTimetableUtc,
      timeStr: timeStr ?? this.timeStr,
      isRealtime: isRealtime ?? this.isRealtime,
      timeRealtimeUtc: timeRealtimeUtc ?? this.timeRealtimeUtc,
      estimatedTimeArrival: estimatedTimeArrival ?? this.estimatedTimeArrival,
      estimatedTimeDeparture:
          estimatedTimeDeparture ?? this.estimatedTimeDeparture,
    );
  }

  V3JourneyPlannerStop copyWithWrapped({
    Wrapped<V3JourneyPlannerLocation?>? location,
    Wrapped<DateTime?>? timeTimetableUtc,
    Wrapped<String?>? timeStr,
    Wrapped<bool?>? isRealtime,
    Wrapped<DateTime?>? timeRealtimeUtc,
    Wrapped<DateTime?>? estimatedTimeArrival,
    Wrapped<DateTime?>? estimatedTimeDeparture,
  }) {
    return V3JourneyPlannerStop(
      location: (location != null ? location.value : this.location),
      timeTimetableUtc: (timeTimetableUtc != null
          ? timeTimetableUtc.value
          : this.timeTimetableUtc),
      timeStr: (timeStr != null ? timeStr.value : this.timeStr),
      isRealtime: (isRealtime != null ? isRealtime.value : this.isRealtime),
      timeRealtimeUtc: (timeRealtimeUtc != null
          ? timeRealtimeUtc.value
          : this.timeRealtimeUtc),
      estimatedTimeArrival: (estimatedTimeArrival != null
          ? estimatedTimeArrival.value
          : this.estimatedTimeArrival),
      estimatedTimeDeparture: (estimatedTimeDeparture != null
          ? estimatedTimeDeparture.value
          : this.estimatedTimeDeparture),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3JourneyLegPathCoordinate {
  const V3JourneyLegPathCoordinate({this.lat, this.lon});

  factory V3JourneyLegPathCoordinate.fromJson(Map<String, dynamic> json) =>
      _$V3JourneyLegPathCoordinateFromJson(json);

  static const toJsonFactory = _$V3JourneyLegPathCoordinateToJson;
  Map<String, dynamic> toJson() => _$V3JourneyLegPathCoordinateToJson(this);

  @JsonKey(name: 'Lat')
  final double? lat;
  @JsonKey(name: 'Lon')
  final double? lon;
  static const fromJsonFactory = _$V3JourneyLegPathCoordinateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3JourneyLegPathCoordinate &&
            (identical(other.lat, lat) ||
                const DeepCollectionEquality().equals(other.lat, lat)) &&
            (identical(other.lon, lon) ||
                const DeepCollectionEquality().equals(other.lon, lon)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lat) ^
      const DeepCollectionEquality().hash(lon) ^
      runtimeType.hashCode;
}

extension $V3JourneyLegPathCoordinateExtension on V3JourneyLegPathCoordinate {
  V3JourneyLegPathCoordinate copyWith({double? lat, double? lon}) {
    return V3JourneyLegPathCoordinate(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  V3JourneyLegPathCoordinate copyWithWrapped({
    Wrapped<double?>? lat,
    Wrapped<double?>? lon,
  }) {
    return V3JourneyLegPathCoordinate(
      lat: (lat != null ? lat.value : this.lat),
      lon: (lon != null ? lon.value : this.lon),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopTicket {
  const V3StopTicket({
    this.ticketType,
    this.zone,
    this.isFreeFareZone,
    this.ticketMachine,
    this.ticketChecks,
    this.vlineReservation,
    this.ticketZones,
  });

  factory V3StopTicket.fromJson(Map<String, dynamic> json) =>
      _$V3StopTicketFromJson(json);

  static const toJsonFactory = _$V3StopTicketToJson;
  Map<String, dynamic> toJson() => _$V3StopTicketToJson(this);

  @JsonKey(name: 'ticket_type')
  final String? ticketType;
  @JsonKey(name: 'zone')
  final String? zone;
  @JsonKey(name: 'is_free_fare_zone')
  final bool? isFreeFareZone;
  @JsonKey(name: 'ticket_machine')
  final bool? ticketMachine;
  @JsonKey(name: 'ticket_checks')
  final bool? ticketChecks;
  @JsonKey(name: 'vline_reservation')
  final bool? vlineReservation;
  @JsonKey(name: 'ticket_zones', defaultValue: <int>[])
  final List<int>? ticketZones;
  static const fromJsonFactory = _$V3StopTicketFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopTicket &&
            (identical(other.ticketType, ticketType) ||
                const DeepCollectionEquality().equals(
                  other.ticketType,
                  ticketType,
                )) &&
            (identical(other.zone, zone) ||
                const DeepCollectionEquality().equals(other.zone, zone)) &&
            (identical(other.isFreeFareZone, isFreeFareZone) ||
                const DeepCollectionEquality().equals(
                  other.isFreeFareZone,
                  isFreeFareZone,
                )) &&
            (identical(other.ticketMachine, ticketMachine) ||
                const DeepCollectionEquality().equals(
                  other.ticketMachine,
                  ticketMachine,
                )) &&
            (identical(other.ticketChecks, ticketChecks) ||
                const DeepCollectionEquality().equals(
                  other.ticketChecks,
                  ticketChecks,
                )) &&
            (identical(other.vlineReservation, vlineReservation) ||
                const DeepCollectionEquality().equals(
                  other.vlineReservation,
                  vlineReservation,
                )) &&
            (identical(other.ticketZones, ticketZones) ||
                const DeepCollectionEquality().equals(
                  other.ticketZones,
                  ticketZones,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(ticketType) ^
      const DeepCollectionEquality().hash(zone) ^
      const DeepCollectionEquality().hash(isFreeFareZone) ^
      const DeepCollectionEquality().hash(ticketMachine) ^
      const DeepCollectionEquality().hash(ticketChecks) ^
      const DeepCollectionEquality().hash(vlineReservation) ^
      const DeepCollectionEquality().hash(ticketZones) ^
      runtimeType.hashCode;
}

extension $V3StopTicketExtension on V3StopTicket {
  V3StopTicket copyWith({
    String? ticketType,
    String? zone,
    bool? isFreeFareZone,
    bool? ticketMachine,
    bool? ticketChecks,
    bool? vlineReservation,
    List<int>? ticketZones,
  }) {
    return V3StopTicket(
      ticketType: ticketType ?? this.ticketType,
      zone: zone ?? this.zone,
      isFreeFareZone: isFreeFareZone ?? this.isFreeFareZone,
      ticketMachine: ticketMachine ?? this.ticketMachine,
      ticketChecks: ticketChecks ?? this.ticketChecks,
      vlineReservation: vlineReservation ?? this.vlineReservation,
      ticketZones: ticketZones ?? this.ticketZones,
    );
  }

  V3StopTicket copyWithWrapped({
    Wrapped<String?>? ticketType,
    Wrapped<String?>? zone,
    Wrapped<bool?>? isFreeFareZone,
    Wrapped<bool?>? ticketMachine,
    Wrapped<bool?>? ticketChecks,
    Wrapped<bool?>? vlineReservation,
    Wrapped<List<int>?>? ticketZones,
  }) {
    return V3StopTicket(
      ticketType: (ticketType != null ? ticketType.value : this.ticketType),
      zone: (zone != null ? zone.value : this.zone),
      isFreeFareZone: (isFreeFareZone != null
          ? isFreeFareZone.value
          : this.isFreeFareZone),
      ticketMachine: (ticketMachine != null
          ? ticketMachine.value
          : this.ticketMachine),
      ticketChecks: (ticketChecks != null
          ? ticketChecks.value
          : this.ticketChecks),
      vlineReservation: (vlineReservation != null
          ? vlineReservation.value
          : this.vlineReservation),
      ticketZones: (ticketZones != null ? ticketZones.value : this.ticketZones),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3NetworkMapsResponse {
  const V3NetworkMapsResponse({this.maps, this.status});

  factory V3NetworkMapsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3NetworkMapsResponseFromJson(json);

  static const toJsonFactory = _$V3NetworkMapsResponseToJson;
  Map<String, dynamic> toJson() => _$V3NetworkMapsResponseToJson(this);

  @JsonKey(name: 'maps', defaultValue: <V3NetworkMap>[])
  final List<V3NetworkMap>? maps;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3NetworkMapsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3NetworkMapsResponse &&
            (identical(other.maps, maps) ||
                const DeepCollectionEquality().equals(other.maps, maps)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(maps) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3NetworkMapsResponseExtension on V3NetworkMapsResponse {
  V3NetworkMapsResponse copyWith({List<V3NetworkMap>? maps, V3Status? status}) {
    return V3NetworkMapsResponse(
      maps: maps ?? this.maps,
      status: status ?? this.status,
    );
  }

  V3NetworkMapsResponse copyWithWrapped({
    Wrapped<List<V3NetworkMap>?>? maps,
    Wrapped<V3Status?>? status,
  }) {
    return V3NetworkMapsResponse(
      maps: (maps != null ? maps.value : this.maps),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3NetworkMap {
  const V3NetworkMap({this.version, this.url, this.size});

  factory V3NetworkMap.fromJson(Map<String, dynamic> json) =>
      _$V3NetworkMapFromJson(json);

  static const toJsonFactory = _$V3NetworkMapToJson;
  Map<String, dynamic> toJson() => _$V3NetworkMapToJson(this);

  @JsonKey(name: 'version')
  final String? version;
  @JsonKey(name: 'url')
  final String? url;
  @JsonKey(name: 'size')
  final String? size;
  static const fromJsonFactory = _$V3NetworkMapFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3NetworkMap &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.url, url) ||
                const DeepCollectionEquality().equals(other.url, url)) &&
            (identical(other.size, size) ||
                const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(url) ^
      const DeepCollectionEquality().hash(size) ^
      runtimeType.hashCode;
}

extension $V3NetworkMapExtension on V3NetworkMap {
  V3NetworkMap copyWith({String? version, String? url, String? size}) {
    return V3NetworkMap(
      version: version ?? this.version,
      url: url ?? this.url,
      size: size ?? this.size,
    );
  }

  V3NetworkMap copyWithWrapped({
    Wrapped<String?>? version,
    Wrapped<String?>? url,
    Wrapped<String?>? size,
  }) {
    return V3NetworkMap(
      version: (version != null ? version.value : this.version),
      url: (url != null ? url.value : this.url),
      size: (size != null ? size.value : this.size),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OperatorsSocialFeedsResponse {
  const V3OperatorsSocialFeedsResponse({this.operators, this.status});

  factory V3OperatorsSocialFeedsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3OperatorsSocialFeedsResponseFromJson(json);

  static const toJsonFactory = _$V3OperatorsSocialFeedsResponseToJson;
  Map<String, dynamic> toJson() => _$V3OperatorsSocialFeedsResponseToJson(this);

  @JsonKey(name: 'operators')
  final V3OperatorsSocialMediaModes? operators;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3OperatorsSocialFeedsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OperatorsSocialFeedsResponse &&
            (identical(other.operators, operators) ||
                const DeepCollectionEquality().equals(
                  other.operators,
                  operators,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(operators) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3OperatorsSocialFeedsResponseExtension
    on V3OperatorsSocialFeedsResponse {
  V3OperatorsSocialFeedsResponse copyWith({
    V3OperatorsSocialMediaModes? operators,
    V3Status? status,
  }) {
    return V3OperatorsSocialFeedsResponse(
      operators: operators ?? this.operators,
      status: status ?? this.status,
    );
  }

  V3OperatorsSocialFeedsResponse copyWithWrapped({
    Wrapped<V3OperatorsSocialMediaModes?>? operators,
    Wrapped<V3Status?>? status,
  }) {
    return V3OperatorsSocialFeedsResponse(
      operators: (operators != null ? operators.value : this.operators),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OperatorsSocialMediaModes {
  const V3OperatorsSocialMediaModes({
    this.metroTrain,
    this.metroBus,
    this.metroTram,
    this.regionalTrain,
    this.regionalCoach,
    this.regionalBus,
  });

  factory V3OperatorsSocialMediaModes.fromJson(Map<String, dynamic> json) =>
      _$V3OperatorsSocialMediaModesFromJson(json);

  static const toJsonFactory = _$V3OperatorsSocialMediaModesToJson;
  Map<String, dynamic> toJson() => _$V3OperatorsSocialMediaModesToJson(this);

  @JsonKey(name: 'metro_train', defaultValue: <V3OperatorSocialMedia>[])
  final List<V3OperatorSocialMedia>? metroTrain;
  @JsonKey(name: 'metro_bus', defaultValue: <V3OperatorSocialMedia>[])
  final List<V3OperatorSocialMedia>? metroBus;
  @JsonKey(name: 'metro_tram', defaultValue: <V3OperatorSocialMedia>[])
  final List<V3OperatorSocialMedia>? metroTram;
  @JsonKey(name: 'regional_train', defaultValue: <V3OperatorSocialMedia>[])
  final List<V3OperatorSocialMedia>? regionalTrain;
  @JsonKey(name: 'regional_coach', defaultValue: <V3OperatorSocialMedia>[])
  final List<V3OperatorSocialMedia>? regionalCoach;
  @JsonKey(name: 'regional_bus', defaultValue: <V3OperatorSocialMedia>[])
  final List<V3OperatorSocialMedia>? regionalBus;
  static const fromJsonFactory = _$V3OperatorsSocialMediaModesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OperatorsSocialMediaModes &&
            (identical(other.metroTrain, metroTrain) ||
                const DeepCollectionEquality().equals(
                  other.metroTrain,
                  metroTrain,
                )) &&
            (identical(other.metroBus, metroBus) ||
                const DeepCollectionEquality().equals(
                  other.metroBus,
                  metroBus,
                )) &&
            (identical(other.metroTram, metroTram) ||
                const DeepCollectionEquality().equals(
                  other.metroTram,
                  metroTram,
                )) &&
            (identical(other.regionalTrain, regionalTrain) ||
                const DeepCollectionEquality().equals(
                  other.regionalTrain,
                  regionalTrain,
                )) &&
            (identical(other.regionalCoach, regionalCoach) ||
                const DeepCollectionEquality().equals(
                  other.regionalCoach,
                  regionalCoach,
                )) &&
            (identical(other.regionalBus, regionalBus) ||
                const DeepCollectionEquality().equals(
                  other.regionalBus,
                  regionalBus,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(metroTrain) ^
      const DeepCollectionEquality().hash(metroBus) ^
      const DeepCollectionEquality().hash(metroTram) ^
      const DeepCollectionEquality().hash(regionalTrain) ^
      const DeepCollectionEquality().hash(regionalCoach) ^
      const DeepCollectionEquality().hash(regionalBus) ^
      runtimeType.hashCode;
}

extension $V3OperatorsSocialMediaModesExtension on V3OperatorsSocialMediaModes {
  V3OperatorsSocialMediaModes copyWith({
    List<V3OperatorSocialMedia>? metroTrain,
    List<V3OperatorSocialMedia>? metroBus,
    List<V3OperatorSocialMedia>? metroTram,
    List<V3OperatorSocialMedia>? regionalTrain,
    List<V3OperatorSocialMedia>? regionalCoach,
    List<V3OperatorSocialMedia>? regionalBus,
  }) {
    return V3OperatorsSocialMediaModes(
      metroTrain: metroTrain ?? this.metroTrain,
      metroBus: metroBus ?? this.metroBus,
      metroTram: metroTram ?? this.metroTram,
      regionalTrain: regionalTrain ?? this.regionalTrain,
      regionalCoach: regionalCoach ?? this.regionalCoach,
      regionalBus: regionalBus ?? this.regionalBus,
    );
  }

  V3OperatorsSocialMediaModes copyWithWrapped({
    Wrapped<List<V3OperatorSocialMedia>?>? metroTrain,
    Wrapped<List<V3OperatorSocialMedia>?>? metroBus,
    Wrapped<List<V3OperatorSocialMedia>?>? metroTram,
    Wrapped<List<V3OperatorSocialMedia>?>? regionalTrain,
    Wrapped<List<V3OperatorSocialMedia>?>? regionalCoach,
    Wrapped<List<V3OperatorSocialMedia>?>? regionalBus,
  }) {
    return V3OperatorsSocialMediaModes(
      metroTrain: (metroTrain != null ? metroTrain.value : this.metroTrain),
      metroBus: (metroBus != null ? metroBus.value : this.metroBus),
      metroTram: (metroTram != null ? metroTram.value : this.metroTram),
      regionalTrain: (regionalTrain != null
          ? regionalTrain.value
          : this.regionalTrain),
      regionalCoach: (regionalCoach != null
          ? regionalCoach.value
          : this.regionalCoach),
      regionalBus: (regionalBus != null ? regionalBus.value : this.regionalBus),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OperatorSocialMedia {
  const V3OperatorSocialMedia({this.name, this.accounts});

  factory V3OperatorSocialMedia.fromJson(Map<String, dynamic> json) =>
      _$V3OperatorSocialMediaFromJson(json);

  static const toJsonFactory = _$V3OperatorSocialMediaToJson;
  Map<String, dynamic> toJson() => _$V3OperatorSocialMediaToJson(this);

  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'accounts', defaultValue: <V3OperatorSocialMediaAccount>[])
  final List<V3OperatorSocialMediaAccount>? accounts;
  static const fromJsonFactory = _$V3OperatorSocialMediaFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OperatorSocialMedia &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.accounts, accounts) ||
                const DeepCollectionEquality().equals(
                  other.accounts,
                  accounts,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(accounts) ^
      runtimeType.hashCode;
}

extension $V3OperatorSocialMediaExtension on V3OperatorSocialMedia {
  V3OperatorSocialMedia copyWith({
    String? name,
    List<V3OperatorSocialMediaAccount>? accounts,
  }) {
    return V3OperatorSocialMedia(
      name: name ?? this.name,
      accounts: accounts ?? this.accounts,
    );
  }

  V3OperatorSocialMedia copyWithWrapped({
    Wrapped<String?>? name,
    Wrapped<List<V3OperatorSocialMediaAccount>?>? accounts,
  }) {
    return V3OperatorSocialMedia(
      name: (name != null ? name.value : this.name),
      accounts: (accounts != null ? accounts.value : this.accounts),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OperatorSocialMediaAccount {
  const V3OperatorSocialMediaAccount({
    this.type,
    this.accountName,
    this.url,
    this.iOSUrl,
  });

  factory V3OperatorSocialMediaAccount.fromJson(Map<String, dynamic> json) =>
      _$V3OperatorSocialMediaAccountFromJson(json);

  static const toJsonFactory = _$V3OperatorSocialMediaAccountToJson;
  Map<String, dynamic> toJson() => _$V3OperatorSocialMediaAccountToJson(this);

  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'account_name')
  final String? accountName;
  @JsonKey(name: 'url')
  final String? url;
  @JsonKey(name: 'iOS_url')
  final String? iOSUrl;
  static const fromJsonFactory = _$V3OperatorSocialMediaAccountFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OperatorSocialMediaAccount &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.accountName, accountName) ||
                const DeepCollectionEquality().equals(
                  other.accountName,
                  accountName,
                )) &&
            (identical(other.url, url) ||
                const DeepCollectionEquality().equals(other.url, url)) &&
            (identical(other.iOSUrl, iOSUrl) ||
                const DeepCollectionEquality().equals(other.iOSUrl, iOSUrl)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(accountName) ^
      const DeepCollectionEquality().hash(url) ^
      const DeepCollectionEquality().hash(iOSUrl) ^
      runtimeType.hashCode;
}

extension $V3OperatorSocialMediaAccountExtension
    on V3OperatorSocialMediaAccount {
  V3OperatorSocialMediaAccount copyWith({
    String? type,
    String? accountName,
    String? url,
    String? iOSUrl,
  }) {
    return V3OperatorSocialMediaAccount(
      type: type ?? this.type,
      accountName: accountName ?? this.accountName,
      url: url ?? this.url,
      iOSUrl: iOSUrl ?? this.iOSUrl,
    );
  }

  V3OperatorSocialMediaAccount copyWithWrapped({
    Wrapped<String?>? type,
    Wrapped<String?>? accountName,
    Wrapped<String?>? url,
    Wrapped<String?>? iOSUrl,
  }) {
    return V3OperatorSocialMediaAccount(
      type: (type != null ? type.value : this.type),
      accountName: (accountName != null ? accountName.value : this.accountName),
      url: (url != null ? url.value : this.url),
      iOSUrl: (iOSUrl != null ? iOSUrl.value : this.iOSUrl),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OperatorsResponse {
  const V3OperatorsResponse({this.operators, this.status});

  factory V3OperatorsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3OperatorsResponseFromJson(json);

  static const toJsonFactory = _$V3OperatorsResponseToJson;
  Map<String, dynamic> toJson() => _$V3OperatorsResponseToJson(this);

  @JsonKey(name: 'operators', defaultValue: <Object>[])
  final List<Object>? operators;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3OperatorsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OperatorsResponse &&
            (identical(other.operators, operators) ||
                const DeepCollectionEquality().equals(
                  other.operators,
                  operators,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(operators) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3OperatorsResponseExtension on V3OperatorsResponse {
  V3OperatorsResponse copyWith({List<Object>? operators, V3Status? status}) {
    return V3OperatorsResponse(
      operators: operators ?? this.operators,
      status: status ?? this.status,
    );
  }

  V3OperatorsResponse copyWithWrapped({
    Wrapped<List<Object>?>? operators,
    Wrapped<V3Status?>? status,
  }) {
    return V3OperatorsResponse(
      operators: (operators != null ? operators.value : this.operators),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OutletParameters {
  const V3OutletParameters({this.maxResults});

  factory V3OutletParameters.fromJson(Map<String, dynamic> json) =>
      _$V3OutletParametersFromJson(json);

  static const toJsonFactory = _$V3OutletParametersToJson;
  Map<String, dynamic> toJson() => _$V3OutletParametersToJson(this);

  @JsonKey(name: 'max_results')
  final int? maxResults;
  static const fromJsonFactory = _$V3OutletParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OutletParameters &&
            (identical(other.maxResults, maxResults) ||
                const DeepCollectionEquality().equals(
                  other.maxResults,
                  maxResults,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(maxResults) ^ runtimeType.hashCode;
}

extension $V3OutletParametersExtension on V3OutletParameters {
  V3OutletParameters copyWith({int? maxResults}) {
    return V3OutletParameters(maxResults: maxResults ?? this.maxResults);
  }

  V3OutletParameters copyWithWrapped({Wrapped<int?>? maxResults}) {
    return V3OutletParameters(
      maxResults: (maxResults != null ? maxResults.value : this.maxResults),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OutletResponse {
  const V3OutletResponse({this.outlets, this.status});

  factory V3OutletResponse.fromJson(Map<String, dynamic> json) =>
      _$V3OutletResponseFromJson(json);

  static const toJsonFactory = _$V3OutletResponseToJson;
  Map<String, dynamic> toJson() => _$V3OutletResponseToJson(this);

  @JsonKey(name: 'outlets', defaultValue: <V3Outlet>[])
  final List<V3Outlet>? outlets;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3OutletResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OutletResponse &&
            (identical(other.outlets, outlets) ||
                const DeepCollectionEquality().equals(
                  other.outlets,
                  outlets,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(outlets) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3OutletResponseExtension on V3OutletResponse {
  V3OutletResponse copyWith({List<V3Outlet>? outlets, V3Status? status}) {
    return V3OutletResponse(
      outlets: outlets ?? this.outlets,
      status: status ?? this.status,
    );
  }

  V3OutletResponse copyWithWrapped({
    Wrapped<List<V3Outlet>?>? outlets,
    Wrapped<V3Status?>? status,
  }) {
    return V3OutletResponse(
      outlets: (outlets != null ? outlets.value : this.outlets),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Outlet {
  const V3Outlet({
    this.outletSlidSpid,
    this.outletName,
    this.outletBusiness,
    this.outletLatitude,
    this.outletLongitude,
    this.outletSuburb,
    this.outletPostcode,
    this.outletBusinessHourMon,
    this.outletBusinessHourTue,
    this.outletBusinessHourWed,
    this.outletBusinessHourThur,
    this.outletBusinessHourFri,
    this.outletBusinessHourSat,
    this.outletBusinessHourSun,
    this.outletNotes,
  });

  factory V3Outlet.fromJson(Map<String, dynamic> json) =>
      _$V3OutletFromJson(json);

  static const toJsonFactory = _$V3OutletToJson;
  Map<String, dynamic> toJson() => _$V3OutletToJson(this);

  @JsonKey(name: 'outlet_slid_spid')
  final String? outletSlidSpid;
  @JsonKey(name: 'outlet_name')
  final String? outletName;
  @JsonKey(name: 'outlet_business')
  final String? outletBusiness;
  @JsonKey(name: 'outlet_latitude')
  final double? outletLatitude;
  @JsonKey(name: 'outlet_longitude')
  final double? outletLongitude;
  @JsonKey(name: 'outlet_suburb')
  final String? outletSuburb;
  @JsonKey(name: 'outlet_postcode')
  final int? outletPostcode;
  @JsonKey(name: 'outlet_business_hour_mon')
  final String? outletBusinessHourMon;
  @JsonKey(name: 'outlet_business_hour_tue')
  final String? outletBusinessHourTue;
  @JsonKey(name: 'outlet_business_hour_wed')
  final String? outletBusinessHourWed;
  @JsonKey(name: 'outlet_business_hour_thur')
  final String? outletBusinessHourThur;
  @JsonKey(name: 'outlet_business_hour_fri')
  final String? outletBusinessHourFri;
  @JsonKey(name: 'outlet_business_hour_sat')
  final String? outletBusinessHourSat;
  @JsonKey(name: 'outlet_business_hour_sun')
  final String? outletBusinessHourSun;
  @JsonKey(name: 'outlet_notes')
  final String? outletNotes;
  static const fromJsonFactory = _$V3OutletFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3Outlet &&
            (identical(other.outletSlidSpid, outletSlidSpid) ||
                const DeepCollectionEquality().equals(
                  other.outletSlidSpid,
                  outletSlidSpid,
                )) &&
            (identical(other.outletName, outletName) ||
                const DeepCollectionEquality().equals(
                  other.outletName,
                  outletName,
                )) &&
            (identical(other.outletBusiness, outletBusiness) ||
                const DeepCollectionEquality().equals(
                  other.outletBusiness,
                  outletBusiness,
                )) &&
            (identical(other.outletLatitude, outletLatitude) ||
                const DeepCollectionEquality().equals(
                  other.outletLatitude,
                  outletLatitude,
                )) &&
            (identical(other.outletLongitude, outletLongitude) ||
                const DeepCollectionEquality().equals(
                  other.outletLongitude,
                  outletLongitude,
                )) &&
            (identical(other.outletSuburb, outletSuburb) ||
                const DeepCollectionEquality().equals(
                  other.outletSuburb,
                  outletSuburb,
                )) &&
            (identical(other.outletPostcode, outletPostcode) ||
                const DeepCollectionEquality().equals(
                  other.outletPostcode,
                  outletPostcode,
                )) &&
            (identical(other.outletBusinessHourMon, outletBusinessHourMon) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourMon,
                  outletBusinessHourMon,
                )) &&
            (identical(other.outletBusinessHourTue, outletBusinessHourTue) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourTue,
                  outletBusinessHourTue,
                )) &&
            (identical(other.outletBusinessHourWed, outletBusinessHourWed) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourWed,
                  outletBusinessHourWed,
                )) &&
            (identical(other.outletBusinessHourThur, outletBusinessHourThur) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourThur,
                  outletBusinessHourThur,
                )) &&
            (identical(other.outletBusinessHourFri, outletBusinessHourFri) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourFri,
                  outletBusinessHourFri,
                )) &&
            (identical(other.outletBusinessHourSat, outletBusinessHourSat) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourSat,
                  outletBusinessHourSat,
                )) &&
            (identical(other.outletBusinessHourSun, outletBusinessHourSun) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourSun,
                  outletBusinessHourSun,
                )) &&
            (identical(other.outletNotes, outletNotes) ||
                const DeepCollectionEquality().equals(
                  other.outletNotes,
                  outletNotes,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(outletSlidSpid) ^
      const DeepCollectionEquality().hash(outletName) ^
      const DeepCollectionEquality().hash(outletBusiness) ^
      const DeepCollectionEquality().hash(outletLatitude) ^
      const DeepCollectionEquality().hash(outletLongitude) ^
      const DeepCollectionEquality().hash(outletSuburb) ^
      const DeepCollectionEquality().hash(outletPostcode) ^
      const DeepCollectionEquality().hash(outletBusinessHourMon) ^
      const DeepCollectionEquality().hash(outletBusinessHourTue) ^
      const DeepCollectionEquality().hash(outletBusinessHourWed) ^
      const DeepCollectionEquality().hash(outletBusinessHourThur) ^
      const DeepCollectionEquality().hash(outletBusinessHourFri) ^
      const DeepCollectionEquality().hash(outletBusinessHourSat) ^
      const DeepCollectionEquality().hash(outletBusinessHourSun) ^
      const DeepCollectionEquality().hash(outletNotes) ^
      runtimeType.hashCode;
}

extension $V3OutletExtension on V3Outlet {
  V3Outlet copyWith({
    String? outletSlidSpid,
    String? outletName,
    String? outletBusiness,
    double? outletLatitude,
    double? outletLongitude,
    String? outletSuburb,
    int? outletPostcode,
    String? outletBusinessHourMon,
    String? outletBusinessHourTue,
    String? outletBusinessHourWed,
    String? outletBusinessHourThur,
    String? outletBusinessHourFri,
    String? outletBusinessHourSat,
    String? outletBusinessHourSun,
    String? outletNotes,
  }) {
    return V3Outlet(
      outletSlidSpid: outletSlidSpid ?? this.outletSlidSpid,
      outletName: outletName ?? this.outletName,
      outletBusiness: outletBusiness ?? this.outletBusiness,
      outletLatitude: outletLatitude ?? this.outletLatitude,
      outletLongitude: outletLongitude ?? this.outletLongitude,
      outletSuburb: outletSuburb ?? this.outletSuburb,
      outletPostcode: outletPostcode ?? this.outletPostcode,
      outletBusinessHourMon:
          outletBusinessHourMon ?? this.outletBusinessHourMon,
      outletBusinessHourTue:
          outletBusinessHourTue ?? this.outletBusinessHourTue,
      outletBusinessHourWed:
          outletBusinessHourWed ?? this.outletBusinessHourWed,
      outletBusinessHourThur:
          outletBusinessHourThur ?? this.outletBusinessHourThur,
      outletBusinessHourFri:
          outletBusinessHourFri ?? this.outletBusinessHourFri,
      outletBusinessHourSat:
          outletBusinessHourSat ?? this.outletBusinessHourSat,
      outletBusinessHourSun:
          outletBusinessHourSun ?? this.outletBusinessHourSun,
      outletNotes: outletNotes ?? this.outletNotes,
    );
  }

  V3Outlet copyWithWrapped({
    Wrapped<String?>? outletSlidSpid,
    Wrapped<String?>? outletName,
    Wrapped<String?>? outletBusiness,
    Wrapped<double?>? outletLatitude,
    Wrapped<double?>? outletLongitude,
    Wrapped<String?>? outletSuburb,
    Wrapped<int?>? outletPostcode,
    Wrapped<String?>? outletBusinessHourMon,
    Wrapped<String?>? outletBusinessHourTue,
    Wrapped<String?>? outletBusinessHourWed,
    Wrapped<String?>? outletBusinessHourThur,
    Wrapped<String?>? outletBusinessHourFri,
    Wrapped<String?>? outletBusinessHourSat,
    Wrapped<String?>? outletBusinessHourSun,
    Wrapped<String?>? outletNotes,
  }) {
    return V3Outlet(
      outletSlidSpid: (outletSlidSpid != null
          ? outletSlidSpid.value
          : this.outletSlidSpid),
      outletName: (outletName != null ? outletName.value : this.outletName),
      outletBusiness: (outletBusiness != null
          ? outletBusiness.value
          : this.outletBusiness),
      outletLatitude: (outletLatitude != null
          ? outletLatitude.value
          : this.outletLatitude),
      outletLongitude: (outletLongitude != null
          ? outletLongitude.value
          : this.outletLongitude),
      outletSuburb: (outletSuburb != null
          ? outletSuburb.value
          : this.outletSuburb),
      outletPostcode: (outletPostcode != null
          ? outletPostcode.value
          : this.outletPostcode),
      outletBusinessHourMon: (outletBusinessHourMon != null
          ? outletBusinessHourMon.value
          : this.outletBusinessHourMon),
      outletBusinessHourTue: (outletBusinessHourTue != null
          ? outletBusinessHourTue.value
          : this.outletBusinessHourTue),
      outletBusinessHourWed: (outletBusinessHourWed != null
          ? outletBusinessHourWed.value
          : this.outletBusinessHourWed),
      outletBusinessHourThur: (outletBusinessHourThur != null
          ? outletBusinessHourThur.value
          : this.outletBusinessHourThur),
      outletBusinessHourFri: (outletBusinessHourFri != null
          ? outletBusinessHourFri.value
          : this.outletBusinessHourFri),
      outletBusinessHourSat: (outletBusinessHourSat != null
          ? outletBusinessHourSat.value
          : this.outletBusinessHourSat),
      outletBusinessHourSun: (outletBusinessHourSun != null
          ? outletBusinessHourSun.value
          : this.outletBusinessHourSun),
      outletNotes: (outletNotes != null ? outletNotes.value : this.outletNotes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OutletGeolocationParameters {
  const V3OutletGeolocationParameters({this.maxDistance, this.maxResults});

  factory V3OutletGeolocationParameters.fromJson(Map<String, dynamic> json) =>
      _$V3OutletGeolocationParametersFromJson(json);

  static const toJsonFactory = _$V3OutletGeolocationParametersToJson;
  Map<String, dynamic> toJson() => _$V3OutletGeolocationParametersToJson(this);

  @JsonKey(name: 'max_distance')
  final double? maxDistance;
  @JsonKey(name: 'max_results')
  final int? maxResults;
  static const fromJsonFactory = _$V3OutletGeolocationParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OutletGeolocationParameters &&
            (identical(other.maxDistance, maxDistance) ||
                const DeepCollectionEquality().equals(
                  other.maxDistance,
                  maxDistance,
                )) &&
            (identical(other.maxResults, maxResults) ||
                const DeepCollectionEquality().equals(
                  other.maxResults,
                  maxResults,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(maxDistance) ^
      const DeepCollectionEquality().hash(maxResults) ^
      runtimeType.hashCode;
}

extension $V3OutletGeolocationParametersExtension
    on V3OutletGeolocationParameters {
  V3OutletGeolocationParameters copyWith({
    double? maxDistance,
    int? maxResults,
  }) {
    return V3OutletGeolocationParameters(
      maxDistance: maxDistance ?? this.maxDistance,
      maxResults: maxResults ?? this.maxResults,
    );
  }

  V3OutletGeolocationParameters copyWithWrapped({
    Wrapped<double?>? maxDistance,
    Wrapped<int?>? maxResults,
  }) {
    return V3OutletGeolocationParameters(
      maxDistance: (maxDistance != null ? maxDistance.value : this.maxDistance),
      maxResults: (maxResults != null ? maxResults.value : this.maxResults),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OutletGeolocationResponse {
  const V3OutletGeolocationResponse({this.outlets, this.status});

  factory V3OutletGeolocationResponse.fromJson(Map<String, dynamic> json) =>
      _$V3OutletGeolocationResponseFromJson(json);

  static const toJsonFactory = _$V3OutletGeolocationResponseToJson;
  Map<String, dynamic> toJson() => _$V3OutletGeolocationResponseToJson(this);

  @JsonKey(name: 'outlets', defaultValue: <V3OutletGeolocation>[])
  final List<V3OutletGeolocation>? outlets;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3OutletGeolocationResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OutletGeolocationResponse &&
            (identical(other.outlets, outlets) ||
                const DeepCollectionEquality().equals(
                  other.outlets,
                  outlets,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(outlets) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3OutletGeolocationResponseExtension on V3OutletGeolocationResponse {
  V3OutletGeolocationResponse copyWith({
    List<V3OutletGeolocation>? outlets,
    V3Status? status,
  }) {
    return V3OutletGeolocationResponse(
      outlets: outlets ?? this.outlets,
      status: status ?? this.status,
    );
  }

  V3OutletGeolocationResponse copyWithWrapped({
    Wrapped<List<V3OutletGeolocation>?>? outlets,
    Wrapped<V3Status?>? status,
  }) {
    return V3OutletGeolocationResponse(
      outlets: (outlets != null ? outlets.value : this.outlets),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3OutletGeolocation {
  const V3OutletGeolocation({
    this.outletDistance,
    this.outletSlidSpid,
    this.outletName,
    this.outletBusiness,
    this.outletLatitude,
    this.outletLongitude,
    this.outletSuburb,
    this.outletPostcode,
    this.outletBusinessHourMon,
    this.outletBusinessHourTue,
    this.outletBusinessHourWed,
    this.outletBusinessHourThur,
    this.outletBusinessHourFri,
    this.outletBusinessHourSat,
    this.outletBusinessHourSun,
    this.outletNotes,
  });

  factory V3OutletGeolocation.fromJson(Map<String, dynamic> json) =>
      _$V3OutletGeolocationFromJson(json);

  static const toJsonFactory = _$V3OutletGeolocationToJson;
  Map<String, dynamic> toJson() => _$V3OutletGeolocationToJson(this);

  @JsonKey(name: 'outlet_distance')
  final double? outletDistance;
  @JsonKey(name: 'outlet_slid_spid')
  final String? outletSlidSpid;
  @JsonKey(name: 'outlet_name')
  final String? outletName;
  @JsonKey(name: 'outlet_business')
  final String? outletBusiness;
  @JsonKey(name: 'outlet_latitude')
  final double? outletLatitude;
  @JsonKey(name: 'outlet_longitude')
  final double? outletLongitude;
  @JsonKey(name: 'outlet_suburb')
  final String? outletSuburb;
  @JsonKey(name: 'outlet_postcode')
  final int? outletPostcode;
  @JsonKey(name: 'outlet_business_hour_mon')
  final String? outletBusinessHourMon;
  @JsonKey(name: 'outlet_business_hour_tue')
  final String? outletBusinessHourTue;
  @JsonKey(name: 'outlet_business_hour_wed')
  final String? outletBusinessHourWed;
  @JsonKey(name: 'outlet_business_hour_thur')
  final String? outletBusinessHourThur;
  @JsonKey(name: 'outlet_business_hour_fri')
  final String? outletBusinessHourFri;
  @JsonKey(name: 'outlet_business_hour_sat')
  final String? outletBusinessHourSat;
  @JsonKey(name: 'outlet_business_hour_sun')
  final String? outletBusinessHourSun;
  @JsonKey(name: 'outlet_notes')
  final String? outletNotes;
  static const fromJsonFactory = _$V3OutletGeolocationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3OutletGeolocation &&
            (identical(other.outletDistance, outletDistance) ||
                const DeepCollectionEquality().equals(
                  other.outletDistance,
                  outletDistance,
                )) &&
            (identical(other.outletSlidSpid, outletSlidSpid) ||
                const DeepCollectionEquality().equals(
                  other.outletSlidSpid,
                  outletSlidSpid,
                )) &&
            (identical(other.outletName, outletName) ||
                const DeepCollectionEquality().equals(
                  other.outletName,
                  outletName,
                )) &&
            (identical(other.outletBusiness, outletBusiness) ||
                const DeepCollectionEquality().equals(
                  other.outletBusiness,
                  outletBusiness,
                )) &&
            (identical(other.outletLatitude, outletLatitude) ||
                const DeepCollectionEquality().equals(
                  other.outletLatitude,
                  outletLatitude,
                )) &&
            (identical(other.outletLongitude, outletLongitude) ||
                const DeepCollectionEquality().equals(
                  other.outletLongitude,
                  outletLongitude,
                )) &&
            (identical(other.outletSuburb, outletSuburb) ||
                const DeepCollectionEquality().equals(
                  other.outletSuburb,
                  outletSuburb,
                )) &&
            (identical(other.outletPostcode, outletPostcode) ||
                const DeepCollectionEquality().equals(
                  other.outletPostcode,
                  outletPostcode,
                )) &&
            (identical(other.outletBusinessHourMon, outletBusinessHourMon) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourMon,
                  outletBusinessHourMon,
                )) &&
            (identical(other.outletBusinessHourTue, outletBusinessHourTue) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourTue,
                  outletBusinessHourTue,
                )) &&
            (identical(other.outletBusinessHourWed, outletBusinessHourWed) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourWed,
                  outletBusinessHourWed,
                )) &&
            (identical(other.outletBusinessHourThur, outletBusinessHourThur) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourThur,
                  outletBusinessHourThur,
                )) &&
            (identical(other.outletBusinessHourFri, outletBusinessHourFri) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourFri,
                  outletBusinessHourFri,
                )) &&
            (identical(other.outletBusinessHourSat, outletBusinessHourSat) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourSat,
                  outletBusinessHourSat,
                )) &&
            (identical(other.outletBusinessHourSun, outletBusinessHourSun) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourSun,
                  outletBusinessHourSun,
                )) &&
            (identical(other.outletNotes, outletNotes) ||
                const DeepCollectionEquality().equals(
                  other.outletNotes,
                  outletNotes,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(outletDistance) ^
      const DeepCollectionEquality().hash(outletSlidSpid) ^
      const DeepCollectionEquality().hash(outletName) ^
      const DeepCollectionEquality().hash(outletBusiness) ^
      const DeepCollectionEquality().hash(outletLatitude) ^
      const DeepCollectionEquality().hash(outletLongitude) ^
      const DeepCollectionEquality().hash(outletSuburb) ^
      const DeepCollectionEquality().hash(outletPostcode) ^
      const DeepCollectionEquality().hash(outletBusinessHourMon) ^
      const DeepCollectionEquality().hash(outletBusinessHourTue) ^
      const DeepCollectionEquality().hash(outletBusinessHourWed) ^
      const DeepCollectionEquality().hash(outletBusinessHourThur) ^
      const DeepCollectionEquality().hash(outletBusinessHourFri) ^
      const DeepCollectionEquality().hash(outletBusinessHourSat) ^
      const DeepCollectionEquality().hash(outletBusinessHourSun) ^
      const DeepCollectionEquality().hash(outletNotes) ^
      runtimeType.hashCode;
}

extension $V3OutletGeolocationExtension on V3OutletGeolocation {
  V3OutletGeolocation copyWith({
    double? outletDistance,
    String? outletSlidSpid,
    String? outletName,
    String? outletBusiness,
    double? outletLatitude,
    double? outletLongitude,
    String? outletSuburb,
    int? outletPostcode,
    String? outletBusinessHourMon,
    String? outletBusinessHourTue,
    String? outletBusinessHourWed,
    String? outletBusinessHourThur,
    String? outletBusinessHourFri,
    String? outletBusinessHourSat,
    String? outletBusinessHourSun,
    String? outletNotes,
  }) {
    return V3OutletGeolocation(
      outletDistance: outletDistance ?? this.outletDistance,
      outletSlidSpid: outletSlidSpid ?? this.outletSlidSpid,
      outletName: outletName ?? this.outletName,
      outletBusiness: outletBusiness ?? this.outletBusiness,
      outletLatitude: outletLatitude ?? this.outletLatitude,
      outletLongitude: outletLongitude ?? this.outletLongitude,
      outletSuburb: outletSuburb ?? this.outletSuburb,
      outletPostcode: outletPostcode ?? this.outletPostcode,
      outletBusinessHourMon:
          outletBusinessHourMon ?? this.outletBusinessHourMon,
      outletBusinessHourTue:
          outletBusinessHourTue ?? this.outletBusinessHourTue,
      outletBusinessHourWed:
          outletBusinessHourWed ?? this.outletBusinessHourWed,
      outletBusinessHourThur:
          outletBusinessHourThur ?? this.outletBusinessHourThur,
      outletBusinessHourFri:
          outletBusinessHourFri ?? this.outletBusinessHourFri,
      outletBusinessHourSat:
          outletBusinessHourSat ?? this.outletBusinessHourSat,
      outletBusinessHourSun:
          outletBusinessHourSun ?? this.outletBusinessHourSun,
      outletNotes: outletNotes ?? this.outletNotes,
    );
  }

  V3OutletGeolocation copyWithWrapped({
    Wrapped<double?>? outletDistance,
    Wrapped<String?>? outletSlidSpid,
    Wrapped<String?>? outletName,
    Wrapped<String?>? outletBusiness,
    Wrapped<double?>? outletLatitude,
    Wrapped<double?>? outletLongitude,
    Wrapped<String?>? outletSuburb,
    Wrapped<int?>? outletPostcode,
    Wrapped<String?>? outletBusinessHourMon,
    Wrapped<String?>? outletBusinessHourTue,
    Wrapped<String?>? outletBusinessHourWed,
    Wrapped<String?>? outletBusinessHourThur,
    Wrapped<String?>? outletBusinessHourFri,
    Wrapped<String?>? outletBusinessHourSat,
    Wrapped<String?>? outletBusinessHourSun,
    Wrapped<String?>? outletNotes,
  }) {
    return V3OutletGeolocation(
      outletDistance: (outletDistance != null
          ? outletDistance.value
          : this.outletDistance),
      outletSlidSpid: (outletSlidSpid != null
          ? outletSlidSpid.value
          : this.outletSlidSpid),
      outletName: (outletName != null ? outletName.value : this.outletName),
      outletBusiness: (outletBusiness != null
          ? outletBusiness.value
          : this.outletBusiness),
      outletLatitude: (outletLatitude != null
          ? outletLatitude.value
          : this.outletLatitude),
      outletLongitude: (outletLongitude != null
          ? outletLongitude.value
          : this.outletLongitude),
      outletSuburb: (outletSuburb != null
          ? outletSuburb.value
          : this.outletSuburb),
      outletPostcode: (outletPostcode != null
          ? outletPostcode.value
          : this.outletPostcode),
      outletBusinessHourMon: (outletBusinessHourMon != null
          ? outletBusinessHourMon.value
          : this.outletBusinessHourMon),
      outletBusinessHourTue: (outletBusinessHourTue != null
          ? outletBusinessHourTue.value
          : this.outletBusinessHourTue),
      outletBusinessHourWed: (outletBusinessHourWed != null
          ? outletBusinessHourWed.value
          : this.outletBusinessHourWed),
      outletBusinessHourThur: (outletBusinessHourThur != null
          ? outletBusinessHourThur.value
          : this.outletBusinessHourThur),
      outletBusinessHourFri: (outletBusinessHourFri != null
          ? outletBusinessHourFri.value
          : this.outletBusinessHourFri),
      outletBusinessHourSat: (outletBusinessHourSat != null
          ? outletBusinessHourSat.value
          : this.outletBusinessHourSat),
      outletBusinessHourSun: (outletBusinessHourSun != null
          ? outletBusinessHourSun.value
          : this.outletBusinessHourSun),
      outletNotes: (outletNotes != null ? outletNotes.value : this.outletNotes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3PatternsParameters {
  const V3PatternsParameters({
    this.expand,
    this.stopId,
    this.dateUtc,
    this.includeSkippedStops,
    this.includeGeopath,
    this.includeAdvertisedInterchange,
  });

  factory V3PatternsParameters.fromJson(Map<String, dynamic> json) =>
      _$V3PatternsParametersFromJson(json);

  static const toJsonFactory = _$V3PatternsParametersToJson;
  Map<String, dynamic> toJson() => _$V3PatternsParametersToJson(this);

  @JsonKey(name: 'expand', defaultValue: <int>[])
  final List<int>? expand;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'include_skipped_stops')
  final bool? includeSkippedStops;
  @JsonKey(name: 'include_geopath')
  final bool? includeGeopath;
  @JsonKey(name: 'include_advertised_interchange')
  final bool? includeAdvertisedInterchange;
  static const fromJsonFactory = _$V3PatternsParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3PatternsParameters &&
            (identical(other.expand, expand) ||
                const DeepCollectionEquality().equals(other.expand, expand)) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(other.includeSkippedStops, includeSkippedStops) ||
                const DeepCollectionEquality().equals(
                  other.includeSkippedStops,
                  includeSkippedStops,
                )) &&
            (identical(other.includeGeopath, includeGeopath) ||
                const DeepCollectionEquality().equals(
                  other.includeGeopath,
                  includeGeopath,
                )) &&
            (identical(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                ) ||
                const DeepCollectionEquality().equals(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(expand) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(includeSkippedStops) ^
      const DeepCollectionEquality().hash(includeGeopath) ^
      const DeepCollectionEquality().hash(includeAdvertisedInterchange) ^
      runtimeType.hashCode;
}

extension $V3PatternsParametersExtension on V3PatternsParameters {
  V3PatternsParameters copyWith({
    List<int>? expand,
    int? stopId,
    DateTime? dateUtc,
    bool? includeSkippedStops,
    bool? includeGeopath,
    bool? includeAdvertisedInterchange,
  }) {
    return V3PatternsParameters(
      expand: expand ?? this.expand,
      stopId: stopId ?? this.stopId,
      dateUtc: dateUtc ?? this.dateUtc,
      includeSkippedStops: includeSkippedStops ?? this.includeSkippedStops,
      includeGeopath: includeGeopath ?? this.includeGeopath,
      includeAdvertisedInterchange:
          includeAdvertisedInterchange ?? this.includeAdvertisedInterchange,
    );
  }

  V3PatternsParameters copyWithWrapped({
    Wrapped<List<int>?>? expand,
    Wrapped<int?>? stopId,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<bool?>? includeSkippedStops,
    Wrapped<bool?>? includeGeopath,
    Wrapped<bool?>? includeAdvertisedInterchange,
  }) {
    return V3PatternsParameters(
      expand: (expand != null ? expand.value : this.expand),
      stopId: (stopId != null ? stopId.value : this.stopId),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      includeSkippedStops: (includeSkippedStops != null
          ? includeSkippedStops.value
          : this.includeSkippedStops),
      includeGeopath: (includeGeopath != null
          ? includeGeopath.value
          : this.includeGeopath),
      includeAdvertisedInterchange: (includeAdvertisedInterchange != null
          ? includeAdvertisedInterchange.value
          : this.includeAdvertisedInterchange),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StoppingPattern {
  const V3StoppingPattern({
    this.disruptions,
    this.departures,
    this.stops,
    this.routes,
    this.runs,
    this.directions,
    this.status,
  });

  factory V3StoppingPattern.fromJson(Map<String, dynamic> json) =>
      _$V3StoppingPatternFromJson(json);

  static const toJsonFactory = _$V3StoppingPatternToJson;
  Map<String, dynamic> toJson() => _$V3StoppingPatternToJson(this);

  @JsonKey(name: 'disruptions', defaultValue: <V3Disruption>[])
  final List<V3Disruption>? disruptions;
  @JsonKey(name: 'departures', defaultValue: <V3PatternDeparture>[])
  final List<V3PatternDeparture>? departures;
  @JsonKey(name: 'stops')
  final Map<String, dynamic>? stops;
  @JsonKey(name: 'routes')
  final Map<String, dynamic>? routes;
  @JsonKey(name: 'runs')
  final Map<String, dynamic>? runs;
  @JsonKey(name: 'directions')
  final Map<String, dynamic>? directions;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3StoppingPatternFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StoppingPattern &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.departures, departures) ||
                const DeepCollectionEquality().equals(
                  other.departures,
                  departures,
                )) &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)) &&
            (identical(other.routes, routes) ||
                const DeepCollectionEquality().equals(other.routes, routes)) &&
            (identical(other.runs, runs) ||
                const DeepCollectionEquality().equals(other.runs, runs)) &&
            (identical(other.directions, directions) ||
                const DeepCollectionEquality().equals(
                  other.directions,
                  directions,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(departures) ^
      const DeepCollectionEquality().hash(stops) ^
      const DeepCollectionEquality().hash(routes) ^
      const DeepCollectionEquality().hash(runs) ^
      const DeepCollectionEquality().hash(directions) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3StoppingPatternExtension on V3StoppingPattern {
  V3StoppingPattern copyWith({
    List<V3Disruption>? disruptions,
    List<V3PatternDeparture>? departures,
    Map<String, dynamic>? stops,
    Map<String, dynamic>? routes,
    Map<String, dynamic>? runs,
    Map<String, dynamic>? directions,
    V3Status? status,
  }) {
    return V3StoppingPattern(
      disruptions: disruptions ?? this.disruptions,
      departures: departures ?? this.departures,
      stops: stops ?? this.stops,
      routes: routes ?? this.routes,
      runs: runs ?? this.runs,
      directions: directions ?? this.directions,
      status: status ?? this.status,
    );
  }

  V3StoppingPattern copyWithWrapped({
    Wrapped<List<V3Disruption>?>? disruptions,
    Wrapped<List<V3PatternDeparture>?>? departures,
    Wrapped<Map<String, dynamic>?>? stops,
    Wrapped<Map<String, dynamic>?>? routes,
    Wrapped<Map<String, dynamic>?>? runs,
    Wrapped<Map<String, dynamic>?>? directions,
    Wrapped<V3Status?>? status,
  }) {
    return V3StoppingPattern(
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      departures: (departures != null ? departures.value : this.departures),
      stops: (stops != null ? stops.value : this.stops),
      routes: (routes != null ? routes.value : this.routes),
      runs: (runs != null ? runs.value : this.runs),
      directions: (directions != null ? directions.value : this.directions),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3PatternDeparture {
  const V3PatternDeparture({
    this.skippedStops,
    this.stopId,
    this.routeId,
    this.runId,
    this.runRef,
    this.directionId,
    this.disruptionIds,
    this.scheduledDepartureUtc,
    this.estimatedDepartureUtc,
    this.atPlatform,
    this.platformNumber,
    this.flags,
    this.departureSequence,
    this.departureNote,
  });

  factory V3PatternDeparture.fromJson(Map<String, dynamic> json) =>
      _$V3PatternDepartureFromJson(json);

  static const toJsonFactory = _$V3PatternDepartureToJson;
  Map<String, dynamic> toJson() => _$V3PatternDepartureToJson(this);

  @JsonKey(name: 'skipped_stops', defaultValue: <V3StopModel>[])
  final List<V3StopModel>? skippedStops;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'run_id')
  final int? runId;
  @JsonKey(name: 'run_ref')
  final String? runRef;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'disruption_ids', defaultValue: <int>[])
  final List<int>? disruptionIds;
  @JsonKey(name: 'scheduled_departure_utc')
  final DateTime? scheduledDepartureUtc;
  @JsonKey(name: 'estimated_departure_utc')
  final DateTime? estimatedDepartureUtc;
  @JsonKey(name: 'at_platform')
  final bool? atPlatform;
  @JsonKey(name: 'platform_number')
  final String? platformNumber;
  @JsonKey(name: 'flags')
  final String? flags;
  @JsonKey(name: 'departure_sequence')
  final int? departureSequence;
  @JsonKey(name: 'departure_note')
  final String? departureNote;
  static const fromJsonFactory = _$V3PatternDepartureFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3PatternDeparture &&
            (identical(other.skippedStops, skippedStops) ||
                const DeepCollectionEquality().equals(
                  other.skippedStops,
                  skippedStops,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.runId, runId) ||
                const DeepCollectionEquality().equals(other.runId, runId)) &&
            (identical(other.runRef, runRef) ||
                const DeepCollectionEquality().equals(other.runRef, runRef)) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.disruptionIds, disruptionIds) ||
                const DeepCollectionEquality().equals(
                  other.disruptionIds,
                  disruptionIds,
                )) &&
            (identical(other.scheduledDepartureUtc, scheduledDepartureUtc) ||
                const DeepCollectionEquality().equals(
                  other.scheduledDepartureUtc,
                  scheduledDepartureUtc,
                )) &&
            (identical(other.estimatedDepartureUtc, estimatedDepartureUtc) ||
                const DeepCollectionEquality().equals(
                  other.estimatedDepartureUtc,
                  estimatedDepartureUtc,
                )) &&
            (identical(other.atPlatform, atPlatform) ||
                const DeepCollectionEquality().equals(
                  other.atPlatform,
                  atPlatform,
                )) &&
            (identical(other.platformNumber, platformNumber) ||
                const DeepCollectionEquality().equals(
                  other.platformNumber,
                  platformNumber,
                )) &&
            (identical(other.flags, flags) ||
                const DeepCollectionEquality().equals(other.flags, flags)) &&
            (identical(other.departureSequence, departureSequence) ||
                const DeepCollectionEquality().equals(
                  other.departureSequence,
                  departureSequence,
                )) &&
            (identical(other.departureNote, departureNote) ||
                const DeepCollectionEquality().equals(
                  other.departureNote,
                  departureNote,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(skippedStops) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(runId) ^
      const DeepCollectionEquality().hash(runRef) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(disruptionIds) ^
      const DeepCollectionEquality().hash(scheduledDepartureUtc) ^
      const DeepCollectionEquality().hash(estimatedDepartureUtc) ^
      const DeepCollectionEquality().hash(atPlatform) ^
      const DeepCollectionEquality().hash(platformNumber) ^
      const DeepCollectionEquality().hash(flags) ^
      const DeepCollectionEquality().hash(departureSequence) ^
      const DeepCollectionEquality().hash(departureNote) ^
      runtimeType.hashCode;
}

extension $V3PatternDepartureExtension on V3PatternDeparture {
  V3PatternDeparture copyWith({
    List<V3StopModel>? skippedStops,
    int? stopId,
    int? routeId,
    int? runId,
    String? runRef,
    int? directionId,
    List<int>? disruptionIds,
    DateTime? scheduledDepartureUtc,
    DateTime? estimatedDepartureUtc,
    bool? atPlatform,
    String? platformNumber,
    String? flags,
    int? departureSequence,
    String? departureNote,
  }) {
    return V3PatternDeparture(
      skippedStops: skippedStops ?? this.skippedStops,
      stopId: stopId ?? this.stopId,
      routeId: routeId ?? this.routeId,
      runId: runId ?? this.runId,
      runRef: runRef ?? this.runRef,
      directionId: directionId ?? this.directionId,
      disruptionIds: disruptionIds ?? this.disruptionIds,
      scheduledDepartureUtc:
          scheduledDepartureUtc ?? this.scheduledDepartureUtc,
      estimatedDepartureUtc:
          estimatedDepartureUtc ?? this.estimatedDepartureUtc,
      atPlatform: atPlatform ?? this.atPlatform,
      platformNumber: platformNumber ?? this.platformNumber,
      flags: flags ?? this.flags,
      departureSequence: departureSequence ?? this.departureSequence,
      departureNote: departureNote ?? this.departureNote,
    );
  }

  V3PatternDeparture copyWithWrapped({
    Wrapped<List<V3StopModel>?>? skippedStops,
    Wrapped<int?>? stopId,
    Wrapped<int?>? routeId,
    Wrapped<int?>? runId,
    Wrapped<String?>? runRef,
    Wrapped<int?>? directionId,
    Wrapped<List<int>?>? disruptionIds,
    Wrapped<DateTime?>? scheduledDepartureUtc,
    Wrapped<DateTime?>? estimatedDepartureUtc,
    Wrapped<bool?>? atPlatform,
    Wrapped<String?>? platformNumber,
    Wrapped<String?>? flags,
    Wrapped<int?>? departureSequence,
    Wrapped<String?>? departureNote,
  }) {
    return V3PatternDeparture(
      skippedStops: (skippedStops != null
          ? skippedStops.value
          : this.skippedStops),
      stopId: (stopId != null ? stopId.value : this.stopId),
      routeId: (routeId != null ? routeId.value : this.routeId),
      runId: (runId != null ? runId.value : this.runId),
      runRef: (runRef != null ? runRef.value : this.runRef),
      directionId: (directionId != null ? directionId.value : this.directionId),
      disruptionIds: (disruptionIds != null
          ? disruptionIds.value
          : this.disruptionIds),
      scheduledDepartureUtc: (scheduledDepartureUtc != null
          ? scheduledDepartureUtc.value
          : this.scheduledDepartureUtc),
      estimatedDepartureUtc: (estimatedDepartureUtc != null
          ? estimatedDepartureUtc.value
          : this.estimatedDepartureUtc),
      atPlatform: (atPlatform != null ? atPlatform.value : this.atPlatform),
      platformNumber: (platformNumber != null
          ? platformNumber.value
          : this.platformNumber),
      flags: (flags != null ? flags.value : this.flags),
      departureSequence: (departureSequence != null
          ? departureSequence.value
          : this.departureSequence),
      departureNote: (departureNote != null
          ? departureNote.value
          : this.departureNote),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StoppingPatternStop {
  const V3StoppingPatternStop({
    this.stopTicket,
    this.stopDistance,
    this.stopSuburb,
    this.stopName,
    this.stopId,
    this.routeType,
    this.stopLatitude,
    this.stopLongitude,
    this.stopLandmark,
    this.stopSequence,
  });

  factory V3StoppingPatternStop.fromJson(Map<String, dynamic> json) =>
      _$V3StoppingPatternStopFromJson(json);

  static const toJsonFactory = _$V3StoppingPatternStopToJson;
  Map<String, dynamic> toJson() => _$V3StoppingPatternStopToJson(this);

  @JsonKey(name: 'stop_ticket')
  final V3StopTicket? stopTicket;
  @JsonKey(name: 'stop_distance')
  final double? stopDistance;
  @JsonKey(name: 'stop_suburb')
  final String? stopSuburb;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'stop_latitude')
  final double? stopLatitude;
  @JsonKey(name: 'stop_longitude')
  final double? stopLongitude;
  @JsonKey(name: 'stop_landmark')
  final String? stopLandmark;
  @JsonKey(name: 'stop_sequence')
  final int? stopSequence;
  static const fromJsonFactory = _$V3StoppingPatternStopFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StoppingPatternStop &&
            (identical(other.stopTicket, stopTicket) ||
                const DeepCollectionEquality().equals(
                  other.stopTicket,
                  stopTicket,
                )) &&
            (identical(other.stopDistance, stopDistance) ||
                const DeepCollectionEquality().equals(
                  other.stopDistance,
                  stopDistance,
                )) &&
            (identical(other.stopSuburb, stopSuburb) ||
                const DeepCollectionEquality().equals(
                  other.stopSuburb,
                  stopSuburb,
                )) &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.stopLatitude, stopLatitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLatitude,
                  stopLatitude,
                )) &&
            (identical(other.stopLongitude, stopLongitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLongitude,
                  stopLongitude,
                )) &&
            (identical(other.stopLandmark, stopLandmark) ||
                const DeepCollectionEquality().equals(
                  other.stopLandmark,
                  stopLandmark,
                )) &&
            (identical(other.stopSequence, stopSequence) ||
                const DeepCollectionEquality().equals(
                  other.stopSequence,
                  stopSequence,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopTicket) ^
      const DeepCollectionEquality().hash(stopDistance) ^
      const DeepCollectionEquality().hash(stopSuburb) ^
      const DeepCollectionEquality().hash(stopName) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(stopLatitude) ^
      const DeepCollectionEquality().hash(stopLongitude) ^
      const DeepCollectionEquality().hash(stopLandmark) ^
      const DeepCollectionEquality().hash(stopSequence) ^
      runtimeType.hashCode;
}

extension $V3StoppingPatternStopExtension on V3StoppingPatternStop {
  V3StoppingPatternStop copyWith({
    V3StopTicket? stopTicket,
    double? stopDistance,
    String? stopSuburb,
    String? stopName,
    int? stopId,
    int? routeType,
    double? stopLatitude,
    double? stopLongitude,
    String? stopLandmark,
    int? stopSequence,
  }) {
    return V3StoppingPatternStop(
      stopTicket: stopTicket ?? this.stopTicket,
      stopDistance: stopDistance ?? this.stopDistance,
      stopSuburb: stopSuburb ?? this.stopSuburb,
      stopName: stopName ?? this.stopName,
      stopId: stopId ?? this.stopId,
      routeType: routeType ?? this.routeType,
      stopLatitude: stopLatitude ?? this.stopLatitude,
      stopLongitude: stopLongitude ?? this.stopLongitude,
      stopLandmark: stopLandmark ?? this.stopLandmark,
      stopSequence: stopSequence ?? this.stopSequence,
    );
  }

  V3StoppingPatternStop copyWithWrapped({
    Wrapped<V3StopTicket?>? stopTicket,
    Wrapped<double?>? stopDistance,
    Wrapped<String?>? stopSuburb,
    Wrapped<String?>? stopName,
    Wrapped<int?>? stopId,
    Wrapped<int?>? routeType,
    Wrapped<double?>? stopLatitude,
    Wrapped<double?>? stopLongitude,
    Wrapped<String?>? stopLandmark,
    Wrapped<int?>? stopSequence,
  }) {
    return V3StoppingPatternStop(
      stopTicket: (stopTicket != null ? stopTicket.value : this.stopTicket),
      stopDistance: (stopDistance != null
          ? stopDistance.value
          : this.stopDistance),
      stopSuburb: (stopSuburb != null ? stopSuburb.value : this.stopSuburb),
      stopName: (stopName != null ? stopName.value : this.stopName),
      stopId: (stopId != null ? stopId.value : this.stopId),
      routeType: (routeType != null ? routeType.value : this.routeType),
      stopLatitude: (stopLatitude != null
          ? stopLatitude.value
          : this.stopLatitude),
      stopLongitude: (stopLongitude != null
          ? stopLongitude.value
          : this.stopLongitude),
      stopLandmark: (stopLandmark != null
          ? stopLandmark.value
          : this.stopLandmark),
      stopSequence: (stopSequence != null
          ? stopSequence.value
          : this.stopSequence),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3PeriodsResponse {
  const V3PeriodsResponse({this.periods, this.status});

  factory V3PeriodsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3PeriodsResponseFromJson(json);

  static const toJsonFactory = _$V3PeriodsResponseToJson;
  Map<String, dynamic> toJson() => _$V3PeriodsResponseToJson(this);

  @JsonKey(name: 'periods', defaultValue: <Object>[])
  final List<Object>? periods;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3PeriodsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3PeriodsResponse &&
            (identical(other.periods, periods) ||
                const DeepCollectionEquality().equals(
                  other.periods,
                  periods,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(periods) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3PeriodsResponseExtension on V3PeriodsResponse {
  V3PeriodsResponse copyWith({List<Object>? periods, V3Status? status}) {
    return V3PeriodsResponse(
      periods: periods ?? this.periods,
      status: status ?? this.status,
    );
  }

  V3PeriodsResponse copyWithWrapped({
    Wrapped<List<Object>?>? periods,
    Wrapped<V3Status?>? status,
  }) {
    return V3PeriodsResponse(
      periods: (periods != null ? periods.value : this.periods),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RouteResponse {
  const V3RouteResponse({this.route, this.status});

  factory V3RouteResponse.fromJson(Map<String, dynamic> json) =>
      _$V3RouteResponseFromJson(json);

  static const toJsonFactory = _$V3RouteResponseToJson;
  Map<String, dynamic> toJson() => _$V3RouteResponseToJson(this);

  @JsonKey(name: 'route')
  final V3RouteWithStatus? route;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3RouteResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RouteResponse &&
            (identical(other.route, route) ||
                const DeepCollectionEquality().equals(other.route, route)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(route) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3RouteResponseExtension on V3RouteResponse {
  V3RouteResponse copyWith({V3RouteWithStatus? route, V3Status? status}) {
    return V3RouteResponse(
      route: route ?? this.route,
      status: status ?? this.status,
    );
  }

  V3RouteResponse copyWithWrapped({
    Wrapped<V3RouteWithStatus?>? route,
    Wrapped<V3Status?>? status,
  }) {
    return V3RouteResponse(
      route: (route != null ? route.value : this.route),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RouteWithStatus {
  const V3RouteWithStatus({
    this.routeServiceStatus,
    this.routeType,
    this.routeId,
    this.routeName,
    this.routeNumber,
    this.routeGtfsId,
    this.geopath,
  });

  factory V3RouteWithStatus.fromJson(Map<String, dynamic> json) =>
      _$V3RouteWithStatusFromJson(json);

  static const toJsonFactory = _$V3RouteWithStatusToJson;
  Map<String, dynamic> toJson() => _$V3RouteWithStatusToJson(this);

  @JsonKey(name: 'route_service_status')
  final V3RouteServiceStatus? routeServiceStatus;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'route_name')
  final String? routeName;
  @JsonKey(name: 'route_number')
  final String? routeNumber;
  @JsonKey(name: 'route_gtfs_id')
  final String? routeGtfsId;
  @JsonKey(name: 'geopath', defaultValue: <Object>[])
  final List<Object>? geopath;
  static const fromJsonFactory = _$V3RouteWithStatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RouteWithStatus &&
            (identical(other.routeServiceStatus, routeServiceStatus) ||
                const DeepCollectionEquality().equals(
                  other.routeServiceStatus,
                  routeServiceStatus,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.routeName, routeName) ||
                const DeepCollectionEquality().equals(
                  other.routeName,
                  routeName,
                )) &&
            (identical(other.routeNumber, routeNumber) ||
                const DeepCollectionEquality().equals(
                  other.routeNumber,
                  routeNumber,
                )) &&
            (identical(other.routeGtfsId, routeGtfsId) ||
                const DeepCollectionEquality().equals(
                  other.routeGtfsId,
                  routeGtfsId,
                )) &&
            (identical(other.geopath, geopath) ||
                const DeepCollectionEquality().equals(other.geopath, geopath)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeServiceStatus) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(routeName) ^
      const DeepCollectionEquality().hash(routeNumber) ^
      const DeepCollectionEquality().hash(routeGtfsId) ^
      const DeepCollectionEquality().hash(geopath) ^
      runtimeType.hashCode;
}

extension $V3RouteWithStatusExtension on V3RouteWithStatus {
  V3RouteWithStatus copyWith({
    V3RouteServiceStatus? routeServiceStatus,
    int? routeType,
    int? routeId,
    String? routeName,
    String? routeNumber,
    String? routeGtfsId,
    List<Object>? geopath,
  }) {
    return V3RouteWithStatus(
      routeServiceStatus: routeServiceStatus ?? this.routeServiceStatus,
      routeType: routeType ?? this.routeType,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      routeNumber: routeNumber ?? this.routeNumber,
      routeGtfsId: routeGtfsId ?? this.routeGtfsId,
      geopath: geopath ?? this.geopath,
    );
  }

  V3RouteWithStatus copyWithWrapped({
    Wrapped<V3RouteServiceStatus?>? routeServiceStatus,
    Wrapped<int?>? routeType,
    Wrapped<int?>? routeId,
    Wrapped<String?>? routeName,
    Wrapped<String?>? routeNumber,
    Wrapped<String?>? routeGtfsId,
    Wrapped<List<Object>?>? geopath,
  }) {
    return V3RouteWithStatus(
      routeServiceStatus: (routeServiceStatus != null
          ? routeServiceStatus.value
          : this.routeServiceStatus),
      routeType: (routeType != null ? routeType.value : this.routeType),
      routeId: (routeId != null ? routeId.value : this.routeId),
      routeName: (routeName != null ? routeName.value : this.routeName),
      routeNumber: (routeNumber != null ? routeNumber.value : this.routeNumber),
      routeGtfsId: (routeGtfsId != null ? routeGtfsId.value : this.routeGtfsId),
      geopath: (geopath != null ? geopath.value : this.geopath),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RouteServiceStatus {
  const V3RouteServiceStatus({this.description, this.timestamp});

  factory V3RouteServiceStatus.fromJson(Map<String, dynamic> json) =>
      _$V3RouteServiceStatusFromJson(json);

  static const toJsonFactory = _$V3RouteServiceStatusToJson;
  Map<String, dynamic> toJson() => _$V3RouteServiceStatusToJson(this);

  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'timestamp')
  final DateTime? timestamp;
  static const fromJsonFactory = _$V3RouteServiceStatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RouteServiceStatus &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.timestamp, timestamp) ||
                const DeepCollectionEquality().equals(
                  other.timestamp,
                  timestamp,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(timestamp) ^
      runtimeType.hashCode;
}

extension $V3RouteServiceStatusExtension on V3RouteServiceStatus {
  V3RouteServiceStatus copyWith({String? description, DateTime? timestamp}) {
    return V3RouteServiceStatus(
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  V3RouteServiceStatus copyWithWrapped({
    Wrapped<String?>? description,
    Wrapped<DateTime?>? timestamp,
  }) {
    return V3RouteServiceStatus(
      description: (description != null ? description.value : this.description),
      timestamp: (timestamp != null ? timestamp.value : this.timestamp),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RouteTypesResponse {
  const V3RouteTypesResponse({this.routeTypes, this.status});

  factory V3RouteTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$V3RouteTypesResponseFromJson(json);

  static const toJsonFactory = _$V3RouteTypesResponseToJson;
  Map<String, dynamic> toJson() => _$V3RouteTypesResponseToJson(this);

  @JsonKey(name: 'route_types', defaultValue: <V3RouteType>[])
  final List<V3RouteType>? routeTypes;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3RouteTypesResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RouteTypesResponse &&
            (identical(other.routeTypes, routeTypes) ||
                const DeepCollectionEquality().equals(
                  other.routeTypes,
                  routeTypes,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeTypes) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3RouteTypesResponseExtension on V3RouteTypesResponse {
  V3RouteTypesResponse copyWith({
    List<V3RouteType>? routeTypes,
    V3Status? status,
  }) {
    return V3RouteTypesResponse(
      routeTypes: routeTypes ?? this.routeTypes,
      status: status ?? this.status,
    );
  }

  V3RouteTypesResponse copyWithWrapped({
    Wrapped<List<V3RouteType>?>? routeTypes,
    Wrapped<V3Status?>? status,
  }) {
    return V3RouteTypesResponse(
      routeTypes: (routeTypes != null ? routeTypes.value : this.routeTypes),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RouteType {
  const V3RouteType({this.routeTypeName, this.routeType});

  factory V3RouteType.fromJson(Map<String, dynamic> json) =>
      _$V3RouteTypeFromJson(json);

  static const toJsonFactory = _$V3RouteTypeToJson;
  Map<String, dynamic> toJson() => _$V3RouteTypeToJson(this);

  @JsonKey(name: 'route_type_name')
  final String? routeTypeName;
  @JsonKey(name: 'route_type')
  final int? routeType;
  static const fromJsonFactory = _$V3RouteTypeFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RouteType &&
            (identical(other.routeTypeName, routeTypeName) ||
                const DeepCollectionEquality().equals(
                  other.routeTypeName,
                  routeTypeName,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeTypeName) ^
      const DeepCollectionEquality().hash(routeType) ^
      runtimeType.hashCode;
}

extension $V3RouteTypeExtension on V3RouteType {
  V3RouteType copyWith({String? routeTypeName, int? routeType}) {
    return V3RouteType(
      routeTypeName: routeTypeName ?? this.routeTypeName,
      routeType: routeType ?? this.routeType,
    );
  }

  V3RouteType copyWithWrapped({
    Wrapped<String?>? routeTypeName,
    Wrapped<int?>? routeType,
  }) {
    return V3RouteType(
      routeTypeName: (routeTypeName != null
          ? routeTypeName.value
          : this.routeTypeName),
      routeType: (routeType != null ? routeType.value : this.routeType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RunsBroadParameters {
  const V3RunsBroadParameters({
    this.expand,
    this.dateUtc,
    this.includeAdvertisedInterchange,
  });

  factory V3RunsBroadParameters.fromJson(Map<String, dynamic> json) =>
      _$V3RunsBroadParametersFromJson(json);

  static const toJsonFactory = _$V3RunsBroadParametersToJson;
  Map<String, dynamic> toJson() => _$V3RunsBroadParametersToJson(this);

  @JsonKey(name: 'expand', defaultValue: <int>[])
  final List<int>? expand;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'include_advertised_interchange')
  final bool? includeAdvertisedInterchange;
  static const fromJsonFactory = _$V3RunsBroadParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RunsBroadParameters &&
            (identical(other.expand, expand) ||
                const DeepCollectionEquality().equals(other.expand, expand)) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                ) ||
                const DeepCollectionEquality().equals(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(expand) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(includeAdvertisedInterchange) ^
      runtimeType.hashCode;
}

extension $V3RunsBroadParametersExtension on V3RunsBroadParameters {
  V3RunsBroadParameters copyWith({
    List<int>? expand,
    DateTime? dateUtc,
    bool? includeAdvertisedInterchange,
  }) {
    return V3RunsBroadParameters(
      expand: expand ?? this.expand,
      dateUtc: dateUtc ?? this.dateUtc,
      includeAdvertisedInterchange:
          includeAdvertisedInterchange ?? this.includeAdvertisedInterchange,
    );
  }

  V3RunsBroadParameters copyWithWrapped({
    Wrapped<List<int>?>? expand,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<bool?>? includeAdvertisedInterchange,
  }) {
    return V3RunsBroadParameters(
      expand: (expand != null ? expand.value : this.expand),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      includeAdvertisedInterchange: (includeAdvertisedInterchange != null
          ? includeAdvertisedInterchange.value
          : this.includeAdvertisedInterchange),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RunsResponse {
  const V3RunsResponse({this.runs, this.status});

  factory V3RunsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3RunsResponseFromJson(json);

  static const toJsonFactory = _$V3RunsResponseToJson;
  Map<String, dynamic> toJson() => _$V3RunsResponseToJson(this);

  @JsonKey(name: 'runs', defaultValue: <V3Run>[])
  final List<V3Run>? runs;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3RunsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RunsResponse &&
            (identical(other.runs, runs) ||
                const DeepCollectionEquality().equals(other.runs, runs)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(runs) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3RunsResponseExtension on V3RunsResponse {
  V3RunsResponse copyWith({List<V3Run>? runs, V3Status? status}) {
    return V3RunsResponse(
      runs: runs ?? this.runs,
      status: status ?? this.status,
    );
  }

  V3RunsResponse copyWithWrapped({
    Wrapped<List<V3Run>?>? runs,
    Wrapped<V3Status?>? status,
  }) {
    return V3RunsResponse(
      runs: (runs != null ? runs.value : this.runs),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RunsSpecificParameters {
  const V3RunsSpecificParameters({
    this.includeGeopath,
    this.expand,
    this.dateUtc,
    this.includeAdvertisedInterchange,
  });

  factory V3RunsSpecificParameters.fromJson(Map<String, dynamic> json) =>
      _$V3RunsSpecificParametersFromJson(json);

  static const toJsonFactory = _$V3RunsSpecificParametersToJson;
  Map<String, dynamic> toJson() => _$V3RunsSpecificParametersToJson(this);

  @JsonKey(name: 'include_geopath')
  final bool? includeGeopath;
  @JsonKey(name: 'expand', defaultValue: <int>[])
  final List<int>? expand;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'include_advertised_interchange')
  final bool? includeAdvertisedInterchange;
  static const fromJsonFactory = _$V3RunsSpecificParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RunsSpecificParameters &&
            (identical(other.includeGeopath, includeGeopath) ||
                const DeepCollectionEquality().equals(
                  other.includeGeopath,
                  includeGeopath,
                )) &&
            (identical(other.expand, expand) ||
                const DeepCollectionEquality().equals(other.expand, expand)) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                ) ||
                const DeepCollectionEquality().equals(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(includeGeopath) ^
      const DeepCollectionEquality().hash(expand) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(includeAdvertisedInterchange) ^
      runtimeType.hashCode;
}

extension $V3RunsSpecificParametersExtension on V3RunsSpecificParameters {
  V3RunsSpecificParameters copyWith({
    bool? includeGeopath,
    List<int>? expand,
    DateTime? dateUtc,
    bool? includeAdvertisedInterchange,
  }) {
    return V3RunsSpecificParameters(
      includeGeopath: includeGeopath ?? this.includeGeopath,
      expand: expand ?? this.expand,
      dateUtc: dateUtc ?? this.dateUtc,
      includeAdvertisedInterchange:
          includeAdvertisedInterchange ?? this.includeAdvertisedInterchange,
    );
  }

  V3RunsSpecificParameters copyWithWrapped({
    Wrapped<bool?>? includeGeopath,
    Wrapped<List<int>?>? expand,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<bool?>? includeAdvertisedInterchange,
  }) {
    return V3RunsSpecificParameters(
      includeGeopath: (includeGeopath != null
          ? includeGeopath.value
          : this.includeGeopath),
      expand: (expand != null ? expand.value : this.expand),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      includeAdvertisedInterchange: (includeAdvertisedInterchange != null
          ? includeAdvertisedInterchange.value
          : this.includeAdvertisedInterchange),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RunAndRouteTypeParameters {
  const V3RunAndRouteTypeParameters({
    this.expand,
    this.dateUtc,
    this.includeGeopath,
  });

  factory V3RunAndRouteTypeParameters.fromJson(Map<String, dynamic> json) =>
      _$V3RunAndRouteTypeParametersFromJson(json);

  static const toJsonFactory = _$V3RunAndRouteTypeParametersToJson;
  Map<String, dynamic> toJson() => _$V3RunAndRouteTypeParametersToJson(this);

  @JsonKey(name: 'expand', defaultValue: <int>[])
  final List<int>? expand;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'include_geopath')
  final bool? includeGeopath;
  static const fromJsonFactory = _$V3RunAndRouteTypeParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RunAndRouteTypeParameters &&
            (identical(other.expand, expand) ||
                const DeepCollectionEquality().equals(other.expand, expand)) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(other.includeGeopath, includeGeopath) ||
                const DeepCollectionEquality().equals(
                  other.includeGeopath,
                  includeGeopath,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(expand) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(includeGeopath) ^
      runtimeType.hashCode;
}

extension $V3RunAndRouteTypeParametersExtension on V3RunAndRouteTypeParameters {
  V3RunAndRouteTypeParameters copyWith({
    List<int>? expand,
    DateTime? dateUtc,
    bool? includeGeopath,
  }) {
    return V3RunAndRouteTypeParameters(
      expand: expand ?? this.expand,
      dateUtc: dateUtc ?? this.dateUtc,
      includeGeopath: includeGeopath ?? this.includeGeopath,
    );
  }

  V3RunAndRouteTypeParameters copyWithWrapped({
    Wrapped<List<int>?>? expand,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<bool?>? includeGeopath,
  }) {
    return V3RunAndRouteTypeParameters(
      expand: (expand != null ? expand.value : this.expand),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      includeGeopath: (includeGeopath != null
          ? includeGeopath.value
          : this.includeGeopath),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3RunResponse {
  const V3RunResponse({this.run, this.status});

  factory V3RunResponse.fromJson(Map<String, dynamic> json) =>
      _$V3RunResponseFromJson(json);

  static const toJsonFactory = _$V3RunResponseToJson;
  Map<String, dynamic> toJson() => _$V3RunResponseToJson(this);

  @JsonKey(name: 'run')
  final V3Run? run;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3RunResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3RunResponse &&
            (identical(other.run, run) ||
                const DeepCollectionEquality().equals(other.run, run)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(run) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3RunResponseExtension on V3RunResponse {
  V3RunResponse copyWith({V3Run? run, V3Status? status}) {
    return V3RunResponse(run: run ?? this.run, status: status ?? this.status);
  }

  V3RunResponse copyWithWrapped({
    Wrapped<V3Run?>? run,
    Wrapped<V3Status?>? status,
  }) {
    return V3RunResponse(
      run: (run != null ? run.value : this.run),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SearchParameters {
  const V3SearchParameters({
    this.routeTypes,
    this.latitude,
    this.longitude,
    this.maxDistance,
    this.includeAddresses,
    this.includeOutlets,
    this.matchStopBySuburb,
    this.matchRouteBySuburb,
    this.matchStopByGtfsStopId,
  });

  factory V3SearchParameters.fromJson(Map<String, dynamic> json) =>
      _$V3SearchParametersFromJson(json);

  static const toJsonFactory = _$V3SearchParametersToJson;
  Map<String, dynamic> toJson() => _$V3SearchParametersToJson(this);

  @JsonKey(name: 'route_types', defaultValue: <int>[])
  final List<int>? routeTypes;
  @JsonKey(name: 'latitude')
  final double? latitude;
  @JsonKey(name: 'longitude')
  final double? longitude;
  @JsonKey(name: 'max_distance')
  final double? maxDistance;
  @JsonKey(name: 'include_addresses')
  final bool? includeAddresses;
  @JsonKey(name: 'include_outlets')
  final bool? includeOutlets;
  @JsonKey(name: 'match_stop_by_suburb')
  final bool? matchStopBySuburb;
  @JsonKey(name: 'match_route_by_suburb')
  final bool? matchRouteBySuburb;
  @JsonKey(name: 'match_stop_by_gtfs_stop_id')
  final bool? matchStopByGtfsStopId;
  static const fromJsonFactory = _$V3SearchParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SearchParameters &&
            (identical(other.routeTypes, routeTypes) ||
                const DeepCollectionEquality().equals(
                  other.routeTypes,
                  routeTypes,
                )) &&
            (identical(other.latitude, latitude) ||
                const DeepCollectionEquality().equals(
                  other.latitude,
                  latitude,
                )) &&
            (identical(other.longitude, longitude) ||
                const DeepCollectionEquality().equals(
                  other.longitude,
                  longitude,
                )) &&
            (identical(other.maxDistance, maxDistance) ||
                const DeepCollectionEquality().equals(
                  other.maxDistance,
                  maxDistance,
                )) &&
            (identical(other.includeAddresses, includeAddresses) ||
                const DeepCollectionEquality().equals(
                  other.includeAddresses,
                  includeAddresses,
                )) &&
            (identical(other.includeOutlets, includeOutlets) ||
                const DeepCollectionEquality().equals(
                  other.includeOutlets,
                  includeOutlets,
                )) &&
            (identical(other.matchStopBySuburb, matchStopBySuburb) ||
                const DeepCollectionEquality().equals(
                  other.matchStopBySuburb,
                  matchStopBySuburb,
                )) &&
            (identical(other.matchRouteBySuburb, matchRouteBySuburb) ||
                const DeepCollectionEquality().equals(
                  other.matchRouteBySuburb,
                  matchRouteBySuburb,
                )) &&
            (identical(other.matchStopByGtfsStopId, matchStopByGtfsStopId) ||
                const DeepCollectionEquality().equals(
                  other.matchStopByGtfsStopId,
                  matchStopByGtfsStopId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeTypes) ^
      const DeepCollectionEquality().hash(latitude) ^
      const DeepCollectionEquality().hash(longitude) ^
      const DeepCollectionEquality().hash(maxDistance) ^
      const DeepCollectionEquality().hash(includeAddresses) ^
      const DeepCollectionEquality().hash(includeOutlets) ^
      const DeepCollectionEquality().hash(matchStopBySuburb) ^
      const DeepCollectionEquality().hash(matchRouteBySuburb) ^
      const DeepCollectionEquality().hash(matchStopByGtfsStopId) ^
      runtimeType.hashCode;
}

extension $V3SearchParametersExtension on V3SearchParameters {
  V3SearchParameters copyWith({
    List<int>? routeTypes,
    double? latitude,
    double? longitude,
    double? maxDistance,
    bool? includeAddresses,
    bool? includeOutlets,
    bool? matchStopBySuburb,
    bool? matchRouteBySuburb,
    bool? matchStopByGtfsStopId,
  }) {
    return V3SearchParameters(
      routeTypes: routeTypes ?? this.routeTypes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxDistance: maxDistance ?? this.maxDistance,
      includeAddresses: includeAddresses ?? this.includeAddresses,
      includeOutlets: includeOutlets ?? this.includeOutlets,
      matchStopBySuburb: matchStopBySuburb ?? this.matchStopBySuburb,
      matchRouteBySuburb: matchRouteBySuburb ?? this.matchRouteBySuburb,
      matchStopByGtfsStopId:
          matchStopByGtfsStopId ?? this.matchStopByGtfsStopId,
    );
  }

  V3SearchParameters copyWithWrapped({
    Wrapped<List<int>?>? routeTypes,
    Wrapped<double?>? latitude,
    Wrapped<double?>? longitude,
    Wrapped<double?>? maxDistance,
    Wrapped<bool?>? includeAddresses,
    Wrapped<bool?>? includeOutlets,
    Wrapped<bool?>? matchStopBySuburb,
    Wrapped<bool?>? matchRouteBySuburb,
    Wrapped<bool?>? matchStopByGtfsStopId,
  }) {
    return V3SearchParameters(
      routeTypes: (routeTypes != null ? routeTypes.value : this.routeTypes),
      latitude: (latitude != null ? latitude.value : this.latitude),
      longitude: (longitude != null ? longitude.value : this.longitude),
      maxDistance: (maxDistance != null ? maxDistance.value : this.maxDistance),
      includeAddresses: (includeAddresses != null
          ? includeAddresses.value
          : this.includeAddresses),
      includeOutlets: (includeOutlets != null
          ? includeOutlets.value
          : this.includeOutlets),
      matchStopBySuburb: (matchStopBySuburb != null
          ? matchStopBySuburb.value
          : this.matchStopBySuburb),
      matchRouteBySuburb: (matchRouteBySuburb != null
          ? matchRouteBySuburb.value
          : this.matchRouteBySuburb),
      matchStopByGtfsStopId: (matchStopByGtfsStopId != null
          ? matchStopByGtfsStopId.value
          : this.matchStopByGtfsStopId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SearchResult {
  const V3SearchResult({this.stops, this.routes, this.outlets, this.status});

  factory V3SearchResult.fromJson(Map<String, dynamic> json) =>
      _$V3SearchResultFromJson(json);

  static const toJsonFactory = _$V3SearchResultToJson;
  Map<String, dynamic> toJson() => _$V3SearchResultToJson(this);

  @JsonKey(name: 'stops', defaultValue: <V3ResultStop>[])
  final List<V3ResultStop>? stops;
  @JsonKey(name: 'routes', defaultValue: <V3ResultRoute>[])
  final List<V3ResultRoute>? routes;
  @JsonKey(name: 'outlets', defaultValue: <V3ResultOutlet>[])
  final List<V3ResultOutlet>? outlets;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3SearchResultFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SearchResult &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)) &&
            (identical(other.routes, routes) ||
                const DeepCollectionEquality().equals(other.routes, routes)) &&
            (identical(other.outlets, outlets) ||
                const DeepCollectionEquality().equals(
                  other.outlets,
                  outlets,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stops) ^
      const DeepCollectionEquality().hash(routes) ^
      const DeepCollectionEquality().hash(outlets) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3SearchResultExtension on V3SearchResult {
  V3SearchResult copyWith({
    List<V3ResultStop>? stops,
    List<V3ResultRoute>? routes,
    List<V3ResultOutlet>? outlets,
    V3Status? status,
  }) {
    return V3SearchResult(
      stops: stops ?? this.stops,
      routes: routes ?? this.routes,
      outlets: outlets ?? this.outlets,
      status: status ?? this.status,
    );
  }

  V3SearchResult copyWithWrapped({
    Wrapped<List<V3ResultStop>?>? stops,
    Wrapped<List<V3ResultRoute>?>? routes,
    Wrapped<List<V3ResultOutlet>?>? outlets,
    Wrapped<V3Status?>? status,
  }) {
    return V3SearchResult(
      stops: (stops != null ? stops.value : this.stops),
      routes: (routes != null ? routes.value : this.routes),
      outlets: (outlets != null ? outlets.value : this.outlets),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3ResultStop {
  const V3ResultStop({
    this.stopDistance,
    this.stopSuburb,
    this.routeType,
    this.routes,
    this.stopLatitude,
    this.stopLongitude,
    this.stopSequence,
    this.stopId,
    this.stopName,
    this.stopLandmark,
  });

  factory V3ResultStop.fromJson(Map<String, dynamic> json) =>
      _$V3ResultStopFromJson(json);

  static const toJsonFactory = _$V3ResultStopToJson;
  Map<String, dynamic> toJson() => _$V3ResultStopToJson(this);

  @JsonKey(name: 'stop_distance')
  final double? stopDistance;
  @JsonKey(name: 'stop_suburb')
  final String? stopSuburb;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'routes', defaultValue: <V3ResultRoute>[])
  final List<V3ResultRoute>? routes;
  @JsonKey(name: 'stop_latitude')
  final double? stopLatitude;
  @JsonKey(name: 'stop_longitude')
  final double? stopLongitude;
  @JsonKey(name: 'stop_sequence')
  final int? stopSequence;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  @JsonKey(name: 'stop_landmark')
  final String? stopLandmark;
  static const fromJsonFactory = _$V3ResultStopFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3ResultStop &&
            (identical(other.stopDistance, stopDistance) ||
                const DeepCollectionEquality().equals(
                  other.stopDistance,
                  stopDistance,
                )) &&
            (identical(other.stopSuburb, stopSuburb) ||
                const DeepCollectionEquality().equals(
                  other.stopSuburb,
                  stopSuburb,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.routes, routes) ||
                const DeepCollectionEquality().equals(other.routes, routes)) &&
            (identical(other.stopLatitude, stopLatitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLatitude,
                  stopLatitude,
                )) &&
            (identical(other.stopLongitude, stopLongitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLongitude,
                  stopLongitude,
                )) &&
            (identical(other.stopSequence, stopSequence) ||
                const DeepCollectionEquality().equals(
                  other.stopSequence,
                  stopSequence,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )) &&
            (identical(other.stopLandmark, stopLandmark) ||
                const DeepCollectionEquality().equals(
                  other.stopLandmark,
                  stopLandmark,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopDistance) ^
      const DeepCollectionEquality().hash(stopSuburb) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(routes) ^
      const DeepCollectionEquality().hash(stopLatitude) ^
      const DeepCollectionEquality().hash(stopLongitude) ^
      const DeepCollectionEquality().hash(stopSequence) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(stopName) ^
      const DeepCollectionEquality().hash(stopLandmark) ^
      runtimeType.hashCode;
}

extension $V3ResultStopExtension on V3ResultStop {
  V3ResultStop copyWith({
    double? stopDistance,
    String? stopSuburb,
    int? routeType,
    List<V3ResultRoute>? routes,
    double? stopLatitude,
    double? stopLongitude,
    int? stopSequence,
    int? stopId,
    String? stopName,
    String? stopLandmark,
  }) {
    return V3ResultStop(
      stopDistance: stopDistance ?? this.stopDistance,
      stopSuburb: stopSuburb ?? this.stopSuburb,
      routeType: routeType ?? this.routeType,
      routes: routes ?? this.routes,
      stopLatitude: stopLatitude ?? this.stopLatitude,
      stopLongitude: stopLongitude ?? this.stopLongitude,
      stopSequence: stopSequence ?? this.stopSequence,
      stopId: stopId ?? this.stopId,
      stopName: stopName ?? this.stopName,
      stopLandmark: stopLandmark ?? this.stopLandmark,
    );
  }

  V3ResultStop copyWithWrapped({
    Wrapped<double?>? stopDistance,
    Wrapped<String?>? stopSuburb,
    Wrapped<int?>? routeType,
    Wrapped<List<V3ResultRoute>?>? routes,
    Wrapped<double?>? stopLatitude,
    Wrapped<double?>? stopLongitude,
    Wrapped<int?>? stopSequence,
    Wrapped<int?>? stopId,
    Wrapped<String?>? stopName,
    Wrapped<String?>? stopLandmark,
  }) {
    return V3ResultStop(
      stopDistance: (stopDistance != null
          ? stopDistance.value
          : this.stopDistance),
      stopSuburb: (stopSuburb != null ? stopSuburb.value : this.stopSuburb),
      routeType: (routeType != null ? routeType.value : this.routeType),
      routes: (routes != null ? routes.value : this.routes),
      stopLatitude: (stopLatitude != null
          ? stopLatitude.value
          : this.stopLatitude),
      stopLongitude: (stopLongitude != null
          ? stopLongitude.value
          : this.stopLongitude),
      stopSequence: (stopSequence != null
          ? stopSequence.value
          : this.stopSequence),
      stopId: (stopId != null ? stopId.value : this.stopId),
      stopName: (stopName != null ? stopName.value : this.stopName),
      stopLandmark: (stopLandmark != null
          ? stopLandmark.value
          : this.stopLandmark),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3ResultRoute {
  const V3ResultRoute({
    this.routeName,
    this.routeNumber,
    this.routeType,
    this.routeId,
    this.routeGtfsId,
    this.routeServiceStatus,
  });

  factory V3ResultRoute.fromJson(Map<String, dynamic> json) =>
      _$V3ResultRouteFromJson(json);

  static const toJsonFactory = _$V3ResultRouteToJson;
  Map<String, dynamic> toJson() => _$V3ResultRouteToJson(this);

  @JsonKey(name: 'route_name')
  final String? routeName;
  @JsonKey(name: 'route_number')
  final String? routeNumber;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'route_gtfs_id')
  final String? routeGtfsId;
  @JsonKey(name: 'route_service_status')
  final V3RouteServiceStatus? routeServiceStatus;
  static const fromJsonFactory = _$V3ResultRouteFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3ResultRoute &&
            (identical(other.routeName, routeName) ||
                const DeepCollectionEquality().equals(
                  other.routeName,
                  routeName,
                )) &&
            (identical(other.routeNumber, routeNumber) ||
                const DeepCollectionEquality().equals(
                  other.routeNumber,
                  routeNumber,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.routeGtfsId, routeGtfsId) ||
                const DeepCollectionEquality().equals(
                  other.routeGtfsId,
                  routeGtfsId,
                )) &&
            (identical(other.routeServiceStatus, routeServiceStatus) ||
                const DeepCollectionEquality().equals(
                  other.routeServiceStatus,
                  routeServiceStatus,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeName) ^
      const DeepCollectionEquality().hash(routeNumber) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(routeGtfsId) ^
      const DeepCollectionEquality().hash(routeServiceStatus) ^
      runtimeType.hashCode;
}

extension $V3ResultRouteExtension on V3ResultRoute {
  V3ResultRoute copyWith({
    String? routeName,
    String? routeNumber,
    int? routeType,
    int? routeId,
    String? routeGtfsId,
    V3RouteServiceStatus? routeServiceStatus,
  }) {
    return V3ResultRoute(
      routeName: routeName ?? this.routeName,
      routeNumber: routeNumber ?? this.routeNumber,
      routeType: routeType ?? this.routeType,
      routeId: routeId ?? this.routeId,
      routeGtfsId: routeGtfsId ?? this.routeGtfsId,
      routeServiceStatus: routeServiceStatus ?? this.routeServiceStatus,
    );
  }

  V3ResultRoute copyWithWrapped({
    Wrapped<String?>? routeName,
    Wrapped<String?>? routeNumber,
    Wrapped<int?>? routeType,
    Wrapped<int?>? routeId,
    Wrapped<String?>? routeGtfsId,
    Wrapped<V3RouteServiceStatus?>? routeServiceStatus,
  }) {
    return V3ResultRoute(
      routeName: (routeName != null ? routeName.value : this.routeName),
      routeNumber: (routeNumber != null ? routeNumber.value : this.routeNumber),
      routeType: (routeType != null ? routeType.value : this.routeType),
      routeId: (routeId != null ? routeId.value : this.routeId),
      routeGtfsId: (routeGtfsId != null ? routeGtfsId.value : this.routeGtfsId),
      routeServiceStatus: (routeServiceStatus != null
          ? routeServiceStatus.value
          : this.routeServiceStatus),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3ResultOutlet {
  const V3ResultOutlet({
    this.outletDistance,
    this.outletSlidSpid,
    this.outletName,
    this.outletBusiness,
    this.outletLatitude,
    this.outletLongitude,
    this.outletSuburb,
    this.outletPostcode,
    this.outletBusinessHourMon,
    this.outletBusinessHourTue,
    this.outletBusinessHourWed,
    this.outletBusinessHourThur,
    this.outletBusinessHourFri,
    this.outletBusinessHourSat,
    this.outletBusinessHourSun,
    this.outletNotes,
  });

  factory V3ResultOutlet.fromJson(Map<String, dynamic> json) =>
      _$V3ResultOutletFromJson(json);

  static const toJsonFactory = _$V3ResultOutletToJson;
  Map<String, dynamic> toJson() => _$V3ResultOutletToJson(this);

  @JsonKey(name: 'outlet_distance')
  final double? outletDistance;
  @JsonKey(name: 'outlet_slid_spid')
  final String? outletSlidSpid;
  @JsonKey(name: 'outlet_name')
  final String? outletName;
  @JsonKey(name: 'outlet_business')
  final String? outletBusiness;
  @JsonKey(name: 'outlet_latitude')
  final double? outletLatitude;
  @JsonKey(name: 'outlet_longitude')
  final double? outletLongitude;
  @JsonKey(name: 'outlet_suburb')
  final String? outletSuburb;
  @JsonKey(name: 'outlet_postcode')
  final int? outletPostcode;
  @JsonKey(name: 'outlet_business_hour_mon')
  final String? outletBusinessHourMon;
  @JsonKey(name: 'outlet_business_hour_tue')
  final String? outletBusinessHourTue;
  @JsonKey(name: 'outlet_business_hour_wed')
  final String? outletBusinessHourWed;
  @JsonKey(name: 'outlet_business_hour_thur')
  final String? outletBusinessHourThur;
  @JsonKey(name: 'outlet_business_hour_fri')
  final String? outletBusinessHourFri;
  @JsonKey(name: 'outlet_business_hour_sat')
  final String? outletBusinessHourSat;
  @JsonKey(name: 'outlet_business_hour_sun')
  final String? outletBusinessHourSun;
  @JsonKey(name: 'outlet_notes')
  final String? outletNotes;
  static const fromJsonFactory = _$V3ResultOutletFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3ResultOutlet &&
            (identical(other.outletDistance, outletDistance) ||
                const DeepCollectionEquality().equals(
                  other.outletDistance,
                  outletDistance,
                )) &&
            (identical(other.outletSlidSpid, outletSlidSpid) ||
                const DeepCollectionEquality().equals(
                  other.outletSlidSpid,
                  outletSlidSpid,
                )) &&
            (identical(other.outletName, outletName) ||
                const DeepCollectionEquality().equals(
                  other.outletName,
                  outletName,
                )) &&
            (identical(other.outletBusiness, outletBusiness) ||
                const DeepCollectionEquality().equals(
                  other.outletBusiness,
                  outletBusiness,
                )) &&
            (identical(other.outletLatitude, outletLatitude) ||
                const DeepCollectionEquality().equals(
                  other.outletLatitude,
                  outletLatitude,
                )) &&
            (identical(other.outletLongitude, outletLongitude) ||
                const DeepCollectionEquality().equals(
                  other.outletLongitude,
                  outletLongitude,
                )) &&
            (identical(other.outletSuburb, outletSuburb) ||
                const DeepCollectionEquality().equals(
                  other.outletSuburb,
                  outletSuburb,
                )) &&
            (identical(other.outletPostcode, outletPostcode) ||
                const DeepCollectionEquality().equals(
                  other.outletPostcode,
                  outletPostcode,
                )) &&
            (identical(other.outletBusinessHourMon, outletBusinessHourMon) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourMon,
                  outletBusinessHourMon,
                )) &&
            (identical(other.outletBusinessHourTue, outletBusinessHourTue) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourTue,
                  outletBusinessHourTue,
                )) &&
            (identical(other.outletBusinessHourWed, outletBusinessHourWed) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourWed,
                  outletBusinessHourWed,
                )) &&
            (identical(other.outletBusinessHourThur, outletBusinessHourThur) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourThur,
                  outletBusinessHourThur,
                )) &&
            (identical(other.outletBusinessHourFri, outletBusinessHourFri) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourFri,
                  outletBusinessHourFri,
                )) &&
            (identical(other.outletBusinessHourSat, outletBusinessHourSat) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourSat,
                  outletBusinessHourSat,
                )) &&
            (identical(other.outletBusinessHourSun, outletBusinessHourSun) ||
                const DeepCollectionEquality().equals(
                  other.outletBusinessHourSun,
                  outletBusinessHourSun,
                )) &&
            (identical(other.outletNotes, outletNotes) ||
                const DeepCollectionEquality().equals(
                  other.outletNotes,
                  outletNotes,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(outletDistance) ^
      const DeepCollectionEquality().hash(outletSlidSpid) ^
      const DeepCollectionEquality().hash(outletName) ^
      const DeepCollectionEquality().hash(outletBusiness) ^
      const DeepCollectionEquality().hash(outletLatitude) ^
      const DeepCollectionEquality().hash(outletLongitude) ^
      const DeepCollectionEquality().hash(outletSuburb) ^
      const DeepCollectionEquality().hash(outletPostcode) ^
      const DeepCollectionEquality().hash(outletBusinessHourMon) ^
      const DeepCollectionEquality().hash(outletBusinessHourTue) ^
      const DeepCollectionEquality().hash(outletBusinessHourWed) ^
      const DeepCollectionEquality().hash(outletBusinessHourThur) ^
      const DeepCollectionEquality().hash(outletBusinessHourFri) ^
      const DeepCollectionEquality().hash(outletBusinessHourSat) ^
      const DeepCollectionEquality().hash(outletBusinessHourSun) ^
      const DeepCollectionEquality().hash(outletNotes) ^
      runtimeType.hashCode;
}

extension $V3ResultOutletExtension on V3ResultOutlet {
  V3ResultOutlet copyWith({
    double? outletDistance,
    String? outletSlidSpid,
    String? outletName,
    String? outletBusiness,
    double? outletLatitude,
    double? outletLongitude,
    String? outletSuburb,
    int? outletPostcode,
    String? outletBusinessHourMon,
    String? outletBusinessHourTue,
    String? outletBusinessHourWed,
    String? outletBusinessHourThur,
    String? outletBusinessHourFri,
    String? outletBusinessHourSat,
    String? outletBusinessHourSun,
    String? outletNotes,
  }) {
    return V3ResultOutlet(
      outletDistance: outletDistance ?? this.outletDistance,
      outletSlidSpid: outletSlidSpid ?? this.outletSlidSpid,
      outletName: outletName ?? this.outletName,
      outletBusiness: outletBusiness ?? this.outletBusiness,
      outletLatitude: outletLatitude ?? this.outletLatitude,
      outletLongitude: outletLongitude ?? this.outletLongitude,
      outletSuburb: outletSuburb ?? this.outletSuburb,
      outletPostcode: outletPostcode ?? this.outletPostcode,
      outletBusinessHourMon:
          outletBusinessHourMon ?? this.outletBusinessHourMon,
      outletBusinessHourTue:
          outletBusinessHourTue ?? this.outletBusinessHourTue,
      outletBusinessHourWed:
          outletBusinessHourWed ?? this.outletBusinessHourWed,
      outletBusinessHourThur:
          outletBusinessHourThur ?? this.outletBusinessHourThur,
      outletBusinessHourFri:
          outletBusinessHourFri ?? this.outletBusinessHourFri,
      outletBusinessHourSat:
          outletBusinessHourSat ?? this.outletBusinessHourSat,
      outletBusinessHourSun:
          outletBusinessHourSun ?? this.outletBusinessHourSun,
      outletNotes: outletNotes ?? this.outletNotes,
    );
  }

  V3ResultOutlet copyWithWrapped({
    Wrapped<double?>? outletDistance,
    Wrapped<String?>? outletSlidSpid,
    Wrapped<String?>? outletName,
    Wrapped<String?>? outletBusiness,
    Wrapped<double?>? outletLatitude,
    Wrapped<double?>? outletLongitude,
    Wrapped<String?>? outletSuburb,
    Wrapped<int?>? outletPostcode,
    Wrapped<String?>? outletBusinessHourMon,
    Wrapped<String?>? outletBusinessHourTue,
    Wrapped<String?>? outletBusinessHourWed,
    Wrapped<String?>? outletBusinessHourThur,
    Wrapped<String?>? outletBusinessHourFri,
    Wrapped<String?>? outletBusinessHourSat,
    Wrapped<String?>? outletBusinessHourSun,
    Wrapped<String?>? outletNotes,
  }) {
    return V3ResultOutlet(
      outletDistance: (outletDistance != null
          ? outletDistance.value
          : this.outletDistance),
      outletSlidSpid: (outletSlidSpid != null
          ? outletSlidSpid.value
          : this.outletSlidSpid),
      outletName: (outletName != null ? outletName.value : this.outletName),
      outletBusiness: (outletBusiness != null
          ? outletBusiness.value
          : this.outletBusiness),
      outletLatitude: (outletLatitude != null
          ? outletLatitude.value
          : this.outletLatitude),
      outletLongitude: (outletLongitude != null
          ? outletLongitude.value
          : this.outletLongitude),
      outletSuburb: (outletSuburb != null
          ? outletSuburb.value
          : this.outletSuburb),
      outletPostcode: (outletPostcode != null
          ? outletPostcode.value
          : this.outletPostcode),
      outletBusinessHourMon: (outletBusinessHourMon != null
          ? outletBusinessHourMon.value
          : this.outletBusinessHourMon),
      outletBusinessHourTue: (outletBusinessHourTue != null
          ? outletBusinessHourTue.value
          : this.outletBusinessHourTue),
      outletBusinessHourWed: (outletBusinessHourWed != null
          ? outletBusinessHourWed.value
          : this.outletBusinessHourWed),
      outletBusinessHourThur: (outletBusinessHourThur != null
          ? outletBusinessHourThur.value
          : this.outletBusinessHourThur),
      outletBusinessHourFri: (outletBusinessHourFri != null
          ? outletBusinessHourFri.value
          : this.outletBusinessHourFri),
      outletBusinessHourSat: (outletBusinessHourSat != null
          ? outletBusinessHourSat.value
          : this.outletBusinessHourSat),
      outletBusinessHourSun: (outletBusinessHourSun != null
          ? outletBusinessHourSun.value
          : this.outletBusinessHourSun),
      outletNotes: (outletNotes != null ? outletNotes.value : this.outletNotes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3GenerateDivaMappingResponse {
  const V3GenerateDivaMappingResponse({this.mappingVersion, this.status});

  factory V3GenerateDivaMappingResponse.fromJson(Map<String, dynamic> json) =>
      _$V3GenerateDivaMappingResponseFromJson(json);

  static const toJsonFactory = _$V3GenerateDivaMappingResponseToJson;
  Map<String, dynamic> toJson() => _$V3GenerateDivaMappingResponseToJson(this);

  @JsonKey(name: 'mapping_version')
  final String? mappingVersion;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3GenerateDivaMappingResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3GenerateDivaMappingResponse &&
            (identical(other.mappingVersion, mappingVersion) ||
                const DeepCollectionEquality().equals(
                  other.mappingVersion,
                  mappingVersion,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(mappingVersion) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3GenerateDivaMappingResponseExtension
    on V3GenerateDivaMappingResponse {
  V3GenerateDivaMappingResponse copyWith({
    String? mappingVersion,
    V3Status? status,
  }) {
    return V3GenerateDivaMappingResponse(
      mappingVersion: mappingVersion ?? this.mappingVersion,
      status: status ?? this.status,
    );
  }

  V3GenerateDivaMappingResponse copyWithWrapped({
    Wrapped<String?>? mappingVersion,
    Wrapped<V3Status?>? status,
  }) {
    return V3GenerateDivaMappingResponse(
      mappingVersion: (mappingVersion != null
          ? mappingVersion.value
          : this.mappingVersion),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriReferenceDataRequest {
  const V3SiriReferenceDataRequest({
    required this.lineRefs,
    this.stopPointRefs,
    this.dateUtc,
    required this.mappingVersion,
  });

  factory V3SiriReferenceDataRequest.fromJson(Map<String, dynamic> json) =>
      _$V3SiriReferenceDataRequestFromJson(json);

  static const toJsonFactory = _$V3SiriReferenceDataRequestToJson;
  Map<String, dynamic> toJson() => _$V3SiriReferenceDataRequestToJson(this);

  @JsonKey(
    name: 'line_refs',
    defaultValue: <V3SiriLineRefDirectionRefStopPointRef>[],
  )
  final List<V3SiriLineRefDirectionRefStopPointRef> lineRefs;
  @JsonKey(name: 'stop_point_refs', defaultValue: <int>[])
  final List<int>? stopPointRefs;
  @JsonKey(name: 'date_utc')
  final DateTime? dateUtc;
  @JsonKey(name: 'mapping_version')
  final String mappingVersion;
  static const fromJsonFactory = _$V3SiriReferenceDataRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriReferenceDataRequest &&
            (identical(other.lineRefs, lineRefs) ||
                const DeepCollectionEquality().equals(
                  other.lineRefs,
                  lineRefs,
                )) &&
            (identical(other.stopPointRefs, stopPointRefs) ||
                const DeepCollectionEquality().equals(
                  other.stopPointRefs,
                  stopPointRefs,
                )) &&
            (identical(other.dateUtc, dateUtc) ||
                const DeepCollectionEquality().equals(
                  other.dateUtc,
                  dateUtc,
                )) &&
            (identical(other.mappingVersion, mappingVersion) ||
                const DeepCollectionEquality().equals(
                  other.mappingVersion,
                  mappingVersion,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lineRefs) ^
      const DeepCollectionEquality().hash(stopPointRefs) ^
      const DeepCollectionEquality().hash(dateUtc) ^
      const DeepCollectionEquality().hash(mappingVersion) ^
      runtimeType.hashCode;
}

extension $V3SiriReferenceDataRequestExtension on V3SiriReferenceDataRequest {
  V3SiriReferenceDataRequest copyWith({
    List<V3SiriLineRefDirectionRefStopPointRef>? lineRefs,
    List<int>? stopPointRefs,
    DateTime? dateUtc,
    String? mappingVersion,
  }) {
    return V3SiriReferenceDataRequest(
      lineRefs: lineRefs ?? this.lineRefs,
      stopPointRefs: stopPointRefs ?? this.stopPointRefs,
      dateUtc: dateUtc ?? this.dateUtc,
      mappingVersion: mappingVersion ?? this.mappingVersion,
    );
  }

  V3SiriReferenceDataRequest copyWithWrapped({
    Wrapped<List<V3SiriLineRefDirectionRefStopPointRef>>? lineRefs,
    Wrapped<List<int>?>? stopPointRefs,
    Wrapped<DateTime?>? dateUtc,
    Wrapped<String>? mappingVersion,
  }) {
    return V3SiriReferenceDataRequest(
      lineRefs: (lineRefs != null ? lineRefs.value : this.lineRefs),
      stopPointRefs: (stopPointRefs != null
          ? stopPointRefs.value
          : this.stopPointRefs),
      dateUtc: (dateUtc != null ? dateUtc.value : this.dateUtc),
      mappingVersion: (mappingVersion != null
          ? mappingVersion.value
          : this.mappingVersion),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriLineRefDirectionRefStopPointRef {
  const V3SiriLineRefDirectionRefStopPointRef({
    required this.lineRef,
    required this.directionRef,
    required this.stopPointRef,
  });

  factory V3SiriLineRefDirectionRefStopPointRef.fromJson(
    Map<String, dynamic> json,
  ) => _$V3SiriLineRefDirectionRefStopPointRefFromJson(json);

  static const toJsonFactory = _$V3SiriLineRefDirectionRefStopPointRefToJson;
  Map<String, dynamic> toJson() =>
      _$V3SiriLineRefDirectionRefStopPointRefToJson(this);

  @JsonKey(name: 'line_ref')
  final String lineRef;
  @JsonKey(name: 'direction_ref')
  final int directionRef;
  @JsonKey(name: 'stop_point_ref')
  final int stopPointRef;
  static const fromJsonFactory =
      _$V3SiriLineRefDirectionRefStopPointRefFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriLineRefDirectionRefStopPointRef &&
            (identical(other.lineRef, lineRef) ||
                const DeepCollectionEquality().equals(
                  other.lineRef,
                  lineRef,
                )) &&
            (identical(other.directionRef, directionRef) ||
                const DeepCollectionEquality().equals(
                  other.directionRef,
                  directionRef,
                )) &&
            (identical(other.stopPointRef, stopPointRef) ||
                const DeepCollectionEquality().equals(
                  other.stopPointRef,
                  stopPointRef,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lineRef) ^
      const DeepCollectionEquality().hash(directionRef) ^
      const DeepCollectionEquality().hash(stopPointRef) ^
      runtimeType.hashCode;
}

extension $V3SiriLineRefDirectionRefStopPointRefExtension
    on V3SiriLineRefDirectionRefStopPointRef {
  V3SiriLineRefDirectionRefStopPointRef copyWith({
    String? lineRef,
    int? directionRef,
    int? stopPointRef,
  }) {
    return V3SiriLineRefDirectionRefStopPointRef(
      lineRef: lineRef ?? this.lineRef,
      directionRef: directionRef ?? this.directionRef,
      stopPointRef: stopPointRef ?? this.stopPointRef,
    );
  }

  V3SiriLineRefDirectionRefStopPointRef copyWithWrapped({
    Wrapped<String>? lineRef,
    Wrapped<int>? directionRef,
    Wrapped<int>? stopPointRef,
  }) {
    return V3SiriLineRefDirectionRefStopPointRef(
      lineRef: (lineRef != null ? lineRef.value : this.lineRef),
      directionRef: (directionRef != null
          ? directionRef.value
          : this.directionRef),
      stopPointRef: (stopPointRef != null
          ? stopPointRef.value
          : this.stopPointRef),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriReferenceDataMappingsResponse {
  const V3SiriReferenceDataMappingsResponse({
    this.mappingVersion,
    this.lineRefs,
    this.stopPointRefs,
    this.status,
  });

  factory V3SiriReferenceDataMappingsResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$V3SiriReferenceDataMappingsResponseFromJson(json);

  static const toJsonFactory = _$V3SiriReferenceDataMappingsResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V3SiriReferenceDataMappingsResponseToJson(this);

  @JsonKey(name: 'mapping_version')
  final String? mappingVersion;
  @JsonKey(name: 'line_refs')
  final Map<String, dynamic>? lineRefs;
  @JsonKey(name: 'stop_point_refs')
  final Map<String, dynamic>? stopPointRefs;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3SiriReferenceDataMappingsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriReferenceDataMappingsResponse &&
            (identical(other.mappingVersion, mappingVersion) ||
                const DeepCollectionEquality().equals(
                  other.mappingVersion,
                  mappingVersion,
                )) &&
            (identical(other.lineRefs, lineRefs) ||
                const DeepCollectionEquality().equals(
                  other.lineRefs,
                  lineRefs,
                )) &&
            (identical(other.stopPointRefs, stopPointRefs) ||
                const DeepCollectionEquality().equals(
                  other.stopPointRefs,
                  stopPointRefs,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(mappingVersion) ^
      const DeepCollectionEquality().hash(lineRefs) ^
      const DeepCollectionEquality().hash(stopPointRefs) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3SiriReferenceDataMappingsResponseExtension
    on V3SiriReferenceDataMappingsResponse {
  V3SiriReferenceDataMappingsResponse copyWith({
    String? mappingVersion,
    Map<String, dynamic>? lineRefs,
    Map<String, dynamic>? stopPointRefs,
    V3Status? status,
  }) {
    return V3SiriReferenceDataMappingsResponse(
      mappingVersion: mappingVersion ?? this.mappingVersion,
      lineRefs: lineRefs ?? this.lineRefs,
      stopPointRefs: stopPointRefs ?? this.stopPointRefs,
      status: status ?? this.status,
    );
  }

  V3SiriReferenceDataMappingsResponse copyWithWrapped({
    Wrapped<String?>? mappingVersion,
    Wrapped<Map<String, dynamic>?>? lineRefs,
    Wrapped<Map<String, dynamic>?>? stopPointRefs,
    Wrapped<V3Status?>? status,
  }) {
    return V3SiriReferenceDataMappingsResponse(
      mappingVersion: (mappingVersion != null
          ? mappingVersion.value
          : this.mappingVersion),
      lineRefs: (lineRefs != null ? lineRefs.value : this.lineRefs),
      stopPointRefs: (stopPointRefs != null
          ? stopPointRefs.value
          : this.stopPointRefs),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriDirectionRefsDictionary {
  const V3SiriDirectionRefsDictionary({this.directionRefs});

  factory V3SiriDirectionRefsDictionary.fromJson(Map<String, dynamic> json) =>
      _$V3SiriDirectionRefsDictionaryFromJson(json);

  static const toJsonFactory = _$V3SiriDirectionRefsDictionaryToJson;
  Map<String, dynamic> toJson() => _$V3SiriDirectionRefsDictionaryToJson(this);

  @JsonKey(name: 'direction_refs')
  final Map<String, dynamic>? directionRefs;
  static const fromJsonFactory = _$V3SiriDirectionRefsDictionaryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriDirectionRefsDictionary &&
            (identical(other.directionRefs, directionRefs) ||
                const DeepCollectionEquality().equals(
                  other.directionRefs,
                  directionRefs,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(directionRefs) ^ runtimeType.hashCode;
}

extension $V3SiriDirectionRefsDictionaryExtension
    on V3SiriDirectionRefsDictionary {
  V3SiriDirectionRefsDictionary copyWith({
    Map<String, dynamic>? directionRefs,
  }) {
    return V3SiriDirectionRefsDictionary(
      directionRefs: directionRefs ?? this.directionRefs,
    );
  }

  V3SiriDirectionRefsDictionary copyWithWrapped({
    Wrapped<Map<String, dynamic>?>? directionRefs,
  }) {
    return V3SiriDirectionRefsDictionary(
      directionRefs: (directionRefs != null
          ? directionRefs.value
          : this.directionRefs),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopPoint {
  const V3StopPoint({this.stopId});

  factory V3StopPoint.fromJson(Map<String, dynamic> json) =>
      _$V3StopPointFromJson(json);

  static const toJsonFactory = _$V3StopPointToJson;
  Map<String, dynamic> toJson() => _$V3StopPointToJson(this);

  @JsonKey(name: 'stop_id')
  final int? stopId;
  static const fromJsonFactory = _$V3StopPointFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopPoint &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopId) ^ runtimeType.hashCode;
}

extension $V3StopPointExtension on V3StopPoint {
  V3StopPoint copyWith({int? stopId}) {
    return V3StopPoint(stopId: stopId ?? this.stopId);
  }

  V3StopPoint copyWithWrapped({Wrapped<int?>? stopId}) {
    return V3StopPoint(stopId: (stopId != null ? stopId.value : this.stopId));
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriStopsRefsDictionary {
  const V3SiriStopsRefsDictionary({
    this.stopPointRefs,
    this.unmatchedStopPointRefs,
  });

  factory V3SiriStopsRefsDictionary.fromJson(Map<String, dynamic> json) =>
      _$V3SiriStopsRefsDictionaryFromJson(json);

  static const toJsonFactory = _$V3SiriStopsRefsDictionaryToJson;
  Map<String, dynamic> toJson() => _$V3SiriStopsRefsDictionaryToJson(this);

  @JsonKey(name: 'stop_point_refs')
  final Map<String, dynamic>? stopPointRefs;
  @JsonKey(name: 'unmatched_stop_point_refs')
  final Map<String, dynamic>? unmatchedStopPointRefs;
  static const fromJsonFactory = _$V3SiriStopsRefsDictionaryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriStopsRefsDictionary &&
            (identical(other.stopPointRefs, stopPointRefs) ||
                const DeepCollectionEquality().equals(
                  other.stopPointRefs,
                  stopPointRefs,
                )) &&
            (identical(other.unmatchedStopPointRefs, unmatchedStopPointRefs) ||
                const DeepCollectionEquality().equals(
                  other.unmatchedStopPointRefs,
                  unmatchedStopPointRefs,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stopPointRefs) ^
      const DeepCollectionEquality().hash(unmatchedStopPointRefs) ^
      runtimeType.hashCode;
}

extension $V3SiriStopsRefsDictionaryExtension on V3SiriStopsRefsDictionary {
  V3SiriStopsRefsDictionary copyWith({
    Map<String, dynamic>? stopPointRefs,
    Map<String, dynamic>? unmatchedStopPointRefs,
  }) {
    return V3SiriStopsRefsDictionary(
      stopPointRefs: stopPointRefs ?? this.stopPointRefs,
      unmatchedStopPointRefs:
          unmatchedStopPointRefs ?? this.unmatchedStopPointRefs,
    );
  }

  V3SiriStopsRefsDictionary copyWithWrapped({
    Wrapped<Map<String, dynamic>?>? stopPointRefs,
    Wrapped<Map<String, dynamic>?>? unmatchedStopPointRefs,
  }) {
    return V3SiriStopsRefsDictionary(
      stopPointRefs: (stopPointRefs != null
          ? stopPointRefs.value
          : this.stopPointRefs),
      unmatchedStopPointRefs: (unmatchedStopPointRefs != null
          ? unmatchedStopPointRefs.value
          : this.unmatchedStopPointRefs),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriReferenceDataDetail {
  const V3SiriReferenceDataDetail({
    this.noMatchReason,
    this.routeId,
    this.routeNumberShort,
    this.directionId,
    this.trackingSupplierId,
    this.routeType,
  });

  factory V3SiriReferenceDataDetail.fromJson(Map<String, dynamic> json) =>
      _$V3SiriReferenceDataDetailFromJson(json);

  static const toJsonFactory = _$V3SiriReferenceDataDetailToJson;
  Map<String, dynamic> toJson() => _$V3SiriReferenceDataDetailToJson(this);

  @JsonKey(name: 'NoMatchReason')
  final int? noMatchReason;
  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'route_number_short')
  final String? routeNumberShort;
  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'tracking_supplier_id')
  final int? trackingSupplierId;
  @JsonKey(name: 'route_type')
  final int? routeType;
  static const fromJsonFactory = _$V3SiriReferenceDataDetailFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriReferenceDataDetail &&
            (identical(other.noMatchReason, noMatchReason) ||
                const DeepCollectionEquality().equals(
                  other.noMatchReason,
                  noMatchReason,
                )) &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.routeNumberShort, routeNumberShort) ||
                const DeepCollectionEquality().equals(
                  other.routeNumberShort,
                  routeNumberShort,
                )) &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.trackingSupplierId, trackingSupplierId) ||
                const DeepCollectionEquality().equals(
                  other.trackingSupplierId,
                  trackingSupplierId,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(noMatchReason) ^
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(routeNumberShort) ^
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(trackingSupplierId) ^
      const DeepCollectionEquality().hash(routeType) ^
      runtimeType.hashCode;
}

extension $V3SiriReferenceDataDetailExtension on V3SiriReferenceDataDetail {
  V3SiriReferenceDataDetail copyWith({
    int? noMatchReason,
    int? routeId,
    String? routeNumberShort,
    int? directionId,
    int? trackingSupplierId,
    int? routeType,
  }) {
    return V3SiriReferenceDataDetail(
      noMatchReason: noMatchReason ?? this.noMatchReason,
      routeId: routeId ?? this.routeId,
      routeNumberShort: routeNumberShort ?? this.routeNumberShort,
      directionId: directionId ?? this.directionId,
      trackingSupplierId: trackingSupplierId ?? this.trackingSupplierId,
      routeType: routeType ?? this.routeType,
    );
  }

  V3SiriReferenceDataDetail copyWithWrapped({
    Wrapped<int?>? noMatchReason,
    Wrapped<int?>? routeId,
    Wrapped<String?>? routeNumberShort,
    Wrapped<int?>? directionId,
    Wrapped<int?>? trackingSupplierId,
    Wrapped<int?>? routeType,
  }) {
    return V3SiriReferenceDataDetail(
      noMatchReason: (noMatchReason != null
          ? noMatchReason.value
          : this.noMatchReason),
      routeId: (routeId != null ? routeId.value : this.routeId),
      routeNumberShort: (routeNumberShort != null
          ? routeNumberShort.value
          : this.routeNumberShort),
      directionId: (directionId != null ? directionId.value : this.directionId),
      trackingSupplierId: (trackingSupplierId != null
          ? trackingSupplierId.value
          : this.trackingSupplierId),
      routeType: (routeType != null ? routeType.value : this.routeType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriLineRefsRequest {
  const V3SiriLineRefsRequest({this.lineRefs, required this.mappingVersion});

  factory V3SiriLineRefsRequest.fromJson(Map<String, dynamic> json) =>
      _$V3SiriLineRefsRequestFromJson(json);

  static const toJsonFactory = _$V3SiriLineRefsRequestToJson;
  Map<String, dynamic> toJson() => _$V3SiriLineRefsRequestToJson(this);

  @JsonKey(name: 'line_refs', defaultValue: <V3SiriLineRef>[])
  final List<V3SiriLineRef>? lineRefs;
  @JsonKey(name: 'mapping_version')
  final String mappingVersion;
  static const fromJsonFactory = _$V3SiriLineRefsRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriLineRefsRequest &&
            (identical(other.lineRefs, lineRefs) ||
                const DeepCollectionEquality().equals(
                  other.lineRefs,
                  lineRefs,
                )) &&
            (identical(other.mappingVersion, mappingVersion) ||
                const DeepCollectionEquality().equals(
                  other.mappingVersion,
                  mappingVersion,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lineRefs) ^
      const DeepCollectionEquality().hash(mappingVersion) ^
      runtimeType.hashCode;
}

extension $V3SiriLineRefsRequestExtension on V3SiriLineRefsRequest {
  V3SiriLineRefsRequest copyWith({
    List<V3SiriLineRef>? lineRefs,
    String? mappingVersion,
  }) {
    return V3SiriLineRefsRequest(
      lineRefs: lineRefs ?? this.lineRefs,
      mappingVersion: mappingVersion ?? this.mappingVersion,
    );
  }

  V3SiriLineRefsRequest copyWithWrapped({
    Wrapped<List<V3SiriLineRef>?>? lineRefs,
    Wrapped<String>? mappingVersion,
  }) {
    return V3SiriLineRefsRequest(
      lineRefs: (lineRefs != null ? lineRefs.value : this.lineRefs),
      mappingVersion: (mappingVersion != null
          ? mappingVersion.value
          : this.mappingVersion),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriLineRef {
  const V3SiriLineRef({required this.lineRef, this.directionRef});

  factory V3SiriLineRef.fromJson(Map<String, dynamic> json) =>
      _$V3SiriLineRefFromJson(json);

  static const toJsonFactory = _$V3SiriLineRefToJson;
  Map<String, dynamic> toJson() => _$V3SiriLineRefToJson(this);

  @JsonKey(name: 'line_ref')
  final String lineRef;
  @JsonKey(name: 'direction_ref')
  final int? directionRef;
  static const fromJsonFactory = _$V3SiriLineRefFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriLineRef &&
            (identical(other.lineRef, lineRef) ||
                const DeepCollectionEquality().equals(
                  other.lineRef,
                  lineRef,
                )) &&
            (identical(other.directionRef, directionRef) ||
                const DeepCollectionEquality().equals(
                  other.directionRef,
                  directionRef,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lineRef) ^
      const DeepCollectionEquality().hash(directionRef) ^
      runtimeType.hashCode;
}

extension $V3SiriLineRefExtension on V3SiriLineRef {
  V3SiriLineRef copyWith({String? lineRef, int? directionRef}) {
    return V3SiriLineRef(
      lineRef: lineRef ?? this.lineRef,
      directionRef: directionRef ?? this.directionRef,
    );
  }

  V3SiriLineRef copyWithWrapped({
    Wrapped<String>? lineRef,
    Wrapped<int?>? directionRef,
  }) {
    return V3SiriLineRef(
      lineRef: (lineRef != null ? lineRef.value : this.lineRef),
      directionRef: (directionRef != null
          ? directionRef.value
          : this.directionRef),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriLineRefMappingsResponse {
  const V3SiriLineRefMappingsResponse({
    this.mappingVersion,
    this.lineRefs,
    this.status,
  });

  factory V3SiriLineRefMappingsResponse.fromJson(Map<String, dynamic> json) =>
      _$V3SiriLineRefMappingsResponseFromJson(json);

  static const toJsonFactory = _$V3SiriLineRefMappingsResponseToJson;
  Map<String, dynamic> toJson() => _$V3SiriLineRefMappingsResponseToJson(this);

  @JsonKey(name: 'mapping_version')
  final String? mappingVersion;
  @JsonKey(name: 'line_refs')
  final Map<String, dynamic>? lineRefs;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3SiriLineRefMappingsResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriLineRefMappingsResponse &&
            (identical(other.mappingVersion, mappingVersion) ||
                const DeepCollectionEquality().equals(
                  other.mappingVersion,
                  mappingVersion,
                )) &&
            (identical(other.lineRefs, lineRefs) ||
                const DeepCollectionEquality().equals(
                  other.lineRefs,
                  lineRefs,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(mappingVersion) ^
      const DeepCollectionEquality().hash(lineRefs) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3SiriLineRefMappingsResponseExtension
    on V3SiriLineRefMappingsResponse {
  V3SiriLineRefMappingsResponse copyWith({
    String? mappingVersion,
    Map<String, dynamic>? lineRefs,
    V3Status? status,
  }) {
    return V3SiriLineRefMappingsResponse(
      mappingVersion: mappingVersion ?? this.mappingVersion,
      lineRefs: lineRefs ?? this.lineRefs,
      status: status ?? this.status,
    );
  }

  V3SiriLineRefMappingsResponse copyWithWrapped({
    Wrapped<String?>? mappingVersion,
    Wrapped<Map<String, dynamic>?>? lineRefs,
    Wrapped<V3Status?>? status,
  }) {
    return V3SiriLineRefMappingsResponse(
      mappingVersion: (mappingVersion != null
          ? mappingVersion.value
          : this.mappingVersion),
      lineRefs: (lineRefs != null ? lineRefs.value : this.lineRefs),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriLineRefDirectionRefsDictionary {
  const V3SiriLineRefDirectionRefsDictionary({
    this.directionRefs,
    this.unmatchedDirectionRefs,
  });

  factory V3SiriLineRefDirectionRefsDictionary.fromJson(
    Map<String, dynamic> json,
  ) => _$V3SiriLineRefDirectionRefsDictionaryFromJson(json);

  static const toJsonFactory = _$V3SiriLineRefDirectionRefsDictionaryToJson;
  Map<String, dynamic> toJson() =>
      _$V3SiriLineRefDirectionRefsDictionaryToJson(this);

  @JsonKey(name: 'direction_refs')
  final Map<String, dynamic>? directionRefs;
  @JsonKey(name: 'unmatched_direction_refs')
  final Map<String, dynamic>? unmatchedDirectionRefs;
  static const fromJsonFactory = _$V3SiriLineRefDirectionRefsDictionaryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriLineRefDirectionRefsDictionary &&
            (identical(other.directionRefs, directionRefs) ||
                const DeepCollectionEquality().equals(
                  other.directionRefs,
                  directionRefs,
                )) &&
            (identical(other.unmatchedDirectionRefs, unmatchedDirectionRefs) ||
                const DeepCollectionEquality().equals(
                  other.unmatchedDirectionRefs,
                  unmatchedDirectionRefs,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(directionRefs) ^
      const DeepCollectionEquality().hash(unmatchedDirectionRefs) ^
      runtimeType.hashCode;
}

extension $V3SiriLineRefDirectionRefsDictionaryExtension
    on V3SiriLineRefDirectionRefsDictionary {
  V3SiriLineRefDirectionRefsDictionary copyWith({
    Map<String, dynamic>? directionRefs,
    Map<String, dynamic>? unmatchedDirectionRefs,
  }) {
    return V3SiriLineRefDirectionRefsDictionary(
      directionRefs: directionRefs ?? this.directionRefs,
      unmatchedDirectionRefs:
          unmatchedDirectionRefs ?? this.unmatchedDirectionRefs,
    );
  }

  V3SiriLineRefDirectionRefsDictionary copyWithWrapped({
    Wrapped<Map<String, dynamic>?>? directionRefs,
    Wrapped<Map<String, dynamic>?>? unmatchedDirectionRefs,
  }) {
    return V3SiriLineRefDirectionRefsDictionary(
      directionRefs: (directionRefs != null
          ? directionRefs.value
          : this.directionRefs),
      unmatchedDirectionRefs: (unmatchedDirectionRefs != null
          ? unmatchedDirectionRefs.value
          : this.unmatchedDirectionRefs),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DynamoDbTimetablesReponse {
  const V3DynamoDbTimetablesReponse({this.timetables, this.status});

  factory V3DynamoDbTimetablesReponse.fromJson(Map<String, dynamic> json) =>
      _$V3DynamoDbTimetablesReponseFromJson(json);

  static const toJsonFactory = _$V3DynamoDbTimetablesReponseToJson;
  Map<String, dynamic> toJson() => _$V3DynamoDbTimetablesReponseToJson(this);

  @JsonKey(name: 'timetables', defaultValue: <V3DynamoDbTimetable>[])
  final List<V3DynamoDbTimetable>? timetables;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3DynamoDbTimetablesReponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DynamoDbTimetablesReponse &&
            (identical(other.timetables, timetables) ||
                const DeepCollectionEquality().equals(
                  other.timetables,
                  timetables,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(timetables) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3DynamoDbTimetablesReponseExtension on V3DynamoDbTimetablesReponse {
  V3DynamoDbTimetablesReponse copyWith({
    List<V3DynamoDbTimetable>? timetables,
    V3Status? status,
  }) {
    return V3DynamoDbTimetablesReponse(
      timetables: timetables ?? this.timetables,
      status: status ?? this.status,
    );
  }

  V3DynamoDbTimetablesReponse copyWithWrapped({
    Wrapped<List<V3DynamoDbTimetable>?>? timetables,
    Wrapped<V3Status?>? status,
  }) {
    return V3DynamoDbTimetablesReponse(
      timetables: (timetables != null ? timetables.value : this.timetables),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3DynamoDbTimetable {
  const V3DynamoDbTimetable({
    this.tableName,
    this.parserVersion,
    this.parserMappingVersion,
    this.ptVersion,
    this.ptMappingVersion,
    this.transportType,
    this.applicableDate,
    this.applicableLocalDate,
    this.exists,
  });

  factory V3DynamoDbTimetable.fromJson(Map<String, dynamic> json) =>
      _$V3DynamoDbTimetableFromJson(json);

  static const toJsonFactory = _$V3DynamoDbTimetableToJson;
  Map<String, dynamic> toJson() => _$V3DynamoDbTimetableToJson(this);

  @JsonKey(name: 'table_name')
  final String? tableName;
  @JsonKey(name: 'parser_version')
  final int? parserVersion;
  @JsonKey(name: 'parser_mapping_version')
  final String? parserMappingVersion;
  @JsonKey(name: 'pt_version')
  final int? ptVersion;
  @JsonKey(name: 'pt_mapping_version')
  final String? ptMappingVersion;
  @JsonKey(name: 'transport_type')
  final int? transportType;
  @JsonKey(name: 'applicable_date')
  final DateTime? applicableDate;
  @JsonKey(name: 'applicable_local_date')
  final String? applicableLocalDate;
  @JsonKey(name: 'exists')
  final bool? exists;
  static const fromJsonFactory = _$V3DynamoDbTimetableFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3DynamoDbTimetable &&
            (identical(other.tableName, tableName) ||
                const DeepCollectionEquality().equals(
                  other.tableName,
                  tableName,
                )) &&
            (identical(other.parserVersion, parserVersion) ||
                const DeepCollectionEquality().equals(
                  other.parserVersion,
                  parserVersion,
                )) &&
            (identical(other.parserMappingVersion, parserMappingVersion) ||
                const DeepCollectionEquality().equals(
                  other.parserMappingVersion,
                  parserMappingVersion,
                )) &&
            (identical(other.ptVersion, ptVersion) ||
                const DeepCollectionEquality().equals(
                  other.ptVersion,
                  ptVersion,
                )) &&
            (identical(other.ptMappingVersion, ptMappingVersion) ||
                const DeepCollectionEquality().equals(
                  other.ptMappingVersion,
                  ptMappingVersion,
                )) &&
            (identical(other.transportType, transportType) ||
                const DeepCollectionEquality().equals(
                  other.transportType,
                  transportType,
                )) &&
            (identical(other.applicableDate, applicableDate) ||
                const DeepCollectionEquality().equals(
                  other.applicableDate,
                  applicableDate,
                )) &&
            (identical(other.applicableLocalDate, applicableLocalDate) ||
                const DeepCollectionEquality().equals(
                  other.applicableLocalDate,
                  applicableLocalDate,
                )) &&
            (identical(other.exists, exists) ||
                const DeepCollectionEquality().equals(other.exists, exists)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(tableName) ^
      const DeepCollectionEquality().hash(parserVersion) ^
      const DeepCollectionEquality().hash(parserMappingVersion) ^
      const DeepCollectionEquality().hash(ptVersion) ^
      const DeepCollectionEquality().hash(ptMappingVersion) ^
      const DeepCollectionEquality().hash(transportType) ^
      const DeepCollectionEquality().hash(applicableDate) ^
      const DeepCollectionEquality().hash(applicableLocalDate) ^
      const DeepCollectionEquality().hash(exists) ^
      runtimeType.hashCode;
}

extension $V3DynamoDbTimetableExtension on V3DynamoDbTimetable {
  V3DynamoDbTimetable copyWith({
    String? tableName,
    int? parserVersion,
    String? parserMappingVersion,
    int? ptVersion,
    String? ptMappingVersion,
    int? transportType,
    DateTime? applicableDate,
    String? applicableLocalDate,
    bool? exists,
  }) {
    return V3DynamoDbTimetable(
      tableName: tableName ?? this.tableName,
      parserVersion: parserVersion ?? this.parserVersion,
      parserMappingVersion: parserMappingVersion ?? this.parserMappingVersion,
      ptVersion: ptVersion ?? this.ptVersion,
      ptMappingVersion: ptMappingVersion ?? this.ptMappingVersion,
      transportType: transportType ?? this.transportType,
      applicableDate: applicableDate ?? this.applicableDate,
      applicableLocalDate: applicableLocalDate ?? this.applicableLocalDate,
      exists: exists ?? this.exists,
    );
  }

  V3DynamoDbTimetable copyWithWrapped({
    Wrapped<String?>? tableName,
    Wrapped<int?>? parserVersion,
    Wrapped<String?>? parserMappingVersion,
    Wrapped<int?>? ptVersion,
    Wrapped<String?>? ptMappingVersion,
    Wrapped<int?>? transportType,
    Wrapped<DateTime?>? applicableDate,
    Wrapped<String?>? applicableLocalDate,
    Wrapped<bool?>? exists,
  }) {
    return V3DynamoDbTimetable(
      tableName: (tableName != null ? tableName.value : this.tableName),
      parserVersion: (parserVersion != null
          ? parserVersion.value
          : this.parserVersion),
      parserMappingVersion: (parserMappingVersion != null
          ? parserMappingVersion.value
          : this.parserMappingVersion),
      ptVersion: (ptVersion != null ? ptVersion.value : this.ptVersion),
      ptMappingVersion: (ptMappingVersion != null
          ? ptMappingVersion.value
          : this.ptMappingVersion),
      transportType: (transportType != null
          ? transportType.value
          : this.transportType),
      applicableDate: (applicableDate != null
          ? applicableDate.value
          : this.applicableDate),
      applicableLocalDate: (applicableLocalDate != null
          ? applicableLocalDate.value
          : this.applicableLocalDate),
      exists: (exists != null ? exists.value : this.exists),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriDownstreamSubscription {
  const V3SiriDownstreamSubscription({
    this.subscriberRef,
    this.subscriptionRef,
    this.messageType,
    this.siriFormat,
    this.siriVersion,
    this.consumerAddress,
    this.initialTerminationTime,
    this.validityPeriodStart,
    this.validityPeriodEnd,
    this.previewInterval,
    this.topics,
  });

  factory V3SiriDownstreamSubscription.fromJson(Map<String, dynamic> json) =>
      _$V3SiriDownstreamSubscriptionFromJson(json);

  static const toJsonFactory = _$V3SiriDownstreamSubscriptionToJson;
  Map<String, dynamic> toJson() => _$V3SiriDownstreamSubscriptionToJson(this);

  @JsonKey(name: 'subscriber_ref')
  final String? subscriberRef;
  @JsonKey(name: 'subscription_ref')
  final String? subscriptionRef;
  @JsonKey(name: 'message_type')
  final int? messageType;
  @JsonKey(name: 'siri_format')
  final int? siriFormat;
  @JsonKey(name: 'siri_version')
  final String? siriVersion;
  @JsonKey(name: 'consumer_address')
  final String? consumerAddress;
  @JsonKey(name: 'initial_termination_time')
  final DateTime? initialTerminationTime;
  @JsonKey(name: 'validity_period_start')
  final DateTime? validityPeriodStart;
  @JsonKey(name: 'validity_period_end')
  final DateTime? validityPeriodEnd;
  @JsonKey(name: 'preview_interval')
  final String? previewInterval;
  @JsonKey(name: 'topics', defaultValue: <V3SiriDownstreamSubscriptionTopic>[])
  final List<V3SiriDownstreamSubscriptionTopic>? topics;
  static const fromJsonFactory = _$V3SiriDownstreamSubscriptionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriDownstreamSubscription &&
            (identical(other.subscriberRef, subscriberRef) ||
                const DeepCollectionEquality().equals(
                  other.subscriberRef,
                  subscriberRef,
                )) &&
            (identical(other.subscriptionRef, subscriptionRef) ||
                const DeepCollectionEquality().equals(
                  other.subscriptionRef,
                  subscriptionRef,
                )) &&
            (identical(other.messageType, messageType) ||
                const DeepCollectionEquality().equals(
                  other.messageType,
                  messageType,
                )) &&
            (identical(other.siriFormat, siriFormat) ||
                const DeepCollectionEquality().equals(
                  other.siriFormat,
                  siriFormat,
                )) &&
            (identical(other.siriVersion, siriVersion) ||
                const DeepCollectionEquality().equals(
                  other.siriVersion,
                  siriVersion,
                )) &&
            (identical(other.consumerAddress, consumerAddress) ||
                const DeepCollectionEquality().equals(
                  other.consumerAddress,
                  consumerAddress,
                )) &&
            (identical(other.initialTerminationTime, initialTerminationTime) ||
                const DeepCollectionEquality().equals(
                  other.initialTerminationTime,
                  initialTerminationTime,
                )) &&
            (identical(other.validityPeriodStart, validityPeriodStart) ||
                const DeepCollectionEquality().equals(
                  other.validityPeriodStart,
                  validityPeriodStart,
                )) &&
            (identical(other.validityPeriodEnd, validityPeriodEnd) ||
                const DeepCollectionEquality().equals(
                  other.validityPeriodEnd,
                  validityPeriodEnd,
                )) &&
            (identical(other.previewInterval, previewInterval) ||
                const DeepCollectionEquality().equals(
                  other.previewInterval,
                  previewInterval,
                )) &&
            (identical(other.topics, topics) ||
                const DeepCollectionEquality().equals(other.topics, topics)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(subscriberRef) ^
      const DeepCollectionEquality().hash(subscriptionRef) ^
      const DeepCollectionEquality().hash(messageType) ^
      const DeepCollectionEquality().hash(siriFormat) ^
      const DeepCollectionEquality().hash(siriVersion) ^
      const DeepCollectionEquality().hash(consumerAddress) ^
      const DeepCollectionEquality().hash(initialTerminationTime) ^
      const DeepCollectionEquality().hash(validityPeriodStart) ^
      const DeepCollectionEquality().hash(validityPeriodEnd) ^
      const DeepCollectionEquality().hash(previewInterval) ^
      const DeepCollectionEquality().hash(topics) ^
      runtimeType.hashCode;
}

extension $V3SiriDownstreamSubscriptionExtension
    on V3SiriDownstreamSubscription {
  V3SiriDownstreamSubscription copyWith({
    String? subscriberRef,
    String? subscriptionRef,
    int? messageType,
    int? siriFormat,
    String? siriVersion,
    String? consumerAddress,
    DateTime? initialTerminationTime,
    DateTime? validityPeriodStart,
    DateTime? validityPeriodEnd,
    String? previewInterval,
    List<V3SiriDownstreamSubscriptionTopic>? topics,
  }) {
    return V3SiriDownstreamSubscription(
      subscriberRef: subscriberRef ?? this.subscriberRef,
      subscriptionRef: subscriptionRef ?? this.subscriptionRef,
      messageType: messageType ?? this.messageType,
      siriFormat: siriFormat ?? this.siriFormat,
      siriVersion: siriVersion ?? this.siriVersion,
      consumerAddress: consumerAddress ?? this.consumerAddress,
      initialTerminationTime:
          initialTerminationTime ?? this.initialTerminationTime,
      validityPeriodStart: validityPeriodStart ?? this.validityPeriodStart,
      validityPeriodEnd: validityPeriodEnd ?? this.validityPeriodEnd,
      previewInterval: previewInterval ?? this.previewInterval,
      topics: topics ?? this.topics,
    );
  }

  V3SiriDownstreamSubscription copyWithWrapped({
    Wrapped<String?>? subscriberRef,
    Wrapped<String?>? subscriptionRef,
    Wrapped<int?>? messageType,
    Wrapped<int?>? siriFormat,
    Wrapped<String?>? siriVersion,
    Wrapped<String?>? consumerAddress,
    Wrapped<DateTime?>? initialTerminationTime,
    Wrapped<DateTime?>? validityPeriodStart,
    Wrapped<DateTime?>? validityPeriodEnd,
    Wrapped<String?>? previewInterval,
    Wrapped<List<V3SiriDownstreamSubscriptionTopic>?>? topics,
  }) {
    return V3SiriDownstreamSubscription(
      subscriberRef: (subscriberRef != null
          ? subscriberRef.value
          : this.subscriberRef),
      subscriptionRef: (subscriptionRef != null
          ? subscriptionRef.value
          : this.subscriptionRef),
      messageType: (messageType != null ? messageType.value : this.messageType),
      siriFormat: (siriFormat != null ? siriFormat.value : this.siriFormat),
      siriVersion: (siriVersion != null ? siriVersion.value : this.siriVersion),
      consumerAddress: (consumerAddress != null
          ? consumerAddress.value
          : this.consumerAddress),
      initialTerminationTime: (initialTerminationTime != null
          ? initialTerminationTime.value
          : this.initialTerminationTime),
      validityPeriodStart: (validityPeriodStart != null
          ? validityPeriodStart.value
          : this.validityPeriodStart),
      validityPeriodEnd: (validityPeriodEnd != null
          ? validityPeriodEnd.value
          : this.validityPeriodEnd),
      previewInterval: (previewInterval != null
          ? previewInterval.value
          : this.previewInterval),
      topics: (topics != null ? topics.value : this.topics),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriDownstreamSubscriptionTopic {
  const V3SiriDownstreamSubscriptionTopic({
    this.lineRef,
    this.directionRef,
    this.routeType,
  });

  factory V3SiriDownstreamSubscriptionTopic.fromJson(
    Map<String, dynamic> json,
  ) => _$V3SiriDownstreamSubscriptionTopicFromJson(json);

  static const toJsonFactory = _$V3SiriDownstreamSubscriptionTopicToJson;
  Map<String, dynamic> toJson() =>
      _$V3SiriDownstreamSubscriptionTopicToJson(this);

  @JsonKey(name: 'line_ref')
  final String? lineRef;
  @JsonKey(name: 'direction_ref')
  final int? directionRef;
  @JsonKey(name: 'route_type')
  final int? routeType;
  static const fromJsonFactory = _$V3SiriDownstreamSubscriptionTopicFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriDownstreamSubscriptionTopic &&
            (identical(other.lineRef, lineRef) ||
                const DeepCollectionEquality().equals(
                  other.lineRef,
                  lineRef,
                )) &&
            (identical(other.directionRef, directionRef) ||
                const DeepCollectionEquality().equals(
                  other.directionRef,
                  directionRef,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lineRef) ^
      const DeepCollectionEquality().hash(directionRef) ^
      const DeepCollectionEquality().hash(routeType) ^
      runtimeType.hashCode;
}

extension $V3SiriDownstreamSubscriptionTopicExtension
    on V3SiriDownstreamSubscriptionTopic {
  V3SiriDownstreamSubscriptionTopic copyWith({
    String? lineRef,
    int? directionRef,
    int? routeType,
  }) {
    return V3SiriDownstreamSubscriptionTopic(
      lineRef: lineRef ?? this.lineRef,
      directionRef: directionRef ?? this.directionRef,
      routeType: routeType ?? this.routeType,
    );
  }

  V3SiriDownstreamSubscriptionTopic copyWithWrapped({
    Wrapped<String?>? lineRef,
    Wrapped<int?>? directionRef,
    Wrapped<int?>? routeType,
  }) {
    return V3SiriDownstreamSubscriptionTopic(
      lineRef: (lineRef != null ? lineRef.value : this.lineRef),
      directionRef: (directionRef != null
          ? directionRef.value
          : this.directionRef),
      routeType: (routeType != null ? routeType.value : this.routeType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriProductionTimetableSubscriptionRequest {
  const V3SiriProductionTimetableSubscriptionRequest({
    required this.startTime,
    required this.endTime,
    required this.subscriberRef,
    required this.subscriptionRef,
    required this.siriFormat,
    required this.siriVersion,
    required this.consumerAddress,
    required this.initialTerminationTime,
    required this.topics,
  });

  factory V3SiriProductionTimetableSubscriptionRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$V3SiriProductionTimetableSubscriptionRequestFromJson(json);

  static const toJsonFactory =
      _$V3SiriProductionTimetableSubscriptionRequestToJson;
  Map<String, dynamic> toJson() =>
      _$V3SiriProductionTimetableSubscriptionRequestToJson(this);

  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @JsonKey(name: 'subscriber_ref')
  final String subscriberRef;
  @JsonKey(name: 'subscription_ref')
  final String subscriptionRef;
  @JsonKey(name: 'siri_format')
  final int siriFormat;
  @JsonKey(name: 'siri_version')
  final String siriVersion;
  @JsonKey(name: 'consumer_address')
  final String consumerAddress;
  @JsonKey(name: 'initial_termination_time')
  final DateTime initialTerminationTime;
  @JsonKey(name: 'topics', defaultValue: <V3SiriSubscriptionTopic>[])
  final List<V3SiriSubscriptionTopic> topics;
  static const fromJsonFactory =
      _$V3SiriProductionTimetableSubscriptionRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriProductionTimetableSubscriptionRequest &&
            (identical(other.startTime, startTime) ||
                const DeepCollectionEquality().equals(
                  other.startTime,
                  startTime,
                )) &&
            (identical(other.endTime, endTime) ||
                const DeepCollectionEquality().equals(
                  other.endTime,
                  endTime,
                )) &&
            (identical(other.subscriberRef, subscriberRef) ||
                const DeepCollectionEquality().equals(
                  other.subscriberRef,
                  subscriberRef,
                )) &&
            (identical(other.subscriptionRef, subscriptionRef) ||
                const DeepCollectionEquality().equals(
                  other.subscriptionRef,
                  subscriptionRef,
                )) &&
            (identical(other.siriFormat, siriFormat) ||
                const DeepCollectionEquality().equals(
                  other.siriFormat,
                  siriFormat,
                )) &&
            (identical(other.siriVersion, siriVersion) ||
                const DeepCollectionEquality().equals(
                  other.siriVersion,
                  siriVersion,
                )) &&
            (identical(other.consumerAddress, consumerAddress) ||
                const DeepCollectionEquality().equals(
                  other.consumerAddress,
                  consumerAddress,
                )) &&
            (identical(other.initialTerminationTime, initialTerminationTime) ||
                const DeepCollectionEquality().equals(
                  other.initialTerminationTime,
                  initialTerminationTime,
                )) &&
            (identical(other.topics, topics) ||
                const DeepCollectionEquality().equals(other.topics, topics)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(startTime) ^
      const DeepCollectionEquality().hash(endTime) ^
      const DeepCollectionEquality().hash(subscriberRef) ^
      const DeepCollectionEquality().hash(subscriptionRef) ^
      const DeepCollectionEquality().hash(siriFormat) ^
      const DeepCollectionEquality().hash(siriVersion) ^
      const DeepCollectionEquality().hash(consumerAddress) ^
      const DeepCollectionEquality().hash(initialTerminationTime) ^
      const DeepCollectionEquality().hash(topics) ^
      runtimeType.hashCode;
}

extension $V3SiriProductionTimetableSubscriptionRequestExtension
    on V3SiriProductionTimetableSubscriptionRequest {
  V3SiriProductionTimetableSubscriptionRequest copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? subscriberRef,
    String? subscriptionRef,
    int? siriFormat,
    String? siriVersion,
    String? consumerAddress,
    DateTime? initialTerminationTime,
    List<V3SiriSubscriptionTopic>? topics,
  }) {
    return V3SiriProductionTimetableSubscriptionRequest(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subscriberRef: subscriberRef ?? this.subscriberRef,
      subscriptionRef: subscriptionRef ?? this.subscriptionRef,
      siriFormat: siriFormat ?? this.siriFormat,
      siriVersion: siriVersion ?? this.siriVersion,
      consumerAddress: consumerAddress ?? this.consumerAddress,
      initialTerminationTime:
          initialTerminationTime ?? this.initialTerminationTime,
      topics: topics ?? this.topics,
    );
  }

  V3SiriProductionTimetableSubscriptionRequest copyWithWrapped({
    Wrapped<DateTime>? startTime,
    Wrapped<DateTime>? endTime,
    Wrapped<String>? subscriberRef,
    Wrapped<String>? subscriptionRef,
    Wrapped<int>? siriFormat,
    Wrapped<String>? siriVersion,
    Wrapped<String>? consumerAddress,
    Wrapped<DateTime>? initialTerminationTime,
    Wrapped<List<V3SiriSubscriptionTopic>>? topics,
  }) {
    return V3SiriProductionTimetableSubscriptionRequest(
      startTime: (startTime != null ? startTime.value : this.startTime),
      endTime: (endTime != null ? endTime.value : this.endTime),
      subscriberRef: (subscriberRef != null
          ? subscriberRef.value
          : this.subscriberRef),
      subscriptionRef: (subscriptionRef != null
          ? subscriptionRef.value
          : this.subscriptionRef),
      siriFormat: (siriFormat != null ? siriFormat.value : this.siriFormat),
      siriVersion: (siriVersion != null ? siriVersion.value : this.siriVersion),
      consumerAddress: (consumerAddress != null
          ? consumerAddress.value
          : this.consumerAddress),
      initialTerminationTime: (initialTerminationTime != null
          ? initialTerminationTime.value
          : this.initialTerminationTime),
      topics: (topics != null ? topics.value : this.topics),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriSubscriptionTopic {
  const V3SiriSubscriptionTopic({
    required this.lineRef,
    this.directionRef,
    required this.routeType,
  });

  factory V3SiriSubscriptionTopic.fromJson(Map<String, dynamic> json) =>
      _$V3SiriSubscriptionTopicFromJson(json);

  static const toJsonFactory = _$V3SiriSubscriptionTopicToJson;
  Map<String, dynamic> toJson() => _$V3SiriSubscriptionTopicToJson(this);

  @JsonKey(name: 'line_ref')
  final String lineRef;
  @JsonKey(name: 'direction_ref')
  final int? directionRef;
  @JsonKey(name: 'route_type')
  final int routeType;
  static const fromJsonFactory = _$V3SiriSubscriptionTopicFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriSubscriptionTopic &&
            (identical(other.lineRef, lineRef) ||
                const DeepCollectionEquality().equals(
                  other.lineRef,
                  lineRef,
                )) &&
            (identical(other.directionRef, directionRef) ||
                const DeepCollectionEquality().equals(
                  other.directionRef,
                  directionRef,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lineRef) ^
      const DeepCollectionEquality().hash(directionRef) ^
      const DeepCollectionEquality().hash(routeType) ^
      runtimeType.hashCode;
}

extension $V3SiriSubscriptionTopicExtension on V3SiriSubscriptionTopic {
  V3SiriSubscriptionTopic copyWith({
    String? lineRef,
    int? directionRef,
    int? routeType,
  }) {
    return V3SiriSubscriptionTopic(
      lineRef: lineRef ?? this.lineRef,
      directionRef: directionRef ?? this.directionRef,
      routeType: routeType ?? this.routeType,
    );
  }

  V3SiriSubscriptionTopic copyWithWrapped({
    Wrapped<String>? lineRef,
    Wrapped<int?>? directionRef,
    Wrapped<int>? routeType,
  }) {
    return V3SiriSubscriptionTopic(
      lineRef: (lineRef != null ? lineRef.value : this.lineRef),
      directionRef: (directionRef != null
          ? directionRef.value
          : this.directionRef),
      routeType: (routeType != null ? routeType.value : this.routeType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriDownstreamSubscriptionResponse {
  const V3SiriDownstreamSubscriptionResponse({this.validUntil});

  factory V3SiriDownstreamSubscriptionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$V3SiriDownstreamSubscriptionResponseFromJson(json);

  static const toJsonFactory = _$V3SiriDownstreamSubscriptionResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V3SiriDownstreamSubscriptionResponseToJson(this);

  @JsonKey(name: 'valid_until')
  final DateTime? validUntil;
  static const fromJsonFactory = _$V3SiriDownstreamSubscriptionResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriDownstreamSubscriptionResponse &&
            (identical(other.validUntil, validUntil) ||
                const DeepCollectionEquality().equals(
                  other.validUntil,
                  validUntil,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(validUntil) ^ runtimeType.hashCode;
}

extension $V3SiriDownstreamSubscriptionResponseExtension
    on V3SiriDownstreamSubscriptionResponse {
  V3SiriDownstreamSubscriptionResponse copyWith({DateTime? validUntil}) {
    return V3SiriDownstreamSubscriptionResponse(
      validUntil: validUntil ?? this.validUntil,
    );
  }

  V3SiriDownstreamSubscriptionResponse copyWithWrapped({
    Wrapped<DateTime?>? validUntil,
  }) {
    return V3SiriDownstreamSubscriptionResponse(
      validUntil: (validUntil != null ? validUntil.value : this.validUntil),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriEstimatedTimetableSubscriptionRequest {
  const V3SiriEstimatedTimetableSubscriptionRequest({
    required this.previewInterval,
    required this.subscriberRef,
    required this.subscriptionRef,
    required this.siriFormat,
    required this.siriVersion,
    required this.consumerAddress,
    required this.initialTerminationTime,
    required this.topics,
  });

  factory V3SiriEstimatedTimetableSubscriptionRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$V3SiriEstimatedTimetableSubscriptionRequestFromJson(json);

  static const toJsonFactory =
      _$V3SiriEstimatedTimetableSubscriptionRequestToJson;
  Map<String, dynamic> toJson() =>
      _$V3SiriEstimatedTimetableSubscriptionRequestToJson(this);

  @JsonKey(name: 'preview_interval')
  final String previewInterval;
  @JsonKey(name: 'subscriber_ref')
  final String subscriberRef;
  @JsonKey(name: 'subscription_ref')
  final String subscriptionRef;
  @JsonKey(name: 'siri_format')
  final int siriFormat;
  @JsonKey(name: 'siri_version')
  final String siriVersion;
  @JsonKey(name: 'consumer_address')
  final String consumerAddress;
  @JsonKey(name: 'initial_termination_time')
  final DateTime initialTerminationTime;
  @JsonKey(name: 'topics', defaultValue: <V3SiriSubscriptionTopic>[])
  final List<V3SiriSubscriptionTopic> topics;
  static const fromJsonFactory =
      _$V3SiriEstimatedTimetableSubscriptionRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriEstimatedTimetableSubscriptionRequest &&
            (identical(other.previewInterval, previewInterval) ||
                const DeepCollectionEquality().equals(
                  other.previewInterval,
                  previewInterval,
                )) &&
            (identical(other.subscriberRef, subscriberRef) ||
                const DeepCollectionEquality().equals(
                  other.subscriberRef,
                  subscriberRef,
                )) &&
            (identical(other.subscriptionRef, subscriptionRef) ||
                const DeepCollectionEquality().equals(
                  other.subscriptionRef,
                  subscriptionRef,
                )) &&
            (identical(other.siriFormat, siriFormat) ||
                const DeepCollectionEquality().equals(
                  other.siriFormat,
                  siriFormat,
                )) &&
            (identical(other.siriVersion, siriVersion) ||
                const DeepCollectionEquality().equals(
                  other.siriVersion,
                  siriVersion,
                )) &&
            (identical(other.consumerAddress, consumerAddress) ||
                const DeepCollectionEquality().equals(
                  other.consumerAddress,
                  consumerAddress,
                )) &&
            (identical(other.initialTerminationTime, initialTerminationTime) ||
                const DeepCollectionEquality().equals(
                  other.initialTerminationTime,
                  initialTerminationTime,
                )) &&
            (identical(other.topics, topics) ||
                const DeepCollectionEquality().equals(other.topics, topics)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(previewInterval) ^
      const DeepCollectionEquality().hash(subscriberRef) ^
      const DeepCollectionEquality().hash(subscriptionRef) ^
      const DeepCollectionEquality().hash(siriFormat) ^
      const DeepCollectionEquality().hash(siriVersion) ^
      const DeepCollectionEquality().hash(consumerAddress) ^
      const DeepCollectionEquality().hash(initialTerminationTime) ^
      const DeepCollectionEquality().hash(topics) ^
      runtimeType.hashCode;
}

extension $V3SiriEstimatedTimetableSubscriptionRequestExtension
    on V3SiriEstimatedTimetableSubscriptionRequest {
  V3SiriEstimatedTimetableSubscriptionRequest copyWith({
    String? previewInterval,
    String? subscriberRef,
    String? subscriptionRef,
    int? siriFormat,
    String? siriVersion,
    String? consumerAddress,
    DateTime? initialTerminationTime,
    List<V3SiriSubscriptionTopic>? topics,
  }) {
    return V3SiriEstimatedTimetableSubscriptionRequest(
      previewInterval: previewInterval ?? this.previewInterval,
      subscriberRef: subscriberRef ?? this.subscriberRef,
      subscriptionRef: subscriptionRef ?? this.subscriptionRef,
      siriFormat: siriFormat ?? this.siriFormat,
      siriVersion: siriVersion ?? this.siriVersion,
      consumerAddress: consumerAddress ?? this.consumerAddress,
      initialTerminationTime:
          initialTerminationTime ?? this.initialTerminationTime,
      topics: topics ?? this.topics,
    );
  }

  V3SiriEstimatedTimetableSubscriptionRequest copyWithWrapped({
    Wrapped<String>? previewInterval,
    Wrapped<String>? subscriberRef,
    Wrapped<String>? subscriptionRef,
    Wrapped<int>? siriFormat,
    Wrapped<String>? siriVersion,
    Wrapped<String>? consumerAddress,
    Wrapped<DateTime>? initialTerminationTime,
    Wrapped<List<V3SiriSubscriptionTopic>>? topics,
  }) {
    return V3SiriEstimatedTimetableSubscriptionRequest(
      previewInterval: (previewInterval != null
          ? previewInterval.value
          : this.previewInterval),
      subscriberRef: (subscriberRef != null
          ? subscriberRef.value
          : this.subscriberRef),
      subscriptionRef: (subscriptionRef != null
          ? subscriptionRef.value
          : this.subscriptionRef),
      siriFormat: (siriFormat != null ? siriFormat.value : this.siriFormat),
      siriVersion: (siriVersion != null ? siriVersion.value : this.siriVersion),
      consumerAddress: (consumerAddress != null
          ? consumerAddress.value
          : this.consumerAddress),
      initialTerminationTime: (initialTerminationTime != null
          ? initialTerminationTime.value
          : this.initialTerminationTime),
      topics: (topics != null ? topics.value : this.topics),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3SiriDownstreamSubscriptionDeleteRequest {
  const V3SiriDownstreamSubscriptionDeleteRequest({
    required this.subscriberRef,
    this.subscriptionRef,
  });

  factory V3SiriDownstreamSubscriptionDeleteRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$V3SiriDownstreamSubscriptionDeleteRequestFromJson(json);

  static const toJsonFactory =
      _$V3SiriDownstreamSubscriptionDeleteRequestToJson;
  Map<String, dynamic> toJson() =>
      _$V3SiriDownstreamSubscriptionDeleteRequestToJson(this);

  @JsonKey(name: 'subscriber_ref')
  final String subscriberRef;
  @JsonKey(name: 'subscription_ref', defaultValue: <String>[])
  final List<String>? subscriptionRef;
  static const fromJsonFactory =
      _$V3SiriDownstreamSubscriptionDeleteRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3SiriDownstreamSubscriptionDeleteRequest &&
            (identical(other.subscriberRef, subscriberRef) ||
                const DeepCollectionEquality().equals(
                  other.subscriberRef,
                  subscriberRef,
                )) &&
            (identical(other.subscriptionRef, subscriptionRef) ||
                const DeepCollectionEquality().equals(
                  other.subscriptionRef,
                  subscriptionRef,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(subscriberRef) ^
      const DeepCollectionEquality().hash(subscriptionRef) ^
      runtimeType.hashCode;
}

extension $V3SiriDownstreamSubscriptionDeleteRequestExtension
    on V3SiriDownstreamSubscriptionDeleteRequest {
  V3SiriDownstreamSubscriptionDeleteRequest copyWith({
    String? subscriberRef,
    List<String>? subscriptionRef,
  }) {
    return V3SiriDownstreamSubscriptionDeleteRequest(
      subscriberRef: subscriberRef ?? this.subscriberRef,
      subscriptionRef: subscriptionRef ?? this.subscriptionRef,
    );
  }

  V3SiriDownstreamSubscriptionDeleteRequest copyWithWrapped({
    Wrapped<String>? subscriberRef,
    Wrapped<List<String>?>? subscriptionRef,
  }) {
    return V3SiriDownstreamSubscriptionDeleteRequest(
      subscriberRef: (subscriberRef != null
          ? subscriberRef.value
          : this.subscriberRef),
      subscriptionRef: (subscriptionRef != null
          ? subscriptionRef.value
          : this.subscriptionRef),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3Void {
  const V3Void();

  factory V3Void.fromJson(Map<String, dynamic> json) => _$V3VoidFromJson(json);

  static const toJsonFactory = _$V3VoidToJson;
  Map<String, dynamic> toJson() => _$V3VoidToJson(this);

  static const fromJsonFactory = _$V3VoidFromJson;

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode => runtimeType.hashCode;
}

@JsonSerializable(explicitToJson: true)
class V3StopResponse {
  const V3StopResponse({this.stop, this.disruptions, this.status});

  factory V3StopResponse.fromJson(Map<String, dynamic> json) =>
      _$V3StopResponseFromJson(json);

  static const toJsonFactory = _$V3StopResponseToJson;
  Map<String, dynamic> toJson() => _$V3StopResponseToJson(this);

  @JsonKey(name: 'stop')
  final V3StopDetails? stop;
  @JsonKey(name: 'disruptions')
  final Map<String, dynamic>? disruptions;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3StopResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopResponse &&
            (identical(other.stop, stop) ||
                const DeepCollectionEquality().equals(other.stop, stop)) &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stop) ^
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3StopResponseExtension on V3StopResponse {
  V3StopResponse copyWith({
    V3StopDetails? stop,
    Map<String, dynamic>? disruptions,
    V3Status? status,
  }) {
    return V3StopResponse(
      stop: stop ?? this.stop,
      disruptions: disruptions ?? this.disruptions,
      status: status ?? this.status,
    );
  }

  V3StopResponse copyWithWrapped({
    Wrapped<V3StopDetails?>? stop,
    Wrapped<Map<String, dynamic>?>? disruptions,
    Wrapped<V3Status?>? status,
  }) {
    return V3StopResponse(
      stop: (stop != null ? stop.value : this.stop),
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopDetails {
  const V3StopDetails({
    this.disruptionIds,
    this.stationType,
    this.stationDescription,
    this.routeType,
    this.stopLocation,
    this.stopAmenities,
    this.stopAccessibility,
    this.stopStaffing,
    this.routes,
    this.stopId,
    this.stopName,
    this.stopLandmark,
  });

  factory V3StopDetails.fromJson(Map<String, dynamic> json) =>
      _$V3StopDetailsFromJson(json);

  static const toJsonFactory = _$V3StopDetailsToJson;
  Map<String, dynamic> toJson() => _$V3StopDetailsToJson(this);

  @JsonKey(name: 'disruption_ids', defaultValue: <int>[])
  final List<int>? disruptionIds;
  @JsonKey(name: 'station_type')
  final String? stationType;
  @JsonKey(name: 'station_description')
  final String? stationDescription;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'stop_location')
  final V3StopLocation? stopLocation;
  @JsonKey(name: 'stop_amenities')
  final V3StopAmenityDetails? stopAmenities;
  @JsonKey(name: 'stop_accessibility')
  final V3StopAccessibility? stopAccessibility;
  @JsonKey(name: 'stop_staffing')
  final V3StopStaffing? stopStaffing;
  @JsonKey(name: 'routes', defaultValue: <Object>[])
  final List<Object>? routes;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  @JsonKey(name: 'stop_landmark')
  final String? stopLandmark;
  static const fromJsonFactory = _$V3StopDetailsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopDetails &&
            (identical(other.disruptionIds, disruptionIds) ||
                const DeepCollectionEquality().equals(
                  other.disruptionIds,
                  disruptionIds,
                )) &&
            (identical(other.stationType, stationType) ||
                const DeepCollectionEquality().equals(
                  other.stationType,
                  stationType,
                )) &&
            (identical(other.stationDescription, stationDescription) ||
                const DeepCollectionEquality().equals(
                  other.stationDescription,
                  stationDescription,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.stopLocation, stopLocation) ||
                const DeepCollectionEquality().equals(
                  other.stopLocation,
                  stopLocation,
                )) &&
            (identical(other.stopAmenities, stopAmenities) ||
                const DeepCollectionEquality().equals(
                  other.stopAmenities,
                  stopAmenities,
                )) &&
            (identical(other.stopAccessibility, stopAccessibility) ||
                const DeepCollectionEquality().equals(
                  other.stopAccessibility,
                  stopAccessibility,
                )) &&
            (identical(other.stopStaffing, stopStaffing) ||
                const DeepCollectionEquality().equals(
                  other.stopStaffing,
                  stopStaffing,
                )) &&
            (identical(other.routes, routes) ||
                const DeepCollectionEquality().equals(other.routes, routes)) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )) &&
            (identical(other.stopLandmark, stopLandmark) ||
                const DeepCollectionEquality().equals(
                  other.stopLandmark,
                  stopLandmark,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptionIds) ^
      const DeepCollectionEquality().hash(stationType) ^
      const DeepCollectionEquality().hash(stationDescription) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(stopLocation) ^
      const DeepCollectionEquality().hash(stopAmenities) ^
      const DeepCollectionEquality().hash(stopAccessibility) ^
      const DeepCollectionEquality().hash(stopStaffing) ^
      const DeepCollectionEquality().hash(routes) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(stopName) ^
      const DeepCollectionEquality().hash(stopLandmark) ^
      runtimeType.hashCode;
}

extension $V3StopDetailsExtension on V3StopDetails {
  V3StopDetails copyWith({
    List<int>? disruptionIds,
    String? stationType,
    String? stationDescription,
    int? routeType,
    V3StopLocation? stopLocation,
    V3StopAmenityDetails? stopAmenities,
    V3StopAccessibility? stopAccessibility,
    V3StopStaffing? stopStaffing,
    List<Object>? routes,
    int? stopId,
    String? stopName,
    String? stopLandmark,
  }) {
    return V3StopDetails(
      disruptionIds: disruptionIds ?? this.disruptionIds,
      stationType: stationType ?? this.stationType,
      stationDescription: stationDescription ?? this.stationDescription,
      routeType: routeType ?? this.routeType,
      stopLocation: stopLocation ?? this.stopLocation,
      stopAmenities: stopAmenities ?? this.stopAmenities,
      stopAccessibility: stopAccessibility ?? this.stopAccessibility,
      stopStaffing: stopStaffing ?? this.stopStaffing,
      routes: routes ?? this.routes,
      stopId: stopId ?? this.stopId,
      stopName: stopName ?? this.stopName,
      stopLandmark: stopLandmark ?? this.stopLandmark,
    );
  }

  V3StopDetails copyWithWrapped({
    Wrapped<List<int>?>? disruptionIds,
    Wrapped<String?>? stationType,
    Wrapped<String?>? stationDescription,
    Wrapped<int?>? routeType,
    Wrapped<V3StopLocation?>? stopLocation,
    Wrapped<V3StopAmenityDetails?>? stopAmenities,
    Wrapped<V3StopAccessibility?>? stopAccessibility,
    Wrapped<V3StopStaffing?>? stopStaffing,
    Wrapped<List<Object>?>? routes,
    Wrapped<int?>? stopId,
    Wrapped<String?>? stopName,
    Wrapped<String?>? stopLandmark,
  }) {
    return V3StopDetails(
      disruptionIds: (disruptionIds != null
          ? disruptionIds.value
          : this.disruptionIds),
      stationType: (stationType != null ? stationType.value : this.stationType),
      stationDescription: (stationDescription != null
          ? stationDescription.value
          : this.stationDescription),
      routeType: (routeType != null ? routeType.value : this.routeType),
      stopLocation: (stopLocation != null
          ? stopLocation.value
          : this.stopLocation),
      stopAmenities: (stopAmenities != null
          ? stopAmenities.value
          : this.stopAmenities),
      stopAccessibility: (stopAccessibility != null
          ? stopAccessibility.value
          : this.stopAccessibility),
      stopStaffing: (stopStaffing != null
          ? stopStaffing.value
          : this.stopStaffing),
      routes: (routes != null ? routes.value : this.routes),
      stopId: (stopId != null ? stopId.value : this.stopId),
      stopName: (stopName != null ? stopName.value : this.stopName),
      stopLandmark: (stopLandmark != null
          ? stopLandmark.value
          : this.stopLandmark),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopLocation {
  const V3StopLocation({this.gps});

  factory V3StopLocation.fromJson(Map<String, dynamic> json) =>
      _$V3StopLocationFromJson(json);

  static const toJsonFactory = _$V3StopLocationToJson;
  Map<String, dynamic> toJson() => _$V3StopLocationToJson(this);

  @JsonKey(name: 'gps')
  final V3StopGps? gps;
  static const fromJsonFactory = _$V3StopLocationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopLocation &&
            (identical(other.gps, gps) ||
                const DeepCollectionEquality().equals(other.gps, gps)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(gps) ^ runtimeType.hashCode;
}

extension $V3StopLocationExtension on V3StopLocation {
  V3StopLocation copyWith({V3StopGps? gps}) {
    return V3StopLocation(gps: gps ?? this.gps);
  }

  V3StopLocation copyWithWrapped({Wrapped<V3StopGps?>? gps}) {
    return V3StopLocation(gps: (gps != null ? gps.value : this.gps));
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopAmenityDetails {
  const V3StopAmenityDetails({
    this.toilet,
    this.taxiRank,
    this.carParking,
    this.cctv,
  });

  factory V3StopAmenityDetails.fromJson(Map<String, dynamic> json) =>
      _$V3StopAmenityDetailsFromJson(json);

  static const toJsonFactory = _$V3StopAmenityDetailsToJson;
  Map<String, dynamic> toJson() => _$V3StopAmenityDetailsToJson(this);

  @JsonKey(name: 'toilet')
  final bool? toilet;
  @JsonKey(name: 'taxi_rank')
  final bool? taxiRank;
  @JsonKey(name: 'car_parking')
  final String? carParking;
  @JsonKey(name: 'cctv')
  final bool? cctv;
  static const fromJsonFactory = _$V3StopAmenityDetailsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopAmenityDetails &&
            (identical(other.toilet, toilet) ||
                const DeepCollectionEquality().equals(other.toilet, toilet)) &&
            (identical(other.taxiRank, taxiRank) ||
                const DeepCollectionEquality().equals(
                  other.taxiRank,
                  taxiRank,
                )) &&
            (identical(other.carParking, carParking) ||
                const DeepCollectionEquality().equals(
                  other.carParking,
                  carParking,
                )) &&
            (identical(other.cctv, cctv) ||
                const DeepCollectionEquality().equals(other.cctv, cctv)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(toilet) ^
      const DeepCollectionEquality().hash(taxiRank) ^
      const DeepCollectionEquality().hash(carParking) ^
      const DeepCollectionEquality().hash(cctv) ^
      runtimeType.hashCode;
}

extension $V3StopAmenityDetailsExtension on V3StopAmenityDetails {
  V3StopAmenityDetails copyWith({
    bool? toilet,
    bool? taxiRank,
    String? carParking,
    bool? cctv,
  }) {
    return V3StopAmenityDetails(
      toilet: toilet ?? this.toilet,
      taxiRank: taxiRank ?? this.taxiRank,
      carParking: carParking ?? this.carParking,
      cctv: cctv ?? this.cctv,
    );
  }

  V3StopAmenityDetails copyWithWrapped({
    Wrapped<bool?>? toilet,
    Wrapped<bool?>? taxiRank,
    Wrapped<String?>? carParking,
    Wrapped<bool?>? cctv,
  }) {
    return V3StopAmenityDetails(
      toilet: (toilet != null ? toilet.value : this.toilet),
      taxiRank: (taxiRank != null ? taxiRank.value : this.taxiRank),
      carParking: (carParking != null ? carParking.value : this.carParking),
      cctv: (cctv != null ? cctv.value : this.cctv),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopAccessibility {
  const V3StopAccessibility({
    this.lighting,
    this.platformNumber,
    this.audioCustomerInformation,
    this.escalator,
    this.hearingLoop,
    this.lift,
    this.stairs,
    this.stopAccessible,
    this.tactileGroundSurfaceIndicator,
    this.waitingRoom,
    this.wheelchair,
  });

  factory V3StopAccessibility.fromJson(Map<String, dynamic> json) =>
      _$V3StopAccessibilityFromJson(json);

  static const toJsonFactory = _$V3StopAccessibilityToJson;
  Map<String, dynamic> toJson() => _$V3StopAccessibilityToJson(this);

  @JsonKey(name: 'lighting')
  final bool? lighting;
  @JsonKey(name: 'platform_number')
  final int? platformNumber;
  @JsonKey(name: 'audio_customer_information')
  final bool? audioCustomerInformation;
  @JsonKey(name: 'escalator')
  final bool? escalator;
  @JsonKey(name: 'hearing_loop')
  final bool? hearingLoop;
  @JsonKey(name: 'lift')
  final bool? lift;
  @JsonKey(name: 'stairs')
  final bool? stairs;
  @JsonKey(name: 'stop_accessible')
  final bool? stopAccessible;
  @JsonKey(name: 'tactile_ground_surface_indicator')
  final bool? tactileGroundSurfaceIndicator;
  @JsonKey(name: 'waiting_room')
  final bool? waitingRoom;
  @JsonKey(name: 'wheelchair')
  final V3StopAccessibilityWheelchair? wheelchair;
  static const fromJsonFactory = _$V3StopAccessibilityFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopAccessibility &&
            (identical(other.lighting, lighting) ||
                const DeepCollectionEquality().equals(
                  other.lighting,
                  lighting,
                )) &&
            (identical(other.platformNumber, platformNumber) ||
                const DeepCollectionEquality().equals(
                  other.platformNumber,
                  platformNumber,
                )) &&
            (identical(
                  other.audioCustomerInformation,
                  audioCustomerInformation,
                ) ||
                const DeepCollectionEquality().equals(
                  other.audioCustomerInformation,
                  audioCustomerInformation,
                )) &&
            (identical(other.escalator, escalator) ||
                const DeepCollectionEquality().equals(
                  other.escalator,
                  escalator,
                )) &&
            (identical(other.hearingLoop, hearingLoop) ||
                const DeepCollectionEquality().equals(
                  other.hearingLoop,
                  hearingLoop,
                )) &&
            (identical(other.lift, lift) ||
                const DeepCollectionEquality().equals(other.lift, lift)) &&
            (identical(other.stairs, stairs) ||
                const DeepCollectionEquality().equals(other.stairs, stairs)) &&
            (identical(other.stopAccessible, stopAccessible) ||
                const DeepCollectionEquality().equals(
                  other.stopAccessible,
                  stopAccessible,
                )) &&
            (identical(
                  other.tactileGroundSurfaceIndicator,
                  tactileGroundSurfaceIndicator,
                ) ||
                const DeepCollectionEquality().equals(
                  other.tactileGroundSurfaceIndicator,
                  tactileGroundSurfaceIndicator,
                )) &&
            (identical(other.waitingRoom, waitingRoom) ||
                const DeepCollectionEquality().equals(
                  other.waitingRoom,
                  waitingRoom,
                )) &&
            (identical(other.wheelchair, wheelchair) ||
                const DeepCollectionEquality().equals(
                  other.wheelchair,
                  wheelchair,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lighting) ^
      const DeepCollectionEquality().hash(platformNumber) ^
      const DeepCollectionEquality().hash(audioCustomerInformation) ^
      const DeepCollectionEquality().hash(escalator) ^
      const DeepCollectionEquality().hash(hearingLoop) ^
      const DeepCollectionEquality().hash(lift) ^
      const DeepCollectionEquality().hash(stairs) ^
      const DeepCollectionEquality().hash(stopAccessible) ^
      const DeepCollectionEquality().hash(tactileGroundSurfaceIndicator) ^
      const DeepCollectionEquality().hash(waitingRoom) ^
      const DeepCollectionEquality().hash(wheelchair) ^
      runtimeType.hashCode;
}

extension $V3StopAccessibilityExtension on V3StopAccessibility {
  V3StopAccessibility copyWith({
    bool? lighting,
    int? platformNumber,
    bool? audioCustomerInformation,
    bool? escalator,
    bool? hearingLoop,
    bool? lift,
    bool? stairs,
    bool? stopAccessible,
    bool? tactileGroundSurfaceIndicator,
    bool? waitingRoom,
    V3StopAccessibilityWheelchair? wheelchair,
  }) {
    return V3StopAccessibility(
      lighting: lighting ?? this.lighting,
      platformNumber: platformNumber ?? this.platformNumber,
      audioCustomerInformation:
          audioCustomerInformation ?? this.audioCustomerInformation,
      escalator: escalator ?? this.escalator,
      hearingLoop: hearingLoop ?? this.hearingLoop,
      lift: lift ?? this.lift,
      stairs: stairs ?? this.stairs,
      stopAccessible: stopAccessible ?? this.stopAccessible,
      tactileGroundSurfaceIndicator:
          tactileGroundSurfaceIndicator ?? this.tactileGroundSurfaceIndicator,
      waitingRoom: waitingRoom ?? this.waitingRoom,
      wheelchair: wheelchair ?? this.wheelchair,
    );
  }

  V3StopAccessibility copyWithWrapped({
    Wrapped<bool?>? lighting,
    Wrapped<int?>? platformNumber,
    Wrapped<bool?>? audioCustomerInformation,
    Wrapped<bool?>? escalator,
    Wrapped<bool?>? hearingLoop,
    Wrapped<bool?>? lift,
    Wrapped<bool?>? stairs,
    Wrapped<bool?>? stopAccessible,
    Wrapped<bool?>? tactileGroundSurfaceIndicator,
    Wrapped<bool?>? waitingRoom,
    Wrapped<V3StopAccessibilityWheelchair?>? wheelchair,
  }) {
    return V3StopAccessibility(
      lighting: (lighting != null ? lighting.value : this.lighting),
      platformNumber: (platformNumber != null
          ? platformNumber.value
          : this.platformNumber),
      audioCustomerInformation: (audioCustomerInformation != null
          ? audioCustomerInformation.value
          : this.audioCustomerInformation),
      escalator: (escalator != null ? escalator.value : this.escalator),
      hearingLoop: (hearingLoop != null ? hearingLoop.value : this.hearingLoop),
      lift: (lift != null ? lift.value : this.lift),
      stairs: (stairs != null ? stairs.value : this.stairs),
      stopAccessible: (stopAccessible != null
          ? stopAccessible.value
          : this.stopAccessible),
      tactileGroundSurfaceIndicator: (tactileGroundSurfaceIndicator != null
          ? tactileGroundSurfaceIndicator.value
          : this.tactileGroundSurfaceIndicator),
      waitingRoom: (waitingRoom != null ? waitingRoom.value : this.waitingRoom),
      wheelchair: (wheelchair != null ? wheelchair.value : this.wheelchair),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopStaffing {
  const V3StopStaffing({
    this.friAmFrom,
    this.friAmTo,
    this.friPmFrom,
    this.friPmTo,
    this.monAmFrom,
    this.monAmTo,
    this.monPmFrom,
    this.monPmTo,
    this.phAdditionalText,
    this.phFrom,
    this.phTo,
    this.satAmFrom,
    this.satAmTo,
    this.satPmFrom,
    this.satPmTo,
    this.sunAmFrom,
    this.sunAmTo,
    this.sunPmFrom,
    this.sunPmTo,
    this.thuAmFrom,
    this.thuAmTo,
    this.thuPmFrom,
    this.thuPmTo,
    this.tueAmFrom,
    this.tueAmTo,
    this.tuePmFrom,
    this.tuePmTo,
    this.wedAmFrom,
    this.wedAmTo,
    this.wedPmFrom,
    this.wedPmTo,
  });

  factory V3StopStaffing.fromJson(Map<String, dynamic> json) =>
      _$V3StopStaffingFromJson(json);

  static const toJsonFactory = _$V3StopStaffingToJson;
  Map<String, dynamic> toJson() => _$V3StopStaffingToJson(this);

  @JsonKey(name: 'fri_am_from')
  final String? friAmFrom;
  @JsonKey(name: 'fri_am_to')
  final String? friAmTo;
  @JsonKey(name: 'fri_pm_from')
  final String? friPmFrom;
  @JsonKey(name: 'fri_pm_to')
  final String? friPmTo;
  @JsonKey(name: 'mon_am_from')
  final String? monAmFrom;
  @JsonKey(name: 'mon_am_to')
  final String? monAmTo;
  @JsonKey(name: 'mon_pm_from')
  final String? monPmFrom;
  @JsonKey(name: 'mon_pm_to')
  final String? monPmTo;
  @JsonKey(name: 'ph_additional_text')
  final String? phAdditionalText;
  @JsonKey(name: 'ph_from')
  final String? phFrom;
  @JsonKey(name: 'ph_to')
  final String? phTo;
  @JsonKey(name: 'sat_am_from')
  final String? satAmFrom;
  @JsonKey(name: 'sat_am_to')
  final String? satAmTo;
  @JsonKey(name: 'sat_pm_from')
  final String? satPmFrom;
  @JsonKey(name: 'sat_pm_to')
  final String? satPmTo;
  @JsonKey(name: 'sun_am_from')
  final String? sunAmFrom;
  @JsonKey(name: 'sun_am_to')
  final String? sunAmTo;
  @JsonKey(name: 'sun_pm_from')
  final String? sunPmFrom;
  @JsonKey(name: 'sun_pm_to')
  final String? sunPmTo;
  @JsonKey(name: 'thu_am_from')
  final String? thuAmFrom;
  @JsonKey(name: 'thu_am_to')
  final String? thuAmTo;
  @JsonKey(name: 'thu_pm_from')
  final String? thuPmFrom;
  @JsonKey(name: 'thu_pm_to')
  final String? thuPmTo;
  @JsonKey(name: 'tue_am_from')
  final String? tueAmFrom;
  @JsonKey(name: 'tue_am_to')
  final String? tueAmTo;
  @JsonKey(name: 'tue_pm_from')
  final String? tuePmFrom;
  @JsonKey(name: 'tue_pm_to')
  final String? tuePmTo;
  @JsonKey(name: 'wed_am_from')
  final String? wedAmFrom;
  @JsonKey(name: 'wed_am_to')
  final String? wedAmTo;
  @JsonKey(name: 'wed_pm_from')
  final String? wedPmFrom;
  @JsonKey(name: 'wed_pm_To')
  final String? wedPmTo;
  static const fromJsonFactory = _$V3StopStaffingFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopStaffing &&
            (identical(other.friAmFrom, friAmFrom) ||
                const DeepCollectionEquality().equals(
                  other.friAmFrom,
                  friAmFrom,
                )) &&
            (identical(other.friAmTo, friAmTo) ||
                const DeepCollectionEquality().equals(
                  other.friAmTo,
                  friAmTo,
                )) &&
            (identical(other.friPmFrom, friPmFrom) ||
                const DeepCollectionEquality().equals(
                  other.friPmFrom,
                  friPmFrom,
                )) &&
            (identical(other.friPmTo, friPmTo) ||
                const DeepCollectionEquality().equals(
                  other.friPmTo,
                  friPmTo,
                )) &&
            (identical(other.monAmFrom, monAmFrom) ||
                const DeepCollectionEquality().equals(
                  other.monAmFrom,
                  monAmFrom,
                )) &&
            (identical(other.monAmTo, monAmTo) ||
                const DeepCollectionEquality().equals(
                  other.monAmTo,
                  monAmTo,
                )) &&
            (identical(other.monPmFrom, monPmFrom) ||
                const DeepCollectionEquality().equals(
                  other.monPmFrom,
                  monPmFrom,
                )) &&
            (identical(other.monPmTo, monPmTo) ||
                const DeepCollectionEquality().equals(
                  other.monPmTo,
                  monPmTo,
                )) &&
            (identical(other.phAdditionalText, phAdditionalText) ||
                const DeepCollectionEquality().equals(
                  other.phAdditionalText,
                  phAdditionalText,
                )) &&
            (identical(other.phFrom, phFrom) ||
                const DeepCollectionEquality().equals(other.phFrom, phFrom)) &&
            (identical(other.phTo, phTo) ||
                const DeepCollectionEquality().equals(other.phTo, phTo)) &&
            (identical(other.satAmFrom, satAmFrom) ||
                const DeepCollectionEquality().equals(
                  other.satAmFrom,
                  satAmFrom,
                )) &&
            (identical(other.satAmTo, satAmTo) ||
                const DeepCollectionEquality().equals(
                  other.satAmTo,
                  satAmTo,
                )) &&
            (identical(other.satPmFrom, satPmFrom) ||
                const DeepCollectionEquality().equals(
                  other.satPmFrom,
                  satPmFrom,
                )) &&
            (identical(other.satPmTo, satPmTo) ||
                const DeepCollectionEquality().equals(
                  other.satPmTo,
                  satPmTo,
                )) &&
            (identical(other.sunAmFrom, sunAmFrom) ||
                const DeepCollectionEquality().equals(
                  other.sunAmFrom,
                  sunAmFrom,
                )) &&
            (identical(other.sunAmTo, sunAmTo) ||
                const DeepCollectionEquality().equals(
                  other.sunAmTo,
                  sunAmTo,
                )) &&
            (identical(other.sunPmFrom, sunPmFrom) ||
                const DeepCollectionEquality().equals(
                  other.sunPmFrom,
                  sunPmFrom,
                )) &&
            (identical(other.sunPmTo, sunPmTo) ||
                const DeepCollectionEquality().equals(
                  other.sunPmTo,
                  sunPmTo,
                )) &&
            (identical(other.thuAmFrom, thuAmFrom) ||
                const DeepCollectionEquality().equals(
                  other.thuAmFrom,
                  thuAmFrom,
                )) &&
            (identical(other.thuAmTo, thuAmTo) ||
                const DeepCollectionEquality().equals(
                  other.thuAmTo,
                  thuAmTo,
                )) &&
            (identical(other.thuPmFrom, thuPmFrom) ||
                const DeepCollectionEquality().equals(
                  other.thuPmFrom,
                  thuPmFrom,
                )) &&
            (identical(other.thuPmTo, thuPmTo) ||
                const DeepCollectionEquality().equals(
                  other.thuPmTo,
                  thuPmTo,
                )) &&
            (identical(other.tueAmFrom, tueAmFrom) ||
                const DeepCollectionEquality().equals(
                  other.tueAmFrom,
                  tueAmFrom,
                )) &&
            (identical(other.tueAmTo, tueAmTo) ||
                const DeepCollectionEquality().equals(
                  other.tueAmTo,
                  tueAmTo,
                )) &&
            (identical(other.tuePmFrom, tuePmFrom) ||
                const DeepCollectionEquality().equals(
                  other.tuePmFrom,
                  tuePmFrom,
                )) &&
            (identical(other.tuePmTo, tuePmTo) ||
                const DeepCollectionEquality().equals(
                  other.tuePmTo,
                  tuePmTo,
                )) &&
            (identical(other.wedAmFrom, wedAmFrom) ||
                const DeepCollectionEquality().equals(
                  other.wedAmFrom,
                  wedAmFrom,
                )) &&
            (identical(other.wedAmTo, wedAmTo) ||
                const DeepCollectionEquality().equals(
                  other.wedAmTo,
                  wedAmTo,
                )) &&
            (identical(other.wedPmFrom, wedPmFrom) ||
                const DeepCollectionEquality().equals(
                  other.wedPmFrom,
                  wedPmFrom,
                )) &&
            (identical(other.wedPmTo, wedPmTo) ||
                const DeepCollectionEquality().equals(other.wedPmTo, wedPmTo)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(friAmFrom) ^
      const DeepCollectionEquality().hash(friAmTo) ^
      const DeepCollectionEquality().hash(friPmFrom) ^
      const DeepCollectionEquality().hash(friPmTo) ^
      const DeepCollectionEquality().hash(monAmFrom) ^
      const DeepCollectionEquality().hash(monAmTo) ^
      const DeepCollectionEquality().hash(monPmFrom) ^
      const DeepCollectionEquality().hash(monPmTo) ^
      const DeepCollectionEquality().hash(phAdditionalText) ^
      const DeepCollectionEquality().hash(phFrom) ^
      const DeepCollectionEquality().hash(phTo) ^
      const DeepCollectionEquality().hash(satAmFrom) ^
      const DeepCollectionEquality().hash(satAmTo) ^
      const DeepCollectionEquality().hash(satPmFrom) ^
      const DeepCollectionEquality().hash(satPmTo) ^
      const DeepCollectionEquality().hash(sunAmFrom) ^
      const DeepCollectionEquality().hash(sunAmTo) ^
      const DeepCollectionEquality().hash(sunPmFrom) ^
      const DeepCollectionEquality().hash(sunPmTo) ^
      const DeepCollectionEquality().hash(thuAmFrom) ^
      const DeepCollectionEquality().hash(thuAmTo) ^
      const DeepCollectionEquality().hash(thuPmFrom) ^
      const DeepCollectionEquality().hash(thuPmTo) ^
      const DeepCollectionEquality().hash(tueAmFrom) ^
      const DeepCollectionEquality().hash(tueAmTo) ^
      const DeepCollectionEquality().hash(tuePmFrom) ^
      const DeepCollectionEquality().hash(tuePmTo) ^
      const DeepCollectionEquality().hash(wedAmFrom) ^
      const DeepCollectionEquality().hash(wedAmTo) ^
      const DeepCollectionEquality().hash(wedPmFrom) ^
      const DeepCollectionEquality().hash(wedPmTo) ^
      runtimeType.hashCode;
}

extension $V3StopStaffingExtension on V3StopStaffing {
  V3StopStaffing copyWith({
    String? friAmFrom,
    String? friAmTo,
    String? friPmFrom,
    String? friPmTo,
    String? monAmFrom,
    String? monAmTo,
    String? monPmFrom,
    String? monPmTo,
    String? phAdditionalText,
    String? phFrom,
    String? phTo,
    String? satAmFrom,
    String? satAmTo,
    String? satPmFrom,
    String? satPmTo,
    String? sunAmFrom,
    String? sunAmTo,
    String? sunPmFrom,
    String? sunPmTo,
    String? thuAmFrom,
    String? thuAmTo,
    String? thuPmFrom,
    String? thuPmTo,
    String? tueAmFrom,
    String? tueAmTo,
    String? tuePmFrom,
    String? tuePmTo,
    String? wedAmFrom,
    String? wedAmTo,
    String? wedPmFrom,
    String? wedPmTo,
  }) {
    return V3StopStaffing(
      friAmFrom: friAmFrom ?? this.friAmFrom,
      friAmTo: friAmTo ?? this.friAmTo,
      friPmFrom: friPmFrom ?? this.friPmFrom,
      friPmTo: friPmTo ?? this.friPmTo,
      monAmFrom: monAmFrom ?? this.monAmFrom,
      monAmTo: monAmTo ?? this.monAmTo,
      monPmFrom: monPmFrom ?? this.monPmFrom,
      monPmTo: monPmTo ?? this.monPmTo,
      phAdditionalText: phAdditionalText ?? this.phAdditionalText,
      phFrom: phFrom ?? this.phFrom,
      phTo: phTo ?? this.phTo,
      satAmFrom: satAmFrom ?? this.satAmFrom,
      satAmTo: satAmTo ?? this.satAmTo,
      satPmFrom: satPmFrom ?? this.satPmFrom,
      satPmTo: satPmTo ?? this.satPmTo,
      sunAmFrom: sunAmFrom ?? this.sunAmFrom,
      sunAmTo: sunAmTo ?? this.sunAmTo,
      sunPmFrom: sunPmFrom ?? this.sunPmFrom,
      sunPmTo: sunPmTo ?? this.sunPmTo,
      thuAmFrom: thuAmFrom ?? this.thuAmFrom,
      thuAmTo: thuAmTo ?? this.thuAmTo,
      thuPmFrom: thuPmFrom ?? this.thuPmFrom,
      thuPmTo: thuPmTo ?? this.thuPmTo,
      tueAmFrom: tueAmFrom ?? this.tueAmFrom,
      tueAmTo: tueAmTo ?? this.tueAmTo,
      tuePmFrom: tuePmFrom ?? this.tuePmFrom,
      tuePmTo: tuePmTo ?? this.tuePmTo,
      wedAmFrom: wedAmFrom ?? this.wedAmFrom,
      wedAmTo: wedAmTo ?? this.wedAmTo,
      wedPmFrom: wedPmFrom ?? this.wedPmFrom,
      wedPmTo: wedPmTo ?? this.wedPmTo,
    );
  }

  V3StopStaffing copyWithWrapped({
    Wrapped<String?>? friAmFrom,
    Wrapped<String?>? friAmTo,
    Wrapped<String?>? friPmFrom,
    Wrapped<String?>? friPmTo,
    Wrapped<String?>? monAmFrom,
    Wrapped<String?>? monAmTo,
    Wrapped<String?>? monPmFrom,
    Wrapped<String?>? monPmTo,
    Wrapped<String?>? phAdditionalText,
    Wrapped<String?>? phFrom,
    Wrapped<String?>? phTo,
    Wrapped<String?>? satAmFrom,
    Wrapped<String?>? satAmTo,
    Wrapped<String?>? satPmFrom,
    Wrapped<String?>? satPmTo,
    Wrapped<String?>? sunAmFrom,
    Wrapped<String?>? sunAmTo,
    Wrapped<String?>? sunPmFrom,
    Wrapped<String?>? sunPmTo,
    Wrapped<String?>? thuAmFrom,
    Wrapped<String?>? thuAmTo,
    Wrapped<String?>? thuPmFrom,
    Wrapped<String?>? thuPmTo,
    Wrapped<String?>? tueAmFrom,
    Wrapped<String?>? tueAmTo,
    Wrapped<String?>? tuePmFrom,
    Wrapped<String?>? tuePmTo,
    Wrapped<String?>? wedAmFrom,
    Wrapped<String?>? wedAmTo,
    Wrapped<String?>? wedPmFrom,
    Wrapped<String?>? wedPmTo,
  }) {
    return V3StopStaffing(
      friAmFrom: (friAmFrom != null ? friAmFrom.value : this.friAmFrom),
      friAmTo: (friAmTo != null ? friAmTo.value : this.friAmTo),
      friPmFrom: (friPmFrom != null ? friPmFrom.value : this.friPmFrom),
      friPmTo: (friPmTo != null ? friPmTo.value : this.friPmTo),
      monAmFrom: (monAmFrom != null ? monAmFrom.value : this.monAmFrom),
      monAmTo: (monAmTo != null ? monAmTo.value : this.monAmTo),
      monPmFrom: (monPmFrom != null ? monPmFrom.value : this.monPmFrom),
      monPmTo: (monPmTo != null ? monPmTo.value : this.monPmTo),
      phAdditionalText: (phAdditionalText != null
          ? phAdditionalText.value
          : this.phAdditionalText),
      phFrom: (phFrom != null ? phFrom.value : this.phFrom),
      phTo: (phTo != null ? phTo.value : this.phTo),
      satAmFrom: (satAmFrom != null ? satAmFrom.value : this.satAmFrom),
      satAmTo: (satAmTo != null ? satAmTo.value : this.satAmTo),
      satPmFrom: (satPmFrom != null ? satPmFrom.value : this.satPmFrom),
      satPmTo: (satPmTo != null ? satPmTo.value : this.satPmTo),
      sunAmFrom: (sunAmFrom != null ? sunAmFrom.value : this.sunAmFrom),
      sunAmTo: (sunAmTo != null ? sunAmTo.value : this.sunAmTo),
      sunPmFrom: (sunPmFrom != null ? sunPmFrom.value : this.sunPmFrom),
      sunPmTo: (sunPmTo != null ? sunPmTo.value : this.sunPmTo),
      thuAmFrom: (thuAmFrom != null ? thuAmFrom.value : this.thuAmFrom),
      thuAmTo: (thuAmTo != null ? thuAmTo.value : this.thuAmTo),
      thuPmFrom: (thuPmFrom != null ? thuPmFrom.value : this.thuPmFrom),
      thuPmTo: (thuPmTo != null ? thuPmTo.value : this.thuPmTo),
      tueAmFrom: (tueAmFrom != null ? tueAmFrom.value : this.tueAmFrom),
      tueAmTo: (tueAmTo != null ? tueAmTo.value : this.tueAmTo),
      tuePmFrom: (tuePmFrom != null ? tuePmFrom.value : this.tuePmFrom),
      tuePmTo: (tuePmTo != null ? tuePmTo.value : this.tuePmTo),
      wedAmFrom: (wedAmFrom != null ? wedAmFrom.value : this.wedAmFrom),
      wedAmTo: (wedAmTo != null ? wedAmTo.value : this.wedAmTo),
      wedPmFrom: (wedPmFrom != null ? wedPmFrom.value : this.wedPmFrom),
      wedPmTo: (wedPmTo != null ? wedPmTo.value : this.wedPmTo),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopGps {
  const V3StopGps({this.latitude, this.longitude});

  factory V3StopGps.fromJson(Map<String, dynamic> json) =>
      _$V3StopGpsFromJson(json);

  static const toJsonFactory = _$V3StopGpsToJson;
  Map<String, dynamic> toJson() => _$V3StopGpsToJson(this);

  @JsonKey(name: 'latitude')
  final double? latitude;
  @JsonKey(name: 'longitude')
  final double? longitude;
  static const fromJsonFactory = _$V3StopGpsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopGps &&
            (identical(other.latitude, latitude) ||
                const DeepCollectionEquality().equals(
                  other.latitude,
                  latitude,
                )) &&
            (identical(other.longitude, longitude) ||
                const DeepCollectionEquality().equals(
                  other.longitude,
                  longitude,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(latitude) ^
      const DeepCollectionEquality().hash(longitude) ^
      runtimeType.hashCode;
}

extension $V3StopGpsExtension on V3StopGps {
  V3StopGps copyWith({double? latitude, double? longitude}) {
    return V3StopGps(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  V3StopGps copyWithWrapped({
    Wrapped<double?>? latitude,
    Wrapped<double?>? longitude,
  }) {
    return V3StopGps(
      latitude: (latitude != null ? latitude.value : this.latitude),
      longitude: (longitude != null ? longitude.value : this.longitude),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopAccessibilityWheelchair {
  const V3StopAccessibilityWheelchair({
    this.accessibleRamp,
    this.parking,
    this.telephone,
    this.toilet,
    this.lowTicketCounter,
    this.manouvering,
    this.raisedPlatform,
    this.ramp,
    this.secondaryPath,
    this.raisedPlatformShelther,
    this.steepRamp,
  });

  factory V3StopAccessibilityWheelchair.fromJson(Map<String, dynamic> json) =>
      _$V3StopAccessibilityWheelchairFromJson(json);

  static const toJsonFactory = _$V3StopAccessibilityWheelchairToJson;
  Map<String, dynamic> toJson() => _$V3StopAccessibilityWheelchairToJson(this);

  @JsonKey(name: 'accessible_ramp')
  final bool? accessibleRamp;
  @JsonKey(name: 'parking')
  final bool? parking;
  @JsonKey(name: 'telephone')
  final bool? telephone;
  @JsonKey(name: 'toilet')
  final bool? toilet;
  @JsonKey(name: 'low_ticket_counter')
  final bool? lowTicketCounter;
  @JsonKey(name: 'manouvering')
  final bool? manouvering;
  @JsonKey(name: 'raised_platform')
  final bool? raisedPlatform;
  @JsonKey(name: 'ramp')
  final bool? ramp;
  @JsonKey(name: 'secondary_path')
  final bool? secondaryPath;
  @JsonKey(name: 'raised_platform_shelther')
  final bool? raisedPlatformShelther;
  @JsonKey(name: 'steep_ramp')
  final bool? steepRamp;
  static const fromJsonFactory = _$V3StopAccessibilityWheelchairFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopAccessibilityWheelchair &&
            (identical(other.accessibleRamp, accessibleRamp) ||
                const DeepCollectionEquality().equals(
                  other.accessibleRamp,
                  accessibleRamp,
                )) &&
            (identical(other.parking, parking) ||
                const DeepCollectionEquality().equals(
                  other.parking,
                  parking,
                )) &&
            (identical(other.telephone, telephone) ||
                const DeepCollectionEquality().equals(
                  other.telephone,
                  telephone,
                )) &&
            (identical(other.toilet, toilet) ||
                const DeepCollectionEquality().equals(other.toilet, toilet)) &&
            (identical(other.lowTicketCounter, lowTicketCounter) ||
                const DeepCollectionEquality().equals(
                  other.lowTicketCounter,
                  lowTicketCounter,
                )) &&
            (identical(other.manouvering, manouvering) ||
                const DeepCollectionEquality().equals(
                  other.manouvering,
                  manouvering,
                )) &&
            (identical(other.raisedPlatform, raisedPlatform) ||
                const DeepCollectionEquality().equals(
                  other.raisedPlatform,
                  raisedPlatform,
                )) &&
            (identical(other.ramp, ramp) ||
                const DeepCollectionEquality().equals(other.ramp, ramp)) &&
            (identical(other.secondaryPath, secondaryPath) ||
                const DeepCollectionEquality().equals(
                  other.secondaryPath,
                  secondaryPath,
                )) &&
            (identical(other.raisedPlatformShelther, raisedPlatformShelther) ||
                const DeepCollectionEquality().equals(
                  other.raisedPlatformShelther,
                  raisedPlatformShelther,
                )) &&
            (identical(other.steepRamp, steepRamp) ||
                const DeepCollectionEquality().equals(
                  other.steepRamp,
                  steepRamp,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accessibleRamp) ^
      const DeepCollectionEquality().hash(parking) ^
      const DeepCollectionEquality().hash(telephone) ^
      const DeepCollectionEquality().hash(toilet) ^
      const DeepCollectionEquality().hash(lowTicketCounter) ^
      const DeepCollectionEquality().hash(manouvering) ^
      const DeepCollectionEquality().hash(raisedPlatform) ^
      const DeepCollectionEquality().hash(ramp) ^
      const DeepCollectionEquality().hash(secondaryPath) ^
      const DeepCollectionEquality().hash(raisedPlatformShelther) ^
      const DeepCollectionEquality().hash(steepRamp) ^
      runtimeType.hashCode;
}

extension $V3StopAccessibilityWheelchairExtension
    on V3StopAccessibilityWheelchair {
  V3StopAccessibilityWheelchair copyWith({
    bool? accessibleRamp,
    bool? parking,
    bool? telephone,
    bool? toilet,
    bool? lowTicketCounter,
    bool? manouvering,
    bool? raisedPlatform,
    bool? ramp,
    bool? secondaryPath,
    bool? raisedPlatformShelther,
    bool? steepRamp,
  }) {
    return V3StopAccessibilityWheelchair(
      accessibleRamp: accessibleRamp ?? this.accessibleRamp,
      parking: parking ?? this.parking,
      telephone: telephone ?? this.telephone,
      toilet: toilet ?? this.toilet,
      lowTicketCounter: lowTicketCounter ?? this.lowTicketCounter,
      manouvering: manouvering ?? this.manouvering,
      raisedPlatform: raisedPlatform ?? this.raisedPlatform,
      ramp: ramp ?? this.ramp,
      secondaryPath: secondaryPath ?? this.secondaryPath,
      raisedPlatformShelther:
          raisedPlatformShelther ?? this.raisedPlatformShelther,
      steepRamp: steepRamp ?? this.steepRamp,
    );
  }

  V3StopAccessibilityWheelchair copyWithWrapped({
    Wrapped<bool?>? accessibleRamp,
    Wrapped<bool?>? parking,
    Wrapped<bool?>? telephone,
    Wrapped<bool?>? toilet,
    Wrapped<bool?>? lowTicketCounter,
    Wrapped<bool?>? manouvering,
    Wrapped<bool?>? raisedPlatform,
    Wrapped<bool?>? ramp,
    Wrapped<bool?>? secondaryPath,
    Wrapped<bool?>? raisedPlatformShelther,
    Wrapped<bool?>? steepRamp,
  }) {
    return V3StopAccessibilityWheelchair(
      accessibleRamp: (accessibleRamp != null
          ? accessibleRamp.value
          : this.accessibleRamp),
      parking: (parking != null ? parking.value : this.parking),
      telephone: (telephone != null ? telephone.value : this.telephone),
      toilet: (toilet != null ? toilet.value : this.toilet),
      lowTicketCounter: (lowTicketCounter != null
          ? lowTicketCounter.value
          : this.lowTicketCounter),
      manouvering: (manouvering != null ? manouvering.value : this.manouvering),
      raisedPlatform: (raisedPlatform != null
          ? raisedPlatform.value
          : this.raisedPlatform),
      ramp: (ramp != null ? ramp.value : this.ramp),
      secondaryPath: (secondaryPath != null
          ? secondaryPath.value
          : this.secondaryPath),
      raisedPlatformShelther: (raisedPlatformShelther != null
          ? raisedPlatformShelther.value
          : this.raisedPlatformShelther),
      steepRamp: (steepRamp != null ? steepRamp.value : this.steepRamp),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopsByRouteIdParameters {
  const V3StopsByRouteIdParameters({
    this.directionId,
    this.stopDisruptions,
    this.includeGeopath,
    this.geopathUtc,
    this.includeAdvertisedInterchange,
  });

  factory V3StopsByRouteIdParameters.fromJson(Map<String, dynamic> json) =>
      _$V3StopsByRouteIdParametersFromJson(json);

  static const toJsonFactory = _$V3StopsByRouteIdParametersToJson;
  Map<String, dynamic> toJson() => _$V3StopsByRouteIdParametersToJson(this);

  @JsonKey(name: 'direction_id')
  final int? directionId;
  @JsonKey(name: 'stop_disruptions')
  final bool? stopDisruptions;
  @JsonKey(name: 'include_geopath')
  final bool? includeGeopath;
  @JsonKey(name: 'geopath_utc')
  final DateTime? geopathUtc;
  @JsonKey(name: 'include_advertised_interchange')
  final bool? includeAdvertisedInterchange;
  static const fromJsonFactory = _$V3StopsByRouteIdParametersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopsByRouteIdParameters &&
            (identical(other.directionId, directionId) ||
                const DeepCollectionEquality().equals(
                  other.directionId,
                  directionId,
                )) &&
            (identical(other.stopDisruptions, stopDisruptions) ||
                const DeepCollectionEquality().equals(
                  other.stopDisruptions,
                  stopDisruptions,
                )) &&
            (identical(other.includeGeopath, includeGeopath) ||
                const DeepCollectionEquality().equals(
                  other.includeGeopath,
                  includeGeopath,
                )) &&
            (identical(other.geopathUtc, geopathUtc) ||
                const DeepCollectionEquality().equals(
                  other.geopathUtc,
                  geopathUtc,
                )) &&
            (identical(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                ) ||
                const DeepCollectionEquality().equals(
                  other.includeAdvertisedInterchange,
                  includeAdvertisedInterchange,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(directionId) ^
      const DeepCollectionEquality().hash(stopDisruptions) ^
      const DeepCollectionEquality().hash(includeGeopath) ^
      const DeepCollectionEquality().hash(geopathUtc) ^
      const DeepCollectionEquality().hash(includeAdvertisedInterchange) ^
      runtimeType.hashCode;
}

extension $V3StopsByRouteIdParametersExtension on V3StopsByRouteIdParameters {
  V3StopsByRouteIdParameters copyWith({
    int? directionId,
    bool? stopDisruptions,
    bool? includeGeopath,
    DateTime? geopathUtc,
    bool? includeAdvertisedInterchange,
  }) {
    return V3StopsByRouteIdParameters(
      directionId: directionId ?? this.directionId,
      stopDisruptions: stopDisruptions ?? this.stopDisruptions,
      includeGeopath: includeGeopath ?? this.includeGeopath,
      geopathUtc: geopathUtc ?? this.geopathUtc,
      includeAdvertisedInterchange:
          includeAdvertisedInterchange ?? this.includeAdvertisedInterchange,
    );
  }

  V3StopsByRouteIdParameters copyWithWrapped({
    Wrapped<int?>? directionId,
    Wrapped<bool?>? stopDisruptions,
    Wrapped<bool?>? includeGeopath,
    Wrapped<DateTime?>? geopathUtc,
    Wrapped<bool?>? includeAdvertisedInterchange,
  }) {
    return V3StopsByRouteIdParameters(
      directionId: (directionId != null ? directionId.value : this.directionId),
      stopDisruptions: (stopDisruptions != null
          ? stopDisruptions.value
          : this.stopDisruptions),
      includeGeopath: (includeGeopath != null
          ? includeGeopath.value
          : this.includeGeopath),
      geopathUtc: (geopathUtc != null ? geopathUtc.value : this.geopathUtc),
      includeAdvertisedInterchange: (includeAdvertisedInterchange != null
          ? includeAdvertisedInterchange.value
          : this.includeAdvertisedInterchange),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopsOnRouteResponse {
  const V3StopsOnRouteResponse({
    this.stops,
    this.disruptions,
    this.geopath,
    this.status,
  });

  factory V3StopsOnRouteResponse.fromJson(Map<String, dynamic> json) =>
      _$V3StopsOnRouteResponseFromJson(json);

  static const toJsonFactory = _$V3StopsOnRouteResponseToJson;
  Map<String, dynamic> toJson() => _$V3StopsOnRouteResponseToJson(this);

  @JsonKey(name: 'stops', defaultValue: <V3StopOnRoute>[])
  final List<V3StopOnRoute>? stops;
  @JsonKey(name: 'disruptions')
  final Map<String, dynamic>? disruptions;
  @JsonKey(name: 'geopath', defaultValue: <Object>[])
  final List<Object>? geopath;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3StopsOnRouteResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopsOnRouteResponse &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)) &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.geopath, geopath) ||
                const DeepCollectionEquality().equals(
                  other.geopath,
                  geopath,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stops) ^
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(geopath) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3StopsOnRouteResponseExtension on V3StopsOnRouteResponse {
  V3StopsOnRouteResponse copyWith({
    List<V3StopOnRoute>? stops,
    Map<String, dynamic>? disruptions,
    List<Object>? geopath,
    V3Status? status,
  }) {
    return V3StopsOnRouteResponse(
      stops: stops ?? this.stops,
      disruptions: disruptions ?? this.disruptions,
      geopath: geopath ?? this.geopath,
      status: status ?? this.status,
    );
  }

  V3StopsOnRouteResponse copyWithWrapped({
    Wrapped<List<V3StopOnRoute>?>? stops,
    Wrapped<Map<String, dynamic>?>? disruptions,
    Wrapped<List<Object>?>? geopath,
    Wrapped<V3Status?>? status,
  }) {
    return V3StopsOnRouteResponse(
      stops: (stops != null ? stops.value : this.stops),
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      geopath: (geopath != null ? geopath.value : this.geopath),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopOnRoute {
  const V3StopOnRoute({
    this.disruptionIds,
    this.stopSuburb,
    this.routeType,
    this.stopLatitude,
    this.stopLongitude,
    this.stopSequence,
    this.stopTicket,
    this.interchange,
    this.stopId,
    this.stopName,
    this.stopLandmark,
  });

  factory V3StopOnRoute.fromJson(Map<String, dynamic> json) =>
      _$V3StopOnRouteFromJson(json);

  static const toJsonFactory = _$V3StopOnRouteToJson;
  Map<String, dynamic> toJson() => _$V3StopOnRouteToJson(this);

  @JsonKey(name: 'disruption_ids', defaultValue: <int>[])
  final List<int>? disruptionIds;
  @JsonKey(name: 'stop_suburb')
  final String? stopSuburb;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'stop_latitude')
  final double? stopLatitude;
  @JsonKey(name: 'stop_longitude')
  final double? stopLongitude;
  @JsonKey(name: 'stop_sequence')
  final int? stopSequence;
  @JsonKey(name: 'stop_ticket')
  final V3StopTicket? stopTicket;
  @JsonKey(name: 'interchange', defaultValue: <V3InterchangeRoute>[])
  final List<V3InterchangeRoute>? interchange;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  @JsonKey(name: 'stop_landmark')
  final String? stopLandmark;
  static const fromJsonFactory = _$V3StopOnRouteFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopOnRoute &&
            (identical(other.disruptionIds, disruptionIds) ||
                const DeepCollectionEquality().equals(
                  other.disruptionIds,
                  disruptionIds,
                )) &&
            (identical(other.stopSuburb, stopSuburb) ||
                const DeepCollectionEquality().equals(
                  other.stopSuburb,
                  stopSuburb,
                )) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.stopLatitude, stopLatitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLatitude,
                  stopLatitude,
                )) &&
            (identical(other.stopLongitude, stopLongitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLongitude,
                  stopLongitude,
                )) &&
            (identical(other.stopSequence, stopSequence) ||
                const DeepCollectionEquality().equals(
                  other.stopSequence,
                  stopSequence,
                )) &&
            (identical(other.stopTicket, stopTicket) ||
                const DeepCollectionEquality().equals(
                  other.stopTicket,
                  stopTicket,
                )) &&
            (identical(other.interchange, interchange) ||
                const DeepCollectionEquality().equals(
                  other.interchange,
                  interchange,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )) &&
            (identical(other.stopLandmark, stopLandmark) ||
                const DeepCollectionEquality().equals(
                  other.stopLandmark,
                  stopLandmark,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptionIds) ^
      const DeepCollectionEquality().hash(stopSuburb) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(stopLatitude) ^
      const DeepCollectionEquality().hash(stopLongitude) ^
      const DeepCollectionEquality().hash(stopSequence) ^
      const DeepCollectionEquality().hash(stopTicket) ^
      const DeepCollectionEquality().hash(interchange) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(stopName) ^
      const DeepCollectionEquality().hash(stopLandmark) ^
      runtimeType.hashCode;
}

extension $V3StopOnRouteExtension on V3StopOnRoute {
  V3StopOnRoute copyWith({
    List<int>? disruptionIds,
    String? stopSuburb,
    int? routeType,
    double? stopLatitude,
    double? stopLongitude,
    int? stopSequence,
    V3StopTicket? stopTicket,
    List<V3InterchangeRoute>? interchange,
    int? stopId,
    String? stopName,
    String? stopLandmark,
  }) {
    return V3StopOnRoute(
      disruptionIds: disruptionIds ?? this.disruptionIds,
      stopSuburb: stopSuburb ?? this.stopSuburb,
      routeType: routeType ?? this.routeType,
      stopLatitude: stopLatitude ?? this.stopLatitude,
      stopLongitude: stopLongitude ?? this.stopLongitude,
      stopSequence: stopSequence ?? this.stopSequence,
      stopTicket: stopTicket ?? this.stopTicket,
      interchange: interchange ?? this.interchange,
      stopId: stopId ?? this.stopId,
      stopName: stopName ?? this.stopName,
      stopLandmark: stopLandmark ?? this.stopLandmark,
    );
  }

  V3StopOnRoute copyWithWrapped({
    Wrapped<List<int>?>? disruptionIds,
    Wrapped<String?>? stopSuburb,
    Wrapped<int?>? routeType,
    Wrapped<double?>? stopLatitude,
    Wrapped<double?>? stopLongitude,
    Wrapped<int?>? stopSequence,
    Wrapped<V3StopTicket?>? stopTicket,
    Wrapped<List<V3InterchangeRoute>?>? interchange,
    Wrapped<int?>? stopId,
    Wrapped<String?>? stopName,
    Wrapped<String?>? stopLandmark,
  }) {
    return V3StopOnRoute(
      disruptionIds: (disruptionIds != null
          ? disruptionIds.value
          : this.disruptionIds),
      stopSuburb: (stopSuburb != null ? stopSuburb.value : this.stopSuburb),
      routeType: (routeType != null ? routeType.value : this.routeType),
      stopLatitude: (stopLatitude != null
          ? stopLatitude.value
          : this.stopLatitude),
      stopLongitude: (stopLongitude != null
          ? stopLongitude.value
          : this.stopLongitude),
      stopSequence: (stopSequence != null
          ? stopSequence.value
          : this.stopSequence),
      stopTicket: (stopTicket != null ? stopTicket.value : this.stopTicket),
      interchange: (interchange != null ? interchange.value : this.interchange),
      stopId: (stopId != null ? stopId.value : this.stopId),
      stopName: (stopName != null ? stopName.value : this.stopName),
      stopLandmark: (stopLandmark != null
          ? stopLandmark.value
          : this.stopLandmark),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3InterchangeRoute {
  const V3InterchangeRoute({this.routeId, this.advertised});

  factory V3InterchangeRoute.fromJson(Map<String, dynamic> json) =>
      _$V3InterchangeRouteFromJson(json);

  static const toJsonFactory = _$V3InterchangeRouteToJson;
  Map<String, dynamic> toJson() => _$V3InterchangeRouteToJson(this);

  @JsonKey(name: 'route_id')
  final int? routeId;
  @JsonKey(name: 'advertised')
  final bool? advertised;
  static const fromJsonFactory = _$V3InterchangeRouteFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3InterchangeRoute &&
            (identical(other.routeId, routeId) ||
                const DeepCollectionEquality().equals(
                  other.routeId,
                  routeId,
                )) &&
            (identical(other.advertised, advertised) ||
                const DeepCollectionEquality().equals(
                  other.advertised,
                  advertised,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(routeId) ^
      const DeepCollectionEquality().hash(advertised) ^
      runtimeType.hashCode;
}

extension $V3InterchangeRouteExtension on V3InterchangeRoute {
  V3InterchangeRoute copyWith({int? routeId, bool? advertised}) {
    return V3InterchangeRoute(
      routeId: routeId ?? this.routeId,
      advertised: advertised ?? this.advertised,
    );
  }

  V3InterchangeRoute copyWithWrapped({
    Wrapped<int?>? routeId,
    Wrapped<bool?>? advertised,
  }) {
    return V3InterchangeRoute(
      routeId: (routeId != null ? routeId.value : this.routeId),
      advertised: (advertised != null ? advertised.value : this.advertised),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopsByDistanceResponse {
  const V3StopsByDistanceResponse({this.stops, this.disruptions, this.status});

  factory V3StopsByDistanceResponse.fromJson(Map<String, dynamic> json) =>
      _$V3StopsByDistanceResponseFromJson(json);

  static const toJsonFactory = _$V3StopsByDistanceResponseToJson;
  Map<String, dynamic> toJson() => _$V3StopsByDistanceResponseToJson(this);

  @JsonKey(name: 'stops', defaultValue: <V3StopGeosearch>[])
  final List<V3StopGeosearch>? stops;
  @JsonKey(name: 'disruptions')
  final Map<String, dynamic>? disruptions;
  @JsonKey(name: 'status')
  final V3Status? status;
  static const fromJsonFactory = _$V3StopsByDistanceResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopsByDistanceResponse &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)) &&
            (identical(other.disruptions, disruptions) ||
                const DeepCollectionEquality().equals(
                  other.disruptions,
                  disruptions,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(stops) ^
      const DeepCollectionEquality().hash(disruptions) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $V3StopsByDistanceResponseExtension on V3StopsByDistanceResponse {
  V3StopsByDistanceResponse copyWith({
    List<V3StopGeosearch>? stops,
    Map<String, dynamic>? disruptions,
    V3Status? status,
  }) {
    return V3StopsByDistanceResponse(
      stops: stops ?? this.stops,
      disruptions: disruptions ?? this.disruptions,
      status: status ?? this.status,
    );
  }

  V3StopsByDistanceResponse copyWithWrapped({
    Wrapped<List<V3StopGeosearch>?>? stops,
    Wrapped<Map<String, dynamic>?>? disruptions,
    Wrapped<V3Status?>? status,
  }) {
    return V3StopsByDistanceResponse(
      stops: (stops != null ? stops.value : this.stops),
      disruptions: (disruptions != null ? disruptions.value : this.disruptions),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V3StopGeosearch {
  const V3StopGeosearch({
    this.disruptionIds,
    this.stopDistance,
    this.stopSuburb,
    this.stopName,
    this.stopId,
    this.routeType,
    this.routes,
    this.stopLatitude,
    this.stopLongitude,
    this.stopLandmark,
    this.stopSequence,
  });

  factory V3StopGeosearch.fromJson(Map<String, dynamic> json) =>
      _$V3StopGeosearchFromJson(json);

  static const toJsonFactory = _$V3StopGeosearchToJson;
  Map<String, dynamic> toJson() => _$V3StopGeosearchToJson(this);

  @JsonKey(name: 'disruption_ids', defaultValue: <int>[])
  final List<int>? disruptionIds;
  @JsonKey(name: 'stop_distance')
  final double? stopDistance;
  @JsonKey(name: 'stop_suburb')
  final String? stopSuburb;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  @JsonKey(name: 'stop_id')
  final int? stopId;
  @JsonKey(name: 'route_type')
  final int? routeType;
  @JsonKey(name: 'routes', defaultValue: <Object>[])
  final List<Object>? routes;
  @JsonKey(name: 'stop_latitude')
  final double? stopLatitude;
  @JsonKey(name: 'stop_longitude')
  final double? stopLongitude;
  @JsonKey(name: 'stop_landmark')
  final String? stopLandmark;
  @JsonKey(name: 'stop_sequence')
  final int? stopSequence;
  static const fromJsonFactory = _$V3StopGeosearchFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V3StopGeosearch &&
            (identical(other.disruptionIds, disruptionIds) ||
                const DeepCollectionEquality().equals(
                  other.disruptionIds,
                  disruptionIds,
                )) &&
            (identical(other.stopDistance, stopDistance) ||
                const DeepCollectionEquality().equals(
                  other.stopDistance,
                  stopDistance,
                )) &&
            (identical(other.stopSuburb, stopSuburb) ||
                const DeepCollectionEquality().equals(
                  other.stopSuburb,
                  stopSuburb,
                )) &&
            (identical(other.stopName, stopName) ||
                const DeepCollectionEquality().equals(
                  other.stopName,
                  stopName,
                )) &&
            (identical(other.stopId, stopId) ||
                const DeepCollectionEquality().equals(other.stopId, stopId)) &&
            (identical(other.routeType, routeType) ||
                const DeepCollectionEquality().equals(
                  other.routeType,
                  routeType,
                )) &&
            (identical(other.routes, routes) ||
                const DeepCollectionEquality().equals(other.routes, routes)) &&
            (identical(other.stopLatitude, stopLatitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLatitude,
                  stopLatitude,
                )) &&
            (identical(other.stopLongitude, stopLongitude) ||
                const DeepCollectionEquality().equals(
                  other.stopLongitude,
                  stopLongitude,
                )) &&
            (identical(other.stopLandmark, stopLandmark) ||
                const DeepCollectionEquality().equals(
                  other.stopLandmark,
                  stopLandmark,
                )) &&
            (identical(other.stopSequence, stopSequence) ||
                const DeepCollectionEquality().equals(
                  other.stopSequence,
                  stopSequence,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disruptionIds) ^
      const DeepCollectionEquality().hash(stopDistance) ^
      const DeepCollectionEquality().hash(stopSuburb) ^
      const DeepCollectionEquality().hash(stopName) ^
      const DeepCollectionEquality().hash(stopId) ^
      const DeepCollectionEquality().hash(routeType) ^
      const DeepCollectionEquality().hash(routes) ^
      const DeepCollectionEquality().hash(stopLatitude) ^
      const DeepCollectionEquality().hash(stopLongitude) ^
      const DeepCollectionEquality().hash(stopLandmark) ^
      const DeepCollectionEquality().hash(stopSequence) ^
      runtimeType.hashCode;
}

extension $V3StopGeosearchExtension on V3StopGeosearch {
  V3StopGeosearch copyWith({
    List<int>? disruptionIds,
    double? stopDistance,
    String? stopSuburb,
    String? stopName,
    int? stopId,
    int? routeType,
    List<Object>? routes,
    double? stopLatitude,
    double? stopLongitude,
    String? stopLandmark,
    int? stopSequence,
  }) {
    return V3StopGeosearch(
      disruptionIds: disruptionIds ?? this.disruptionIds,
      stopDistance: stopDistance ?? this.stopDistance,
      stopSuburb: stopSuburb ?? this.stopSuburb,
      stopName: stopName ?? this.stopName,
      stopId: stopId ?? this.stopId,
      routeType: routeType ?? this.routeType,
      routes: routes ?? this.routes,
      stopLatitude: stopLatitude ?? this.stopLatitude,
      stopLongitude: stopLongitude ?? this.stopLongitude,
      stopLandmark: stopLandmark ?? this.stopLandmark,
      stopSequence: stopSequence ?? this.stopSequence,
    );
  }

  V3StopGeosearch copyWithWrapped({
    Wrapped<List<int>?>? disruptionIds,
    Wrapped<double?>? stopDistance,
    Wrapped<String?>? stopSuburb,
    Wrapped<String?>? stopName,
    Wrapped<int?>? stopId,
    Wrapped<int?>? routeType,
    Wrapped<List<Object>?>? routes,
    Wrapped<double?>? stopLatitude,
    Wrapped<double?>? stopLongitude,
    Wrapped<String?>? stopLandmark,
    Wrapped<int?>? stopSequence,
  }) {
    return V3StopGeosearch(
      disruptionIds: (disruptionIds != null
          ? disruptionIds.value
          : this.disruptionIds),
      stopDistance: (stopDistance != null
          ? stopDistance.value
          : this.stopDistance),
      stopSuburb: (stopSuburb != null ? stopSuburb.value : this.stopSuburb),
      stopName: (stopName != null ? stopName.value : this.stopName),
      stopId: (stopId != null ? stopId.value : this.stopId),
      routeType: (routeType != null ? routeType.value : this.routeType),
      routes: (routes != null ? routes.value : this.routes),
      stopLatitude: (stopLatitude != null
          ? stopLatitude.value
          : this.stopLatitude),
      stopLongitude: (stopLongitude != null
          ? stopLongitude.value
          : this.stopLongitude),
      stopLandmark: (stopLandmark != null
          ? stopLandmark.value
          : this.stopLandmark),
      stopSequence: (stopSequence != null
          ? stopSequence.value
          : this.stopSequence),
    );
  }
}

int? v3StatusHealthNullableToJson(enums.V3StatusHealth? v3StatusHealth) {
  return v3StatusHealth?.value;
}

int? v3StatusHealthToJson(enums.V3StatusHealth v3StatusHealth) {
  return v3StatusHealth.value;
}

enums.V3StatusHealth v3StatusHealthFromJson(
  Object? v3StatusHealth, [
  enums.V3StatusHealth? defaultValue,
]) {
  return enums.V3StatusHealth.values.firstWhereOrNull(
        (e) => e.value == v3StatusHealth,
      ) ??
      defaultValue ??
      enums.V3StatusHealth.swaggerGeneratedUnknown;
}

enums.V3StatusHealth? v3StatusHealthNullableFromJson(
  Object? v3StatusHealth, [
  enums.V3StatusHealth? defaultValue,
]) {
  if (v3StatusHealth == null) {
    return null;
  }
  return enums.V3StatusHealth.values.firstWhereOrNull(
        (e) => e.value == v3StatusHealth,
      ) ??
      defaultValue;
}

String v3StatusHealthExplodedListToJson(
  List<enums.V3StatusHealth>? v3StatusHealth,
) {
  return v3StatusHealth?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3StatusHealthListToJson(List<enums.V3StatusHealth>? v3StatusHealth) {
  if (v3StatusHealth == null) {
    return [];
  }

  return v3StatusHealth.map((e) => e.value!).toList();
}

List<enums.V3StatusHealth> v3StatusHealthListFromJson(
  List? v3StatusHealth, [
  List<enums.V3StatusHealth>? defaultValue,
]) {
  if (v3StatusHealth == null) {
    return defaultValue ?? [];
  }

  return v3StatusHealth.map((e) => v3StatusHealthFromJson(e)).toList();
}

List<enums.V3StatusHealth>? v3StatusHealthNullableListFromJson(
  List? v3StatusHealth, [
  List<enums.V3StatusHealth>? defaultValue,
]) {
  if (v3StatusHealth == null) {
    return defaultValue;
  }

  return v3StatusHealth.map((e) => v3StatusHealthFromJson(e)).toList();
}

int? v3DeparturesBroadParametersExpandNullableToJson(
  enums.V3DeparturesBroadParametersExpand? v3DeparturesBroadParametersExpand,
) {
  return v3DeparturesBroadParametersExpand?.value;
}

int? v3DeparturesBroadParametersExpandToJson(
  enums.V3DeparturesBroadParametersExpand v3DeparturesBroadParametersExpand,
) {
  return v3DeparturesBroadParametersExpand.value;
}

enums.V3DeparturesBroadParametersExpand
v3DeparturesBroadParametersExpandFromJson(
  Object? v3DeparturesBroadParametersExpand, [
  enums.V3DeparturesBroadParametersExpand? defaultValue,
]) {
  return enums.V3DeparturesBroadParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3DeparturesBroadParametersExpand,
      ) ??
      defaultValue ??
      enums.V3DeparturesBroadParametersExpand.swaggerGeneratedUnknown;
}

enums.V3DeparturesBroadParametersExpand?
v3DeparturesBroadParametersExpandNullableFromJson(
  Object? v3DeparturesBroadParametersExpand, [
  enums.V3DeparturesBroadParametersExpand? defaultValue,
]) {
  if (v3DeparturesBroadParametersExpand == null) {
    return null;
  }
  return enums.V3DeparturesBroadParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3DeparturesBroadParametersExpand,
      ) ??
      defaultValue;
}

String v3DeparturesBroadParametersExpandExplodedListToJson(
  List<enums.V3DeparturesBroadParametersExpand>?
  v3DeparturesBroadParametersExpand,
) {
  return v3DeparturesBroadParametersExpand?.map((e) => e.value!).join(',') ??
      '';
}

List<int> v3DeparturesBroadParametersExpandListToJson(
  List<enums.V3DeparturesBroadParametersExpand>?
  v3DeparturesBroadParametersExpand,
) {
  if (v3DeparturesBroadParametersExpand == null) {
    return [];
  }

  return v3DeparturesBroadParametersExpand.map((e) => e.value!).toList();
}

List<enums.V3DeparturesBroadParametersExpand>
v3DeparturesBroadParametersExpandListFromJson(
  List? v3DeparturesBroadParametersExpand, [
  List<enums.V3DeparturesBroadParametersExpand>? defaultValue,
]) {
  if (v3DeparturesBroadParametersExpand == null) {
    return defaultValue ?? [];
  }

  return v3DeparturesBroadParametersExpand
      .map((e) => v3DeparturesBroadParametersExpandFromJson(e))
      .toList();
}

List<enums.V3DeparturesBroadParametersExpand>?
v3DeparturesBroadParametersExpandNullableListFromJson(
  List? v3DeparturesBroadParametersExpand, [
  List<enums.V3DeparturesBroadParametersExpand>? defaultValue,
]) {
  if (v3DeparturesBroadParametersExpand == null) {
    return defaultValue;
  }

  return v3DeparturesBroadParametersExpand
      .map((e) => v3DeparturesBroadParametersExpandFromJson(e))
      .toList();
}

int? v3RunExternalServiceNullableToJson(
  enums.V3RunExternalService? v3RunExternalService,
) {
  return v3RunExternalService?.value;
}

int? v3RunExternalServiceToJson(
  enums.V3RunExternalService v3RunExternalService,
) {
  return v3RunExternalService.value;
}

enums.V3RunExternalService v3RunExternalServiceFromJson(
  Object? v3RunExternalService, [
  enums.V3RunExternalService? defaultValue,
]) {
  return enums.V3RunExternalService.values.firstWhereOrNull(
        (e) => e.value == v3RunExternalService,
      ) ??
      defaultValue ??
      enums.V3RunExternalService.swaggerGeneratedUnknown;
}

enums.V3RunExternalService? v3RunExternalServiceNullableFromJson(
  Object? v3RunExternalService, [
  enums.V3RunExternalService? defaultValue,
]) {
  if (v3RunExternalService == null) {
    return null;
  }
  return enums.V3RunExternalService.values.firstWhereOrNull(
        (e) => e.value == v3RunExternalService,
      ) ??
      defaultValue;
}

String v3RunExternalServiceExplodedListToJson(
  List<enums.V3RunExternalService>? v3RunExternalService,
) {
  return v3RunExternalService?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3RunExternalServiceListToJson(
  List<enums.V3RunExternalService>? v3RunExternalService,
) {
  if (v3RunExternalService == null) {
    return [];
  }

  return v3RunExternalService.map((e) => e.value!).toList();
}

List<enums.V3RunExternalService> v3RunExternalServiceListFromJson(
  List? v3RunExternalService, [
  List<enums.V3RunExternalService>? defaultValue,
]) {
  if (v3RunExternalService == null) {
    return defaultValue ?? [];
  }

  return v3RunExternalService
      .map((e) => v3RunExternalServiceFromJson(e))
      .toList();
}

List<enums.V3RunExternalService>? v3RunExternalServiceNullableListFromJson(
  List? v3RunExternalService, [
  List<enums.V3RunExternalService>? defaultValue,
]) {
  if (v3RunExternalService == null) {
    return defaultValue;
  }

  return v3RunExternalService
      .map((e) => v3RunExternalServiceFromJson(e))
      .toList();
}

int? v3DeparturesSpecificParametersExpandNullableToJson(
  enums.V3DeparturesSpecificParametersExpand?
  v3DeparturesSpecificParametersExpand,
) {
  return v3DeparturesSpecificParametersExpand?.value;
}

int? v3DeparturesSpecificParametersExpandToJson(
  enums.V3DeparturesSpecificParametersExpand
  v3DeparturesSpecificParametersExpand,
) {
  return v3DeparturesSpecificParametersExpand.value;
}

enums.V3DeparturesSpecificParametersExpand
v3DeparturesSpecificParametersExpandFromJson(
  Object? v3DeparturesSpecificParametersExpand, [
  enums.V3DeparturesSpecificParametersExpand? defaultValue,
]) {
  return enums.V3DeparturesSpecificParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3DeparturesSpecificParametersExpand,
      ) ??
      defaultValue ??
      enums.V3DeparturesSpecificParametersExpand.swaggerGeneratedUnknown;
}

enums.V3DeparturesSpecificParametersExpand?
v3DeparturesSpecificParametersExpandNullableFromJson(
  Object? v3DeparturesSpecificParametersExpand, [
  enums.V3DeparturesSpecificParametersExpand? defaultValue,
]) {
  if (v3DeparturesSpecificParametersExpand == null) {
    return null;
  }
  return enums.V3DeparturesSpecificParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3DeparturesSpecificParametersExpand,
      ) ??
      defaultValue;
}

String v3DeparturesSpecificParametersExpandExplodedListToJson(
  List<enums.V3DeparturesSpecificParametersExpand>?
  v3DeparturesSpecificParametersExpand,
) {
  return v3DeparturesSpecificParametersExpand?.map((e) => e.value!).join(',') ??
      '';
}

List<int> v3DeparturesSpecificParametersExpandListToJson(
  List<enums.V3DeparturesSpecificParametersExpand>?
  v3DeparturesSpecificParametersExpand,
) {
  if (v3DeparturesSpecificParametersExpand == null) {
    return [];
  }

  return v3DeparturesSpecificParametersExpand.map((e) => e.value!).toList();
}

List<enums.V3DeparturesSpecificParametersExpand>
v3DeparturesSpecificParametersExpandListFromJson(
  List? v3DeparturesSpecificParametersExpand, [
  List<enums.V3DeparturesSpecificParametersExpand>? defaultValue,
]) {
  if (v3DeparturesSpecificParametersExpand == null) {
    return defaultValue ?? [];
  }

  return v3DeparturesSpecificParametersExpand
      .map((e) => v3DeparturesSpecificParametersExpandFromJson(e))
      .toList();
}

List<enums.V3DeparturesSpecificParametersExpand>?
v3DeparturesSpecificParametersExpandNullableListFromJson(
  List? v3DeparturesSpecificParametersExpand, [
  List<enums.V3DeparturesSpecificParametersExpand>? defaultValue,
]) {
  if (v3DeparturesSpecificParametersExpand == null) {
    return defaultValue;
  }

  return v3DeparturesSpecificParametersExpand
      .map((e) => v3DeparturesSpecificParametersExpandFromJson(e))
      .toList();
}

int? v3RouteDeparturesSpecificParametersExpandNullableToJson(
  enums.V3RouteDeparturesSpecificParametersExpand?
  v3RouteDeparturesSpecificParametersExpand,
) {
  return v3RouteDeparturesSpecificParametersExpand?.value;
}

int? v3RouteDeparturesSpecificParametersExpandToJson(
  enums.V3RouteDeparturesSpecificParametersExpand
  v3RouteDeparturesSpecificParametersExpand,
) {
  return v3RouteDeparturesSpecificParametersExpand.value;
}

enums.V3RouteDeparturesSpecificParametersExpand
v3RouteDeparturesSpecificParametersExpandFromJson(
  Object? v3RouteDeparturesSpecificParametersExpand, [
  enums.V3RouteDeparturesSpecificParametersExpand? defaultValue,
]) {
  return enums.V3RouteDeparturesSpecificParametersExpand.values
          .firstWhereOrNull(
            (e) => e.value == v3RouteDeparturesSpecificParametersExpand,
          ) ??
      defaultValue ??
      enums.V3RouteDeparturesSpecificParametersExpand.swaggerGeneratedUnknown;
}

enums.V3RouteDeparturesSpecificParametersExpand?
v3RouteDeparturesSpecificParametersExpandNullableFromJson(
  Object? v3RouteDeparturesSpecificParametersExpand, [
  enums.V3RouteDeparturesSpecificParametersExpand? defaultValue,
]) {
  if (v3RouteDeparturesSpecificParametersExpand == null) {
    return null;
  }
  return enums.V3RouteDeparturesSpecificParametersExpand.values
          .firstWhereOrNull(
            (e) => e.value == v3RouteDeparturesSpecificParametersExpand,
          ) ??
      defaultValue;
}

String v3RouteDeparturesSpecificParametersExpandExplodedListToJson(
  List<enums.V3RouteDeparturesSpecificParametersExpand>?
  v3RouteDeparturesSpecificParametersExpand,
) {
  return v3RouteDeparturesSpecificParametersExpand
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3RouteDeparturesSpecificParametersExpandListToJson(
  List<enums.V3RouteDeparturesSpecificParametersExpand>?
  v3RouteDeparturesSpecificParametersExpand,
) {
  if (v3RouteDeparturesSpecificParametersExpand == null) {
    return [];
  }

  return v3RouteDeparturesSpecificParametersExpand
      .map((e) => e.value!)
      .toList();
}

List<enums.V3RouteDeparturesSpecificParametersExpand>
v3RouteDeparturesSpecificParametersExpandListFromJson(
  List? v3RouteDeparturesSpecificParametersExpand, [
  List<enums.V3RouteDeparturesSpecificParametersExpand>? defaultValue,
]) {
  if (v3RouteDeparturesSpecificParametersExpand == null) {
    return defaultValue ?? [];
  }

  return v3RouteDeparturesSpecificParametersExpand
      .map((e) => v3RouteDeparturesSpecificParametersExpandFromJson(e))
      .toList();
}

List<enums.V3RouteDeparturesSpecificParametersExpand>?
v3RouteDeparturesSpecificParametersExpandNullableListFromJson(
  List? v3RouteDeparturesSpecificParametersExpand, [
  List<enums.V3RouteDeparturesSpecificParametersExpand>? defaultValue,
]) {
  if (v3RouteDeparturesSpecificParametersExpand == null) {
    return defaultValue;
  }

  return v3RouteDeparturesSpecificParametersExpand
      .map((e) => v3RouteDeparturesSpecificParametersExpandFromJson(e))
      .toList();
}

int? v3BulkDeparturesRequestExpandNullableToJson(
  enums.V3BulkDeparturesRequestExpand? v3BulkDeparturesRequestExpand,
) {
  return v3BulkDeparturesRequestExpand?.value;
}

int? v3BulkDeparturesRequestExpandToJson(
  enums.V3BulkDeparturesRequestExpand v3BulkDeparturesRequestExpand,
) {
  return v3BulkDeparturesRequestExpand.value;
}

enums.V3BulkDeparturesRequestExpand v3BulkDeparturesRequestExpandFromJson(
  Object? v3BulkDeparturesRequestExpand, [
  enums.V3BulkDeparturesRequestExpand? defaultValue,
]) {
  return enums.V3BulkDeparturesRequestExpand.values.firstWhereOrNull(
        (e) => e.value == v3BulkDeparturesRequestExpand,
      ) ??
      defaultValue ??
      enums.V3BulkDeparturesRequestExpand.swaggerGeneratedUnknown;
}

enums.V3BulkDeparturesRequestExpand?
v3BulkDeparturesRequestExpandNullableFromJson(
  Object? v3BulkDeparturesRequestExpand, [
  enums.V3BulkDeparturesRequestExpand? defaultValue,
]) {
  if (v3BulkDeparturesRequestExpand == null) {
    return null;
  }
  return enums.V3BulkDeparturesRequestExpand.values.firstWhereOrNull(
        (e) => e.value == v3BulkDeparturesRequestExpand,
      ) ??
      defaultValue;
}

String v3BulkDeparturesRequestExpandExplodedListToJson(
  List<enums.V3BulkDeparturesRequestExpand>? v3BulkDeparturesRequestExpand,
) {
  return v3BulkDeparturesRequestExpand?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3BulkDeparturesRequestExpandListToJson(
  List<enums.V3BulkDeparturesRequestExpand>? v3BulkDeparturesRequestExpand,
) {
  if (v3BulkDeparturesRequestExpand == null) {
    return [];
  }

  return v3BulkDeparturesRequestExpand.map((e) => e.value!).toList();
}

List<enums.V3BulkDeparturesRequestExpand>
v3BulkDeparturesRequestExpandListFromJson(
  List? v3BulkDeparturesRequestExpand, [
  List<enums.V3BulkDeparturesRequestExpand>? defaultValue,
]) {
  if (v3BulkDeparturesRequestExpand == null) {
    return defaultValue ?? [];
  }

  return v3BulkDeparturesRequestExpand
      .map((e) => v3BulkDeparturesRequestExpandFromJson(e))
      .toList();
}

List<enums.V3BulkDeparturesRequestExpand>?
v3BulkDeparturesRequestExpandNullableListFromJson(
  List? v3BulkDeparturesRequestExpand, [
  List<enums.V3BulkDeparturesRequestExpand>? defaultValue,
]) {
  if (v3BulkDeparturesRequestExpand == null) {
    return defaultValue;
  }

  return v3BulkDeparturesRequestExpand
      .map((e) => v3BulkDeparturesRequestExpandFromJson(e))
      .toList();
}

int? v3StopDepartureRequestRouteTypeNullableToJson(
  enums.V3StopDepartureRequestRouteType? v3StopDepartureRequestRouteType,
) {
  return v3StopDepartureRequestRouteType?.value;
}

int? v3StopDepartureRequestRouteTypeToJson(
  enums.V3StopDepartureRequestRouteType v3StopDepartureRequestRouteType,
) {
  return v3StopDepartureRequestRouteType.value;
}

enums.V3StopDepartureRequestRouteType v3StopDepartureRequestRouteTypeFromJson(
  Object? v3StopDepartureRequestRouteType, [
  enums.V3StopDepartureRequestRouteType? defaultValue,
]) {
  return enums.V3StopDepartureRequestRouteType.values.firstWhereOrNull(
        (e) => e.value == v3StopDepartureRequestRouteType,
      ) ??
      defaultValue ??
      enums.V3StopDepartureRequestRouteType.swaggerGeneratedUnknown;
}

enums.V3StopDepartureRequestRouteType?
v3StopDepartureRequestRouteTypeNullableFromJson(
  Object? v3StopDepartureRequestRouteType, [
  enums.V3StopDepartureRequestRouteType? defaultValue,
]) {
  if (v3StopDepartureRequestRouteType == null) {
    return null;
  }
  return enums.V3StopDepartureRequestRouteType.values.firstWhereOrNull(
        (e) => e.value == v3StopDepartureRequestRouteType,
      ) ??
      defaultValue;
}

String v3StopDepartureRequestRouteTypeExplodedListToJson(
  List<enums.V3StopDepartureRequestRouteType>? v3StopDepartureRequestRouteType,
) {
  return v3StopDepartureRequestRouteType?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3StopDepartureRequestRouteTypeListToJson(
  List<enums.V3StopDepartureRequestRouteType>? v3StopDepartureRequestRouteType,
) {
  if (v3StopDepartureRequestRouteType == null) {
    return [];
  }

  return v3StopDepartureRequestRouteType.map((e) => e.value!).toList();
}

List<enums.V3StopDepartureRequestRouteType>
v3StopDepartureRequestRouteTypeListFromJson(
  List? v3StopDepartureRequestRouteType, [
  List<enums.V3StopDepartureRequestRouteType>? defaultValue,
]) {
  if (v3StopDepartureRequestRouteType == null) {
    return defaultValue ?? [];
  }

  return v3StopDepartureRequestRouteType
      .map((e) => v3StopDepartureRequestRouteTypeFromJson(e))
      .toList();
}

List<enums.V3StopDepartureRequestRouteType>?
v3StopDepartureRequestRouteTypeNullableListFromJson(
  List? v3StopDepartureRequestRouteType, [
  List<enums.V3StopDepartureRequestRouteType>? defaultValue,
]) {
  if (v3StopDepartureRequestRouteType == null) {
    return defaultValue;
  }

  return v3StopDepartureRequestRouteType
      .map((e) => v3StopDepartureRequestRouteTypeFromJson(e))
      .toList();
}

int? v3FareEstimateParametersTravelledRouteTypesNullableToJson(
  enums.V3FareEstimateParametersTravelledRouteTypes?
  v3FareEstimateParametersTravelledRouteTypes,
) {
  return v3FareEstimateParametersTravelledRouteTypes?.value;
}

int? v3FareEstimateParametersTravelledRouteTypesToJson(
  enums.V3FareEstimateParametersTravelledRouteTypes
  v3FareEstimateParametersTravelledRouteTypes,
) {
  return v3FareEstimateParametersTravelledRouteTypes.value;
}

enums.V3FareEstimateParametersTravelledRouteTypes
v3FareEstimateParametersTravelledRouteTypesFromJson(
  Object? v3FareEstimateParametersTravelledRouteTypes, [
  enums.V3FareEstimateParametersTravelledRouteTypes? defaultValue,
]) {
  return enums.V3FareEstimateParametersTravelledRouteTypes.values
          .firstWhereOrNull(
            (e) => e.value == v3FareEstimateParametersTravelledRouteTypes,
          ) ??
      defaultValue ??
      enums.V3FareEstimateParametersTravelledRouteTypes.swaggerGeneratedUnknown;
}

enums.V3FareEstimateParametersTravelledRouteTypes?
v3FareEstimateParametersTravelledRouteTypesNullableFromJson(
  Object? v3FareEstimateParametersTravelledRouteTypes, [
  enums.V3FareEstimateParametersTravelledRouteTypes? defaultValue,
]) {
  if (v3FareEstimateParametersTravelledRouteTypes == null) {
    return null;
  }
  return enums.V3FareEstimateParametersTravelledRouteTypes.values
          .firstWhereOrNull(
            (e) => e.value == v3FareEstimateParametersTravelledRouteTypes,
          ) ??
      defaultValue;
}

String v3FareEstimateParametersTravelledRouteTypesExplodedListToJson(
  List<enums.V3FareEstimateParametersTravelledRouteTypes>?
  v3FareEstimateParametersTravelledRouteTypes,
) {
  return v3FareEstimateParametersTravelledRouteTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3FareEstimateParametersTravelledRouteTypesListToJson(
  List<enums.V3FareEstimateParametersTravelledRouteTypes>?
  v3FareEstimateParametersTravelledRouteTypes,
) {
  if (v3FareEstimateParametersTravelledRouteTypes == null) {
    return [];
  }

  return v3FareEstimateParametersTravelledRouteTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V3FareEstimateParametersTravelledRouteTypes>
v3FareEstimateParametersTravelledRouteTypesListFromJson(
  List? v3FareEstimateParametersTravelledRouteTypes, [
  List<enums.V3FareEstimateParametersTravelledRouteTypes>? defaultValue,
]) {
  if (v3FareEstimateParametersTravelledRouteTypes == null) {
    return defaultValue ?? [];
  }

  return v3FareEstimateParametersTravelledRouteTypes
      .map((e) => v3FareEstimateParametersTravelledRouteTypesFromJson(e))
      .toList();
}

List<enums.V3FareEstimateParametersTravelledRouteTypes>?
v3FareEstimateParametersTravelledRouteTypesNullableListFromJson(
  List? v3FareEstimateParametersTravelledRouteTypes, [
  List<enums.V3FareEstimateParametersTravelledRouteTypes>? defaultValue,
]) {
  if (v3FareEstimateParametersTravelledRouteTypes == null) {
    return defaultValue;
  }

  return v3FareEstimateParametersTravelledRouteTypes
      .map((e) => v3FareEstimateParametersTravelledRouteTypesFromJson(e))
      .toList();
}

int? v3JourneyPlannerLocationRouteTypesNullableToJson(
  enums.V3JourneyPlannerLocationRouteTypes? v3JourneyPlannerLocationRouteTypes,
) {
  return v3JourneyPlannerLocationRouteTypes?.value;
}

int? v3JourneyPlannerLocationRouteTypesToJson(
  enums.V3JourneyPlannerLocationRouteTypes v3JourneyPlannerLocationRouteTypes,
) {
  return v3JourneyPlannerLocationRouteTypes.value;
}

enums.V3JourneyPlannerLocationRouteTypes
v3JourneyPlannerLocationRouteTypesFromJson(
  Object? v3JourneyPlannerLocationRouteTypes, [
  enums.V3JourneyPlannerLocationRouteTypes? defaultValue,
]) {
  return enums.V3JourneyPlannerLocationRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3JourneyPlannerLocationRouteTypes,
      ) ??
      defaultValue ??
      enums.V3JourneyPlannerLocationRouteTypes.swaggerGeneratedUnknown;
}

enums.V3JourneyPlannerLocationRouteTypes?
v3JourneyPlannerLocationRouteTypesNullableFromJson(
  Object? v3JourneyPlannerLocationRouteTypes, [
  enums.V3JourneyPlannerLocationRouteTypes? defaultValue,
]) {
  if (v3JourneyPlannerLocationRouteTypes == null) {
    return null;
  }
  return enums.V3JourneyPlannerLocationRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3JourneyPlannerLocationRouteTypes,
      ) ??
      defaultValue;
}

String v3JourneyPlannerLocationRouteTypesExplodedListToJson(
  List<enums.V3JourneyPlannerLocationRouteTypes>?
  v3JourneyPlannerLocationRouteTypes,
) {
  return v3JourneyPlannerLocationRouteTypes?.map((e) => e.value!).join(',') ??
      '';
}

List<int> v3JourneyPlannerLocationRouteTypesListToJson(
  List<enums.V3JourneyPlannerLocationRouteTypes>?
  v3JourneyPlannerLocationRouteTypes,
) {
  if (v3JourneyPlannerLocationRouteTypes == null) {
    return [];
  }

  return v3JourneyPlannerLocationRouteTypes.map((e) => e.value!).toList();
}

List<enums.V3JourneyPlannerLocationRouteTypes>
v3JourneyPlannerLocationRouteTypesListFromJson(
  List? v3JourneyPlannerLocationRouteTypes, [
  List<enums.V3JourneyPlannerLocationRouteTypes>? defaultValue,
]) {
  if (v3JourneyPlannerLocationRouteTypes == null) {
    return defaultValue ?? [];
  }

  return v3JourneyPlannerLocationRouteTypes
      .map((e) => v3JourneyPlannerLocationRouteTypesFromJson(e))
      .toList();
}

List<enums.V3JourneyPlannerLocationRouteTypes>?
v3JourneyPlannerLocationRouteTypesNullableListFromJson(
  List? v3JourneyPlannerLocationRouteTypes, [
  List<enums.V3JourneyPlannerLocationRouteTypes>? defaultValue,
]) {
  if (v3JourneyPlannerLocationRouteTypes == null) {
    return defaultValue;
  }

  return v3JourneyPlannerLocationRouteTypes
      .map((e) => v3JourneyPlannerLocationRouteTypesFromJson(e))
      .toList();
}

int? v3PatternsParametersExpandNullableToJson(
  enums.V3PatternsParametersExpand? v3PatternsParametersExpand,
) {
  return v3PatternsParametersExpand?.value;
}

int? v3PatternsParametersExpandToJson(
  enums.V3PatternsParametersExpand v3PatternsParametersExpand,
) {
  return v3PatternsParametersExpand.value;
}

enums.V3PatternsParametersExpand v3PatternsParametersExpandFromJson(
  Object? v3PatternsParametersExpand, [
  enums.V3PatternsParametersExpand? defaultValue,
]) {
  return enums.V3PatternsParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3PatternsParametersExpand,
      ) ??
      defaultValue ??
      enums.V3PatternsParametersExpand.swaggerGeneratedUnknown;
}

enums.V3PatternsParametersExpand? v3PatternsParametersExpandNullableFromJson(
  Object? v3PatternsParametersExpand, [
  enums.V3PatternsParametersExpand? defaultValue,
]) {
  if (v3PatternsParametersExpand == null) {
    return null;
  }
  return enums.V3PatternsParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3PatternsParametersExpand,
      ) ??
      defaultValue;
}

String v3PatternsParametersExpandExplodedListToJson(
  List<enums.V3PatternsParametersExpand>? v3PatternsParametersExpand,
) {
  return v3PatternsParametersExpand?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3PatternsParametersExpandListToJson(
  List<enums.V3PatternsParametersExpand>? v3PatternsParametersExpand,
) {
  if (v3PatternsParametersExpand == null) {
    return [];
  }

  return v3PatternsParametersExpand.map((e) => e.value!).toList();
}

List<enums.V3PatternsParametersExpand> v3PatternsParametersExpandListFromJson(
  List? v3PatternsParametersExpand, [
  List<enums.V3PatternsParametersExpand>? defaultValue,
]) {
  if (v3PatternsParametersExpand == null) {
    return defaultValue ?? [];
  }

  return v3PatternsParametersExpand
      .map((e) => v3PatternsParametersExpandFromJson(e))
      .toList();
}

List<enums.V3PatternsParametersExpand>?
v3PatternsParametersExpandNullableListFromJson(
  List? v3PatternsParametersExpand, [
  List<enums.V3PatternsParametersExpand>? defaultValue,
]) {
  if (v3PatternsParametersExpand == null) {
    return defaultValue;
  }

  return v3PatternsParametersExpand
      .map((e) => v3PatternsParametersExpandFromJson(e))
      .toList();
}

int? v3RunsBroadParametersExpandNullableToJson(
  enums.V3RunsBroadParametersExpand? v3RunsBroadParametersExpand,
) {
  return v3RunsBroadParametersExpand?.value;
}

int? v3RunsBroadParametersExpandToJson(
  enums.V3RunsBroadParametersExpand v3RunsBroadParametersExpand,
) {
  return v3RunsBroadParametersExpand.value;
}

enums.V3RunsBroadParametersExpand v3RunsBroadParametersExpandFromJson(
  Object? v3RunsBroadParametersExpand, [
  enums.V3RunsBroadParametersExpand? defaultValue,
]) {
  return enums.V3RunsBroadParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsBroadParametersExpand,
      ) ??
      defaultValue ??
      enums.V3RunsBroadParametersExpand.swaggerGeneratedUnknown;
}

enums.V3RunsBroadParametersExpand? v3RunsBroadParametersExpandNullableFromJson(
  Object? v3RunsBroadParametersExpand, [
  enums.V3RunsBroadParametersExpand? defaultValue,
]) {
  if (v3RunsBroadParametersExpand == null) {
    return null;
  }
  return enums.V3RunsBroadParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsBroadParametersExpand,
      ) ??
      defaultValue;
}

String v3RunsBroadParametersExpandExplodedListToJson(
  List<enums.V3RunsBroadParametersExpand>? v3RunsBroadParametersExpand,
) {
  return v3RunsBroadParametersExpand?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3RunsBroadParametersExpandListToJson(
  List<enums.V3RunsBroadParametersExpand>? v3RunsBroadParametersExpand,
) {
  if (v3RunsBroadParametersExpand == null) {
    return [];
  }

  return v3RunsBroadParametersExpand.map((e) => e.value!).toList();
}

List<enums.V3RunsBroadParametersExpand> v3RunsBroadParametersExpandListFromJson(
  List? v3RunsBroadParametersExpand, [
  List<enums.V3RunsBroadParametersExpand>? defaultValue,
]) {
  if (v3RunsBroadParametersExpand == null) {
    return defaultValue ?? [];
  }

  return v3RunsBroadParametersExpand
      .map((e) => v3RunsBroadParametersExpandFromJson(e))
      .toList();
}

List<enums.V3RunsBroadParametersExpand>?
v3RunsBroadParametersExpandNullableListFromJson(
  List? v3RunsBroadParametersExpand, [
  List<enums.V3RunsBroadParametersExpand>? defaultValue,
]) {
  if (v3RunsBroadParametersExpand == null) {
    return defaultValue;
  }

  return v3RunsBroadParametersExpand
      .map((e) => v3RunsBroadParametersExpandFromJson(e))
      .toList();
}

int? v3RunsSpecificParametersExpandNullableToJson(
  enums.V3RunsSpecificParametersExpand? v3RunsSpecificParametersExpand,
) {
  return v3RunsSpecificParametersExpand?.value;
}

int? v3RunsSpecificParametersExpandToJson(
  enums.V3RunsSpecificParametersExpand v3RunsSpecificParametersExpand,
) {
  return v3RunsSpecificParametersExpand.value;
}

enums.V3RunsSpecificParametersExpand v3RunsSpecificParametersExpandFromJson(
  Object? v3RunsSpecificParametersExpand, [
  enums.V3RunsSpecificParametersExpand? defaultValue,
]) {
  return enums.V3RunsSpecificParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsSpecificParametersExpand,
      ) ??
      defaultValue ??
      enums.V3RunsSpecificParametersExpand.swaggerGeneratedUnknown;
}

enums.V3RunsSpecificParametersExpand?
v3RunsSpecificParametersExpandNullableFromJson(
  Object? v3RunsSpecificParametersExpand, [
  enums.V3RunsSpecificParametersExpand? defaultValue,
]) {
  if (v3RunsSpecificParametersExpand == null) {
    return null;
  }
  return enums.V3RunsSpecificParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsSpecificParametersExpand,
      ) ??
      defaultValue;
}

String v3RunsSpecificParametersExpandExplodedListToJson(
  List<enums.V3RunsSpecificParametersExpand>? v3RunsSpecificParametersExpand,
) {
  return v3RunsSpecificParametersExpand?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3RunsSpecificParametersExpandListToJson(
  List<enums.V3RunsSpecificParametersExpand>? v3RunsSpecificParametersExpand,
) {
  if (v3RunsSpecificParametersExpand == null) {
    return [];
  }

  return v3RunsSpecificParametersExpand.map((e) => e.value!).toList();
}

List<enums.V3RunsSpecificParametersExpand>
v3RunsSpecificParametersExpandListFromJson(
  List? v3RunsSpecificParametersExpand, [
  List<enums.V3RunsSpecificParametersExpand>? defaultValue,
]) {
  if (v3RunsSpecificParametersExpand == null) {
    return defaultValue ?? [];
  }

  return v3RunsSpecificParametersExpand
      .map((e) => v3RunsSpecificParametersExpandFromJson(e))
      .toList();
}

List<enums.V3RunsSpecificParametersExpand>?
v3RunsSpecificParametersExpandNullableListFromJson(
  List? v3RunsSpecificParametersExpand, [
  List<enums.V3RunsSpecificParametersExpand>? defaultValue,
]) {
  if (v3RunsSpecificParametersExpand == null) {
    return defaultValue;
  }

  return v3RunsSpecificParametersExpand
      .map((e) => v3RunsSpecificParametersExpandFromJson(e))
      .toList();
}

int? v3RunAndRouteTypeParametersExpandNullableToJson(
  enums.V3RunAndRouteTypeParametersExpand? v3RunAndRouteTypeParametersExpand,
) {
  return v3RunAndRouteTypeParametersExpand?.value;
}

int? v3RunAndRouteTypeParametersExpandToJson(
  enums.V3RunAndRouteTypeParametersExpand v3RunAndRouteTypeParametersExpand,
) {
  return v3RunAndRouteTypeParametersExpand.value;
}

enums.V3RunAndRouteTypeParametersExpand
v3RunAndRouteTypeParametersExpandFromJson(
  Object? v3RunAndRouteTypeParametersExpand, [
  enums.V3RunAndRouteTypeParametersExpand? defaultValue,
]) {
  return enums.V3RunAndRouteTypeParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunAndRouteTypeParametersExpand,
      ) ??
      defaultValue ??
      enums.V3RunAndRouteTypeParametersExpand.swaggerGeneratedUnknown;
}

enums.V3RunAndRouteTypeParametersExpand?
v3RunAndRouteTypeParametersExpandNullableFromJson(
  Object? v3RunAndRouteTypeParametersExpand, [
  enums.V3RunAndRouteTypeParametersExpand? defaultValue,
]) {
  if (v3RunAndRouteTypeParametersExpand == null) {
    return null;
  }
  return enums.V3RunAndRouteTypeParametersExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunAndRouteTypeParametersExpand,
      ) ??
      defaultValue;
}

String v3RunAndRouteTypeParametersExpandExplodedListToJson(
  List<enums.V3RunAndRouteTypeParametersExpand>?
  v3RunAndRouteTypeParametersExpand,
) {
  return v3RunAndRouteTypeParametersExpand?.map((e) => e.value!).join(',') ??
      '';
}

List<int> v3RunAndRouteTypeParametersExpandListToJson(
  List<enums.V3RunAndRouteTypeParametersExpand>?
  v3RunAndRouteTypeParametersExpand,
) {
  if (v3RunAndRouteTypeParametersExpand == null) {
    return [];
  }

  return v3RunAndRouteTypeParametersExpand.map((e) => e.value!).toList();
}

List<enums.V3RunAndRouteTypeParametersExpand>
v3RunAndRouteTypeParametersExpandListFromJson(
  List? v3RunAndRouteTypeParametersExpand, [
  List<enums.V3RunAndRouteTypeParametersExpand>? defaultValue,
]) {
  if (v3RunAndRouteTypeParametersExpand == null) {
    return defaultValue ?? [];
  }

  return v3RunAndRouteTypeParametersExpand
      .map((e) => v3RunAndRouteTypeParametersExpandFromJson(e))
      .toList();
}

List<enums.V3RunAndRouteTypeParametersExpand>?
v3RunAndRouteTypeParametersExpandNullableListFromJson(
  List? v3RunAndRouteTypeParametersExpand, [
  List<enums.V3RunAndRouteTypeParametersExpand>? defaultValue,
]) {
  if (v3RunAndRouteTypeParametersExpand == null) {
    return defaultValue;
  }

  return v3RunAndRouteTypeParametersExpand
      .map((e) => v3RunAndRouteTypeParametersExpandFromJson(e))
      .toList();
}

int? v3SearchParametersRouteTypesNullableToJson(
  enums.V3SearchParametersRouteTypes? v3SearchParametersRouteTypes,
) {
  return v3SearchParametersRouteTypes?.value;
}

int? v3SearchParametersRouteTypesToJson(
  enums.V3SearchParametersRouteTypes v3SearchParametersRouteTypes,
) {
  return v3SearchParametersRouteTypes.value;
}

enums.V3SearchParametersRouteTypes v3SearchParametersRouteTypesFromJson(
  Object? v3SearchParametersRouteTypes, [
  enums.V3SearchParametersRouteTypes? defaultValue,
]) {
  return enums.V3SearchParametersRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3SearchParametersRouteTypes,
      ) ??
      defaultValue ??
      enums.V3SearchParametersRouteTypes.swaggerGeneratedUnknown;
}

enums.V3SearchParametersRouteTypes?
v3SearchParametersRouteTypesNullableFromJson(
  Object? v3SearchParametersRouteTypes, [
  enums.V3SearchParametersRouteTypes? defaultValue,
]) {
  if (v3SearchParametersRouteTypes == null) {
    return null;
  }
  return enums.V3SearchParametersRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3SearchParametersRouteTypes,
      ) ??
      defaultValue;
}

String v3SearchParametersRouteTypesExplodedListToJson(
  List<enums.V3SearchParametersRouteTypes>? v3SearchParametersRouteTypes,
) {
  return v3SearchParametersRouteTypes?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3SearchParametersRouteTypesListToJson(
  List<enums.V3SearchParametersRouteTypes>? v3SearchParametersRouteTypes,
) {
  if (v3SearchParametersRouteTypes == null) {
    return [];
  }

  return v3SearchParametersRouteTypes.map((e) => e.value!).toList();
}

List<enums.V3SearchParametersRouteTypes>
v3SearchParametersRouteTypesListFromJson(
  List? v3SearchParametersRouteTypes, [
  List<enums.V3SearchParametersRouteTypes>? defaultValue,
]) {
  if (v3SearchParametersRouteTypes == null) {
    return defaultValue ?? [];
  }

  return v3SearchParametersRouteTypes
      .map((e) => v3SearchParametersRouteTypesFromJson(e))
      .toList();
}

List<enums.V3SearchParametersRouteTypes>?
v3SearchParametersRouteTypesNullableListFromJson(
  List? v3SearchParametersRouteTypes, [
  List<enums.V3SearchParametersRouteTypes>? defaultValue,
]) {
  if (v3SearchParametersRouteTypes == null) {
    return defaultValue;
  }

  return v3SearchParametersRouteTypes
      .map((e) => v3SearchParametersRouteTypesFromJson(e))
      .toList();
}

int? v3SiriLineRefDirectionRefStopPointRefDirectionRefNullableToJson(
  enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef?
  v3SiriLineRefDirectionRefStopPointRefDirectionRef,
) {
  return v3SiriLineRefDirectionRefStopPointRefDirectionRef?.value;
}

int? v3SiriLineRefDirectionRefStopPointRefDirectionRefToJson(
  enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef
  v3SiriLineRefDirectionRefStopPointRefDirectionRef,
) {
  return v3SiriLineRefDirectionRefStopPointRefDirectionRef.value;
}

enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef
v3SiriLineRefDirectionRefStopPointRefDirectionRefFromJson(
  Object? v3SiriLineRefDirectionRefStopPointRefDirectionRef, [
  enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef? defaultValue,
]) {
  return enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef.values
          .firstWhereOrNull(
            (e) => e.value == v3SiriLineRefDirectionRefStopPointRefDirectionRef,
          ) ??
      defaultValue ??
      enums
          .V3SiriLineRefDirectionRefStopPointRefDirectionRef
          .swaggerGeneratedUnknown;
}

enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef?
v3SiriLineRefDirectionRefStopPointRefDirectionRefNullableFromJson(
  Object? v3SiriLineRefDirectionRefStopPointRefDirectionRef, [
  enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef? defaultValue,
]) {
  if (v3SiriLineRefDirectionRefStopPointRefDirectionRef == null) {
    return null;
  }
  return enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef.values
          .firstWhereOrNull(
            (e) => e.value == v3SiriLineRefDirectionRefStopPointRefDirectionRef,
          ) ??
      defaultValue;
}

String v3SiriLineRefDirectionRefStopPointRefDirectionRefExplodedListToJson(
  List<enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef>?
  v3SiriLineRefDirectionRefStopPointRefDirectionRef,
) {
  return v3SiriLineRefDirectionRefStopPointRefDirectionRef
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3SiriLineRefDirectionRefStopPointRefDirectionRefListToJson(
  List<enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef>?
  v3SiriLineRefDirectionRefStopPointRefDirectionRef,
) {
  if (v3SiriLineRefDirectionRefStopPointRefDirectionRef == null) {
    return [];
  }

  return v3SiriLineRefDirectionRefStopPointRefDirectionRef
      .map((e) => e.value!)
      .toList();
}

List<enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef>
v3SiriLineRefDirectionRefStopPointRefDirectionRefListFromJson(
  List? v3SiriLineRefDirectionRefStopPointRefDirectionRef, [
  List<enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef>? defaultValue,
]) {
  if (v3SiriLineRefDirectionRefStopPointRefDirectionRef == null) {
    return defaultValue ?? [];
  }

  return v3SiriLineRefDirectionRefStopPointRefDirectionRef
      .map((e) => v3SiriLineRefDirectionRefStopPointRefDirectionRefFromJson(e))
      .toList();
}

List<enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef>?
v3SiriLineRefDirectionRefStopPointRefDirectionRefNullableListFromJson(
  List? v3SiriLineRefDirectionRefStopPointRefDirectionRef, [
  List<enums.V3SiriLineRefDirectionRefStopPointRefDirectionRef>? defaultValue,
]) {
  if (v3SiriLineRefDirectionRefStopPointRefDirectionRef == null) {
    return defaultValue;
  }

  return v3SiriLineRefDirectionRefStopPointRefDirectionRef
      .map((e) => v3SiriLineRefDirectionRefStopPointRefDirectionRefFromJson(e))
      .toList();
}

int? v3SiriReferenceDataDetailNoMatchReasonNullableToJson(
  enums.V3SiriReferenceDataDetailNoMatchReason?
  v3SiriReferenceDataDetailNoMatchReason,
) {
  return v3SiriReferenceDataDetailNoMatchReason?.value;
}

int? v3SiriReferenceDataDetailNoMatchReasonToJson(
  enums.V3SiriReferenceDataDetailNoMatchReason
  v3SiriReferenceDataDetailNoMatchReason,
) {
  return v3SiriReferenceDataDetailNoMatchReason.value;
}

enums.V3SiriReferenceDataDetailNoMatchReason
v3SiriReferenceDataDetailNoMatchReasonFromJson(
  Object? v3SiriReferenceDataDetailNoMatchReason, [
  enums.V3SiriReferenceDataDetailNoMatchReason? defaultValue,
]) {
  return enums.V3SiriReferenceDataDetailNoMatchReason.values.firstWhereOrNull(
        (e) => e.value == v3SiriReferenceDataDetailNoMatchReason,
      ) ??
      defaultValue ??
      enums.V3SiriReferenceDataDetailNoMatchReason.swaggerGeneratedUnknown;
}

enums.V3SiriReferenceDataDetailNoMatchReason?
v3SiriReferenceDataDetailNoMatchReasonNullableFromJson(
  Object? v3SiriReferenceDataDetailNoMatchReason, [
  enums.V3SiriReferenceDataDetailNoMatchReason? defaultValue,
]) {
  if (v3SiriReferenceDataDetailNoMatchReason == null) {
    return null;
  }
  return enums.V3SiriReferenceDataDetailNoMatchReason.values.firstWhereOrNull(
        (e) => e.value == v3SiriReferenceDataDetailNoMatchReason,
      ) ??
      defaultValue;
}

String v3SiriReferenceDataDetailNoMatchReasonExplodedListToJson(
  List<enums.V3SiriReferenceDataDetailNoMatchReason>?
  v3SiriReferenceDataDetailNoMatchReason,
) {
  return v3SiriReferenceDataDetailNoMatchReason
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3SiriReferenceDataDetailNoMatchReasonListToJson(
  List<enums.V3SiriReferenceDataDetailNoMatchReason>?
  v3SiriReferenceDataDetailNoMatchReason,
) {
  if (v3SiriReferenceDataDetailNoMatchReason == null) {
    return [];
  }

  return v3SiriReferenceDataDetailNoMatchReason.map((e) => e.value!).toList();
}

List<enums.V3SiriReferenceDataDetailNoMatchReason>
v3SiriReferenceDataDetailNoMatchReasonListFromJson(
  List? v3SiriReferenceDataDetailNoMatchReason, [
  List<enums.V3SiriReferenceDataDetailNoMatchReason>? defaultValue,
]) {
  if (v3SiriReferenceDataDetailNoMatchReason == null) {
    return defaultValue ?? [];
  }

  return v3SiriReferenceDataDetailNoMatchReason
      .map((e) => v3SiriReferenceDataDetailNoMatchReasonFromJson(e))
      .toList();
}

List<enums.V3SiriReferenceDataDetailNoMatchReason>?
v3SiriReferenceDataDetailNoMatchReasonNullableListFromJson(
  List? v3SiriReferenceDataDetailNoMatchReason, [
  List<enums.V3SiriReferenceDataDetailNoMatchReason>? defaultValue,
]) {
  if (v3SiriReferenceDataDetailNoMatchReason == null) {
    return defaultValue;
  }

  return v3SiriReferenceDataDetailNoMatchReason
      .map((e) => v3SiriReferenceDataDetailNoMatchReasonFromJson(e))
      .toList();
}

int? v3SiriLineRefDirectionRefNullableToJson(
  enums.V3SiriLineRefDirectionRef? v3SiriLineRefDirectionRef,
) {
  return v3SiriLineRefDirectionRef?.value;
}

int? v3SiriLineRefDirectionRefToJson(
  enums.V3SiriLineRefDirectionRef v3SiriLineRefDirectionRef,
) {
  return v3SiriLineRefDirectionRef.value;
}

enums.V3SiriLineRefDirectionRef v3SiriLineRefDirectionRefFromJson(
  Object? v3SiriLineRefDirectionRef, [
  enums.V3SiriLineRefDirectionRef? defaultValue,
]) {
  return enums.V3SiriLineRefDirectionRef.values.firstWhereOrNull(
        (e) => e.value == v3SiriLineRefDirectionRef,
      ) ??
      defaultValue ??
      enums.V3SiriLineRefDirectionRef.swaggerGeneratedUnknown;
}

enums.V3SiriLineRefDirectionRef? v3SiriLineRefDirectionRefNullableFromJson(
  Object? v3SiriLineRefDirectionRef, [
  enums.V3SiriLineRefDirectionRef? defaultValue,
]) {
  if (v3SiriLineRefDirectionRef == null) {
    return null;
  }
  return enums.V3SiriLineRefDirectionRef.values.firstWhereOrNull(
        (e) => e.value == v3SiriLineRefDirectionRef,
      ) ??
      defaultValue;
}

String v3SiriLineRefDirectionRefExplodedListToJson(
  List<enums.V3SiriLineRefDirectionRef>? v3SiriLineRefDirectionRef,
) {
  return v3SiriLineRefDirectionRef?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3SiriLineRefDirectionRefListToJson(
  List<enums.V3SiriLineRefDirectionRef>? v3SiriLineRefDirectionRef,
) {
  if (v3SiriLineRefDirectionRef == null) {
    return [];
  }

  return v3SiriLineRefDirectionRef.map((e) => e.value!).toList();
}

List<enums.V3SiriLineRefDirectionRef> v3SiriLineRefDirectionRefListFromJson(
  List? v3SiriLineRefDirectionRef, [
  List<enums.V3SiriLineRefDirectionRef>? defaultValue,
]) {
  if (v3SiriLineRefDirectionRef == null) {
    return defaultValue ?? [];
  }

  return v3SiriLineRefDirectionRef
      .map((e) => v3SiriLineRefDirectionRefFromJson(e))
      .toList();
}

List<enums.V3SiriLineRefDirectionRef>?
v3SiriLineRefDirectionRefNullableListFromJson(
  List? v3SiriLineRefDirectionRef, [
  List<enums.V3SiriLineRefDirectionRef>? defaultValue,
]) {
  if (v3SiriLineRefDirectionRef == null) {
    return defaultValue;
  }

  return v3SiriLineRefDirectionRef
      .map((e) => v3SiriLineRefDirectionRefFromJson(e))
      .toList();
}

int? v3DynamoDbTimetableTransportTypeNullableToJson(
  enums.V3DynamoDbTimetableTransportType? v3DynamoDbTimetableTransportType,
) {
  return v3DynamoDbTimetableTransportType?.value;
}

int? v3DynamoDbTimetableTransportTypeToJson(
  enums.V3DynamoDbTimetableTransportType v3DynamoDbTimetableTransportType,
) {
  return v3DynamoDbTimetableTransportType.value;
}

enums.V3DynamoDbTimetableTransportType v3DynamoDbTimetableTransportTypeFromJson(
  Object? v3DynamoDbTimetableTransportType, [
  enums.V3DynamoDbTimetableTransportType? defaultValue,
]) {
  return enums.V3DynamoDbTimetableTransportType.values.firstWhereOrNull(
        (e) => e.value == v3DynamoDbTimetableTransportType,
      ) ??
      defaultValue ??
      enums.V3DynamoDbTimetableTransportType.swaggerGeneratedUnknown;
}

enums.V3DynamoDbTimetableTransportType?
v3DynamoDbTimetableTransportTypeNullableFromJson(
  Object? v3DynamoDbTimetableTransportType, [
  enums.V3DynamoDbTimetableTransportType? defaultValue,
]) {
  if (v3DynamoDbTimetableTransportType == null) {
    return null;
  }
  return enums.V3DynamoDbTimetableTransportType.values.firstWhereOrNull(
        (e) => e.value == v3DynamoDbTimetableTransportType,
      ) ??
      defaultValue;
}

String v3DynamoDbTimetableTransportTypeExplodedListToJson(
  List<enums.V3DynamoDbTimetableTransportType>?
  v3DynamoDbTimetableTransportType,
) {
  return v3DynamoDbTimetableTransportType?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3DynamoDbTimetableTransportTypeListToJson(
  List<enums.V3DynamoDbTimetableTransportType>?
  v3DynamoDbTimetableTransportType,
) {
  if (v3DynamoDbTimetableTransportType == null) {
    return [];
  }

  return v3DynamoDbTimetableTransportType.map((e) => e.value!).toList();
}

List<enums.V3DynamoDbTimetableTransportType>
v3DynamoDbTimetableTransportTypeListFromJson(
  List? v3DynamoDbTimetableTransportType, [
  List<enums.V3DynamoDbTimetableTransportType>? defaultValue,
]) {
  if (v3DynamoDbTimetableTransportType == null) {
    return defaultValue ?? [];
  }

  return v3DynamoDbTimetableTransportType
      .map((e) => v3DynamoDbTimetableTransportTypeFromJson(e))
      .toList();
}

List<enums.V3DynamoDbTimetableTransportType>?
v3DynamoDbTimetableTransportTypeNullableListFromJson(
  List? v3DynamoDbTimetableTransportType, [
  List<enums.V3DynamoDbTimetableTransportType>? defaultValue,
]) {
  if (v3DynamoDbTimetableTransportType == null) {
    return defaultValue;
  }

  return v3DynamoDbTimetableTransportType
      .map((e) => v3DynamoDbTimetableTransportTypeFromJson(e))
      .toList();
}

int? v3SiriDownstreamSubscriptionMessageTypeNullableToJson(
  enums.V3SiriDownstreamSubscriptionMessageType?
  v3SiriDownstreamSubscriptionMessageType,
) {
  return v3SiriDownstreamSubscriptionMessageType?.value;
}

int? v3SiriDownstreamSubscriptionMessageTypeToJson(
  enums.V3SiriDownstreamSubscriptionMessageType
  v3SiriDownstreamSubscriptionMessageType,
) {
  return v3SiriDownstreamSubscriptionMessageType.value;
}

enums.V3SiriDownstreamSubscriptionMessageType
v3SiriDownstreamSubscriptionMessageTypeFromJson(
  Object? v3SiriDownstreamSubscriptionMessageType, [
  enums.V3SiriDownstreamSubscriptionMessageType? defaultValue,
]) {
  return enums.V3SiriDownstreamSubscriptionMessageType.values.firstWhereOrNull(
        (e) => e.value == v3SiriDownstreamSubscriptionMessageType,
      ) ??
      defaultValue ??
      enums.V3SiriDownstreamSubscriptionMessageType.swaggerGeneratedUnknown;
}

enums.V3SiriDownstreamSubscriptionMessageType?
v3SiriDownstreamSubscriptionMessageTypeNullableFromJson(
  Object? v3SiriDownstreamSubscriptionMessageType, [
  enums.V3SiriDownstreamSubscriptionMessageType? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionMessageType == null) {
    return null;
  }
  return enums.V3SiriDownstreamSubscriptionMessageType.values.firstWhereOrNull(
        (e) => e.value == v3SiriDownstreamSubscriptionMessageType,
      ) ??
      defaultValue;
}

String v3SiriDownstreamSubscriptionMessageTypeExplodedListToJson(
  List<enums.V3SiriDownstreamSubscriptionMessageType>?
  v3SiriDownstreamSubscriptionMessageType,
) {
  return v3SiriDownstreamSubscriptionMessageType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3SiriDownstreamSubscriptionMessageTypeListToJson(
  List<enums.V3SiriDownstreamSubscriptionMessageType>?
  v3SiriDownstreamSubscriptionMessageType,
) {
  if (v3SiriDownstreamSubscriptionMessageType == null) {
    return [];
  }

  return v3SiriDownstreamSubscriptionMessageType.map((e) => e.value!).toList();
}

List<enums.V3SiriDownstreamSubscriptionMessageType>
v3SiriDownstreamSubscriptionMessageTypeListFromJson(
  List? v3SiriDownstreamSubscriptionMessageType, [
  List<enums.V3SiriDownstreamSubscriptionMessageType>? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionMessageType == null) {
    return defaultValue ?? [];
  }

  return v3SiriDownstreamSubscriptionMessageType
      .map((e) => v3SiriDownstreamSubscriptionMessageTypeFromJson(e))
      .toList();
}

List<enums.V3SiriDownstreamSubscriptionMessageType>?
v3SiriDownstreamSubscriptionMessageTypeNullableListFromJson(
  List? v3SiriDownstreamSubscriptionMessageType, [
  List<enums.V3SiriDownstreamSubscriptionMessageType>? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionMessageType == null) {
    return defaultValue;
  }

  return v3SiriDownstreamSubscriptionMessageType
      .map((e) => v3SiriDownstreamSubscriptionMessageTypeFromJson(e))
      .toList();
}

int? v3SiriDownstreamSubscriptionSiriFormatNullableToJson(
  enums.V3SiriDownstreamSubscriptionSiriFormat?
  v3SiriDownstreamSubscriptionSiriFormat,
) {
  return v3SiriDownstreamSubscriptionSiriFormat?.value;
}

int? v3SiriDownstreamSubscriptionSiriFormatToJson(
  enums.V3SiriDownstreamSubscriptionSiriFormat
  v3SiriDownstreamSubscriptionSiriFormat,
) {
  return v3SiriDownstreamSubscriptionSiriFormat.value;
}

enums.V3SiriDownstreamSubscriptionSiriFormat
v3SiriDownstreamSubscriptionSiriFormatFromJson(
  Object? v3SiriDownstreamSubscriptionSiriFormat, [
  enums.V3SiriDownstreamSubscriptionSiriFormat? defaultValue,
]) {
  return enums.V3SiriDownstreamSubscriptionSiriFormat.values.firstWhereOrNull(
        (e) => e.value == v3SiriDownstreamSubscriptionSiriFormat,
      ) ??
      defaultValue ??
      enums.V3SiriDownstreamSubscriptionSiriFormat.swaggerGeneratedUnknown;
}

enums.V3SiriDownstreamSubscriptionSiriFormat?
v3SiriDownstreamSubscriptionSiriFormatNullableFromJson(
  Object? v3SiriDownstreamSubscriptionSiriFormat, [
  enums.V3SiriDownstreamSubscriptionSiriFormat? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionSiriFormat == null) {
    return null;
  }
  return enums.V3SiriDownstreamSubscriptionSiriFormat.values.firstWhereOrNull(
        (e) => e.value == v3SiriDownstreamSubscriptionSiriFormat,
      ) ??
      defaultValue;
}

String v3SiriDownstreamSubscriptionSiriFormatExplodedListToJson(
  List<enums.V3SiriDownstreamSubscriptionSiriFormat>?
  v3SiriDownstreamSubscriptionSiriFormat,
) {
  return v3SiriDownstreamSubscriptionSiriFormat
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3SiriDownstreamSubscriptionSiriFormatListToJson(
  List<enums.V3SiriDownstreamSubscriptionSiriFormat>?
  v3SiriDownstreamSubscriptionSiriFormat,
) {
  if (v3SiriDownstreamSubscriptionSiriFormat == null) {
    return [];
  }

  return v3SiriDownstreamSubscriptionSiriFormat.map((e) => e.value!).toList();
}

List<enums.V3SiriDownstreamSubscriptionSiriFormat>
v3SiriDownstreamSubscriptionSiriFormatListFromJson(
  List? v3SiriDownstreamSubscriptionSiriFormat, [
  List<enums.V3SiriDownstreamSubscriptionSiriFormat>? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionSiriFormat == null) {
    return defaultValue ?? [];
  }

  return v3SiriDownstreamSubscriptionSiriFormat
      .map((e) => v3SiriDownstreamSubscriptionSiriFormatFromJson(e))
      .toList();
}

List<enums.V3SiriDownstreamSubscriptionSiriFormat>?
v3SiriDownstreamSubscriptionSiriFormatNullableListFromJson(
  List? v3SiriDownstreamSubscriptionSiriFormat, [
  List<enums.V3SiriDownstreamSubscriptionSiriFormat>? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionSiriFormat == null) {
    return defaultValue;
  }

  return v3SiriDownstreamSubscriptionSiriFormat
      .map((e) => v3SiriDownstreamSubscriptionSiriFormatFromJson(e))
      .toList();
}

int? v3SiriDownstreamSubscriptionTopicDirectionRefNullableToJson(
  enums.V3SiriDownstreamSubscriptionTopicDirectionRef?
  v3SiriDownstreamSubscriptionTopicDirectionRef,
) {
  return v3SiriDownstreamSubscriptionTopicDirectionRef?.value;
}

int? v3SiriDownstreamSubscriptionTopicDirectionRefToJson(
  enums.V3SiriDownstreamSubscriptionTopicDirectionRef
  v3SiriDownstreamSubscriptionTopicDirectionRef,
) {
  return v3SiriDownstreamSubscriptionTopicDirectionRef.value;
}

enums.V3SiriDownstreamSubscriptionTopicDirectionRef
v3SiriDownstreamSubscriptionTopicDirectionRefFromJson(
  Object? v3SiriDownstreamSubscriptionTopicDirectionRef, [
  enums.V3SiriDownstreamSubscriptionTopicDirectionRef? defaultValue,
]) {
  return enums.V3SiriDownstreamSubscriptionTopicDirectionRef.values
          .firstWhereOrNull(
            (e) => e.value == v3SiriDownstreamSubscriptionTopicDirectionRef,
          ) ??
      defaultValue ??
      enums
          .V3SiriDownstreamSubscriptionTopicDirectionRef
          .swaggerGeneratedUnknown;
}

enums.V3SiriDownstreamSubscriptionTopicDirectionRef?
v3SiriDownstreamSubscriptionTopicDirectionRefNullableFromJson(
  Object? v3SiriDownstreamSubscriptionTopicDirectionRef, [
  enums.V3SiriDownstreamSubscriptionTopicDirectionRef? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionTopicDirectionRef == null) {
    return null;
  }
  return enums.V3SiriDownstreamSubscriptionTopicDirectionRef.values
          .firstWhereOrNull(
            (e) => e.value == v3SiriDownstreamSubscriptionTopicDirectionRef,
          ) ??
      defaultValue;
}

String v3SiriDownstreamSubscriptionTopicDirectionRefExplodedListToJson(
  List<enums.V3SiriDownstreamSubscriptionTopicDirectionRef>?
  v3SiriDownstreamSubscriptionTopicDirectionRef,
) {
  return v3SiriDownstreamSubscriptionTopicDirectionRef
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3SiriDownstreamSubscriptionTopicDirectionRefListToJson(
  List<enums.V3SiriDownstreamSubscriptionTopicDirectionRef>?
  v3SiriDownstreamSubscriptionTopicDirectionRef,
) {
  if (v3SiriDownstreamSubscriptionTopicDirectionRef == null) {
    return [];
  }

  return v3SiriDownstreamSubscriptionTopicDirectionRef
      .map((e) => e.value!)
      .toList();
}

List<enums.V3SiriDownstreamSubscriptionTopicDirectionRef>
v3SiriDownstreamSubscriptionTopicDirectionRefListFromJson(
  List? v3SiriDownstreamSubscriptionTopicDirectionRef, [
  List<enums.V3SiriDownstreamSubscriptionTopicDirectionRef>? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionTopicDirectionRef == null) {
    return defaultValue ?? [];
  }

  return v3SiriDownstreamSubscriptionTopicDirectionRef
      .map((e) => v3SiriDownstreamSubscriptionTopicDirectionRefFromJson(e))
      .toList();
}

List<enums.V3SiriDownstreamSubscriptionTopicDirectionRef>?
v3SiriDownstreamSubscriptionTopicDirectionRefNullableListFromJson(
  List? v3SiriDownstreamSubscriptionTopicDirectionRef, [
  List<enums.V3SiriDownstreamSubscriptionTopicDirectionRef>? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionTopicDirectionRef == null) {
    return defaultValue;
  }

  return v3SiriDownstreamSubscriptionTopicDirectionRef
      .map((e) => v3SiriDownstreamSubscriptionTopicDirectionRefFromJson(e))
      .toList();
}

int? v3SiriDownstreamSubscriptionTopicRouteTypeNullableToJson(
  enums.V3SiriDownstreamSubscriptionTopicRouteType?
  v3SiriDownstreamSubscriptionTopicRouteType,
) {
  return v3SiriDownstreamSubscriptionTopicRouteType?.value;
}

int? v3SiriDownstreamSubscriptionTopicRouteTypeToJson(
  enums.V3SiriDownstreamSubscriptionTopicRouteType
  v3SiriDownstreamSubscriptionTopicRouteType,
) {
  return v3SiriDownstreamSubscriptionTopicRouteType.value;
}

enums.V3SiriDownstreamSubscriptionTopicRouteType
v3SiriDownstreamSubscriptionTopicRouteTypeFromJson(
  Object? v3SiriDownstreamSubscriptionTopicRouteType, [
  enums.V3SiriDownstreamSubscriptionTopicRouteType? defaultValue,
]) {
  return enums.V3SiriDownstreamSubscriptionTopicRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3SiriDownstreamSubscriptionTopicRouteType,
          ) ??
      defaultValue ??
      enums.V3SiriDownstreamSubscriptionTopicRouteType.swaggerGeneratedUnknown;
}

enums.V3SiriDownstreamSubscriptionTopicRouteType?
v3SiriDownstreamSubscriptionTopicRouteTypeNullableFromJson(
  Object? v3SiriDownstreamSubscriptionTopicRouteType, [
  enums.V3SiriDownstreamSubscriptionTopicRouteType? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionTopicRouteType == null) {
    return null;
  }
  return enums.V3SiriDownstreamSubscriptionTopicRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3SiriDownstreamSubscriptionTopicRouteType,
          ) ??
      defaultValue;
}

String v3SiriDownstreamSubscriptionTopicRouteTypeExplodedListToJson(
  List<enums.V3SiriDownstreamSubscriptionTopicRouteType>?
  v3SiriDownstreamSubscriptionTopicRouteType,
) {
  return v3SiriDownstreamSubscriptionTopicRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3SiriDownstreamSubscriptionTopicRouteTypeListToJson(
  List<enums.V3SiriDownstreamSubscriptionTopicRouteType>?
  v3SiriDownstreamSubscriptionTopicRouteType,
) {
  if (v3SiriDownstreamSubscriptionTopicRouteType == null) {
    return [];
  }

  return v3SiriDownstreamSubscriptionTopicRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3SiriDownstreamSubscriptionTopicRouteType>
v3SiriDownstreamSubscriptionTopicRouteTypeListFromJson(
  List? v3SiriDownstreamSubscriptionTopicRouteType, [
  List<enums.V3SiriDownstreamSubscriptionTopicRouteType>? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionTopicRouteType == null) {
    return defaultValue ?? [];
  }

  return v3SiriDownstreamSubscriptionTopicRouteType
      .map((e) => v3SiriDownstreamSubscriptionTopicRouteTypeFromJson(e))
      .toList();
}

List<enums.V3SiriDownstreamSubscriptionTopicRouteType>?
v3SiriDownstreamSubscriptionTopicRouteTypeNullableListFromJson(
  List? v3SiriDownstreamSubscriptionTopicRouteType, [
  List<enums.V3SiriDownstreamSubscriptionTopicRouteType>? defaultValue,
]) {
  if (v3SiriDownstreamSubscriptionTopicRouteType == null) {
    return defaultValue;
  }

  return v3SiriDownstreamSubscriptionTopicRouteType
      .map((e) => v3SiriDownstreamSubscriptionTopicRouteTypeFromJson(e))
      .toList();
}

int? v3SiriProductionTimetableSubscriptionRequestSiriFormatNullableToJson(
  enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat?
  v3SiriProductionTimetableSubscriptionRequestSiriFormat,
) {
  return v3SiriProductionTimetableSubscriptionRequestSiriFormat?.value;
}

int? v3SiriProductionTimetableSubscriptionRequestSiriFormatToJson(
  enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat
  v3SiriProductionTimetableSubscriptionRequestSiriFormat,
) {
  return v3SiriProductionTimetableSubscriptionRequestSiriFormat.value;
}

enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat
v3SiriProductionTimetableSubscriptionRequestSiriFormatFromJson(
  Object? v3SiriProductionTimetableSubscriptionRequestSiriFormat, [
  enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat? defaultValue,
]) {
  return enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3SiriProductionTimetableSubscriptionRequestSiriFormat,
          ) ??
      defaultValue ??
      enums
          .V3SiriProductionTimetableSubscriptionRequestSiriFormat
          .swaggerGeneratedUnknown;
}

enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat?
v3SiriProductionTimetableSubscriptionRequestSiriFormatNullableFromJson(
  Object? v3SiriProductionTimetableSubscriptionRequestSiriFormat, [
  enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat? defaultValue,
]) {
  if (v3SiriProductionTimetableSubscriptionRequestSiriFormat == null) {
    return null;
  }
  return enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3SiriProductionTimetableSubscriptionRequestSiriFormat,
          ) ??
      defaultValue;
}

String v3SiriProductionTimetableSubscriptionRequestSiriFormatExplodedListToJson(
  List<enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat>?
  v3SiriProductionTimetableSubscriptionRequestSiriFormat,
) {
  return v3SiriProductionTimetableSubscriptionRequestSiriFormat
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3SiriProductionTimetableSubscriptionRequestSiriFormatListToJson(
  List<enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat>?
  v3SiriProductionTimetableSubscriptionRequestSiriFormat,
) {
  if (v3SiriProductionTimetableSubscriptionRequestSiriFormat == null) {
    return [];
  }

  return v3SiriProductionTimetableSubscriptionRequestSiriFormat
      .map((e) => e.value!)
      .toList();
}

List<enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat>
v3SiriProductionTimetableSubscriptionRequestSiriFormatListFromJson(
  List? v3SiriProductionTimetableSubscriptionRequestSiriFormat, [
  List<enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat>?
  defaultValue,
]) {
  if (v3SiriProductionTimetableSubscriptionRequestSiriFormat == null) {
    return defaultValue ?? [];
  }

  return v3SiriProductionTimetableSubscriptionRequestSiriFormat
      .map(
        (e) =>
            v3SiriProductionTimetableSubscriptionRequestSiriFormatFromJson(e),
      )
      .toList();
}

List<enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat>?
v3SiriProductionTimetableSubscriptionRequestSiriFormatNullableListFromJson(
  List? v3SiriProductionTimetableSubscriptionRequestSiriFormat, [
  List<enums.V3SiriProductionTimetableSubscriptionRequestSiriFormat>?
  defaultValue,
]) {
  if (v3SiriProductionTimetableSubscriptionRequestSiriFormat == null) {
    return defaultValue;
  }

  return v3SiriProductionTimetableSubscriptionRequestSiriFormat
      .map(
        (e) =>
            v3SiriProductionTimetableSubscriptionRequestSiriFormatFromJson(e),
      )
      .toList();
}

int? v3SiriSubscriptionTopicDirectionRefNullableToJson(
  enums.V3SiriSubscriptionTopicDirectionRef?
  v3SiriSubscriptionTopicDirectionRef,
) {
  return v3SiriSubscriptionTopicDirectionRef?.value;
}

int? v3SiriSubscriptionTopicDirectionRefToJson(
  enums.V3SiriSubscriptionTopicDirectionRef v3SiriSubscriptionTopicDirectionRef,
) {
  return v3SiriSubscriptionTopicDirectionRef.value;
}

enums.V3SiriSubscriptionTopicDirectionRef
v3SiriSubscriptionTopicDirectionRefFromJson(
  Object? v3SiriSubscriptionTopicDirectionRef, [
  enums.V3SiriSubscriptionTopicDirectionRef? defaultValue,
]) {
  return enums.V3SiriSubscriptionTopicDirectionRef.values.firstWhereOrNull(
        (e) => e.value == v3SiriSubscriptionTopicDirectionRef,
      ) ??
      defaultValue ??
      enums.V3SiriSubscriptionTopicDirectionRef.swaggerGeneratedUnknown;
}

enums.V3SiriSubscriptionTopicDirectionRef?
v3SiriSubscriptionTopicDirectionRefNullableFromJson(
  Object? v3SiriSubscriptionTopicDirectionRef, [
  enums.V3SiriSubscriptionTopicDirectionRef? defaultValue,
]) {
  if (v3SiriSubscriptionTopicDirectionRef == null) {
    return null;
  }
  return enums.V3SiriSubscriptionTopicDirectionRef.values.firstWhereOrNull(
        (e) => e.value == v3SiriSubscriptionTopicDirectionRef,
      ) ??
      defaultValue;
}

String v3SiriSubscriptionTopicDirectionRefExplodedListToJson(
  List<enums.V3SiriSubscriptionTopicDirectionRef>?
  v3SiriSubscriptionTopicDirectionRef,
) {
  return v3SiriSubscriptionTopicDirectionRef?.map((e) => e.value!).join(',') ??
      '';
}

List<int> v3SiriSubscriptionTopicDirectionRefListToJson(
  List<enums.V3SiriSubscriptionTopicDirectionRef>?
  v3SiriSubscriptionTopicDirectionRef,
) {
  if (v3SiriSubscriptionTopicDirectionRef == null) {
    return [];
  }

  return v3SiriSubscriptionTopicDirectionRef.map((e) => e.value!).toList();
}

List<enums.V3SiriSubscriptionTopicDirectionRef>
v3SiriSubscriptionTopicDirectionRefListFromJson(
  List? v3SiriSubscriptionTopicDirectionRef, [
  List<enums.V3SiriSubscriptionTopicDirectionRef>? defaultValue,
]) {
  if (v3SiriSubscriptionTopicDirectionRef == null) {
    return defaultValue ?? [];
  }

  return v3SiriSubscriptionTopicDirectionRef
      .map((e) => v3SiriSubscriptionTopicDirectionRefFromJson(e))
      .toList();
}

List<enums.V3SiriSubscriptionTopicDirectionRef>?
v3SiriSubscriptionTopicDirectionRefNullableListFromJson(
  List? v3SiriSubscriptionTopicDirectionRef, [
  List<enums.V3SiriSubscriptionTopicDirectionRef>? defaultValue,
]) {
  if (v3SiriSubscriptionTopicDirectionRef == null) {
    return defaultValue;
  }

  return v3SiriSubscriptionTopicDirectionRef
      .map((e) => v3SiriSubscriptionTopicDirectionRefFromJson(e))
      .toList();
}

int? v3SiriSubscriptionTopicRouteTypeNullableToJson(
  enums.V3SiriSubscriptionTopicRouteType? v3SiriSubscriptionTopicRouteType,
) {
  return v3SiriSubscriptionTopicRouteType?.value;
}

int? v3SiriSubscriptionTopicRouteTypeToJson(
  enums.V3SiriSubscriptionTopicRouteType v3SiriSubscriptionTopicRouteType,
) {
  return v3SiriSubscriptionTopicRouteType.value;
}

enums.V3SiriSubscriptionTopicRouteType v3SiriSubscriptionTopicRouteTypeFromJson(
  Object? v3SiriSubscriptionTopicRouteType, [
  enums.V3SiriSubscriptionTopicRouteType? defaultValue,
]) {
  return enums.V3SiriSubscriptionTopicRouteType.values.firstWhereOrNull(
        (e) => e.value == v3SiriSubscriptionTopicRouteType,
      ) ??
      defaultValue ??
      enums.V3SiriSubscriptionTopicRouteType.swaggerGeneratedUnknown;
}

enums.V3SiriSubscriptionTopicRouteType?
v3SiriSubscriptionTopicRouteTypeNullableFromJson(
  Object? v3SiriSubscriptionTopicRouteType, [
  enums.V3SiriSubscriptionTopicRouteType? defaultValue,
]) {
  if (v3SiriSubscriptionTopicRouteType == null) {
    return null;
  }
  return enums.V3SiriSubscriptionTopicRouteType.values.firstWhereOrNull(
        (e) => e.value == v3SiriSubscriptionTopicRouteType,
      ) ??
      defaultValue;
}

String v3SiriSubscriptionTopicRouteTypeExplodedListToJson(
  List<enums.V3SiriSubscriptionTopicRouteType>?
  v3SiriSubscriptionTopicRouteType,
) {
  return v3SiriSubscriptionTopicRouteType?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3SiriSubscriptionTopicRouteTypeListToJson(
  List<enums.V3SiriSubscriptionTopicRouteType>?
  v3SiriSubscriptionTopicRouteType,
) {
  if (v3SiriSubscriptionTopicRouteType == null) {
    return [];
  }

  return v3SiriSubscriptionTopicRouteType.map((e) => e.value!).toList();
}

List<enums.V3SiriSubscriptionTopicRouteType>
v3SiriSubscriptionTopicRouteTypeListFromJson(
  List? v3SiriSubscriptionTopicRouteType, [
  List<enums.V3SiriSubscriptionTopicRouteType>? defaultValue,
]) {
  if (v3SiriSubscriptionTopicRouteType == null) {
    return defaultValue ?? [];
  }

  return v3SiriSubscriptionTopicRouteType
      .map((e) => v3SiriSubscriptionTopicRouteTypeFromJson(e))
      .toList();
}

List<enums.V3SiriSubscriptionTopicRouteType>?
v3SiriSubscriptionTopicRouteTypeNullableListFromJson(
  List? v3SiriSubscriptionTopicRouteType, [
  List<enums.V3SiriSubscriptionTopicRouteType>? defaultValue,
]) {
  if (v3SiriSubscriptionTopicRouteType == null) {
    return defaultValue;
  }

  return v3SiriSubscriptionTopicRouteType
      .map((e) => v3SiriSubscriptionTopicRouteTypeFromJson(e))
      .toList();
}

int? v3SiriEstimatedTimetableSubscriptionRequestSiriFormatNullableToJson(
  enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat?
  v3SiriEstimatedTimetableSubscriptionRequestSiriFormat,
) {
  return v3SiriEstimatedTimetableSubscriptionRequestSiriFormat?.value;
}

int? v3SiriEstimatedTimetableSubscriptionRequestSiriFormatToJson(
  enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat
  v3SiriEstimatedTimetableSubscriptionRequestSiriFormat,
) {
  return v3SiriEstimatedTimetableSubscriptionRequestSiriFormat.value;
}

enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat
v3SiriEstimatedTimetableSubscriptionRequestSiriFormatFromJson(
  Object? v3SiriEstimatedTimetableSubscriptionRequestSiriFormat, [
  enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat? defaultValue,
]) {
  return enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3SiriEstimatedTimetableSubscriptionRequestSiriFormat,
          ) ??
      defaultValue ??
      enums
          .V3SiriEstimatedTimetableSubscriptionRequestSiriFormat
          .swaggerGeneratedUnknown;
}

enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat?
v3SiriEstimatedTimetableSubscriptionRequestSiriFormatNullableFromJson(
  Object? v3SiriEstimatedTimetableSubscriptionRequestSiriFormat, [
  enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat? defaultValue,
]) {
  if (v3SiriEstimatedTimetableSubscriptionRequestSiriFormat == null) {
    return null;
  }
  return enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3SiriEstimatedTimetableSubscriptionRequestSiriFormat,
          ) ??
      defaultValue;
}

String v3SiriEstimatedTimetableSubscriptionRequestSiriFormatExplodedListToJson(
  List<enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat>?
  v3SiriEstimatedTimetableSubscriptionRequestSiriFormat,
) {
  return v3SiriEstimatedTimetableSubscriptionRequestSiriFormat
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3SiriEstimatedTimetableSubscriptionRequestSiriFormatListToJson(
  List<enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat>?
  v3SiriEstimatedTimetableSubscriptionRequestSiriFormat,
) {
  if (v3SiriEstimatedTimetableSubscriptionRequestSiriFormat == null) {
    return [];
  }

  return v3SiriEstimatedTimetableSubscriptionRequestSiriFormat
      .map((e) => e.value!)
      .toList();
}

List<enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat>
v3SiriEstimatedTimetableSubscriptionRequestSiriFormatListFromJson(
  List? v3SiriEstimatedTimetableSubscriptionRequestSiriFormat, [
  List<enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat>?
  defaultValue,
]) {
  if (v3SiriEstimatedTimetableSubscriptionRequestSiriFormat == null) {
    return defaultValue ?? [];
  }

  return v3SiriEstimatedTimetableSubscriptionRequestSiriFormat
      .map(
        (e) => v3SiriEstimatedTimetableSubscriptionRequestSiriFormatFromJson(e),
      )
      .toList();
}

List<enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat>?
v3SiriEstimatedTimetableSubscriptionRequestSiriFormatNullableListFromJson(
  List? v3SiriEstimatedTimetableSubscriptionRequestSiriFormat, [
  List<enums.V3SiriEstimatedTimetableSubscriptionRequestSiriFormat>?
  defaultValue,
]) {
  if (v3SiriEstimatedTimetableSubscriptionRequestSiriFormat == null) {
    return defaultValue;
  }

  return v3SiriEstimatedTimetableSubscriptionRequestSiriFormat
      .map(
        (e) => v3SiriEstimatedTimetableSubscriptionRequestSiriFormatFromJson(e),
      )
      .toList();
}

String? v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeNullableToJson(
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType?
  v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType?.value;
}

String? v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeToJson(
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
  v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value;
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeFromJson(
  Object? v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType, [
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType? defaultValue,
]) {
  return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.values
          .firstWhereOrNull(
            (e) =>
                e.value == v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType,
          ) ??
      defaultValue ??
      enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
          .swaggerGeneratedUnknown;
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType?
v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeNullableFromJson(
  Object? v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType, [
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType? defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType == null) {
    return null;
  }
  return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.values
          .firstWhereOrNull(
            (e) =>
                e.value == v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType,
          ) ??
      defaultValue;
}

String v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeExplodedListToJson(
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType>?
  v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeListToJson(
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType>?
  v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType,
) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType == null) {
    return [];
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType>
v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeListFromJson(
  List? v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType, [
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType>?
  defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType == null) {
    return defaultValue ?? [];
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
      .map(
        (e) => v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType>?
v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeNullableListFromJson(
  List? v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType, [
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType>?
  defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType == null) {
    return defaultValue;
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
      .map(
        (e) => v3DeparturesRouteTypeRouteTypeStopStopIdGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

int? v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandNullableToJson(
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand?
  v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand?.value;
}

int? v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandToJson(
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand
  v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand.value;
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand
v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandFromJson(
  Object? v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand, [
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand? defaultValue,
]) {
  return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand.values
          .firstWhereOrNull(
            (e) => e.value == v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand,
          ) ??
      defaultValue ??
      enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand
          .swaggerGeneratedUnknown;
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand?
v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandNullableFromJson(
  Object? v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand, [
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand? defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand == null) {
    return null;
  }
  return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand.values
          .firstWhereOrNull(
            (e) => e.value == v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand,
          ) ??
      defaultValue;
}

String v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandExplodedListToJson(
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand>?
  v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandListToJson(
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand>?
  v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand,
) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand == null) {
    return [];
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand
      .map((e) => e.value!)
      .toList();
}

List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand>
v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandListFromJson(
  List? v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand, [
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand>? defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand == null) {
    return defaultValue ?? [];
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand
      .map((e) => v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandFromJson(e))
      .toList();
}

List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand>?
v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandNullableListFromJson(
  List? v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand, [
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand>? defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand == null) {
    return defaultValue;
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdGetExpand
      .map((e) => v3DeparturesRouteTypeRouteTypeStopStopIdGetExpandFromJson(e))
      .toList();
}

String?
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeNullableToJson(
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType?
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
      ?.value;
}

String? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeToJson(
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType.value;
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeFromJson(
  Object? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType, [
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType?
  defaultValue,
]) {
  return enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType,
          ) ??
      defaultValue ??
      enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
          .swaggerGeneratedUnknown;
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType?
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeNullableFromJson(
  Object? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType, [
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType?
  defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType ==
      null) {
    return null;
  }
  return enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType,
          ) ??
      defaultValue;
}

String
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeExplodedListToJson(
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType>?
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeListToJson(
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType>?
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType,
) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType ==
      null) {
    return [];
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType>
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeListFromJson(
  List? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType, [
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType>?
  defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType ==
      null) {
    return defaultValue ?? [];
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
      .map(
        (e) =>
            v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType>?
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeNullableListFromJson(
  List? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType, [
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType>?
  defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType ==
      null) {
    return defaultValue;
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType
      .map(
        (e) =>
            v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteTypeFromJson(
              e.toString(),
            ),
      )
      .toList();
}

int?
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandNullableToJson(
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand?
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand?.value;
}

int? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandToJson(
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand.value;
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandFromJson(
  Object? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand, [
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand?
  defaultValue,
]) {
  return enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand,
          ) ??
      defaultValue ??
      enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
          .swaggerGeneratedUnknown;
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand?
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandNullableFromJson(
  Object? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand, [
  enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand?
  defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand == null) {
    return null;
  }
  return enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand,
          ) ??
      defaultValue;
}

String
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandExplodedListToJson(
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand>?
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand,
) {
  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int>
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandListToJson(
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand>?
  v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand,
) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand == null) {
    return [];
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
      .map((e) => e.value!)
      .toList();
}

List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand>
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandListFromJson(
  List? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand, [
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand>?
  defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand == null) {
    return defaultValue ?? [];
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
      .map(
        (e) =>
            v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandFromJson(
              e,
            ),
      )
      .toList();
}

List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand>?
v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandNullableListFromJson(
  List? v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand, [
  List<enums.V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand>?
  defaultValue,
]) {
  if (v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand == null) {
    return defaultValue;
  }

  return v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand
      .map(
        (e) =>
            v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpandFromJson(
              e,
            ),
      )
      .toList();
}

String? v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeNullableToJson(
  enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType?
  v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType,
) {
  return v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType?.value;
}

String? v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeToJson(
  enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType
  v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType,
) {
  return v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType.value;
}

enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType
v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeFromJson(
  Object? v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType, [
  enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  return enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue ??
      enums
          .V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType
          .swaggerGeneratedUnknown;
}

enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType?
v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeNullableFromJson(
  Object? v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType, [
  enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  if (v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType == null) {
    return null;
  }
  return enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue;
}

String v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeExplodedListToJson(
  List<enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType>?
  v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType,
) {
  return v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeListToJson(
  List<enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType>?
  v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType,
) {
  if (v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType == null) {
    return [];
  }

  return v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType>
v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeListFromJson(
  List? v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType, [
  List<enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType>?
  defaultValue,
]) {
  if (v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue ?? [];
  }

  return v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType>?
v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeNullableListFromJson(
  List? v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType, [
  List<enums.V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType>?
  defaultValue,
]) {
  if (v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue;
  }

  return v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3DirectionsDirectionIdRouteTypeRouteTypeGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

int? v3DisruptionsGetRouteTypesNullableToJson(
  enums.V3DisruptionsGetRouteTypes? v3DisruptionsGetRouteTypes,
) {
  return v3DisruptionsGetRouteTypes?.value;
}

int? v3DisruptionsGetRouteTypesToJson(
  enums.V3DisruptionsGetRouteTypes v3DisruptionsGetRouteTypes,
) {
  return v3DisruptionsGetRouteTypes.value;
}

enums.V3DisruptionsGetRouteTypes v3DisruptionsGetRouteTypesFromJson(
  Object? v3DisruptionsGetRouteTypes, [
  enums.V3DisruptionsGetRouteTypes? defaultValue,
]) {
  return enums.V3DisruptionsGetRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3DisruptionsGetRouteTypes,
      ) ??
      defaultValue ??
      enums.V3DisruptionsGetRouteTypes.swaggerGeneratedUnknown;
}

enums.V3DisruptionsGetRouteTypes? v3DisruptionsGetRouteTypesNullableFromJson(
  Object? v3DisruptionsGetRouteTypes, [
  enums.V3DisruptionsGetRouteTypes? defaultValue,
]) {
  if (v3DisruptionsGetRouteTypes == null) {
    return null;
  }
  return enums.V3DisruptionsGetRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3DisruptionsGetRouteTypes,
      ) ??
      defaultValue;
}

String v3DisruptionsGetRouteTypesExplodedListToJson(
  List<enums.V3DisruptionsGetRouteTypes>? v3DisruptionsGetRouteTypes,
) {
  return v3DisruptionsGetRouteTypes?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3DisruptionsGetRouteTypesListToJson(
  List<enums.V3DisruptionsGetRouteTypes>? v3DisruptionsGetRouteTypes,
) {
  if (v3DisruptionsGetRouteTypes == null) {
    return [];
  }

  return v3DisruptionsGetRouteTypes.map((e) => e.value!).toList();
}

List<enums.V3DisruptionsGetRouteTypes> v3DisruptionsGetRouteTypesListFromJson(
  List? v3DisruptionsGetRouteTypes, [
  List<enums.V3DisruptionsGetRouteTypes>? defaultValue,
]) {
  if (v3DisruptionsGetRouteTypes == null) {
    return defaultValue ?? [];
  }

  return v3DisruptionsGetRouteTypes
      .map((e) => v3DisruptionsGetRouteTypesFromJson(e))
      .toList();
}

List<enums.V3DisruptionsGetRouteTypes>?
v3DisruptionsGetRouteTypesNullableListFromJson(
  List? v3DisruptionsGetRouteTypes, [
  List<enums.V3DisruptionsGetRouteTypes>? defaultValue,
]) {
  if (v3DisruptionsGetRouteTypes == null) {
    return defaultValue;
  }

  return v3DisruptionsGetRouteTypes
      .map((e) => v3DisruptionsGetRouteTypesFromJson(e))
      .toList();
}

int? v3DisruptionsGetDisruptionModesNullableToJson(
  enums.V3DisruptionsGetDisruptionModes? v3DisruptionsGetDisruptionModes,
) {
  return v3DisruptionsGetDisruptionModes?.value;
}

int? v3DisruptionsGetDisruptionModesToJson(
  enums.V3DisruptionsGetDisruptionModes v3DisruptionsGetDisruptionModes,
) {
  return v3DisruptionsGetDisruptionModes.value;
}

enums.V3DisruptionsGetDisruptionModes v3DisruptionsGetDisruptionModesFromJson(
  Object? v3DisruptionsGetDisruptionModes, [
  enums.V3DisruptionsGetDisruptionModes? defaultValue,
]) {
  return enums.V3DisruptionsGetDisruptionModes.values.firstWhereOrNull(
        (e) => e.value == v3DisruptionsGetDisruptionModes,
      ) ??
      defaultValue ??
      enums.V3DisruptionsGetDisruptionModes.swaggerGeneratedUnknown;
}

enums.V3DisruptionsGetDisruptionModes?
v3DisruptionsGetDisruptionModesNullableFromJson(
  Object? v3DisruptionsGetDisruptionModes, [
  enums.V3DisruptionsGetDisruptionModes? defaultValue,
]) {
  if (v3DisruptionsGetDisruptionModes == null) {
    return null;
  }
  return enums.V3DisruptionsGetDisruptionModes.values.firstWhereOrNull(
        (e) => e.value == v3DisruptionsGetDisruptionModes,
      ) ??
      defaultValue;
}

String v3DisruptionsGetDisruptionModesExplodedListToJson(
  List<enums.V3DisruptionsGetDisruptionModes>? v3DisruptionsGetDisruptionModes,
) {
  return v3DisruptionsGetDisruptionModes?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3DisruptionsGetDisruptionModesListToJson(
  List<enums.V3DisruptionsGetDisruptionModes>? v3DisruptionsGetDisruptionModes,
) {
  if (v3DisruptionsGetDisruptionModes == null) {
    return [];
  }

  return v3DisruptionsGetDisruptionModes.map((e) => e.value!).toList();
}

List<enums.V3DisruptionsGetDisruptionModes>
v3DisruptionsGetDisruptionModesListFromJson(
  List? v3DisruptionsGetDisruptionModes, [
  List<enums.V3DisruptionsGetDisruptionModes>? defaultValue,
]) {
  if (v3DisruptionsGetDisruptionModes == null) {
    return defaultValue ?? [];
  }

  return v3DisruptionsGetDisruptionModes
      .map((e) => v3DisruptionsGetDisruptionModesFromJson(e))
      .toList();
}

List<enums.V3DisruptionsGetDisruptionModes>?
v3DisruptionsGetDisruptionModesNullableListFromJson(
  List? v3DisruptionsGetDisruptionModes, [
  List<enums.V3DisruptionsGetDisruptionModes>? defaultValue,
]) {
  if (v3DisruptionsGetDisruptionModes == null) {
    return defaultValue;
  }

  return v3DisruptionsGetDisruptionModes
      .map((e) => v3DisruptionsGetDisruptionModesFromJson(e))
      .toList();
}

String? v3DisruptionsGetDisruptionStatusNullableToJson(
  enums.V3DisruptionsGetDisruptionStatus? v3DisruptionsGetDisruptionStatus,
) {
  return v3DisruptionsGetDisruptionStatus?.value;
}

String? v3DisruptionsGetDisruptionStatusToJson(
  enums.V3DisruptionsGetDisruptionStatus v3DisruptionsGetDisruptionStatus,
) {
  return v3DisruptionsGetDisruptionStatus.value;
}

enums.V3DisruptionsGetDisruptionStatus v3DisruptionsGetDisruptionStatusFromJson(
  Object? v3DisruptionsGetDisruptionStatus, [
  enums.V3DisruptionsGetDisruptionStatus? defaultValue,
]) {
  return enums.V3DisruptionsGetDisruptionStatus.values.firstWhereOrNull(
        (e) => e.value == v3DisruptionsGetDisruptionStatus,
      ) ??
      defaultValue ??
      enums.V3DisruptionsGetDisruptionStatus.swaggerGeneratedUnknown;
}

enums.V3DisruptionsGetDisruptionStatus?
v3DisruptionsGetDisruptionStatusNullableFromJson(
  Object? v3DisruptionsGetDisruptionStatus, [
  enums.V3DisruptionsGetDisruptionStatus? defaultValue,
]) {
  if (v3DisruptionsGetDisruptionStatus == null) {
    return null;
  }
  return enums.V3DisruptionsGetDisruptionStatus.values.firstWhereOrNull(
        (e) => e.value == v3DisruptionsGetDisruptionStatus,
      ) ??
      defaultValue;
}

String v3DisruptionsGetDisruptionStatusExplodedListToJson(
  List<enums.V3DisruptionsGetDisruptionStatus>?
  v3DisruptionsGetDisruptionStatus,
) {
  return v3DisruptionsGetDisruptionStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> v3DisruptionsGetDisruptionStatusListToJson(
  List<enums.V3DisruptionsGetDisruptionStatus>?
  v3DisruptionsGetDisruptionStatus,
) {
  if (v3DisruptionsGetDisruptionStatus == null) {
    return [];
  }

  return v3DisruptionsGetDisruptionStatus.map((e) => e.value!).toList();
}

List<enums.V3DisruptionsGetDisruptionStatus>
v3DisruptionsGetDisruptionStatusListFromJson(
  List? v3DisruptionsGetDisruptionStatus, [
  List<enums.V3DisruptionsGetDisruptionStatus>? defaultValue,
]) {
  if (v3DisruptionsGetDisruptionStatus == null) {
    return defaultValue ?? [];
  }

  return v3DisruptionsGetDisruptionStatus
      .map((e) => v3DisruptionsGetDisruptionStatusFromJson(e.toString()))
      .toList();
}

List<enums.V3DisruptionsGetDisruptionStatus>?
v3DisruptionsGetDisruptionStatusNullableListFromJson(
  List? v3DisruptionsGetDisruptionStatus, [
  List<enums.V3DisruptionsGetDisruptionStatus>? defaultValue,
]) {
  if (v3DisruptionsGetDisruptionStatus == null) {
    return defaultValue;
  }

  return v3DisruptionsGetDisruptionStatus
      .map((e) => v3DisruptionsGetDisruptionStatusFromJson(e.toString()))
      .toList();
}

String? v3DisruptionsRouteRouteIdGetDisruptionStatusNullableToJson(
  enums.V3DisruptionsRouteRouteIdGetDisruptionStatus?
  v3DisruptionsRouteRouteIdGetDisruptionStatus,
) {
  return v3DisruptionsRouteRouteIdGetDisruptionStatus?.value;
}

String? v3DisruptionsRouteRouteIdGetDisruptionStatusToJson(
  enums.V3DisruptionsRouteRouteIdGetDisruptionStatus
  v3DisruptionsRouteRouteIdGetDisruptionStatus,
) {
  return v3DisruptionsRouteRouteIdGetDisruptionStatus.value;
}

enums.V3DisruptionsRouteRouteIdGetDisruptionStatus
v3DisruptionsRouteRouteIdGetDisruptionStatusFromJson(
  Object? v3DisruptionsRouteRouteIdGetDisruptionStatus, [
  enums.V3DisruptionsRouteRouteIdGetDisruptionStatus? defaultValue,
]) {
  return enums.V3DisruptionsRouteRouteIdGetDisruptionStatus.values
          .firstWhereOrNull(
            (e) => e.value == v3DisruptionsRouteRouteIdGetDisruptionStatus,
          ) ??
      defaultValue ??
      enums
          .V3DisruptionsRouteRouteIdGetDisruptionStatus
          .swaggerGeneratedUnknown;
}

enums.V3DisruptionsRouteRouteIdGetDisruptionStatus?
v3DisruptionsRouteRouteIdGetDisruptionStatusNullableFromJson(
  Object? v3DisruptionsRouteRouteIdGetDisruptionStatus, [
  enums.V3DisruptionsRouteRouteIdGetDisruptionStatus? defaultValue,
]) {
  if (v3DisruptionsRouteRouteIdGetDisruptionStatus == null) {
    return null;
  }
  return enums.V3DisruptionsRouteRouteIdGetDisruptionStatus.values
          .firstWhereOrNull(
            (e) => e.value == v3DisruptionsRouteRouteIdGetDisruptionStatus,
          ) ??
      defaultValue;
}

String v3DisruptionsRouteRouteIdGetDisruptionStatusExplodedListToJson(
  List<enums.V3DisruptionsRouteRouteIdGetDisruptionStatus>?
  v3DisruptionsRouteRouteIdGetDisruptionStatus,
) {
  return v3DisruptionsRouteRouteIdGetDisruptionStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3DisruptionsRouteRouteIdGetDisruptionStatusListToJson(
  List<enums.V3DisruptionsRouteRouteIdGetDisruptionStatus>?
  v3DisruptionsRouteRouteIdGetDisruptionStatus,
) {
  if (v3DisruptionsRouteRouteIdGetDisruptionStatus == null) {
    return [];
  }

  return v3DisruptionsRouteRouteIdGetDisruptionStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.V3DisruptionsRouteRouteIdGetDisruptionStatus>
v3DisruptionsRouteRouteIdGetDisruptionStatusListFromJson(
  List? v3DisruptionsRouteRouteIdGetDisruptionStatus, [
  List<enums.V3DisruptionsRouteRouteIdGetDisruptionStatus>? defaultValue,
]) {
  if (v3DisruptionsRouteRouteIdGetDisruptionStatus == null) {
    return defaultValue ?? [];
  }

  return v3DisruptionsRouteRouteIdGetDisruptionStatus
      .map(
        (e) =>
            v3DisruptionsRouteRouteIdGetDisruptionStatusFromJson(e.toString()),
      )
      .toList();
}

List<enums.V3DisruptionsRouteRouteIdGetDisruptionStatus>?
v3DisruptionsRouteRouteIdGetDisruptionStatusNullableListFromJson(
  List? v3DisruptionsRouteRouteIdGetDisruptionStatus, [
  List<enums.V3DisruptionsRouteRouteIdGetDisruptionStatus>? defaultValue,
]) {
  if (v3DisruptionsRouteRouteIdGetDisruptionStatus == null) {
    return defaultValue;
  }

  return v3DisruptionsRouteRouteIdGetDisruptionStatus
      .map(
        (e) =>
            v3DisruptionsRouteRouteIdGetDisruptionStatusFromJson(e.toString()),
      )
      .toList();
}

String? v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusNullableToJson(
  enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus?
  v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus,
) {
  return v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus?.value;
}

String? v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusToJson(
  enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus
  v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus,
) {
  return v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus.value;
}

enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus
v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusFromJson(
  Object? v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus, [
  enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus? defaultValue,
]) {
  return enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus,
          ) ??
      defaultValue ??
      enums
          .V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus
          .swaggerGeneratedUnknown;
}

enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus?
v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusNullableFromJson(
  Object? v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus, [
  enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus? defaultValue,
]) {
  if (v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus == null) {
    return null;
  }
  return enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus,
          ) ??
      defaultValue;
}

String v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusExplodedListToJson(
  List<enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus>?
  v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus,
) {
  return v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusListToJson(
  List<enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus>?
  v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus,
) {
  if (v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus == null) {
    return [];
  }

  return v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus>
v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusListFromJson(
  List? v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus, [
  List<enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus>?
  defaultValue,
]) {
  if (v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus == null) {
    return defaultValue ?? [];
  }

  return v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus
      .map(
        (e) => v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus>?
v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusNullableListFromJson(
  List? v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus, [
  List<enums.V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus>?
  defaultValue,
]) {
  if (v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus == null) {
    return defaultValue;
  }

  return v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus
      .map(
        (e) => v3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatusFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v3DisruptionsStopStopIdGetDisruptionStatusNullableToJson(
  enums.V3DisruptionsStopStopIdGetDisruptionStatus?
  v3DisruptionsStopStopIdGetDisruptionStatus,
) {
  return v3DisruptionsStopStopIdGetDisruptionStatus?.value;
}

String? v3DisruptionsStopStopIdGetDisruptionStatusToJson(
  enums.V3DisruptionsStopStopIdGetDisruptionStatus
  v3DisruptionsStopStopIdGetDisruptionStatus,
) {
  return v3DisruptionsStopStopIdGetDisruptionStatus.value;
}

enums.V3DisruptionsStopStopIdGetDisruptionStatus
v3DisruptionsStopStopIdGetDisruptionStatusFromJson(
  Object? v3DisruptionsStopStopIdGetDisruptionStatus, [
  enums.V3DisruptionsStopStopIdGetDisruptionStatus? defaultValue,
]) {
  return enums.V3DisruptionsStopStopIdGetDisruptionStatus.values
          .firstWhereOrNull(
            (e) => e.value == v3DisruptionsStopStopIdGetDisruptionStatus,
          ) ??
      defaultValue ??
      enums.V3DisruptionsStopStopIdGetDisruptionStatus.swaggerGeneratedUnknown;
}

enums.V3DisruptionsStopStopIdGetDisruptionStatus?
v3DisruptionsStopStopIdGetDisruptionStatusNullableFromJson(
  Object? v3DisruptionsStopStopIdGetDisruptionStatus, [
  enums.V3DisruptionsStopStopIdGetDisruptionStatus? defaultValue,
]) {
  if (v3DisruptionsStopStopIdGetDisruptionStatus == null) {
    return null;
  }
  return enums.V3DisruptionsStopStopIdGetDisruptionStatus.values
          .firstWhereOrNull(
            (e) => e.value == v3DisruptionsStopStopIdGetDisruptionStatus,
          ) ??
      defaultValue;
}

String v3DisruptionsStopStopIdGetDisruptionStatusExplodedListToJson(
  List<enums.V3DisruptionsStopStopIdGetDisruptionStatus>?
  v3DisruptionsStopStopIdGetDisruptionStatus,
) {
  return v3DisruptionsStopStopIdGetDisruptionStatus
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3DisruptionsStopStopIdGetDisruptionStatusListToJson(
  List<enums.V3DisruptionsStopStopIdGetDisruptionStatus>?
  v3DisruptionsStopStopIdGetDisruptionStatus,
) {
  if (v3DisruptionsStopStopIdGetDisruptionStatus == null) {
    return [];
  }

  return v3DisruptionsStopStopIdGetDisruptionStatus
      .map((e) => e.value!)
      .toList();
}

List<enums.V3DisruptionsStopStopIdGetDisruptionStatus>
v3DisruptionsStopStopIdGetDisruptionStatusListFromJson(
  List? v3DisruptionsStopStopIdGetDisruptionStatus, [
  List<enums.V3DisruptionsStopStopIdGetDisruptionStatus>? defaultValue,
]) {
  if (v3DisruptionsStopStopIdGetDisruptionStatus == null) {
    return defaultValue ?? [];
  }

  return v3DisruptionsStopStopIdGetDisruptionStatus
      .map(
        (e) => v3DisruptionsStopStopIdGetDisruptionStatusFromJson(e.toString()),
      )
      .toList();
}

List<enums.V3DisruptionsStopStopIdGetDisruptionStatus>?
v3DisruptionsStopStopIdGetDisruptionStatusNullableListFromJson(
  List? v3DisruptionsStopStopIdGetDisruptionStatus, [
  List<enums.V3DisruptionsStopStopIdGetDisruptionStatus>? defaultValue,
]) {
  if (v3DisruptionsStopStopIdGetDisruptionStatus == null) {
    return defaultValue;
  }

  return v3DisruptionsStopStopIdGetDisruptionStatus
      .map(
        (e) => v3DisruptionsStopStopIdGetDisruptionStatusFromJson(e.toString()),
      )
      .toList();
}

int?
v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesNullableToJson(
  enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes?
  v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes,
) {
  return v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
      ?.value;
}

int? v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesToJson(
  enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
  v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes,
) {
  return v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes.value;
}

enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesFromJson(
  Object? v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes, [
  enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes?
  defaultValue,
]) {
  return enums
          .V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes,
          ) ??
      defaultValue ??
      enums
          .V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
          .swaggerGeneratedUnknown;
}

enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes?
v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesNullableFromJson(
  Object? v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes, [
  enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes?
  defaultValue,
]) {
  if (v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes ==
      null) {
    return null;
  }
  return enums
          .V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes,
          ) ??
      defaultValue;
}

String
v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesExplodedListToJson(
  List<enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes>?
  v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes,
) {
  return v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int>
v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesListToJson(
  List<enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes>?
  v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes,
) {
  if (v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes ==
      null) {
    return [];
  }

  return v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes>
v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesListFromJson(
  List? v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes, [
  List<enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes>?
  defaultValue,
]) {
  if (v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes ==
      null) {
    return defaultValue ?? [];
  }

  return v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
      .map(
        (e) =>
            v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesFromJson(
              e,
            ),
      )
      .toList();
}

List<enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes>?
v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesNullableListFromJson(
  List? v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes, [
  List<enums.V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes>?
  defaultValue,
]) {
  if (v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes ==
      null) {
    return defaultValue;
  }

  return v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes
      .map(
        (e) =>
            v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypesFromJson(
              e,
            ),
      )
      .toList();
}

String? v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeNullableToJson(
  enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType?
  v3PatternRunRunRefRouteTypeRouteTypeGetRouteType,
) {
  return v3PatternRunRunRefRouteTypeRouteTypeGetRouteType?.value;
}

String? v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeToJson(
  enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType
  v3PatternRunRunRefRouteTypeRouteTypeGetRouteType,
) {
  return v3PatternRunRunRefRouteTypeRouteTypeGetRouteType.value;
}

enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType
v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeFromJson(
  Object? v3PatternRunRunRefRouteTypeRouteTypeGetRouteType, [
  enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  return enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3PatternRunRunRefRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue ??
      enums
          .V3PatternRunRunRefRouteTypeRouteTypeGetRouteType
          .swaggerGeneratedUnknown;
}

enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType?
v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeNullableFromJson(
  Object? v3PatternRunRunRefRouteTypeRouteTypeGetRouteType, [
  enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  if (v3PatternRunRunRefRouteTypeRouteTypeGetRouteType == null) {
    return null;
  }
  return enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3PatternRunRunRefRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue;
}

String v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeExplodedListToJson(
  List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType>?
  v3PatternRunRunRefRouteTypeRouteTypeGetRouteType,
) {
  return v3PatternRunRunRefRouteTypeRouteTypeGetRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeListToJson(
  List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType>?
  v3PatternRunRunRefRouteTypeRouteTypeGetRouteType,
) {
  if (v3PatternRunRunRefRouteTypeRouteTypeGetRouteType == null) {
    return [];
  }

  return v3PatternRunRunRefRouteTypeRouteTypeGetRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType>
v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeListFromJson(
  List? v3PatternRunRunRefRouteTypeRouteTypeGetRouteType, [
  List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3PatternRunRunRefRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue ?? [];
  }

  return v3PatternRunRunRefRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType>?
v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeNullableListFromJson(
  List? v3PatternRunRunRefRouteTypeRouteTypeGetRouteType, [
  List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3PatternRunRunRefRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue;
  }

  return v3PatternRunRunRefRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3PatternRunRunRefRouteTypeRouteTypeGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

int? v3PatternRunRunRefRouteTypeRouteTypeGetExpandNullableToJson(
  enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand?
  v3PatternRunRunRefRouteTypeRouteTypeGetExpand,
) {
  return v3PatternRunRunRefRouteTypeRouteTypeGetExpand?.value;
}

int? v3PatternRunRunRefRouteTypeRouteTypeGetExpandToJson(
  enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand
  v3PatternRunRunRefRouteTypeRouteTypeGetExpand,
) {
  return v3PatternRunRunRefRouteTypeRouteTypeGetExpand.value;
}

enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand
v3PatternRunRunRefRouteTypeRouteTypeGetExpandFromJson(
  Object? v3PatternRunRunRefRouteTypeRouteTypeGetExpand, [
  enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand? defaultValue,
]) {
  return enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand.values
          .firstWhereOrNull(
            (e) => e.value == v3PatternRunRunRefRouteTypeRouteTypeGetExpand,
          ) ??
      defaultValue ??
      enums
          .V3PatternRunRunRefRouteTypeRouteTypeGetExpand
          .swaggerGeneratedUnknown;
}

enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand?
v3PatternRunRunRefRouteTypeRouteTypeGetExpandNullableFromJson(
  Object? v3PatternRunRunRefRouteTypeRouteTypeGetExpand, [
  enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand? defaultValue,
]) {
  if (v3PatternRunRunRefRouteTypeRouteTypeGetExpand == null) {
    return null;
  }
  return enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand.values
          .firstWhereOrNull(
            (e) => e.value == v3PatternRunRunRefRouteTypeRouteTypeGetExpand,
          ) ??
      defaultValue;
}

String v3PatternRunRunRefRouteTypeRouteTypeGetExpandExplodedListToJson(
  List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand>?
  v3PatternRunRunRefRouteTypeRouteTypeGetExpand,
) {
  return v3PatternRunRunRefRouteTypeRouteTypeGetExpand
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3PatternRunRunRefRouteTypeRouteTypeGetExpandListToJson(
  List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand>?
  v3PatternRunRunRefRouteTypeRouteTypeGetExpand,
) {
  if (v3PatternRunRunRefRouteTypeRouteTypeGetExpand == null) {
    return [];
  }

  return v3PatternRunRunRefRouteTypeRouteTypeGetExpand
      .map((e) => e.value!)
      .toList();
}

List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand>
v3PatternRunRunRefRouteTypeRouteTypeGetExpandListFromJson(
  List? v3PatternRunRunRefRouteTypeRouteTypeGetExpand, [
  List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand>? defaultValue,
]) {
  if (v3PatternRunRunRefRouteTypeRouteTypeGetExpand == null) {
    return defaultValue ?? [];
  }

  return v3PatternRunRunRefRouteTypeRouteTypeGetExpand
      .map((e) => v3PatternRunRunRefRouteTypeRouteTypeGetExpandFromJson(e))
      .toList();
}

List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand>?
v3PatternRunRunRefRouteTypeRouteTypeGetExpandNullableListFromJson(
  List? v3PatternRunRunRefRouteTypeRouteTypeGetExpand, [
  List<enums.V3PatternRunRunRefRouteTypeRouteTypeGetExpand>? defaultValue,
]) {
  if (v3PatternRunRunRefRouteTypeRouteTypeGetExpand == null) {
    return defaultValue;
  }

  return v3PatternRunRunRefRouteTypeRouteTypeGetExpand
      .map((e) => v3PatternRunRunRefRouteTypeRouteTypeGetExpandFromJson(e))
      .toList();
}

int? v3RoutesGetRouteTypesNullableToJson(
  enums.V3RoutesGetRouteTypes? v3RoutesGetRouteTypes,
) {
  return v3RoutesGetRouteTypes?.value;
}

int? v3RoutesGetRouteTypesToJson(
  enums.V3RoutesGetRouteTypes v3RoutesGetRouteTypes,
) {
  return v3RoutesGetRouteTypes.value;
}

enums.V3RoutesGetRouteTypes v3RoutesGetRouteTypesFromJson(
  Object? v3RoutesGetRouteTypes, [
  enums.V3RoutesGetRouteTypes? defaultValue,
]) {
  return enums.V3RoutesGetRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3RoutesGetRouteTypes,
      ) ??
      defaultValue ??
      enums.V3RoutesGetRouteTypes.swaggerGeneratedUnknown;
}

enums.V3RoutesGetRouteTypes? v3RoutesGetRouteTypesNullableFromJson(
  Object? v3RoutesGetRouteTypes, [
  enums.V3RoutesGetRouteTypes? defaultValue,
]) {
  if (v3RoutesGetRouteTypes == null) {
    return null;
  }
  return enums.V3RoutesGetRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3RoutesGetRouteTypes,
      ) ??
      defaultValue;
}

String v3RoutesGetRouteTypesExplodedListToJson(
  List<enums.V3RoutesGetRouteTypes>? v3RoutesGetRouteTypes,
) {
  return v3RoutesGetRouteTypes?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3RoutesGetRouteTypesListToJson(
  List<enums.V3RoutesGetRouteTypes>? v3RoutesGetRouteTypes,
) {
  if (v3RoutesGetRouteTypes == null) {
    return [];
  }

  return v3RoutesGetRouteTypes.map((e) => e.value!).toList();
}

List<enums.V3RoutesGetRouteTypes> v3RoutesGetRouteTypesListFromJson(
  List? v3RoutesGetRouteTypes, [
  List<enums.V3RoutesGetRouteTypes>? defaultValue,
]) {
  if (v3RoutesGetRouteTypes == null) {
    return defaultValue ?? [];
  }

  return v3RoutesGetRouteTypes
      .map((e) => v3RoutesGetRouteTypesFromJson(e))
      .toList();
}

List<enums.V3RoutesGetRouteTypes>? v3RoutesGetRouteTypesNullableListFromJson(
  List? v3RoutesGetRouteTypes, [
  List<enums.V3RoutesGetRouteTypes>? defaultValue,
]) {
  if (v3RoutesGetRouteTypes == null) {
    return defaultValue;
  }

  return v3RoutesGetRouteTypes
      .map((e) => v3RoutesGetRouteTypesFromJson(e))
      .toList();
}

int? v3RunsRouteRouteIdGetExpandNullableToJson(
  enums.V3RunsRouteRouteIdGetExpand? v3RunsRouteRouteIdGetExpand,
) {
  return v3RunsRouteRouteIdGetExpand?.value;
}

int? v3RunsRouteRouteIdGetExpandToJson(
  enums.V3RunsRouteRouteIdGetExpand v3RunsRouteRouteIdGetExpand,
) {
  return v3RunsRouteRouteIdGetExpand.value;
}

enums.V3RunsRouteRouteIdGetExpand v3RunsRouteRouteIdGetExpandFromJson(
  Object? v3RunsRouteRouteIdGetExpand, [
  enums.V3RunsRouteRouteIdGetExpand? defaultValue,
]) {
  return enums.V3RunsRouteRouteIdGetExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsRouteRouteIdGetExpand,
      ) ??
      defaultValue ??
      enums.V3RunsRouteRouteIdGetExpand.swaggerGeneratedUnknown;
}

enums.V3RunsRouteRouteIdGetExpand? v3RunsRouteRouteIdGetExpandNullableFromJson(
  Object? v3RunsRouteRouteIdGetExpand, [
  enums.V3RunsRouteRouteIdGetExpand? defaultValue,
]) {
  if (v3RunsRouteRouteIdGetExpand == null) {
    return null;
  }
  return enums.V3RunsRouteRouteIdGetExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsRouteRouteIdGetExpand,
      ) ??
      defaultValue;
}

String v3RunsRouteRouteIdGetExpandExplodedListToJson(
  List<enums.V3RunsRouteRouteIdGetExpand>? v3RunsRouteRouteIdGetExpand,
) {
  return v3RunsRouteRouteIdGetExpand?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3RunsRouteRouteIdGetExpandListToJson(
  List<enums.V3RunsRouteRouteIdGetExpand>? v3RunsRouteRouteIdGetExpand,
) {
  if (v3RunsRouteRouteIdGetExpand == null) {
    return [];
  }

  return v3RunsRouteRouteIdGetExpand.map((e) => e.value!).toList();
}

List<enums.V3RunsRouteRouteIdGetExpand> v3RunsRouteRouteIdGetExpandListFromJson(
  List? v3RunsRouteRouteIdGetExpand, [
  List<enums.V3RunsRouteRouteIdGetExpand>? defaultValue,
]) {
  if (v3RunsRouteRouteIdGetExpand == null) {
    return defaultValue ?? [];
  }

  return v3RunsRouteRouteIdGetExpand
      .map((e) => v3RunsRouteRouteIdGetExpandFromJson(e))
      .toList();
}

List<enums.V3RunsRouteRouteIdGetExpand>?
v3RunsRouteRouteIdGetExpandNullableListFromJson(
  List? v3RunsRouteRouteIdGetExpand, [
  List<enums.V3RunsRouteRouteIdGetExpand>? defaultValue,
]) {
  if (v3RunsRouteRouteIdGetExpand == null) {
    return defaultValue;
  }

  return v3RunsRouteRouteIdGetExpand
      .map((e) => v3RunsRouteRouteIdGetExpandFromJson(e))
      .toList();
}

String? v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeNullableToJson(
  enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType?
  v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType,
) {
  return v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType?.value;
}

String? v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeToJson(
  enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType
  v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType,
) {
  return v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType.value;
}

enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType
v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeFromJson(
  Object? v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType, [
  enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  return enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue ??
      enums
          .V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType
          .swaggerGeneratedUnknown;
}

enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType?
v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeNullableFromJson(
  Object? v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType, [
  enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  if (v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType == null) {
    return null;
  }
  return enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue;
}

String v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeExplodedListToJson(
  List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType>?
  v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType,
) {
  return v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeListToJson(
  List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType>?
  v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType,
) {
  if (v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType == null) {
    return [];
  }

  return v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType>
v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeListFromJson(
  List? v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType, [
  List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue ?? [];
  }

  return v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType>?
v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeNullableListFromJson(
  List? v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType, [
  List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue;
  }

  return v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3RunsRouteRouteIdRouteTypeRouteTypeGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

int? v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandNullableToJson(
  enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand?
  v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand,
) {
  return v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand?.value;
}

int? v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandToJson(
  enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand
  v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand,
) {
  return v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand.value;
}

enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand
v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandFromJson(
  Object? v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand, [
  enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand? defaultValue,
]) {
  return enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand.values
          .firstWhereOrNull(
            (e) => e.value == v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand,
          ) ??
      defaultValue ??
      enums
          .V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand
          .swaggerGeneratedUnknown;
}

enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand?
v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandNullableFromJson(
  Object? v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand, [
  enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand? defaultValue,
]) {
  if (v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand == null) {
    return null;
  }
  return enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand.values
          .firstWhereOrNull(
            (e) => e.value == v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand,
          ) ??
      defaultValue;
}

String v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandExplodedListToJson(
  List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand>?
  v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand,
) {
  return v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandListToJson(
  List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand>?
  v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand,
) {
  if (v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand == null) {
    return [];
  }

  return v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand
      .map((e) => e.value!)
      .toList();
}

List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand>
v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandListFromJson(
  List? v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand, [
  List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand>? defaultValue,
]) {
  if (v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand == null) {
    return defaultValue ?? [];
  }

  return v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand
      .map((e) => v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandFromJson(e))
      .toList();
}

List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand>?
v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandNullableListFromJson(
  List? v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand, [
  List<enums.V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand>? defaultValue,
]) {
  if (v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand == null) {
    return defaultValue;
  }

  return v3RunsRouteRouteIdRouteTypeRouteTypeGetExpand
      .map((e) => v3RunsRouteRouteIdRouteTypeRouteTypeGetExpandFromJson(e))
      .toList();
}

int? v3RunsRunRefGetExpandNullableToJson(
  enums.V3RunsRunRefGetExpand? v3RunsRunRefGetExpand,
) {
  return v3RunsRunRefGetExpand?.value;
}

int? v3RunsRunRefGetExpandToJson(
  enums.V3RunsRunRefGetExpand v3RunsRunRefGetExpand,
) {
  return v3RunsRunRefGetExpand.value;
}

enums.V3RunsRunRefGetExpand v3RunsRunRefGetExpandFromJson(
  Object? v3RunsRunRefGetExpand, [
  enums.V3RunsRunRefGetExpand? defaultValue,
]) {
  return enums.V3RunsRunRefGetExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsRunRefGetExpand,
      ) ??
      defaultValue ??
      enums.V3RunsRunRefGetExpand.swaggerGeneratedUnknown;
}

enums.V3RunsRunRefGetExpand? v3RunsRunRefGetExpandNullableFromJson(
  Object? v3RunsRunRefGetExpand, [
  enums.V3RunsRunRefGetExpand? defaultValue,
]) {
  if (v3RunsRunRefGetExpand == null) {
    return null;
  }
  return enums.V3RunsRunRefGetExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsRunRefGetExpand,
      ) ??
      defaultValue;
}

String v3RunsRunRefGetExpandExplodedListToJson(
  List<enums.V3RunsRunRefGetExpand>? v3RunsRunRefGetExpand,
) {
  return v3RunsRunRefGetExpand?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3RunsRunRefGetExpandListToJson(
  List<enums.V3RunsRunRefGetExpand>? v3RunsRunRefGetExpand,
) {
  if (v3RunsRunRefGetExpand == null) {
    return [];
  }

  return v3RunsRunRefGetExpand.map((e) => e.value!).toList();
}

List<enums.V3RunsRunRefGetExpand> v3RunsRunRefGetExpandListFromJson(
  List? v3RunsRunRefGetExpand, [
  List<enums.V3RunsRunRefGetExpand>? defaultValue,
]) {
  if (v3RunsRunRefGetExpand == null) {
    return defaultValue ?? [];
  }

  return v3RunsRunRefGetExpand
      .map((e) => v3RunsRunRefGetExpandFromJson(e))
      .toList();
}

List<enums.V3RunsRunRefGetExpand>? v3RunsRunRefGetExpandNullableListFromJson(
  List? v3RunsRunRefGetExpand, [
  List<enums.V3RunsRunRefGetExpand>? defaultValue,
]) {
  if (v3RunsRunRefGetExpand == null) {
    return defaultValue;
  }

  return v3RunsRunRefGetExpand
      .map((e) => v3RunsRunRefGetExpandFromJson(e))
      .toList();
}

String? v3RunsRunRefRouteTypeRouteTypeGetRouteTypeNullableToJson(
  enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType?
  v3RunsRunRefRouteTypeRouteTypeGetRouteType,
) {
  return v3RunsRunRefRouteTypeRouteTypeGetRouteType?.value;
}

String? v3RunsRunRefRouteTypeRouteTypeGetRouteTypeToJson(
  enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType
  v3RunsRunRefRouteTypeRouteTypeGetRouteType,
) {
  return v3RunsRunRefRouteTypeRouteTypeGetRouteType.value;
}

enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType
v3RunsRunRefRouteTypeRouteTypeGetRouteTypeFromJson(
  Object? v3RunsRunRefRouteTypeRouteTypeGetRouteType, [
  enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  return enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3RunsRunRefRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue ??
      enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType.swaggerGeneratedUnknown;
}

enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType?
v3RunsRunRefRouteTypeRouteTypeGetRouteTypeNullableFromJson(
  Object? v3RunsRunRefRouteTypeRouteTypeGetRouteType, [
  enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  if (v3RunsRunRefRouteTypeRouteTypeGetRouteType == null) {
    return null;
  }
  return enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3RunsRunRefRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue;
}

String v3RunsRunRefRouteTypeRouteTypeGetRouteTypeExplodedListToJson(
  List<enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType>?
  v3RunsRunRefRouteTypeRouteTypeGetRouteType,
) {
  return v3RunsRunRefRouteTypeRouteTypeGetRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3RunsRunRefRouteTypeRouteTypeGetRouteTypeListToJson(
  List<enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType>?
  v3RunsRunRefRouteTypeRouteTypeGetRouteType,
) {
  if (v3RunsRunRefRouteTypeRouteTypeGetRouteType == null) {
    return [];
  }

  return v3RunsRunRefRouteTypeRouteTypeGetRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType>
v3RunsRunRefRouteTypeRouteTypeGetRouteTypeListFromJson(
  List? v3RunsRunRefRouteTypeRouteTypeGetRouteType, [
  List<enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3RunsRunRefRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue ?? [];
  }

  return v3RunsRunRefRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3RunsRunRefRouteTypeRouteTypeGetRouteTypeFromJson(e.toString()),
      )
      .toList();
}

List<enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType>?
v3RunsRunRefRouteTypeRouteTypeGetRouteTypeNullableListFromJson(
  List? v3RunsRunRefRouteTypeRouteTypeGetRouteType, [
  List<enums.V3RunsRunRefRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3RunsRunRefRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue;
  }

  return v3RunsRunRefRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3RunsRunRefRouteTypeRouteTypeGetRouteTypeFromJson(e.toString()),
      )
      .toList();
}

int? v3RunsRunRefRouteTypeRouteTypeGetExpandNullableToJson(
  enums.V3RunsRunRefRouteTypeRouteTypeGetExpand?
  v3RunsRunRefRouteTypeRouteTypeGetExpand,
) {
  return v3RunsRunRefRouteTypeRouteTypeGetExpand?.value;
}

int? v3RunsRunRefRouteTypeRouteTypeGetExpandToJson(
  enums.V3RunsRunRefRouteTypeRouteTypeGetExpand
  v3RunsRunRefRouteTypeRouteTypeGetExpand,
) {
  return v3RunsRunRefRouteTypeRouteTypeGetExpand.value;
}

enums.V3RunsRunRefRouteTypeRouteTypeGetExpand
v3RunsRunRefRouteTypeRouteTypeGetExpandFromJson(
  Object? v3RunsRunRefRouteTypeRouteTypeGetExpand, [
  enums.V3RunsRunRefRouteTypeRouteTypeGetExpand? defaultValue,
]) {
  return enums.V3RunsRunRefRouteTypeRouteTypeGetExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsRunRefRouteTypeRouteTypeGetExpand,
      ) ??
      defaultValue ??
      enums.V3RunsRunRefRouteTypeRouteTypeGetExpand.swaggerGeneratedUnknown;
}

enums.V3RunsRunRefRouteTypeRouteTypeGetExpand?
v3RunsRunRefRouteTypeRouteTypeGetExpandNullableFromJson(
  Object? v3RunsRunRefRouteTypeRouteTypeGetExpand, [
  enums.V3RunsRunRefRouteTypeRouteTypeGetExpand? defaultValue,
]) {
  if (v3RunsRunRefRouteTypeRouteTypeGetExpand == null) {
    return null;
  }
  return enums.V3RunsRunRefRouteTypeRouteTypeGetExpand.values.firstWhereOrNull(
        (e) => e.value == v3RunsRunRefRouteTypeRouteTypeGetExpand,
      ) ??
      defaultValue;
}

String v3RunsRunRefRouteTypeRouteTypeGetExpandExplodedListToJson(
  List<enums.V3RunsRunRefRouteTypeRouteTypeGetExpand>?
  v3RunsRunRefRouteTypeRouteTypeGetExpand,
) {
  return v3RunsRunRefRouteTypeRouteTypeGetExpand
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3RunsRunRefRouteTypeRouteTypeGetExpandListToJson(
  List<enums.V3RunsRunRefRouteTypeRouteTypeGetExpand>?
  v3RunsRunRefRouteTypeRouteTypeGetExpand,
) {
  if (v3RunsRunRefRouteTypeRouteTypeGetExpand == null) {
    return [];
  }

  return v3RunsRunRefRouteTypeRouteTypeGetExpand.map((e) => e.value!).toList();
}

List<enums.V3RunsRunRefRouteTypeRouteTypeGetExpand>
v3RunsRunRefRouteTypeRouteTypeGetExpandListFromJson(
  List? v3RunsRunRefRouteTypeRouteTypeGetExpand, [
  List<enums.V3RunsRunRefRouteTypeRouteTypeGetExpand>? defaultValue,
]) {
  if (v3RunsRunRefRouteTypeRouteTypeGetExpand == null) {
    return defaultValue ?? [];
  }

  return v3RunsRunRefRouteTypeRouteTypeGetExpand
      .map((e) => v3RunsRunRefRouteTypeRouteTypeGetExpandFromJson(e))
      .toList();
}

List<enums.V3RunsRunRefRouteTypeRouteTypeGetExpand>?
v3RunsRunRefRouteTypeRouteTypeGetExpandNullableListFromJson(
  List? v3RunsRunRefRouteTypeRouteTypeGetExpand, [
  List<enums.V3RunsRunRefRouteTypeRouteTypeGetExpand>? defaultValue,
]) {
  if (v3RunsRunRefRouteTypeRouteTypeGetExpand == null) {
    return defaultValue;
  }

  return v3RunsRunRefRouteTypeRouteTypeGetExpand
      .map((e) => v3RunsRunRefRouteTypeRouteTypeGetExpandFromJson(e))
      .toList();
}

int? v3SearchSearchTermGetRouteTypesNullableToJson(
  enums.V3SearchSearchTermGetRouteTypes? v3SearchSearchTermGetRouteTypes,
) {
  return v3SearchSearchTermGetRouteTypes?.value;
}

int? v3SearchSearchTermGetRouteTypesToJson(
  enums.V3SearchSearchTermGetRouteTypes v3SearchSearchTermGetRouteTypes,
) {
  return v3SearchSearchTermGetRouteTypes.value;
}

enums.V3SearchSearchTermGetRouteTypes v3SearchSearchTermGetRouteTypesFromJson(
  Object? v3SearchSearchTermGetRouteTypes, [
  enums.V3SearchSearchTermGetRouteTypes? defaultValue,
]) {
  return enums.V3SearchSearchTermGetRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3SearchSearchTermGetRouteTypes,
      ) ??
      defaultValue ??
      enums.V3SearchSearchTermGetRouteTypes.swaggerGeneratedUnknown;
}

enums.V3SearchSearchTermGetRouteTypes?
v3SearchSearchTermGetRouteTypesNullableFromJson(
  Object? v3SearchSearchTermGetRouteTypes, [
  enums.V3SearchSearchTermGetRouteTypes? defaultValue,
]) {
  if (v3SearchSearchTermGetRouteTypes == null) {
    return null;
  }
  return enums.V3SearchSearchTermGetRouteTypes.values.firstWhereOrNull(
        (e) => e.value == v3SearchSearchTermGetRouteTypes,
      ) ??
      defaultValue;
}

String v3SearchSearchTermGetRouteTypesExplodedListToJson(
  List<enums.V3SearchSearchTermGetRouteTypes>? v3SearchSearchTermGetRouteTypes,
) {
  return v3SearchSearchTermGetRouteTypes?.map((e) => e.value!).join(',') ?? '';
}

List<int> v3SearchSearchTermGetRouteTypesListToJson(
  List<enums.V3SearchSearchTermGetRouteTypes>? v3SearchSearchTermGetRouteTypes,
) {
  if (v3SearchSearchTermGetRouteTypes == null) {
    return [];
  }

  return v3SearchSearchTermGetRouteTypes.map((e) => e.value!).toList();
}

List<enums.V3SearchSearchTermGetRouteTypes>
v3SearchSearchTermGetRouteTypesListFromJson(
  List? v3SearchSearchTermGetRouteTypes, [
  List<enums.V3SearchSearchTermGetRouteTypes>? defaultValue,
]) {
  if (v3SearchSearchTermGetRouteTypes == null) {
    return defaultValue ?? [];
  }

  return v3SearchSearchTermGetRouteTypes
      .map((e) => v3SearchSearchTermGetRouteTypesFromJson(e))
      .toList();
}

List<enums.V3SearchSearchTermGetRouteTypes>?
v3SearchSearchTermGetRouteTypesNullableListFromJson(
  List? v3SearchSearchTermGetRouteTypes, [
  List<enums.V3SearchSearchTermGetRouteTypes>? defaultValue,
]) {
  if (v3SearchSearchTermGetRouteTypes == null) {
    return defaultValue;
  }

  return v3SearchSearchTermGetRouteTypes
      .map((e) => v3SearchSearchTermGetRouteTypesFromJson(e))
      .toList();
}

String? v3StopsStopIdRouteTypeRouteTypeGetRouteTypeNullableToJson(
  enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType?
  v3StopsStopIdRouteTypeRouteTypeGetRouteType,
) {
  return v3StopsStopIdRouteTypeRouteTypeGetRouteType?.value;
}

String? v3StopsStopIdRouteTypeRouteTypeGetRouteTypeToJson(
  enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType
  v3StopsStopIdRouteTypeRouteTypeGetRouteType,
) {
  return v3StopsStopIdRouteTypeRouteTypeGetRouteType.value;
}

enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType
v3StopsStopIdRouteTypeRouteTypeGetRouteTypeFromJson(
  Object? v3StopsStopIdRouteTypeRouteTypeGetRouteType, [
  enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3StopsStopIdRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue ??
      enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.swaggerGeneratedUnknown;
}

enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType?
v3StopsStopIdRouteTypeRouteTypeGetRouteTypeNullableFromJson(
  Object? v3StopsStopIdRouteTypeRouteTypeGetRouteType, [
  enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  if (v3StopsStopIdRouteTypeRouteTypeGetRouteType == null) {
    return null;
  }
  return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3StopsStopIdRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue;
}

String v3StopsStopIdRouteTypeRouteTypeGetRouteTypeExplodedListToJson(
  List<enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType>?
  v3StopsStopIdRouteTypeRouteTypeGetRouteType,
) {
  return v3StopsStopIdRouteTypeRouteTypeGetRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3StopsStopIdRouteTypeRouteTypeGetRouteTypeListToJson(
  List<enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType>?
  v3StopsStopIdRouteTypeRouteTypeGetRouteType,
) {
  if (v3StopsStopIdRouteTypeRouteTypeGetRouteType == null) {
    return [];
  }

  return v3StopsStopIdRouteTypeRouteTypeGetRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType>
v3StopsStopIdRouteTypeRouteTypeGetRouteTypeListFromJson(
  List? v3StopsStopIdRouteTypeRouteTypeGetRouteType, [
  List<enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3StopsStopIdRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue ?? [];
  }

  return v3StopsStopIdRouteTypeRouteTypeGetRouteType
      .map(
        (e) =>
            v3StopsStopIdRouteTypeRouteTypeGetRouteTypeFromJson(e.toString()),
      )
      .toList();
}

List<enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType>?
v3StopsStopIdRouteTypeRouteTypeGetRouteTypeNullableListFromJson(
  List? v3StopsStopIdRouteTypeRouteTypeGetRouteType, [
  List<enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3StopsStopIdRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue;
  }

  return v3StopsStopIdRouteTypeRouteTypeGetRouteType
      .map(
        (e) =>
            v3StopsStopIdRouteTypeRouteTypeGetRouteTypeFromJson(e.toString()),
      )
      .toList();
}

String? v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeNullableToJson(
  enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType?
  v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType,
) {
  return v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType?.value;
}

String? v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeToJson(
  enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType
  v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType,
) {
  return v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType.value;
}

enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType
v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeFromJson(
  Object? v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType, [
  enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  return enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue ??
      enums
          .V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType
          .swaggerGeneratedUnknown;
}

enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType?
v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeNullableFromJson(
  Object? v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType, [
  enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType? defaultValue,
]) {
  if (v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType == null) {
    return null;
  }
  return enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType.values
          .firstWhereOrNull(
            (e) => e.value == v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType,
          ) ??
      defaultValue;
}

String v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeExplodedListToJson(
  List<enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType>?
  v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType,
) {
  return v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeListToJson(
  List<enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType>?
  v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType,
) {
  if (v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType == null) {
    return [];
  }

  return v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType
      .map((e) => e.value!)
      .toList();
}

List<enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType>
v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeListFromJson(
  List? v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType, [
  List<enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue ?? [];
  }

  return v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType>?
v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeNullableListFromJson(
  List? v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType, [
  List<enums.V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType>? defaultValue,
]) {
  if (v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType == null) {
    return defaultValue;
  }

  return v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType
      .map(
        (e) => v3StopsRouteRouteIdRouteTypeRouteTypeGetRouteTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

int? v3StopsLocationLatitudeLongitudeGetRouteTypesNullableToJson(
  enums.V3StopsLocationLatitudeLongitudeGetRouteTypes?
  v3StopsLocationLatitudeLongitudeGetRouteTypes,
) {
  return v3StopsLocationLatitudeLongitudeGetRouteTypes?.value;
}

int? v3StopsLocationLatitudeLongitudeGetRouteTypesToJson(
  enums.V3StopsLocationLatitudeLongitudeGetRouteTypes
  v3StopsLocationLatitudeLongitudeGetRouteTypes,
) {
  return v3StopsLocationLatitudeLongitudeGetRouteTypes.value;
}

enums.V3StopsLocationLatitudeLongitudeGetRouteTypes
v3StopsLocationLatitudeLongitudeGetRouteTypesFromJson(
  Object? v3StopsLocationLatitudeLongitudeGetRouteTypes, [
  enums.V3StopsLocationLatitudeLongitudeGetRouteTypes? defaultValue,
]) {
  return enums.V3StopsLocationLatitudeLongitudeGetRouteTypes.values
          .firstWhereOrNull(
            (e) => e.value == v3StopsLocationLatitudeLongitudeGetRouteTypes,
          ) ??
      defaultValue ??
      enums
          .V3StopsLocationLatitudeLongitudeGetRouteTypes
          .swaggerGeneratedUnknown;
}

enums.V3StopsLocationLatitudeLongitudeGetRouteTypes?
v3StopsLocationLatitudeLongitudeGetRouteTypesNullableFromJson(
  Object? v3StopsLocationLatitudeLongitudeGetRouteTypes, [
  enums.V3StopsLocationLatitudeLongitudeGetRouteTypes? defaultValue,
]) {
  if (v3StopsLocationLatitudeLongitudeGetRouteTypes == null) {
    return null;
  }
  return enums.V3StopsLocationLatitudeLongitudeGetRouteTypes.values
          .firstWhereOrNull(
            (e) => e.value == v3StopsLocationLatitudeLongitudeGetRouteTypes,
          ) ??
      defaultValue;
}

String v3StopsLocationLatitudeLongitudeGetRouteTypesExplodedListToJson(
  List<enums.V3StopsLocationLatitudeLongitudeGetRouteTypes>?
  v3StopsLocationLatitudeLongitudeGetRouteTypes,
) {
  return v3StopsLocationLatitudeLongitudeGetRouteTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> v3StopsLocationLatitudeLongitudeGetRouteTypesListToJson(
  List<enums.V3StopsLocationLatitudeLongitudeGetRouteTypes>?
  v3StopsLocationLatitudeLongitudeGetRouteTypes,
) {
  if (v3StopsLocationLatitudeLongitudeGetRouteTypes == null) {
    return [];
  }

  return v3StopsLocationLatitudeLongitudeGetRouteTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V3StopsLocationLatitudeLongitudeGetRouteTypes>
v3StopsLocationLatitudeLongitudeGetRouteTypesListFromJson(
  List? v3StopsLocationLatitudeLongitudeGetRouteTypes, [
  List<enums.V3StopsLocationLatitudeLongitudeGetRouteTypes>? defaultValue,
]) {
  if (v3StopsLocationLatitudeLongitudeGetRouteTypes == null) {
    return defaultValue ?? [];
  }

  return v3StopsLocationLatitudeLongitudeGetRouteTypes
      .map((e) => v3StopsLocationLatitudeLongitudeGetRouteTypesFromJson(e))
      .toList();
}

List<enums.V3StopsLocationLatitudeLongitudeGetRouteTypes>?
v3StopsLocationLatitudeLongitudeGetRouteTypesNullableListFromJson(
  List? v3StopsLocationLatitudeLongitudeGetRouteTypes, [
  List<enums.V3StopsLocationLatitudeLongitudeGetRouteTypes>? defaultValue,
]) {
  if (v3StopsLocationLatitudeLongitudeGetRouteTypes == null) {
    return defaultValue;
  }

  return v3StopsLocationLatitudeLongitudeGetRouteTypes
      .map((e) => v3StopsLocationLatitudeLongitudeGetRouteTypesFromJson(e))
      .toList();
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
    chopper.Response response,
  ) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
        body:
            DateTime.parse((response.body as String).replaceAll('"', ''))
                as ResultType,
      );
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
      body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType,
    );
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
