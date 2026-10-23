// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'ptv_timetable_v3.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$PtvTimetableV3 extends PtvTimetableV3 {
  _$PtvTimetableV3([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = PtvTimetableV3;

  @override
  Future<Response<V3DeparturesResponse>>
  _v3DeparturesRouteTypeRouteTypeStopStopIdGet({
    required String? routeType,
    required int stopId,
    List<int>? platformNumbers,
    int? directionId,
    bool? gtfs,
    DateTime? dateUtc,
    int? maxResults,
    bool? includeCancelled,
    bool? lookBackwards,
    List<Object?>? expand,
    bool? includeGeopath,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse(
      '/v3/departures/route_type/${routeType}/stop/${stopId}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'platform_numbers': platformNumbers,
      'direction_id': directionId,
      'gtfs': gtfs,
      'date_utc': dateUtc,
      'max_results': maxResults,
      'include_cancelled': includeCancelled,
      'look_backwards': lookBackwards,
      'expand': expand,
      'include_geopath': includeGeopath,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DeparturesResponse, V3DeparturesResponse>($request);
  }

  @override
  Future<Response<V3DeparturesResponse>>
  _v3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGet({
    required String? routeType,
    required int stopId,
    required String routeId,
    int? directionId,
    bool? gtfs,
    DateTime? dateUtc,
    int? maxResults,
    bool? includeCancelled,
    bool? lookBackwards,
    List<Object?>? expand,
    bool? includeGeopath,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse(
      '/v3/departures/route_type/${routeType}/stop/${stopId}/route/${routeId}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'direction_id': directionId,
      'gtfs': gtfs,
      'date_utc': dateUtc,
      'max_results': maxResults,
      'include_cancelled': includeCancelled,
      'look_backwards': lookBackwards,
      'expand': expand,
      'include_geopath': includeGeopath,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DeparturesResponse, V3DeparturesResponse>($request);
  }

  @override
  Future<Response<V3DirectionsResponse>> _v3DirectionsRouteRouteIdGet({
    required int routeId,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/directions/route/${routeId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DirectionsResponse, V3DirectionsResponse>($request);
  }

  @override
  Future<Response<V3DirectionsResponse>> _v3DirectionsDirectionIdGet({
    required int directionId,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/directions/${directionId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DirectionsResponse, V3DirectionsResponse>($request);
  }

  @override
  Future<Response<V3DirectionsResponse>>
  _v3DirectionsDirectionIdRouteTypeRouteTypeGet({
    required int directionId,
    required String? routeType,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse(
      '/v3/directions/${directionId}/route_type/${routeType}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DirectionsResponse, V3DirectionsResponse>($request);
  }

  @override
  Future<Response<V3DisruptionsResponse>> _v3DisruptionsGet({
    List<Object?>? routeTypes,
    List<Object?>? disruptionModes,
    String? disruptionStatus,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/disruptions');
    final Map<String, dynamic> $params = <String, dynamic>{
      'route_types': routeTypes,
      'disruption_modes': disruptionModes,
      'disruption_status': disruptionStatus,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DisruptionsResponse, V3DisruptionsResponse>($request);
  }

  @override
  Future<Response<V3DisruptionsResponse>> _v3DisruptionsRouteRouteIdGet({
    required int routeId,
    String? disruptionStatus,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/disruptions/route/${routeId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'disruption_status': disruptionStatus,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DisruptionsResponse, V3DisruptionsResponse>($request);
  }

  @override
  Future<Response<V3DisruptionsResponse>>
  _v3DisruptionsRouteRouteIdStopStopIdGet({
    required int routeId,
    required int stopId,
    String? disruptionStatus,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse(
      '/v3/disruptions/route/${routeId}/stop/${stopId}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'disruption_status': disruptionStatus,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DisruptionsResponse, V3DisruptionsResponse>($request);
  }

  @override
  Future<Response<V3DisruptionsResponse>> _v3DisruptionsStopStopIdGet({
    required int stopId,
    String? disruptionStatus,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/disruptions/stop/${stopId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'disruption_status': disruptionStatus,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DisruptionsResponse, V3DisruptionsResponse>($request);
  }

  @override
  Future<Response<V3DisruptionResponse>> _v3DisruptionsDisruptionIdGet({
    required int disruptionId,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/disruptions/${disruptionId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DisruptionResponse, V3DisruptionResponse>($request);
  }

  @override
  Future<Response<V3DisruptionModesResponse>> _v3DisruptionsModesGet({
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/disruptions/modes');
    final Map<String, dynamic> $params = <String, dynamic>{
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3DisruptionModesResponse, V3DisruptionModesResponse>(
      $request,
    );
  }

  @override
  Future<Response<V3FareEstimateResponse>>
  _v3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGet({
    required int minZone,
    required int maxZone,
    DateTime? journeyTouchOnUtc,
    DateTime? journeyTouchOffUtc,
    bool? isJourneyInFreeTramZone,
    bool? isJourneyInOverlapZone,
    List<Object?>? travelledRouteTypes,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse(
      '/v3/fare_estimate/min_zone/${minZone}/max_zone/${maxZone}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'journey_touch_on_utc': journeyTouchOnUtc,
      'journey_touch_off_utc': journeyTouchOffUtc,
      'is_journey_in_free_tram_zone': isJourneyInFreeTramZone,
      'is_journey_in_overlap_zone': isJourneyInOverlapZone,
      'travelled_route_types': travelledRouteTypes,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3FareEstimateResponse, V3FareEstimateResponse>(
      $request,
    );
  }

  @override
  Future<Response<V3OutletResponse>> _v3OutletsGet({
    int? maxResults,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/outlets');
    final Map<String, dynamic> $params = <String, dynamic>{
      'max_results': maxResults,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3OutletResponse, V3OutletResponse>($request);
  }

  @override
  Future<Response<V3OutletGeolocationResponse>>
  _v3OutletsLocationLatitudeLongitudeGet({
    required num latitude,
    required num longitude,
    num? maxDistance,
    int? maxResults,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/outlets/location/${latitude},${longitude}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'max_distance': maxDistance,
      'max_results': maxResults,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client
        .send<V3OutletGeolocationResponse, V3OutletGeolocationResponse>(
          $request,
        );
  }

  @override
  Future<Response<V3StoppingPattern>> _v3PatternRunRunRefRouteTypeRouteTypeGet({
    required String runRef,
    required String? routeType,
    List<Object?>? expand,
    int? stopId,
    DateTime? dateUtc,
    bool? includeSkippedStops,
    bool? includeGeopath,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse(
      '/v3/pattern/run/${runRef}/route_type/${routeType}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'expand': expand,
      'stop_id': stopId,
      'date_utc': dateUtc,
      'include_skipped_stops': includeSkippedStops,
      'include_geopath': includeGeopath,
      'include_advertised_interchange': includeAdvertisedInterchange,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3StoppingPattern, V3StoppingPattern>($request);
  }

  @override
  Future<Response<V3RouteResponse>> _v3RoutesGet({
    List<Object?>? routeTypes,
    String? routeName,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/routes');
    final Map<String, dynamic> $params = <String, dynamic>{
      'route_types': routeTypes,
      'route_name': routeName,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3RouteResponse, V3RouteResponse>($request);
  }

  @override
  Future<Response<V3RouteResponse>> _v3RoutesRouteIdGet({
    required int routeId,
    bool? includeGeopath,
    DateTime? geopathUtc,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/routes/${routeId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'include_geopath': includeGeopath,
      'geopath_utc': geopathUtc,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3RouteResponse, V3RouteResponse>($request);
  }

  @override
  Future<Response<V3RouteTypesResponse>> _v3RouteTypesGet({
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/route_types');
    final Map<String, dynamic> $params = <String, dynamic>{
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3RouteTypesResponse, V3RouteTypesResponse>($request);
  }

  @override
  Future<Response<V3RunsResponse>> _v3RunsRouteRouteIdGet({
    required int routeId,
    List<Object?>? expand,
    DateTime? dateUtc,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/runs/route/${routeId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'expand': expand,
      'date_utc': dateUtc,
      'include_advertised_interchange': includeAdvertisedInterchange,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3RunsResponse, V3RunsResponse>($request);
  }

  @override
  Future<Response<V3RunsResponse>> _v3RunsRouteRouteIdRouteTypeRouteTypeGet({
    required int routeId,
    required String? routeType,
    List<Object?>? expand,
    DateTime? dateUtc,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse(
      '/v3/runs/route/${routeId}/route_type/${routeType}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'expand': expand,
      'date_utc': dateUtc,
      'include_advertised_interchange': includeAdvertisedInterchange,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3RunsResponse, V3RunsResponse>($request);
  }

  @override
  Future<Response<V3RunsResponse>> _v3RunsRunRefGet({
    required String runRef,
    bool? includeGeopath,
    List<Object?>? expand,
    DateTime? dateUtc,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/runs/${runRef}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'include_geopath': includeGeopath,
      'expand': expand,
      'date_utc': dateUtc,
      'include_advertised_interchange': includeAdvertisedInterchange,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3RunsResponse, V3RunsResponse>($request);
  }

  @override
  Future<Response<V3RunResponse>> _v3RunsRunRefRouteTypeRouteTypeGet({
    required String runRef,
    required String? routeType,
    List<Object?>? expand,
    DateTime? dateUtc,
    bool? includeGeopath,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/runs/${runRef}/route_type/${routeType}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'expand': expand,
      'date_utc': dateUtc,
      'include_geopath': includeGeopath,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3RunResponse, V3RunResponse>($request);
  }

  @override
  Future<Response<V3SearchResult>> _v3SearchSearchTermGet({
    required String searchTerm,
    List<Object?>? routeTypes,
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
  }) {
    final Uri $url = Uri.parse('/v3/search/${searchTerm}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'route_types': routeTypes,
      'latitude': latitude,
      'longitude': longitude,
      'max_distance': maxDistance,
      'include_addresses': includeAddresses,
      'include_outlets': includeOutlets,
      'match_stop_by_suburb': matchStopBySuburb,
      'match_route_by_suburb': matchRouteBySuburb,
      'match_stop_by_gtfs_stop_id': matchStopByGtfsStopId,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3SearchResult, V3SearchResult>($request);
  }

  @override
  Future<Response<V3StopResponse>> _v3StopsStopIdRouteTypeRouteTypeGet({
    required int stopId,
    required String? routeType,
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
  }) {
    final Uri $url = Uri.parse('/v3/stops/${stopId}/route_type/${routeType}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'stop_location': stopLocation,
      'stop_amenities': stopAmenities,
      'stop_accessibility': stopAccessibility,
      'stop_contact': stopContact,
      'stop_ticket': stopTicket,
      'gtfs': gtfs,
      'stop_staffing': stopStaffing,
      'stop_disruptions': stopDisruptions,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3StopResponse, V3StopResponse>($request);
  }

  @override
  Future<Response<V3StopsOnRouteResponse>>
  _v3StopsRouteRouteIdRouteTypeRouteTypeGet({
    required int routeId,
    required String? routeType,
    int? directionId,
    bool? stopDisruptions,
    bool? includeGeopath,
    DateTime? geopathUtc,
    bool? includeAdvertisedInterchange,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse(
      '/v3/stops/route/${routeId}/route_type/${routeType}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'direction_id': directionId,
      'stop_disruptions': stopDisruptions,
      'include_geopath': includeGeopath,
      'geopath_utc': geopathUtc,
      'include_advertised_interchange': includeAdvertisedInterchange,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3StopsOnRouteResponse, V3StopsOnRouteResponse>(
      $request,
    );
  }

  @override
  Future<Response<V3StopsByDistanceResponse>>
  _v3StopsLocationLatitudeLongitudeGet({
    required num latitude,
    required num longitude,
    List<Object?>? routeTypes,
    int? maxResults,
    num? maxDistance,
    bool? stopDisruptions,
    String? token,
    String? devid,
    String? signature,
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
  }) {
    final Uri $url = Uri.parse('/v3/stops/location/${latitude},${longitude}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'route_types': routeTypes,
      'max_results': maxResults,
      'max_distance': maxDistance,
      'stop_disruptions': stopDisruptions,
      'token': token,
      'devid': devid,
      'signature': signature,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<V3StopsByDistanceResponse, V3StopsByDistanceResponse>(
      $request,
    );
  }
}
