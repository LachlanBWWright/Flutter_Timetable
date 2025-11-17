// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'trip_planner.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$TripPlanner extends TripPlanner {
  _$TripPlanner([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = TripPlanner;

  @override
  Future<Response<AdditionalInfoResponse>> _addInfoGet({
    required String? outputFormat,
    String? filterDateValid,
    String? filterMOTType,
    String? filterPublicationStatus,
    String? itdLPxxSelStop,
    String? itdLPxxSelLine,
    String? itdLPxxSelOperator,
    String? filterPNLineDir,
    String? filterPNLineSub,
    String? version,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
        description:
            '''This endpoint returns a list of service alerts or additional information about travelling on the public transport
network. This list can be filtered by date, route type, route, operator or stop.
''',
        summary:
            'Provides capability to display all public transport service status and incident information (as published from the Service Alert Messaging System).',
        operationId: 'tfnsw_addinfo_request',
        consumes: [],
        produces: [],
        security: [],
        tags: [],
        deprecated: false),
  }) {
    final Uri $url = Uri.parse('/add_info');
    final Map<String, dynamic> $params = <String, dynamic>{
      'outputFormat': outputFormat,
      'filterDateValid': filterDateValid,
      'filterMOTType': filterMOTType,
      'filterPublicationStatus': filterPublicationStatus,
      'itdLPxx_selStop': itdLPxxSelStop,
      'itdLPxx_selLine': itdLPxxSelLine,
      'itdLPxx_selOperator': itdLPxxSelOperator,
      'filterPNLineDir': filterPNLineDir,
      'filterPNLineSub': filterPNLineSub,
      'version': version,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client
        .send<AdditionalInfoResponse, AdditionalInfoResponse>($request);
  }

  @override
  Future<Response<CoordRequestResponse>> _coordGet({
    required String? outputFormat,
    required String coord,
    required String? coordOutputFormat,
    required String? inclFilter,
    required String? type1,
    required int radius1,
    String? inclDrawClasses1,
    String? poisOnMapMacro,
    String? version,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
        description:
            '''This endpoint returns places of interest based on the given coordinate and a radius. The types of POIs can be controlled, so if, for example,
you only want Opal resellers returned, you can do so.
''',
        summary:
            'When given a specific geographical location, this API finds public transport stops, stations, wharfs and points of interest around that location.',
        operationId: 'tfnsw_coord_request',
        consumes: [],
        produces: [],
        security: [],
        tags: [],
        deprecated: false),
  }) {
    final Uri $url = Uri.parse('/coord');
    final Map<String, dynamic> $params = <String, dynamic>{
      'outputFormat': outputFormat,
      'coord': coord,
      'coordOutputFormat': coordOutputFormat,
      'inclFilter': inclFilter,
      'type_1': type1,
      'radius_1': radius1,
      'inclDrawClasses_1': inclDrawClasses1,
      'PoisOnMapMacro': poisOnMapMacro,
      'version': version,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<CoordRequestResponse, CoordRequestResponse>($request);
  }

  @override
  Future<Response<DepartureMonitorResponse>> _departureMonGet({
    required String? outputFormat,
    required String? coordOutputFormat,
    String? mode,
    required String? typeDm,
    required String nameDm,
    String? nameKeyDm,
    String? itdDate,
    String? itdTime,
    String? departureMonitorMacro,
    String? excludedMeans,
    String? exclMOT1,
    String? exclMOT2,
    String? exclMOT4,
    String? exclMOT5,
    String? exclMOT7,
    String? exclMOT9,
    String? exclMOT11,
    String? tfNSWDM,
    String? version,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
        description:
            '''This endpoint returns a list of departures for a given location based on the date and time specified. This data can be used to
display a "upcoming departures" board for a stop.
''',
        summary:
            'Provides capability to provide NSW public transport departure information from a stop, station or wharf including real-time.',
        operationId: 'tfnsw_dm_request',
        consumes: [],
        produces: [],
        security: [],
        tags: [],
        deprecated: false),
  }) {
    final Uri $url = Uri.parse('/departure_mon');
    final Map<String, dynamic> $params = <String, dynamic>{
      'outputFormat': outputFormat,
      'coordOutputFormat': coordOutputFormat,
      'mode': mode,
      'type_dm': typeDm,
      'name_dm': nameDm,
      'nameKey_dm': nameKeyDm,
      'itdDate': itdDate,
      'itdTime': itdTime,
      'departureMonitorMacro': departureMonitorMacro,
      'excludedMeans': excludedMeans,
      'exclMOT_1': exclMOT1,
      'exclMOT_2': exclMOT2,
      'exclMOT_4': exclMOT4,
      'exclMOT_5': exclMOT5,
      'exclMOT_7': exclMOT7,
      'exclMOT_9': exclMOT9,
      'exclMOT_11': exclMOT11,
      'TfNSWDM': tfNSWDM,
      'version': version,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client
        .send<DepartureMonitorResponse, DepartureMonitorResponse>($request);
  }

  @override
  Future<Response<StopFinderResponse>> _stopFinderGet({
    required String? outputFormat,
    required String? typeSf,
    required String nameSf,
    required String? coordOutputFormat,
    String? tfNSWSF,
    String? version,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
        description:
            '''This endpoint returns info about stops that match the search criteria. Matches can be sorted on `matchQuality` to determine the best matches for the given input,
while the best match will be indicated by the `isBest` value.
''',
        summary:
            'Provides capability to return all NSW public transport stop, station, wharf, points of interest and known addresses to be used for auto-suggest/auto-complete (to be used with the Trip planner and Departure board APIs).',
        operationId: 'tfnsw_stopfinder_request',
        consumes: [],
        produces: [],
        security: [],
        tags: [],
        deprecated: false),
  }) {
    final Uri $url = Uri.parse('/stop_finder');
    final Map<String, dynamic> $params = <String, dynamic>{
      'outputFormat': outputFormat,
      'type_sf': typeSf,
      'name_sf': nameSf,
      'coordOutputFormat': coordOutputFormat,
      'TfNSWSF': tfNSWSF,
      'version': version,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<StopFinderResponse, StopFinderResponse>($request);
  }

  @override
  Future<Response<TripRequestResponse>> _tripGet({
    required String? outputFormat,
    required String? coordOutputFormat,
    required String? depArrMacro,
    String? itdDate,
    String? itdTime,
    required String? typeOrigin,
    required String nameOrigin,
    required String? typeDestination,
    required String nameDestination,
    int? calcNumberOfTrips,
    String? wheelchair,
    String? excludedMeans,
    String? exclMOT1,
    String? exclMOT2,
    String? exclMOT4,
    String? exclMOT5,
    String? exclMOT7,
    String? exclMOT9,
    String? exclMOT11,
    String? tfNSWTR,
    String? version,
    int? itOptionsActive,
    bool? computeMonomodalTripBicycle,
    int? cycleSpeed,
    String? bikeProfSpeed,
    int? maxTimeBicycle,
    int? onlyITBicycle,
    int? useElevationData,
    int? elevFac,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
        description:
            '''This endpoint is used to find a list of journeys between two locations at the specified date and time. For example,
if the user is at the Airport and wants to get to Manly using public transport but isn\'t sure how exactly, this call
will tell them exactly which train, bus, ferry or light rail to catch, and between which stops. It is extremely detailed,
and includes the the specific path the vehicle(s) will take. ''',
        summary:
            'Provides capability to provide NSW public transport trip plan options, including walking and driving legs and real-time information.',
        operationId: 'tfnsw_trip_request2',
        consumes: [],
        produces: [],
        security: [],
        tags: [],
        deprecated: false),
  }) {
    final Uri $url = Uri.parse('/trip');
    final Map<String, dynamic> $params = <String, dynamic>{
      'outputFormat': outputFormat,
      'coordOutputFormat': coordOutputFormat,
      'depArrMacro': depArrMacro,
      'itdDate': itdDate,
      'itdTime': itdTime,
      'type_origin': typeOrigin,
      'name_origin': nameOrigin,
      'type_destination': typeDestination,
      'name_destination': nameDestination,
      'calcNumberOfTrips': calcNumberOfTrips,
      'wheelchair': wheelchair,
      'excludedMeans': excludedMeans,
      'exclMOT_1': exclMOT1,
      'exclMOT_2': exclMOT2,
      'exclMOT_4': exclMOT4,
      'exclMOT_5': exclMOT5,
      'exclMOT_7': exclMOT7,
      'exclMOT_9': exclMOT9,
      'exclMOT_11': exclMOT11,
      'TfNSWTR': tfNSWTR,
      'version': version,
      'itOptionsActive': itOptionsActive,
      'computeMonomodalTripBicycle': computeMonomodalTripBicycle,
      'cycleSpeed': cycleSpeed,
      'bikeProfSpeed': bikeProfSpeed,
      'maxTimeBicycle': maxTimeBicycle,
      'onlyITBicycle': onlyITBicycle,
      'useElevationData': useElevationData,
      'elevFac': elevFac,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<TripRequestResponse, TripRequestResponse>($request);
  }
}
