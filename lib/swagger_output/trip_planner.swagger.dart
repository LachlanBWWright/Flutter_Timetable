// ignore_for_file: type=lint

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
import 'trip_planner.enums.swagger.dart' as enums;
export 'trip_planner.enums.swagger.dart';

part 'trip_planner.swagger.chopper.dart';
part 'trip_planner.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class TripPlanner extends ChopperService {
  static TripPlanner create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$TripPlanner(client);
    }

    final newClient = ChopperClient(
        services: [_$TripPlanner()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ?? Uri.parse('http://api.transport.nsw.gov.au/v1/tp'));
    return _$TripPlanner(newClient);
  }

  ///Provides capability to display all public transport service status and incident information (as published from the Service Alert Messaging System).
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param filterDateValid This parameter allows you to filter the returned items that are only valid on the specified date. The format of this field is `DD-MM-YYYY`. For example, 12 September 2016 would be represented by `12-09-2016`.
  ///@param filterMOTType This parameter allows you to filter the returned items by the modes of transport they affected. Available modes include:  * `1`: Train * `2`: Metro * `4`: Light Rail * `5`: Bus * `7`: Coach * `9`: Ferry * `11`: School Bus  To search for more than one mode, include the parameter multiple times.
  ///@param filterPublicationStatus This field can be used so only current alerts are returned, and not historic alerts.
  ///@param itdLPxx_selStop This parameter allows you to filter the returned items by its stop ID or global stop ID. For example, to retrieve items that are only relevant to Central Station, you would set this value to `10111010` (stop ID) or `200060` (global stop ID). You can use the `stop_finder` API call to determine the ID for a particular stop.
  ///@param itdLPxx_selLine This parameter allows you to filter the returned items by line number. For example, `020T1`. You can use this parameter multiple times if you want to search for more than one line number.
  ///@param itdLPxx_selOperator This parameter allows you to filter the returned items by operator ID. You can use this parameter multiple times if you want to search for more than one line number.
  ///@param filterPNLineDir This parameter allows you to filter the returned items by specific routes. The route is provided in the format `NNN:LLLLL:D`, (NNN: subnet, LLLLL: Route number, D: direction `H`/`R`). You can use this parameter multiple times if you want to search for more than one line number.
  ///@param filterPNLineSub This parameter allows you to filter the returned items by specific routes. The route is provided in the format `NNN:LLLLL:E`, (NNN: subnet, LLLLL: Route number, E: supplement). You can use this parameter multiple times if you want to search for more than one line number.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  Future<chopper.Response<AdditionalInfoResponse>> addInfoGet({
    required enums.AddInfoGetOutputFormat? outputFormat,
    String? filterDateValid,
    enums.AddInfoGetFilterMOTType? filterMOTType,
    enums.AddInfoGetFilterPublicationStatus? filterPublicationStatus,
    String? itdLPxxSelStop,
    String? itdLPxxSelLine,
    String? itdLPxxSelOperator,
    String? filterPNLineDir,
    String? filterPNLineSub,
    String? version,
  }) {
    generatedMapping.putIfAbsent(
        AdditionalInfoResponse, () => AdditionalInfoResponse.fromJsonFactory);

    return _addInfoGet(
        outputFormat: outputFormat?.value?.toString(),
        filterDateValid: filterDateValid,
        filterMOTType: filterMOTType?.value?.toString(),
        filterPublicationStatus: filterPublicationStatus?.value?.toString(),
        itdLPxxSelStop: itdLPxxSelStop,
        itdLPxxSelLine: itdLPxxSelLine,
        itdLPxxSelOperator: itdLPxxSelOperator,
        filterPNLineDir: filterPNLineDir,
        filterPNLineSub: filterPNLineSub,
        version: version);
  }

  ///Provides capability to display all public transport service status and incident information (as published from the Service Alert Messaging System).
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param filterDateValid This parameter allows you to filter the returned items that are only valid on the specified date. The format of this field is `DD-MM-YYYY`. For example, 12 September 2016 would be represented by `12-09-2016`.
  ///@param filterMOTType This parameter allows you to filter the returned items by the modes of transport they affected. Available modes include:  * `1`: Train * `2`: Metro * `4`: Light Rail * `5`: Bus * `7`: Coach * `9`: Ferry * `11`: School Bus  To search for more than one mode, include the parameter multiple times.
  ///@param filterPublicationStatus This field can be used so only current alerts are returned, and not historic alerts.
  ///@param itdLPxx_selStop This parameter allows you to filter the returned items by its stop ID or global stop ID. For example, to retrieve items that are only relevant to Central Station, you would set this value to `10111010` (stop ID) or `200060` (global stop ID). You can use the `stop_finder` API call to determine the ID for a particular stop.
  ///@param itdLPxx_selLine This parameter allows you to filter the returned items by line number. For example, `020T1`. You can use this parameter multiple times if you want to search for more than one line number.
  ///@param itdLPxx_selOperator This parameter allows you to filter the returned items by operator ID. You can use this parameter multiple times if you want to search for more than one line number.
  ///@param filterPNLineDir This parameter allows you to filter the returned items by specific routes. The route is provided in the format `NNN:LLLLL:D`, (NNN: subnet, LLLLL: Route number, D: direction `H`/`R`). You can use this parameter multiple times if you want to search for more than one line number.
  ///@param filterPNLineSub This parameter allows you to filter the returned items by specific routes. The route is provided in the format `NNN:LLLLL:E`, (NNN: subnet, LLLLL: Route number, E: supplement). You can use this parameter multiple times if you want to search for more than one line number.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  @Get(path: '/add_info')
  Future<chopper.Response<AdditionalInfoResponse>> _addInfoGet({
    @Query('outputFormat') required String? outputFormat,
    @Query('filterDateValid') String? filterDateValid,
    @Query('filterMOTType') String? filterMOTType,
    @Query('filterPublicationStatus') String? filterPublicationStatus,
    @Query('itdLPxx_selStop') String? itdLPxxSelStop,
    @Query('itdLPxx_selLine') String? itdLPxxSelLine,
    @Query('itdLPxx_selOperator') String? itdLPxxSelOperator,
    @Query('filterPNLineDir') String? filterPNLineDir,
    @Query('filterPNLineSub') String? filterPNLineSub,
    @Query('version') String? version,
  });

  ///When given a specific geographical location, this API finds public transport stops, stations, wharfs and points of interest around that location.
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param coord The coordinate is in the format `LONGITUDE:LATITUDE:EPSG:4326` (Note that longitude is first). For example, the following `coord` value can be used to search around Central Station: `151.206290:-33.884080:EPSG:4326`.
  ///@param coordOutputFormat This specifies the format the coordinates are returned in. While other variations are available, the `EPSG:4326` format will return the widely-used format.
  ///@param inclFilter This enables "advanced filter mode" on the server, which is required to enable searching using coordinates.
  ///@param type_1 This specifies the type of items to return.  * `GIS_POINT`: GIS points, including Opal resellers (see `inclDrawClasses_1`) * `BUS_POINT`: Stops/stations * `POI_POINT`: Places of interest  The `_1` suffix is an index for this particular filter. You can specify multiple filters by incrementing the suffix for each combination of `type`, `radius` and `inclDrawClasses`. For example, `type_1` means the first filter, `type_2` refers to the second, and so on.
  ///@param radius_1 This indicates the maximum number of metres to search in all directions from the location specified in `coord`. For example, if you use a value of `500`, a `type_1` value of `GIS_POINT` and `inclDrawClasses_1` with a value of `74`, all Opal resellers within 500 metres will be returned. The suffix of `_1` indicates this radius value corresponds to the `type_1` value. If multiple filters are to be included, the appropriate suffix should be updated accordingly.
  ///@param inclDrawClasses_1 This flag changes the list of POIs that are returned. To return Opal resellers, set this value to `74` and `type_1` to `GIS_POINT`.The suffix of `_1` indicates this radius value corresponds to the `type_1` value. If multiple filters are to be included, the appropriate suffix should be updated accordingly.
  ///@param PoisOnMapMacro This field indicates how the returned data is to be used, which in turn impacts whether or not certain locations are returned.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  Future<chopper.Response<CoordRequestResponse>> coordGet({
    required enums.CoordGetOutputFormat? outputFormat,
    required String? coord,
    required enums.CoordGetCoordOutputFormat? coordOutputFormat,
    required enums.CoordGetInclFilter? inclFilter,
    required enums.CoordGetType1? type1,
    required int? radius1,
    enums.CoordGetInclDrawClasses1? inclDrawClasses1,
    enums.CoordGetPoisOnMapMacro? poisOnMapMacro,
    String? version,
  }) {
    generatedMapping.putIfAbsent(
        CoordRequestResponse, () => CoordRequestResponse.fromJsonFactory);

    return _coordGet(
        outputFormat: outputFormat?.value?.toString(),
        coord: coord,
        coordOutputFormat: coordOutputFormat?.value?.toString(),
        inclFilter: inclFilter?.value?.toString(),
        type1: type1?.value?.toString(),
        radius1: radius1,
        inclDrawClasses1: inclDrawClasses1?.value?.toString(),
        poisOnMapMacro: poisOnMapMacro?.value?.toString(),
        version: version);
  }

  ///When given a specific geographical location, this API finds public transport stops, stations, wharfs and points of interest around that location.
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param coord The coordinate is in the format `LONGITUDE:LATITUDE:EPSG:4326` (Note that longitude is first). For example, the following `coord` value can be used to search around Central Station: `151.206290:-33.884080:EPSG:4326`.
  ///@param coordOutputFormat This specifies the format the coordinates are returned in. While other variations are available, the `EPSG:4326` format will return the widely-used format.
  ///@param inclFilter This enables "advanced filter mode" on the server, which is required to enable searching using coordinates.
  ///@param type_1 This specifies the type of items to return.  * `GIS_POINT`: GIS points, including Opal resellers (see `inclDrawClasses_1`) * `BUS_POINT`: Stops/stations * `POI_POINT`: Places of interest  The `_1` suffix is an index for this particular filter. You can specify multiple filters by incrementing the suffix for each combination of `type`, `radius` and `inclDrawClasses`. For example, `type_1` means the first filter, `type_2` refers to the second, and so on.
  ///@param radius_1 This indicates the maximum number of metres to search in all directions from the location specified in `coord`. For example, if you use a value of `500`, a `type_1` value of `GIS_POINT` and `inclDrawClasses_1` with a value of `74`, all Opal resellers within 500 metres will be returned. The suffix of `_1` indicates this radius value corresponds to the `type_1` value. If multiple filters are to be included, the appropriate suffix should be updated accordingly.
  ///@param inclDrawClasses_1 This flag changes the list of POIs that are returned. To return Opal resellers, set this value to `74` and `type_1` to `GIS_POINT`.The suffix of `_1` indicates this radius value corresponds to the `type_1` value. If multiple filters are to be included, the appropriate suffix should be updated accordingly.
  ///@param PoisOnMapMacro This field indicates how the returned data is to be used, which in turn impacts whether or not certain locations are returned.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  @Get(path: '/coord')
  Future<chopper.Response<CoordRequestResponse>> _coordGet({
    @Query('outputFormat') required String? outputFormat,
    @Query('coord') required String? coord,
    @Query('coordOutputFormat') required String? coordOutputFormat,
    @Query('inclFilter') required String? inclFilter,
    @Query('type_1') required String? type1,
    @Query('radius_1') required int? radius1,
    @Query('inclDrawClasses_1') String? inclDrawClasses1,
    @Query('PoisOnMapMacro') String? poisOnMapMacro,
    @Query('version') String? version,
  });

  ///Provides capability to provide NSW public transport departure information from a stop, station or wharf including real-time.
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param coordOutputFormat This specifies the format the coordinates are returned in. While other variations are available, the `EPSG:4326` format will return the widely-used format.
  ///@param mode This allows the departure board to display directly without going through the stop verification process. Use this when the stop is known. This relies on the given combination of `type_dm` and `name_dm` returning only a single result, otherwise a list of stops and no departures shall be returned.
  ///@param type_dm This specifies the type of results expected based on the search input in `name_dm`. By specifying `any`, locations of all types can be returned. Typically, this API call is used for a specific stop, so `stop` should be used along with a stop ID or global stop ID in `name_dm`.
  ///@param name_dm This is the search term that will be used to find locations. If the combination of this value and `type_dm` results in more than one location found - or `mode` is not set to `direct`, then a list of stops and no departures will be returned. If `type_dm` is set to `stop` then this value can take a stop ID or a global stop ID.
  ///@param nameKey_dm Setting this parameter to `$USEPOINT$` enables you to request departures for a specific platform within a station. If this isn't used, then departures for all platforms at the stop specified in `name_dm` are returned.
  ///@param itdDate The reference date used when searching trips, in `YYYYMMDD` format. For instance, 20160901 refers to 1 September 2016. Works in conjunction with the `itdTime` value. If not specified, the current server date is used.
  ///@param itdTime The reference time used when searching trips, in `HHMM` 24-hour format. For instance, 2215 refers to 10:15 PM. | Works in conjunction with the `itdDate` value. If not specified, the current server time is used.
  ///@param departureMonitorMacro Including this parameter enables a number of options that result in the departure monitor operating in the same way as the Transport for NSW Trip Planner web site. It is recommended this is enabled, along with the `TfNSWDM` parameter.
  ///@param excludedMeans This parameter which means of transport to exclude from the departure monitor. To exclude one means, select one of the following: `1` = train, `2` = metro, `4` = light rail, `5` = bus, `7` = coach, `9` = ferry, `11` = school bus. `checkbox` allows you to exclude more than one means of transport when used in conjunction with the `exclMOT_<ID>` parameters.
  ///@param exclMOT_1 Excludes train services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_2 Excludes metro services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_4 Excludes light rail services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_5 Excludes bus services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_7 Excludes coach services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_9 Excludes ferry services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_11 Excludes school bus services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param TfNSWDM Including this parameter enables a number of options that result in the departure monitor operating in the same way as the Transport for NSW Trip Planner web site, including enabling real-time data. It is recommended this is enabled, along with the `departureMonitorMacro` parameter.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  Future<chopper.Response<DepartureMonitorResponse>> departureMonGet({
    required enums.DepartureMonGetOutputFormat? outputFormat,
    required enums.DepartureMonGetCoordOutputFormat? coordOutputFormat,
    enums.DepartureMonGetMode? mode,
    required enums.DepartureMonGetTypeDm? typeDm,
    required String? nameDm,
    enums.DepartureMonGetNameKeyDm? nameKeyDm,
    String? itdDate,
    String? itdTime,
    enums.DepartureMonGetDepartureMonitorMacro? departureMonitorMacro,
    enums.DepartureMonGetExcludedMeans? excludedMeans,
    enums.DepartureMonGetExclMOT1? exclMOT1,
    enums.DepartureMonGetExclMOT2? exclMOT2,
    enums.DepartureMonGetExclMOT4? exclMOT4,
    enums.DepartureMonGetExclMOT5? exclMOT5,
    enums.DepartureMonGetExclMOT7? exclMOT7,
    enums.DepartureMonGetExclMOT9? exclMOT9,
    enums.DepartureMonGetExclMOT11? exclMOT11,
    enums.DepartureMonGetTfNSWDM? tfNSWDM,
    String? version,
  }) {
    generatedMapping.putIfAbsent(DepartureMonitorResponse,
        () => DepartureMonitorResponse.fromJsonFactory);

    return _departureMonGet(
        outputFormat: outputFormat?.value?.toString(),
        coordOutputFormat: coordOutputFormat?.value?.toString(),
        mode: mode?.value?.toString(),
        typeDm: typeDm?.value?.toString(),
        nameDm: nameDm,
        nameKeyDm: nameKeyDm?.value?.toString(),
        itdDate: itdDate,
        itdTime: itdTime,
        departureMonitorMacro: departureMonitorMacro?.value?.toString(),
        excludedMeans: excludedMeans?.value?.toString(),
        exclMOT1: exclMOT1?.value?.toString(),
        exclMOT2: exclMOT2?.value?.toString(),
        exclMOT4: exclMOT4?.value?.toString(),
        exclMOT5: exclMOT5?.value?.toString(),
        exclMOT7: exclMOT7?.value?.toString(),
        exclMOT9: exclMOT9?.value?.toString(),
        exclMOT11: exclMOT11?.value?.toString(),
        tfNSWDM: tfNSWDM?.value?.toString(),
        version: version);
  }

  ///Provides capability to provide NSW public transport departure information from a stop, station or wharf including real-time.
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param coordOutputFormat This specifies the format the coordinates are returned in. While other variations are available, the `EPSG:4326` format will return the widely-used format.
  ///@param mode This allows the departure board to display directly without going through the stop verification process. Use this when the stop is known. This relies on the given combination of `type_dm` and `name_dm` returning only a single result, otherwise a list of stops and no departures shall be returned.
  ///@param type_dm This specifies the type of results expected based on the search input in `name_dm`. By specifying `any`, locations of all types can be returned. Typically, this API call is used for a specific stop, so `stop` should be used along with a stop ID or global stop ID in `name_dm`.
  ///@param name_dm This is the search term that will be used to find locations. If the combination of this value and `type_dm` results in more than one location found - or `mode` is not set to `direct`, then a list of stops and no departures will be returned. If `type_dm` is set to `stop` then this value can take a stop ID or a global stop ID.
  ///@param nameKey_dm Setting this parameter to `$USEPOINT$` enables you to request departures for a specific platform within a station. If this isn't used, then departures for all platforms at the stop specified in `name_dm` are returned.
  ///@param itdDate The reference date used when searching trips, in `YYYYMMDD` format. For instance, 20160901 refers to 1 September 2016. Works in conjunction with the `itdTime` value. If not specified, the current server date is used.
  ///@param itdTime The reference time used when searching trips, in `HHMM` 24-hour format. For instance, 2215 refers to 10:15 PM. | Works in conjunction with the `itdDate` value. If not specified, the current server time is used.
  ///@param departureMonitorMacro Including this parameter enables a number of options that result in the departure monitor operating in the same way as the Transport for NSW Trip Planner web site. It is recommended this is enabled, along with the `TfNSWDM` parameter.
  ///@param excludedMeans This parameter which means of transport to exclude from the departure monitor. To exclude one means, select one of the following: `1` = train, `2` = metro, `4` = light rail, `5` = bus, `7` = coach, `9` = ferry, `11` = school bus. `checkbox` allows you to exclude more than one means of transport when used in conjunction with the `exclMOT_<ID>` parameters.
  ///@param exclMOT_1 Excludes train services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_2 Excludes metro services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_4 Excludes light rail services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_5 Excludes bus services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_7 Excludes coach services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_9 Excludes ferry services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_11 Excludes school bus services from the departure monitor.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param TfNSWDM Including this parameter enables a number of options that result in the departure monitor operating in the same way as the Transport for NSW Trip Planner web site, including enabling real-time data. It is recommended this is enabled, along with the `departureMonitorMacro` parameter.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  @Get(path: '/departure_mon')
  Future<chopper.Response<DepartureMonitorResponse>> _departureMonGet({
    @Query('outputFormat') required String? outputFormat,
    @Query('coordOutputFormat') required String? coordOutputFormat,
    @Query('mode') String? mode,
    @Query('type_dm') required String? typeDm,
    @Query('name_dm') required String? nameDm,
    @Query('nameKey_dm') String? nameKeyDm,
    @Query('itdDate') String? itdDate,
    @Query('itdTime') String? itdTime,
    @Query('departureMonitorMacro') String? departureMonitorMacro,
    @Query('excludedMeans') String? excludedMeans,
    @Query('exclMOT_1') String? exclMOT1,
    @Query('exclMOT_2') String? exclMOT2,
    @Query('exclMOT_4') String? exclMOT4,
    @Query('exclMOT_5') String? exclMOT5,
    @Query('exclMOT_7') String? exclMOT7,
    @Query('exclMOT_9') String? exclMOT9,
    @Query('exclMOT_11') String? exclMOT11,
    @Query('TfNSWDM') String? tfNSWDM,
    @Query('version') String? version,
  });

  ///Provides capability to return all NSW public transport stop, station, wharf, points of interest and known addresses to be used for auto-suggest/auto-complete (to be used with the Trip planner and Departure board APIs).
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param type_sf This specifies the type of results expected in the list of returned stops. By specifying `any`, locations of all types can be returned. If you specifically know that you're searching using a coord, specify `coord`. Likewise, if you're using a stop ID or global stop ID as an input, use `stop` for more accurate results.
  ///@param name_sf This is the search term that will be used to find locations. To lookup a coordinate, set `type_sf` to `coord`, and use the following format: `LONGITUDE:LATITUDE:EPSG:4326` (Note that longitude is first). For example, `151.206290:-33.884080:EPSG:4326`. To lookup a stop set `type_sf` to  `stop` and enter the stop id or global stop ID. For example, `10101100`
  ///@param coordOutputFormat This specifies the format the coordinates are returned in. While other variations are available, the `EPSG:4326` format will return the widely-used format.
  ///@param TfNSWSF Including this parameter enables a number of options that result in the stop finder operating in the same way as the Transport for NSW Trip Planner web site.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  Future<chopper.Response<StopFinderResponse>> stopFinderGet({
    required enums.StopFinderGetOutputFormat? outputFormat,
    enums.StopFinderGetTypeSf? typeSf,
    required String? nameSf,
    required enums.StopFinderGetCoordOutputFormat? coordOutputFormat,
    enums.StopFinderGetTfNSWSF? tfNSWSF,
    String? version,
  }) {
    generatedMapping.putIfAbsent(
        StopFinderResponse, () => StopFinderResponse.fromJsonFactory);

    return _stopFinderGet(
        outputFormat: outputFormat?.value?.toString(),
        typeSf: typeSf?.value?.toString(),
        nameSf: nameSf,
        coordOutputFormat: coordOutputFormat?.value?.toString(),
        tfNSWSF: tfNSWSF?.value?.toString(),
        version: version);
  }

  ///Provides capability to return all NSW public transport stop, station, wharf, points of interest and known addresses to be used for auto-suggest/auto-complete (to be used with the Trip planner and Departure board APIs).
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param type_sf This specifies the type of results expected in the list of returned stops. By specifying `any`, locations of all types can be returned. If you specifically know that you're searching using a coord, specify `coord`. Likewise, if you're using a stop ID or global stop ID as an input, use `stop` for more accurate results.
  ///@param name_sf This is the search term that will be used to find locations. To lookup a coordinate, set `type_sf` to `coord`, and use the following format: `LONGITUDE:LATITUDE:EPSG:4326` (Note that longitude is first). For example, `151.206290:-33.884080:EPSG:4326`. To lookup a stop set `type_sf` to  `stop` and enter the stop id or global stop ID. For example, `10101100`
  ///@param coordOutputFormat This specifies the format the coordinates are returned in. While other variations are available, the `EPSG:4326` format will return the widely-used format.
  ///@param TfNSWSF Including this parameter enables a number of options that result in the stop finder operating in the same way as the Transport for NSW Trip Planner web site.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  @Get(path: '/stop_finder')
  Future<chopper.Response<StopFinderResponse>> _stopFinderGet({
    @Query('outputFormat') required String? outputFormat,
    @Query('type_sf') String? typeSf,
    @Query('name_sf') required String? nameSf,
    @Query('coordOutputFormat') required String? coordOutputFormat,
    @Query('TfNSWSF') String? tfNSWSF,
    @Query('version') String? version,
  });

  ///Provides capability to provide NSW public transport trip plan options, including walking and driving legs and real-time information.
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param coordOutputFormat This specifies the format the coordinates are returned in. While other variations are available, the `EPSG:4326` format will return the widely-used format.
  ///@param depArrMacro This value anchors the requested date time. If set to `dep`, then trips *departing after* the specified date/time *at the specified location* are included. If set to `arr`, then trips *arriving before* the specified time *at its destination stop* are included. Works in conjunctions with the `itdDate` and `itdTime` values.
  ///@param itdDate The reference date used when searching trips, in `YYYYMMDD` format. For instance, `20160901` refers to 1 September 2016. Works in conjunction with the `itdTime` and `depArrMacro` values. If not specified, the current server date is used.
  ///@param itdTime The reference time used when searching trips, in `HHMM` 24-hour format. For instance, `2215` refers to 10:15 PM. | Works in conjunction with the `itdDate` and `depArrMacro` values. If not specified, the current server time is used.
  ///@param type_origin This is the type of data specified in the `name_origin` field. The origin indicates the starting point when searching for journeys. The best way to use the trip planner is to use use `any` for this field then specify a valid location ID in `type_origin`, or to use `coord` in this field and a correctly formatted coordinate in `type_origin`.
  ///@param name_origin This value is used to indicate the starting point when searching for journeys. This value can be one of three things: A valid location/stop ID (for example, `10101100` indicates Central Station - this can be determined using `stop_finder`). A valid global stop ID (for example, `200060` indicates Central Station - this can be determined using `stop_finder`) Coordinates in the format `LONGITUDE:LATITUDE:EPSG:4326` (Note that longitude is first).
  ///@param type_destination This is the type of data specified in the `name_destination` field. The origin indicates the finishing point when searching for journeys. The best way to use the trip planner is to use use `any` for this field then specify a valid location ID in `type_destination`, or to use `coord` in this field and a correctly formatted coordinate in `type_destination`.
  ///@param name_destination This value is used to indicate the finishing point when searching for journeys. This value can be one of three things: A valid location/stop ID (for example, `10101100` indicates Central Station - this can be determined using `stop_finder`). A valid global stop ID (for example, `200060` indicates Central Station - this can be determined using `stop_finder`) Coordinates in the format `LONGITUDE:LATITUDE:EPSG:4326` (Note that longitude is first).
  ///@param calcNumberOfTrips This parameter indicates the maximum number of trips to returned. Fewer trips may be returned anyway, depending on the available public transport services.
  ///@param wheelchair Including this parameter (regardless of its value) ensures that only wheelchair-accessible options are returned.
  ///@param excludedMeans This parameter which means of transport to exclude from the trip plan. To exclude one means, select one of the following: `1` = train, `2` = metro, `4` = light rail, `5` = bus, `7` = coach, `9` = ferry, `11` = school bus. `checkbox` allows you to exclude more than one means of transport when used in conjunction with the `exclMOT_<ID>` parameters.
  ///@param exclMOT_1 Excludes train services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_2 Excludes metro services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_4 Excludes light rail services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_5 Excludes bus services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_7 Excludes coach services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_9 Excludes ferry services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_11 Excludes school bus services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param TfNSWTR Including this parameter enables a number of options that result in this API call operating in the same way as the Transport for NSW Trip Planner web site, including enabling real-time data.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  ///@param itOptionsActive This parameter activates the options for individual transport. If the parameter is disabled, the parameters concerning individual transport will not be taken into account. possible values are 0 and 1
  ///@param computeMonomodalTripBicycle Activates the calculation of a monomodal trip, i.e., a trip that takes place exclusively with the means of transport <means of transport>, e.g., with bicycle. Note 1: In order to use this parameter, the options for individual transport must be activated with itOptionsActive=1. Note 2: If no monomodal trip with the means of transport <means of transport> is calculated despite the parameter, the maximum time is often set too low. The parameter MaxITTime applies to all means of transport, the parameter MaxITTime<means of transport>to the means of transport <means of transport> (e.g., MaxITTime107). These parameters are located in the [Parameters] section or are added to it. The configuration can be alternatively overridden bythe maxTime<Transport means> parameter.
  ///@param cycleSpeed The value of the <speed> parameter is used to specify the speed of cycle travel in kilometers per hour.Note: In order to use this parameter, the options for individual transport must be activated with itOptionsActive=1. If the parameter is to be specified together with a profile, the bikeProfSpeed parameter can be used.The parameter “'cycleSpeed” specifies the desired real speed of the user for the bike route, which overwrites the speed in the SpeedSettings of the corresponding “bikeProfSpeed”.
  ///@param bikeProfSpeed With the parameter 'bikeProfSpeed' a bike profile name is passed
  ///@param maxTimeBicycle The value of the this parameter sets the maximum time to be covered by the means of cycling. The time is specified in minutes. Note: To use this parameter, the options for individual transport must be enabled with itOptionsActive=1
  ///@param onlyITBicycle Restricts the calculation to trips with the bikes only. Note: To be able to use this parameter, the options for individual transport must be activated with itOptionsActive=1. Possible values are 1, true, on
  ///@param useElevationData If this parameter is active, the elevation data is taken into account in the trip calculation for all means of transport and output in a route description for each individual transport section. Note: To be able to use this parameter, the options for individual transport must be activated with itOptionsActive=1. Possible values are 1, true, on
  ///@param elevFac This parameter specifies the maximum slope for bike routes. Roads with a slope greater than the specified?? one are avoided. The slope is specified by a factor <factor> whose value range is [0..100]. By default, the value of the parameter is 50
  Future<chopper.Response<TripRequestResponse>> tripGet({
    required enums.TripGetOutputFormat? outputFormat,
    required enums.TripGetCoordOutputFormat? coordOutputFormat,
    required enums.TripGetDepArrMacro? depArrMacro,
    String? itdDate,
    String? itdTime,
    required enums.TripGetTypeOrigin? typeOrigin,
    required String? nameOrigin,
    required enums.TripGetTypeDestination? typeDestination,
    required String? nameDestination,
    int? calcNumberOfTrips,
    enums.TripGetWheelchair? wheelchair,
    enums.TripGetExcludedMeans? excludedMeans,
    enums.TripGetExclMOT1? exclMOT1,
    enums.TripGetExclMOT2? exclMOT2,
    enums.TripGetExclMOT4? exclMOT4,
    enums.TripGetExclMOT5? exclMOT5,
    enums.TripGetExclMOT7? exclMOT7,
    enums.TripGetExclMOT9? exclMOT9,
    enums.TripGetExclMOT11? exclMOT11,
    enums.TripGetTfNSWTR? tfNSWTR,
    String? version,
    int? itOptionsActive,
    bool? computeMonomodalTripBicycle,
    int? cycleSpeed,
    enums.TripGetBikeProfSpeed? bikeProfSpeed,
    int? maxTimeBicycle,
    int? onlyITBicycle,
    int? useElevationData,
    int? elevFac,
  }) {
    generatedMapping.putIfAbsent(
        TripRequestResponse, () => TripRequestResponse.fromJsonFactory);

    return _tripGet(
        outputFormat: outputFormat?.value?.toString(),
        coordOutputFormat: coordOutputFormat?.value?.toString(),
        depArrMacro: depArrMacro?.value?.toString(),
        itdDate: itdDate,
        itdTime: itdTime,
        typeOrigin: typeOrigin?.value?.toString(),
        nameOrigin: nameOrigin,
        typeDestination: typeDestination?.value?.toString(),
        nameDestination: nameDestination,
        calcNumberOfTrips: calcNumberOfTrips,
        wheelchair: wheelchair?.value?.toString(),
        excludedMeans: excludedMeans?.value?.toString(),
        exclMOT1: exclMOT1?.value?.toString(),
        exclMOT2: exclMOT2?.value?.toString(),
        exclMOT4: exclMOT4?.value?.toString(),
        exclMOT5: exclMOT5?.value?.toString(),
        exclMOT7: exclMOT7?.value?.toString(),
        exclMOT9: exclMOT9?.value?.toString(),
        exclMOT11: exclMOT11?.value?.toString(),
        tfNSWTR: tfNSWTR?.value?.toString(),
        version: version,
        itOptionsActive: itOptionsActive,
        computeMonomodalTripBicycle: computeMonomodalTripBicycle,
        cycleSpeed: cycleSpeed,
        bikeProfSpeed: bikeProfSpeed?.value?.toString(),
        maxTimeBicycle: maxTimeBicycle,
        onlyITBicycle: onlyITBicycle,
        useElevationData: useElevationData,
        elevFac: elevFac);
  }

  ///Provides capability to provide NSW public transport trip plan options, including walking and driving legs and real-time information.
  ///@param outputFormat Used to set the response data type. This documentation only covers responses that use the JSON format. Setting the `outputFormat` value to `rapidJSON` is required to enable JSON output.
  ///@param coordOutputFormat This specifies the format the coordinates are returned in. While other variations are available, the `EPSG:4326` format will return the widely-used format.
  ///@param depArrMacro This value anchors the requested date time. If set to `dep`, then trips *departing after* the specified date/time *at the specified location* are included. If set to `arr`, then trips *arriving before* the specified time *at its destination stop* are included. Works in conjunctions with the `itdDate` and `itdTime` values.
  ///@param itdDate The reference date used when searching trips, in `YYYYMMDD` format. For instance, `20160901` refers to 1 September 2016. Works in conjunction with the `itdTime` and `depArrMacro` values. If not specified, the current server date is used.
  ///@param itdTime The reference time used when searching trips, in `HHMM` 24-hour format. For instance, `2215` refers to 10:15 PM. | Works in conjunction with the `itdDate` and `depArrMacro` values. If not specified, the current server time is used.
  ///@param type_origin This is the type of data specified in the `name_origin` field. The origin indicates the starting point when searching for journeys. The best way to use the trip planner is to use use `any` for this field then specify a valid location ID in `type_origin`, or to use `coord` in this field and a correctly formatted coordinate in `type_origin`.
  ///@param name_origin This value is used to indicate the starting point when searching for journeys. This value can be one of three things: A valid location/stop ID (for example, `10101100` indicates Central Station - this can be determined using `stop_finder`). A valid global stop ID (for example, `200060` indicates Central Station - this can be determined using `stop_finder`) Coordinates in the format `LONGITUDE:LATITUDE:EPSG:4326` (Note that longitude is first).
  ///@param type_destination This is the type of data specified in the `name_destination` field. The origin indicates the finishing point when searching for journeys. The best way to use the trip planner is to use use `any` for this field then specify a valid location ID in `type_destination`, or to use `coord` in this field and a correctly formatted coordinate in `type_destination`.
  ///@param name_destination This value is used to indicate the finishing point when searching for journeys. This value can be one of three things: A valid location/stop ID (for example, `10101100` indicates Central Station - this can be determined using `stop_finder`). A valid global stop ID (for example, `200060` indicates Central Station - this can be determined using `stop_finder`) Coordinates in the format `LONGITUDE:LATITUDE:EPSG:4326` (Note that longitude is first).
  ///@param calcNumberOfTrips This parameter indicates the maximum number of trips to returned. Fewer trips may be returned anyway, depending on the available public transport services.
  ///@param wheelchair Including this parameter (regardless of its value) ensures that only wheelchair-accessible options are returned.
  ///@param excludedMeans This parameter which means of transport to exclude from the trip plan. To exclude one means, select one of the following: `1` = train, `2` = metro, `4` = light rail, `5` = bus, `7` = coach, `9` = ferry, `11` = school bus. `checkbox` allows you to exclude more than one means of transport when used in conjunction with the `exclMOT_<ID>` parameters.
  ///@param exclMOT_1 Excludes train services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_2 Excludes metro services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_4 Excludes light rail services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_5 Excludes bus services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_7 Excludes coach services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_9 Excludes ferry services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param exclMOT_11 Excludes school bus services from the trip plan.  Must be used in conjunction with `excludedMeans=checkbox`
  ///@param TfNSWTR Including this parameter enables a number of options that result in this API call operating in the same way as the Transport for NSW Trip Planner web site, including enabling real-time data.
  ///@param version Indicates which version of the API the caller is expecting for both request and response data. Note that if this version differs from the version listed above then the returned data may not be as expected.
  ///@param itOptionsActive This parameter activates the options for individual transport. If the parameter is disabled, the parameters concerning individual transport will not be taken into account. possible values are 0 and 1
  ///@param computeMonomodalTripBicycle Activates the calculation of a monomodal trip, i.e., a trip that takes place exclusively with the means of transport <means of transport>, e.g., with bicycle. Note 1: In order to use this parameter, the options for individual transport must be activated with itOptionsActive=1. Note 2: If no monomodal trip with the means of transport <means of transport> is calculated despite the parameter, the maximum time is often set too low. The parameter MaxITTime applies to all means of transport, the parameter MaxITTime<means of transport>to the means of transport <means of transport> (e.g., MaxITTime107). These parameters are located in the [Parameters] section or are added to it. The configuration can be alternatively overridden bythe maxTime<Transport means> parameter.
  ///@param cycleSpeed The value of the <speed> parameter is used to specify the speed of cycle travel in kilometers per hour.Note: In order to use this parameter, the options for individual transport must be activated with itOptionsActive=1. If the parameter is to be specified together with a profile, the bikeProfSpeed parameter can be used.The parameter “'cycleSpeed” specifies the desired real speed of the user for the bike route, which overwrites the speed in the SpeedSettings of the corresponding “bikeProfSpeed”.
  ///@param bikeProfSpeed With the parameter 'bikeProfSpeed' a bike profile name is passed
  ///@param maxTimeBicycle The value of the this parameter sets the maximum time to be covered by the means of cycling. The time is specified in minutes. Note: To use this parameter, the options for individual transport must be enabled with itOptionsActive=1
  ///@param onlyITBicycle Restricts the calculation to trips with the bikes only. Note: To be able to use this parameter, the options for individual transport must be activated with itOptionsActive=1. Possible values are 1, true, on
  ///@param useElevationData If this parameter is active, the elevation data is taken into account in the trip calculation for all means of transport and output in a route description for each individual transport section. Note: To be able to use this parameter, the options for individual transport must be activated with itOptionsActive=1. Possible values are 1, true, on
  ///@param elevFac This parameter specifies the maximum slope for bike routes. Roads with a slope greater than the specified?? one are avoided. The slope is specified by a factor <factor> whose value range is [0..100]. By default, the value of the parameter is 50
  @Get(path: '/trip')
  Future<chopper.Response<TripRequestResponse>> _tripGet({
    @Query('outputFormat') required String? outputFormat,
    @Query('coordOutputFormat') required String? coordOutputFormat,
    @Query('depArrMacro') required String? depArrMacro,
    @Query('itdDate') String? itdDate,
    @Query('itdTime') String? itdTime,
    @Query('type_origin') required String? typeOrigin,
    @Query('name_origin') required String? nameOrigin,
    @Query('type_destination') required String? typeDestination,
    @Query('name_destination') required String? nameDestination,
    @Query('calcNumberOfTrips') int? calcNumberOfTrips,
    @Query('wheelchair') String? wheelchair,
    @Query('excludedMeans') String? excludedMeans,
    @Query('exclMOT_1') String? exclMOT1,
    @Query('exclMOT_2') String? exclMOT2,
    @Query('exclMOT_4') String? exclMOT4,
    @Query('exclMOT_5') String? exclMOT5,
    @Query('exclMOT_7') String? exclMOT7,
    @Query('exclMOT_9') String? exclMOT9,
    @Query('exclMOT_11') String? exclMOT11,
    @Query('TfNSWTR') String? tfNSWTR,
    @Query('version') String? version,
    @Query('itOptionsActive') int? itOptionsActive,
    @Query('computeMonomodalTripBicycle') bool? computeMonomodalTripBicycle,
    @Query('cycleSpeed') int? cycleSpeed,
    @Query('bikeProfSpeed') String? bikeProfSpeed,
    @Query('maxTimeBicycle') int? maxTimeBicycle,
    @Query('onlyITBicycle') int? onlyITBicycle,
    @Query('useElevationData') int? useElevationData,
    @Query('elevFac') int? elevFac,
  });
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponse {
  const AdditionalInfoResponse({
    this.error,
    this.infos,
    this.timestamp,
    this.version,
  });

  factory AdditionalInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$AdditionalInfoResponseFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponseToJson;
  Map<String, dynamic> toJson() => _$AdditionalInfoResponseToJson(this);

  @JsonKey(name: 'error')
  final ApiErrorResponse? error;
  @JsonKey(name: 'infos')
  final AdditionalInfoResponse$Infos? infos;
  @JsonKey(name: 'timestamp')
  final String? timestamp;
  @JsonKey(name: 'version')
  final String? version;
  static const fromJsonFactory = _$AdditionalInfoResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponse &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.infos, infos) ||
                const DeepCollectionEquality().equals(other.infos, infos)) &&
            (identical(other.timestamp, timestamp) ||
                const DeepCollectionEquality()
                    .equals(other.timestamp, timestamp)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(infos) ^
      const DeepCollectionEquality().hash(timestamp) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseExtension on AdditionalInfoResponse {
  AdditionalInfoResponse copyWith(
      {ApiErrorResponse? error,
      AdditionalInfoResponse$Infos? infos,
      String? timestamp,
      String? version}) {
    return AdditionalInfoResponse(
        error: error ?? this.error,
        infos: infos ?? this.infos,
        timestamp: timestamp ?? this.timestamp,
        version: version ?? this.version);
  }

  AdditionalInfoResponse copyWithWrapped(
      {Wrapped<ApiErrorResponse?>? error,
      Wrapped<AdditionalInfoResponse$Infos?>? infos,
      Wrapped<String?>? timestamp,
      Wrapped<String?>? version}) {
    return AdditionalInfoResponse(
        error: (error != null ? error.value : this.error),
        infos: (infos != null ? infos.value : this.infos),
        timestamp: (timestamp != null ? timestamp.value : this.timestamp),
        version: (version != null ? version.value : this.version));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseAffectedLine {
  const AdditionalInfoResponseAffectedLine({
    this.destination,
    this.id,
    this.name,
    this.number,
    this.product,
  });

  factory AdditionalInfoResponseAffectedLine.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseAffectedLineFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponseAffectedLineToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseAffectedLineToJson(this);

  @JsonKey(name: 'destination')
  final AdditionalInfoResponseAffectedLine$Destination? destination;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'number')
  final String? number;
  @JsonKey(name: 'product')
  final RouteProduct? product;
  static const fromJsonFactory = _$AdditionalInfoResponseAffectedLineFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseAffectedLine &&
            (identical(other.destination, destination) ||
                const DeepCollectionEquality()
                    .equals(other.destination, destination)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.number, number) ||
                const DeepCollectionEquality().equals(other.number, number)) &&
            (identical(other.product, product) ||
                const DeepCollectionEquality().equals(other.product, product)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(destination) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(number) ^
      const DeepCollectionEquality().hash(product) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseAffectedLineExtension
    on AdditionalInfoResponseAffectedLine {
  AdditionalInfoResponseAffectedLine copyWith(
      {AdditionalInfoResponseAffectedLine$Destination? destination,
      String? id,
      String? name,
      String? number,
      RouteProduct? product}) {
    return AdditionalInfoResponseAffectedLine(
        destination: destination ?? this.destination,
        id: id ?? this.id,
        name: name ?? this.name,
        number: number ?? this.number,
        product: product ?? this.product);
  }

  AdditionalInfoResponseAffectedLine copyWithWrapped(
      {Wrapped<AdditionalInfoResponseAffectedLine$Destination?>? destination,
      Wrapped<String?>? id,
      Wrapped<String?>? name,
      Wrapped<String?>? number,
      Wrapped<RouteProduct?>? product}) {
    return AdditionalInfoResponseAffectedLine(
        destination:
            (destination != null ? destination.value : this.destination),
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        number: (number != null ? number.value : this.number),
        product: (product != null ? product.value : this.product));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseAffectedStop {
  const AdditionalInfoResponseAffectedStop({
    this.id,
    this.name,
    this.parent,
    this.type,
  });

  factory AdditionalInfoResponseAffectedStop.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseAffectedStopFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponseAffectedStopToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseAffectedStopToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'parent')
  final ParentLocation? parent;
  @JsonKey(
    name: 'type',
    toJson: additionalInfoResponseAffectedStopTypeNullableToJson,
    fromJson: additionalInfoResponseAffectedStopTypeNullableFromJson,
  )
  final enums.AdditionalInfoResponseAffectedStopType? type;
  static const fromJsonFactory = _$AdditionalInfoResponseAffectedStopFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseAffectedStop &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.parent, parent) ||
                const DeepCollectionEquality().equals(other.parent, parent)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(parent) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseAffectedStopExtension
    on AdditionalInfoResponseAffectedStop {
  AdditionalInfoResponseAffectedStop copyWith(
      {String? id,
      String? name,
      ParentLocation? parent,
      enums.AdditionalInfoResponseAffectedStopType? type}) {
    return AdditionalInfoResponseAffectedStop(
        id: id ?? this.id,
        name: name ?? this.name,
        parent: parent ?? this.parent,
        type: type ?? this.type);
  }

  AdditionalInfoResponseAffectedStop copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<String?>? name,
      Wrapped<ParentLocation?>? parent,
      Wrapped<enums.AdditionalInfoResponseAffectedStopType?>? type}) {
    return AdditionalInfoResponseAffectedStop(
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        parent: (parent != null ? parent.value : this.parent),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseMessage {
  const AdditionalInfoResponseMessage({
    this.affected,
    this.content,
    this.id,
    this.priority,
    this.properties,
    this.subtitle,
    this.timestamps,
    this.type,
    this.url,
    this.urlText,
    this.version,
  });

  factory AdditionalInfoResponseMessage.fromJson(Map<String, dynamic> json) =>
      _$AdditionalInfoResponseMessageFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponseMessageToJson;
  Map<String, dynamic> toJson() => _$AdditionalInfoResponseMessageToJson(this);

  @JsonKey(name: 'affected')
  final AdditionalInfoResponseMessage$Affected? affected;
  @JsonKey(name: 'content')
  final String? content;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(
    name: 'priority',
    toJson: additionalInfoResponseMessagePriorityNullableToJson,
    fromJson: additionalInfoResponseMessagePriorityNullableFromJson,
  )
  final enums.AdditionalInfoResponseMessagePriority? priority;
  @JsonKey(name: 'properties')
  final AdditionalInfoResponseMessage$Properties? properties;
  @JsonKey(name: 'subtitle')
  final String? subtitle;
  @JsonKey(name: 'timestamps')
  final AdditionalInfoResponseTimestamps? timestamps;
  @JsonKey(
    name: 'type',
    toJson: additionalInfoResponseMessageTypeNullableToJson,
    fromJson: additionalInfoResponseMessageTypeNullableFromJson,
  )
  final enums.AdditionalInfoResponseMessageType? type;
  @JsonKey(name: 'url')
  final String? url;
  @JsonKey(name: 'urlText')
  final String? urlText;
  @JsonKey(name: 'version')
  final int? version;
  static const fromJsonFactory = _$AdditionalInfoResponseMessageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseMessage &&
            (identical(other.affected, affected) ||
                const DeepCollectionEquality()
                    .equals(other.affected, affected)) &&
            (identical(other.content, content) ||
                const DeepCollectionEquality()
                    .equals(other.content, content)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.priority, priority) ||
                const DeepCollectionEquality()
                    .equals(other.priority, priority)) &&
            (identical(other.properties, properties) ||
                const DeepCollectionEquality()
                    .equals(other.properties, properties)) &&
            (identical(other.subtitle, subtitle) ||
                const DeepCollectionEquality()
                    .equals(other.subtitle, subtitle)) &&
            (identical(other.timestamps, timestamps) ||
                const DeepCollectionEquality()
                    .equals(other.timestamps, timestamps)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.url, url) ||
                const DeepCollectionEquality().equals(other.url, url)) &&
            (identical(other.urlText, urlText) ||
                const DeepCollectionEquality()
                    .equals(other.urlText, urlText)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(affected) ^
      const DeepCollectionEquality().hash(content) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(priority) ^
      const DeepCollectionEquality().hash(properties) ^
      const DeepCollectionEquality().hash(subtitle) ^
      const DeepCollectionEquality().hash(timestamps) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(url) ^
      const DeepCollectionEquality().hash(urlText) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseMessageExtension
    on AdditionalInfoResponseMessage {
  AdditionalInfoResponseMessage copyWith(
      {AdditionalInfoResponseMessage$Affected? affected,
      String? content,
      String? id,
      enums.AdditionalInfoResponseMessagePriority? priority,
      AdditionalInfoResponseMessage$Properties? properties,
      String? subtitle,
      AdditionalInfoResponseTimestamps? timestamps,
      enums.AdditionalInfoResponseMessageType? type,
      String? url,
      String? urlText,
      int? version}) {
    return AdditionalInfoResponseMessage(
        affected: affected ?? this.affected,
        content: content ?? this.content,
        id: id ?? this.id,
        priority: priority ?? this.priority,
        properties: properties ?? this.properties,
        subtitle: subtitle ?? this.subtitle,
        timestamps: timestamps ?? this.timestamps,
        type: type ?? this.type,
        url: url ?? this.url,
        urlText: urlText ?? this.urlText,
        version: version ?? this.version);
  }

  AdditionalInfoResponseMessage copyWithWrapped(
      {Wrapped<AdditionalInfoResponseMessage$Affected?>? affected,
      Wrapped<String?>? content,
      Wrapped<String?>? id,
      Wrapped<enums.AdditionalInfoResponseMessagePriority?>? priority,
      Wrapped<AdditionalInfoResponseMessage$Properties?>? properties,
      Wrapped<String?>? subtitle,
      Wrapped<AdditionalInfoResponseTimestamps?>? timestamps,
      Wrapped<enums.AdditionalInfoResponseMessageType?>? type,
      Wrapped<String?>? url,
      Wrapped<String?>? urlText,
      Wrapped<int?>? version}) {
    return AdditionalInfoResponseMessage(
        affected: (affected != null ? affected.value : this.affected),
        content: (content != null ? content.value : this.content),
        id: (id != null ? id.value : this.id),
        priority: (priority != null ? priority.value : this.priority),
        properties: (properties != null ? properties.value : this.properties),
        subtitle: (subtitle != null ? subtitle.value : this.subtitle),
        timestamps: (timestamps != null ? timestamps.value : this.timestamps),
        type: (type != null ? type.value : this.type),
        url: (url != null ? url.value : this.url),
        urlText: (urlText != null ? urlText.value : this.urlText),
        version: (version != null ? version.value : this.version));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseTimestamps {
  const AdditionalInfoResponseTimestamps({
    this.availability,
    this.creation,
    this.lastModification,
    this.validity,
  });

  factory AdditionalInfoResponseTimestamps.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseTimestampsFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponseTimestampsToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseTimestampsToJson(this);

  @JsonKey(name: 'availability')
  final AdditionalInfoResponseTimestamps$Availability? availability;
  @JsonKey(name: 'creation')
  final String? creation;
  @JsonKey(name: 'lastModification')
  final String? lastModification;
  @JsonKey(name: 'validity')
  final List<AdditionalInfoResponseTimestamps$Validity$Item>? validity;
  static const fromJsonFactory = _$AdditionalInfoResponseTimestampsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseTimestamps &&
            (identical(other.availability, availability) ||
                const DeepCollectionEquality()
                    .equals(other.availability, availability)) &&
            (identical(other.creation, creation) ||
                const DeepCollectionEquality()
                    .equals(other.creation, creation)) &&
            (identical(other.lastModification, lastModification) ||
                const DeepCollectionEquality()
                    .equals(other.lastModification, lastModification)) &&
            (identical(other.validity, validity) ||
                const DeepCollectionEquality()
                    .equals(other.validity, validity)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(availability) ^
      const DeepCollectionEquality().hash(creation) ^
      const DeepCollectionEquality().hash(lastModification) ^
      const DeepCollectionEquality().hash(validity) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseTimestampsExtension
    on AdditionalInfoResponseTimestamps {
  AdditionalInfoResponseTimestamps copyWith(
      {AdditionalInfoResponseTimestamps$Availability? availability,
      String? creation,
      String? lastModification,
      List<AdditionalInfoResponseTimestamps$Validity$Item>? validity}) {
    return AdditionalInfoResponseTimestamps(
        availability: availability ?? this.availability,
        creation: creation ?? this.creation,
        lastModification: lastModification ?? this.lastModification,
        validity: validity ?? this.validity);
  }

  AdditionalInfoResponseTimestamps copyWithWrapped(
      {Wrapped<AdditionalInfoResponseTimestamps$Availability?>? availability,
      Wrapped<String?>? creation,
      Wrapped<String?>? lastModification,
      Wrapped<List<AdditionalInfoResponseTimestamps$Validity$Item>?>?
          validity}) {
    return AdditionalInfoResponseTimestamps(
        availability:
            (availability != null ? availability.value : this.availability),
        creation: (creation != null ? creation.value : this.creation),
        lastModification: (lastModification != null
            ? lastModification.value
            : this.lastModification),
        validity: (validity != null ? validity.value : this.validity));
  }
}

@JsonSerializable(explicitToJson: true)
class ApiErrorResponse {
  const ApiErrorResponse({
    this.message,
    this.versions,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseFromJson(json);

  static const toJsonFactory = _$ApiErrorResponseToJson;
  Map<String, dynamic> toJson() => _$ApiErrorResponseToJson(this);

  @JsonKey(name: 'message')
  final String? message;
  @JsonKey(name: 'versions')
  final ApiErrorResponse$Versions? versions;
  static const fromJsonFactory = _$ApiErrorResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiErrorResponse &&
            (identical(other.message, message) ||
                const DeepCollectionEquality()
                    .equals(other.message, message)) &&
            (identical(other.versions, versions) ||
                const DeepCollectionEquality()
                    .equals(other.versions, versions)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(versions) ^
      runtimeType.hashCode;
}

extension $ApiErrorResponseExtension on ApiErrorResponse {
  ApiErrorResponse copyWith(
      {String? message, ApiErrorResponse$Versions? versions}) {
    return ApiErrorResponse(
        message: message ?? this.message, versions: versions ?? this.versions);
  }

  ApiErrorResponse copyWithWrapped(
      {Wrapped<String?>? message,
      Wrapped<ApiErrorResponse$Versions?>? versions}) {
    return ApiErrorResponse(
        message: (message != null ? message.value : this.message),
        versions: (versions != null ? versions.value : this.versions));
  }
}

@JsonSerializable(explicitToJson: true)
class CoordRequestResponse {
  const CoordRequestResponse({
    this.error,
    this.locations,
    this.version,
  });

  factory CoordRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$CoordRequestResponseFromJson(json);

  static const toJsonFactory = _$CoordRequestResponseToJson;
  Map<String, dynamic> toJson() => _$CoordRequestResponseToJson(this);

  @JsonKey(name: 'error')
  final ApiErrorResponse? error;
  @JsonKey(name: 'locations', defaultValue: <CoordRequestResponseLocation>[])
  final List<CoordRequestResponseLocation>? locations;
  @JsonKey(name: 'version')
  final String? version;
  static const fromJsonFactory = _$CoordRequestResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CoordRequestResponse &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.locations, locations) ||
                const DeepCollectionEquality()
                    .equals(other.locations, locations)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(locations) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $CoordRequestResponseExtension on CoordRequestResponse {
  CoordRequestResponse copyWith(
      {ApiErrorResponse? error,
      List<CoordRequestResponseLocation>? locations,
      String? version}) {
    return CoordRequestResponse(
        error: error ?? this.error,
        locations: locations ?? this.locations,
        version: version ?? this.version);
  }

  CoordRequestResponse copyWithWrapped(
      {Wrapped<ApiErrorResponse?>? error,
      Wrapped<List<CoordRequestResponseLocation>?>? locations,
      Wrapped<String?>? version}) {
    return CoordRequestResponse(
        error: (error != null ? error.value : this.error),
        locations: (locations != null ? locations.value : this.locations),
        version: (version != null ? version.value : this.version));
  }
}

@JsonSerializable(explicitToJson: true)
class CoordRequestResponseLocation {
  const CoordRequestResponseLocation({
    this.coord,
    this.disassembledName,
    this.id,
    this.name,
    this.parent,
    this.properties,
    this.type,
  });

  factory CoordRequestResponseLocation.fromJson(Map<String, dynamic> json) =>
      _$CoordRequestResponseLocationFromJson(json);

  static const toJsonFactory = _$CoordRequestResponseLocationToJson;
  Map<String, dynamic> toJson() => _$CoordRequestResponseLocationToJson(this);

  @JsonKey(name: 'coord', defaultValue: <double>[])
  final List<double>? coord;
  @JsonKey(name: 'disassembledName')
  final String? disassembledName;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'parent')
  final ParentLocation? parent;
  @JsonKey(name: 'properties')
  final CoordRequestResponseLocation$Properties? properties;
  @JsonKey(
    name: 'type',
    toJson: coordRequestResponseLocationTypeNullableToJson,
    fromJson: coordRequestResponseLocationTypeNullableFromJson,
  )
  final enums.CoordRequestResponseLocationType? type;
  static const fromJsonFactory = _$CoordRequestResponseLocationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CoordRequestResponseLocation &&
            (identical(other.coord, coord) ||
                const DeepCollectionEquality().equals(other.coord, coord)) &&
            (identical(other.disassembledName, disassembledName) ||
                const DeepCollectionEquality()
                    .equals(other.disassembledName, disassembledName)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.parent, parent) ||
                const DeepCollectionEquality().equals(other.parent, parent)) &&
            (identical(other.properties, properties) ||
                const DeepCollectionEquality()
                    .equals(other.properties, properties)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(coord) ^
      const DeepCollectionEquality().hash(disassembledName) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(parent) ^
      const DeepCollectionEquality().hash(properties) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $CoordRequestResponseLocationExtension
    on CoordRequestResponseLocation {
  CoordRequestResponseLocation copyWith(
      {List<double>? coord,
      String? disassembledName,
      String? id,
      String? name,
      ParentLocation? parent,
      CoordRequestResponseLocation$Properties? properties,
      enums.CoordRequestResponseLocationType? type}) {
    return CoordRequestResponseLocation(
        coord: coord ?? this.coord,
        disassembledName: disassembledName ?? this.disassembledName,
        id: id ?? this.id,
        name: name ?? this.name,
        parent: parent ?? this.parent,
        properties: properties ?? this.properties,
        type: type ?? this.type);
  }

  CoordRequestResponseLocation copyWithWrapped(
      {Wrapped<List<double>?>? coord,
      Wrapped<String?>? disassembledName,
      Wrapped<String?>? id,
      Wrapped<String?>? name,
      Wrapped<ParentLocation?>? parent,
      Wrapped<CoordRequestResponseLocation$Properties?>? properties,
      Wrapped<enums.CoordRequestResponseLocationType?>? type}) {
    return CoordRequestResponseLocation(
        coord: (coord != null ? coord.value : this.coord),
        disassembledName: (disassembledName != null
            ? disassembledName.value
            : this.disassembledName),
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        parent: (parent != null ? parent.value : this.parent),
        properties: (properties != null ? properties.value : this.properties),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class DepartureMonitorResponse {
  const DepartureMonitorResponse({
    this.error,
    this.locations,
    this.stopEvents,
    this.version,
  });

  factory DepartureMonitorResponse.fromJson(Map<String, dynamic> json) =>
      _$DepartureMonitorResponseFromJson(json);

  static const toJsonFactory = _$DepartureMonitorResponseToJson;
  Map<String, dynamic> toJson() => _$DepartureMonitorResponseToJson(this);

  @JsonKey(name: 'error')
  final ApiErrorResponse? error;
  @JsonKey(name: 'locations', defaultValue: <StopFinderLocation>[])
  final List<StopFinderLocation>? locations;
  @JsonKey(
      name: 'stopEvents', defaultValue: <DepartureMonitorResponseStopEvent>[])
  final List<DepartureMonitorResponseStopEvent>? stopEvents;
  @JsonKey(name: 'version')
  final String? version;
  static const fromJsonFactory = _$DepartureMonitorResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DepartureMonitorResponse &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.locations, locations) ||
                const DeepCollectionEquality()
                    .equals(other.locations, locations)) &&
            (identical(other.stopEvents, stopEvents) ||
                const DeepCollectionEquality()
                    .equals(other.stopEvents, stopEvents)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(locations) ^
      const DeepCollectionEquality().hash(stopEvents) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $DepartureMonitorResponseExtension on DepartureMonitorResponse {
  DepartureMonitorResponse copyWith(
      {ApiErrorResponse? error,
      List<StopFinderLocation>? locations,
      List<DepartureMonitorResponseStopEvent>? stopEvents,
      String? version}) {
    return DepartureMonitorResponse(
        error: error ?? this.error,
        locations: locations ?? this.locations,
        stopEvents: stopEvents ?? this.stopEvents,
        version: version ?? this.version);
  }

  DepartureMonitorResponse copyWithWrapped(
      {Wrapped<ApiErrorResponse?>? error,
      Wrapped<List<StopFinderLocation>?>? locations,
      Wrapped<List<DepartureMonitorResponseStopEvent>?>? stopEvents,
      Wrapped<String?>? version}) {
    return DepartureMonitorResponse(
        error: (error != null ? error.value : this.error),
        locations: (locations != null ? locations.value : this.locations),
        stopEvents: (stopEvents != null ? stopEvents.value : this.stopEvents),
        version: (version != null ? version.value : this.version));
  }
}

@JsonSerializable(explicitToJson: true)
class DepartureMonitorResponseStopEvent {
  const DepartureMonitorResponseStopEvent({
    this.departureTimePlanned,
    this.infos,
    this.location,
    this.transportation,
  });

  factory DepartureMonitorResponseStopEvent.fromJson(
          Map<String, dynamic> json) =>
      _$DepartureMonitorResponseStopEventFromJson(json);

  static const toJsonFactory = _$DepartureMonitorResponseStopEventToJson;
  Map<String, dynamic> toJson() =>
      _$DepartureMonitorResponseStopEventToJson(this);

  @JsonKey(name: 'departureTimePlanned')
  final String? departureTimePlanned;
  @JsonKey(
      name: 'infos', defaultValue: <TripRequestResponseJourneyLegStopInfo>[])
  final List<TripRequestResponseJourneyLegStopInfo>? infos;
  @JsonKey(name: 'location')
  final StopFinderLocation? location;
  @JsonKey(name: 'transportation')
  final TripTransportation? transportation;
  static const fromJsonFactory = _$DepartureMonitorResponseStopEventFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DepartureMonitorResponseStopEvent &&
            (identical(other.departureTimePlanned, departureTimePlanned) ||
                const DeepCollectionEquality().equals(
                    other.departureTimePlanned, departureTimePlanned)) &&
            (identical(other.infos, infos) ||
                const DeepCollectionEquality().equals(other.infos, infos)) &&
            (identical(other.location, location) ||
                const DeepCollectionEquality()
                    .equals(other.location, location)) &&
            (identical(other.transportation, transportation) ||
                const DeepCollectionEquality()
                    .equals(other.transportation, transportation)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(departureTimePlanned) ^
      const DeepCollectionEquality().hash(infos) ^
      const DeepCollectionEquality().hash(location) ^
      const DeepCollectionEquality().hash(transportation) ^
      runtimeType.hashCode;
}

extension $DepartureMonitorResponseStopEventExtension
    on DepartureMonitorResponseStopEvent {
  DepartureMonitorResponseStopEvent copyWith(
      {String? departureTimePlanned,
      List<TripRequestResponseJourneyLegStopInfo>? infos,
      StopFinderLocation? location,
      TripTransportation? transportation}) {
    return DepartureMonitorResponseStopEvent(
        departureTimePlanned: departureTimePlanned ?? this.departureTimePlanned,
        infos: infos ?? this.infos,
        location: location ?? this.location,
        transportation: transportation ?? this.transportation);
  }

  DepartureMonitorResponseStopEvent copyWithWrapped(
      {Wrapped<String?>? departureTimePlanned,
      Wrapped<List<TripRequestResponseJourneyLegStopInfo>?>? infos,
      Wrapped<StopFinderLocation?>? location,
      Wrapped<TripTransportation?>? transportation}) {
    return DepartureMonitorResponseStopEvent(
        departureTimePlanned: (departureTimePlanned != null
            ? departureTimePlanned.value
            : this.departureTimePlanned),
        infos: (infos != null ? infos.value : this.infos),
        location: (location != null ? location.value : this.location),
        transportation: (transportation != null
            ? transportation.value
            : this.transportation));
  }
}

@JsonSerializable(explicitToJson: true)
class HttpErrorResponse {
  const HttpErrorResponse({
    this.errorDateTime,
    this.message,
    this.requestedMethod,
    this.requestedUrl,
    this.transactionId,
  });

  factory HttpErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$HttpErrorResponseFromJson(json);

  static const toJsonFactory = _$HttpErrorResponseToJson;
  Map<String, dynamic> toJson() => _$HttpErrorResponseToJson(this);

  @JsonKey(name: 'ErrorDateTime')
  final String? errorDateTime;
  @JsonKey(name: 'Message')
  final String? message;
  @JsonKey(name: 'RequestedMethod')
  final String? requestedMethod;
  @JsonKey(name: 'RequestedUrl')
  final String? requestedUrl;
  @JsonKey(name: 'TransactionId')
  final String? transactionId;
  static const fromJsonFactory = _$HttpErrorResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HttpErrorResponse &&
            (identical(other.errorDateTime, errorDateTime) ||
                const DeepCollectionEquality()
                    .equals(other.errorDateTime, errorDateTime)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality()
                    .equals(other.message, message)) &&
            (identical(other.requestedMethod, requestedMethod) ||
                const DeepCollectionEquality()
                    .equals(other.requestedMethod, requestedMethod)) &&
            (identical(other.requestedUrl, requestedUrl) ||
                const DeepCollectionEquality()
                    .equals(other.requestedUrl, requestedUrl)) &&
            (identical(other.transactionId, transactionId) ||
                const DeepCollectionEquality()
                    .equals(other.transactionId, transactionId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(errorDateTime) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(requestedMethod) ^
      const DeepCollectionEquality().hash(requestedUrl) ^
      const DeepCollectionEquality().hash(transactionId) ^
      runtimeType.hashCode;
}

extension $HttpErrorResponseExtension on HttpErrorResponse {
  HttpErrorResponse copyWith(
      {String? errorDateTime,
      String? message,
      String? requestedMethod,
      String? requestedUrl,
      String? transactionId}) {
    return HttpErrorResponse(
        errorDateTime: errorDateTime ?? this.errorDateTime,
        message: message ?? this.message,
        requestedMethod: requestedMethod ?? this.requestedMethod,
        requestedUrl: requestedUrl ?? this.requestedUrl,
        transactionId: transactionId ?? this.transactionId);
  }

  HttpErrorResponse copyWithWrapped(
      {Wrapped<String?>? errorDateTime,
      Wrapped<String?>? message,
      Wrapped<String?>? requestedMethod,
      Wrapped<String?>? requestedUrl,
      Wrapped<String?>? transactionId}) {
    return HttpErrorResponse(
        errorDateTime:
            (errorDateTime != null ? errorDateTime.value : this.errorDateTime),
        message: (message != null ? message.value : this.message),
        requestedMethod: (requestedMethod != null
            ? requestedMethod.value
            : this.requestedMethod),
        requestedUrl:
            (requestedUrl != null ? requestedUrl.value : this.requestedUrl),
        transactionId:
            (transactionId != null ? transactionId.value : this.transactionId));
  }
}

@JsonSerializable(explicitToJson: true)
class ParentLocation {
  const ParentLocation({
    this.disassembledName,
    this.id,
    this.name,
    this.parent,
    this.type,
  });

  factory ParentLocation.fromJson(Map<String, dynamic> json) =>
      _$ParentLocationFromJson(json);

  static const toJsonFactory = _$ParentLocationToJson;
  Map<String, dynamic> toJson() => _$ParentLocationToJson(this);

  @JsonKey(name: 'disassembledName')
  final String? disassembledName;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'parent')
  final ParentLocation? parent;
  @JsonKey(
    name: 'type',
    toJson: parentLocationTypeNullableToJson,
    fromJson: parentLocationTypeNullableFromJson,
  )
  final enums.ParentLocationType? type;
  static const fromJsonFactory = _$ParentLocationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ParentLocation &&
            (identical(other.disassembledName, disassembledName) ||
                const DeepCollectionEquality()
                    .equals(other.disassembledName, disassembledName)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.parent, parent) ||
                const DeepCollectionEquality().equals(other.parent, parent)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disassembledName) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(parent) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $ParentLocationExtension on ParentLocation {
  ParentLocation copyWith(
      {String? disassembledName,
      String? id,
      String? name,
      ParentLocation? parent,
      enums.ParentLocationType? type}) {
    return ParentLocation(
        disassembledName: disassembledName ?? this.disassembledName,
        id: id ?? this.id,
        name: name ?? this.name,
        parent: parent ?? this.parent,
        type: type ?? this.type);
  }

  ParentLocation copyWithWrapped(
      {Wrapped<String?>? disassembledName,
      Wrapped<String?>? id,
      Wrapped<String?>? name,
      Wrapped<ParentLocation?>? parent,
      Wrapped<enums.ParentLocationType?>? type}) {
    return ParentLocation(
        disassembledName: (disassembledName != null
            ? disassembledName.value
            : this.disassembledName),
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        parent: (parent != null ? parent.value : this.parent),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class RouteProduct {
  const RouteProduct({
    this.$class,
    this.iconId,
    this.name,
  });

  factory RouteProduct.fromJson(Map<String, dynamic> json) =>
      _$RouteProductFromJson(json);

  static const toJsonFactory = _$RouteProductToJson;
  Map<String, dynamic> toJson() => _$RouteProductToJson(this);

  @JsonKey(name: 'class')
  final int? $class;
  @JsonKey(name: 'iconId')
  final int? iconId;
  @JsonKey(name: 'name')
  final String? name;
  static const fromJsonFactory = _$RouteProductFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RouteProduct &&
            (identical(other.$class, $class) ||
                const DeepCollectionEquality().equals(other.$class, $class)) &&
            (identical(other.iconId, iconId) ||
                const DeepCollectionEquality().equals(other.iconId, iconId)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($class) ^
      const DeepCollectionEquality().hash(iconId) ^
      const DeepCollectionEquality().hash(name) ^
      runtimeType.hashCode;
}

extension $RouteProductExtension on RouteProduct {
  RouteProduct copyWith({int? $class, int? iconId, String? name}) {
    return RouteProduct(
        $class: $class ?? this.$class,
        iconId: iconId ?? this.iconId,
        name: name ?? this.name);
  }

  RouteProduct copyWithWrapped(
      {Wrapped<int?>? $class, Wrapped<int?>? iconId, Wrapped<String?>? name}) {
    return RouteProduct(
        $class: ($class != null ? $class.value : this.$class),
        iconId: (iconId != null ? iconId.value : this.iconId),
        name: (name != null ? name.value : this.name));
  }
}

@JsonSerializable(explicitToJson: true)
class StopFinderAssignedStop {
  const StopFinderAssignedStop({
    this.connectingMode,
    this.coord,
    this.disassembledName,
    this.distance,
    this.duration,
    this.id,
    this.modes,
    this.name,
    this.parent,
    this.type,
  });

  factory StopFinderAssignedStop.fromJson(Map<String, dynamic> json) =>
      _$StopFinderAssignedStopFromJson(json);

  static const toJsonFactory = _$StopFinderAssignedStopToJson;
  Map<String, dynamic> toJson() => _$StopFinderAssignedStopToJson(this);

  @JsonKey(name: 'connectingMode')
  final int? connectingMode;
  @JsonKey(name: 'coord', defaultValue: <double>[])
  final List<double>? coord;
  @JsonKey(name: 'disassembledName')
  final String? disassembledName;
  @JsonKey(name: 'distance')
  final int? distance;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'modes', defaultValue: <int>[])
  final List<int>? modes;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'parent')
  final ParentLocation? parent;
  @JsonKey(
    name: 'type',
    toJson: stopFinderAssignedStopTypeNullableToJson,
    fromJson: stopFinderAssignedStopTypeNullableFromJson,
  )
  final enums.StopFinderAssignedStopType? type;
  static const fromJsonFactory = _$StopFinderAssignedStopFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StopFinderAssignedStop &&
            (identical(other.connectingMode, connectingMode) ||
                const DeepCollectionEquality()
                    .equals(other.connectingMode, connectingMode)) &&
            (identical(other.coord, coord) ||
                const DeepCollectionEquality().equals(other.coord, coord)) &&
            (identical(other.disassembledName, disassembledName) ||
                const DeepCollectionEquality()
                    .equals(other.disassembledName, disassembledName)) &&
            (identical(other.distance, distance) ||
                const DeepCollectionEquality()
                    .equals(other.distance, distance)) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality()
                    .equals(other.duration, duration)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.modes, modes) ||
                const DeepCollectionEquality().equals(other.modes, modes)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.parent, parent) ||
                const DeepCollectionEquality().equals(other.parent, parent)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(connectingMode) ^
      const DeepCollectionEquality().hash(coord) ^
      const DeepCollectionEquality().hash(disassembledName) ^
      const DeepCollectionEquality().hash(distance) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(modes) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(parent) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $StopFinderAssignedStopExtension on StopFinderAssignedStop {
  StopFinderAssignedStop copyWith(
      {int? connectingMode,
      List<double>? coord,
      String? disassembledName,
      int? distance,
      int? duration,
      String? id,
      List<int>? modes,
      String? name,
      ParentLocation? parent,
      enums.StopFinderAssignedStopType? type}) {
    return StopFinderAssignedStop(
        connectingMode: connectingMode ?? this.connectingMode,
        coord: coord ?? this.coord,
        disassembledName: disassembledName ?? this.disassembledName,
        distance: distance ?? this.distance,
        duration: duration ?? this.duration,
        id: id ?? this.id,
        modes: modes ?? this.modes,
        name: name ?? this.name,
        parent: parent ?? this.parent,
        type: type ?? this.type);
  }

  StopFinderAssignedStop copyWithWrapped(
      {Wrapped<int?>? connectingMode,
      Wrapped<List<double>?>? coord,
      Wrapped<String?>? disassembledName,
      Wrapped<int?>? distance,
      Wrapped<int?>? duration,
      Wrapped<String?>? id,
      Wrapped<List<int>?>? modes,
      Wrapped<String?>? name,
      Wrapped<ParentLocation?>? parent,
      Wrapped<enums.StopFinderAssignedStopType?>? type}) {
    return StopFinderAssignedStop(
        connectingMode: (connectingMode != null
            ? connectingMode.value
            : this.connectingMode),
        coord: (coord != null ? coord.value : this.coord),
        disassembledName: (disassembledName != null
            ? disassembledName.value
            : this.disassembledName),
        distance: (distance != null ? distance.value : this.distance),
        duration: (duration != null ? duration.value : this.duration),
        id: (id != null ? id.value : this.id),
        modes: (modes != null ? modes.value : this.modes),
        name: (name != null ? name.value : this.name),
        parent: (parent != null ? parent.value : this.parent),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class StopFinderLocation {
  const StopFinderLocation({
    this.assignedStops,
    this.buildingNumber,
    this.coord,
    this.disassembledName,
    this.id,
    this.isBest,
    this.isGlobalId,
    this.matchQuality,
    this.modes,
    this.name,
    this.parent,
    this.streetName,
    this.type,
  });

  factory StopFinderLocation.fromJson(Map<String, dynamic> json) =>
      _$StopFinderLocationFromJson(json);

  static const toJsonFactory = _$StopFinderLocationToJson;
  Map<String, dynamic> toJson() => _$StopFinderLocationToJson(this);

  @JsonKey(name: 'assignedStops', defaultValue: <StopFinderAssignedStop>[])
  final List<StopFinderAssignedStop>? assignedStops;
  @JsonKey(name: 'buildingNumber')
  final String? buildingNumber;
  @JsonKey(name: 'coord', defaultValue: <double>[])
  final List<double>? coord;
  @JsonKey(name: 'disassembledName')
  final String? disassembledName;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'isBest')
  final bool? isBest;
  @JsonKey(name: 'isGlobalId')
  final bool? isGlobalId;
  @JsonKey(name: 'matchQuality')
  final int? matchQuality;
  @JsonKey(name: 'modes', defaultValue: <int>[])
  final List<int>? modes;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'parent')
  final ParentLocation? parent;
  @JsonKey(name: 'streetName')
  final String? streetName;
  @JsonKey(
    name: 'type',
    toJson: stopFinderLocationTypeNullableToJson,
    fromJson: stopFinderLocationTypeNullableFromJson,
  )
  final enums.StopFinderLocationType? type;
  static const fromJsonFactory = _$StopFinderLocationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StopFinderLocation &&
            (identical(other.assignedStops, assignedStops) ||
                const DeepCollectionEquality()
                    .equals(other.assignedStops, assignedStops)) &&
            (identical(other.buildingNumber, buildingNumber) ||
                const DeepCollectionEquality()
                    .equals(other.buildingNumber, buildingNumber)) &&
            (identical(other.coord, coord) ||
                const DeepCollectionEquality().equals(other.coord, coord)) &&
            (identical(other.disassembledName, disassembledName) ||
                const DeepCollectionEquality()
                    .equals(other.disassembledName, disassembledName)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.isBest, isBest) ||
                const DeepCollectionEquality().equals(other.isBest, isBest)) &&
            (identical(other.isGlobalId, isGlobalId) ||
                const DeepCollectionEquality()
                    .equals(other.isGlobalId, isGlobalId)) &&
            (identical(other.matchQuality, matchQuality) ||
                const DeepCollectionEquality()
                    .equals(other.matchQuality, matchQuality)) &&
            (identical(other.modes, modes) ||
                const DeepCollectionEquality().equals(other.modes, modes)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.parent, parent) ||
                const DeepCollectionEquality().equals(other.parent, parent)) &&
            (identical(other.streetName, streetName) ||
                const DeepCollectionEquality()
                    .equals(other.streetName, streetName)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(assignedStops) ^
      const DeepCollectionEquality().hash(buildingNumber) ^
      const DeepCollectionEquality().hash(coord) ^
      const DeepCollectionEquality().hash(disassembledName) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(isBest) ^
      const DeepCollectionEquality().hash(isGlobalId) ^
      const DeepCollectionEquality().hash(matchQuality) ^
      const DeepCollectionEquality().hash(modes) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(parent) ^
      const DeepCollectionEquality().hash(streetName) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $StopFinderLocationExtension on StopFinderLocation {
  StopFinderLocation copyWith(
      {List<StopFinderAssignedStop>? assignedStops,
      String? buildingNumber,
      List<double>? coord,
      String? disassembledName,
      String? id,
      bool? isBest,
      bool? isGlobalId,
      int? matchQuality,
      List<int>? modes,
      String? name,
      ParentLocation? parent,
      String? streetName,
      enums.StopFinderLocationType? type}) {
    return StopFinderLocation(
        assignedStops: assignedStops ?? this.assignedStops,
        buildingNumber: buildingNumber ?? this.buildingNumber,
        coord: coord ?? this.coord,
        disassembledName: disassembledName ?? this.disassembledName,
        id: id ?? this.id,
        isBest: isBest ?? this.isBest,
        isGlobalId: isGlobalId ?? this.isGlobalId,
        matchQuality: matchQuality ?? this.matchQuality,
        modes: modes ?? this.modes,
        name: name ?? this.name,
        parent: parent ?? this.parent,
        streetName: streetName ?? this.streetName,
        type: type ?? this.type);
  }

  StopFinderLocation copyWithWrapped(
      {Wrapped<List<StopFinderAssignedStop>?>? assignedStops,
      Wrapped<String?>? buildingNumber,
      Wrapped<List<double>?>? coord,
      Wrapped<String?>? disassembledName,
      Wrapped<String?>? id,
      Wrapped<bool?>? isBest,
      Wrapped<bool?>? isGlobalId,
      Wrapped<int?>? matchQuality,
      Wrapped<List<int>?>? modes,
      Wrapped<String?>? name,
      Wrapped<ParentLocation?>? parent,
      Wrapped<String?>? streetName,
      Wrapped<enums.StopFinderLocationType?>? type}) {
    return StopFinderLocation(
        assignedStops:
            (assignedStops != null ? assignedStops.value : this.assignedStops),
        buildingNumber: (buildingNumber != null
            ? buildingNumber.value
            : this.buildingNumber),
        coord: (coord != null ? coord.value : this.coord),
        disassembledName: (disassembledName != null
            ? disassembledName.value
            : this.disassembledName),
        id: (id != null ? id.value : this.id),
        isBest: (isBest != null ? isBest.value : this.isBest),
        isGlobalId: (isGlobalId != null ? isGlobalId.value : this.isGlobalId),
        matchQuality:
            (matchQuality != null ? matchQuality.value : this.matchQuality),
        modes: (modes != null ? modes.value : this.modes),
        name: (name != null ? name.value : this.name),
        parent: (parent != null ? parent.value : this.parent),
        streetName: (streetName != null ? streetName.value : this.streetName),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class StopFinderResponse {
  const StopFinderResponse({
    this.error,
    this.locations,
    this.version,
  });

  factory StopFinderResponse.fromJson(Map<String, dynamic> json) =>
      _$StopFinderResponseFromJson(json);

  static const toJsonFactory = _$StopFinderResponseToJson;
  Map<String, dynamic> toJson() => _$StopFinderResponseToJson(this);

  @JsonKey(name: 'error')
  final ApiErrorResponse? error;
  @JsonKey(name: 'locations', defaultValue: <StopFinderLocation>[])
  final List<StopFinderLocation>? locations;
  @JsonKey(name: 'version')
  final String? version;
  static const fromJsonFactory = _$StopFinderResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StopFinderResponse &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.locations, locations) ||
                const DeepCollectionEquality()
                    .equals(other.locations, locations)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(locations) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $StopFinderResponseExtension on StopFinderResponse {
  StopFinderResponse copyWith(
      {ApiErrorResponse? error,
      List<StopFinderLocation>? locations,
      String? version}) {
    return StopFinderResponse(
        error: error ?? this.error,
        locations: locations ?? this.locations,
        version: version ?? this.version);
  }

  StopFinderResponse copyWithWrapped(
      {Wrapped<ApiErrorResponse?>? error,
      Wrapped<List<StopFinderLocation>?>? locations,
      Wrapped<String?>? version}) {
    return StopFinderResponse(
        error: (error != null ? error.value : this.error),
        locations: (locations != null ? locations.value : this.locations),
        version: (version != null ? version.value : this.version));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponse {
  const TripRequestResponse({
    this.error,
    this.journeys,
    this.systemMessages,
    this.version,
  });

  factory TripRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$TripRequestResponseFromJson(json);

  static const toJsonFactory = _$TripRequestResponseToJson;
  Map<String, dynamic> toJson() => _$TripRequestResponseToJson(this);

  @JsonKey(name: 'error')
  final ApiErrorResponse? error;
  @JsonKey(name: 'journeys', defaultValue: <TripRequestResponseJourney>[])
  final List<TripRequestResponseJourney>? journeys;
  @JsonKey(name: 'systemMessages')
  final TripRequestResponse$SystemMessages? systemMessages;
  @JsonKey(name: 'version')
  final String? version;
  static const fromJsonFactory = _$TripRequestResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponse &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.journeys, journeys) ||
                const DeepCollectionEquality()
                    .equals(other.journeys, journeys)) &&
            (identical(other.systemMessages, systemMessages) ||
                const DeepCollectionEquality()
                    .equals(other.systemMessages, systemMessages)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(journeys) ^
      const DeepCollectionEquality().hash(systemMessages) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseExtension on TripRequestResponse {
  TripRequestResponse copyWith(
      {ApiErrorResponse? error,
      List<TripRequestResponseJourney>? journeys,
      TripRequestResponse$SystemMessages? systemMessages,
      String? version}) {
    return TripRequestResponse(
        error: error ?? this.error,
        journeys: journeys ?? this.journeys,
        systemMessages: systemMessages ?? this.systemMessages,
        version: version ?? this.version);
  }

  TripRequestResponse copyWithWrapped(
      {Wrapped<ApiErrorResponse?>? error,
      Wrapped<List<TripRequestResponseJourney>?>? journeys,
      Wrapped<TripRequestResponse$SystemMessages?>? systemMessages,
      Wrapped<String?>? version}) {
    return TripRequestResponse(
        error: (error != null ? error.value : this.error),
        journeys: (journeys != null ? journeys.value : this.journeys),
        systemMessages: (systemMessages != null
            ? systemMessages.value
            : this.systemMessages),
        version: (version != null ? version.value : this.version));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourney {
  const TripRequestResponseJourney({
    this.isAdditional,
    this.legs,
    this.rating,
  });

  factory TripRequestResponseJourney.fromJson(Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyFromJson(json);

  static const toJsonFactory = _$TripRequestResponseJourneyToJson;
  Map<String, dynamic> toJson() => _$TripRequestResponseJourneyToJson(this);

  @JsonKey(name: 'isAdditional')
  final bool? isAdditional;
  @JsonKey(name: 'legs', defaultValue: <TripRequestResponseJourneyLeg>[])
  final List<TripRequestResponseJourneyLeg>? legs;
  @JsonKey(name: 'rating')
  final int? rating;
  static const fromJsonFactory = _$TripRequestResponseJourneyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourney &&
            (identical(other.isAdditional, isAdditional) ||
                const DeepCollectionEquality()
                    .equals(other.isAdditional, isAdditional)) &&
            (identical(other.legs, legs) ||
                const DeepCollectionEquality().equals(other.legs, legs)) &&
            (identical(other.rating, rating) ||
                const DeepCollectionEquality().equals(other.rating, rating)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(isAdditional) ^
      const DeepCollectionEquality().hash(legs) ^
      const DeepCollectionEquality().hash(rating) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyExtension on TripRequestResponseJourney {
  TripRequestResponseJourney copyWith(
      {bool? isAdditional,
      List<TripRequestResponseJourneyLeg>? legs,
      int? rating}) {
    return TripRequestResponseJourney(
        isAdditional: isAdditional ?? this.isAdditional,
        legs: legs ?? this.legs,
        rating: rating ?? this.rating);
  }

  TripRequestResponseJourney copyWithWrapped(
      {Wrapped<bool?>? isAdditional,
      Wrapped<List<TripRequestResponseJourneyLeg>?>? legs,
      Wrapped<int?>? rating}) {
    return TripRequestResponseJourney(
        isAdditional:
            (isAdditional != null ? isAdditional.value : this.isAdditional),
        legs: (legs != null ? legs.value : this.legs),
        rating: (rating != null ? rating.value : this.rating));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyFareZone {
  const TripRequestResponseJourneyFareZone({
    this.fromLeg,
    this.net,
    this.neutralZone,
    this.toLeg,
  });

  factory TripRequestResponseJourneyFareZone.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyFareZoneFromJson(json);

  static const toJsonFactory = _$TripRequestResponseJourneyFareZoneToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyFareZoneToJson(this);

  @JsonKey(name: 'fromLeg')
  final int? fromLeg;
  @JsonKey(name: 'net')
  final String? net;
  @JsonKey(name: 'neutralZone')
  final String? neutralZone;
  @JsonKey(name: 'toLeg')
  final int? toLeg;
  static const fromJsonFactory = _$TripRequestResponseJourneyFareZoneFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyFareZone &&
            (identical(other.fromLeg, fromLeg) ||
                const DeepCollectionEquality()
                    .equals(other.fromLeg, fromLeg)) &&
            (identical(other.net, net) ||
                const DeepCollectionEquality().equals(other.net, net)) &&
            (identical(other.neutralZone, neutralZone) ||
                const DeepCollectionEquality()
                    .equals(other.neutralZone, neutralZone)) &&
            (identical(other.toLeg, toLeg) ||
                const DeepCollectionEquality().equals(other.toLeg, toLeg)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(fromLeg) ^
      const DeepCollectionEquality().hash(net) ^
      const DeepCollectionEquality().hash(neutralZone) ^
      const DeepCollectionEquality().hash(toLeg) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyFareZoneExtension
    on TripRequestResponseJourneyFareZone {
  TripRequestResponseJourneyFareZone copyWith(
      {int? fromLeg, String? net, String? neutralZone, int? toLeg}) {
    return TripRequestResponseJourneyFareZone(
        fromLeg: fromLeg ?? this.fromLeg,
        net: net ?? this.net,
        neutralZone: neutralZone ?? this.neutralZone,
        toLeg: toLeg ?? this.toLeg);
  }

  TripRequestResponseJourneyFareZone copyWithWrapped(
      {Wrapped<int?>? fromLeg,
      Wrapped<String?>? net,
      Wrapped<String?>? neutralZone,
      Wrapped<int?>? toLeg}) {
    return TripRequestResponseJourneyFareZone(
        fromLeg: (fromLeg != null ? fromLeg.value : this.fromLeg),
        net: (net != null ? net.value : this.net),
        neutralZone:
            (neutralZone != null ? neutralZone.value : this.neutralZone),
        toLeg: (toLeg != null ? toLeg.value : this.toLeg));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLeg {
  const TripRequestResponseJourneyLeg({
    this.coords,
    this.destination,
    this.distance,
    this.duration,
    this.footPathInfo,
    this.hints,
    this.infos,
    this.interchange,
    this.isRealtimeControlled,
    this.origin,
    this.pathDescriptions,
    this.properties,
    this.stopSequence,
    this.transportation,
  });

  factory TripRequestResponseJourneyLeg.fromJson(Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegFromJson(json);

  static const toJsonFactory = _$TripRequestResponseJourneyLegToJson;
  Map<String, dynamic> toJson() => _$TripRequestResponseJourneyLegToJson(this);

  @JsonKey(name: 'coords', defaultValue: <List<double?>>[])
  final List<List<double?>>? coords;
  @JsonKey(name: 'destination')
  final TripRequestResponseJourneyLegStop? destination;
  @JsonKey(name: 'distance')
  final int? distance;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(
      name: 'footPathInfo',
      defaultValue: <TripRequestResponseJourneyLegStopFootpathInfo>[])
  final List<TripRequestResponseJourneyLegStopFootpathInfo>? footPathInfo;
  @JsonKey(name: 'hints')
  final List<TripRequestResponseJourneyLeg$Hints$Item>? hints;
  @JsonKey(
      name: 'infos', defaultValue: <TripRequestResponseJourneyLegStopInfo>[])
  final List<TripRequestResponseJourneyLegStopInfo>? infos;
  @JsonKey(name: 'interchange')
  final TripRequestResponseJourneyLegInterchange? interchange;
  @JsonKey(name: 'isRealtimeControlled')
  final bool? isRealtimeControlled;
  @JsonKey(name: 'origin')
  final TripRequestResponseJourneyLegStop? origin;
  @JsonKey(
      name: 'pathDescriptions',
      defaultValue: <TripRequestResponseJourneyLegPathDescription>[])
  final List<TripRequestResponseJourneyLegPathDescription>? pathDescriptions;
  @JsonKey(name: 'properties')
  final TripRequestResponseJourneyLeg$Properties? properties;
  @JsonKey(
      name: 'stopSequence', defaultValue: <TripRequestResponseJourneyLegStop>[])
  final List<TripRequestResponseJourneyLegStop>? stopSequence;
  @JsonKey(name: 'transportation')
  final TripTransportation? transportation;
  static const fromJsonFactory = _$TripRequestResponseJourneyLegFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLeg &&
            (identical(other.coords, coords) ||
                const DeepCollectionEquality().equals(other.coords, coords)) &&
            (identical(other.destination, destination) ||
                const DeepCollectionEquality()
                    .equals(other.destination, destination)) &&
            (identical(other.distance, distance) ||
                const DeepCollectionEquality()
                    .equals(other.distance, distance)) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality()
                    .equals(other.duration, duration)) &&
            (identical(other.footPathInfo, footPathInfo) ||
                const DeepCollectionEquality()
                    .equals(other.footPathInfo, footPathInfo)) &&
            (identical(other.hints, hints) ||
                const DeepCollectionEquality().equals(other.hints, hints)) &&
            (identical(other.infos, infos) ||
                const DeepCollectionEquality().equals(other.infos, infos)) &&
            (identical(other.interchange, interchange) ||
                const DeepCollectionEquality()
                    .equals(other.interchange, interchange)) &&
            (identical(other.isRealtimeControlled, isRealtimeControlled) ||
                const DeepCollectionEquality().equals(
                    other.isRealtimeControlled, isRealtimeControlled)) &&
            (identical(other.origin, origin) ||
                const DeepCollectionEquality().equals(other.origin, origin)) &&
            (identical(other.pathDescriptions, pathDescriptions) ||
                const DeepCollectionEquality()
                    .equals(other.pathDescriptions, pathDescriptions)) &&
            (identical(other.properties, properties) ||
                const DeepCollectionEquality()
                    .equals(other.properties, properties)) &&
            (identical(other.stopSequence, stopSequence) ||
                const DeepCollectionEquality()
                    .equals(other.stopSequence, stopSequence)) &&
            (identical(other.transportation, transportation) ||
                const DeepCollectionEquality()
                    .equals(other.transportation, transportation)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(coords) ^
      const DeepCollectionEquality().hash(destination) ^
      const DeepCollectionEquality().hash(distance) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(footPathInfo) ^
      const DeepCollectionEquality().hash(hints) ^
      const DeepCollectionEquality().hash(infos) ^
      const DeepCollectionEquality().hash(interchange) ^
      const DeepCollectionEquality().hash(isRealtimeControlled) ^
      const DeepCollectionEquality().hash(origin) ^
      const DeepCollectionEquality().hash(pathDescriptions) ^
      const DeepCollectionEquality().hash(properties) ^
      const DeepCollectionEquality().hash(stopSequence) ^
      const DeepCollectionEquality().hash(transportation) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegExtension
    on TripRequestResponseJourneyLeg {
  TripRequestResponseJourneyLeg copyWith(
      {List<List<double?>>? coords,
      TripRequestResponseJourneyLegStop? destination,
      int? distance,
      int? duration,
      List<TripRequestResponseJourneyLegStopFootpathInfo>? footPathInfo,
      List<TripRequestResponseJourneyLeg$Hints$Item>? hints,
      List<TripRequestResponseJourneyLegStopInfo>? infos,
      TripRequestResponseJourneyLegInterchange? interchange,
      bool? isRealtimeControlled,
      TripRequestResponseJourneyLegStop? origin,
      List<TripRequestResponseJourneyLegPathDescription>? pathDescriptions,
      TripRequestResponseJourneyLeg$Properties? properties,
      List<TripRequestResponseJourneyLegStop>? stopSequence,
      TripTransportation? transportation}) {
    return TripRequestResponseJourneyLeg(
        coords: coords ?? this.coords,
        destination: destination ?? this.destination,
        distance: distance ?? this.distance,
        duration: duration ?? this.duration,
        footPathInfo: footPathInfo ?? this.footPathInfo,
        hints: hints ?? this.hints,
        infos: infos ?? this.infos,
        interchange: interchange ?? this.interchange,
        isRealtimeControlled: isRealtimeControlled ?? this.isRealtimeControlled,
        origin: origin ?? this.origin,
        pathDescriptions: pathDescriptions ?? this.pathDescriptions,
        properties: properties ?? this.properties,
        stopSequence: stopSequence ?? this.stopSequence,
        transportation: transportation ?? this.transportation);
  }

  TripRequestResponseJourneyLeg copyWithWrapped(
      {Wrapped<List<List<double?>>?>? coords,
      Wrapped<TripRequestResponseJourneyLegStop?>? destination,
      Wrapped<int?>? distance,
      Wrapped<int?>? duration,
      Wrapped<List<TripRequestResponseJourneyLegStopFootpathInfo>?>?
          footPathInfo,
      Wrapped<List<TripRequestResponseJourneyLeg$Hints$Item>?>? hints,
      Wrapped<List<TripRequestResponseJourneyLegStopInfo>?>? infos,
      Wrapped<TripRequestResponseJourneyLegInterchange?>? interchange,
      Wrapped<bool?>? isRealtimeControlled,
      Wrapped<TripRequestResponseJourneyLegStop?>? origin,
      Wrapped<List<TripRequestResponseJourneyLegPathDescription>?>?
          pathDescriptions,
      Wrapped<TripRequestResponseJourneyLeg$Properties?>? properties,
      Wrapped<List<TripRequestResponseJourneyLegStop>?>? stopSequence,
      Wrapped<TripTransportation?>? transportation}) {
    return TripRequestResponseJourneyLeg(
        coords: (coords != null ? coords.value : this.coords),
        destination:
            (destination != null ? destination.value : this.destination),
        distance: (distance != null ? distance.value : this.distance),
        duration: (duration != null ? duration.value : this.duration),
        footPathInfo:
            (footPathInfo != null ? footPathInfo.value : this.footPathInfo),
        hints: (hints != null ? hints.value : this.hints),
        infos: (infos != null ? infos.value : this.infos),
        interchange:
            (interchange != null ? interchange.value : this.interchange),
        isRealtimeControlled: (isRealtimeControlled != null
            ? isRealtimeControlled.value
            : this.isRealtimeControlled),
        origin: (origin != null ? origin.value : this.origin),
        pathDescriptions: (pathDescriptions != null
            ? pathDescriptions.value
            : this.pathDescriptions),
        properties: (properties != null ? properties.value : this.properties),
        stopSequence:
            (stopSequence != null ? stopSequence.value : this.stopSequence),
        transportation: (transportation != null
            ? transportation.value
            : this.transportation));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegInterchange {
  const TripRequestResponseJourneyLegInterchange({
    this.coords,
    this.desc,
    this.type,
  });

  factory TripRequestResponseJourneyLegInterchange.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegInterchangeFromJson(json);

  static const toJsonFactory = _$TripRequestResponseJourneyLegInterchangeToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegInterchangeToJson(this);

  @JsonKey(name: 'coords', defaultValue: <List<double?>>[])
  final List<List<double?>>? coords;
  @JsonKey(name: 'desc')
  final String? desc;
  @JsonKey(name: 'type')
  final int? type;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegInterchangeFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegInterchange &&
            (identical(other.coords, coords) ||
                const DeepCollectionEquality().equals(other.coords, coords)) &&
            (identical(other.desc, desc) ||
                const DeepCollectionEquality().equals(other.desc, desc)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(coords) ^
      const DeepCollectionEquality().hash(desc) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegInterchangeExtension
    on TripRequestResponseJourneyLegInterchange {
  TripRequestResponseJourneyLegInterchange copyWith(
      {List<List<double?>>? coords, String? desc, int? type}) {
    return TripRequestResponseJourneyLegInterchange(
        coords: coords ?? this.coords,
        desc: desc ?? this.desc,
        type: type ?? this.type);
  }

  TripRequestResponseJourneyLegInterchange copyWithWrapped(
      {Wrapped<List<List<double?>>?>? coords,
      Wrapped<String?>? desc,
      Wrapped<int?>? type}) {
    return TripRequestResponseJourneyLegInterchange(
        coords: (coords != null ? coords.value : this.coords),
        desc: (desc != null ? desc.value : this.desc),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegPathDescription {
  const TripRequestResponseJourneyLegPathDescription({
    this.coord,
    this.cumDistance,
    this.cumDuration,
    this.distance,
    this.distanceDown,
    this.distanceUp,
    this.duration,
    this.fromCoordsIndex,
    this.manoeuvre,
    this.name,
    this.skyDirection,
    this.toCoordsIndex,
    this.turnDirection,
  });

  factory TripRequestResponseJourneyLegPathDescription.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegPathDescriptionFromJson(json);

  static const toJsonFactory =
      _$TripRequestResponseJourneyLegPathDescriptionToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegPathDescriptionToJson(this);

  @JsonKey(name: 'coord', defaultValue: <double>[])
  final List<double>? coord;
  @JsonKey(name: 'cumDistance')
  final int? cumDistance;
  @JsonKey(name: 'cumDuration')
  final int? cumDuration;
  @JsonKey(name: 'distance')
  final int? distance;
  @JsonKey(name: 'distanceDown')
  final int? distanceDown;
  @JsonKey(name: 'distanceUp')
  final int? distanceUp;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'fromCoordsIndex')
  final int? fromCoordsIndex;
  @JsonKey(
    name: 'manoeuvre',
    toJson: tripRequestResponseJourneyLegPathDescriptionManoeuvreNullableToJson,
    fromJson:
        tripRequestResponseJourneyLegPathDescriptionManoeuvreNullableFromJson,
  )
  final enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre? manoeuvre;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'skyDirection')
  final int? skyDirection;
  @JsonKey(name: 'toCoordsIndex')
  final int? toCoordsIndex;
  @JsonKey(
    name: 'turnDirection',
    toJson:
        tripRequestResponseJourneyLegPathDescriptionTurnDirectionNullableToJson,
    fromJson:
        tripRequestResponseJourneyLegPathDescriptionTurnDirectionNullableFromJson,
  )
  final enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection?
      turnDirection;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegPathDescriptionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegPathDescription &&
            (identical(other.coord, coord) ||
                const DeepCollectionEquality().equals(other.coord, coord)) &&
            (identical(other.cumDistance, cumDistance) ||
                const DeepCollectionEquality()
                    .equals(other.cumDistance, cumDistance)) &&
            (identical(other.cumDuration, cumDuration) ||
                const DeepCollectionEquality()
                    .equals(other.cumDuration, cumDuration)) &&
            (identical(other.distance, distance) ||
                const DeepCollectionEquality()
                    .equals(other.distance, distance)) &&
            (identical(other.distanceDown, distanceDown) ||
                const DeepCollectionEquality()
                    .equals(other.distanceDown, distanceDown)) &&
            (identical(other.distanceUp, distanceUp) ||
                const DeepCollectionEquality()
                    .equals(other.distanceUp, distanceUp)) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality()
                    .equals(other.duration, duration)) &&
            (identical(other.fromCoordsIndex, fromCoordsIndex) ||
                const DeepCollectionEquality()
                    .equals(other.fromCoordsIndex, fromCoordsIndex)) &&
            (identical(other.manoeuvre, manoeuvre) ||
                const DeepCollectionEquality()
                    .equals(other.manoeuvre, manoeuvre)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.skyDirection, skyDirection) ||
                const DeepCollectionEquality()
                    .equals(other.skyDirection, skyDirection)) &&
            (identical(other.toCoordsIndex, toCoordsIndex) ||
                const DeepCollectionEquality()
                    .equals(other.toCoordsIndex, toCoordsIndex)) &&
            (identical(other.turnDirection, turnDirection) ||
                const DeepCollectionEquality()
                    .equals(other.turnDirection, turnDirection)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(coord) ^
      const DeepCollectionEquality().hash(cumDistance) ^
      const DeepCollectionEquality().hash(cumDuration) ^
      const DeepCollectionEquality().hash(distance) ^
      const DeepCollectionEquality().hash(distanceDown) ^
      const DeepCollectionEquality().hash(distanceUp) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(fromCoordsIndex) ^
      const DeepCollectionEquality().hash(manoeuvre) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(skyDirection) ^
      const DeepCollectionEquality().hash(toCoordsIndex) ^
      const DeepCollectionEquality().hash(turnDirection) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegPathDescriptionExtension
    on TripRequestResponseJourneyLegPathDescription {
  TripRequestResponseJourneyLegPathDescription copyWith(
      {List<double>? coord,
      int? cumDistance,
      int? cumDuration,
      int? distance,
      int? distanceDown,
      int? distanceUp,
      int? duration,
      int? fromCoordsIndex,
      enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre? manoeuvre,
      String? name,
      int? skyDirection,
      int? toCoordsIndex,
      enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection?
          turnDirection}) {
    return TripRequestResponseJourneyLegPathDescription(
        coord: coord ?? this.coord,
        cumDistance: cumDistance ?? this.cumDistance,
        cumDuration: cumDuration ?? this.cumDuration,
        distance: distance ?? this.distance,
        distanceDown: distanceDown ?? this.distanceDown,
        distanceUp: distanceUp ?? this.distanceUp,
        duration: duration ?? this.duration,
        fromCoordsIndex: fromCoordsIndex ?? this.fromCoordsIndex,
        manoeuvre: manoeuvre ?? this.manoeuvre,
        name: name ?? this.name,
        skyDirection: skyDirection ?? this.skyDirection,
        toCoordsIndex: toCoordsIndex ?? this.toCoordsIndex,
        turnDirection: turnDirection ?? this.turnDirection);
  }

  TripRequestResponseJourneyLegPathDescription copyWithWrapped(
      {Wrapped<List<double>?>? coord,
      Wrapped<int?>? cumDistance,
      Wrapped<int?>? cumDuration,
      Wrapped<int?>? distance,
      Wrapped<int?>? distanceDown,
      Wrapped<int?>? distanceUp,
      Wrapped<int?>? duration,
      Wrapped<int?>? fromCoordsIndex,
      Wrapped<enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre?>?
          manoeuvre,
      Wrapped<String?>? name,
      Wrapped<int?>? skyDirection,
      Wrapped<int?>? toCoordsIndex,
      Wrapped<enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection?>?
          turnDirection}) {
    return TripRequestResponseJourneyLegPathDescription(
        coord: (coord != null ? coord.value : this.coord),
        cumDistance:
            (cumDistance != null ? cumDistance.value : this.cumDistance),
        cumDuration:
            (cumDuration != null ? cumDuration.value : this.cumDuration),
        distance: (distance != null ? distance.value : this.distance),
        distanceDown:
            (distanceDown != null ? distanceDown.value : this.distanceDown),
        distanceUp: (distanceUp != null ? distanceUp.value : this.distanceUp),
        duration: (duration != null ? duration.value : this.duration),
        fromCoordsIndex: (fromCoordsIndex != null
            ? fromCoordsIndex.value
            : this.fromCoordsIndex),
        manoeuvre: (manoeuvre != null ? manoeuvre.value : this.manoeuvre),
        name: (name != null ? name.value : this.name),
        skyDirection:
            (skyDirection != null ? skyDirection.value : this.skyDirection),
        toCoordsIndex:
            (toCoordsIndex != null ? toCoordsIndex.value : this.toCoordsIndex),
        turnDirection:
            (turnDirection != null ? turnDirection.value : this.turnDirection));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegStop {
  const TripRequestResponseJourneyLegStop({
    this.arrivalTimeEstimated,
    this.arrivalTimePlanned,
    this.coord,
    this.departureTimeEstimated,
    this.departureTimePlanned,
    this.disassembledName,
    this.id,
    this.name,
    this.parent,
    this.properties,
    this.type,
  });

  factory TripRequestResponseJourneyLegStop.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegStopFromJson(json);

  static const toJsonFactory = _$TripRequestResponseJourneyLegStopToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegStopToJson(this);

  @JsonKey(name: 'arrivalTimeEstimated')
  final String? arrivalTimeEstimated;
  @JsonKey(name: 'arrivalTimePlanned')
  final String? arrivalTimePlanned;
  @JsonKey(name: 'coord', defaultValue: <double>[])
  final List<double>? coord;
  @JsonKey(name: 'departureTimeEstimated')
  final String? departureTimeEstimated;
  @JsonKey(name: 'departureTimePlanned')
  final String? departureTimePlanned;
  @JsonKey(name: 'disassembledName')
  final String? disassembledName;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'parent')
  final ParentLocation? parent;
  @JsonKey(name: 'properties')
  final TripRequestResponseJourneyLegStop$Properties? properties;
  @JsonKey(
    name: 'type',
    toJson: tripRequestResponseJourneyLegStopTypeNullableToJson,
    fromJson: tripRequestResponseJourneyLegStopTypeNullableFromJson,
  )
  final enums.TripRequestResponseJourneyLegStopType? type;
  static const fromJsonFactory = _$TripRequestResponseJourneyLegStopFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegStop &&
            (identical(other.arrivalTimeEstimated, arrivalTimeEstimated) ||
                const DeepCollectionEquality().equals(
                    other.arrivalTimeEstimated, arrivalTimeEstimated)) &&
            (identical(other.arrivalTimePlanned, arrivalTimePlanned) ||
                const DeepCollectionEquality()
                    .equals(other.arrivalTimePlanned, arrivalTimePlanned)) &&
            (identical(other.coord, coord) ||
                const DeepCollectionEquality().equals(other.coord, coord)) &&
            (identical(other.departureTimeEstimated, departureTimeEstimated) ||
                const DeepCollectionEquality().equals(
                    other.departureTimeEstimated, departureTimeEstimated)) &&
            (identical(other.departureTimePlanned, departureTimePlanned) ||
                const DeepCollectionEquality().equals(
                    other.departureTimePlanned, departureTimePlanned)) &&
            (identical(other.disassembledName, disassembledName) ||
                const DeepCollectionEquality()
                    .equals(other.disassembledName, disassembledName)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.parent, parent) ||
                const DeepCollectionEquality().equals(other.parent, parent)) &&
            (identical(other.properties, properties) ||
                const DeepCollectionEquality()
                    .equals(other.properties, properties)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(arrivalTimeEstimated) ^
      const DeepCollectionEquality().hash(arrivalTimePlanned) ^
      const DeepCollectionEquality().hash(coord) ^
      const DeepCollectionEquality().hash(departureTimeEstimated) ^
      const DeepCollectionEquality().hash(departureTimePlanned) ^
      const DeepCollectionEquality().hash(disassembledName) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(parent) ^
      const DeepCollectionEquality().hash(properties) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegStopExtension
    on TripRequestResponseJourneyLegStop {
  TripRequestResponseJourneyLegStop copyWith(
      {String? arrivalTimeEstimated,
      String? arrivalTimePlanned,
      List<double>? coord,
      String? departureTimeEstimated,
      String? departureTimePlanned,
      String? disassembledName,
      String? id,
      String? name,
      ParentLocation? parent,
      TripRequestResponseJourneyLegStop$Properties? properties,
      enums.TripRequestResponseJourneyLegStopType? type}) {
    return TripRequestResponseJourneyLegStop(
        arrivalTimeEstimated: arrivalTimeEstimated ?? this.arrivalTimeEstimated,
        arrivalTimePlanned: arrivalTimePlanned ?? this.arrivalTimePlanned,
        coord: coord ?? this.coord,
        departureTimeEstimated:
            departureTimeEstimated ?? this.departureTimeEstimated,
        departureTimePlanned: departureTimePlanned ?? this.departureTimePlanned,
        disassembledName: disassembledName ?? this.disassembledName,
        id: id ?? this.id,
        name: name ?? this.name,
        parent: parent ?? this.parent,
        properties: properties ?? this.properties,
        type: type ?? this.type);
  }

  TripRequestResponseJourneyLegStop copyWithWrapped(
      {Wrapped<String?>? arrivalTimeEstimated,
      Wrapped<String?>? arrivalTimePlanned,
      Wrapped<List<double>?>? coord,
      Wrapped<String?>? departureTimeEstimated,
      Wrapped<String?>? departureTimePlanned,
      Wrapped<String?>? disassembledName,
      Wrapped<String?>? id,
      Wrapped<String?>? name,
      Wrapped<ParentLocation?>? parent,
      Wrapped<TripRequestResponseJourneyLegStop$Properties?>? properties,
      Wrapped<enums.TripRequestResponseJourneyLegStopType?>? type}) {
    return TripRequestResponseJourneyLegStop(
        arrivalTimeEstimated: (arrivalTimeEstimated != null
            ? arrivalTimeEstimated.value
            : this.arrivalTimeEstimated),
        arrivalTimePlanned: (arrivalTimePlanned != null
            ? arrivalTimePlanned.value
            : this.arrivalTimePlanned),
        coord: (coord != null ? coord.value : this.coord),
        departureTimeEstimated: (departureTimeEstimated != null
            ? departureTimeEstimated.value
            : this.departureTimeEstimated),
        departureTimePlanned: (departureTimePlanned != null
            ? departureTimePlanned.value
            : this.departureTimePlanned),
        disassembledName: (disassembledName != null
            ? disassembledName.value
            : this.disassembledName),
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        parent: (parent != null ? parent.value : this.parent),
        properties: (properties != null ? properties.value : this.properties),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegStopDownload {
  const TripRequestResponseJourneyLegStopDownload({
    this.type,
    this.url,
  });

  factory TripRequestResponseJourneyLegStopDownload.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegStopDownloadFromJson(json);

  static const toJsonFactory =
      _$TripRequestResponseJourneyLegStopDownloadToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegStopDownloadToJson(this);

  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'url')
  final String? url;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegStopDownloadFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegStopDownload &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.url, url) ||
                const DeepCollectionEquality().equals(other.url, url)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(url) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegStopDownloadExtension
    on TripRequestResponseJourneyLegStopDownload {
  TripRequestResponseJourneyLegStopDownload copyWith(
      {String? type, String? url}) {
    return TripRequestResponseJourneyLegStopDownload(
        type: type ?? this.type, url: url ?? this.url);
  }

  TripRequestResponseJourneyLegStopDownload copyWithWrapped(
      {Wrapped<String?>? type, Wrapped<String?>? url}) {
    return TripRequestResponseJourneyLegStopDownload(
        type: (type != null ? type.value : this.type),
        url: (url != null ? url.value : this.url));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegStopFootpathInfo {
  const TripRequestResponseJourneyLegStopFootpathInfo({
    this.duration,
    this.footPathElem,
    this.position,
  });

  factory TripRequestResponseJourneyLegStopFootpathInfo.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegStopFootpathInfoFromJson(json);

  static const toJsonFactory =
      _$TripRequestResponseJourneyLegStopFootpathInfoToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegStopFootpathInfoToJson(this);

  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(
      name: 'footPathElem',
      defaultValue: <TripRequestResponseJourneyLegStopFootpathInfoFootpathElem>[])
  final List<TripRequestResponseJourneyLegStopFootpathInfoFootpathElem>?
      footPathElem;
  @JsonKey(
    name: 'position',
    toJson: tripRequestResponseJourneyLegStopFootpathInfoPositionNullableToJson,
    fromJson:
        tripRequestResponseJourneyLegStopFootpathInfoPositionNullableFromJson,
  )
  final enums.TripRequestResponseJourneyLegStopFootpathInfoPosition? position;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegStopFootpathInfoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegStopFootpathInfo &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality()
                    .equals(other.duration, duration)) &&
            (identical(other.footPathElem, footPathElem) ||
                const DeepCollectionEquality()
                    .equals(other.footPathElem, footPathElem)) &&
            (identical(other.position, position) ||
                const DeepCollectionEquality()
                    .equals(other.position, position)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(footPathElem) ^
      const DeepCollectionEquality().hash(position) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegStopFootpathInfoExtension
    on TripRequestResponseJourneyLegStopFootpathInfo {
  TripRequestResponseJourneyLegStopFootpathInfo copyWith(
      {int? duration,
      List<TripRequestResponseJourneyLegStopFootpathInfoFootpathElem>?
          footPathElem,
      enums.TripRequestResponseJourneyLegStopFootpathInfoPosition? position}) {
    return TripRequestResponseJourneyLegStopFootpathInfo(
        duration: duration ?? this.duration,
        footPathElem: footPathElem ?? this.footPathElem,
        position: position ?? this.position);
  }

  TripRequestResponseJourneyLegStopFootpathInfo copyWithWrapped(
      {Wrapped<int?>? duration,
      Wrapped<List<TripRequestResponseJourneyLegStopFootpathInfoFootpathElem>?>?
          footPathElem,
      Wrapped<enums.TripRequestResponseJourneyLegStopFootpathInfoPosition?>?
          position}) {
    return TripRequestResponseJourneyLegStopFootpathInfo(
        duration: (duration != null ? duration.value : this.duration),
        footPathElem:
            (footPathElem != null ? footPathElem.value : this.footPathElem),
        position: (position != null ? position.value : this.position));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegStopFootpathInfoFootpathElem {
  const TripRequestResponseJourneyLegStopFootpathInfoFootpathElem({
    this.description,
    this.destination,
    this.level,
    this.levelFrom,
    this.levelTo,
    this.origin,
    this.type,
  });

  factory TripRequestResponseJourneyLegStopFootpathInfoFootpathElem.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemFromJson(json);

  static const toJsonFactory =
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemToJson(this);

  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'destination')
  final TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation?
      destination;
  @JsonKey(
    name: 'level',
    toJson:
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelNullableToJson,
    fromJson:
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelNullableFromJson,
  )
  final enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel?
      level;
  @JsonKey(name: 'levelFrom')
  final int? levelFrom;
  @JsonKey(name: 'levelTo')
  final int? levelTo;
  @JsonKey(name: 'origin')
  final TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation?
      origin;
  @JsonKey(
    name: 'type',
    toJson:
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeNullableToJson,
    fromJson:
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeNullableFromJson,
  )
  final enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType?
      type;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegStopFootpathInfoFootpathElem &&
            (identical(other.description, description) ||
                const DeepCollectionEquality()
                    .equals(other.description, description)) &&
            (identical(other.destination, destination) ||
                const DeepCollectionEquality()
                    .equals(other.destination, destination)) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.levelFrom, levelFrom) ||
                const DeepCollectionEquality()
                    .equals(other.levelFrom, levelFrom)) &&
            (identical(other.levelTo, levelTo) ||
                const DeepCollectionEquality()
                    .equals(other.levelTo, levelTo)) &&
            (identical(other.origin, origin) ||
                const DeepCollectionEquality().equals(other.origin, origin)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(destination) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(levelFrom) ^
      const DeepCollectionEquality().hash(levelTo) ^
      const DeepCollectionEquality().hash(origin) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegStopFootpathInfoFootpathElemExtension
    on TripRequestResponseJourneyLegStopFootpathInfoFootpathElem {
  TripRequestResponseJourneyLegStopFootpathInfoFootpathElem copyWith(
      {String? description,
      TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation?
          destination,
      enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel?
          level,
      int? levelFrom,
      int? levelTo,
      TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation? origin,
      enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType?
          type}) {
    return TripRequestResponseJourneyLegStopFootpathInfoFootpathElem(
        description: description ?? this.description,
        destination: destination ?? this.destination,
        level: level ?? this.level,
        levelFrom: levelFrom ?? this.levelFrom,
        levelTo: levelTo ?? this.levelTo,
        origin: origin ?? this.origin,
        type: type ?? this.type);
  }

  TripRequestResponseJourneyLegStopFootpathInfoFootpathElem copyWithWrapped(
      {Wrapped<String?>? description,
      Wrapped<TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation?>?
          destination,
      Wrapped<
              enums
              .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel?>?
          level,
      Wrapped<int?>? levelFrom,
      Wrapped<int?>? levelTo,
      Wrapped<TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation?>?
          origin,
      Wrapped<
              enums
              .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType?>?
          type}) {
    return TripRequestResponseJourneyLegStopFootpathInfoFootpathElem(
        description:
            (description != null ? description.value : this.description),
        destination:
            (destination != null ? destination.value : this.destination),
        level: (level != null ? level.value : this.level),
        levelFrom: (levelFrom != null ? levelFrom.value : this.levelFrom),
        levelTo: (levelTo != null ? levelTo.value : this.levelTo),
        origin: (origin != null ? origin.value : this.origin),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation {
  const TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation({
    this.area,
    this.georef,
    this.location,
    this.platform,
  });

  factory TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocationFromJson(
          json);

  static const toJsonFactory =
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocationToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocationToJson(
          this);

  @JsonKey(name: 'area')
  final int? area;
  @JsonKey(name: 'georef')
  final String? georef;
  @JsonKey(name: 'location')
  final TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location?
      location;
  @JsonKey(name: 'platform')
  final int? platform;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation &&
            (identical(other.area, area) ||
                const DeepCollectionEquality().equals(other.area, area)) &&
            (identical(other.georef, georef) ||
                const DeepCollectionEquality().equals(other.georef, georef)) &&
            (identical(other.location, location) ||
                const DeepCollectionEquality()
                    .equals(other.location, location)) &&
            (identical(other.platform, platform) ||
                const DeepCollectionEquality()
                    .equals(other.platform, platform)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(area) ^
      const DeepCollectionEquality().hash(georef) ^
      const DeepCollectionEquality().hash(location) ^
      const DeepCollectionEquality().hash(platform) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocationExtension
    on TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation {
  TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation copyWith(
      {int? area,
      String? georef,
      TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location?
          location,
      int? platform}) {
    return TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation(
        area: area ?? this.area,
        georef: georef ?? this.georef,
        location: location ?? this.location,
        platform: platform ?? this.platform);
  }

  TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation copyWithWrapped(
      {Wrapped<int?>? area,
      Wrapped<String?>? georef,
      Wrapped<TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location?>?
          location,
      Wrapped<int?>? platform}) {
    return TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation(
        area: (area != null ? area.value : this.area),
        georef: (georef != null ? georef.value : this.georef),
        location: (location != null ? location.value : this.location),
        platform: (platform != null ? platform.value : this.platform));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegStopInfo {
  const TripRequestResponseJourneyLegStopInfo({
    this.content,
    this.id,
    this.priority,
    this.subtitle,
    this.timestamps,
    this.url,
    this.urlText,
    this.version,
  });

  factory TripRequestResponseJourneyLegStopInfo.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegStopInfoFromJson(json);

  static const toJsonFactory = _$TripRequestResponseJourneyLegStopInfoToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegStopInfoToJson(this);

  @JsonKey(name: 'content')
  final String? content;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(
    name: 'priority',
    toJson: tripRequestResponseJourneyLegStopInfoPriorityNullableToJson,
    fromJson: tripRequestResponseJourneyLegStopInfoPriorityNullableFromJson,
  )
  final enums.TripRequestResponseJourneyLegStopInfoPriority? priority;
  @JsonKey(name: 'subtitle')
  final String? subtitle;
  @JsonKey(name: 'timestamps')
  final AdditionalInfoResponseTimestamps? timestamps;
  @JsonKey(name: 'url')
  final String? url;
  @JsonKey(name: 'urlText')
  final String? urlText;
  @JsonKey(name: 'version')
  final int? version;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegStopInfoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegStopInfo &&
            (identical(other.content, content) ||
                const DeepCollectionEquality()
                    .equals(other.content, content)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.priority, priority) ||
                const DeepCollectionEquality()
                    .equals(other.priority, priority)) &&
            (identical(other.subtitle, subtitle) ||
                const DeepCollectionEquality()
                    .equals(other.subtitle, subtitle)) &&
            (identical(other.timestamps, timestamps) ||
                const DeepCollectionEquality()
                    .equals(other.timestamps, timestamps)) &&
            (identical(other.url, url) ||
                const DeepCollectionEquality().equals(other.url, url)) &&
            (identical(other.urlText, urlText) ||
                const DeepCollectionEquality()
                    .equals(other.urlText, urlText)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(content) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(priority) ^
      const DeepCollectionEquality().hash(subtitle) ^
      const DeepCollectionEquality().hash(timestamps) ^
      const DeepCollectionEquality().hash(url) ^
      const DeepCollectionEquality().hash(urlText) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegStopInfoExtension
    on TripRequestResponseJourneyLegStopInfo {
  TripRequestResponseJourneyLegStopInfo copyWith(
      {String? content,
      String? id,
      enums.TripRequestResponseJourneyLegStopInfoPriority? priority,
      String? subtitle,
      AdditionalInfoResponseTimestamps? timestamps,
      String? url,
      String? urlText,
      int? version}) {
    return TripRequestResponseJourneyLegStopInfo(
        content: content ?? this.content,
        id: id ?? this.id,
        priority: priority ?? this.priority,
        subtitle: subtitle ?? this.subtitle,
        timestamps: timestamps ?? this.timestamps,
        url: url ?? this.url,
        urlText: urlText ?? this.urlText,
        version: version ?? this.version);
  }

  TripRequestResponseJourneyLegStopInfo copyWithWrapped(
      {Wrapped<String?>? content,
      Wrapped<String?>? id,
      Wrapped<enums.TripRequestResponseJourneyLegStopInfoPriority?>? priority,
      Wrapped<String?>? subtitle,
      Wrapped<AdditionalInfoResponseTimestamps?>? timestamps,
      Wrapped<String?>? url,
      Wrapped<String?>? urlText,
      Wrapped<int?>? version}) {
    return TripRequestResponseJourneyLegStopInfo(
        content: (content != null ? content.value : this.content),
        id: (id != null ? id.value : this.id),
        priority: (priority != null ? priority.value : this.priority),
        subtitle: (subtitle != null ? subtitle.value : this.subtitle),
        timestamps: (timestamps != null ? timestamps.value : this.timestamps),
        url: (url != null ? url.value : this.url),
        urlText: (urlText != null ? urlText.value : this.urlText),
        version: (version != null ? version.value : this.version));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseMessage {
  const TripRequestResponseMessage({
    this.code,
    this.error,
    this.module,
    this.type,
  });

  factory TripRequestResponseMessage.fromJson(Map<String, dynamic> json) =>
      _$TripRequestResponseMessageFromJson(json);

  static const toJsonFactory = _$TripRequestResponseMessageToJson;
  Map<String, dynamic> toJson() => _$TripRequestResponseMessageToJson(this);

  @JsonKey(name: 'code')
  final int? code;
  @JsonKey(name: 'error')
  final String? error;
  @JsonKey(name: 'module')
  final String? module;
  @JsonKey(name: 'type')
  final String? type;
  static const fromJsonFactory = _$TripRequestResponseMessageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseMessage &&
            (identical(other.code, code) ||
                const DeepCollectionEquality().equals(other.code, code)) &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.module, module) ||
                const DeepCollectionEquality().equals(other.module, module)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(code) ^
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(module) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseMessageExtension on TripRequestResponseMessage {
  TripRequestResponseMessage copyWith(
      {int? code, String? error, String? module, String? type}) {
    return TripRequestResponseMessage(
        code: code ?? this.code,
        error: error ?? this.error,
        module: module ?? this.module,
        type: type ?? this.type);
  }

  TripRequestResponseMessage copyWithWrapped(
      {Wrapped<int?>? code,
      Wrapped<String?>? error,
      Wrapped<String?>? module,
      Wrapped<String?>? type}) {
    return TripRequestResponseMessage(
        code: (code != null ? code.value : this.code),
        error: (error != null ? error.value : this.error),
        module: (module != null ? module.value : this.module),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class TripTransportation {
  const TripTransportation({
    this.description,
    this.destination,
    this.disassembledName,
    this.iconId,
    this.id,
    this.name,
    this.number,
    this.$operator,
    this.product,
    this.properties,
  });

  factory TripTransportation.fromJson(Map<String, dynamic> json) =>
      _$TripTransportationFromJson(json);

  static const toJsonFactory = _$TripTransportationToJson;
  Map<String, dynamic> toJson() => _$TripTransportationToJson(this);

  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'destination')
  final TripTransportation$Destination? destination;
  @JsonKey(name: 'disassembledName')
  final String? disassembledName;
  @JsonKey(name: 'iconId')
  final int? iconId;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'number')
  final String? number;
  @JsonKey(name: 'operator')
  final TripTransportation$Operator? $operator;
  @JsonKey(name: 'product')
  final RouteProduct? product;
  @JsonKey(name: 'properties')
  final TripTransportation$Properties? properties;
  static const fromJsonFactory = _$TripTransportationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripTransportation &&
            (identical(other.description, description) ||
                const DeepCollectionEquality()
                    .equals(other.description, description)) &&
            (identical(other.destination, destination) ||
                const DeepCollectionEquality()
                    .equals(other.destination, destination)) &&
            (identical(other.disassembledName, disassembledName) ||
                const DeepCollectionEquality()
                    .equals(other.disassembledName, disassembledName)) &&
            (identical(other.iconId, iconId) ||
                const DeepCollectionEquality().equals(other.iconId, iconId)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.number, number) ||
                const DeepCollectionEquality().equals(other.number, number)) &&
            (identical(other.$operator, $operator) ||
                const DeepCollectionEquality()
                    .equals(other.$operator, $operator)) &&
            (identical(other.product, product) ||
                const DeepCollectionEquality()
                    .equals(other.product, product)) &&
            (identical(other.properties, properties) ||
                const DeepCollectionEquality()
                    .equals(other.properties, properties)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(destination) ^
      const DeepCollectionEquality().hash(disassembledName) ^
      const DeepCollectionEquality().hash(iconId) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(number) ^
      const DeepCollectionEquality().hash($operator) ^
      const DeepCollectionEquality().hash(product) ^
      const DeepCollectionEquality().hash(properties) ^
      runtimeType.hashCode;
}

extension $TripTransportationExtension on TripTransportation {
  TripTransportation copyWith(
      {String? description,
      TripTransportation$Destination? destination,
      String? disassembledName,
      int? iconId,
      String? id,
      String? name,
      String? number,
      TripTransportation$Operator? $operator,
      RouteProduct? product,
      TripTransportation$Properties? properties}) {
    return TripTransportation(
        description: description ?? this.description,
        destination: destination ?? this.destination,
        disassembledName: disassembledName ?? this.disassembledName,
        iconId: iconId ?? this.iconId,
        id: id ?? this.id,
        name: name ?? this.name,
        number: number ?? this.number,
        $operator: $operator ?? this.$operator,
        product: product ?? this.product,
        properties: properties ?? this.properties);
  }

  TripTransportation copyWithWrapped(
      {Wrapped<String?>? description,
      Wrapped<TripTransportation$Destination?>? destination,
      Wrapped<String?>? disassembledName,
      Wrapped<int?>? iconId,
      Wrapped<String?>? id,
      Wrapped<String?>? name,
      Wrapped<String?>? number,
      Wrapped<TripTransportation$Operator?>? $operator,
      Wrapped<RouteProduct?>? product,
      Wrapped<TripTransportation$Properties?>? properties}) {
    return TripTransportation(
        description:
            (description != null ? description.value : this.description),
        destination:
            (destination != null ? destination.value : this.destination),
        disassembledName: (disassembledName != null
            ? disassembledName.value
            : this.disassembledName),
        iconId: (iconId != null ? iconId.value : this.iconId),
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        number: (number != null ? number.value : this.number),
        $operator: ($operator != null ? $operator.value : this.$operator),
        product: (product != null ? product.value : this.product),
        properties: (properties != null ? properties.value : this.properties));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponse$Infos {
  const AdditionalInfoResponse$Infos({
    this.affected,
    this.current,
    this.historic,
  });

  factory AdditionalInfoResponse$Infos.fromJson(Map<String, dynamic> json) =>
      _$AdditionalInfoResponse$InfosFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponse$InfosToJson;
  Map<String, dynamic> toJson() => _$AdditionalInfoResponse$InfosToJson(this);

  @JsonKey(name: 'affected')
  final AdditionalInfoResponse$Infos$Affected? affected;
  @JsonKey(name: 'current', defaultValue: <AdditionalInfoResponseMessage>[])
  final List<AdditionalInfoResponseMessage>? current;
  @JsonKey(name: 'historic', defaultValue: <AdditionalInfoResponseMessage>[])
  final List<AdditionalInfoResponseMessage>? historic;
  static const fromJsonFactory = _$AdditionalInfoResponse$InfosFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponse$Infos &&
            (identical(other.affected, affected) ||
                const DeepCollectionEquality()
                    .equals(other.affected, affected)) &&
            (identical(other.current, current) ||
                const DeepCollectionEquality()
                    .equals(other.current, current)) &&
            (identical(other.historic, historic) ||
                const DeepCollectionEquality()
                    .equals(other.historic, historic)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(affected) ^
      const DeepCollectionEquality().hash(current) ^
      const DeepCollectionEquality().hash(historic) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponse$InfosExtension
    on AdditionalInfoResponse$Infos {
  AdditionalInfoResponse$Infos copyWith(
      {AdditionalInfoResponse$Infos$Affected? affected,
      List<AdditionalInfoResponseMessage>? current,
      List<AdditionalInfoResponseMessage>? historic}) {
    return AdditionalInfoResponse$Infos(
        affected: affected ?? this.affected,
        current: current ?? this.current,
        historic: historic ?? this.historic);
  }

  AdditionalInfoResponse$Infos copyWithWrapped(
      {Wrapped<AdditionalInfoResponse$Infos$Affected?>? affected,
      Wrapped<List<AdditionalInfoResponseMessage>?>? current,
      Wrapped<List<AdditionalInfoResponseMessage>?>? historic}) {
    return AdditionalInfoResponse$Infos(
        affected: (affected != null ? affected.value : this.affected),
        current: (current != null ? current.value : this.current),
        historic: (historic != null ? historic.value : this.historic));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseAffectedLine$Destination {
  const AdditionalInfoResponseAffectedLine$Destination({
    this.name,
    this.type,
  });

  factory AdditionalInfoResponseAffectedLine$Destination.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseAffectedLine$DestinationFromJson(json);

  static const toJsonFactory =
      _$AdditionalInfoResponseAffectedLine$DestinationToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseAffectedLine$DestinationToJson(this);

  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(
    name: 'type',
    toJson: additionalInfoResponseAffectedLine$DestinationTypeNullableToJson,
    fromJson:
        additionalInfoResponseAffectedLine$DestinationTypeNullableFromJson,
  )
  final enums.AdditionalInfoResponseAffectedLine$DestinationType? type;
  static const fromJsonFactory =
      _$AdditionalInfoResponseAffectedLine$DestinationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseAffectedLine$Destination &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseAffectedLine$DestinationExtension
    on AdditionalInfoResponseAffectedLine$Destination {
  AdditionalInfoResponseAffectedLine$Destination copyWith(
      {String? name,
      enums.AdditionalInfoResponseAffectedLine$DestinationType? type}) {
    return AdditionalInfoResponseAffectedLine$Destination(
        name: name ?? this.name, type: type ?? this.type);
  }

  AdditionalInfoResponseAffectedLine$Destination copyWithWrapped(
      {Wrapped<String?>? name,
      Wrapped<enums.AdditionalInfoResponseAffectedLine$DestinationType?>?
          type}) {
    return AdditionalInfoResponseAffectedLine$Destination(
        name: (name != null ? name.value : this.name),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseMessage$Affected {
  const AdditionalInfoResponseMessage$Affected({
    this.lines,
    this.stops,
  });

  factory AdditionalInfoResponseMessage$Affected.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseMessage$AffectedFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponseMessage$AffectedToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseMessage$AffectedToJson(this);

  @JsonKey(name: 'lines', defaultValue: <AdditionalInfoResponseAffectedLine>[])
  final List<AdditionalInfoResponseAffectedLine>? lines;
  @JsonKey(name: 'stops', defaultValue: <AdditionalInfoResponseAffectedStop>[])
  final List<AdditionalInfoResponseAffectedStop>? stops;
  static const fromJsonFactory =
      _$AdditionalInfoResponseMessage$AffectedFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseMessage$Affected &&
            (identical(other.lines, lines) ||
                const DeepCollectionEquality().equals(other.lines, lines)) &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lines) ^
      const DeepCollectionEquality().hash(stops) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseMessage$AffectedExtension
    on AdditionalInfoResponseMessage$Affected {
  AdditionalInfoResponseMessage$Affected copyWith(
      {List<AdditionalInfoResponseAffectedLine>? lines,
      List<AdditionalInfoResponseAffectedStop>? stops}) {
    return AdditionalInfoResponseMessage$Affected(
        lines: lines ?? this.lines, stops: stops ?? this.stops);
  }

  AdditionalInfoResponseMessage$Affected copyWithWrapped(
      {Wrapped<List<AdditionalInfoResponseAffectedLine>?>? lines,
      Wrapped<List<AdditionalInfoResponseAffectedStop>?>? stops}) {
    return AdditionalInfoResponseMessage$Affected(
        lines: (lines != null ? lines.value : this.lines),
        stops: (stops != null ? stops.value : this.stops));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseMessage$Properties {
  const AdditionalInfoResponseMessage$Properties({
    this.providerCode,
    this.smsText,
    this.source,
  });

  factory AdditionalInfoResponseMessage$Properties.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseMessage$PropertiesFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponseMessage$PropertiesToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseMessage$PropertiesToJson(this);

  @JsonKey(name: 'providerCode')
  final String? providerCode;
  @JsonKey(name: 'smsText')
  final String? smsText;
  @JsonKey(name: 'source')
  final AdditionalInfoResponseMessage$Properties$Source? source;
  static const fromJsonFactory =
      _$AdditionalInfoResponseMessage$PropertiesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseMessage$Properties &&
            (identical(other.providerCode, providerCode) ||
                const DeepCollectionEquality()
                    .equals(other.providerCode, providerCode)) &&
            (identical(other.smsText, smsText) ||
                const DeepCollectionEquality()
                    .equals(other.smsText, smsText)) &&
            (identical(other.source, source) ||
                const DeepCollectionEquality().equals(other.source, source)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(providerCode) ^
      const DeepCollectionEquality().hash(smsText) ^
      const DeepCollectionEquality().hash(source) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseMessage$PropertiesExtension
    on AdditionalInfoResponseMessage$Properties {
  AdditionalInfoResponseMessage$Properties copyWith(
      {String? providerCode,
      String? smsText,
      AdditionalInfoResponseMessage$Properties$Source? source}) {
    return AdditionalInfoResponseMessage$Properties(
        providerCode: providerCode ?? this.providerCode,
        smsText: smsText ?? this.smsText,
        source: source ?? this.source);
  }

  AdditionalInfoResponseMessage$Properties copyWithWrapped(
      {Wrapped<String?>? providerCode,
      Wrapped<String?>? smsText,
      Wrapped<AdditionalInfoResponseMessage$Properties$Source?>? source}) {
    return AdditionalInfoResponseMessage$Properties(
        providerCode:
            (providerCode != null ? providerCode.value : this.providerCode),
        smsText: (smsText != null ? smsText.value : this.smsText),
        source: (source != null ? source.value : this.source));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseTimestamps$Availability {
  const AdditionalInfoResponseTimestamps$Availability({
    this.from,
    this.to,
  });

  factory AdditionalInfoResponseTimestamps$Availability.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseTimestamps$AvailabilityFromJson(json);

  static const toJsonFactory =
      _$AdditionalInfoResponseTimestamps$AvailabilityToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseTimestamps$AvailabilityToJson(this);

  @JsonKey(name: 'from')
  final String? from;
  @JsonKey(name: 'to')
  final String? to;
  static const fromJsonFactory =
      _$AdditionalInfoResponseTimestamps$AvailabilityFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseTimestamps$Availability &&
            (identical(other.from, from) ||
                const DeepCollectionEquality().equals(other.from, from)) &&
            (identical(other.to, to) ||
                const DeepCollectionEquality().equals(other.to, to)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(from) ^
      const DeepCollectionEquality().hash(to) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseTimestamps$AvailabilityExtension
    on AdditionalInfoResponseTimestamps$Availability {
  AdditionalInfoResponseTimestamps$Availability copyWith(
      {String? from, String? to}) {
    return AdditionalInfoResponseTimestamps$Availability(
        from: from ?? this.from, to: to ?? this.to);
  }

  AdditionalInfoResponseTimestamps$Availability copyWithWrapped(
      {Wrapped<String?>? from, Wrapped<String?>? to}) {
    return AdditionalInfoResponseTimestamps$Availability(
        from: (from != null ? from.value : this.from),
        to: (to != null ? to.value : this.to));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseTimestamps$Validity$Item {
  const AdditionalInfoResponseTimestamps$Validity$Item({
    this.from,
    this.to,
  });

  factory AdditionalInfoResponseTimestamps$Validity$Item.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseTimestamps$Validity$ItemFromJson(json);

  static const toJsonFactory =
      _$AdditionalInfoResponseTimestamps$Validity$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseTimestamps$Validity$ItemToJson(this);

  @JsonKey(name: 'from')
  final String? from;
  @JsonKey(name: 'to')
  final String? to;
  static const fromJsonFactory =
      _$AdditionalInfoResponseTimestamps$Validity$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseTimestamps$Validity$Item &&
            (identical(other.from, from) ||
                const DeepCollectionEquality().equals(other.from, from)) &&
            (identical(other.to, to) ||
                const DeepCollectionEquality().equals(other.to, to)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(from) ^
      const DeepCollectionEquality().hash(to) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseTimestamps$Validity$ItemExtension
    on AdditionalInfoResponseTimestamps$Validity$Item {
  AdditionalInfoResponseTimestamps$Validity$Item copyWith(
      {String? from, String? to}) {
    return AdditionalInfoResponseTimestamps$Validity$Item(
        from: from ?? this.from, to: to ?? this.to);
  }

  AdditionalInfoResponseTimestamps$Validity$Item copyWithWrapped(
      {Wrapped<String?>? from, Wrapped<String?>? to}) {
    return AdditionalInfoResponseTimestamps$Validity$Item(
        from: (from != null ? from.value : this.from),
        to: (to != null ? to.value : this.to));
  }
}

@JsonSerializable(explicitToJson: true)
class ApiErrorResponse$Versions {
  const ApiErrorResponse$Versions({
    this.controller,
    this.interfaceMax,
    this.interfaceMin,
  });

  factory ApiErrorResponse$Versions.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponse$VersionsFromJson(json);

  static const toJsonFactory = _$ApiErrorResponse$VersionsToJson;
  Map<String, dynamic> toJson() => _$ApiErrorResponse$VersionsToJson(this);

  @JsonKey(name: 'controller')
  final String? controller;
  @JsonKey(name: 'interfaceMax')
  final String? interfaceMax;
  @JsonKey(name: 'interfaceMin')
  final String? interfaceMin;
  static const fromJsonFactory = _$ApiErrorResponse$VersionsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiErrorResponse$Versions &&
            (identical(other.controller, controller) ||
                const DeepCollectionEquality()
                    .equals(other.controller, controller)) &&
            (identical(other.interfaceMax, interfaceMax) ||
                const DeepCollectionEquality()
                    .equals(other.interfaceMax, interfaceMax)) &&
            (identical(other.interfaceMin, interfaceMin) ||
                const DeepCollectionEquality()
                    .equals(other.interfaceMin, interfaceMin)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(controller) ^
      const DeepCollectionEquality().hash(interfaceMax) ^
      const DeepCollectionEquality().hash(interfaceMin) ^
      runtimeType.hashCode;
}

extension $ApiErrorResponse$VersionsExtension on ApiErrorResponse$Versions {
  ApiErrorResponse$Versions copyWith(
      {String? controller, String? interfaceMax, String? interfaceMin}) {
    return ApiErrorResponse$Versions(
        controller: controller ?? this.controller,
        interfaceMax: interfaceMax ?? this.interfaceMax,
        interfaceMin: interfaceMin ?? this.interfaceMin);
  }

  ApiErrorResponse$Versions copyWithWrapped(
      {Wrapped<String?>? controller,
      Wrapped<String?>? interfaceMax,
      Wrapped<String?>? interfaceMin}) {
    return ApiErrorResponse$Versions(
        controller: (controller != null ? controller.value : this.controller),
        interfaceMax:
            (interfaceMax != null ? interfaceMax.value : this.interfaceMax),
        interfaceMin:
            (interfaceMin != null ? interfaceMin.value : this.interfaceMin));
  }
}

@JsonSerializable(explicitToJson: true)
class CoordRequestResponseLocation$Properties {
  const CoordRequestResponseLocation$Properties({
    this.gisdrawclass,
    this.gisdrawclasstype,
    this.gisniveau,
    this.poidrawclass,
    this.poidrawclasstype,
    this.poihierarchy0,
    this.poihierarchykey,
    this.distance,
  });

  factory CoordRequestResponseLocation$Properties.fromJson(
          Map<String, dynamic> json) =>
      _$CoordRequestResponseLocation$PropertiesFromJson(json);

  static const toJsonFactory = _$CoordRequestResponseLocation$PropertiesToJson;
  Map<String, dynamic> toJson() =>
      _$CoordRequestResponseLocation$PropertiesToJson(this);

  @JsonKey(name: 'GIS_DRAW_CLASS')
  final String? gisdrawclass;
  @JsonKey(
    name: 'GIS_DRAW_CLASS_TYPE',
    toJson:
        coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPENullableToJson,
    fromJson:
        coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPENullableFromJson,
  )
  final enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE?
      gisdrawclasstype;
  @JsonKey(name: 'GIS_NIVEAU')
  final String? gisniveau;
  @JsonKey(name: 'POI_DRAW_CLASS')
  final String? poidrawclass;
  @JsonKey(
    name: 'POI_DRAW_CLASS_TYPE',
    toJson:
        coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPENullableToJson,
    fromJson:
        coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPENullableFromJson,
  )
  final enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE?
      poidrawclasstype;
  @JsonKey(name: 'POI_HIERARCHY_0')
  final String? poihierarchy0;
  @JsonKey(name: 'POI_HIERARCHY_KEY')
  final String? poihierarchykey;
  @JsonKey(name: 'distance')
  final String? distance;
  static const fromJsonFactory =
      _$CoordRequestResponseLocation$PropertiesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CoordRequestResponseLocation$Properties &&
            (identical(other.gisdrawclass, gisdrawclass) ||
                const DeepCollectionEquality()
                    .equals(other.gisdrawclass, gisdrawclass)) &&
            (identical(other.gisdrawclasstype, gisdrawclasstype) ||
                const DeepCollectionEquality()
                    .equals(other.gisdrawclasstype, gisdrawclasstype)) &&
            (identical(other.gisniveau, gisniveau) ||
                const DeepCollectionEquality()
                    .equals(other.gisniveau, gisniveau)) &&
            (identical(other.poidrawclass, poidrawclass) ||
                const DeepCollectionEquality()
                    .equals(other.poidrawclass, poidrawclass)) &&
            (identical(other.poidrawclasstype, poidrawclasstype) ||
                const DeepCollectionEquality()
                    .equals(other.poidrawclasstype, poidrawclasstype)) &&
            (identical(other.poihierarchy0, poihierarchy0) ||
                const DeepCollectionEquality()
                    .equals(other.poihierarchy0, poihierarchy0)) &&
            (identical(other.poihierarchykey, poihierarchykey) ||
                const DeepCollectionEquality()
                    .equals(other.poihierarchykey, poihierarchykey)) &&
            (identical(other.distance, distance) ||
                const DeepCollectionEquality()
                    .equals(other.distance, distance)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(gisdrawclass) ^
      const DeepCollectionEquality().hash(gisdrawclasstype) ^
      const DeepCollectionEquality().hash(gisniveau) ^
      const DeepCollectionEquality().hash(poidrawclass) ^
      const DeepCollectionEquality().hash(poidrawclasstype) ^
      const DeepCollectionEquality().hash(poihierarchy0) ^
      const DeepCollectionEquality().hash(poihierarchykey) ^
      const DeepCollectionEquality().hash(distance) ^
      runtimeType.hashCode;
}

extension $CoordRequestResponseLocation$PropertiesExtension
    on CoordRequestResponseLocation$Properties {
  CoordRequestResponseLocation$Properties copyWith(
      {String? gisdrawclass,
      enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE?
          gisdrawclasstype,
      String? gisniveau,
      String? poidrawclass,
      enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE?
          poidrawclasstype,
      String? poihierarchy0,
      String? poihierarchykey,
      String? distance}) {
    return CoordRequestResponseLocation$Properties(
        gisdrawclass: gisdrawclass ?? this.gisdrawclass,
        gisdrawclasstype: gisdrawclasstype ?? this.gisdrawclasstype,
        gisniveau: gisniveau ?? this.gisniveau,
        poidrawclass: poidrawclass ?? this.poidrawclass,
        poidrawclasstype: poidrawclasstype ?? this.poidrawclasstype,
        poihierarchy0: poihierarchy0 ?? this.poihierarchy0,
        poihierarchykey: poihierarchykey ?? this.poihierarchykey,
        distance: distance ?? this.distance);
  }

  CoordRequestResponseLocation$Properties copyWithWrapped(
      {Wrapped<String?>? gisdrawclass,
      Wrapped<enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE?>?
          gisdrawclasstype,
      Wrapped<String?>? gisniveau,
      Wrapped<String?>? poidrawclass,
      Wrapped<enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE?>?
          poidrawclasstype,
      Wrapped<String?>? poihierarchy0,
      Wrapped<String?>? poihierarchykey,
      Wrapped<String?>? distance}) {
    return CoordRequestResponseLocation$Properties(
        gisdrawclass:
            (gisdrawclass != null ? gisdrawclass.value : this.gisdrawclass),
        gisdrawclasstype: (gisdrawclasstype != null
            ? gisdrawclasstype.value
            : this.gisdrawclasstype),
        gisniveau: (gisniveau != null ? gisniveau.value : this.gisniveau),
        poidrawclass:
            (poidrawclass != null ? poidrawclass.value : this.poidrawclass),
        poidrawclasstype: (poidrawclasstype != null
            ? poidrawclasstype.value
            : this.poidrawclasstype),
        poihierarchy0:
            (poihierarchy0 != null ? poihierarchy0.value : this.poihierarchy0),
        poihierarchykey: (poihierarchykey != null
            ? poihierarchykey.value
            : this.poihierarchykey),
        distance: (distance != null ? distance.value : this.distance));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponse$SystemMessages {
  const TripRequestResponse$SystemMessages({
    this.responseMessages,
  });

  factory TripRequestResponse$SystemMessages.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponse$SystemMessagesFromJson(json);

  static const toJsonFactory = _$TripRequestResponse$SystemMessagesToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponse$SystemMessagesToJson(this);

  @JsonKey(
      name: 'responseMessages', defaultValue: <TripRequestResponseMessage>[])
  final List<TripRequestResponseMessage>? responseMessages;
  static const fromJsonFactory = _$TripRequestResponse$SystemMessagesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponse$SystemMessages &&
            (identical(other.responseMessages, responseMessages) ||
                const DeepCollectionEquality()
                    .equals(other.responseMessages, responseMessages)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(responseMessages) ^
      runtimeType.hashCode;
}

extension $TripRequestResponse$SystemMessagesExtension
    on TripRequestResponse$SystemMessages {
  TripRequestResponse$SystemMessages copyWith(
      {List<TripRequestResponseMessage>? responseMessages}) {
    return TripRequestResponse$SystemMessages(
        responseMessages: responseMessages ?? this.responseMessages);
  }

  TripRequestResponse$SystemMessages copyWithWrapped(
      {Wrapped<List<TripRequestResponseMessage>?>? responseMessages}) {
    return TripRequestResponse$SystemMessages(
        responseMessages: (responseMessages != null
            ? responseMessages.value
            : this.responseMessages));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLeg$Hints$Item {
  const TripRequestResponseJourneyLeg$Hints$Item({
    this.infoText,
  });

  factory TripRequestResponseJourneyLeg$Hints$Item.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLeg$Hints$ItemFromJson(json);

  static const toJsonFactory = _$TripRequestResponseJourneyLeg$Hints$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLeg$Hints$ItemToJson(this);

  @JsonKey(name: 'infoText')
  final String? infoText;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLeg$Hints$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLeg$Hints$Item &&
            (identical(other.infoText, infoText) ||
                const DeepCollectionEquality()
                    .equals(other.infoText, infoText)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(infoText) ^ runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLeg$Hints$ItemExtension
    on TripRequestResponseJourneyLeg$Hints$Item {
  TripRequestResponseJourneyLeg$Hints$Item copyWith({String? infoText}) {
    return TripRequestResponseJourneyLeg$Hints$Item(
        infoText: infoText ?? this.infoText);
  }

  TripRequestResponseJourneyLeg$Hints$Item copyWithWrapped(
      {Wrapped<String?>? infoText}) {
    return TripRequestResponseJourneyLeg$Hints$Item(
        infoText: (infoText != null ? infoText.value : this.infoText));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLeg$Properties {
  const TripRequestResponseJourneyLeg$Properties({
    this.differentfares,
    this.planLowFloorVehicle,
    this.planWheelChairAccess,
    this.lineType,
    this.vehicleAccess,
  });

  factory TripRequestResponseJourneyLeg$Properties.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLeg$PropertiesFromJson(json);

  static const toJsonFactory = _$TripRequestResponseJourneyLeg$PropertiesToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLeg$PropertiesToJson(this);

  @JsonKey(name: 'DIFFERENT_FARES')
  final String? differentfares;
  @JsonKey(name: 'PlanLowFloorVehicle')
  final String? planLowFloorVehicle;
  @JsonKey(name: 'PlanWheelChairAccess')
  final String? planWheelChairAccess;
  @JsonKey(name: 'lineType')
  final String? lineType;
  @JsonKey(name: 'vehicleAccess', defaultValue: <String>[])
  final List<String>? vehicleAccess;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLeg$PropertiesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLeg$Properties &&
            (identical(other.differentfares, differentfares) ||
                const DeepCollectionEquality()
                    .equals(other.differentfares, differentfares)) &&
            (identical(other.planLowFloorVehicle, planLowFloorVehicle) ||
                const DeepCollectionEquality()
                    .equals(other.planLowFloorVehicle, planLowFloorVehicle)) &&
            (identical(other.planWheelChairAccess, planWheelChairAccess) ||
                const DeepCollectionEquality().equals(
                    other.planWheelChairAccess, planWheelChairAccess)) &&
            (identical(other.lineType, lineType) ||
                const DeepCollectionEquality()
                    .equals(other.lineType, lineType)) &&
            (identical(other.vehicleAccess, vehicleAccess) ||
                const DeepCollectionEquality()
                    .equals(other.vehicleAccess, vehicleAccess)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(differentfares) ^
      const DeepCollectionEquality().hash(planLowFloorVehicle) ^
      const DeepCollectionEquality().hash(planWheelChairAccess) ^
      const DeepCollectionEquality().hash(lineType) ^
      const DeepCollectionEquality().hash(vehicleAccess) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLeg$PropertiesExtension
    on TripRequestResponseJourneyLeg$Properties {
  TripRequestResponseJourneyLeg$Properties copyWith(
      {String? differentfares,
      String? planLowFloorVehicle,
      String? planWheelChairAccess,
      String? lineType,
      List<String>? vehicleAccess}) {
    return TripRequestResponseJourneyLeg$Properties(
        differentfares: differentfares ?? this.differentfares,
        planLowFloorVehicle: planLowFloorVehicle ?? this.planLowFloorVehicle,
        planWheelChairAccess: planWheelChairAccess ?? this.planWheelChairAccess,
        lineType: lineType ?? this.lineType,
        vehicleAccess: vehicleAccess ?? this.vehicleAccess);
  }

  TripRequestResponseJourneyLeg$Properties copyWithWrapped(
      {Wrapped<String?>? differentfares,
      Wrapped<String?>? planLowFloorVehicle,
      Wrapped<String?>? planWheelChairAccess,
      Wrapped<String?>? lineType,
      Wrapped<List<String>?>? vehicleAccess}) {
    return TripRequestResponseJourneyLeg$Properties(
        differentfares: (differentfares != null
            ? differentfares.value
            : this.differentfares),
        planLowFloorVehicle: (planLowFloorVehicle != null
            ? planLowFloorVehicle.value
            : this.planLowFloorVehicle),
        planWheelChairAccess: (planWheelChairAccess != null
            ? planWheelChairAccess.value
            : this.planWheelChairAccess),
        lineType: (lineType != null ? lineType.value : this.lineType),
        vehicleAccess:
            (vehicleAccess != null ? vehicleAccess.value : this.vehicleAccess));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegStop$Properties {
  const TripRequestResponseJourneyLegStop$Properties({
    this.wheelchairAccess,
    this.downloads,
  });

  factory TripRequestResponseJourneyLegStop$Properties.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegStop$PropertiesFromJson(json);

  static const toJsonFactory =
      _$TripRequestResponseJourneyLegStop$PropertiesToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegStop$PropertiesToJson(this);

  @JsonKey(
    name: 'WheelchairAccess',
    toJson:
        tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessNullableToJson,
    fromJson:
        tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessNullableFromJson,
  )
  final enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess?
      wheelchairAccess;
  @JsonKey(
      name: 'downloads',
      defaultValue: <TripRequestResponseJourneyLegStopDownload>[])
  final List<TripRequestResponseJourneyLegStopDownload>? downloads;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegStop$PropertiesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegStop$Properties &&
            (identical(other.wheelchairAccess, wheelchairAccess) ||
                const DeepCollectionEquality()
                    .equals(other.wheelchairAccess, wheelchairAccess)) &&
            (identical(other.downloads, downloads) ||
                const DeepCollectionEquality()
                    .equals(other.downloads, downloads)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(wheelchairAccess) ^
      const DeepCollectionEquality().hash(downloads) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegStop$PropertiesExtension
    on TripRequestResponseJourneyLegStop$Properties {
  TripRequestResponseJourneyLegStop$Properties copyWith(
      {enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess?
          wheelchairAccess,
      List<TripRequestResponseJourneyLegStopDownload>? downloads}) {
    return TripRequestResponseJourneyLegStop$Properties(
        wheelchairAccess: wheelchairAccess ?? this.wheelchairAccess,
        downloads: downloads ?? this.downloads);
  }

  TripRequestResponseJourneyLegStop$Properties copyWithWrapped(
      {Wrapped<
              enums
              .TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess?>?
          wheelchairAccess,
      Wrapped<List<TripRequestResponseJourneyLegStopDownload>?>? downloads}) {
    return TripRequestResponseJourneyLegStop$Properties(
        wheelchairAccess: (wheelchairAccess != null
            ? wheelchairAccess.value
            : this.wheelchairAccess),
        downloads: (downloads != null ? downloads.value : this.downloads));
  }
}

@JsonSerializable(explicitToJson: true)
class TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location {
  const TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location({
    this.coord,
    this.id,
    this.type,
  });

  factory TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location.fromJson(
          Map<String, dynamic> json) =>
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationFromJson(
          json);

  static const toJsonFactory =
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationToJson;
  Map<String, dynamic> toJson() =>
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationToJson(
          this);

  @JsonKey(name: 'coord', defaultValue: <double>[])
  final List<double>? coord;
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(
    name: 'type',
    toJson:
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeNullableToJson,
    fromJson:
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeNullableFromJson,
  )
  final enums
      .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType?
      type;
  static const fromJsonFactory =
      _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location &&
            (identical(other.coord, coord) ||
                const DeepCollectionEquality().equals(other.coord, coord)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(coord) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationExtension
    on TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location {
  TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location
      copyWith(
          {List<double>? coord,
          String? id,
          enums
              .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType?
              type}) {
    return TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location(
        coord: coord ?? this.coord, id: id ?? this.id, type: type ?? this.type);
  }

  TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location
      copyWithWrapped(
          {Wrapped<List<double>?>? coord,
          Wrapped<String?>? id,
          Wrapped<
                  enums
                  .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType?>?
              type}) {
    return TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location(
        coord: (coord != null ? coord.value : this.coord),
        id: (id != null ? id.value : this.id),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class TripTransportation$Destination {
  const TripTransportation$Destination({
    this.id,
    this.name,
  });

  factory TripTransportation$Destination.fromJson(Map<String, dynamic> json) =>
      _$TripTransportation$DestinationFromJson(json);

  static const toJsonFactory = _$TripTransportation$DestinationToJson;
  Map<String, dynamic> toJson() => _$TripTransportation$DestinationToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  static const fromJsonFactory = _$TripTransportation$DestinationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripTransportation$Destination &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      runtimeType.hashCode;
}

extension $TripTransportation$DestinationExtension
    on TripTransportation$Destination {
  TripTransportation$Destination copyWith({String? id, String? name}) {
    return TripTransportation$Destination(
        id: id ?? this.id, name: name ?? this.name);
  }

  TripTransportation$Destination copyWithWrapped(
      {Wrapped<String?>? id, Wrapped<String?>? name}) {
    return TripTransportation$Destination(
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name));
  }
}

@JsonSerializable(explicitToJson: true)
class TripTransportation$Operator {
  const TripTransportation$Operator({
    this.id,
    this.name,
  });

  factory TripTransportation$Operator.fromJson(Map<String, dynamic> json) =>
      _$TripTransportation$OperatorFromJson(json);

  static const toJsonFactory = _$TripTransportation$OperatorToJson;
  Map<String, dynamic> toJson() => _$TripTransportation$OperatorToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  static const fromJsonFactory = _$TripTransportation$OperatorFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripTransportation$Operator &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      runtimeType.hashCode;
}

extension $TripTransportation$OperatorExtension on TripTransportation$Operator {
  TripTransportation$Operator copyWith({String? id, String? name}) {
    return TripTransportation$Operator(
        id: id ?? this.id, name: name ?? this.name);
  }

  TripTransportation$Operator copyWithWrapped(
      {Wrapped<String?>? id, Wrapped<String?>? name}) {
    return TripTransportation$Operator(
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name));
  }
}

@JsonSerializable(explicitToJson: true)
class TripTransportation$Properties {
  const TripTransportation$Properties({
    this.isTTB,
    this.tripCode,
  });

  factory TripTransportation$Properties.fromJson(Map<String, dynamic> json) =>
      _$TripTransportation$PropertiesFromJson(json);

  static const toJsonFactory = _$TripTransportation$PropertiesToJson;
  Map<String, dynamic> toJson() => _$TripTransportation$PropertiesToJson(this);

  @JsonKey(name: 'isTTB')
  final bool? isTTB;
  @JsonKey(name: 'tripCode')
  final int? tripCode;
  static const fromJsonFactory = _$TripTransportation$PropertiesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TripTransportation$Properties &&
            (identical(other.isTTB, isTTB) ||
                const DeepCollectionEquality().equals(other.isTTB, isTTB)) &&
            (identical(other.tripCode, tripCode) ||
                const DeepCollectionEquality()
                    .equals(other.tripCode, tripCode)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(isTTB) ^
      const DeepCollectionEquality().hash(tripCode) ^
      runtimeType.hashCode;
}

extension $TripTransportation$PropertiesExtension
    on TripTransportation$Properties {
  TripTransportation$Properties copyWith({bool? isTTB, int? tripCode}) {
    return TripTransportation$Properties(
        isTTB: isTTB ?? this.isTTB, tripCode: tripCode ?? this.tripCode);
  }

  TripTransportation$Properties copyWithWrapped(
      {Wrapped<bool?>? isTTB, Wrapped<int?>? tripCode}) {
    return TripTransportation$Properties(
        isTTB: (isTTB != null ? isTTB.value : this.isTTB),
        tripCode: (tripCode != null ? tripCode.value : this.tripCode));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponse$Infos$Affected {
  const AdditionalInfoResponse$Infos$Affected({
    this.lines,
    this.stops,
  });

  factory AdditionalInfoResponse$Infos$Affected.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponse$Infos$AffectedFromJson(json);

  static const toJsonFactory = _$AdditionalInfoResponse$Infos$AffectedToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponse$Infos$AffectedToJson(this);

  @JsonKey(name: 'lines', defaultValue: <AdditionalInfoResponseAffectedLine>[])
  final List<AdditionalInfoResponseAffectedLine>? lines;
  @JsonKey(name: 'stops', defaultValue: <AdditionalInfoResponseAffectedStop>[])
  final List<AdditionalInfoResponseAffectedStop>? stops;
  static const fromJsonFactory =
      _$AdditionalInfoResponse$Infos$AffectedFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponse$Infos$Affected &&
            (identical(other.lines, lines) ||
                const DeepCollectionEquality().equals(other.lines, lines)) &&
            (identical(other.stops, stops) ||
                const DeepCollectionEquality().equals(other.stops, stops)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(lines) ^
      const DeepCollectionEquality().hash(stops) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponse$Infos$AffectedExtension
    on AdditionalInfoResponse$Infos$Affected {
  AdditionalInfoResponse$Infos$Affected copyWith(
      {List<AdditionalInfoResponseAffectedLine>? lines,
      List<AdditionalInfoResponseAffectedStop>? stops}) {
    return AdditionalInfoResponse$Infos$Affected(
        lines: lines ?? this.lines, stops: stops ?? this.stops);
  }

  AdditionalInfoResponse$Infos$Affected copyWithWrapped(
      {Wrapped<List<AdditionalInfoResponseAffectedLine>?>? lines,
      Wrapped<List<AdditionalInfoResponseAffectedStop>?>? stops}) {
    return AdditionalInfoResponse$Infos$Affected(
        lines: (lines != null ? lines.value : this.lines),
        stops: (stops != null ? stops.value : this.stops));
  }
}

@JsonSerializable(explicitToJson: true)
class AdditionalInfoResponseMessage$Properties$Source {
  const AdditionalInfoResponseMessage$Properties$Source({
    this.id,
    this.name,
    this.type,
  });

  factory AdditionalInfoResponseMessage$Properties$Source.fromJson(
          Map<String, dynamic> json) =>
      _$AdditionalInfoResponseMessage$Properties$SourceFromJson(json);

  static const toJsonFactory =
      _$AdditionalInfoResponseMessage$Properties$SourceToJson;
  Map<String, dynamic> toJson() =>
      _$AdditionalInfoResponseMessage$Properties$SourceToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'type')
  final String? type;
  static const fromJsonFactory =
      _$AdditionalInfoResponseMessage$Properties$SourceFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdditionalInfoResponseMessage$Properties$Source &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $AdditionalInfoResponseMessage$Properties$SourceExtension
    on AdditionalInfoResponseMessage$Properties$Source {
  AdditionalInfoResponseMessage$Properties$Source copyWith(
      {String? id, String? name, String? type}) {
    return AdditionalInfoResponseMessage$Properties$Source(
        id: id ?? this.id, name: name ?? this.name, type: type ?? this.type);
  }

  AdditionalInfoResponseMessage$Properties$Source copyWithWrapped(
      {Wrapped<String?>? id, Wrapped<String?>? name, Wrapped<String?>? type}) {
    return AdditionalInfoResponseMessage$Properties$Source(
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        type: (type != null ? type.value : this.type));
  }
}

String? additionalInfoResponseAffectedLine$DestinationTypeNullableToJson(
    enums.AdditionalInfoResponseAffectedLine$DestinationType?
        additionalInfoResponseAffectedLine$DestinationType) {
  return additionalInfoResponseAffectedLine$DestinationType?.value;
}

String? additionalInfoResponseAffectedLine$DestinationTypeToJson(
    enums.AdditionalInfoResponseAffectedLine$DestinationType
        additionalInfoResponseAffectedLine$DestinationType) {
  return additionalInfoResponseAffectedLine$DestinationType.value;
}

enums.AdditionalInfoResponseAffectedLine$DestinationType
    additionalInfoResponseAffectedLine$DestinationTypeFromJson(
  Object? additionalInfoResponseAffectedLine$DestinationType, [
  enums.AdditionalInfoResponseAffectedLine$DestinationType? defaultValue,
]) {
  return enums.AdditionalInfoResponseAffectedLine$DestinationType.values
          .firstWhereOrNull((e) =>
              e.value == additionalInfoResponseAffectedLine$DestinationType) ??
      defaultValue ??
      enums.AdditionalInfoResponseAffectedLine$DestinationType
          .swaggerGeneratedUnknown;
}

enums.AdditionalInfoResponseAffectedLine$DestinationType?
    additionalInfoResponseAffectedLine$DestinationTypeNullableFromJson(
  Object? additionalInfoResponseAffectedLine$DestinationType, [
  enums.AdditionalInfoResponseAffectedLine$DestinationType? defaultValue,
]) {
  if (additionalInfoResponseAffectedLine$DestinationType == null) {
    return null;
  }
  return enums.AdditionalInfoResponseAffectedLine$DestinationType.values
          .firstWhereOrNull((e) =>
              e.value == additionalInfoResponseAffectedLine$DestinationType) ??
      defaultValue;
}

String additionalInfoResponseAffectedLine$DestinationTypeExplodedListToJson(
    List<enums.AdditionalInfoResponseAffectedLine$DestinationType>?
        additionalInfoResponseAffectedLine$DestinationType) {
  return additionalInfoResponseAffectedLine$DestinationType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> additionalInfoResponseAffectedLine$DestinationTypeListToJson(
    List<enums.AdditionalInfoResponseAffectedLine$DestinationType>?
        additionalInfoResponseAffectedLine$DestinationType) {
  if (additionalInfoResponseAffectedLine$DestinationType == null) {
    return [];
  }

  return additionalInfoResponseAffectedLine$DestinationType
      .map((e) => e.value!)
      .toList();
}

List<enums.AdditionalInfoResponseAffectedLine$DestinationType>
    additionalInfoResponseAffectedLine$DestinationTypeListFromJson(
  List? additionalInfoResponseAffectedLine$DestinationType, [
  List<enums.AdditionalInfoResponseAffectedLine$DestinationType>? defaultValue,
]) {
  if (additionalInfoResponseAffectedLine$DestinationType == null) {
    return defaultValue ?? [];
  }

  return additionalInfoResponseAffectedLine$DestinationType
      .map((e) => additionalInfoResponseAffectedLine$DestinationTypeFromJson(
          e.toString()))
      .toList();
}

List<enums.AdditionalInfoResponseAffectedLine$DestinationType>?
    additionalInfoResponseAffectedLine$DestinationTypeNullableListFromJson(
  List? additionalInfoResponseAffectedLine$DestinationType, [
  List<enums.AdditionalInfoResponseAffectedLine$DestinationType>? defaultValue,
]) {
  if (additionalInfoResponseAffectedLine$DestinationType == null) {
    return defaultValue;
  }

  return additionalInfoResponseAffectedLine$DestinationType
      .map((e) => additionalInfoResponseAffectedLine$DestinationTypeFromJson(
          e.toString()))
      .toList();
}

String? additionalInfoResponseAffectedStopTypeNullableToJson(
    enums.AdditionalInfoResponseAffectedStopType?
        additionalInfoResponseAffectedStopType) {
  return additionalInfoResponseAffectedStopType?.value;
}

String? additionalInfoResponseAffectedStopTypeToJson(
    enums.AdditionalInfoResponseAffectedStopType
        additionalInfoResponseAffectedStopType) {
  return additionalInfoResponseAffectedStopType.value;
}

enums.AdditionalInfoResponseAffectedStopType
    additionalInfoResponseAffectedStopTypeFromJson(
  Object? additionalInfoResponseAffectedStopType, [
  enums.AdditionalInfoResponseAffectedStopType? defaultValue,
]) {
  return enums.AdditionalInfoResponseAffectedStopType.values.firstWhereOrNull(
          (e) => e.value == additionalInfoResponseAffectedStopType) ??
      defaultValue ??
      enums.AdditionalInfoResponseAffectedStopType.swaggerGeneratedUnknown;
}

enums.AdditionalInfoResponseAffectedStopType?
    additionalInfoResponseAffectedStopTypeNullableFromJson(
  Object? additionalInfoResponseAffectedStopType, [
  enums.AdditionalInfoResponseAffectedStopType? defaultValue,
]) {
  if (additionalInfoResponseAffectedStopType == null) {
    return null;
  }
  return enums.AdditionalInfoResponseAffectedStopType.values.firstWhereOrNull(
          (e) => e.value == additionalInfoResponseAffectedStopType) ??
      defaultValue;
}

String additionalInfoResponseAffectedStopTypeExplodedListToJson(
    List<enums.AdditionalInfoResponseAffectedStopType>?
        additionalInfoResponseAffectedStopType) {
  return additionalInfoResponseAffectedStopType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> additionalInfoResponseAffectedStopTypeListToJson(
    List<enums.AdditionalInfoResponseAffectedStopType>?
        additionalInfoResponseAffectedStopType) {
  if (additionalInfoResponseAffectedStopType == null) {
    return [];
  }

  return additionalInfoResponseAffectedStopType.map((e) => e.value!).toList();
}

List<enums.AdditionalInfoResponseAffectedStopType>
    additionalInfoResponseAffectedStopTypeListFromJson(
  List? additionalInfoResponseAffectedStopType, [
  List<enums.AdditionalInfoResponseAffectedStopType>? defaultValue,
]) {
  if (additionalInfoResponseAffectedStopType == null) {
    return defaultValue ?? [];
  }

  return additionalInfoResponseAffectedStopType
      .map((e) => additionalInfoResponseAffectedStopTypeFromJson(e.toString()))
      .toList();
}

List<enums.AdditionalInfoResponseAffectedStopType>?
    additionalInfoResponseAffectedStopTypeNullableListFromJson(
  List? additionalInfoResponseAffectedStopType, [
  List<enums.AdditionalInfoResponseAffectedStopType>? defaultValue,
]) {
  if (additionalInfoResponseAffectedStopType == null) {
    return defaultValue;
  }

  return additionalInfoResponseAffectedStopType
      .map((e) => additionalInfoResponseAffectedStopTypeFromJson(e.toString()))
      .toList();
}

String? additionalInfoResponseMessagePriorityNullableToJson(
    enums.AdditionalInfoResponseMessagePriority?
        additionalInfoResponseMessagePriority) {
  return additionalInfoResponseMessagePriority?.value;
}

String? additionalInfoResponseMessagePriorityToJson(
    enums.AdditionalInfoResponseMessagePriority
        additionalInfoResponseMessagePriority) {
  return additionalInfoResponseMessagePriority.value;
}

enums.AdditionalInfoResponseMessagePriority
    additionalInfoResponseMessagePriorityFromJson(
  Object? additionalInfoResponseMessagePriority, [
  enums.AdditionalInfoResponseMessagePriority? defaultValue,
]) {
  return enums.AdditionalInfoResponseMessagePriority.values.firstWhereOrNull(
          (e) => e.value == additionalInfoResponseMessagePriority) ??
      defaultValue ??
      enums.AdditionalInfoResponseMessagePriority.swaggerGeneratedUnknown;
}

enums.AdditionalInfoResponseMessagePriority?
    additionalInfoResponseMessagePriorityNullableFromJson(
  Object? additionalInfoResponseMessagePriority, [
  enums.AdditionalInfoResponseMessagePriority? defaultValue,
]) {
  if (additionalInfoResponseMessagePriority == null) {
    return null;
  }
  return enums.AdditionalInfoResponseMessagePriority.values.firstWhereOrNull(
          (e) => e.value == additionalInfoResponseMessagePriority) ??
      defaultValue;
}

String additionalInfoResponseMessagePriorityExplodedListToJson(
    List<enums.AdditionalInfoResponseMessagePriority>?
        additionalInfoResponseMessagePriority) {
  return additionalInfoResponseMessagePriority
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> additionalInfoResponseMessagePriorityListToJson(
    List<enums.AdditionalInfoResponseMessagePriority>?
        additionalInfoResponseMessagePriority) {
  if (additionalInfoResponseMessagePriority == null) {
    return [];
  }

  return additionalInfoResponseMessagePriority.map((e) => e.value!).toList();
}

List<enums.AdditionalInfoResponseMessagePriority>
    additionalInfoResponseMessagePriorityListFromJson(
  List? additionalInfoResponseMessagePriority, [
  List<enums.AdditionalInfoResponseMessagePriority>? defaultValue,
]) {
  if (additionalInfoResponseMessagePriority == null) {
    return defaultValue ?? [];
  }

  return additionalInfoResponseMessagePriority
      .map((e) => additionalInfoResponseMessagePriorityFromJson(e.toString()))
      .toList();
}

List<enums.AdditionalInfoResponseMessagePriority>?
    additionalInfoResponseMessagePriorityNullableListFromJson(
  List? additionalInfoResponseMessagePriority, [
  List<enums.AdditionalInfoResponseMessagePriority>? defaultValue,
]) {
  if (additionalInfoResponseMessagePriority == null) {
    return defaultValue;
  }

  return additionalInfoResponseMessagePriority
      .map((e) => additionalInfoResponseMessagePriorityFromJson(e.toString()))
      .toList();
}

String? additionalInfoResponseMessageTypeNullableToJson(
    enums.AdditionalInfoResponseMessageType?
        additionalInfoResponseMessageType) {
  return additionalInfoResponseMessageType?.value;
}

String? additionalInfoResponseMessageTypeToJson(
    enums.AdditionalInfoResponseMessageType additionalInfoResponseMessageType) {
  return additionalInfoResponseMessageType.value;
}

enums.AdditionalInfoResponseMessageType
    additionalInfoResponseMessageTypeFromJson(
  Object? additionalInfoResponseMessageType, [
  enums.AdditionalInfoResponseMessageType? defaultValue,
]) {
  return enums.AdditionalInfoResponseMessageType.values.firstWhereOrNull(
          (e) => e.value == additionalInfoResponseMessageType) ??
      defaultValue ??
      enums.AdditionalInfoResponseMessageType.swaggerGeneratedUnknown;
}

enums.AdditionalInfoResponseMessageType?
    additionalInfoResponseMessageTypeNullableFromJson(
  Object? additionalInfoResponseMessageType, [
  enums.AdditionalInfoResponseMessageType? defaultValue,
]) {
  if (additionalInfoResponseMessageType == null) {
    return null;
  }
  return enums.AdditionalInfoResponseMessageType.values.firstWhereOrNull(
          (e) => e.value == additionalInfoResponseMessageType) ??
      defaultValue;
}

String additionalInfoResponseMessageTypeExplodedListToJson(
    List<enums.AdditionalInfoResponseMessageType>?
        additionalInfoResponseMessageType) {
  return additionalInfoResponseMessageType?.map((e) => e.value!).join(',') ??
      '';
}

List<String> additionalInfoResponseMessageTypeListToJson(
    List<enums.AdditionalInfoResponseMessageType>?
        additionalInfoResponseMessageType) {
  if (additionalInfoResponseMessageType == null) {
    return [];
  }

  return additionalInfoResponseMessageType.map((e) => e.value!).toList();
}

List<enums.AdditionalInfoResponseMessageType>
    additionalInfoResponseMessageTypeListFromJson(
  List? additionalInfoResponseMessageType, [
  List<enums.AdditionalInfoResponseMessageType>? defaultValue,
]) {
  if (additionalInfoResponseMessageType == null) {
    return defaultValue ?? [];
  }

  return additionalInfoResponseMessageType
      .map((e) => additionalInfoResponseMessageTypeFromJson(e.toString()))
      .toList();
}

List<enums.AdditionalInfoResponseMessageType>?
    additionalInfoResponseMessageTypeNullableListFromJson(
  List? additionalInfoResponseMessageType, [
  List<enums.AdditionalInfoResponseMessageType>? defaultValue,
]) {
  if (additionalInfoResponseMessageType == null) {
    return defaultValue;
  }

  return additionalInfoResponseMessageType
      .map((e) => additionalInfoResponseMessageTypeFromJson(e.toString()))
      .toList();
}

String? coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPENullableToJson(
    enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE?
        coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE) {
  return coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE?.value;
}

String? coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPEToJson(
    enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE
        coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE) {
  return coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE.value;
}

enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE
    coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPEFromJson(
  Object? coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE, [
  enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE? defaultValue,
]) {
  return enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE.values
          .firstWhereOrNull((e) =>
              e.value ==
              coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE) ??
      defaultValue ??
      enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE
          .swaggerGeneratedUnknown;
}

enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE?
    coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPENullableFromJson(
  Object? coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE, [
  enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE? defaultValue,
]) {
  if (coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE == null) {
    return null;
  }
  return enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE.values
          .firstWhereOrNull((e) =>
              e.value ==
              coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE) ??
      defaultValue;
}

String
    coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPEExplodedListToJson(
        List<enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE>?
            coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE) {
  return coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPEListToJson(
    List<enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE>?
        coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE) {
  if (coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE == null) {
    return [];
  }

  return coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE
      .map((e) => e.value!)
      .toList();
}

List<enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE>
    coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPEListFromJson(
  List? coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE, [
  List<enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE>?
      defaultValue,
]) {
  if (coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE == null) {
    return defaultValue ?? [];
  }

  return coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE
      .map((e) =>
          coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPEFromJson(
              e.toString()))
      .toList();
}

List<enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE>?
    coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPENullableListFromJson(
  List? coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE, [
  List<enums.CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE>?
      defaultValue,
]) {
  if (coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE == null) {
    return defaultValue;
  }

  return coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE
      .map((e) =>
          coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPEFromJson(
              e.toString()))
      .toList();
}

String? coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPENullableToJson(
    enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE?
        coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE) {
  return coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE?.value;
}

String? coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPEToJson(
    enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE
        coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE) {
  return coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE.value;
}

enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE
    coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPEFromJson(
  Object? coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE, [
  enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE? defaultValue,
]) {
  return enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE.values
          .firstWhereOrNull((e) =>
              e.value ==
              coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE) ??
      defaultValue ??
      enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE
          .swaggerGeneratedUnknown;
}

enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE?
    coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPENullableFromJson(
  Object? coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE, [
  enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE? defaultValue,
]) {
  if (coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE == null) {
    return null;
  }
  return enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE.values
          .firstWhereOrNull((e) =>
              e.value ==
              coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE) ??
      defaultValue;
}

String
    coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPEExplodedListToJson(
        List<enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE>?
            coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE) {
  return coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPEListToJson(
    List<enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE>?
        coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE) {
  if (coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE == null) {
    return [];
  }

  return coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE
      .map((e) => e.value!)
      .toList();
}

List<enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE>
    coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPEListFromJson(
  List? coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE, [
  List<enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE>?
      defaultValue,
]) {
  if (coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE == null) {
    return defaultValue ?? [];
  }

  return coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE
      .map((e) =>
          coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPEFromJson(
              e.toString()))
      .toList();
}

List<enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE>?
    coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPENullableListFromJson(
  List? coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE, [
  List<enums.CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE>?
      defaultValue,
]) {
  if (coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE == null) {
    return defaultValue;
  }

  return coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE
      .map((e) =>
          coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPEFromJson(
              e.toString()))
      .toList();
}

String? coordRequestResponseLocationTypeNullableToJson(
    enums.CoordRequestResponseLocationType? coordRequestResponseLocationType) {
  return coordRequestResponseLocationType?.value;
}

String? coordRequestResponseLocationTypeToJson(
    enums.CoordRequestResponseLocationType coordRequestResponseLocationType) {
  return coordRequestResponseLocationType.value;
}

enums.CoordRequestResponseLocationType coordRequestResponseLocationTypeFromJson(
  Object? coordRequestResponseLocationType, [
  enums.CoordRequestResponseLocationType? defaultValue,
]) {
  return enums.CoordRequestResponseLocationType.values.firstWhereOrNull(
          (e) => e.value == coordRequestResponseLocationType) ??
      defaultValue ??
      enums.CoordRequestResponseLocationType.swaggerGeneratedUnknown;
}

enums.CoordRequestResponseLocationType?
    coordRequestResponseLocationTypeNullableFromJson(
  Object? coordRequestResponseLocationType, [
  enums.CoordRequestResponseLocationType? defaultValue,
]) {
  if (coordRequestResponseLocationType == null) {
    return null;
  }
  return enums.CoordRequestResponseLocationType.values.firstWhereOrNull(
          (e) => e.value == coordRequestResponseLocationType) ??
      defaultValue;
}

String coordRequestResponseLocationTypeExplodedListToJson(
    List<enums.CoordRequestResponseLocationType>?
        coordRequestResponseLocationType) {
  return coordRequestResponseLocationType?.map((e) => e.value!).join(',') ?? '';
}

List<String> coordRequestResponseLocationTypeListToJson(
    List<enums.CoordRequestResponseLocationType>?
        coordRequestResponseLocationType) {
  if (coordRequestResponseLocationType == null) {
    return [];
  }

  return coordRequestResponseLocationType.map((e) => e.value!).toList();
}

List<enums.CoordRequestResponseLocationType>
    coordRequestResponseLocationTypeListFromJson(
  List? coordRequestResponseLocationType, [
  List<enums.CoordRequestResponseLocationType>? defaultValue,
]) {
  if (coordRequestResponseLocationType == null) {
    return defaultValue ?? [];
  }

  return coordRequestResponseLocationType
      .map((e) => coordRequestResponseLocationTypeFromJson(e.toString()))
      .toList();
}

List<enums.CoordRequestResponseLocationType>?
    coordRequestResponseLocationTypeNullableListFromJson(
  List? coordRequestResponseLocationType, [
  List<enums.CoordRequestResponseLocationType>? defaultValue,
]) {
  if (coordRequestResponseLocationType == null) {
    return defaultValue;
  }

  return coordRequestResponseLocationType
      .map((e) => coordRequestResponseLocationTypeFromJson(e.toString()))
      .toList();
}

String? parentLocationTypeNullableToJson(
    enums.ParentLocationType? parentLocationType) {
  return parentLocationType?.value;
}

String? parentLocationTypeToJson(enums.ParentLocationType parentLocationType) {
  return parentLocationType.value;
}

enums.ParentLocationType parentLocationTypeFromJson(
  Object? parentLocationType, [
  enums.ParentLocationType? defaultValue,
]) {
  return enums.ParentLocationType.values
          .firstWhereOrNull((e) => e.value == parentLocationType) ??
      defaultValue ??
      enums.ParentLocationType.swaggerGeneratedUnknown;
}

enums.ParentLocationType? parentLocationTypeNullableFromJson(
  Object? parentLocationType, [
  enums.ParentLocationType? defaultValue,
]) {
  if (parentLocationType == null) {
    return null;
  }
  return enums.ParentLocationType.values
          .firstWhereOrNull((e) => e.value == parentLocationType) ??
      defaultValue;
}

String parentLocationTypeExplodedListToJson(
    List<enums.ParentLocationType>? parentLocationType) {
  return parentLocationType?.map((e) => e.value!).join(',') ?? '';
}

List<String> parentLocationTypeListToJson(
    List<enums.ParentLocationType>? parentLocationType) {
  if (parentLocationType == null) {
    return [];
  }

  return parentLocationType.map((e) => e.value!).toList();
}

List<enums.ParentLocationType> parentLocationTypeListFromJson(
  List? parentLocationType, [
  List<enums.ParentLocationType>? defaultValue,
]) {
  if (parentLocationType == null) {
    return defaultValue ?? [];
  }

  return parentLocationType
      .map((e) => parentLocationTypeFromJson(e.toString()))
      .toList();
}

List<enums.ParentLocationType>? parentLocationTypeNullableListFromJson(
  List? parentLocationType, [
  List<enums.ParentLocationType>? defaultValue,
]) {
  if (parentLocationType == null) {
    return defaultValue;
  }

  return parentLocationType
      .map((e) => parentLocationTypeFromJson(e.toString()))
      .toList();
}

String? stopFinderAssignedStopTypeNullableToJson(
    enums.StopFinderAssignedStopType? stopFinderAssignedStopType) {
  return stopFinderAssignedStopType?.value;
}

String? stopFinderAssignedStopTypeToJson(
    enums.StopFinderAssignedStopType stopFinderAssignedStopType) {
  return stopFinderAssignedStopType.value;
}

enums.StopFinderAssignedStopType stopFinderAssignedStopTypeFromJson(
  Object? stopFinderAssignedStopType, [
  enums.StopFinderAssignedStopType? defaultValue,
]) {
  return enums.StopFinderAssignedStopType.values
          .firstWhereOrNull((e) => e.value == stopFinderAssignedStopType) ??
      defaultValue ??
      enums.StopFinderAssignedStopType.swaggerGeneratedUnknown;
}

enums.StopFinderAssignedStopType? stopFinderAssignedStopTypeNullableFromJson(
  Object? stopFinderAssignedStopType, [
  enums.StopFinderAssignedStopType? defaultValue,
]) {
  if (stopFinderAssignedStopType == null) {
    return null;
  }
  return enums.StopFinderAssignedStopType.values
          .firstWhereOrNull((e) => e.value == stopFinderAssignedStopType) ??
      defaultValue;
}

String stopFinderAssignedStopTypeExplodedListToJson(
    List<enums.StopFinderAssignedStopType>? stopFinderAssignedStopType) {
  return stopFinderAssignedStopType?.map((e) => e.value!).join(',') ?? '';
}

List<String> stopFinderAssignedStopTypeListToJson(
    List<enums.StopFinderAssignedStopType>? stopFinderAssignedStopType) {
  if (stopFinderAssignedStopType == null) {
    return [];
  }

  return stopFinderAssignedStopType.map((e) => e.value!).toList();
}

List<enums.StopFinderAssignedStopType> stopFinderAssignedStopTypeListFromJson(
  List? stopFinderAssignedStopType, [
  List<enums.StopFinderAssignedStopType>? defaultValue,
]) {
  if (stopFinderAssignedStopType == null) {
    return defaultValue ?? [];
  }

  return stopFinderAssignedStopType
      .map((e) => stopFinderAssignedStopTypeFromJson(e.toString()))
      .toList();
}

List<enums.StopFinderAssignedStopType>?
    stopFinderAssignedStopTypeNullableListFromJson(
  List? stopFinderAssignedStopType, [
  List<enums.StopFinderAssignedStopType>? defaultValue,
]) {
  if (stopFinderAssignedStopType == null) {
    return defaultValue;
  }

  return stopFinderAssignedStopType
      .map((e) => stopFinderAssignedStopTypeFromJson(e.toString()))
      .toList();
}

String? stopFinderLocationTypeNullableToJson(
    enums.StopFinderLocationType? stopFinderLocationType) {
  return stopFinderLocationType?.value;
}

String? stopFinderLocationTypeToJson(
    enums.StopFinderLocationType stopFinderLocationType) {
  return stopFinderLocationType.value;
}

enums.StopFinderLocationType stopFinderLocationTypeFromJson(
  Object? stopFinderLocationType, [
  enums.StopFinderLocationType? defaultValue,
]) {
  return enums.StopFinderLocationType.values
          .firstWhereOrNull((e) => e.value == stopFinderLocationType) ??
      defaultValue ??
      enums.StopFinderLocationType.swaggerGeneratedUnknown;
}

enums.StopFinderLocationType? stopFinderLocationTypeNullableFromJson(
  Object? stopFinderLocationType, [
  enums.StopFinderLocationType? defaultValue,
]) {
  if (stopFinderLocationType == null) {
    return null;
  }
  return enums.StopFinderLocationType.values
          .firstWhereOrNull((e) => e.value == stopFinderLocationType) ??
      defaultValue;
}

String stopFinderLocationTypeExplodedListToJson(
    List<enums.StopFinderLocationType>? stopFinderLocationType) {
  return stopFinderLocationType?.map((e) => e.value!).join(',') ?? '';
}

List<String> stopFinderLocationTypeListToJson(
    List<enums.StopFinderLocationType>? stopFinderLocationType) {
  if (stopFinderLocationType == null) {
    return [];
  }

  return stopFinderLocationType.map((e) => e.value!).toList();
}

List<enums.StopFinderLocationType> stopFinderLocationTypeListFromJson(
  List? stopFinderLocationType, [
  List<enums.StopFinderLocationType>? defaultValue,
]) {
  if (stopFinderLocationType == null) {
    return defaultValue ?? [];
  }

  return stopFinderLocationType
      .map((e) => stopFinderLocationTypeFromJson(e.toString()))
      .toList();
}

List<enums.StopFinderLocationType>? stopFinderLocationTypeNullableListFromJson(
  List? stopFinderLocationType, [
  List<enums.StopFinderLocationType>? defaultValue,
]) {
  if (stopFinderLocationType == null) {
    return defaultValue;
  }

  return stopFinderLocationType
      .map((e) => stopFinderLocationTypeFromJson(e.toString()))
      .toList();
}

int? tripRequestResponseJourneyLegInterchangeTypeNullableToJson(
    enums.TripRequestResponseJourneyLegInterchangeType?
        tripRequestResponseJourneyLegInterchangeType) {
  return tripRequestResponseJourneyLegInterchangeType?.value;
}

int? tripRequestResponseJourneyLegInterchangeTypeToJson(
    enums.TripRequestResponseJourneyLegInterchangeType
        tripRequestResponseJourneyLegInterchangeType) {
  return tripRequestResponseJourneyLegInterchangeType.value;
}

enums.TripRequestResponseJourneyLegInterchangeType
    tripRequestResponseJourneyLegInterchangeTypeFromJson(
  Object? tripRequestResponseJourneyLegInterchangeType, [
  enums.TripRequestResponseJourneyLegInterchangeType? defaultValue,
]) {
  return enums.TripRequestResponseJourneyLegInterchangeType.values
          .firstWhereOrNull(
              (e) => e.value == tripRequestResponseJourneyLegInterchangeType) ??
      defaultValue ??
      enums
          .TripRequestResponseJourneyLegInterchangeType.swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegInterchangeType?
    tripRequestResponseJourneyLegInterchangeTypeNullableFromJson(
  Object? tripRequestResponseJourneyLegInterchangeType, [
  enums.TripRequestResponseJourneyLegInterchangeType? defaultValue,
]) {
  if (tripRequestResponseJourneyLegInterchangeType == null) {
    return null;
  }
  return enums.TripRequestResponseJourneyLegInterchangeType.values
          .firstWhereOrNull(
              (e) => e.value == tripRequestResponseJourneyLegInterchangeType) ??
      defaultValue;
}

String tripRequestResponseJourneyLegInterchangeTypeExplodedListToJson(
    List<enums.TripRequestResponseJourneyLegInterchangeType>?
        tripRequestResponseJourneyLegInterchangeType) {
  return tripRequestResponseJourneyLegInterchangeType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<int> tripRequestResponseJourneyLegInterchangeTypeListToJson(
    List<enums.TripRequestResponseJourneyLegInterchangeType>?
        tripRequestResponseJourneyLegInterchangeType) {
  if (tripRequestResponseJourneyLegInterchangeType == null) {
    return [];
  }

  return tripRequestResponseJourneyLegInterchangeType
      .map((e) => e.value!)
      .toList();
}

List<enums.TripRequestResponseJourneyLegInterchangeType>
    tripRequestResponseJourneyLegInterchangeTypeListFromJson(
  List? tripRequestResponseJourneyLegInterchangeType, [
  List<enums.TripRequestResponseJourneyLegInterchangeType>? defaultValue,
]) {
  if (tripRequestResponseJourneyLegInterchangeType == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegInterchangeType
      .map((e) =>
          tripRequestResponseJourneyLegInterchangeTypeFromJson(e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegInterchangeType>?
    tripRequestResponseJourneyLegInterchangeTypeNullableListFromJson(
  List? tripRequestResponseJourneyLegInterchangeType, [
  List<enums.TripRequestResponseJourneyLegInterchangeType>? defaultValue,
]) {
  if (tripRequestResponseJourneyLegInterchangeType == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegInterchangeType
      .map((e) =>
          tripRequestResponseJourneyLegInterchangeTypeFromJson(e.toString()))
      .toList();
}

String? tripRequestResponseJourneyLegPathDescriptionManoeuvreNullableToJson(
    enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre?
        tripRequestResponseJourneyLegPathDescriptionManoeuvre) {
  return tripRequestResponseJourneyLegPathDescriptionManoeuvre?.value;
}

String? tripRequestResponseJourneyLegPathDescriptionManoeuvreToJson(
    enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre
        tripRequestResponseJourneyLegPathDescriptionManoeuvre) {
  return tripRequestResponseJourneyLegPathDescriptionManoeuvre.value;
}

enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre
    tripRequestResponseJourneyLegPathDescriptionManoeuvreFromJson(
  Object? tripRequestResponseJourneyLegPathDescriptionManoeuvre, [
  enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre? defaultValue,
]) {
  return enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegPathDescriptionManoeuvre) ??
      defaultValue ??
      enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre
          .swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre?
    tripRequestResponseJourneyLegPathDescriptionManoeuvreNullableFromJson(
  Object? tripRequestResponseJourneyLegPathDescriptionManoeuvre, [
  enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre? defaultValue,
]) {
  if (tripRequestResponseJourneyLegPathDescriptionManoeuvre == null) {
    return null;
  }
  return enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegPathDescriptionManoeuvre) ??
      defaultValue;
}

String tripRequestResponseJourneyLegPathDescriptionManoeuvreExplodedListToJson(
    List<enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre>?
        tripRequestResponseJourneyLegPathDescriptionManoeuvre) {
  return tripRequestResponseJourneyLegPathDescriptionManoeuvre
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> tripRequestResponseJourneyLegPathDescriptionManoeuvreListToJson(
    List<enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre>?
        tripRequestResponseJourneyLegPathDescriptionManoeuvre) {
  if (tripRequestResponseJourneyLegPathDescriptionManoeuvre == null) {
    return [];
  }

  return tripRequestResponseJourneyLegPathDescriptionManoeuvre
      .map((e) => e.value!)
      .toList();
}

List<enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre>
    tripRequestResponseJourneyLegPathDescriptionManoeuvreListFromJson(
  List? tripRequestResponseJourneyLegPathDescriptionManoeuvre, [
  List<enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegPathDescriptionManoeuvre == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegPathDescriptionManoeuvre
      .map((e) => tripRequestResponseJourneyLegPathDescriptionManoeuvreFromJson(
          e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre>?
    tripRequestResponseJourneyLegPathDescriptionManoeuvreNullableListFromJson(
  List? tripRequestResponseJourneyLegPathDescriptionManoeuvre, [
  List<enums.TripRequestResponseJourneyLegPathDescriptionManoeuvre>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegPathDescriptionManoeuvre == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegPathDescriptionManoeuvre
      .map((e) => tripRequestResponseJourneyLegPathDescriptionManoeuvreFromJson(
          e.toString()))
      .toList();
}

String? tripRequestResponseJourneyLegPathDescriptionTurnDirectionNullableToJson(
    enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection?
        tripRequestResponseJourneyLegPathDescriptionTurnDirection) {
  return tripRequestResponseJourneyLegPathDescriptionTurnDirection?.value;
}

String? tripRequestResponseJourneyLegPathDescriptionTurnDirectionToJson(
    enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection
        tripRequestResponseJourneyLegPathDescriptionTurnDirection) {
  return tripRequestResponseJourneyLegPathDescriptionTurnDirection.value;
}

enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection
    tripRequestResponseJourneyLegPathDescriptionTurnDirectionFromJson(
  Object? tripRequestResponseJourneyLegPathDescriptionTurnDirection, [
  enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection? defaultValue,
]) {
  return enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegPathDescriptionTurnDirection) ??
      defaultValue ??
      enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection
          .swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection?
    tripRequestResponseJourneyLegPathDescriptionTurnDirectionNullableFromJson(
  Object? tripRequestResponseJourneyLegPathDescriptionTurnDirection, [
  enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection? defaultValue,
]) {
  if (tripRequestResponseJourneyLegPathDescriptionTurnDirection == null) {
    return null;
  }
  return enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegPathDescriptionTurnDirection) ??
      defaultValue;
}

String
    tripRequestResponseJourneyLegPathDescriptionTurnDirectionExplodedListToJson(
        List<enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection>?
            tripRequestResponseJourneyLegPathDescriptionTurnDirection) {
  return tripRequestResponseJourneyLegPathDescriptionTurnDirection
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
    tripRequestResponseJourneyLegPathDescriptionTurnDirectionListToJson(
        List<enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection>?
            tripRequestResponseJourneyLegPathDescriptionTurnDirection) {
  if (tripRequestResponseJourneyLegPathDescriptionTurnDirection == null) {
    return [];
  }

  return tripRequestResponseJourneyLegPathDescriptionTurnDirection
      .map((e) => e.value!)
      .toList();
}

List<enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection>
    tripRequestResponseJourneyLegPathDescriptionTurnDirectionListFromJson(
  List? tripRequestResponseJourneyLegPathDescriptionTurnDirection, [
  List<enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegPathDescriptionTurnDirection == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegPathDescriptionTurnDirection
      .map((e) =>
          tripRequestResponseJourneyLegPathDescriptionTurnDirectionFromJson(
              e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection>?
    tripRequestResponseJourneyLegPathDescriptionTurnDirectionNullableListFromJson(
  List? tripRequestResponseJourneyLegPathDescriptionTurnDirection, [
  List<enums.TripRequestResponseJourneyLegPathDescriptionTurnDirection>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegPathDescriptionTurnDirection == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegPathDescriptionTurnDirection
      .map((e) =>
          tripRequestResponseJourneyLegPathDescriptionTurnDirectionFromJson(
              e.toString()))
      .toList();
}

String?
    tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessNullableToJson(
        enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess?
            tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess) {
  return tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess?.value;
}

String? tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessToJson(
    enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess
        tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess) {
  return tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess.value;
}

enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess
    tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessFromJson(
  Object? tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess, [
  enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess?
      defaultValue,
]) {
  return enums
          .TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess) ??
      defaultValue ??
      enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess
          .swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess?
    tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessNullableFromJson(
  Object? tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess, [
  enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess == null) {
    return null;
  }
  return enums
          .TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess) ??
      defaultValue;
}

String
    tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessExplodedListToJson(
        List<
                enums
                .TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess>?
            tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess) {
  return tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
    tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessListToJson(
        List<
                enums
                .TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess>?
            tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess) {
  if (tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess == null) {
    return [];
  }

  return tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess
      .map((e) => e.value!)
      .toList();
}

List<enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess>
    tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessListFromJson(
  List? tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess, [
  List<enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess
      .map((e) =>
          tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessFromJson(
              e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess>?
    tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessNullableListFromJson(
  List? tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess, [
  List<enums.TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegStop$PropertiesWheelchairAccess
      .map((e) =>
          tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessFromJson(
              e.toString()))
      .toList();
}

String? tripRequestResponseJourneyLegStopTypeNullableToJson(
    enums.TripRequestResponseJourneyLegStopType?
        tripRequestResponseJourneyLegStopType) {
  return tripRequestResponseJourneyLegStopType?.value;
}

String? tripRequestResponseJourneyLegStopTypeToJson(
    enums.TripRequestResponseJourneyLegStopType
        tripRequestResponseJourneyLegStopType) {
  return tripRequestResponseJourneyLegStopType.value;
}

enums.TripRequestResponseJourneyLegStopType
    tripRequestResponseJourneyLegStopTypeFromJson(
  Object? tripRequestResponseJourneyLegStopType, [
  enums.TripRequestResponseJourneyLegStopType? defaultValue,
]) {
  return enums.TripRequestResponseJourneyLegStopType.values.firstWhereOrNull(
          (e) => e.value == tripRequestResponseJourneyLegStopType) ??
      defaultValue ??
      enums.TripRequestResponseJourneyLegStopType.swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegStopType?
    tripRequestResponseJourneyLegStopTypeNullableFromJson(
  Object? tripRequestResponseJourneyLegStopType, [
  enums.TripRequestResponseJourneyLegStopType? defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopType == null) {
    return null;
  }
  return enums.TripRequestResponseJourneyLegStopType.values.firstWhereOrNull(
          (e) => e.value == tripRequestResponseJourneyLegStopType) ??
      defaultValue;
}

String tripRequestResponseJourneyLegStopTypeExplodedListToJson(
    List<enums.TripRequestResponseJourneyLegStopType>?
        tripRequestResponseJourneyLegStopType) {
  return tripRequestResponseJourneyLegStopType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> tripRequestResponseJourneyLegStopTypeListToJson(
    List<enums.TripRequestResponseJourneyLegStopType>?
        tripRequestResponseJourneyLegStopType) {
  if (tripRequestResponseJourneyLegStopType == null) {
    return [];
  }

  return tripRequestResponseJourneyLegStopType.map((e) => e.value!).toList();
}

List<enums.TripRequestResponseJourneyLegStopType>
    tripRequestResponseJourneyLegStopTypeListFromJson(
  List? tripRequestResponseJourneyLegStopType, [
  List<enums.TripRequestResponseJourneyLegStopType>? defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopType == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegStopType
      .map((e) => tripRequestResponseJourneyLegStopTypeFromJson(e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopType>?
    tripRequestResponseJourneyLegStopTypeNullableListFromJson(
  List? tripRequestResponseJourneyLegStopType, [
  List<enums.TripRequestResponseJourneyLegStopType>? defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopType == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegStopType
      .map((e) => tripRequestResponseJourneyLegStopTypeFromJson(e.toString()))
      .toList();
}

String? tripRequestResponseJourneyLegStopFootpathInfoPositionNullableToJson(
    enums.TripRequestResponseJourneyLegStopFootpathInfoPosition?
        tripRequestResponseJourneyLegStopFootpathInfoPosition) {
  return tripRequestResponseJourneyLegStopFootpathInfoPosition?.value;
}

String? tripRequestResponseJourneyLegStopFootpathInfoPositionToJson(
    enums.TripRequestResponseJourneyLegStopFootpathInfoPosition
        tripRequestResponseJourneyLegStopFootpathInfoPosition) {
  return tripRequestResponseJourneyLegStopFootpathInfoPosition.value;
}

enums.TripRequestResponseJourneyLegStopFootpathInfoPosition
    tripRequestResponseJourneyLegStopFootpathInfoPositionFromJson(
  Object? tripRequestResponseJourneyLegStopFootpathInfoPosition, [
  enums.TripRequestResponseJourneyLegStopFootpathInfoPosition? defaultValue,
]) {
  return enums.TripRequestResponseJourneyLegStopFootpathInfoPosition.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStopFootpathInfoPosition) ??
      defaultValue ??
      enums.TripRequestResponseJourneyLegStopFootpathInfoPosition
          .swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegStopFootpathInfoPosition?
    tripRequestResponseJourneyLegStopFootpathInfoPositionNullableFromJson(
  Object? tripRequestResponseJourneyLegStopFootpathInfoPosition, [
  enums.TripRequestResponseJourneyLegStopFootpathInfoPosition? defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoPosition == null) {
    return null;
  }
  return enums.TripRequestResponseJourneyLegStopFootpathInfoPosition.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStopFootpathInfoPosition) ??
      defaultValue;
}

String tripRequestResponseJourneyLegStopFootpathInfoPositionExplodedListToJson(
    List<enums.TripRequestResponseJourneyLegStopFootpathInfoPosition>?
        tripRequestResponseJourneyLegStopFootpathInfoPosition) {
  return tripRequestResponseJourneyLegStopFootpathInfoPosition
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> tripRequestResponseJourneyLegStopFootpathInfoPositionListToJson(
    List<enums.TripRequestResponseJourneyLegStopFootpathInfoPosition>?
        tripRequestResponseJourneyLegStopFootpathInfoPosition) {
  if (tripRequestResponseJourneyLegStopFootpathInfoPosition == null) {
    return [];
  }

  return tripRequestResponseJourneyLegStopFootpathInfoPosition
      .map((e) => e.value!)
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopFootpathInfoPosition>
    tripRequestResponseJourneyLegStopFootpathInfoPositionListFromJson(
  List? tripRequestResponseJourneyLegStopFootpathInfoPosition, [
  List<enums.TripRequestResponseJourneyLegStopFootpathInfoPosition>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoPosition == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegStopFootpathInfoPosition
      .map((e) => tripRequestResponseJourneyLegStopFootpathInfoPositionFromJson(
          e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopFootpathInfoPosition>?
    tripRequestResponseJourneyLegStopFootpathInfoPositionNullableListFromJson(
  List? tripRequestResponseJourneyLegStopFootpathInfoPosition, [
  List<enums.TripRequestResponseJourneyLegStopFootpathInfoPosition>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoPosition == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegStopFootpathInfoPosition
      .map((e) => tripRequestResponseJourneyLegStopFootpathInfoPositionFromJson(
          e.toString()))
      .toList();
}

String?
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelNullableToJson(
        enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel?
            tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel?.value;
}

String? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelToJson(
    enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel.value;
}

enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelFromJson(
  Object? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel, [
  enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel?
      defaultValue,
]) {
  return enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel) ??
      defaultValue ??
      enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel
          .swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel?
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelNullableFromJson(
  Object? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel, [
  enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel == null) {
    return null;
  }
  return enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel) ??
      defaultValue;
}

String
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelExplodedListToJson(
        List<
                enums
                .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel>?
            tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelListToJson(
        List<
                enums
                .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel>?
            tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel == null) {
    return [];
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel
      .map((e) => e.value!)
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel>
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelListFromJson(
  List? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel, [
  List<enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel
      .map((e) =>
          tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelFromJson(
              e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel>?
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelNullableListFromJson(
  List? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel, [
  List<enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel
      .map((e) =>
          tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelFromJson(
              e.toString()))
      .toList();
}

String?
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeNullableToJson(
        enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType?
            tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType?.value;
}

String? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeToJson(
    enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType.value;
}

enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeFromJson(
  Object? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType, [
  enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType?
      defaultValue,
]) {
  return enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType) ??
      defaultValue ??
      enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType
          .swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType?
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeNullableFromJson(
  Object? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType, [
  enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType == null) {
    return null;
  }
  return enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType.values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType) ??
      defaultValue;
}

String
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeExplodedListToJson(
        List<
                enums
                .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType>?
            tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeListToJson(
        List<
                enums
                .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType>?
            tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType == null) {
    return [];
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType
      .map((e) => e.value!)
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType>
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeListFromJson(
  List? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType, [
  List<enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType
      .map((e) =>
          tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeFromJson(
              e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType>?
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeNullableListFromJson(
  List? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType, [
  List<enums.TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemType
      .map((e) =>
          tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeFromJson(
              e.toString()))
      .toList();
}

String? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeNullableToJson(
    enums
        .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType?
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
      ?.value;
}

String? tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeToJson(
    enums
        .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
      .value;
}

enums
    .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeFromJson(
  Object?
      tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType, [
  enums
      .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType?
      defaultValue,
]) {
  return enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
          .values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType) ??
      defaultValue ??
      enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
          .swaggerGeneratedUnknown;
}

enums
    .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType?
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeNullableFromJson(
  Object?
      tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType, [
  enums
      .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType ==
      null) {
    return null;
  }
  return enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
          .values
          .firstWhereOrNull((e) =>
              e.value ==
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType) ??
      defaultValue;
}

String tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeExplodedListToJson(
    List<
            enums
            .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType>?
        tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType) {
  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeListToJson(
        List<
                enums
                .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType>?
            tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType ==
      null) {
    return [];
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
      .map((e) => e.value!)
      .toList();
}

List<
        enums
        .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType>
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeListFromJson(
  List?
      tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType, [
  List<
          enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType ==
      null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
      .map((e) =>
          tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeFromJson(
              e.toString()))
      .toList();
}

List<
        enums
        .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType>?
    tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeNullableListFromJson(
  List?
      tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType, [
  List<
          enums
          .TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType>?
      defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType ==
      null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType
      .map((e) =>
          tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeFromJson(
              e.toString()))
      .toList();
}

String? tripRequestResponseJourneyLegStopInfoPriorityNullableToJson(
    enums.TripRequestResponseJourneyLegStopInfoPriority?
        tripRequestResponseJourneyLegStopInfoPriority) {
  return tripRequestResponseJourneyLegStopInfoPriority?.value;
}

String? tripRequestResponseJourneyLegStopInfoPriorityToJson(
    enums.TripRequestResponseJourneyLegStopInfoPriority
        tripRequestResponseJourneyLegStopInfoPriority) {
  return tripRequestResponseJourneyLegStopInfoPriority.value;
}

enums.TripRequestResponseJourneyLegStopInfoPriority
    tripRequestResponseJourneyLegStopInfoPriorityFromJson(
  Object? tripRequestResponseJourneyLegStopInfoPriority, [
  enums.TripRequestResponseJourneyLegStopInfoPriority? defaultValue,
]) {
  return enums.TripRequestResponseJourneyLegStopInfoPriority.values
          .firstWhereOrNull((e) =>
              e.value == tripRequestResponseJourneyLegStopInfoPriority) ??
      defaultValue ??
      enums.TripRequestResponseJourneyLegStopInfoPriority
          .swaggerGeneratedUnknown;
}

enums.TripRequestResponseJourneyLegStopInfoPriority?
    tripRequestResponseJourneyLegStopInfoPriorityNullableFromJson(
  Object? tripRequestResponseJourneyLegStopInfoPriority, [
  enums.TripRequestResponseJourneyLegStopInfoPriority? defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopInfoPriority == null) {
    return null;
  }
  return enums.TripRequestResponseJourneyLegStopInfoPriority.values
          .firstWhereOrNull((e) =>
              e.value == tripRequestResponseJourneyLegStopInfoPriority) ??
      defaultValue;
}

String tripRequestResponseJourneyLegStopInfoPriorityExplodedListToJson(
    List<enums.TripRequestResponseJourneyLegStopInfoPriority>?
        tripRequestResponseJourneyLegStopInfoPriority) {
  return tripRequestResponseJourneyLegStopInfoPriority
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> tripRequestResponseJourneyLegStopInfoPriorityListToJson(
    List<enums.TripRequestResponseJourneyLegStopInfoPriority>?
        tripRequestResponseJourneyLegStopInfoPriority) {
  if (tripRequestResponseJourneyLegStopInfoPriority == null) {
    return [];
  }

  return tripRequestResponseJourneyLegStopInfoPriority
      .map((e) => e.value!)
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopInfoPriority>
    tripRequestResponseJourneyLegStopInfoPriorityListFromJson(
  List? tripRequestResponseJourneyLegStopInfoPriority, [
  List<enums.TripRequestResponseJourneyLegStopInfoPriority>? defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopInfoPriority == null) {
    return defaultValue ?? [];
  }

  return tripRequestResponseJourneyLegStopInfoPriority
      .map((e) =>
          tripRequestResponseJourneyLegStopInfoPriorityFromJson(e.toString()))
      .toList();
}

List<enums.TripRequestResponseJourneyLegStopInfoPriority>?
    tripRequestResponseJourneyLegStopInfoPriorityNullableListFromJson(
  List? tripRequestResponseJourneyLegStopInfoPriority, [
  List<enums.TripRequestResponseJourneyLegStopInfoPriority>? defaultValue,
]) {
  if (tripRequestResponseJourneyLegStopInfoPriority == null) {
    return defaultValue;
  }

  return tripRequestResponseJourneyLegStopInfoPriority
      .map((e) =>
          tripRequestResponseJourneyLegStopInfoPriorityFromJson(e.toString()))
      .toList();
}

String? addInfoGetOutputFormatNullableToJson(
    enums.AddInfoGetOutputFormat? addInfoGetOutputFormat) {
  return addInfoGetOutputFormat?.value;
}

String? addInfoGetOutputFormatToJson(
    enums.AddInfoGetOutputFormat addInfoGetOutputFormat) {
  return addInfoGetOutputFormat.value;
}

enums.AddInfoGetOutputFormat addInfoGetOutputFormatFromJson(
  Object? addInfoGetOutputFormat, [
  enums.AddInfoGetOutputFormat? defaultValue,
]) {
  return enums.AddInfoGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == addInfoGetOutputFormat) ??
      defaultValue ??
      enums.AddInfoGetOutputFormat.swaggerGeneratedUnknown;
}

enums.AddInfoGetOutputFormat? addInfoGetOutputFormatNullableFromJson(
  Object? addInfoGetOutputFormat, [
  enums.AddInfoGetOutputFormat? defaultValue,
]) {
  if (addInfoGetOutputFormat == null) {
    return null;
  }
  return enums.AddInfoGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == addInfoGetOutputFormat) ??
      defaultValue;
}

String addInfoGetOutputFormatExplodedListToJson(
    List<enums.AddInfoGetOutputFormat>? addInfoGetOutputFormat) {
  return addInfoGetOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> addInfoGetOutputFormatListToJson(
    List<enums.AddInfoGetOutputFormat>? addInfoGetOutputFormat) {
  if (addInfoGetOutputFormat == null) {
    return [];
  }

  return addInfoGetOutputFormat.map((e) => e.value!).toList();
}

List<enums.AddInfoGetOutputFormat> addInfoGetOutputFormatListFromJson(
  List? addInfoGetOutputFormat, [
  List<enums.AddInfoGetOutputFormat>? defaultValue,
]) {
  if (addInfoGetOutputFormat == null) {
    return defaultValue ?? [];
  }

  return addInfoGetOutputFormat
      .map((e) => addInfoGetOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.AddInfoGetOutputFormat>? addInfoGetOutputFormatNullableListFromJson(
  List? addInfoGetOutputFormat, [
  List<enums.AddInfoGetOutputFormat>? defaultValue,
]) {
  if (addInfoGetOutputFormat == null) {
    return defaultValue;
  }

  return addInfoGetOutputFormat
      .map((e) => addInfoGetOutputFormatFromJson(e.toString()))
      .toList();
}

String? addInfoGetFilterMOTTypeNullableToJson(
    enums.AddInfoGetFilterMOTType? addInfoGetFilterMOTType) {
  return addInfoGetFilterMOTType?.value;
}

String? addInfoGetFilterMOTTypeToJson(
    enums.AddInfoGetFilterMOTType addInfoGetFilterMOTType) {
  return addInfoGetFilterMOTType.value;
}

enums.AddInfoGetFilterMOTType addInfoGetFilterMOTTypeFromJson(
  Object? addInfoGetFilterMOTType, [
  enums.AddInfoGetFilterMOTType? defaultValue,
]) {
  return enums.AddInfoGetFilterMOTType.values
          .firstWhereOrNull((e) => e.value == addInfoGetFilterMOTType) ??
      defaultValue ??
      enums.AddInfoGetFilterMOTType.swaggerGeneratedUnknown;
}

enums.AddInfoGetFilterMOTType? addInfoGetFilterMOTTypeNullableFromJson(
  Object? addInfoGetFilterMOTType, [
  enums.AddInfoGetFilterMOTType? defaultValue,
]) {
  if (addInfoGetFilterMOTType == null) {
    return null;
  }
  return enums.AddInfoGetFilterMOTType.values
          .firstWhereOrNull((e) => e.value == addInfoGetFilterMOTType) ??
      defaultValue;
}

String addInfoGetFilterMOTTypeExplodedListToJson(
    List<enums.AddInfoGetFilterMOTType>? addInfoGetFilterMOTType) {
  return addInfoGetFilterMOTType?.map((e) => e.value!).join(',') ?? '';
}

List<String> addInfoGetFilterMOTTypeListToJson(
    List<enums.AddInfoGetFilterMOTType>? addInfoGetFilterMOTType) {
  if (addInfoGetFilterMOTType == null) {
    return [];
  }

  return addInfoGetFilterMOTType.map((e) => e.value!).toList();
}

List<enums.AddInfoGetFilterMOTType> addInfoGetFilterMOTTypeListFromJson(
  List? addInfoGetFilterMOTType, [
  List<enums.AddInfoGetFilterMOTType>? defaultValue,
]) {
  if (addInfoGetFilterMOTType == null) {
    return defaultValue ?? [];
  }

  return addInfoGetFilterMOTType
      .map((e) => addInfoGetFilterMOTTypeFromJson(e.toString()))
      .toList();
}

List<enums.AddInfoGetFilterMOTType>?
    addInfoGetFilterMOTTypeNullableListFromJson(
  List? addInfoGetFilterMOTType, [
  List<enums.AddInfoGetFilterMOTType>? defaultValue,
]) {
  if (addInfoGetFilterMOTType == null) {
    return defaultValue;
  }

  return addInfoGetFilterMOTType
      .map((e) => addInfoGetFilterMOTTypeFromJson(e.toString()))
      .toList();
}

String? addInfoGetFilterPublicationStatusNullableToJson(
    enums.AddInfoGetFilterPublicationStatus?
        addInfoGetFilterPublicationStatus) {
  return addInfoGetFilterPublicationStatus?.value;
}

String? addInfoGetFilterPublicationStatusToJson(
    enums.AddInfoGetFilterPublicationStatus addInfoGetFilterPublicationStatus) {
  return addInfoGetFilterPublicationStatus.value;
}

enums.AddInfoGetFilterPublicationStatus
    addInfoGetFilterPublicationStatusFromJson(
  Object? addInfoGetFilterPublicationStatus, [
  enums.AddInfoGetFilterPublicationStatus? defaultValue,
]) {
  return enums.AddInfoGetFilterPublicationStatus.values.firstWhereOrNull(
          (e) => e.value == addInfoGetFilterPublicationStatus) ??
      defaultValue ??
      enums.AddInfoGetFilterPublicationStatus.swaggerGeneratedUnknown;
}

enums.AddInfoGetFilterPublicationStatus?
    addInfoGetFilterPublicationStatusNullableFromJson(
  Object? addInfoGetFilterPublicationStatus, [
  enums.AddInfoGetFilterPublicationStatus? defaultValue,
]) {
  if (addInfoGetFilterPublicationStatus == null) {
    return null;
  }
  return enums.AddInfoGetFilterPublicationStatus.values.firstWhereOrNull(
          (e) => e.value == addInfoGetFilterPublicationStatus) ??
      defaultValue;
}

String addInfoGetFilterPublicationStatusExplodedListToJson(
    List<enums.AddInfoGetFilterPublicationStatus>?
        addInfoGetFilterPublicationStatus) {
  return addInfoGetFilterPublicationStatus?.map((e) => e.value!).join(',') ??
      '';
}

List<String> addInfoGetFilterPublicationStatusListToJson(
    List<enums.AddInfoGetFilterPublicationStatus>?
        addInfoGetFilterPublicationStatus) {
  if (addInfoGetFilterPublicationStatus == null) {
    return [];
  }

  return addInfoGetFilterPublicationStatus.map((e) => e.value!).toList();
}

List<enums.AddInfoGetFilterPublicationStatus>
    addInfoGetFilterPublicationStatusListFromJson(
  List? addInfoGetFilterPublicationStatus, [
  List<enums.AddInfoGetFilterPublicationStatus>? defaultValue,
]) {
  if (addInfoGetFilterPublicationStatus == null) {
    return defaultValue ?? [];
  }

  return addInfoGetFilterPublicationStatus
      .map((e) => addInfoGetFilterPublicationStatusFromJson(e.toString()))
      .toList();
}

List<enums.AddInfoGetFilterPublicationStatus>?
    addInfoGetFilterPublicationStatusNullableListFromJson(
  List? addInfoGetFilterPublicationStatus, [
  List<enums.AddInfoGetFilterPublicationStatus>? defaultValue,
]) {
  if (addInfoGetFilterPublicationStatus == null) {
    return defaultValue;
  }

  return addInfoGetFilterPublicationStatus
      .map((e) => addInfoGetFilterPublicationStatusFromJson(e.toString()))
      .toList();
}

String? coordGetOutputFormatNullableToJson(
    enums.CoordGetOutputFormat? coordGetOutputFormat) {
  return coordGetOutputFormat?.value;
}

String? coordGetOutputFormatToJson(
    enums.CoordGetOutputFormat coordGetOutputFormat) {
  return coordGetOutputFormat.value;
}

enums.CoordGetOutputFormat coordGetOutputFormatFromJson(
  Object? coordGetOutputFormat, [
  enums.CoordGetOutputFormat? defaultValue,
]) {
  return enums.CoordGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == coordGetOutputFormat) ??
      defaultValue ??
      enums.CoordGetOutputFormat.swaggerGeneratedUnknown;
}

enums.CoordGetOutputFormat? coordGetOutputFormatNullableFromJson(
  Object? coordGetOutputFormat, [
  enums.CoordGetOutputFormat? defaultValue,
]) {
  if (coordGetOutputFormat == null) {
    return null;
  }
  return enums.CoordGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == coordGetOutputFormat) ??
      defaultValue;
}

String coordGetOutputFormatExplodedListToJson(
    List<enums.CoordGetOutputFormat>? coordGetOutputFormat) {
  return coordGetOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> coordGetOutputFormatListToJson(
    List<enums.CoordGetOutputFormat>? coordGetOutputFormat) {
  if (coordGetOutputFormat == null) {
    return [];
  }

  return coordGetOutputFormat.map((e) => e.value!).toList();
}

List<enums.CoordGetOutputFormat> coordGetOutputFormatListFromJson(
  List? coordGetOutputFormat, [
  List<enums.CoordGetOutputFormat>? defaultValue,
]) {
  if (coordGetOutputFormat == null) {
    return defaultValue ?? [];
  }

  return coordGetOutputFormat
      .map((e) => coordGetOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.CoordGetOutputFormat>? coordGetOutputFormatNullableListFromJson(
  List? coordGetOutputFormat, [
  List<enums.CoordGetOutputFormat>? defaultValue,
]) {
  if (coordGetOutputFormat == null) {
    return defaultValue;
  }

  return coordGetOutputFormat
      .map((e) => coordGetOutputFormatFromJson(e.toString()))
      .toList();
}

String? coordGetCoordOutputFormatNullableToJson(
    enums.CoordGetCoordOutputFormat? coordGetCoordOutputFormat) {
  return coordGetCoordOutputFormat?.value;
}

String? coordGetCoordOutputFormatToJson(
    enums.CoordGetCoordOutputFormat coordGetCoordOutputFormat) {
  return coordGetCoordOutputFormat.value;
}

enums.CoordGetCoordOutputFormat coordGetCoordOutputFormatFromJson(
  Object? coordGetCoordOutputFormat, [
  enums.CoordGetCoordOutputFormat? defaultValue,
]) {
  return enums.CoordGetCoordOutputFormat.values
          .firstWhereOrNull((e) => e.value == coordGetCoordOutputFormat) ??
      defaultValue ??
      enums.CoordGetCoordOutputFormat.swaggerGeneratedUnknown;
}

enums.CoordGetCoordOutputFormat? coordGetCoordOutputFormatNullableFromJson(
  Object? coordGetCoordOutputFormat, [
  enums.CoordGetCoordOutputFormat? defaultValue,
]) {
  if (coordGetCoordOutputFormat == null) {
    return null;
  }
  return enums.CoordGetCoordOutputFormat.values
          .firstWhereOrNull((e) => e.value == coordGetCoordOutputFormat) ??
      defaultValue;
}

String coordGetCoordOutputFormatExplodedListToJson(
    List<enums.CoordGetCoordOutputFormat>? coordGetCoordOutputFormat) {
  return coordGetCoordOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> coordGetCoordOutputFormatListToJson(
    List<enums.CoordGetCoordOutputFormat>? coordGetCoordOutputFormat) {
  if (coordGetCoordOutputFormat == null) {
    return [];
  }

  return coordGetCoordOutputFormat.map((e) => e.value!).toList();
}

List<enums.CoordGetCoordOutputFormat> coordGetCoordOutputFormatListFromJson(
  List? coordGetCoordOutputFormat, [
  List<enums.CoordGetCoordOutputFormat>? defaultValue,
]) {
  if (coordGetCoordOutputFormat == null) {
    return defaultValue ?? [];
  }

  return coordGetCoordOutputFormat
      .map((e) => coordGetCoordOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.CoordGetCoordOutputFormat>?
    coordGetCoordOutputFormatNullableListFromJson(
  List? coordGetCoordOutputFormat, [
  List<enums.CoordGetCoordOutputFormat>? defaultValue,
]) {
  if (coordGetCoordOutputFormat == null) {
    return defaultValue;
  }

  return coordGetCoordOutputFormat
      .map((e) => coordGetCoordOutputFormatFromJson(e.toString()))
      .toList();
}

String? coordGetInclFilterNullableToJson(
    enums.CoordGetInclFilter? coordGetInclFilter) {
  return coordGetInclFilter?.value;
}

String? coordGetInclFilterToJson(enums.CoordGetInclFilter coordGetInclFilter) {
  return coordGetInclFilter.value;
}

enums.CoordGetInclFilter coordGetInclFilterFromJson(
  Object? coordGetInclFilter, [
  enums.CoordGetInclFilter? defaultValue,
]) {
  return enums.CoordGetInclFilter.values
          .firstWhereOrNull((e) => e.value == coordGetInclFilter) ??
      defaultValue ??
      enums.CoordGetInclFilter.swaggerGeneratedUnknown;
}

enums.CoordGetInclFilter? coordGetInclFilterNullableFromJson(
  Object? coordGetInclFilter, [
  enums.CoordGetInclFilter? defaultValue,
]) {
  if (coordGetInclFilter == null) {
    return null;
  }
  return enums.CoordGetInclFilter.values
          .firstWhereOrNull((e) => e.value == coordGetInclFilter) ??
      defaultValue;
}

String coordGetInclFilterExplodedListToJson(
    List<enums.CoordGetInclFilter>? coordGetInclFilter) {
  return coordGetInclFilter?.map((e) => e.value!).join(',') ?? '';
}

List<String> coordGetInclFilterListToJson(
    List<enums.CoordGetInclFilter>? coordGetInclFilter) {
  if (coordGetInclFilter == null) {
    return [];
  }

  return coordGetInclFilter.map((e) => e.value!).toList();
}

List<enums.CoordGetInclFilter> coordGetInclFilterListFromJson(
  List? coordGetInclFilter, [
  List<enums.CoordGetInclFilter>? defaultValue,
]) {
  if (coordGetInclFilter == null) {
    return defaultValue ?? [];
  }

  return coordGetInclFilter
      .map((e) => coordGetInclFilterFromJson(e.toString()))
      .toList();
}

List<enums.CoordGetInclFilter>? coordGetInclFilterNullableListFromJson(
  List? coordGetInclFilter, [
  List<enums.CoordGetInclFilter>? defaultValue,
]) {
  if (coordGetInclFilter == null) {
    return defaultValue;
  }

  return coordGetInclFilter
      .map((e) => coordGetInclFilterFromJson(e.toString()))
      .toList();
}

String? coordGetType1NullableToJson(enums.CoordGetType1? coordGetType1) {
  return coordGetType1?.value;
}

String? coordGetType1ToJson(enums.CoordGetType1 coordGetType1) {
  return coordGetType1.value;
}

enums.CoordGetType1 coordGetType1FromJson(
  Object? coordGetType1, [
  enums.CoordGetType1? defaultValue,
]) {
  return enums.CoordGetType1.values
          .firstWhereOrNull((e) => e.value == coordGetType1) ??
      defaultValue ??
      enums.CoordGetType1.swaggerGeneratedUnknown;
}

enums.CoordGetType1? coordGetType1NullableFromJson(
  Object? coordGetType1, [
  enums.CoordGetType1? defaultValue,
]) {
  if (coordGetType1 == null) {
    return null;
  }
  return enums.CoordGetType1.values
          .firstWhereOrNull((e) => e.value == coordGetType1) ??
      defaultValue;
}

String coordGetType1ExplodedListToJson(
    List<enums.CoordGetType1>? coordGetType1) {
  return coordGetType1?.map((e) => e.value!).join(',') ?? '';
}

List<String> coordGetType1ListToJson(List<enums.CoordGetType1>? coordGetType1) {
  if (coordGetType1 == null) {
    return [];
  }

  return coordGetType1.map((e) => e.value!).toList();
}

List<enums.CoordGetType1> coordGetType1ListFromJson(
  List? coordGetType1, [
  List<enums.CoordGetType1>? defaultValue,
]) {
  if (coordGetType1 == null) {
    return defaultValue ?? [];
  }

  return coordGetType1.map((e) => coordGetType1FromJson(e.toString())).toList();
}

List<enums.CoordGetType1>? coordGetType1NullableListFromJson(
  List? coordGetType1, [
  List<enums.CoordGetType1>? defaultValue,
]) {
  if (coordGetType1 == null) {
    return defaultValue;
  }

  return coordGetType1.map((e) => coordGetType1FromJson(e.toString())).toList();
}

String? coordGetInclDrawClasses1NullableToJson(
    enums.CoordGetInclDrawClasses1? coordGetInclDrawClasses1) {
  return coordGetInclDrawClasses1?.value;
}

String? coordGetInclDrawClasses1ToJson(
    enums.CoordGetInclDrawClasses1 coordGetInclDrawClasses1) {
  return coordGetInclDrawClasses1.value;
}

enums.CoordGetInclDrawClasses1 coordGetInclDrawClasses1FromJson(
  Object? coordGetInclDrawClasses1, [
  enums.CoordGetInclDrawClasses1? defaultValue,
]) {
  return enums.CoordGetInclDrawClasses1.values
          .firstWhereOrNull((e) => e.value == coordGetInclDrawClasses1) ??
      defaultValue ??
      enums.CoordGetInclDrawClasses1.swaggerGeneratedUnknown;
}

enums.CoordGetInclDrawClasses1? coordGetInclDrawClasses1NullableFromJson(
  Object? coordGetInclDrawClasses1, [
  enums.CoordGetInclDrawClasses1? defaultValue,
]) {
  if (coordGetInclDrawClasses1 == null) {
    return null;
  }
  return enums.CoordGetInclDrawClasses1.values
          .firstWhereOrNull((e) => e.value == coordGetInclDrawClasses1) ??
      defaultValue;
}

String coordGetInclDrawClasses1ExplodedListToJson(
    List<enums.CoordGetInclDrawClasses1>? coordGetInclDrawClasses1) {
  return coordGetInclDrawClasses1?.map((e) => e.value!).join(',') ?? '';
}

List<String> coordGetInclDrawClasses1ListToJson(
    List<enums.CoordGetInclDrawClasses1>? coordGetInclDrawClasses1) {
  if (coordGetInclDrawClasses1 == null) {
    return [];
  }

  return coordGetInclDrawClasses1.map((e) => e.value!).toList();
}

List<enums.CoordGetInclDrawClasses1> coordGetInclDrawClasses1ListFromJson(
  List? coordGetInclDrawClasses1, [
  List<enums.CoordGetInclDrawClasses1>? defaultValue,
]) {
  if (coordGetInclDrawClasses1 == null) {
    return defaultValue ?? [];
  }

  return coordGetInclDrawClasses1
      .map((e) => coordGetInclDrawClasses1FromJson(e.toString()))
      .toList();
}

List<enums.CoordGetInclDrawClasses1>?
    coordGetInclDrawClasses1NullableListFromJson(
  List? coordGetInclDrawClasses1, [
  List<enums.CoordGetInclDrawClasses1>? defaultValue,
]) {
  if (coordGetInclDrawClasses1 == null) {
    return defaultValue;
  }

  return coordGetInclDrawClasses1
      .map((e) => coordGetInclDrawClasses1FromJson(e.toString()))
      .toList();
}

String? coordGetPoisOnMapMacroNullableToJson(
    enums.CoordGetPoisOnMapMacro? coordGetPoisOnMapMacro) {
  return coordGetPoisOnMapMacro?.value;
}

String? coordGetPoisOnMapMacroToJson(
    enums.CoordGetPoisOnMapMacro coordGetPoisOnMapMacro) {
  return coordGetPoisOnMapMacro.value;
}

enums.CoordGetPoisOnMapMacro coordGetPoisOnMapMacroFromJson(
  Object? coordGetPoisOnMapMacro, [
  enums.CoordGetPoisOnMapMacro? defaultValue,
]) {
  return enums.CoordGetPoisOnMapMacro.values
          .firstWhereOrNull((e) => e.value == coordGetPoisOnMapMacro) ??
      defaultValue ??
      enums.CoordGetPoisOnMapMacro.swaggerGeneratedUnknown;
}

enums.CoordGetPoisOnMapMacro? coordGetPoisOnMapMacroNullableFromJson(
  Object? coordGetPoisOnMapMacro, [
  enums.CoordGetPoisOnMapMacro? defaultValue,
]) {
  if (coordGetPoisOnMapMacro == null) {
    return null;
  }
  return enums.CoordGetPoisOnMapMacro.values
          .firstWhereOrNull((e) => e.value == coordGetPoisOnMapMacro) ??
      defaultValue;
}

String coordGetPoisOnMapMacroExplodedListToJson(
    List<enums.CoordGetPoisOnMapMacro>? coordGetPoisOnMapMacro) {
  return coordGetPoisOnMapMacro?.map((e) => e.value!).join(',') ?? '';
}

List<String> coordGetPoisOnMapMacroListToJson(
    List<enums.CoordGetPoisOnMapMacro>? coordGetPoisOnMapMacro) {
  if (coordGetPoisOnMapMacro == null) {
    return [];
  }

  return coordGetPoisOnMapMacro.map((e) => e.value!).toList();
}

List<enums.CoordGetPoisOnMapMacro> coordGetPoisOnMapMacroListFromJson(
  List? coordGetPoisOnMapMacro, [
  List<enums.CoordGetPoisOnMapMacro>? defaultValue,
]) {
  if (coordGetPoisOnMapMacro == null) {
    return defaultValue ?? [];
  }

  return coordGetPoisOnMapMacro
      .map((e) => coordGetPoisOnMapMacroFromJson(e.toString()))
      .toList();
}

List<enums.CoordGetPoisOnMapMacro>? coordGetPoisOnMapMacroNullableListFromJson(
  List? coordGetPoisOnMapMacro, [
  List<enums.CoordGetPoisOnMapMacro>? defaultValue,
]) {
  if (coordGetPoisOnMapMacro == null) {
    return defaultValue;
  }

  return coordGetPoisOnMapMacro
      .map((e) => coordGetPoisOnMapMacroFromJson(e.toString()))
      .toList();
}

String? departureMonGetOutputFormatNullableToJson(
    enums.DepartureMonGetOutputFormat? departureMonGetOutputFormat) {
  return departureMonGetOutputFormat?.value;
}

String? departureMonGetOutputFormatToJson(
    enums.DepartureMonGetOutputFormat departureMonGetOutputFormat) {
  return departureMonGetOutputFormat.value;
}

enums.DepartureMonGetOutputFormat departureMonGetOutputFormatFromJson(
  Object? departureMonGetOutputFormat, [
  enums.DepartureMonGetOutputFormat? defaultValue,
]) {
  return enums.DepartureMonGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == departureMonGetOutputFormat) ??
      defaultValue ??
      enums.DepartureMonGetOutputFormat.swaggerGeneratedUnknown;
}

enums.DepartureMonGetOutputFormat? departureMonGetOutputFormatNullableFromJson(
  Object? departureMonGetOutputFormat, [
  enums.DepartureMonGetOutputFormat? defaultValue,
]) {
  if (departureMonGetOutputFormat == null) {
    return null;
  }
  return enums.DepartureMonGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == departureMonGetOutputFormat) ??
      defaultValue;
}

String departureMonGetOutputFormatExplodedListToJson(
    List<enums.DepartureMonGetOutputFormat>? departureMonGetOutputFormat) {
  return departureMonGetOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetOutputFormatListToJson(
    List<enums.DepartureMonGetOutputFormat>? departureMonGetOutputFormat) {
  if (departureMonGetOutputFormat == null) {
    return [];
  }

  return departureMonGetOutputFormat.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetOutputFormat> departureMonGetOutputFormatListFromJson(
  List? departureMonGetOutputFormat, [
  List<enums.DepartureMonGetOutputFormat>? defaultValue,
]) {
  if (departureMonGetOutputFormat == null) {
    return defaultValue ?? [];
  }

  return departureMonGetOutputFormat
      .map((e) => departureMonGetOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetOutputFormat>?
    departureMonGetOutputFormatNullableListFromJson(
  List? departureMonGetOutputFormat, [
  List<enums.DepartureMonGetOutputFormat>? defaultValue,
]) {
  if (departureMonGetOutputFormat == null) {
    return defaultValue;
  }

  return departureMonGetOutputFormat
      .map((e) => departureMonGetOutputFormatFromJson(e.toString()))
      .toList();
}

String? departureMonGetCoordOutputFormatNullableToJson(
    enums.DepartureMonGetCoordOutputFormat? departureMonGetCoordOutputFormat) {
  return departureMonGetCoordOutputFormat?.value;
}

String? departureMonGetCoordOutputFormatToJson(
    enums.DepartureMonGetCoordOutputFormat departureMonGetCoordOutputFormat) {
  return departureMonGetCoordOutputFormat.value;
}

enums.DepartureMonGetCoordOutputFormat departureMonGetCoordOutputFormatFromJson(
  Object? departureMonGetCoordOutputFormat, [
  enums.DepartureMonGetCoordOutputFormat? defaultValue,
]) {
  return enums.DepartureMonGetCoordOutputFormat.values.firstWhereOrNull(
          (e) => e.value == departureMonGetCoordOutputFormat) ??
      defaultValue ??
      enums.DepartureMonGetCoordOutputFormat.swaggerGeneratedUnknown;
}

enums.DepartureMonGetCoordOutputFormat?
    departureMonGetCoordOutputFormatNullableFromJson(
  Object? departureMonGetCoordOutputFormat, [
  enums.DepartureMonGetCoordOutputFormat? defaultValue,
]) {
  if (departureMonGetCoordOutputFormat == null) {
    return null;
  }
  return enums.DepartureMonGetCoordOutputFormat.values.firstWhereOrNull(
          (e) => e.value == departureMonGetCoordOutputFormat) ??
      defaultValue;
}

String departureMonGetCoordOutputFormatExplodedListToJson(
    List<enums.DepartureMonGetCoordOutputFormat>?
        departureMonGetCoordOutputFormat) {
  return departureMonGetCoordOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetCoordOutputFormatListToJson(
    List<enums.DepartureMonGetCoordOutputFormat>?
        departureMonGetCoordOutputFormat) {
  if (departureMonGetCoordOutputFormat == null) {
    return [];
  }

  return departureMonGetCoordOutputFormat.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetCoordOutputFormat>
    departureMonGetCoordOutputFormatListFromJson(
  List? departureMonGetCoordOutputFormat, [
  List<enums.DepartureMonGetCoordOutputFormat>? defaultValue,
]) {
  if (departureMonGetCoordOutputFormat == null) {
    return defaultValue ?? [];
  }

  return departureMonGetCoordOutputFormat
      .map((e) => departureMonGetCoordOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetCoordOutputFormat>?
    departureMonGetCoordOutputFormatNullableListFromJson(
  List? departureMonGetCoordOutputFormat, [
  List<enums.DepartureMonGetCoordOutputFormat>? defaultValue,
]) {
  if (departureMonGetCoordOutputFormat == null) {
    return defaultValue;
  }

  return departureMonGetCoordOutputFormat
      .map((e) => departureMonGetCoordOutputFormatFromJson(e.toString()))
      .toList();
}

String? departureMonGetModeNullableToJson(
    enums.DepartureMonGetMode? departureMonGetMode) {
  return departureMonGetMode?.value;
}

String? departureMonGetModeToJson(
    enums.DepartureMonGetMode departureMonGetMode) {
  return departureMonGetMode.value;
}

enums.DepartureMonGetMode departureMonGetModeFromJson(
  Object? departureMonGetMode, [
  enums.DepartureMonGetMode? defaultValue,
]) {
  return enums.DepartureMonGetMode.values
          .firstWhereOrNull((e) => e.value == departureMonGetMode) ??
      defaultValue ??
      enums.DepartureMonGetMode.swaggerGeneratedUnknown;
}

enums.DepartureMonGetMode? departureMonGetModeNullableFromJson(
  Object? departureMonGetMode, [
  enums.DepartureMonGetMode? defaultValue,
]) {
  if (departureMonGetMode == null) {
    return null;
  }
  return enums.DepartureMonGetMode.values
          .firstWhereOrNull((e) => e.value == departureMonGetMode) ??
      defaultValue;
}

String departureMonGetModeExplodedListToJson(
    List<enums.DepartureMonGetMode>? departureMonGetMode) {
  return departureMonGetMode?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetModeListToJson(
    List<enums.DepartureMonGetMode>? departureMonGetMode) {
  if (departureMonGetMode == null) {
    return [];
  }

  return departureMonGetMode.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetMode> departureMonGetModeListFromJson(
  List? departureMonGetMode, [
  List<enums.DepartureMonGetMode>? defaultValue,
]) {
  if (departureMonGetMode == null) {
    return defaultValue ?? [];
  }

  return departureMonGetMode
      .map((e) => departureMonGetModeFromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetMode>? departureMonGetModeNullableListFromJson(
  List? departureMonGetMode, [
  List<enums.DepartureMonGetMode>? defaultValue,
]) {
  if (departureMonGetMode == null) {
    return defaultValue;
  }

  return departureMonGetMode
      .map((e) => departureMonGetModeFromJson(e.toString()))
      .toList();
}

String? departureMonGetTypeDmNullableToJson(
    enums.DepartureMonGetTypeDm? departureMonGetTypeDm) {
  return departureMonGetTypeDm?.value;
}

String? departureMonGetTypeDmToJson(
    enums.DepartureMonGetTypeDm departureMonGetTypeDm) {
  return departureMonGetTypeDm.value;
}

enums.DepartureMonGetTypeDm departureMonGetTypeDmFromJson(
  Object? departureMonGetTypeDm, [
  enums.DepartureMonGetTypeDm? defaultValue,
]) {
  return enums.DepartureMonGetTypeDm.values
          .firstWhereOrNull((e) => e.value == departureMonGetTypeDm) ??
      defaultValue ??
      enums.DepartureMonGetTypeDm.swaggerGeneratedUnknown;
}

enums.DepartureMonGetTypeDm? departureMonGetTypeDmNullableFromJson(
  Object? departureMonGetTypeDm, [
  enums.DepartureMonGetTypeDm? defaultValue,
]) {
  if (departureMonGetTypeDm == null) {
    return null;
  }
  return enums.DepartureMonGetTypeDm.values
          .firstWhereOrNull((e) => e.value == departureMonGetTypeDm) ??
      defaultValue;
}

String departureMonGetTypeDmExplodedListToJson(
    List<enums.DepartureMonGetTypeDm>? departureMonGetTypeDm) {
  return departureMonGetTypeDm?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetTypeDmListToJson(
    List<enums.DepartureMonGetTypeDm>? departureMonGetTypeDm) {
  if (departureMonGetTypeDm == null) {
    return [];
  }

  return departureMonGetTypeDm.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetTypeDm> departureMonGetTypeDmListFromJson(
  List? departureMonGetTypeDm, [
  List<enums.DepartureMonGetTypeDm>? defaultValue,
]) {
  if (departureMonGetTypeDm == null) {
    return defaultValue ?? [];
  }

  return departureMonGetTypeDm
      .map((e) => departureMonGetTypeDmFromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetTypeDm>? departureMonGetTypeDmNullableListFromJson(
  List? departureMonGetTypeDm, [
  List<enums.DepartureMonGetTypeDm>? defaultValue,
]) {
  if (departureMonGetTypeDm == null) {
    return defaultValue;
  }

  return departureMonGetTypeDm
      .map((e) => departureMonGetTypeDmFromJson(e.toString()))
      .toList();
}

String? departureMonGetNameKeyDmNullableToJson(
    enums.DepartureMonGetNameKeyDm? departureMonGetNameKeyDm) {
  return departureMonGetNameKeyDm?.value;
}

String? departureMonGetNameKeyDmToJson(
    enums.DepartureMonGetNameKeyDm departureMonGetNameKeyDm) {
  return departureMonGetNameKeyDm.value;
}

enums.DepartureMonGetNameKeyDm departureMonGetNameKeyDmFromJson(
  Object? departureMonGetNameKeyDm, [
  enums.DepartureMonGetNameKeyDm? defaultValue,
]) {
  return enums.DepartureMonGetNameKeyDm.values
          .firstWhereOrNull((e) => e.value == departureMonGetNameKeyDm) ??
      defaultValue ??
      enums.DepartureMonGetNameKeyDm.swaggerGeneratedUnknown;
}

enums.DepartureMonGetNameKeyDm? departureMonGetNameKeyDmNullableFromJson(
  Object? departureMonGetNameKeyDm, [
  enums.DepartureMonGetNameKeyDm? defaultValue,
]) {
  if (departureMonGetNameKeyDm == null) {
    return null;
  }
  return enums.DepartureMonGetNameKeyDm.values
          .firstWhereOrNull((e) => e.value == departureMonGetNameKeyDm) ??
      defaultValue;
}

String departureMonGetNameKeyDmExplodedListToJson(
    List<enums.DepartureMonGetNameKeyDm>? departureMonGetNameKeyDm) {
  return departureMonGetNameKeyDm?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetNameKeyDmListToJson(
    List<enums.DepartureMonGetNameKeyDm>? departureMonGetNameKeyDm) {
  if (departureMonGetNameKeyDm == null) {
    return [];
  }

  return departureMonGetNameKeyDm.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetNameKeyDm> departureMonGetNameKeyDmListFromJson(
  List? departureMonGetNameKeyDm, [
  List<enums.DepartureMonGetNameKeyDm>? defaultValue,
]) {
  if (departureMonGetNameKeyDm == null) {
    return defaultValue ?? [];
  }

  return departureMonGetNameKeyDm
      .map((e) => departureMonGetNameKeyDmFromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetNameKeyDm>?
    departureMonGetNameKeyDmNullableListFromJson(
  List? departureMonGetNameKeyDm, [
  List<enums.DepartureMonGetNameKeyDm>? defaultValue,
]) {
  if (departureMonGetNameKeyDm == null) {
    return defaultValue;
  }

  return departureMonGetNameKeyDm
      .map((e) => departureMonGetNameKeyDmFromJson(e.toString()))
      .toList();
}

String? departureMonGetDepartureMonitorMacroNullableToJson(
    enums.DepartureMonGetDepartureMonitorMacro?
        departureMonGetDepartureMonitorMacro) {
  return departureMonGetDepartureMonitorMacro?.value;
}

String? departureMonGetDepartureMonitorMacroToJson(
    enums.DepartureMonGetDepartureMonitorMacro
        departureMonGetDepartureMonitorMacro) {
  return departureMonGetDepartureMonitorMacro.value;
}

enums.DepartureMonGetDepartureMonitorMacro
    departureMonGetDepartureMonitorMacroFromJson(
  Object? departureMonGetDepartureMonitorMacro, [
  enums.DepartureMonGetDepartureMonitorMacro? defaultValue,
]) {
  return enums.DepartureMonGetDepartureMonitorMacro.values.firstWhereOrNull(
          (e) => e.value == departureMonGetDepartureMonitorMacro) ??
      defaultValue ??
      enums.DepartureMonGetDepartureMonitorMacro.swaggerGeneratedUnknown;
}

enums.DepartureMonGetDepartureMonitorMacro?
    departureMonGetDepartureMonitorMacroNullableFromJson(
  Object? departureMonGetDepartureMonitorMacro, [
  enums.DepartureMonGetDepartureMonitorMacro? defaultValue,
]) {
  if (departureMonGetDepartureMonitorMacro == null) {
    return null;
  }
  return enums.DepartureMonGetDepartureMonitorMacro.values.firstWhereOrNull(
          (e) => e.value == departureMonGetDepartureMonitorMacro) ??
      defaultValue;
}

String departureMonGetDepartureMonitorMacroExplodedListToJson(
    List<enums.DepartureMonGetDepartureMonitorMacro>?
        departureMonGetDepartureMonitorMacro) {
  return departureMonGetDepartureMonitorMacro?.map((e) => e.value!).join(',') ??
      '';
}

List<String> departureMonGetDepartureMonitorMacroListToJson(
    List<enums.DepartureMonGetDepartureMonitorMacro>?
        departureMonGetDepartureMonitorMacro) {
  if (departureMonGetDepartureMonitorMacro == null) {
    return [];
  }

  return departureMonGetDepartureMonitorMacro.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetDepartureMonitorMacro>
    departureMonGetDepartureMonitorMacroListFromJson(
  List? departureMonGetDepartureMonitorMacro, [
  List<enums.DepartureMonGetDepartureMonitorMacro>? defaultValue,
]) {
  if (departureMonGetDepartureMonitorMacro == null) {
    return defaultValue ?? [];
  }

  return departureMonGetDepartureMonitorMacro
      .map((e) => departureMonGetDepartureMonitorMacroFromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetDepartureMonitorMacro>?
    departureMonGetDepartureMonitorMacroNullableListFromJson(
  List? departureMonGetDepartureMonitorMacro, [
  List<enums.DepartureMonGetDepartureMonitorMacro>? defaultValue,
]) {
  if (departureMonGetDepartureMonitorMacro == null) {
    return defaultValue;
  }

  return departureMonGetDepartureMonitorMacro
      .map((e) => departureMonGetDepartureMonitorMacroFromJson(e.toString()))
      .toList();
}

String? departureMonGetExcludedMeansNullableToJson(
    enums.DepartureMonGetExcludedMeans? departureMonGetExcludedMeans) {
  return departureMonGetExcludedMeans?.value;
}

String? departureMonGetExcludedMeansToJson(
    enums.DepartureMonGetExcludedMeans departureMonGetExcludedMeans) {
  return departureMonGetExcludedMeans.value;
}

enums.DepartureMonGetExcludedMeans departureMonGetExcludedMeansFromJson(
  Object? departureMonGetExcludedMeans, [
  enums.DepartureMonGetExcludedMeans? defaultValue,
]) {
  return enums.DepartureMonGetExcludedMeans.values
          .firstWhereOrNull((e) => e.value == departureMonGetExcludedMeans) ??
      defaultValue ??
      enums.DepartureMonGetExcludedMeans.swaggerGeneratedUnknown;
}

enums.DepartureMonGetExcludedMeans?
    departureMonGetExcludedMeansNullableFromJson(
  Object? departureMonGetExcludedMeans, [
  enums.DepartureMonGetExcludedMeans? defaultValue,
]) {
  if (departureMonGetExcludedMeans == null) {
    return null;
  }
  return enums.DepartureMonGetExcludedMeans.values
          .firstWhereOrNull((e) => e.value == departureMonGetExcludedMeans) ??
      defaultValue;
}

String departureMonGetExcludedMeansExplodedListToJson(
    List<enums.DepartureMonGetExcludedMeans>? departureMonGetExcludedMeans) {
  return departureMonGetExcludedMeans?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetExcludedMeansListToJson(
    List<enums.DepartureMonGetExcludedMeans>? departureMonGetExcludedMeans) {
  if (departureMonGetExcludedMeans == null) {
    return [];
  }

  return departureMonGetExcludedMeans.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetExcludedMeans>
    departureMonGetExcludedMeansListFromJson(
  List? departureMonGetExcludedMeans, [
  List<enums.DepartureMonGetExcludedMeans>? defaultValue,
]) {
  if (departureMonGetExcludedMeans == null) {
    return defaultValue ?? [];
  }

  return departureMonGetExcludedMeans
      .map((e) => departureMonGetExcludedMeansFromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetExcludedMeans>?
    departureMonGetExcludedMeansNullableListFromJson(
  List? departureMonGetExcludedMeans, [
  List<enums.DepartureMonGetExcludedMeans>? defaultValue,
]) {
  if (departureMonGetExcludedMeans == null) {
    return defaultValue;
  }

  return departureMonGetExcludedMeans
      .map((e) => departureMonGetExcludedMeansFromJson(e.toString()))
      .toList();
}

String? departureMonGetExclMOT1NullableToJson(
    enums.DepartureMonGetExclMOT1? departureMonGetExclMOT1) {
  return departureMonGetExclMOT1?.value;
}

String? departureMonGetExclMOT1ToJson(
    enums.DepartureMonGetExclMOT1 departureMonGetExclMOT1) {
  return departureMonGetExclMOT1.value;
}

enums.DepartureMonGetExclMOT1 departureMonGetExclMOT1FromJson(
  Object? departureMonGetExclMOT1, [
  enums.DepartureMonGetExclMOT1? defaultValue,
]) {
  return enums.DepartureMonGetExclMOT1.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT1) ??
      defaultValue ??
      enums.DepartureMonGetExclMOT1.swaggerGeneratedUnknown;
}

enums.DepartureMonGetExclMOT1? departureMonGetExclMOT1NullableFromJson(
  Object? departureMonGetExclMOT1, [
  enums.DepartureMonGetExclMOT1? defaultValue,
]) {
  if (departureMonGetExclMOT1 == null) {
    return null;
  }
  return enums.DepartureMonGetExclMOT1.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT1) ??
      defaultValue;
}

String departureMonGetExclMOT1ExplodedListToJson(
    List<enums.DepartureMonGetExclMOT1>? departureMonGetExclMOT1) {
  return departureMonGetExclMOT1?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetExclMOT1ListToJson(
    List<enums.DepartureMonGetExclMOT1>? departureMonGetExclMOT1) {
  if (departureMonGetExclMOT1 == null) {
    return [];
  }

  return departureMonGetExclMOT1.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetExclMOT1> departureMonGetExclMOT1ListFromJson(
  List? departureMonGetExclMOT1, [
  List<enums.DepartureMonGetExclMOT1>? defaultValue,
]) {
  if (departureMonGetExclMOT1 == null) {
    return defaultValue ?? [];
  }

  return departureMonGetExclMOT1
      .map((e) => departureMonGetExclMOT1FromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetExclMOT1>?
    departureMonGetExclMOT1NullableListFromJson(
  List? departureMonGetExclMOT1, [
  List<enums.DepartureMonGetExclMOT1>? defaultValue,
]) {
  if (departureMonGetExclMOT1 == null) {
    return defaultValue;
  }

  return departureMonGetExclMOT1
      .map((e) => departureMonGetExclMOT1FromJson(e.toString()))
      .toList();
}

String? departureMonGetExclMOT2NullableToJson(
    enums.DepartureMonGetExclMOT2? departureMonGetExclMOT2) {
  return departureMonGetExclMOT2?.value;
}

String? departureMonGetExclMOT2ToJson(
    enums.DepartureMonGetExclMOT2 departureMonGetExclMOT2) {
  return departureMonGetExclMOT2.value;
}

enums.DepartureMonGetExclMOT2 departureMonGetExclMOT2FromJson(
  Object? departureMonGetExclMOT2, [
  enums.DepartureMonGetExclMOT2? defaultValue,
]) {
  return enums.DepartureMonGetExclMOT2.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT2) ??
      defaultValue ??
      enums.DepartureMonGetExclMOT2.swaggerGeneratedUnknown;
}

enums.DepartureMonGetExclMOT2? departureMonGetExclMOT2NullableFromJson(
  Object? departureMonGetExclMOT2, [
  enums.DepartureMonGetExclMOT2? defaultValue,
]) {
  if (departureMonGetExclMOT2 == null) {
    return null;
  }
  return enums.DepartureMonGetExclMOT2.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT2) ??
      defaultValue;
}

String departureMonGetExclMOT2ExplodedListToJson(
    List<enums.DepartureMonGetExclMOT2>? departureMonGetExclMOT2) {
  return departureMonGetExclMOT2?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetExclMOT2ListToJson(
    List<enums.DepartureMonGetExclMOT2>? departureMonGetExclMOT2) {
  if (departureMonGetExclMOT2 == null) {
    return [];
  }

  return departureMonGetExclMOT2.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetExclMOT2> departureMonGetExclMOT2ListFromJson(
  List? departureMonGetExclMOT2, [
  List<enums.DepartureMonGetExclMOT2>? defaultValue,
]) {
  if (departureMonGetExclMOT2 == null) {
    return defaultValue ?? [];
  }

  return departureMonGetExclMOT2
      .map((e) => departureMonGetExclMOT2FromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetExclMOT2>?
    departureMonGetExclMOT2NullableListFromJson(
  List? departureMonGetExclMOT2, [
  List<enums.DepartureMonGetExclMOT2>? defaultValue,
]) {
  if (departureMonGetExclMOT2 == null) {
    return defaultValue;
  }

  return departureMonGetExclMOT2
      .map((e) => departureMonGetExclMOT2FromJson(e.toString()))
      .toList();
}

String? departureMonGetExclMOT4NullableToJson(
    enums.DepartureMonGetExclMOT4? departureMonGetExclMOT4) {
  return departureMonGetExclMOT4?.value;
}

String? departureMonGetExclMOT4ToJson(
    enums.DepartureMonGetExclMOT4 departureMonGetExclMOT4) {
  return departureMonGetExclMOT4.value;
}

enums.DepartureMonGetExclMOT4 departureMonGetExclMOT4FromJson(
  Object? departureMonGetExclMOT4, [
  enums.DepartureMonGetExclMOT4? defaultValue,
]) {
  return enums.DepartureMonGetExclMOT4.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT4) ??
      defaultValue ??
      enums.DepartureMonGetExclMOT4.swaggerGeneratedUnknown;
}

enums.DepartureMonGetExclMOT4? departureMonGetExclMOT4NullableFromJson(
  Object? departureMonGetExclMOT4, [
  enums.DepartureMonGetExclMOT4? defaultValue,
]) {
  if (departureMonGetExclMOT4 == null) {
    return null;
  }
  return enums.DepartureMonGetExclMOT4.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT4) ??
      defaultValue;
}

String departureMonGetExclMOT4ExplodedListToJson(
    List<enums.DepartureMonGetExclMOT4>? departureMonGetExclMOT4) {
  return departureMonGetExclMOT4?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetExclMOT4ListToJson(
    List<enums.DepartureMonGetExclMOT4>? departureMonGetExclMOT4) {
  if (departureMonGetExclMOT4 == null) {
    return [];
  }

  return departureMonGetExclMOT4.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetExclMOT4> departureMonGetExclMOT4ListFromJson(
  List? departureMonGetExclMOT4, [
  List<enums.DepartureMonGetExclMOT4>? defaultValue,
]) {
  if (departureMonGetExclMOT4 == null) {
    return defaultValue ?? [];
  }

  return departureMonGetExclMOT4
      .map((e) => departureMonGetExclMOT4FromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetExclMOT4>?
    departureMonGetExclMOT4NullableListFromJson(
  List? departureMonGetExclMOT4, [
  List<enums.DepartureMonGetExclMOT4>? defaultValue,
]) {
  if (departureMonGetExclMOT4 == null) {
    return defaultValue;
  }

  return departureMonGetExclMOT4
      .map((e) => departureMonGetExclMOT4FromJson(e.toString()))
      .toList();
}

String? departureMonGetExclMOT5NullableToJson(
    enums.DepartureMonGetExclMOT5? departureMonGetExclMOT5) {
  return departureMonGetExclMOT5?.value;
}

String? departureMonGetExclMOT5ToJson(
    enums.DepartureMonGetExclMOT5 departureMonGetExclMOT5) {
  return departureMonGetExclMOT5.value;
}

enums.DepartureMonGetExclMOT5 departureMonGetExclMOT5FromJson(
  Object? departureMonGetExclMOT5, [
  enums.DepartureMonGetExclMOT5? defaultValue,
]) {
  return enums.DepartureMonGetExclMOT5.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT5) ??
      defaultValue ??
      enums.DepartureMonGetExclMOT5.swaggerGeneratedUnknown;
}

enums.DepartureMonGetExclMOT5? departureMonGetExclMOT5NullableFromJson(
  Object? departureMonGetExclMOT5, [
  enums.DepartureMonGetExclMOT5? defaultValue,
]) {
  if (departureMonGetExclMOT5 == null) {
    return null;
  }
  return enums.DepartureMonGetExclMOT5.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT5) ??
      defaultValue;
}

String departureMonGetExclMOT5ExplodedListToJson(
    List<enums.DepartureMonGetExclMOT5>? departureMonGetExclMOT5) {
  return departureMonGetExclMOT5?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetExclMOT5ListToJson(
    List<enums.DepartureMonGetExclMOT5>? departureMonGetExclMOT5) {
  if (departureMonGetExclMOT5 == null) {
    return [];
  }

  return departureMonGetExclMOT5.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetExclMOT5> departureMonGetExclMOT5ListFromJson(
  List? departureMonGetExclMOT5, [
  List<enums.DepartureMonGetExclMOT5>? defaultValue,
]) {
  if (departureMonGetExclMOT5 == null) {
    return defaultValue ?? [];
  }

  return departureMonGetExclMOT5
      .map((e) => departureMonGetExclMOT5FromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetExclMOT5>?
    departureMonGetExclMOT5NullableListFromJson(
  List? departureMonGetExclMOT5, [
  List<enums.DepartureMonGetExclMOT5>? defaultValue,
]) {
  if (departureMonGetExclMOT5 == null) {
    return defaultValue;
  }

  return departureMonGetExclMOT5
      .map((e) => departureMonGetExclMOT5FromJson(e.toString()))
      .toList();
}

String? departureMonGetExclMOT7NullableToJson(
    enums.DepartureMonGetExclMOT7? departureMonGetExclMOT7) {
  return departureMonGetExclMOT7?.value;
}

String? departureMonGetExclMOT7ToJson(
    enums.DepartureMonGetExclMOT7 departureMonGetExclMOT7) {
  return departureMonGetExclMOT7.value;
}

enums.DepartureMonGetExclMOT7 departureMonGetExclMOT7FromJson(
  Object? departureMonGetExclMOT7, [
  enums.DepartureMonGetExclMOT7? defaultValue,
]) {
  return enums.DepartureMonGetExclMOT7.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT7) ??
      defaultValue ??
      enums.DepartureMonGetExclMOT7.swaggerGeneratedUnknown;
}

enums.DepartureMonGetExclMOT7? departureMonGetExclMOT7NullableFromJson(
  Object? departureMonGetExclMOT7, [
  enums.DepartureMonGetExclMOT7? defaultValue,
]) {
  if (departureMonGetExclMOT7 == null) {
    return null;
  }
  return enums.DepartureMonGetExclMOT7.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT7) ??
      defaultValue;
}

String departureMonGetExclMOT7ExplodedListToJson(
    List<enums.DepartureMonGetExclMOT7>? departureMonGetExclMOT7) {
  return departureMonGetExclMOT7?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetExclMOT7ListToJson(
    List<enums.DepartureMonGetExclMOT7>? departureMonGetExclMOT7) {
  if (departureMonGetExclMOT7 == null) {
    return [];
  }

  return departureMonGetExclMOT7.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetExclMOT7> departureMonGetExclMOT7ListFromJson(
  List? departureMonGetExclMOT7, [
  List<enums.DepartureMonGetExclMOT7>? defaultValue,
]) {
  if (departureMonGetExclMOT7 == null) {
    return defaultValue ?? [];
  }

  return departureMonGetExclMOT7
      .map((e) => departureMonGetExclMOT7FromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetExclMOT7>?
    departureMonGetExclMOT7NullableListFromJson(
  List? departureMonGetExclMOT7, [
  List<enums.DepartureMonGetExclMOT7>? defaultValue,
]) {
  if (departureMonGetExclMOT7 == null) {
    return defaultValue;
  }

  return departureMonGetExclMOT7
      .map((e) => departureMonGetExclMOT7FromJson(e.toString()))
      .toList();
}

String? departureMonGetExclMOT9NullableToJson(
    enums.DepartureMonGetExclMOT9? departureMonGetExclMOT9) {
  return departureMonGetExclMOT9?.value;
}

String? departureMonGetExclMOT9ToJson(
    enums.DepartureMonGetExclMOT9 departureMonGetExclMOT9) {
  return departureMonGetExclMOT9.value;
}

enums.DepartureMonGetExclMOT9 departureMonGetExclMOT9FromJson(
  Object? departureMonGetExclMOT9, [
  enums.DepartureMonGetExclMOT9? defaultValue,
]) {
  return enums.DepartureMonGetExclMOT9.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT9) ??
      defaultValue ??
      enums.DepartureMonGetExclMOT9.swaggerGeneratedUnknown;
}

enums.DepartureMonGetExclMOT9? departureMonGetExclMOT9NullableFromJson(
  Object? departureMonGetExclMOT9, [
  enums.DepartureMonGetExclMOT9? defaultValue,
]) {
  if (departureMonGetExclMOT9 == null) {
    return null;
  }
  return enums.DepartureMonGetExclMOT9.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT9) ??
      defaultValue;
}

String departureMonGetExclMOT9ExplodedListToJson(
    List<enums.DepartureMonGetExclMOT9>? departureMonGetExclMOT9) {
  return departureMonGetExclMOT9?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetExclMOT9ListToJson(
    List<enums.DepartureMonGetExclMOT9>? departureMonGetExclMOT9) {
  if (departureMonGetExclMOT9 == null) {
    return [];
  }

  return departureMonGetExclMOT9.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetExclMOT9> departureMonGetExclMOT9ListFromJson(
  List? departureMonGetExclMOT9, [
  List<enums.DepartureMonGetExclMOT9>? defaultValue,
]) {
  if (departureMonGetExclMOT9 == null) {
    return defaultValue ?? [];
  }

  return departureMonGetExclMOT9
      .map((e) => departureMonGetExclMOT9FromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetExclMOT9>?
    departureMonGetExclMOT9NullableListFromJson(
  List? departureMonGetExclMOT9, [
  List<enums.DepartureMonGetExclMOT9>? defaultValue,
]) {
  if (departureMonGetExclMOT9 == null) {
    return defaultValue;
  }

  return departureMonGetExclMOT9
      .map((e) => departureMonGetExclMOT9FromJson(e.toString()))
      .toList();
}

String? departureMonGetExclMOT11NullableToJson(
    enums.DepartureMonGetExclMOT11? departureMonGetExclMOT11) {
  return departureMonGetExclMOT11?.value;
}

String? departureMonGetExclMOT11ToJson(
    enums.DepartureMonGetExclMOT11 departureMonGetExclMOT11) {
  return departureMonGetExclMOT11.value;
}

enums.DepartureMonGetExclMOT11 departureMonGetExclMOT11FromJson(
  Object? departureMonGetExclMOT11, [
  enums.DepartureMonGetExclMOT11? defaultValue,
]) {
  return enums.DepartureMonGetExclMOT11.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT11) ??
      defaultValue ??
      enums.DepartureMonGetExclMOT11.swaggerGeneratedUnknown;
}

enums.DepartureMonGetExclMOT11? departureMonGetExclMOT11NullableFromJson(
  Object? departureMonGetExclMOT11, [
  enums.DepartureMonGetExclMOT11? defaultValue,
]) {
  if (departureMonGetExclMOT11 == null) {
    return null;
  }
  return enums.DepartureMonGetExclMOT11.values
          .firstWhereOrNull((e) => e.value == departureMonGetExclMOT11) ??
      defaultValue;
}

String departureMonGetExclMOT11ExplodedListToJson(
    List<enums.DepartureMonGetExclMOT11>? departureMonGetExclMOT11) {
  return departureMonGetExclMOT11?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetExclMOT11ListToJson(
    List<enums.DepartureMonGetExclMOT11>? departureMonGetExclMOT11) {
  if (departureMonGetExclMOT11 == null) {
    return [];
  }

  return departureMonGetExclMOT11.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetExclMOT11> departureMonGetExclMOT11ListFromJson(
  List? departureMonGetExclMOT11, [
  List<enums.DepartureMonGetExclMOT11>? defaultValue,
]) {
  if (departureMonGetExclMOT11 == null) {
    return defaultValue ?? [];
  }

  return departureMonGetExclMOT11
      .map((e) => departureMonGetExclMOT11FromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetExclMOT11>?
    departureMonGetExclMOT11NullableListFromJson(
  List? departureMonGetExclMOT11, [
  List<enums.DepartureMonGetExclMOT11>? defaultValue,
]) {
  if (departureMonGetExclMOT11 == null) {
    return defaultValue;
  }

  return departureMonGetExclMOT11
      .map((e) => departureMonGetExclMOT11FromJson(e.toString()))
      .toList();
}

String? departureMonGetTfNSWDMNullableToJson(
    enums.DepartureMonGetTfNSWDM? departureMonGetTfNSWDM) {
  return departureMonGetTfNSWDM?.value;
}

String? departureMonGetTfNSWDMToJson(
    enums.DepartureMonGetTfNSWDM departureMonGetTfNSWDM) {
  return departureMonGetTfNSWDM.value;
}

enums.DepartureMonGetTfNSWDM departureMonGetTfNSWDMFromJson(
  Object? departureMonGetTfNSWDM, [
  enums.DepartureMonGetTfNSWDM? defaultValue,
]) {
  return enums.DepartureMonGetTfNSWDM.values
          .firstWhereOrNull((e) => e.value == departureMonGetTfNSWDM) ??
      defaultValue ??
      enums.DepartureMonGetTfNSWDM.swaggerGeneratedUnknown;
}

enums.DepartureMonGetTfNSWDM? departureMonGetTfNSWDMNullableFromJson(
  Object? departureMonGetTfNSWDM, [
  enums.DepartureMonGetTfNSWDM? defaultValue,
]) {
  if (departureMonGetTfNSWDM == null) {
    return null;
  }
  return enums.DepartureMonGetTfNSWDM.values
          .firstWhereOrNull((e) => e.value == departureMonGetTfNSWDM) ??
      defaultValue;
}

String departureMonGetTfNSWDMExplodedListToJson(
    List<enums.DepartureMonGetTfNSWDM>? departureMonGetTfNSWDM) {
  return departureMonGetTfNSWDM?.map((e) => e.value!).join(',') ?? '';
}

List<String> departureMonGetTfNSWDMListToJson(
    List<enums.DepartureMonGetTfNSWDM>? departureMonGetTfNSWDM) {
  if (departureMonGetTfNSWDM == null) {
    return [];
  }

  return departureMonGetTfNSWDM.map((e) => e.value!).toList();
}

List<enums.DepartureMonGetTfNSWDM> departureMonGetTfNSWDMListFromJson(
  List? departureMonGetTfNSWDM, [
  List<enums.DepartureMonGetTfNSWDM>? defaultValue,
]) {
  if (departureMonGetTfNSWDM == null) {
    return defaultValue ?? [];
  }

  return departureMonGetTfNSWDM
      .map((e) => departureMonGetTfNSWDMFromJson(e.toString()))
      .toList();
}

List<enums.DepartureMonGetTfNSWDM>? departureMonGetTfNSWDMNullableListFromJson(
  List? departureMonGetTfNSWDM, [
  List<enums.DepartureMonGetTfNSWDM>? defaultValue,
]) {
  if (departureMonGetTfNSWDM == null) {
    return defaultValue;
  }

  return departureMonGetTfNSWDM
      .map((e) => departureMonGetTfNSWDMFromJson(e.toString()))
      .toList();
}

String? stopFinderGetOutputFormatNullableToJson(
    enums.StopFinderGetOutputFormat? stopFinderGetOutputFormat) {
  return stopFinderGetOutputFormat?.value;
}

String? stopFinderGetOutputFormatToJson(
    enums.StopFinderGetOutputFormat stopFinderGetOutputFormat) {
  return stopFinderGetOutputFormat.value;
}

enums.StopFinderGetOutputFormat stopFinderGetOutputFormatFromJson(
  Object? stopFinderGetOutputFormat, [
  enums.StopFinderGetOutputFormat? defaultValue,
]) {
  return enums.StopFinderGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == stopFinderGetOutputFormat) ??
      defaultValue ??
      enums.StopFinderGetOutputFormat.swaggerGeneratedUnknown;
}

enums.StopFinderGetOutputFormat? stopFinderGetOutputFormatNullableFromJson(
  Object? stopFinderGetOutputFormat, [
  enums.StopFinderGetOutputFormat? defaultValue,
]) {
  if (stopFinderGetOutputFormat == null) {
    return null;
  }
  return enums.StopFinderGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == stopFinderGetOutputFormat) ??
      defaultValue;
}

String stopFinderGetOutputFormatExplodedListToJson(
    List<enums.StopFinderGetOutputFormat>? stopFinderGetOutputFormat) {
  return stopFinderGetOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> stopFinderGetOutputFormatListToJson(
    List<enums.StopFinderGetOutputFormat>? stopFinderGetOutputFormat) {
  if (stopFinderGetOutputFormat == null) {
    return [];
  }

  return stopFinderGetOutputFormat.map((e) => e.value!).toList();
}

List<enums.StopFinderGetOutputFormat> stopFinderGetOutputFormatListFromJson(
  List? stopFinderGetOutputFormat, [
  List<enums.StopFinderGetOutputFormat>? defaultValue,
]) {
  if (stopFinderGetOutputFormat == null) {
    return defaultValue ?? [];
  }

  return stopFinderGetOutputFormat
      .map((e) => stopFinderGetOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.StopFinderGetOutputFormat>?
    stopFinderGetOutputFormatNullableListFromJson(
  List? stopFinderGetOutputFormat, [
  List<enums.StopFinderGetOutputFormat>? defaultValue,
]) {
  if (stopFinderGetOutputFormat == null) {
    return defaultValue;
  }

  return stopFinderGetOutputFormat
      .map((e) => stopFinderGetOutputFormatFromJson(e.toString()))
      .toList();
}

String? stopFinderGetTypeSfNullableToJson(
    enums.StopFinderGetTypeSf? stopFinderGetTypeSf) {
  return stopFinderGetTypeSf?.value;
}

String? stopFinderGetTypeSfToJson(
    enums.StopFinderGetTypeSf stopFinderGetTypeSf) {
  return stopFinderGetTypeSf.value;
}

enums.StopFinderGetTypeSf stopFinderGetTypeSfFromJson(
  Object? stopFinderGetTypeSf, [
  enums.StopFinderGetTypeSf? defaultValue,
]) {
  return enums.StopFinderGetTypeSf.values
          .firstWhereOrNull((e) => e.value == stopFinderGetTypeSf) ??
      defaultValue ??
      enums.StopFinderGetTypeSf.swaggerGeneratedUnknown;
}

enums.StopFinderGetTypeSf? stopFinderGetTypeSfNullableFromJson(
  Object? stopFinderGetTypeSf, [
  enums.StopFinderGetTypeSf? defaultValue,
]) {
  if (stopFinderGetTypeSf == null) {
    return null;
  }
  return enums.StopFinderGetTypeSf.values
          .firstWhereOrNull((e) => e.value == stopFinderGetTypeSf) ??
      defaultValue;
}

String stopFinderGetTypeSfExplodedListToJson(
    List<enums.StopFinderGetTypeSf>? stopFinderGetTypeSf) {
  return stopFinderGetTypeSf?.map((e) => e.value!).join(',') ?? '';
}

List<String> stopFinderGetTypeSfListToJson(
    List<enums.StopFinderGetTypeSf>? stopFinderGetTypeSf) {
  if (stopFinderGetTypeSf == null) {
    return [];
  }

  return stopFinderGetTypeSf.map((e) => e.value!).toList();
}

List<enums.StopFinderGetTypeSf> stopFinderGetTypeSfListFromJson(
  List? stopFinderGetTypeSf, [
  List<enums.StopFinderGetTypeSf>? defaultValue,
]) {
  if (stopFinderGetTypeSf == null) {
    return defaultValue ?? [];
  }

  return stopFinderGetTypeSf
      .map((e) => stopFinderGetTypeSfFromJson(e.toString()))
      .toList();
}

List<enums.StopFinderGetTypeSf>? stopFinderGetTypeSfNullableListFromJson(
  List? stopFinderGetTypeSf, [
  List<enums.StopFinderGetTypeSf>? defaultValue,
]) {
  if (stopFinderGetTypeSf == null) {
    return defaultValue;
  }

  return stopFinderGetTypeSf
      .map((e) => stopFinderGetTypeSfFromJson(e.toString()))
      .toList();
}

String? stopFinderGetCoordOutputFormatNullableToJson(
    enums.StopFinderGetCoordOutputFormat? stopFinderGetCoordOutputFormat) {
  return stopFinderGetCoordOutputFormat?.value;
}

String? stopFinderGetCoordOutputFormatToJson(
    enums.StopFinderGetCoordOutputFormat stopFinderGetCoordOutputFormat) {
  return stopFinderGetCoordOutputFormat.value;
}

enums.StopFinderGetCoordOutputFormat stopFinderGetCoordOutputFormatFromJson(
  Object? stopFinderGetCoordOutputFormat, [
  enums.StopFinderGetCoordOutputFormat? defaultValue,
]) {
  return enums.StopFinderGetCoordOutputFormat.values
          .firstWhereOrNull((e) => e.value == stopFinderGetCoordOutputFormat) ??
      defaultValue ??
      enums.StopFinderGetCoordOutputFormat.swaggerGeneratedUnknown;
}

enums.StopFinderGetCoordOutputFormat?
    stopFinderGetCoordOutputFormatNullableFromJson(
  Object? stopFinderGetCoordOutputFormat, [
  enums.StopFinderGetCoordOutputFormat? defaultValue,
]) {
  if (stopFinderGetCoordOutputFormat == null) {
    return null;
  }
  return enums.StopFinderGetCoordOutputFormat.values
          .firstWhereOrNull((e) => e.value == stopFinderGetCoordOutputFormat) ??
      defaultValue;
}

String stopFinderGetCoordOutputFormatExplodedListToJson(
    List<enums.StopFinderGetCoordOutputFormat>?
        stopFinderGetCoordOutputFormat) {
  return stopFinderGetCoordOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> stopFinderGetCoordOutputFormatListToJson(
    List<enums.StopFinderGetCoordOutputFormat>?
        stopFinderGetCoordOutputFormat) {
  if (stopFinderGetCoordOutputFormat == null) {
    return [];
  }

  return stopFinderGetCoordOutputFormat.map((e) => e.value!).toList();
}

List<enums.StopFinderGetCoordOutputFormat>
    stopFinderGetCoordOutputFormatListFromJson(
  List? stopFinderGetCoordOutputFormat, [
  List<enums.StopFinderGetCoordOutputFormat>? defaultValue,
]) {
  if (stopFinderGetCoordOutputFormat == null) {
    return defaultValue ?? [];
  }

  return stopFinderGetCoordOutputFormat
      .map((e) => stopFinderGetCoordOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.StopFinderGetCoordOutputFormat>?
    stopFinderGetCoordOutputFormatNullableListFromJson(
  List? stopFinderGetCoordOutputFormat, [
  List<enums.StopFinderGetCoordOutputFormat>? defaultValue,
]) {
  if (stopFinderGetCoordOutputFormat == null) {
    return defaultValue;
  }

  return stopFinderGetCoordOutputFormat
      .map((e) => stopFinderGetCoordOutputFormatFromJson(e.toString()))
      .toList();
}

String? stopFinderGetTfNSWSFNullableToJson(
    enums.StopFinderGetTfNSWSF? stopFinderGetTfNSWSF) {
  return stopFinderGetTfNSWSF?.value;
}

String? stopFinderGetTfNSWSFToJson(
    enums.StopFinderGetTfNSWSF stopFinderGetTfNSWSF) {
  return stopFinderGetTfNSWSF.value;
}

enums.StopFinderGetTfNSWSF stopFinderGetTfNSWSFFromJson(
  Object? stopFinderGetTfNSWSF, [
  enums.StopFinderGetTfNSWSF? defaultValue,
]) {
  return enums.StopFinderGetTfNSWSF.values
          .firstWhereOrNull((e) => e.value == stopFinderGetTfNSWSF) ??
      defaultValue ??
      enums.StopFinderGetTfNSWSF.swaggerGeneratedUnknown;
}

enums.StopFinderGetTfNSWSF? stopFinderGetTfNSWSFNullableFromJson(
  Object? stopFinderGetTfNSWSF, [
  enums.StopFinderGetTfNSWSF? defaultValue,
]) {
  if (stopFinderGetTfNSWSF == null) {
    return null;
  }
  return enums.StopFinderGetTfNSWSF.values
          .firstWhereOrNull((e) => e.value == stopFinderGetTfNSWSF) ??
      defaultValue;
}

String stopFinderGetTfNSWSFExplodedListToJson(
    List<enums.StopFinderGetTfNSWSF>? stopFinderGetTfNSWSF) {
  return stopFinderGetTfNSWSF?.map((e) => e.value!).join(',') ?? '';
}

List<String> stopFinderGetTfNSWSFListToJson(
    List<enums.StopFinderGetTfNSWSF>? stopFinderGetTfNSWSF) {
  if (stopFinderGetTfNSWSF == null) {
    return [];
  }

  return stopFinderGetTfNSWSF.map((e) => e.value!).toList();
}

List<enums.StopFinderGetTfNSWSF> stopFinderGetTfNSWSFListFromJson(
  List? stopFinderGetTfNSWSF, [
  List<enums.StopFinderGetTfNSWSF>? defaultValue,
]) {
  if (stopFinderGetTfNSWSF == null) {
    return defaultValue ?? [];
  }

  return stopFinderGetTfNSWSF
      .map((e) => stopFinderGetTfNSWSFFromJson(e.toString()))
      .toList();
}

List<enums.StopFinderGetTfNSWSF>? stopFinderGetTfNSWSFNullableListFromJson(
  List? stopFinderGetTfNSWSF, [
  List<enums.StopFinderGetTfNSWSF>? defaultValue,
]) {
  if (stopFinderGetTfNSWSF == null) {
    return defaultValue;
  }

  return stopFinderGetTfNSWSF
      .map((e) => stopFinderGetTfNSWSFFromJson(e.toString()))
      .toList();
}

String? tripGetOutputFormatNullableToJson(
    enums.TripGetOutputFormat? tripGetOutputFormat) {
  return tripGetOutputFormat?.value;
}

String? tripGetOutputFormatToJson(
    enums.TripGetOutputFormat tripGetOutputFormat) {
  return tripGetOutputFormat.value;
}

enums.TripGetOutputFormat tripGetOutputFormatFromJson(
  Object? tripGetOutputFormat, [
  enums.TripGetOutputFormat? defaultValue,
]) {
  return enums.TripGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == tripGetOutputFormat) ??
      defaultValue ??
      enums.TripGetOutputFormat.swaggerGeneratedUnknown;
}

enums.TripGetOutputFormat? tripGetOutputFormatNullableFromJson(
  Object? tripGetOutputFormat, [
  enums.TripGetOutputFormat? defaultValue,
]) {
  if (tripGetOutputFormat == null) {
    return null;
  }
  return enums.TripGetOutputFormat.values
          .firstWhereOrNull((e) => e.value == tripGetOutputFormat) ??
      defaultValue;
}

String tripGetOutputFormatExplodedListToJson(
    List<enums.TripGetOutputFormat>? tripGetOutputFormat) {
  return tripGetOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetOutputFormatListToJson(
    List<enums.TripGetOutputFormat>? tripGetOutputFormat) {
  if (tripGetOutputFormat == null) {
    return [];
  }

  return tripGetOutputFormat.map((e) => e.value!).toList();
}

List<enums.TripGetOutputFormat> tripGetOutputFormatListFromJson(
  List? tripGetOutputFormat, [
  List<enums.TripGetOutputFormat>? defaultValue,
]) {
  if (tripGetOutputFormat == null) {
    return defaultValue ?? [];
  }

  return tripGetOutputFormat
      .map((e) => tripGetOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.TripGetOutputFormat>? tripGetOutputFormatNullableListFromJson(
  List? tripGetOutputFormat, [
  List<enums.TripGetOutputFormat>? defaultValue,
]) {
  if (tripGetOutputFormat == null) {
    return defaultValue;
  }

  return tripGetOutputFormat
      .map((e) => tripGetOutputFormatFromJson(e.toString()))
      .toList();
}

String? tripGetCoordOutputFormatNullableToJson(
    enums.TripGetCoordOutputFormat? tripGetCoordOutputFormat) {
  return tripGetCoordOutputFormat?.value;
}

String? tripGetCoordOutputFormatToJson(
    enums.TripGetCoordOutputFormat tripGetCoordOutputFormat) {
  return tripGetCoordOutputFormat.value;
}

enums.TripGetCoordOutputFormat tripGetCoordOutputFormatFromJson(
  Object? tripGetCoordOutputFormat, [
  enums.TripGetCoordOutputFormat? defaultValue,
]) {
  return enums.TripGetCoordOutputFormat.values
          .firstWhereOrNull((e) => e.value == tripGetCoordOutputFormat) ??
      defaultValue ??
      enums.TripGetCoordOutputFormat.swaggerGeneratedUnknown;
}

enums.TripGetCoordOutputFormat? tripGetCoordOutputFormatNullableFromJson(
  Object? tripGetCoordOutputFormat, [
  enums.TripGetCoordOutputFormat? defaultValue,
]) {
  if (tripGetCoordOutputFormat == null) {
    return null;
  }
  return enums.TripGetCoordOutputFormat.values
          .firstWhereOrNull((e) => e.value == tripGetCoordOutputFormat) ??
      defaultValue;
}

String tripGetCoordOutputFormatExplodedListToJson(
    List<enums.TripGetCoordOutputFormat>? tripGetCoordOutputFormat) {
  return tripGetCoordOutputFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetCoordOutputFormatListToJson(
    List<enums.TripGetCoordOutputFormat>? tripGetCoordOutputFormat) {
  if (tripGetCoordOutputFormat == null) {
    return [];
  }

  return tripGetCoordOutputFormat.map((e) => e.value!).toList();
}

List<enums.TripGetCoordOutputFormat> tripGetCoordOutputFormatListFromJson(
  List? tripGetCoordOutputFormat, [
  List<enums.TripGetCoordOutputFormat>? defaultValue,
]) {
  if (tripGetCoordOutputFormat == null) {
    return defaultValue ?? [];
  }

  return tripGetCoordOutputFormat
      .map((e) => tripGetCoordOutputFormatFromJson(e.toString()))
      .toList();
}

List<enums.TripGetCoordOutputFormat>?
    tripGetCoordOutputFormatNullableListFromJson(
  List? tripGetCoordOutputFormat, [
  List<enums.TripGetCoordOutputFormat>? defaultValue,
]) {
  if (tripGetCoordOutputFormat == null) {
    return defaultValue;
  }

  return tripGetCoordOutputFormat
      .map((e) => tripGetCoordOutputFormatFromJson(e.toString()))
      .toList();
}

String? tripGetDepArrMacroNullableToJson(
    enums.TripGetDepArrMacro? tripGetDepArrMacro) {
  return tripGetDepArrMacro?.value;
}

String? tripGetDepArrMacroToJson(enums.TripGetDepArrMacro tripGetDepArrMacro) {
  return tripGetDepArrMacro.value;
}

enums.TripGetDepArrMacro tripGetDepArrMacroFromJson(
  Object? tripGetDepArrMacro, [
  enums.TripGetDepArrMacro? defaultValue,
]) {
  return enums.TripGetDepArrMacro.values
          .firstWhereOrNull((e) => e.value == tripGetDepArrMacro) ??
      defaultValue ??
      enums.TripGetDepArrMacro.swaggerGeneratedUnknown;
}

enums.TripGetDepArrMacro? tripGetDepArrMacroNullableFromJson(
  Object? tripGetDepArrMacro, [
  enums.TripGetDepArrMacro? defaultValue,
]) {
  if (tripGetDepArrMacro == null) {
    return null;
  }
  return enums.TripGetDepArrMacro.values
          .firstWhereOrNull((e) => e.value == tripGetDepArrMacro) ??
      defaultValue;
}

String tripGetDepArrMacroExplodedListToJson(
    List<enums.TripGetDepArrMacro>? tripGetDepArrMacro) {
  return tripGetDepArrMacro?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetDepArrMacroListToJson(
    List<enums.TripGetDepArrMacro>? tripGetDepArrMacro) {
  if (tripGetDepArrMacro == null) {
    return [];
  }

  return tripGetDepArrMacro.map((e) => e.value!).toList();
}

List<enums.TripGetDepArrMacro> tripGetDepArrMacroListFromJson(
  List? tripGetDepArrMacro, [
  List<enums.TripGetDepArrMacro>? defaultValue,
]) {
  if (tripGetDepArrMacro == null) {
    return defaultValue ?? [];
  }

  return tripGetDepArrMacro
      .map((e) => tripGetDepArrMacroFromJson(e.toString()))
      .toList();
}

List<enums.TripGetDepArrMacro>? tripGetDepArrMacroNullableListFromJson(
  List? tripGetDepArrMacro, [
  List<enums.TripGetDepArrMacro>? defaultValue,
]) {
  if (tripGetDepArrMacro == null) {
    return defaultValue;
  }

  return tripGetDepArrMacro
      .map((e) => tripGetDepArrMacroFromJson(e.toString()))
      .toList();
}

String? tripGetTypeOriginNullableToJson(
    enums.TripGetTypeOrigin? tripGetTypeOrigin) {
  return tripGetTypeOrigin?.value;
}

String? tripGetTypeOriginToJson(enums.TripGetTypeOrigin tripGetTypeOrigin) {
  return tripGetTypeOrigin.value;
}

enums.TripGetTypeOrigin tripGetTypeOriginFromJson(
  Object? tripGetTypeOrigin, [
  enums.TripGetTypeOrigin? defaultValue,
]) {
  return enums.TripGetTypeOrigin.values
          .firstWhereOrNull((e) => e.value == tripGetTypeOrigin) ??
      defaultValue ??
      enums.TripGetTypeOrigin.swaggerGeneratedUnknown;
}

enums.TripGetTypeOrigin? tripGetTypeOriginNullableFromJson(
  Object? tripGetTypeOrigin, [
  enums.TripGetTypeOrigin? defaultValue,
]) {
  if (tripGetTypeOrigin == null) {
    return null;
  }
  return enums.TripGetTypeOrigin.values
          .firstWhereOrNull((e) => e.value == tripGetTypeOrigin) ??
      defaultValue;
}

String tripGetTypeOriginExplodedListToJson(
    List<enums.TripGetTypeOrigin>? tripGetTypeOrigin) {
  return tripGetTypeOrigin?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetTypeOriginListToJson(
    List<enums.TripGetTypeOrigin>? tripGetTypeOrigin) {
  if (tripGetTypeOrigin == null) {
    return [];
  }

  return tripGetTypeOrigin.map((e) => e.value!).toList();
}

List<enums.TripGetTypeOrigin> tripGetTypeOriginListFromJson(
  List? tripGetTypeOrigin, [
  List<enums.TripGetTypeOrigin>? defaultValue,
]) {
  if (tripGetTypeOrigin == null) {
    return defaultValue ?? [];
  }

  return tripGetTypeOrigin
      .map((e) => tripGetTypeOriginFromJson(e.toString()))
      .toList();
}

List<enums.TripGetTypeOrigin>? tripGetTypeOriginNullableListFromJson(
  List? tripGetTypeOrigin, [
  List<enums.TripGetTypeOrigin>? defaultValue,
]) {
  if (tripGetTypeOrigin == null) {
    return defaultValue;
  }

  return tripGetTypeOrigin
      .map((e) => tripGetTypeOriginFromJson(e.toString()))
      .toList();
}

String? tripGetTypeDestinationNullableToJson(
    enums.TripGetTypeDestination? tripGetTypeDestination) {
  return tripGetTypeDestination?.value;
}

String? tripGetTypeDestinationToJson(
    enums.TripGetTypeDestination tripGetTypeDestination) {
  return tripGetTypeDestination.value;
}

enums.TripGetTypeDestination tripGetTypeDestinationFromJson(
  Object? tripGetTypeDestination, [
  enums.TripGetTypeDestination? defaultValue,
]) {
  return enums.TripGetTypeDestination.values
          .firstWhereOrNull((e) => e.value == tripGetTypeDestination) ??
      defaultValue ??
      enums.TripGetTypeDestination.swaggerGeneratedUnknown;
}

enums.TripGetTypeDestination? tripGetTypeDestinationNullableFromJson(
  Object? tripGetTypeDestination, [
  enums.TripGetTypeDestination? defaultValue,
]) {
  if (tripGetTypeDestination == null) {
    return null;
  }
  return enums.TripGetTypeDestination.values
          .firstWhereOrNull((e) => e.value == tripGetTypeDestination) ??
      defaultValue;
}

String tripGetTypeDestinationExplodedListToJson(
    List<enums.TripGetTypeDestination>? tripGetTypeDestination) {
  return tripGetTypeDestination?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetTypeDestinationListToJson(
    List<enums.TripGetTypeDestination>? tripGetTypeDestination) {
  if (tripGetTypeDestination == null) {
    return [];
  }

  return tripGetTypeDestination.map((e) => e.value!).toList();
}

List<enums.TripGetTypeDestination> tripGetTypeDestinationListFromJson(
  List? tripGetTypeDestination, [
  List<enums.TripGetTypeDestination>? defaultValue,
]) {
  if (tripGetTypeDestination == null) {
    return defaultValue ?? [];
  }

  return tripGetTypeDestination
      .map((e) => tripGetTypeDestinationFromJson(e.toString()))
      .toList();
}

List<enums.TripGetTypeDestination>? tripGetTypeDestinationNullableListFromJson(
  List? tripGetTypeDestination, [
  List<enums.TripGetTypeDestination>? defaultValue,
]) {
  if (tripGetTypeDestination == null) {
    return defaultValue;
  }

  return tripGetTypeDestination
      .map((e) => tripGetTypeDestinationFromJson(e.toString()))
      .toList();
}

String? tripGetWheelchairNullableToJson(
    enums.TripGetWheelchair? tripGetWheelchair) {
  return tripGetWheelchair?.value;
}

String? tripGetWheelchairToJson(enums.TripGetWheelchair tripGetWheelchair) {
  return tripGetWheelchair.value;
}

enums.TripGetWheelchair tripGetWheelchairFromJson(
  Object? tripGetWheelchair, [
  enums.TripGetWheelchair? defaultValue,
]) {
  return enums.TripGetWheelchair.values
          .firstWhereOrNull((e) => e.value == tripGetWheelchair) ??
      defaultValue ??
      enums.TripGetWheelchair.swaggerGeneratedUnknown;
}

enums.TripGetWheelchair? tripGetWheelchairNullableFromJson(
  Object? tripGetWheelchair, [
  enums.TripGetWheelchair? defaultValue,
]) {
  if (tripGetWheelchair == null) {
    return null;
  }
  return enums.TripGetWheelchair.values
          .firstWhereOrNull((e) => e.value == tripGetWheelchair) ??
      defaultValue;
}

String tripGetWheelchairExplodedListToJson(
    List<enums.TripGetWheelchair>? tripGetWheelchair) {
  return tripGetWheelchair?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetWheelchairListToJson(
    List<enums.TripGetWheelchair>? tripGetWheelchair) {
  if (tripGetWheelchair == null) {
    return [];
  }

  return tripGetWheelchair.map((e) => e.value!).toList();
}

List<enums.TripGetWheelchair> tripGetWheelchairListFromJson(
  List? tripGetWheelchair, [
  List<enums.TripGetWheelchair>? defaultValue,
]) {
  if (tripGetWheelchair == null) {
    return defaultValue ?? [];
  }

  return tripGetWheelchair
      .map((e) => tripGetWheelchairFromJson(e.toString()))
      .toList();
}

List<enums.TripGetWheelchair>? tripGetWheelchairNullableListFromJson(
  List? tripGetWheelchair, [
  List<enums.TripGetWheelchair>? defaultValue,
]) {
  if (tripGetWheelchair == null) {
    return defaultValue;
  }

  return tripGetWheelchair
      .map((e) => tripGetWheelchairFromJson(e.toString()))
      .toList();
}

String? tripGetExcludedMeansNullableToJson(
    enums.TripGetExcludedMeans? tripGetExcludedMeans) {
  return tripGetExcludedMeans?.value;
}

String? tripGetExcludedMeansToJson(
    enums.TripGetExcludedMeans tripGetExcludedMeans) {
  return tripGetExcludedMeans.value;
}

enums.TripGetExcludedMeans tripGetExcludedMeansFromJson(
  Object? tripGetExcludedMeans, [
  enums.TripGetExcludedMeans? defaultValue,
]) {
  return enums.TripGetExcludedMeans.values
          .firstWhereOrNull((e) => e.value == tripGetExcludedMeans) ??
      defaultValue ??
      enums.TripGetExcludedMeans.swaggerGeneratedUnknown;
}

enums.TripGetExcludedMeans? tripGetExcludedMeansNullableFromJson(
  Object? tripGetExcludedMeans, [
  enums.TripGetExcludedMeans? defaultValue,
]) {
  if (tripGetExcludedMeans == null) {
    return null;
  }
  return enums.TripGetExcludedMeans.values
          .firstWhereOrNull((e) => e.value == tripGetExcludedMeans) ??
      defaultValue;
}

String tripGetExcludedMeansExplodedListToJson(
    List<enums.TripGetExcludedMeans>? tripGetExcludedMeans) {
  return tripGetExcludedMeans?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetExcludedMeansListToJson(
    List<enums.TripGetExcludedMeans>? tripGetExcludedMeans) {
  if (tripGetExcludedMeans == null) {
    return [];
  }

  return tripGetExcludedMeans.map((e) => e.value!).toList();
}

List<enums.TripGetExcludedMeans> tripGetExcludedMeansListFromJson(
  List? tripGetExcludedMeans, [
  List<enums.TripGetExcludedMeans>? defaultValue,
]) {
  if (tripGetExcludedMeans == null) {
    return defaultValue ?? [];
  }

  return tripGetExcludedMeans
      .map((e) => tripGetExcludedMeansFromJson(e.toString()))
      .toList();
}

List<enums.TripGetExcludedMeans>? tripGetExcludedMeansNullableListFromJson(
  List? tripGetExcludedMeans, [
  List<enums.TripGetExcludedMeans>? defaultValue,
]) {
  if (tripGetExcludedMeans == null) {
    return defaultValue;
  }

  return tripGetExcludedMeans
      .map((e) => tripGetExcludedMeansFromJson(e.toString()))
      .toList();
}

String? tripGetExclMOT1NullableToJson(enums.TripGetExclMOT1? tripGetExclMOT1) {
  return tripGetExclMOT1?.value;
}

String? tripGetExclMOT1ToJson(enums.TripGetExclMOT1 tripGetExclMOT1) {
  return tripGetExclMOT1.value;
}

enums.TripGetExclMOT1 tripGetExclMOT1FromJson(
  Object? tripGetExclMOT1, [
  enums.TripGetExclMOT1? defaultValue,
]) {
  return enums.TripGetExclMOT1.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT1) ??
      defaultValue ??
      enums.TripGetExclMOT1.swaggerGeneratedUnknown;
}

enums.TripGetExclMOT1? tripGetExclMOT1NullableFromJson(
  Object? tripGetExclMOT1, [
  enums.TripGetExclMOT1? defaultValue,
]) {
  if (tripGetExclMOT1 == null) {
    return null;
  }
  return enums.TripGetExclMOT1.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT1) ??
      defaultValue;
}

String tripGetExclMOT1ExplodedListToJson(
    List<enums.TripGetExclMOT1>? tripGetExclMOT1) {
  return tripGetExclMOT1?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetExclMOT1ListToJson(
    List<enums.TripGetExclMOT1>? tripGetExclMOT1) {
  if (tripGetExclMOT1 == null) {
    return [];
  }

  return tripGetExclMOT1.map((e) => e.value!).toList();
}

List<enums.TripGetExclMOT1> tripGetExclMOT1ListFromJson(
  List? tripGetExclMOT1, [
  List<enums.TripGetExclMOT1>? defaultValue,
]) {
  if (tripGetExclMOT1 == null) {
    return defaultValue ?? [];
  }

  return tripGetExclMOT1
      .map((e) => tripGetExclMOT1FromJson(e.toString()))
      .toList();
}

List<enums.TripGetExclMOT1>? tripGetExclMOT1NullableListFromJson(
  List? tripGetExclMOT1, [
  List<enums.TripGetExclMOT1>? defaultValue,
]) {
  if (tripGetExclMOT1 == null) {
    return defaultValue;
  }

  return tripGetExclMOT1
      .map((e) => tripGetExclMOT1FromJson(e.toString()))
      .toList();
}

String? tripGetExclMOT2NullableToJson(enums.TripGetExclMOT2? tripGetExclMOT2) {
  return tripGetExclMOT2?.value;
}

String? tripGetExclMOT2ToJson(enums.TripGetExclMOT2 tripGetExclMOT2) {
  return tripGetExclMOT2.value;
}

enums.TripGetExclMOT2 tripGetExclMOT2FromJson(
  Object? tripGetExclMOT2, [
  enums.TripGetExclMOT2? defaultValue,
]) {
  return enums.TripGetExclMOT2.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT2) ??
      defaultValue ??
      enums.TripGetExclMOT2.swaggerGeneratedUnknown;
}

enums.TripGetExclMOT2? tripGetExclMOT2NullableFromJson(
  Object? tripGetExclMOT2, [
  enums.TripGetExclMOT2? defaultValue,
]) {
  if (tripGetExclMOT2 == null) {
    return null;
  }
  return enums.TripGetExclMOT2.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT2) ??
      defaultValue;
}

String tripGetExclMOT2ExplodedListToJson(
    List<enums.TripGetExclMOT2>? tripGetExclMOT2) {
  return tripGetExclMOT2?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetExclMOT2ListToJson(
    List<enums.TripGetExclMOT2>? tripGetExclMOT2) {
  if (tripGetExclMOT2 == null) {
    return [];
  }

  return tripGetExclMOT2.map((e) => e.value!).toList();
}

List<enums.TripGetExclMOT2> tripGetExclMOT2ListFromJson(
  List? tripGetExclMOT2, [
  List<enums.TripGetExclMOT2>? defaultValue,
]) {
  if (tripGetExclMOT2 == null) {
    return defaultValue ?? [];
  }

  return tripGetExclMOT2
      .map((e) => tripGetExclMOT2FromJson(e.toString()))
      .toList();
}

List<enums.TripGetExclMOT2>? tripGetExclMOT2NullableListFromJson(
  List? tripGetExclMOT2, [
  List<enums.TripGetExclMOT2>? defaultValue,
]) {
  if (tripGetExclMOT2 == null) {
    return defaultValue;
  }

  return tripGetExclMOT2
      .map((e) => tripGetExclMOT2FromJson(e.toString()))
      .toList();
}

String? tripGetExclMOT4NullableToJson(enums.TripGetExclMOT4? tripGetExclMOT4) {
  return tripGetExclMOT4?.value;
}

String? tripGetExclMOT4ToJson(enums.TripGetExclMOT4 tripGetExclMOT4) {
  return tripGetExclMOT4.value;
}

enums.TripGetExclMOT4 tripGetExclMOT4FromJson(
  Object? tripGetExclMOT4, [
  enums.TripGetExclMOT4? defaultValue,
]) {
  return enums.TripGetExclMOT4.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT4) ??
      defaultValue ??
      enums.TripGetExclMOT4.swaggerGeneratedUnknown;
}

enums.TripGetExclMOT4? tripGetExclMOT4NullableFromJson(
  Object? tripGetExclMOT4, [
  enums.TripGetExclMOT4? defaultValue,
]) {
  if (tripGetExclMOT4 == null) {
    return null;
  }
  return enums.TripGetExclMOT4.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT4) ??
      defaultValue;
}

String tripGetExclMOT4ExplodedListToJson(
    List<enums.TripGetExclMOT4>? tripGetExclMOT4) {
  return tripGetExclMOT4?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetExclMOT4ListToJson(
    List<enums.TripGetExclMOT4>? tripGetExclMOT4) {
  if (tripGetExclMOT4 == null) {
    return [];
  }

  return tripGetExclMOT4.map((e) => e.value!).toList();
}

List<enums.TripGetExclMOT4> tripGetExclMOT4ListFromJson(
  List? tripGetExclMOT4, [
  List<enums.TripGetExclMOT4>? defaultValue,
]) {
  if (tripGetExclMOT4 == null) {
    return defaultValue ?? [];
  }

  return tripGetExclMOT4
      .map((e) => tripGetExclMOT4FromJson(e.toString()))
      .toList();
}

List<enums.TripGetExclMOT4>? tripGetExclMOT4NullableListFromJson(
  List? tripGetExclMOT4, [
  List<enums.TripGetExclMOT4>? defaultValue,
]) {
  if (tripGetExclMOT4 == null) {
    return defaultValue;
  }

  return tripGetExclMOT4
      .map((e) => tripGetExclMOT4FromJson(e.toString()))
      .toList();
}

String? tripGetExclMOT5NullableToJson(enums.TripGetExclMOT5? tripGetExclMOT5) {
  return tripGetExclMOT5?.value;
}

String? tripGetExclMOT5ToJson(enums.TripGetExclMOT5 tripGetExclMOT5) {
  return tripGetExclMOT5.value;
}

enums.TripGetExclMOT5 tripGetExclMOT5FromJson(
  Object? tripGetExclMOT5, [
  enums.TripGetExclMOT5? defaultValue,
]) {
  return enums.TripGetExclMOT5.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT5) ??
      defaultValue ??
      enums.TripGetExclMOT5.swaggerGeneratedUnknown;
}

enums.TripGetExclMOT5? tripGetExclMOT5NullableFromJson(
  Object? tripGetExclMOT5, [
  enums.TripGetExclMOT5? defaultValue,
]) {
  if (tripGetExclMOT5 == null) {
    return null;
  }
  return enums.TripGetExclMOT5.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT5) ??
      defaultValue;
}

String tripGetExclMOT5ExplodedListToJson(
    List<enums.TripGetExclMOT5>? tripGetExclMOT5) {
  return tripGetExclMOT5?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetExclMOT5ListToJson(
    List<enums.TripGetExclMOT5>? tripGetExclMOT5) {
  if (tripGetExclMOT5 == null) {
    return [];
  }

  return tripGetExclMOT5.map((e) => e.value!).toList();
}

List<enums.TripGetExclMOT5> tripGetExclMOT5ListFromJson(
  List? tripGetExclMOT5, [
  List<enums.TripGetExclMOT5>? defaultValue,
]) {
  if (tripGetExclMOT5 == null) {
    return defaultValue ?? [];
  }

  return tripGetExclMOT5
      .map((e) => tripGetExclMOT5FromJson(e.toString()))
      .toList();
}

List<enums.TripGetExclMOT5>? tripGetExclMOT5NullableListFromJson(
  List? tripGetExclMOT5, [
  List<enums.TripGetExclMOT5>? defaultValue,
]) {
  if (tripGetExclMOT5 == null) {
    return defaultValue;
  }

  return tripGetExclMOT5
      .map((e) => tripGetExclMOT5FromJson(e.toString()))
      .toList();
}

String? tripGetExclMOT7NullableToJson(enums.TripGetExclMOT7? tripGetExclMOT7) {
  return tripGetExclMOT7?.value;
}

String? tripGetExclMOT7ToJson(enums.TripGetExclMOT7 tripGetExclMOT7) {
  return tripGetExclMOT7.value;
}

enums.TripGetExclMOT7 tripGetExclMOT7FromJson(
  Object? tripGetExclMOT7, [
  enums.TripGetExclMOT7? defaultValue,
]) {
  return enums.TripGetExclMOT7.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT7) ??
      defaultValue ??
      enums.TripGetExclMOT7.swaggerGeneratedUnknown;
}

enums.TripGetExclMOT7? tripGetExclMOT7NullableFromJson(
  Object? tripGetExclMOT7, [
  enums.TripGetExclMOT7? defaultValue,
]) {
  if (tripGetExclMOT7 == null) {
    return null;
  }
  return enums.TripGetExclMOT7.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT7) ??
      defaultValue;
}

String tripGetExclMOT7ExplodedListToJson(
    List<enums.TripGetExclMOT7>? tripGetExclMOT7) {
  return tripGetExclMOT7?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetExclMOT7ListToJson(
    List<enums.TripGetExclMOT7>? tripGetExclMOT7) {
  if (tripGetExclMOT7 == null) {
    return [];
  }

  return tripGetExclMOT7.map((e) => e.value!).toList();
}

List<enums.TripGetExclMOT7> tripGetExclMOT7ListFromJson(
  List? tripGetExclMOT7, [
  List<enums.TripGetExclMOT7>? defaultValue,
]) {
  if (tripGetExclMOT7 == null) {
    return defaultValue ?? [];
  }

  return tripGetExclMOT7
      .map((e) => tripGetExclMOT7FromJson(e.toString()))
      .toList();
}

List<enums.TripGetExclMOT7>? tripGetExclMOT7NullableListFromJson(
  List? tripGetExclMOT7, [
  List<enums.TripGetExclMOT7>? defaultValue,
]) {
  if (tripGetExclMOT7 == null) {
    return defaultValue;
  }

  return tripGetExclMOT7
      .map((e) => tripGetExclMOT7FromJson(e.toString()))
      .toList();
}

String? tripGetExclMOT9NullableToJson(enums.TripGetExclMOT9? tripGetExclMOT9) {
  return tripGetExclMOT9?.value;
}

String? tripGetExclMOT9ToJson(enums.TripGetExclMOT9 tripGetExclMOT9) {
  return tripGetExclMOT9.value;
}

enums.TripGetExclMOT9 tripGetExclMOT9FromJson(
  Object? tripGetExclMOT9, [
  enums.TripGetExclMOT9? defaultValue,
]) {
  return enums.TripGetExclMOT9.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT9) ??
      defaultValue ??
      enums.TripGetExclMOT9.swaggerGeneratedUnknown;
}

enums.TripGetExclMOT9? tripGetExclMOT9NullableFromJson(
  Object? tripGetExclMOT9, [
  enums.TripGetExclMOT9? defaultValue,
]) {
  if (tripGetExclMOT9 == null) {
    return null;
  }
  return enums.TripGetExclMOT9.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT9) ??
      defaultValue;
}

String tripGetExclMOT9ExplodedListToJson(
    List<enums.TripGetExclMOT9>? tripGetExclMOT9) {
  return tripGetExclMOT9?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetExclMOT9ListToJson(
    List<enums.TripGetExclMOT9>? tripGetExclMOT9) {
  if (tripGetExclMOT9 == null) {
    return [];
  }

  return tripGetExclMOT9.map((e) => e.value!).toList();
}

List<enums.TripGetExclMOT9> tripGetExclMOT9ListFromJson(
  List? tripGetExclMOT9, [
  List<enums.TripGetExclMOT9>? defaultValue,
]) {
  if (tripGetExclMOT9 == null) {
    return defaultValue ?? [];
  }

  return tripGetExclMOT9
      .map((e) => tripGetExclMOT9FromJson(e.toString()))
      .toList();
}

List<enums.TripGetExclMOT9>? tripGetExclMOT9NullableListFromJson(
  List? tripGetExclMOT9, [
  List<enums.TripGetExclMOT9>? defaultValue,
]) {
  if (tripGetExclMOT9 == null) {
    return defaultValue;
  }

  return tripGetExclMOT9
      .map((e) => tripGetExclMOT9FromJson(e.toString()))
      .toList();
}

String? tripGetExclMOT11NullableToJson(
    enums.TripGetExclMOT11? tripGetExclMOT11) {
  return tripGetExclMOT11?.value;
}

String? tripGetExclMOT11ToJson(enums.TripGetExclMOT11 tripGetExclMOT11) {
  return tripGetExclMOT11.value;
}

enums.TripGetExclMOT11 tripGetExclMOT11FromJson(
  Object? tripGetExclMOT11, [
  enums.TripGetExclMOT11? defaultValue,
]) {
  return enums.TripGetExclMOT11.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT11) ??
      defaultValue ??
      enums.TripGetExclMOT11.swaggerGeneratedUnknown;
}

enums.TripGetExclMOT11? tripGetExclMOT11NullableFromJson(
  Object? tripGetExclMOT11, [
  enums.TripGetExclMOT11? defaultValue,
]) {
  if (tripGetExclMOT11 == null) {
    return null;
  }
  return enums.TripGetExclMOT11.values
          .firstWhereOrNull((e) => e.value == tripGetExclMOT11) ??
      defaultValue;
}

String tripGetExclMOT11ExplodedListToJson(
    List<enums.TripGetExclMOT11>? tripGetExclMOT11) {
  return tripGetExclMOT11?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetExclMOT11ListToJson(
    List<enums.TripGetExclMOT11>? tripGetExclMOT11) {
  if (tripGetExclMOT11 == null) {
    return [];
  }

  return tripGetExclMOT11.map((e) => e.value!).toList();
}

List<enums.TripGetExclMOT11> tripGetExclMOT11ListFromJson(
  List? tripGetExclMOT11, [
  List<enums.TripGetExclMOT11>? defaultValue,
]) {
  if (tripGetExclMOT11 == null) {
    return defaultValue ?? [];
  }

  return tripGetExclMOT11
      .map((e) => tripGetExclMOT11FromJson(e.toString()))
      .toList();
}

List<enums.TripGetExclMOT11>? tripGetExclMOT11NullableListFromJson(
  List? tripGetExclMOT11, [
  List<enums.TripGetExclMOT11>? defaultValue,
]) {
  if (tripGetExclMOT11 == null) {
    return defaultValue;
  }

  return tripGetExclMOT11
      .map((e) => tripGetExclMOT11FromJson(e.toString()))
      .toList();
}

String? tripGetTfNSWTRNullableToJson(enums.TripGetTfNSWTR? tripGetTfNSWTR) {
  return tripGetTfNSWTR?.value;
}

String? tripGetTfNSWTRToJson(enums.TripGetTfNSWTR tripGetTfNSWTR) {
  return tripGetTfNSWTR.value;
}

enums.TripGetTfNSWTR tripGetTfNSWTRFromJson(
  Object? tripGetTfNSWTR, [
  enums.TripGetTfNSWTR? defaultValue,
]) {
  return enums.TripGetTfNSWTR.values
          .firstWhereOrNull((e) => e.value == tripGetTfNSWTR) ??
      defaultValue ??
      enums.TripGetTfNSWTR.swaggerGeneratedUnknown;
}

enums.TripGetTfNSWTR? tripGetTfNSWTRNullableFromJson(
  Object? tripGetTfNSWTR, [
  enums.TripGetTfNSWTR? defaultValue,
]) {
  if (tripGetTfNSWTR == null) {
    return null;
  }
  return enums.TripGetTfNSWTR.values
          .firstWhereOrNull((e) => e.value == tripGetTfNSWTR) ??
      defaultValue;
}

String tripGetTfNSWTRExplodedListToJson(
    List<enums.TripGetTfNSWTR>? tripGetTfNSWTR) {
  return tripGetTfNSWTR?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetTfNSWTRListToJson(
    List<enums.TripGetTfNSWTR>? tripGetTfNSWTR) {
  if (tripGetTfNSWTR == null) {
    return [];
  }

  return tripGetTfNSWTR.map((e) => e.value!).toList();
}

List<enums.TripGetTfNSWTR> tripGetTfNSWTRListFromJson(
  List? tripGetTfNSWTR, [
  List<enums.TripGetTfNSWTR>? defaultValue,
]) {
  if (tripGetTfNSWTR == null) {
    return defaultValue ?? [];
  }

  return tripGetTfNSWTR
      .map((e) => tripGetTfNSWTRFromJson(e.toString()))
      .toList();
}

List<enums.TripGetTfNSWTR>? tripGetTfNSWTRNullableListFromJson(
  List? tripGetTfNSWTR, [
  List<enums.TripGetTfNSWTR>? defaultValue,
]) {
  if (tripGetTfNSWTR == null) {
    return defaultValue;
  }

  return tripGetTfNSWTR
      .map((e) => tripGetTfNSWTRFromJson(e.toString()))
      .toList();
}

String? tripGetBikeProfSpeedNullableToJson(
    enums.TripGetBikeProfSpeed? tripGetBikeProfSpeed) {
  return tripGetBikeProfSpeed?.value;
}

String? tripGetBikeProfSpeedToJson(
    enums.TripGetBikeProfSpeed tripGetBikeProfSpeed) {
  return tripGetBikeProfSpeed.value;
}

enums.TripGetBikeProfSpeed tripGetBikeProfSpeedFromJson(
  Object? tripGetBikeProfSpeed, [
  enums.TripGetBikeProfSpeed? defaultValue,
]) {
  return enums.TripGetBikeProfSpeed.values
          .firstWhereOrNull((e) => e.value == tripGetBikeProfSpeed) ??
      defaultValue ??
      enums.TripGetBikeProfSpeed.swaggerGeneratedUnknown;
}

enums.TripGetBikeProfSpeed? tripGetBikeProfSpeedNullableFromJson(
  Object? tripGetBikeProfSpeed, [
  enums.TripGetBikeProfSpeed? defaultValue,
]) {
  if (tripGetBikeProfSpeed == null) {
    return null;
  }
  return enums.TripGetBikeProfSpeed.values
          .firstWhereOrNull((e) => e.value == tripGetBikeProfSpeed) ??
      defaultValue;
}

String tripGetBikeProfSpeedExplodedListToJson(
    List<enums.TripGetBikeProfSpeed>? tripGetBikeProfSpeed) {
  return tripGetBikeProfSpeed?.map((e) => e.value!).join(',') ?? '';
}

List<String> tripGetBikeProfSpeedListToJson(
    List<enums.TripGetBikeProfSpeed>? tripGetBikeProfSpeed) {
  if (tripGetBikeProfSpeed == null) {
    return [];
  }

  return tripGetBikeProfSpeed.map((e) => e.value!).toList();
}

List<enums.TripGetBikeProfSpeed> tripGetBikeProfSpeedListFromJson(
  List? tripGetBikeProfSpeed, [
  List<enums.TripGetBikeProfSpeed>? defaultValue,
]) {
  if (tripGetBikeProfSpeed == null) {
    return defaultValue ?? [];
  }

  return tripGetBikeProfSpeed
      .map((e) => tripGetBikeProfSpeedFromJson(e.toString()))
      .toList();
}

List<enums.TripGetBikeProfSpeed>? tripGetBikeProfSpeedNullableListFromJson(
  List? tripGetBikeProfSpeed, [
  List<enums.TripGetBikeProfSpeed>? defaultValue,
]) {
  if (tripGetBikeProfSpeed == null) {
    return defaultValue;
  }

  return tripGetBikeProfSpeed
      .map((e) => tripGetBikeProfSpeedFromJson(e.toString()))
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
      chopper.Response response) async {
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
          body: DateTime.parse((response.body as String).replaceAll('"', ''))
              as ResultType);
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
        body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType);
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
