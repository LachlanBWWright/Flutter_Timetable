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

part 'realtime_timetables_v1.swagger.chopper.dart';
part 'realtime_timetables_v1.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class RealtimeTimetablesV1 extends ChopperService {
  static RealtimeTimetablesV1 create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$RealtimeTimetablesV1(client);
    }

    final newClient = ChopperClient(
        services: [_$RealtimeTimetablesV1()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ??
            Uri.parse('http://api.transport.nsw.gov.au/v1/gtfs/schedule'));
    return _$RealtimeTimetablesV1(newClient);
  }

  ///GTFS timetables, stops, and route shapes for Buses
  Future<chopper.Response<List<int>>> busesGet() {
    return _busesGet();
  }

  ///GTFS timetables, stops, and route shapes for Buses
  @Get(path: '/buses')
  Future<chopper.Response<List<int>>> _busesGet();

  ///GTFS timetables, stops, and route shapes for Transit Systems
  Future<chopper.Response<List<int>>> busesSBSC006Get() {
    return _busesSBSC006Get();
  }

  ///GTFS timetables, stops, and route shapes for Transit Systems
  @Get(path: '/buses/SBSC006')
  Future<chopper.Response<List<int>>> _busesSBSC006Get();

  ///GTFS timetables, stops, and route shapes for Busways R1
  Future<chopper.Response<List<int>>> busesGSBC001Get() {
    return _busesGSBC001Get();
  }

  ///GTFS timetables, stops, and route shapes for Busways R1
  @Get(path: '/buses/GSBC001')
  Future<chopper.Response<List<int>>> _busesGSBC001Get();

  ///GTFS timetables, stops, and route shapes for Transit Systems NSW SW
  Future<chopper.Response<List<int>>> busesGSBC002Get() {
    return _busesGSBC002Get();
  }

  ///GTFS timetables, stops, and route shapes for Transit Systems NSW SW
  @Get(path: '/buses/GSBC002')
  Future<chopper.Response<List<int>>> _busesGSBC002Get();

  ///GTFS timetables, stops, and route shapes for Transit Systems NSW
  Future<chopper.Response<List<int>>> busesGSBC003Get() {
    return _busesGSBC003Get();
  }

  ///GTFS timetables, stops, and route shapes for Transit Systems NSW
  @Get(path: '/buses/GSBC003')
  Future<chopper.Response<List<int>>> _busesGSBC003Get();

  ///GTFS timetables, stops, and route shapes for CDC NSW R4
  Future<chopper.Response<List<int>>> busesGSBC004Get() {
    return _busesGSBC004Get();
  }

  ///GTFS timetables, stops, and route shapes for CDC NSW R4
  @Get(path: '/buses/GSBC004')
  Future<chopper.Response<List<int>>> _busesGSBC004Get();

  ///GTFS timetables, stops, and route shapes for Busways North West
  Future<chopper.Response<List<int>>> busesGSBC007Get() {
    return _busesGSBC007Get();
  }

  ///GTFS timetables, stops, and route shapes for Busways North West
  @Get(path: '/buses/GSBC007')
  Future<chopper.Response<List<int>>> _busesGSBC007Get();

  ///GTFS timetables, stops, and route shapes for Keolis Downer Northern Beaches
  Future<chopper.Response<List<int>>> busesGSBC008Get() {
    return _busesGSBC008Get();
  }

  ///GTFS timetables, stops, and route shapes for Keolis Downer Northern Beaches
  @Get(path: '/buses/GSBC008')
  Future<chopper.Response<List<int>>> _busesGSBC008Get();

  ///GTFS timetables, stops, and route shapes for Transdev John Holland
  Future<chopper.Response<List<int>>> busesGSBC009Get() {
    return _busesGSBC009Get();
  }

  ///GTFS timetables, stops, and route shapes for Transdev John Holland
  @Get(path: '/buses/GSBC009')
  Future<chopper.Response<List<int>>> _busesGSBC009Get();

  ///GTFS timetables, stops, and route shapes for U-Go Mobility
  Future<chopper.Response<List<int>>> busesGSBC010Get() {
    return _busesGSBC010Get();
  }

  ///GTFS timetables, stops, and route shapes for U-Go Mobility
  @Get(path: '/buses/GSBC010')
  Future<chopper.Response<List<int>>> _busesGSBC010Get();

  ///GTFS timetables, stops, and route shapes for CDC NSW R14
  Future<chopper.Response<List<int>>> busesGSBC014Get() {
    return _busesGSBC014Get();
  }

  ///GTFS timetables, stops, and route shapes for CDC NSW R14
  @Get(path: '/buses/GSBC014')
  Future<chopper.Response<List<int>>> _busesGSBC014Get();

  ///GTFS timetables, stops, and route shapes for Rover Coaches
  Future<chopper.Response<List<int>>> busesOSMBSC001Get() {
    return _busesOSMBSC001Get();
  }

  ///GTFS timetables, stops, and route shapes for Rover Coaches
  @Get(path: '/buses/OSMBSC001')
  Future<chopper.Response<List<int>>> _busesOSMBSC001Get();

  ///GTFS timetables, stops, and route shapes for Hunter Valley Buses
  Future<chopper.Response<List<int>>> busesOSMBSC002Get() {
    return _busesOSMBSC002Get();
  }

  ///GTFS timetables, stops, and route shapes for Hunter Valley Buses
  @Get(path: '/buses/OSMBSC002')
  Future<chopper.Response<List<int>>> _busesOSMBSC002Get();

  ///GTFS timetables, stops, and route shapes for Port Stephens Coaches
  Future<chopper.Response<List<int>>> busesOSMBSC003Get() {
    return _busesOSMBSC003Get();
  }

  ///GTFS timetables, stops, and route shapes for Port Stephens Coaches
  @Get(path: '/buses/OSMBSC003')
  Future<chopper.Response<List<int>>> _busesOSMBSC003Get();

  ///GTFS timetables, stops, and route shapes for Hunter Valley Buses
  Future<chopper.Response<List<int>>> busesOSMBSC004Get() {
    return _busesOSMBSC004Get();
  }

  ///GTFS timetables, stops, and route shapes for Hunter Valley Buses
  @Get(path: '/buses/OSMBSC004')
  Future<chopper.Response<List<int>>> _busesOSMBSC004Get();

  ///GTFS timetables, stops, and route shapes for Busways OMR6
  Future<chopper.Response<List<int>>> busesOMBSC006Get() {
    return _busesOMBSC006Get();
  }

  ///GTFS timetables, stops, and route shapes for Busways OMR6
  @Get(path: '/buses/OMBSC006')
  Future<chopper.Response<List<int>>> _busesOMBSC006Get();

  ///GTFS timetables, stops, and route shapes for RedBus CDC NSW
  Future<chopper.Response<List<int>>> busesOMBSC007Get() {
    return _busesOMBSC007Get();
  }

  ///GTFS timetables, stops, and route shapes for RedBus CDC NSW
  @Get(path: '/buses/OMBSC007')
  Future<chopper.Response<List<int>>> _busesOMBSC007Get();

  ///GTFS timetables, stops, and route shapes for Blue Mountains Transit
  Future<chopper.Response<List<int>>> busesOSMBSC008Get() {
    return _busesOSMBSC008Get();
  }

  ///GTFS timetables, stops, and route shapes for Blue Mountains Transit
  @Get(path: '/buses/OSMBSC008')
  Future<chopper.Response<List<int>>> _busesOSMBSC008Get();

  ///GTFS timetables, stops, and route shapes for Premier Charters
  Future<chopper.Response<List<int>>> busesOSMBSC009Get() {
    return _busesOSMBSC009Get();
  }

  ///GTFS timetables, stops, and route shapes for Premier Charters
  @Get(path: '/buses/OSMBSC009')
  Future<chopper.Response<List<int>>> _busesOSMBSC009Get();

  ///GTFS timetables, stops, and route shapes for Premier Illawarra
  Future<chopper.Response<List<int>>> busesOSMBSC010Get() {
    return _busesOSMBSC010Get();
  }

  ///GTFS timetables, stops, and route shapes for Premier Illawarra
  @Get(path: '/buses/OSMBSC010')
  Future<chopper.Response<List<int>>> _busesOSMBSC010Get();

  ///GTFS timetables, stops, and route shapes for Coastal Liner
  Future<chopper.Response<List<int>>> busesOSMBSC011Get() {
    return _busesOSMBSC011Get();
  }

  ///GTFS timetables, stops, and route shapes for Coastal Liner
  @Get(path: '/buses/OSMBSC011')
  Future<chopper.Response<List<int>>> _busesOSMBSC011Get();

  ///GTFS timetables, stops, and route shapes for Dions Bus Service
  Future<chopper.Response<List<int>>> busesOSMBSC012Get() {
    return _busesOSMBSC012Get();
  }

  ///GTFS timetables, stops, and route shapes for Dions Bus Service
  @Get(path: '/buses/OSMBSC012')
  Future<chopper.Response<List<int>>> _busesOSMBSC012Get();

  ///GTFS timetables, stops, and route shapes for Newcastle Transport Buses
  Future<chopper.Response<List<int>>> busesNISC001Get() {
    return _busesNISC001Get();
  }

  ///GTFS timetables, stops, and route shapes for Newcastle Transport Buses
  @Get(path: '/buses/NISC001')
  Future<chopper.Response<List<int>>> _busesNISC001Get();

  ///GTFS timetables, stops, and route shapes for Planned Replacement Buses
  Future<chopper.Response<List<int>>> busesReplacementBusGet() {
    return _busesReplacementBusGet();
  }

  ///GTFS timetables, stops, and route shapes for Planned Replacement Buses
  @Get(path: '/buses/ReplacementBus')
  Future<chopper.Response<List<int>>> _busesReplacementBusGet();

  ///GTFS timetables, stops, and route shapes for Sydney Ferries
  Future<chopper.Response<List<int>>> ferriesSydneyferriesGet() {
    return _ferriesSydneyferriesGet();
  }

  ///GTFS timetables, stops, and route shapes for Sydney Ferries
  @Get(path: '/ferries/sydneyferries')
  Future<chopper.Response<List<int>>> _ferriesSydneyferriesGet();

  ///GTFS timetables, stops, and route shapes for Manly Fast Ferry
  Future<chopper.Response<List<int>>> ferriesMFFGet() {
    return _ferriesMFFGet();
  }

  ///GTFS timetables, stops, and route shapes for Manly Fast Ferry
  @Get(path: '/ferries/MFF')
  Future<chopper.Response<List<int>>> _ferriesMFFGet();

  ///GTFS timetables, stops, and route shapes for Inner West Light Rail
  Future<chopper.Response<List<int>>> lightrailInnerwestGet() {
    return _lightrailInnerwestGet();
  }

  ///GTFS timetables, stops, and route shapes for Inner West Light Rail
  @Get(path: '/lightrail/innerwest')
  Future<chopper.Response<List<int>>> _lightrailInnerwestGet();

  ///GTFS timetables, stops, and route shapes for Newcastle Light Rail
  Future<chopper.Response<List<int>>> lightrailNewcastleGet() {
    return _lightrailNewcastleGet();
  }

  ///GTFS timetables, stops, and route shapes for Newcastle Light Rail
  @Get(path: '/lightrail/newcastle')
  Future<chopper.Response<List<int>>> _lightrailNewcastleGet();

  ///GTFS timetables, stops, and route shapes for CBD & South East Light Rail
  Future<chopper.Response<List<int>>> lightrailCbdandsoutheastGet() {
    return _lightrailCbdandsoutheastGet();
  }

  ///GTFS timetables, stops, and route shapes for CBD & South East Light Rail
  @Get(path: '/lightrail/cbdandsoutheast')
  Future<chopper.Response<List<int>>> _lightrailCbdandsoutheastGet();

  ///GTFS timetables, stops, and route shapes for Parramatta Light Rail
  Future<chopper.Response<List<int>>> lightrailParramattaGet() {
    return _lightrailParramattaGet();
  }

  ///GTFS timetables, stops, and route shapes for Parramatta Light Rail
  @Get(path: '/lightrail/parramatta')
  Future<chopper.Response<List<int>>> _lightrailParramattaGet();

  ///GTFS timetables, stops, and route shapes for NSW Trains
  Future<chopper.Response<List<int>>> nswtrainsGet() {
    return _nswtrainsGet();
  }

  ///GTFS timetables, stops, and route shapes for NSW Trains
  @Get(path: '/nswtrains')
  Future<chopper.Response<List<int>>> _nswtrainsGet();

  ///GTFS timetables, stops, and route shapes for Sydney Trains
  Future<chopper.Response<List<int>>> sydneytrainsGet() {
    return _sydneytrainsGet();
  }

  ///GTFS timetables, stops, and route shapes for Sydney Trains
  @Get(path: '/sydneytrains')
  Future<chopper.Response<List<int>>> _sydneytrainsGet();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesSoutheasttablelandsGet() {
    return _regionbusesSoutheasttablelandsGet();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/southeasttablelands')
  Future<chopper.Response<List<int>>> _regionbusesSoutheasttablelandsGet();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesSoutheasttablelands2Get() {
    return _regionbusesSoutheasttablelands2Get();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/southeasttablelands2')
  Future<chopper.Response<List<int>>> _regionbusesSoutheasttablelands2Get();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesNorthcoastGet() {
    return _regionbusesNorthcoastGet();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/northcoast')
  Future<chopper.Response<List<int>>> _regionbusesNorthcoastGet();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesNorthcoast2Get() {
    return _regionbusesNorthcoast2Get();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/northcoast2')
  Future<chopper.Response<List<int>>> _regionbusesNorthcoast2Get();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesCentralwestandoranaGet() {
    return _regionbusesCentralwestandoranaGet();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/centralwestandorana')
  Future<chopper.Response<List<int>>> _regionbusesCentralwestandoranaGet();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesCentralwestandorana2Get() {
    return _regionbusesCentralwestandorana2Get();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/centralwestandorana2')
  Future<chopper.Response<List<int>>> _regionbusesCentralwestandorana2Get();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesRiverinamurrayGet() {
    return _regionbusesRiverinamurrayGet();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/riverinamurray')
  Future<chopper.Response<List<int>>> _regionbusesRiverinamurrayGet();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesNewenglandnorthwestGet() {
    return _regionbusesNewenglandnorthwestGet();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/newenglandnorthwest')
  Future<chopper.Response<List<int>>> _regionbusesNewenglandnorthwestGet();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesRiverinamurray2Get() {
    return _regionbusesRiverinamurray2Get();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/riverinamurray2')
  Future<chopper.Response<List<int>>> _regionbusesRiverinamurray2Get();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesNorthcoast3Get() {
    return _regionbusesNorthcoast3Get();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/northcoast3')
  Future<chopper.Response<List<int>>> _regionbusesNorthcoast3Get();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesSydneysurroundsGet() {
    return _regionbusesSydneysurroundsGet();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/sydneysurrounds')
  Future<chopper.Response<List<int>>> _regionbusesSydneysurroundsGet();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesNewcastlehunterGet() {
    return _regionbusesNewcastlehunterGet();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/newcastlehunter')
  Future<chopper.Response<List<int>>> _regionbusesNewcastlehunterGet();

  ///GTFS timetables, stops, and route shapes for Regional Buses
  Future<chopper.Response<List<int>>> regionbusesFarwestGet() {
    return _regionbusesFarwestGet();
  }

  ///GTFS timetables, stops, and route shapes for Regional Buses
  @Get(path: '/regionbuses/farwest')
  Future<chopper.Response<List<int>>> _regionbusesFarwestGet();
}

@JsonSerializable(explicitToJson: true)
class ErrorDetails {
  const ErrorDetails({
    required this.transactionId,
    required this.errorDateTime,
    required this.message,
    required this.requestedUrl,
    required this.requestedMethod,
  });

  factory ErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailsFromJson(json);

  static const toJsonFactory = _$ErrorDetailsToJson;
  Map<String, dynamic> toJson() => _$ErrorDetailsToJson(this);

  @JsonKey(name: 'TransactionId')
  final String transactionId;
  @JsonKey(name: 'ErrorDateTime')
  final String errorDateTime;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'RequestedUrl')
  final String requestedUrl;
  @JsonKey(name: 'RequestedMethod')
  final String requestedMethod;
  static const fromJsonFactory = _$ErrorDetailsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ErrorDetails &&
            (identical(other.transactionId, transactionId) ||
                const DeepCollectionEquality()
                    .equals(other.transactionId, transactionId)) &&
            (identical(other.errorDateTime, errorDateTime) ||
                const DeepCollectionEquality()
                    .equals(other.errorDateTime, errorDateTime)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality()
                    .equals(other.message, message)) &&
            (identical(other.requestedUrl, requestedUrl) ||
                const DeepCollectionEquality()
                    .equals(other.requestedUrl, requestedUrl)) &&
            (identical(other.requestedMethod, requestedMethod) ||
                const DeepCollectionEquality()
                    .equals(other.requestedMethod, requestedMethod)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(transactionId) ^
      const DeepCollectionEquality().hash(errorDateTime) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(requestedUrl) ^
      const DeepCollectionEquality().hash(requestedMethod) ^
      runtimeType.hashCode;
}

extension $ErrorDetailsExtension on ErrorDetails {
  ErrorDetails copyWith(
      {String? transactionId,
      String? errorDateTime,
      String? message,
      String? requestedUrl,
      String? requestedMethod}) {
    return ErrorDetails(
        transactionId: transactionId ?? this.transactionId,
        errorDateTime: errorDateTime ?? this.errorDateTime,
        message: message ?? this.message,
        requestedUrl: requestedUrl ?? this.requestedUrl,
        requestedMethod: requestedMethod ?? this.requestedMethod);
  }

  ErrorDetails copyWithWrapped(
      {Wrapped<String>? transactionId,
      Wrapped<String>? errorDateTime,
      Wrapped<String>? message,
      Wrapped<String>? requestedUrl,
      Wrapped<String>? requestedMethod}) {
    return ErrorDetails(
        transactionId:
            (transactionId != null ? transactionId.value : this.transactionId),
        errorDateTime:
            (errorDateTime != null ? errorDateTime.value : this.errorDateTime),
        message: (message != null ? message.value : this.message),
        requestedUrl:
            (requestedUrl != null ? requestedUrl.value : this.requestedUrl),
        requestedMethod: (requestedMethod != null
            ? requestedMethod.value
            : this.requestedMethod));
  }
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
