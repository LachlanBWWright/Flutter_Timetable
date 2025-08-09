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
import 'realtime_trip_update_v1.enums.swagger.dart' as enums;
export 'realtime_trip_update_v1.enums.swagger.dart';

part 'realtime_trip_update_v1.swagger.chopper.dart';
part 'realtime_trip_update_v1.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class RealtimeTripUpdateV1 extends ChopperService {
  static RealtimeTripUpdateV1 create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$RealtimeTripUpdateV1(client);
    }

    final newClient = ChopperClient(
      services: [_$RealtimeTripUpdateV1()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl ??
          Uri.parse('http://api.transport.nsw.gov.au/v1/gtfs/realtime'),
    );
    return _$RealtimeTripUpdateV1(newClient);
  }

  ///GTFS-realtime stop time updates for Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> busesGet({enums.BusesGetDebug? debug}) {
    return _busesGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/buses')
  Future<chopper.Response<List<int>>> _busesGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Sydney Ferries
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> ferriesSydneyferriesGet({
    enums.FerriesSydneyferriesGetDebug? debug,
  }) {
    return _ferriesSydneyferriesGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Sydney Ferries
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/ferries/sydneyferries')
  Future<chopper.Response<List<int>>> _ferriesSydneyferriesGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Manly Fast Ferry
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> ferriesMFFGet({
    enums.FerriesMFFGetDebug? debug,
  }) {
    return _ferriesMFFGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Manly Fast Ferry
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/ferries/MFF')
  Future<chopper.Response<List<int>>> _ferriesMFFGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for CBD & South East Light Rail
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> lightrailCbdandsoutheastGet({
    enums.LightrailCbdandsoutheastGetDebug? debug,
  }) {
    return _lightrailCbdandsoutheastGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for CBD & South East Light Rail
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/lightrail/cbdandsoutheast')
  Future<chopper.Response<List<int>>> _lightrailCbdandsoutheastGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Inner West Light Rail
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> lightrailInnerwestGet({
    enums.LightrailInnerwestGetDebug? debug,
  }) {
    return _lightrailInnerwestGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Inner West Light Rail
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/lightrail/innerwest')
  Future<chopper.Response<List<int>>> _lightrailInnerwestGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Newcastle Light Rail
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> lightrailNewcastleGet({
    enums.LightrailNewcastleGetDebug? debug,
  }) {
    return _lightrailNewcastleGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Newcastle Light Rail
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/lightrail/newcastle')
  Future<chopper.Response<List<int>>> _lightrailNewcastleGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Parramatta Light Rail
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> lightrailParramattaGet({
    enums.LightrailParramattaGetDebug? debug,
  }) {
    return _lightrailParramattaGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Parramatta Light Rail
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/lightrail/parramatta')
  Future<chopper.Response<List<int>>> _lightrailParramattaGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for NSW Trains
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> nswtrainsGet({
    enums.NswtrainsGetDebug? debug,
  }) {
    return _nswtrainsGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for NSW Trains
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/nswtrains')
  Future<chopper.Response<List<int>>> _nswtrainsGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesCentralwestandoranaGet({
    enums.RegionbusesCentralwestandoranaGetDebug? debug,
  }) {
    return _regionbusesCentralwestandoranaGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/centralwestandorana')
  Future<chopper.Response<List<int>>> _regionbusesCentralwestandoranaGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesCentralwestandorana2Get({
    enums.RegionbusesCentralwestandorana2GetDebug? debug,
  }) {
    return _regionbusesCentralwestandorana2Get(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/centralwestandorana2')
  Future<chopper.Response<List<int>>> _regionbusesCentralwestandorana2Get({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesFarwestGet({
    enums.RegionbusesFarwestGetDebug? debug,
  }) {
    return _regionbusesFarwestGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/farwest')
  Future<chopper.Response<List<int>>> _regionbusesFarwestGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesNewcastlehunterGet({
    enums.RegionbusesNewcastlehunterGetDebug? debug,
  }) {
    return _regionbusesNewcastlehunterGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/newcastlehunter')
  Future<chopper.Response<List<int>>> _regionbusesNewcastlehunterGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesNewenglandnorthwestGet({
    enums.RegionbusesNewenglandnorthwestGetDebug? debug,
  }) {
    return _regionbusesNewenglandnorthwestGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/newenglandnorthwest')
  Future<chopper.Response<List<int>>> _regionbusesNewenglandnorthwestGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesNorthcoastGet({
    enums.RegionbusesNorthcoastGetDebug? debug,
  }) {
    return _regionbusesNorthcoastGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/northcoast')
  Future<chopper.Response<List<int>>> _regionbusesNorthcoastGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesNorthcoast2Get({
    enums.RegionbusesNorthcoast2GetDebug? debug,
  }) {
    return _regionbusesNorthcoast2Get(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/northcoast2')
  Future<chopper.Response<List<int>>> _regionbusesNorthcoast2Get({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesNorthcoast3Get({
    enums.RegionbusesNorthcoast3GetDebug? debug,
  }) {
    return _regionbusesNorthcoast3Get(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/northcoast3')
  Future<chopper.Response<List<int>>> _regionbusesNorthcoast3Get({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesRiverinamurrayGet({
    enums.RegionbusesRiverinamurrayGetDebug? debug,
  }) {
    return _regionbusesRiverinamurrayGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/riverinamurray')
  Future<chopper.Response<List<int>>> _regionbusesRiverinamurrayGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesRiverinamurray2Get({
    enums.RegionbusesRiverinamurray2GetDebug? debug,
  }) {
    return _regionbusesRiverinamurray2Get(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/riverinamurray2')
  Future<chopper.Response<List<int>>> _regionbusesRiverinamurray2Get({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesSoutheasttablelandsGet({
    enums.RegionbusesSoutheasttablelandsGetDebug? debug,
  }) {
    return _regionbusesSoutheasttablelandsGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/southeasttablelands')
  Future<chopper.Response<List<int>>> _regionbusesSoutheasttablelandsGet({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesSoutheasttablelands2Get({
    enums.RegionbusesSoutheasttablelands2GetDebug? debug,
  }) {
    return _regionbusesSoutheasttablelands2Get(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/southeasttablelands2')
  Future<chopper.Response<List<int>>> _regionbusesSoutheasttablelands2Get({
    @Query('debug') String? debug,
  });

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> regionbusesSydneysurroundsGet({
    enums.RegionbusesSydneysurroundsGetDebug? debug,
  }) {
    return _regionbusesSydneysurroundsGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime stop time updates for Regional Buses
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @GET(path: '/regionbuses/sydneysurrounds')
  Future<chopper.Response<List<int>>> _regionbusesSydneysurroundsGet({
    @Query('debug') String? debug,
  });
}

@JsonSerializable(explicitToJson: true)
class ErrorDetails {
  const ErrorDetails({
    required this.errorDateTime,
    required this.message,
    required this.requestedMethod,
    required this.requestedUrl,
    required this.transactionId,
  });

  factory ErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailsFromJson(json);

  static const toJsonFactory = _$ErrorDetailsToJson;
  Map<String, dynamic> toJson() => _$ErrorDetailsToJson(this);

  @JsonKey(name: 'ErrorDateTime')
  final String errorDateTime;
  @JsonKey(name: 'Message')
  final String message;
  @JsonKey(name: 'RequestedMethod')
  final String requestedMethod;
  @JsonKey(name: 'RequestedUrl')
  final String requestedUrl;
  @JsonKey(name: 'TransactionId')
  final String transactionId;
  static const fromJsonFactory = _$ErrorDetailsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ErrorDetails &&
            (identical(other.errorDateTime, errorDateTime) ||
                const DeepCollectionEquality().equals(
                  other.errorDateTime,
                  errorDateTime,
                )) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.requestedMethod, requestedMethod) ||
                const DeepCollectionEquality().equals(
                  other.requestedMethod,
                  requestedMethod,
                )) &&
            (identical(other.requestedUrl, requestedUrl) ||
                const DeepCollectionEquality().equals(
                  other.requestedUrl,
                  requestedUrl,
                )) &&
            (identical(other.transactionId, transactionId) ||
                const DeepCollectionEquality().equals(
                  other.transactionId,
                  transactionId,
                )));
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

extension $ErrorDetailsExtension on ErrorDetails {
  ErrorDetails copyWith({
    String? errorDateTime,
    String? message,
    String? requestedMethod,
    String? requestedUrl,
    String? transactionId,
  }) {
    return ErrorDetails(
      errorDateTime: errorDateTime ?? this.errorDateTime,
      message: message ?? this.message,
      requestedMethod: requestedMethod ?? this.requestedMethod,
      requestedUrl: requestedUrl ?? this.requestedUrl,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  ErrorDetails copyWithWrapped({
    Wrapped<String>? errorDateTime,
    Wrapped<String>? message,
    Wrapped<String>? requestedMethod,
    Wrapped<String>? requestedUrl,
    Wrapped<String>? transactionId,
  }) {
    return ErrorDetails(
      errorDateTime:
          (errorDateTime != null ? errorDateTime.value : this.errorDateTime),
      message: (message != null ? message.value : this.message),
      requestedMethod: (requestedMethod != null
          ? requestedMethod.value
          : this.requestedMethod),
      requestedUrl:
          (requestedUrl != null ? requestedUrl.value : this.requestedUrl),
      transactionId:
          (transactionId != null ? transactionId.value : this.transactionId),
    );
  }
}

String? busesGetDebugNullableToJson(enums.BusesGetDebug? busesGetDebug) {
  return busesGetDebug?.value;
}

String? busesGetDebugToJson(enums.BusesGetDebug busesGetDebug) {
  return busesGetDebug.value;
}

enums.BusesGetDebug busesGetDebugFromJson(
  Object? busesGetDebug, [
  enums.BusesGetDebug? defaultValue,
]) {
  return enums.BusesGetDebug.values.firstWhereOrNull(
        (e) => e.value == busesGetDebug,
      ) ??
      defaultValue ??
      enums.BusesGetDebug.swaggerGeneratedUnknown;
}

enums.BusesGetDebug? busesGetDebugNullableFromJson(
  Object? busesGetDebug, [
  enums.BusesGetDebug? defaultValue,
]) {
  if (busesGetDebug == null) {
    return null;
  }
  return enums.BusesGetDebug.values.firstWhereOrNull(
        (e) => e.value == busesGetDebug,
      ) ??
      defaultValue;
}

String busesGetDebugExplodedListToJson(
  List<enums.BusesGetDebug>? busesGetDebug,
) {
  return busesGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> busesGetDebugListToJson(List<enums.BusesGetDebug>? busesGetDebug) {
  if (busesGetDebug == null) {
    return [];
  }

  return busesGetDebug.map((e) => e.value!).toList();
}

List<enums.BusesGetDebug> busesGetDebugListFromJson(
  List? busesGetDebug, [
  List<enums.BusesGetDebug>? defaultValue,
]) {
  if (busesGetDebug == null) {
    return defaultValue ?? [];
  }

  return busesGetDebug.map((e) => busesGetDebugFromJson(e.toString())).toList();
}

List<enums.BusesGetDebug>? busesGetDebugNullableListFromJson(
  List? busesGetDebug, [
  List<enums.BusesGetDebug>? defaultValue,
]) {
  if (busesGetDebug == null) {
    return defaultValue;
  }

  return busesGetDebug.map((e) => busesGetDebugFromJson(e.toString())).toList();
}

String? ferriesSydneyferriesGetDebugNullableToJson(
  enums.FerriesSydneyferriesGetDebug? ferriesSydneyferriesGetDebug,
) {
  return ferriesSydneyferriesGetDebug?.value;
}

String? ferriesSydneyferriesGetDebugToJson(
  enums.FerriesSydneyferriesGetDebug ferriesSydneyferriesGetDebug,
) {
  return ferriesSydneyferriesGetDebug.value;
}

enums.FerriesSydneyferriesGetDebug ferriesSydneyferriesGetDebugFromJson(
  Object? ferriesSydneyferriesGetDebug, [
  enums.FerriesSydneyferriesGetDebug? defaultValue,
]) {
  return enums.FerriesSydneyferriesGetDebug.values.firstWhereOrNull(
        (e) => e.value == ferriesSydneyferriesGetDebug,
      ) ??
      defaultValue ??
      enums.FerriesSydneyferriesGetDebug.swaggerGeneratedUnknown;
}

enums.FerriesSydneyferriesGetDebug?
    ferriesSydneyferriesGetDebugNullableFromJson(
  Object? ferriesSydneyferriesGetDebug, [
  enums.FerriesSydneyferriesGetDebug? defaultValue,
]) {
  if (ferriesSydneyferriesGetDebug == null) {
    return null;
  }
  return enums.FerriesSydneyferriesGetDebug.values.firstWhereOrNull(
        (e) => e.value == ferriesSydneyferriesGetDebug,
      ) ??
      defaultValue;
}

String ferriesSydneyferriesGetDebugExplodedListToJson(
  List<enums.FerriesSydneyferriesGetDebug>? ferriesSydneyferriesGetDebug,
) {
  return ferriesSydneyferriesGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> ferriesSydneyferriesGetDebugListToJson(
  List<enums.FerriesSydneyferriesGetDebug>? ferriesSydneyferriesGetDebug,
) {
  if (ferriesSydneyferriesGetDebug == null) {
    return [];
  }

  return ferriesSydneyferriesGetDebug.map((e) => e.value!).toList();
}

List<enums.FerriesSydneyferriesGetDebug>
    ferriesSydneyferriesGetDebugListFromJson(
  List? ferriesSydneyferriesGetDebug, [
  List<enums.FerriesSydneyferriesGetDebug>? defaultValue,
]) {
  if (ferriesSydneyferriesGetDebug == null) {
    return defaultValue ?? [];
  }

  return ferriesSydneyferriesGetDebug
      .map((e) => ferriesSydneyferriesGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.FerriesSydneyferriesGetDebug>?
    ferriesSydneyferriesGetDebugNullableListFromJson(
  List? ferriesSydneyferriesGetDebug, [
  List<enums.FerriesSydneyferriesGetDebug>? defaultValue,
]) {
  if (ferriesSydneyferriesGetDebug == null) {
    return defaultValue;
  }

  return ferriesSydneyferriesGetDebug
      .map((e) => ferriesSydneyferriesGetDebugFromJson(e.toString()))
      .toList();
}

String? ferriesMFFGetDebugNullableToJson(
  enums.FerriesMFFGetDebug? ferriesMFFGetDebug,
) {
  return ferriesMFFGetDebug?.value;
}

String? ferriesMFFGetDebugToJson(enums.FerriesMFFGetDebug ferriesMFFGetDebug) {
  return ferriesMFFGetDebug.value;
}

enums.FerriesMFFGetDebug ferriesMFFGetDebugFromJson(
  Object? ferriesMFFGetDebug, [
  enums.FerriesMFFGetDebug? defaultValue,
]) {
  return enums.FerriesMFFGetDebug.values.firstWhereOrNull(
        (e) => e.value == ferriesMFFGetDebug,
      ) ??
      defaultValue ??
      enums.FerriesMFFGetDebug.swaggerGeneratedUnknown;
}

enums.FerriesMFFGetDebug? ferriesMFFGetDebugNullableFromJson(
  Object? ferriesMFFGetDebug, [
  enums.FerriesMFFGetDebug? defaultValue,
]) {
  if (ferriesMFFGetDebug == null) {
    return null;
  }
  return enums.FerriesMFFGetDebug.values.firstWhereOrNull(
        (e) => e.value == ferriesMFFGetDebug,
      ) ??
      defaultValue;
}

String ferriesMFFGetDebugExplodedListToJson(
  List<enums.FerriesMFFGetDebug>? ferriesMFFGetDebug,
) {
  return ferriesMFFGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> ferriesMFFGetDebugListToJson(
  List<enums.FerriesMFFGetDebug>? ferriesMFFGetDebug,
) {
  if (ferriesMFFGetDebug == null) {
    return [];
  }

  return ferriesMFFGetDebug.map((e) => e.value!).toList();
}

List<enums.FerriesMFFGetDebug> ferriesMFFGetDebugListFromJson(
  List? ferriesMFFGetDebug, [
  List<enums.FerriesMFFGetDebug>? defaultValue,
]) {
  if (ferriesMFFGetDebug == null) {
    return defaultValue ?? [];
  }

  return ferriesMFFGetDebug
      .map((e) => ferriesMFFGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.FerriesMFFGetDebug>? ferriesMFFGetDebugNullableListFromJson(
  List? ferriesMFFGetDebug, [
  List<enums.FerriesMFFGetDebug>? defaultValue,
]) {
  if (ferriesMFFGetDebug == null) {
    return defaultValue;
  }

  return ferriesMFFGetDebug
      .map((e) => ferriesMFFGetDebugFromJson(e.toString()))
      .toList();
}

String? lightrailCbdandsoutheastGetDebugNullableToJson(
  enums.LightrailCbdandsoutheastGetDebug? lightrailCbdandsoutheastGetDebug,
) {
  return lightrailCbdandsoutheastGetDebug?.value;
}

String? lightrailCbdandsoutheastGetDebugToJson(
  enums.LightrailCbdandsoutheastGetDebug lightrailCbdandsoutheastGetDebug,
) {
  return lightrailCbdandsoutheastGetDebug.value;
}

enums.LightrailCbdandsoutheastGetDebug lightrailCbdandsoutheastGetDebugFromJson(
  Object? lightrailCbdandsoutheastGetDebug, [
  enums.LightrailCbdandsoutheastGetDebug? defaultValue,
]) {
  return enums.LightrailCbdandsoutheastGetDebug.values.firstWhereOrNull(
        (e) => e.value == lightrailCbdandsoutheastGetDebug,
      ) ??
      defaultValue ??
      enums.LightrailCbdandsoutheastGetDebug.swaggerGeneratedUnknown;
}

enums.LightrailCbdandsoutheastGetDebug?
    lightrailCbdandsoutheastGetDebugNullableFromJson(
  Object? lightrailCbdandsoutheastGetDebug, [
  enums.LightrailCbdandsoutheastGetDebug? defaultValue,
]) {
  if (lightrailCbdandsoutheastGetDebug == null) {
    return null;
  }
  return enums.LightrailCbdandsoutheastGetDebug.values.firstWhereOrNull(
        (e) => e.value == lightrailCbdandsoutheastGetDebug,
      ) ??
      defaultValue;
}

String lightrailCbdandsoutheastGetDebugExplodedListToJson(
  List<enums.LightrailCbdandsoutheastGetDebug>?
      lightrailCbdandsoutheastGetDebug,
) {
  return lightrailCbdandsoutheastGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> lightrailCbdandsoutheastGetDebugListToJson(
  List<enums.LightrailCbdandsoutheastGetDebug>?
      lightrailCbdandsoutheastGetDebug,
) {
  if (lightrailCbdandsoutheastGetDebug == null) {
    return [];
  }

  return lightrailCbdandsoutheastGetDebug.map((e) => e.value!).toList();
}

List<enums.LightrailCbdandsoutheastGetDebug>
    lightrailCbdandsoutheastGetDebugListFromJson(
  List? lightrailCbdandsoutheastGetDebug, [
  List<enums.LightrailCbdandsoutheastGetDebug>? defaultValue,
]) {
  if (lightrailCbdandsoutheastGetDebug == null) {
    return defaultValue ?? [];
  }

  return lightrailCbdandsoutheastGetDebug
      .map((e) => lightrailCbdandsoutheastGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.LightrailCbdandsoutheastGetDebug>?
    lightrailCbdandsoutheastGetDebugNullableListFromJson(
  List? lightrailCbdandsoutheastGetDebug, [
  List<enums.LightrailCbdandsoutheastGetDebug>? defaultValue,
]) {
  if (lightrailCbdandsoutheastGetDebug == null) {
    return defaultValue;
  }

  return lightrailCbdandsoutheastGetDebug
      .map((e) => lightrailCbdandsoutheastGetDebugFromJson(e.toString()))
      .toList();
}

String? lightrailInnerwestGetDebugNullableToJson(
  enums.LightrailInnerwestGetDebug? lightrailInnerwestGetDebug,
) {
  return lightrailInnerwestGetDebug?.value;
}

String? lightrailInnerwestGetDebugToJson(
  enums.LightrailInnerwestGetDebug lightrailInnerwestGetDebug,
) {
  return lightrailInnerwestGetDebug.value;
}

enums.LightrailInnerwestGetDebug lightrailInnerwestGetDebugFromJson(
  Object? lightrailInnerwestGetDebug, [
  enums.LightrailInnerwestGetDebug? defaultValue,
]) {
  return enums.LightrailInnerwestGetDebug.values.firstWhereOrNull(
        (e) => e.value == lightrailInnerwestGetDebug,
      ) ??
      defaultValue ??
      enums.LightrailInnerwestGetDebug.swaggerGeneratedUnknown;
}

enums.LightrailInnerwestGetDebug? lightrailInnerwestGetDebugNullableFromJson(
  Object? lightrailInnerwestGetDebug, [
  enums.LightrailInnerwestGetDebug? defaultValue,
]) {
  if (lightrailInnerwestGetDebug == null) {
    return null;
  }
  return enums.LightrailInnerwestGetDebug.values.firstWhereOrNull(
        (e) => e.value == lightrailInnerwestGetDebug,
      ) ??
      defaultValue;
}

String lightrailInnerwestGetDebugExplodedListToJson(
  List<enums.LightrailInnerwestGetDebug>? lightrailInnerwestGetDebug,
) {
  return lightrailInnerwestGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> lightrailInnerwestGetDebugListToJson(
  List<enums.LightrailInnerwestGetDebug>? lightrailInnerwestGetDebug,
) {
  if (lightrailInnerwestGetDebug == null) {
    return [];
  }

  return lightrailInnerwestGetDebug.map((e) => e.value!).toList();
}

List<enums.LightrailInnerwestGetDebug> lightrailInnerwestGetDebugListFromJson(
  List? lightrailInnerwestGetDebug, [
  List<enums.LightrailInnerwestGetDebug>? defaultValue,
]) {
  if (lightrailInnerwestGetDebug == null) {
    return defaultValue ?? [];
  }

  return lightrailInnerwestGetDebug
      .map((e) => lightrailInnerwestGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.LightrailInnerwestGetDebug>?
    lightrailInnerwestGetDebugNullableListFromJson(
  List? lightrailInnerwestGetDebug, [
  List<enums.LightrailInnerwestGetDebug>? defaultValue,
]) {
  if (lightrailInnerwestGetDebug == null) {
    return defaultValue;
  }

  return lightrailInnerwestGetDebug
      .map((e) => lightrailInnerwestGetDebugFromJson(e.toString()))
      .toList();
}

String? lightrailNewcastleGetDebugNullableToJson(
  enums.LightrailNewcastleGetDebug? lightrailNewcastleGetDebug,
) {
  return lightrailNewcastleGetDebug?.value;
}

String? lightrailNewcastleGetDebugToJson(
  enums.LightrailNewcastleGetDebug lightrailNewcastleGetDebug,
) {
  return lightrailNewcastleGetDebug.value;
}

enums.LightrailNewcastleGetDebug lightrailNewcastleGetDebugFromJson(
  Object? lightrailNewcastleGetDebug, [
  enums.LightrailNewcastleGetDebug? defaultValue,
]) {
  return enums.LightrailNewcastleGetDebug.values.firstWhereOrNull(
        (e) => e.value == lightrailNewcastleGetDebug,
      ) ??
      defaultValue ??
      enums.LightrailNewcastleGetDebug.swaggerGeneratedUnknown;
}

enums.LightrailNewcastleGetDebug? lightrailNewcastleGetDebugNullableFromJson(
  Object? lightrailNewcastleGetDebug, [
  enums.LightrailNewcastleGetDebug? defaultValue,
]) {
  if (lightrailNewcastleGetDebug == null) {
    return null;
  }
  return enums.LightrailNewcastleGetDebug.values.firstWhereOrNull(
        (e) => e.value == lightrailNewcastleGetDebug,
      ) ??
      defaultValue;
}

String lightrailNewcastleGetDebugExplodedListToJson(
  List<enums.LightrailNewcastleGetDebug>? lightrailNewcastleGetDebug,
) {
  return lightrailNewcastleGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> lightrailNewcastleGetDebugListToJson(
  List<enums.LightrailNewcastleGetDebug>? lightrailNewcastleGetDebug,
) {
  if (lightrailNewcastleGetDebug == null) {
    return [];
  }

  return lightrailNewcastleGetDebug.map((e) => e.value!).toList();
}

List<enums.LightrailNewcastleGetDebug> lightrailNewcastleGetDebugListFromJson(
  List? lightrailNewcastleGetDebug, [
  List<enums.LightrailNewcastleGetDebug>? defaultValue,
]) {
  if (lightrailNewcastleGetDebug == null) {
    return defaultValue ?? [];
  }

  return lightrailNewcastleGetDebug
      .map((e) => lightrailNewcastleGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.LightrailNewcastleGetDebug>?
    lightrailNewcastleGetDebugNullableListFromJson(
  List? lightrailNewcastleGetDebug, [
  List<enums.LightrailNewcastleGetDebug>? defaultValue,
]) {
  if (lightrailNewcastleGetDebug == null) {
    return defaultValue;
  }

  return lightrailNewcastleGetDebug
      .map((e) => lightrailNewcastleGetDebugFromJson(e.toString()))
      .toList();
}

String? lightrailParramattaGetDebugNullableToJson(
  enums.LightrailParramattaGetDebug? lightrailParramattaGetDebug,
) {
  return lightrailParramattaGetDebug?.value;
}

String? lightrailParramattaGetDebugToJson(
  enums.LightrailParramattaGetDebug lightrailParramattaGetDebug,
) {
  return lightrailParramattaGetDebug.value;
}

enums.LightrailParramattaGetDebug lightrailParramattaGetDebugFromJson(
  Object? lightrailParramattaGetDebug, [
  enums.LightrailParramattaGetDebug? defaultValue,
]) {
  return enums.LightrailParramattaGetDebug.values.firstWhereOrNull(
        (e) => e.value == lightrailParramattaGetDebug,
      ) ??
      defaultValue ??
      enums.LightrailParramattaGetDebug.swaggerGeneratedUnknown;
}

enums.LightrailParramattaGetDebug? lightrailParramattaGetDebugNullableFromJson(
  Object? lightrailParramattaGetDebug, [
  enums.LightrailParramattaGetDebug? defaultValue,
]) {
  if (lightrailParramattaGetDebug == null) {
    return null;
  }
  return enums.LightrailParramattaGetDebug.values.firstWhereOrNull(
        (e) => e.value == lightrailParramattaGetDebug,
      ) ??
      defaultValue;
}

String lightrailParramattaGetDebugExplodedListToJson(
  List<enums.LightrailParramattaGetDebug>? lightrailParramattaGetDebug,
) {
  return lightrailParramattaGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> lightrailParramattaGetDebugListToJson(
  List<enums.LightrailParramattaGetDebug>? lightrailParramattaGetDebug,
) {
  if (lightrailParramattaGetDebug == null) {
    return [];
  }

  return lightrailParramattaGetDebug.map((e) => e.value!).toList();
}

List<enums.LightrailParramattaGetDebug> lightrailParramattaGetDebugListFromJson(
  List? lightrailParramattaGetDebug, [
  List<enums.LightrailParramattaGetDebug>? defaultValue,
]) {
  if (lightrailParramattaGetDebug == null) {
    return defaultValue ?? [];
  }

  return lightrailParramattaGetDebug
      .map((e) => lightrailParramattaGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.LightrailParramattaGetDebug>?
    lightrailParramattaGetDebugNullableListFromJson(
  List? lightrailParramattaGetDebug, [
  List<enums.LightrailParramattaGetDebug>? defaultValue,
]) {
  if (lightrailParramattaGetDebug == null) {
    return defaultValue;
  }

  return lightrailParramattaGetDebug
      .map((e) => lightrailParramattaGetDebugFromJson(e.toString()))
      .toList();
}

String? nswtrainsGetDebugNullableToJson(
  enums.NswtrainsGetDebug? nswtrainsGetDebug,
) {
  return nswtrainsGetDebug?.value;
}

String? nswtrainsGetDebugToJson(enums.NswtrainsGetDebug nswtrainsGetDebug) {
  return nswtrainsGetDebug.value;
}

enums.NswtrainsGetDebug nswtrainsGetDebugFromJson(
  Object? nswtrainsGetDebug, [
  enums.NswtrainsGetDebug? defaultValue,
]) {
  return enums.NswtrainsGetDebug.values.firstWhereOrNull(
        (e) => e.value == nswtrainsGetDebug,
      ) ??
      defaultValue ??
      enums.NswtrainsGetDebug.swaggerGeneratedUnknown;
}

enums.NswtrainsGetDebug? nswtrainsGetDebugNullableFromJson(
  Object? nswtrainsGetDebug, [
  enums.NswtrainsGetDebug? defaultValue,
]) {
  if (nswtrainsGetDebug == null) {
    return null;
  }
  return enums.NswtrainsGetDebug.values.firstWhereOrNull(
        (e) => e.value == nswtrainsGetDebug,
      ) ??
      defaultValue;
}

String nswtrainsGetDebugExplodedListToJson(
  List<enums.NswtrainsGetDebug>? nswtrainsGetDebug,
) {
  return nswtrainsGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> nswtrainsGetDebugListToJson(
  List<enums.NswtrainsGetDebug>? nswtrainsGetDebug,
) {
  if (nswtrainsGetDebug == null) {
    return [];
  }

  return nswtrainsGetDebug.map((e) => e.value!).toList();
}

List<enums.NswtrainsGetDebug> nswtrainsGetDebugListFromJson(
  List? nswtrainsGetDebug, [
  List<enums.NswtrainsGetDebug>? defaultValue,
]) {
  if (nswtrainsGetDebug == null) {
    return defaultValue ?? [];
  }

  return nswtrainsGetDebug
      .map((e) => nswtrainsGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.NswtrainsGetDebug>? nswtrainsGetDebugNullableListFromJson(
  List? nswtrainsGetDebug, [
  List<enums.NswtrainsGetDebug>? defaultValue,
]) {
  if (nswtrainsGetDebug == null) {
    return defaultValue;
  }

  return nswtrainsGetDebug
      .map((e) => nswtrainsGetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesCentralwestandoranaGetDebugNullableToJson(
  enums.RegionbusesCentralwestandoranaGetDebug?
      regionbusesCentralwestandoranaGetDebug,
) {
  return regionbusesCentralwestandoranaGetDebug?.value;
}

String? regionbusesCentralwestandoranaGetDebugToJson(
  enums.RegionbusesCentralwestandoranaGetDebug
      regionbusesCentralwestandoranaGetDebug,
) {
  return regionbusesCentralwestandoranaGetDebug.value;
}

enums.RegionbusesCentralwestandoranaGetDebug
    regionbusesCentralwestandoranaGetDebugFromJson(
  Object? regionbusesCentralwestandoranaGetDebug, [
  enums.RegionbusesCentralwestandoranaGetDebug? defaultValue,
]) {
  return enums.RegionbusesCentralwestandoranaGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesCentralwestandoranaGetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesCentralwestandoranaGetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesCentralwestandoranaGetDebug?
    regionbusesCentralwestandoranaGetDebugNullableFromJson(
  Object? regionbusesCentralwestandoranaGetDebug, [
  enums.RegionbusesCentralwestandoranaGetDebug? defaultValue,
]) {
  if (regionbusesCentralwestandoranaGetDebug == null) {
    return null;
  }
  return enums.RegionbusesCentralwestandoranaGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesCentralwestandoranaGetDebug,
      ) ??
      defaultValue;
}

String regionbusesCentralwestandoranaGetDebugExplodedListToJson(
  List<enums.RegionbusesCentralwestandoranaGetDebug>?
      regionbusesCentralwestandoranaGetDebug,
) {
  return regionbusesCentralwestandoranaGetDebug
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> regionbusesCentralwestandoranaGetDebugListToJson(
  List<enums.RegionbusesCentralwestandoranaGetDebug>?
      regionbusesCentralwestandoranaGetDebug,
) {
  if (regionbusesCentralwestandoranaGetDebug == null) {
    return [];
  }

  return regionbusesCentralwestandoranaGetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesCentralwestandoranaGetDebug>
    regionbusesCentralwestandoranaGetDebugListFromJson(
  List? regionbusesCentralwestandoranaGetDebug, [
  List<enums.RegionbusesCentralwestandoranaGetDebug>? defaultValue,
]) {
  if (regionbusesCentralwestandoranaGetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesCentralwestandoranaGetDebug
      .map((e) => regionbusesCentralwestandoranaGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesCentralwestandoranaGetDebug>?
    regionbusesCentralwestandoranaGetDebugNullableListFromJson(
  List? regionbusesCentralwestandoranaGetDebug, [
  List<enums.RegionbusesCentralwestandoranaGetDebug>? defaultValue,
]) {
  if (regionbusesCentralwestandoranaGetDebug == null) {
    return defaultValue;
  }

  return regionbusesCentralwestandoranaGetDebug
      .map((e) => regionbusesCentralwestandoranaGetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesCentralwestandorana2GetDebugNullableToJson(
  enums.RegionbusesCentralwestandorana2GetDebug?
      regionbusesCentralwestandorana2GetDebug,
) {
  return regionbusesCentralwestandorana2GetDebug?.value;
}

String? regionbusesCentralwestandorana2GetDebugToJson(
  enums.RegionbusesCentralwestandorana2GetDebug
      regionbusesCentralwestandorana2GetDebug,
) {
  return regionbusesCentralwestandorana2GetDebug.value;
}

enums.RegionbusesCentralwestandorana2GetDebug
    regionbusesCentralwestandorana2GetDebugFromJson(
  Object? regionbusesCentralwestandorana2GetDebug, [
  enums.RegionbusesCentralwestandorana2GetDebug? defaultValue,
]) {
  return enums.RegionbusesCentralwestandorana2GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesCentralwestandorana2GetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesCentralwestandorana2GetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesCentralwestandorana2GetDebug?
    regionbusesCentralwestandorana2GetDebugNullableFromJson(
  Object? regionbusesCentralwestandorana2GetDebug, [
  enums.RegionbusesCentralwestandorana2GetDebug? defaultValue,
]) {
  if (regionbusesCentralwestandorana2GetDebug == null) {
    return null;
  }
  return enums.RegionbusesCentralwestandorana2GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesCentralwestandorana2GetDebug,
      ) ??
      defaultValue;
}

String regionbusesCentralwestandorana2GetDebugExplodedListToJson(
  List<enums.RegionbusesCentralwestandorana2GetDebug>?
      regionbusesCentralwestandorana2GetDebug,
) {
  return regionbusesCentralwestandorana2GetDebug
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> regionbusesCentralwestandorana2GetDebugListToJson(
  List<enums.RegionbusesCentralwestandorana2GetDebug>?
      regionbusesCentralwestandorana2GetDebug,
) {
  if (regionbusesCentralwestandorana2GetDebug == null) {
    return [];
  }

  return regionbusesCentralwestandorana2GetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesCentralwestandorana2GetDebug>
    regionbusesCentralwestandorana2GetDebugListFromJson(
  List? regionbusesCentralwestandorana2GetDebug, [
  List<enums.RegionbusesCentralwestandorana2GetDebug>? defaultValue,
]) {
  if (regionbusesCentralwestandorana2GetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesCentralwestandorana2GetDebug
      .map((e) => regionbusesCentralwestandorana2GetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesCentralwestandorana2GetDebug>?
    regionbusesCentralwestandorana2GetDebugNullableListFromJson(
  List? regionbusesCentralwestandorana2GetDebug, [
  List<enums.RegionbusesCentralwestandorana2GetDebug>? defaultValue,
]) {
  if (regionbusesCentralwestandorana2GetDebug == null) {
    return defaultValue;
  }

  return regionbusesCentralwestandorana2GetDebug
      .map((e) => regionbusesCentralwestandorana2GetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesFarwestGetDebugNullableToJson(
  enums.RegionbusesFarwestGetDebug? regionbusesFarwestGetDebug,
) {
  return regionbusesFarwestGetDebug?.value;
}

String? regionbusesFarwestGetDebugToJson(
  enums.RegionbusesFarwestGetDebug regionbusesFarwestGetDebug,
) {
  return regionbusesFarwestGetDebug.value;
}

enums.RegionbusesFarwestGetDebug regionbusesFarwestGetDebugFromJson(
  Object? regionbusesFarwestGetDebug, [
  enums.RegionbusesFarwestGetDebug? defaultValue,
]) {
  return enums.RegionbusesFarwestGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesFarwestGetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesFarwestGetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesFarwestGetDebug? regionbusesFarwestGetDebugNullableFromJson(
  Object? regionbusesFarwestGetDebug, [
  enums.RegionbusesFarwestGetDebug? defaultValue,
]) {
  if (regionbusesFarwestGetDebug == null) {
    return null;
  }
  return enums.RegionbusesFarwestGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesFarwestGetDebug,
      ) ??
      defaultValue;
}

String regionbusesFarwestGetDebugExplodedListToJson(
  List<enums.RegionbusesFarwestGetDebug>? regionbusesFarwestGetDebug,
) {
  return regionbusesFarwestGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> regionbusesFarwestGetDebugListToJson(
  List<enums.RegionbusesFarwestGetDebug>? regionbusesFarwestGetDebug,
) {
  if (regionbusesFarwestGetDebug == null) {
    return [];
  }

  return regionbusesFarwestGetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesFarwestGetDebug> regionbusesFarwestGetDebugListFromJson(
  List? regionbusesFarwestGetDebug, [
  List<enums.RegionbusesFarwestGetDebug>? defaultValue,
]) {
  if (regionbusesFarwestGetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesFarwestGetDebug
      .map((e) => regionbusesFarwestGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesFarwestGetDebug>?
    regionbusesFarwestGetDebugNullableListFromJson(
  List? regionbusesFarwestGetDebug, [
  List<enums.RegionbusesFarwestGetDebug>? defaultValue,
]) {
  if (regionbusesFarwestGetDebug == null) {
    return defaultValue;
  }

  return regionbusesFarwestGetDebug
      .map((e) => regionbusesFarwestGetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesNewcastlehunterGetDebugNullableToJson(
  enums.RegionbusesNewcastlehunterGetDebug? regionbusesNewcastlehunterGetDebug,
) {
  return regionbusesNewcastlehunterGetDebug?.value;
}

String? regionbusesNewcastlehunterGetDebugToJson(
  enums.RegionbusesNewcastlehunterGetDebug regionbusesNewcastlehunterGetDebug,
) {
  return regionbusesNewcastlehunterGetDebug.value;
}

enums.RegionbusesNewcastlehunterGetDebug
    regionbusesNewcastlehunterGetDebugFromJson(
  Object? regionbusesNewcastlehunterGetDebug, [
  enums.RegionbusesNewcastlehunterGetDebug? defaultValue,
]) {
  return enums.RegionbusesNewcastlehunterGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNewcastlehunterGetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesNewcastlehunterGetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesNewcastlehunterGetDebug?
    regionbusesNewcastlehunterGetDebugNullableFromJson(
  Object? regionbusesNewcastlehunterGetDebug, [
  enums.RegionbusesNewcastlehunterGetDebug? defaultValue,
]) {
  if (regionbusesNewcastlehunterGetDebug == null) {
    return null;
  }
  return enums.RegionbusesNewcastlehunterGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNewcastlehunterGetDebug,
      ) ??
      defaultValue;
}

String regionbusesNewcastlehunterGetDebugExplodedListToJson(
  List<enums.RegionbusesNewcastlehunterGetDebug>?
      regionbusesNewcastlehunterGetDebug,
) {
  return regionbusesNewcastlehunterGetDebug?.map((e) => e.value!).join(',') ??
      '';
}

List<String> regionbusesNewcastlehunterGetDebugListToJson(
  List<enums.RegionbusesNewcastlehunterGetDebug>?
      regionbusesNewcastlehunterGetDebug,
) {
  if (regionbusesNewcastlehunterGetDebug == null) {
    return [];
  }

  return regionbusesNewcastlehunterGetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesNewcastlehunterGetDebug>
    regionbusesNewcastlehunterGetDebugListFromJson(
  List? regionbusesNewcastlehunterGetDebug, [
  List<enums.RegionbusesNewcastlehunterGetDebug>? defaultValue,
]) {
  if (regionbusesNewcastlehunterGetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesNewcastlehunterGetDebug
      .map((e) => regionbusesNewcastlehunterGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesNewcastlehunterGetDebug>?
    regionbusesNewcastlehunterGetDebugNullableListFromJson(
  List? regionbusesNewcastlehunterGetDebug, [
  List<enums.RegionbusesNewcastlehunterGetDebug>? defaultValue,
]) {
  if (regionbusesNewcastlehunterGetDebug == null) {
    return defaultValue;
  }

  return regionbusesNewcastlehunterGetDebug
      .map((e) => regionbusesNewcastlehunterGetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesNewenglandnorthwestGetDebugNullableToJson(
  enums.RegionbusesNewenglandnorthwestGetDebug?
      regionbusesNewenglandnorthwestGetDebug,
) {
  return regionbusesNewenglandnorthwestGetDebug?.value;
}

String? regionbusesNewenglandnorthwestGetDebugToJson(
  enums.RegionbusesNewenglandnorthwestGetDebug
      regionbusesNewenglandnorthwestGetDebug,
) {
  return regionbusesNewenglandnorthwestGetDebug.value;
}

enums.RegionbusesNewenglandnorthwestGetDebug
    regionbusesNewenglandnorthwestGetDebugFromJson(
  Object? regionbusesNewenglandnorthwestGetDebug, [
  enums.RegionbusesNewenglandnorthwestGetDebug? defaultValue,
]) {
  return enums.RegionbusesNewenglandnorthwestGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNewenglandnorthwestGetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesNewenglandnorthwestGetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesNewenglandnorthwestGetDebug?
    regionbusesNewenglandnorthwestGetDebugNullableFromJson(
  Object? regionbusesNewenglandnorthwestGetDebug, [
  enums.RegionbusesNewenglandnorthwestGetDebug? defaultValue,
]) {
  if (regionbusesNewenglandnorthwestGetDebug == null) {
    return null;
  }
  return enums.RegionbusesNewenglandnorthwestGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNewenglandnorthwestGetDebug,
      ) ??
      defaultValue;
}

String regionbusesNewenglandnorthwestGetDebugExplodedListToJson(
  List<enums.RegionbusesNewenglandnorthwestGetDebug>?
      regionbusesNewenglandnorthwestGetDebug,
) {
  return regionbusesNewenglandnorthwestGetDebug
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> regionbusesNewenglandnorthwestGetDebugListToJson(
  List<enums.RegionbusesNewenglandnorthwestGetDebug>?
      regionbusesNewenglandnorthwestGetDebug,
) {
  if (regionbusesNewenglandnorthwestGetDebug == null) {
    return [];
  }

  return regionbusesNewenglandnorthwestGetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesNewenglandnorthwestGetDebug>
    regionbusesNewenglandnorthwestGetDebugListFromJson(
  List? regionbusesNewenglandnorthwestGetDebug, [
  List<enums.RegionbusesNewenglandnorthwestGetDebug>? defaultValue,
]) {
  if (regionbusesNewenglandnorthwestGetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesNewenglandnorthwestGetDebug
      .map((e) => regionbusesNewenglandnorthwestGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesNewenglandnorthwestGetDebug>?
    regionbusesNewenglandnorthwestGetDebugNullableListFromJson(
  List? regionbusesNewenglandnorthwestGetDebug, [
  List<enums.RegionbusesNewenglandnorthwestGetDebug>? defaultValue,
]) {
  if (regionbusesNewenglandnorthwestGetDebug == null) {
    return defaultValue;
  }

  return regionbusesNewenglandnorthwestGetDebug
      .map((e) => regionbusesNewenglandnorthwestGetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesNorthcoastGetDebugNullableToJson(
  enums.RegionbusesNorthcoastGetDebug? regionbusesNorthcoastGetDebug,
) {
  return regionbusesNorthcoastGetDebug?.value;
}

String? regionbusesNorthcoastGetDebugToJson(
  enums.RegionbusesNorthcoastGetDebug regionbusesNorthcoastGetDebug,
) {
  return regionbusesNorthcoastGetDebug.value;
}

enums.RegionbusesNorthcoastGetDebug regionbusesNorthcoastGetDebugFromJson(
  Object? regionbusesNorthcoastGetDebug, [
  enums.RegionbusesNorthcoastGetDebug? defaultValue,
]) {
  return enums.RegionbusesNorthcoastGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNorthcoastGetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesNorthcoastGetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesNorthcoastGetDebug?
    regionbusesNorthcoastGetDebugNullableFromJson(
  Object? regionbusesNorthcoastGetDebug, [
  enums.RegionbusesNorthcoastGetDebug? defaultValue,
]) {
  if (regionbusesNorthcoastGetDebug == null) {
    return null;
  }
  return enums.RegionbusesNorthcoastGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNorthcoastGetDebug,
      ) ??
      defaultValue;
}

String regionbusesNorthcoastGetDebugExplodedListToJson(
  List<enums.RegionbusesNorthcoastGetDebug>? regionbusesNorthcoastGetDebug,
) {
  return regionbusesNorthcoastGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> regionbusesNorthcoastGetDebugListToJson(
  List<enums.RegionbusesNorthcoastGetDebug>? regionbusesNorthcoastGetDebug,
) {
  if (regionbusesNorthcoastGetDebug == null) {
    return [];
  }

  return regionbusesNorthcoastGetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesNorthcoastGetDebug>
    regionbusesNorthcoastGetDebugListFromJson(
  List? regionbusesNorthcoastGetDebug, [
  List<enums.RegionbusesNorthcoastGetDebug>? defaultValue,
]) {
  if (regionbusesNorthcoastGetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesNorthcoastGetDebug
      .map((e) => regionbusesNorthcoastGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesNorthcoastGetDebug>?
    regionbusesNorthcoastGetDebugNullableListFromJson(
  List? regionbusesNorthcoastGetDebug, [
  List<enums.RegionbusesNorthcoastGetDebug>? defaultValue,
]) {
  if (regionbusesNorthcoastGetDebug == null) {
    return defaultValue;
  }

  return regionbusesNorthcoastGetDebug
      .map((e) => regionbusesNorthcoastGetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesNorthcoast2GetDebugNullableToJson(
  enums.RegionbusesNorthcoast2GetDebug? regionbusesNorthcoast2GetDebug,
) {
  return regionbusesNorthcoast2GetDebug?.value;
}

String? regionbusesNorthcoast2GetDebugToJson(
  enums.RegionbusesNorthcoast2GetDebug regionbusesNorthcoast2GetDebug,
) {
  return regionbusesNorthcoast2GetDebug.value;
}

enums.RegionbusesNorthcoast2GetDebug regionbusesNorthcoast2GetDebugFromJson(
  Object? regionbusesNorthcoast2GetDebug, [
  enums.RegionbusesNorthcoast2GetDebug? defaultValue,
]) {
  return enums.RegionbusesNorthcoast2GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNorthcoast2GetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesNorthcoast2GetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesNorthcoast2GetDebug?
    regionbusesNorthcoast2GetDebugNullableFromJson(
  Object? regionbusesNorthcoast2GetDebug, [
  enums.RegionbusesNorthcoast2GetDebug? defaultValue,
]) {
  if (regionbusesNorthcoast2GetDebug == null) {
    return null;
  }
  return enums.RegionbusesNorthcoast2GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNorthcoast2GetDebug,
      ) ??
      defaultValue;
}

String regionbusesNorthcoast2GetDebugExplodedListToJson(
  List<enums.RegionbusesNorthcoast2GetDebug>? regionbusesNorthcoast2GetDebug,
) {
  return regionbusesNorthcoast2GetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> regionbusesNorthcoast2GetDebugListToJson(
  List<enums.RegionbusesNorthcoast2GetDebug>? regionbusesNorthcoast2GetDebug,
) {
  if (regionbusesNorthcoast2GetDebug == null) {
    return [];
  }

  return regionbusesNorthcoast2GetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesNorthcoast2GetDebug>
    regionbusesNorthcoast2GetDebugListFromJson(
  List? regionbusesNorthcoast2GetDebug, [
  List<enums.RegionbusesNorthcoast2GetDebug>? defaultValue,
]) {
  if (regionbusesNorthcoast2GetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesNorthcoast2GetDebug
      .map((e) => regionbusesNorthcoast2GetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesNorthcoast2GetDebug>?
    regionbusesNorthcoast2GetDebugNullableListFromJson(
  List? regionbusesNorthcoast2GetDebug, [
  List<enums.RegionbusesNorthcoast2GetDebug>? defaultValue,
]) {
  if (regionbusesNorthcoast2GetDebug == null) {
    return defaultValue;
  }

  return regionbusesNorthcoast2GetDebug
      .map((e) => regionbusesNorthcoast2GetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesNorthcoast3GetDebugNullableToJson(
  enums.RegionbusesNorthcoast3GetDebug? regionbusesNorthcoast3GetDebug,
) {
  return regionbusesNorthcoast3GetDebug?.value;
}

String? regionbusesNorthcoast3GetDebugToJson(
  enums.RegionbusesNorthcoast3GetDebug regionbusesNorthcoast3GetDebug,
) {
  return regionbusesNorthcoast3GetDebug.value;
}

enums.RegionbusesNorthcoast3GetDebug regionbusesNorthcoast3GetDebugFromJson(
  Object? regionbusesNorthcoast3GetDebug, [
  enums.RegionbusesNorthcoast3GetDebug? defaultValue,
]) {
  return enums.RegionbusesNorthcoast3GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNorthcoast3GetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesNorthcoast3GetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesNorthcoast3GetDebug?
    regionbusesNorthcoast3GetDebugNullableFromJson(
  Object? regionbusesNorthcoast3GetDebug, [
  enums.RegionbusesNorthcoast3GetDebug? defaultValue,
]) {
  if (regionbusesNorthcoast3GetDebug == null) {
    return null;
  }
  return enums.RegionbusesNorthcoast3GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesNorthcoast3GetDebug,
      ) ??
      defaultValue;
}

String regionbusesNorthcoast3GetDebugExplodedListToJson(
  List<enums.RegionbusesNorthcoast3GetDebug>? regionbusesNorthcoast3GetDebug,
) {
  return regionbusesNorthcoast3GetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> regionbusesNorthcoast3GetDebugListToJson(
  List<enums.RegionbusesNorthcoast3GetDebug>? regionbusesNorthcoast3GetDebug,
) {
  if (regionbusesNorthcoast3GetDebug == null) {
    return [];
  }

  return regionbusesNorthcoast3GetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesNorthcoast3GetDebug>
    regionbusesNorthcoast3GetDebugListFromJson(
  List? regionbusesNorthcoast3GetDebug, [
  List<enums.RegionbusesNorthcoast3GetDebug>? defaultValue,
]) {
  if (regionbusesNorthcoast3GetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesNorthcoast3GetDebug
      .map((e) => regionbusesNorthcoast3GetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesNorthcoast3GetDebug>?
    regionbusesNorthcoast3GetDebugNullableListFromJson(
  List? regionbusesNorthcoast3GetDebug, [
  List<enums.RegionbusesNorthcoast3GetDebug>? defaultValue,
]) {
  if (regionbusesNorthcoast3GetDebug == null) {
    return defaultValue;
  }

  return regionbusesNorthcoast3GetDebug
      .map((e) => regionbusesNorthcoast3GetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesRiverinamurrayGetDebugNullableToJson(
  enums.RegionbusesRiverinamurrayGetDebug? regionbusesRiverinamurrayGetDebug,
) {
  return regionbusesRiverinamurrayGetDebug?.value;
}

String? regionbusesRiverinamurrayGetDebugToJson(
  enums.RegionbusesRiverinamurrayGetDebug regionbusesRiverinamurrayGetDebug,
) {
  return regionbusesRiverinamurrayGetDebug.value;
}

enums.RegionbusesRiverinamurrayGetDebug
    regionbusesRiverinamurrayGetDebugFromJson(
  Object? regionbusesRiverinamurrayGetDebug, [
  enums.RegionbusesRiverinamurrayGetDebug? defaultValue,
]) {
  return enums.RegionbusesRiverinamurrayGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesRiverinamurrayGetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesRiverinamurrayGetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesRiverinamurrayGetDebug?
    regionbusesRiverinamurrayGetDebugNullableFromJson(
  Object? regionbusesRiverinamurrayGetDebug, [
  enums.RegionbusesRiverinamurrayGetDebug? defaultValue,
]) {
  if (regionbusesRiverinamurrayGetDebug == null) {
    return null;
  }
  return enums.RegionbusesRiverinamurrayGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesRiverinamurrayGetDebug,
      ) ??
      defaultValue;
}

String regionbusesRiverinamurrayGetDebugExplodedListToJson(
  List<enums.RegionbusesRiverinamurrayGetDebug>?
      regionbusesRiverinamurrayGetDebug,
) {
  return regionbusesRiverinamurrayGetDebug?.map((e) => e.value!).join(',') ??
      '';
}

List<String> regionbusesRiverinamurrayGetDebugListToJson(
  List<enums.RegionbusesRiverinamurrayGetDebug>?
      regionbusesRiverinamurrayGetDebug,
) {
  if (regionbusesRiverinamurrayGetDebug == null) {
    return [];
  }

  return regionbusesRiverinamurrayGetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesRiverinamurrayGetDebug>
    regionbusesRiverinamurrayGetDebugListFromJson(
  List? regionbusesRiverinamurrayGetDebug, [
  List<enums.RegionbusesRiverinamurrayGetDebug>? defaultValue,
]) {
  if (regionbusesRiverinamurrayGetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesRiverinamurrayGetDebug
      .map((e) => regionbusesRiverinamurrayGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesRiverinamurrayGetDebug>?
    regionbusesRiverinamurrayGetDebugNullableListFromJson(
  List? regionbusesRiverinamurrayGetDebug, [
  List<enums.RegionbusesRiverinamurrayGetDebug>? defaultValue,
]) {
  if (regionbusesRiverinamurrayGetDebug == null) {
    return defaultValue;
  }

  return regionbusesRiverinamurrayGetDebug
      .map((e) => regionbusesRiverinamurrayGetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesRiverinamurray2GetDebugNullableToJson(
  enums.RegionbusesRiverinamurray2GetDebug? regionbusesRiverinamurray2GetDebug,
) {
  return regionbusesRiverinamurray2GetDebug?.value;
}

String? regionbusesRiverinamurray2GetDebugToJson(
  enums.RegionbusesRiverinamurray2GetDebug regionbusesRiverinamurray2GetDebug,
) {
  return regionbusesRiverinamurray2GetDebug.value;
}

enums.RegionbusesRiverinamurray2GetDebug
    regionbusesRiverinamurray2GetDebugFromJson(
  Object? regionbusesRiverinamurray2GetDebug, [
  enums.RegionbusesRiverinamurray2GetDebug? defaultValue,
]) {
  return enums.RegionbusesRiverinamurray2GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesRiverinamurray2GetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesRiverinamurray2GetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesRiverinamurray2GetDebug?
    regionbusesRiverinamurray2GetDebugNullableFromJson(
  Object? regionbusesRiverinamurray2GetDebug, [
  enums.RegionbusesRiverinamurray2GetDebug? defaultValue,
]) {
  if (regionbusesRiverinamurray2GetDebug == null) {
    return null;
  }
  return enums.RegionbusesRiverinamurray2GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesRiverinamurray2GetDebug,
      ) ??
      defaultValue;
}

String regionbusesRiverinamurray2GetDebugExplodedListToJson(
  List<enums.RegionbusesRiverinamurray2GetDebug>?
      regionbusesRiverinamurray2GetDebug,
) {
  return regionbusesRiverinamurray2GetDebug?.map((e) => e.value!).join(',') ??
      '';
}

List<String> regionbusesRiverinamurray2GetDebugListToJson(
  List<enums.RegionbusesRiverinamurray2GetDebug>?
      regionbusesRiverinamurray2GetDebug,
) {
  if (regionbusesRiverinamurray2GetDebug == null) {
    return [];
  }

  return regionbusesRiverinamurray2GetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesRiverinamurray2GetDebug>
    regionbusesRiverinamurray2GetDebugListFromJson(
  List? regionbusesRiverinamurray2GetDebug, [
  List<enums.RegionbusesRiverinamurray2GetDebug>? defaultValue,
]) {
  if (regionbusesRiverinamurray2GetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesRiverinamurray2GetDebug
      .map((e) => regionbusesRiverinamurray2GetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesRiverinamurray2GetDebug>?
    regionbusesRiverinamurray2GetDebugNullableListFromJson(
  List? regionbusesRiverinamurray2GetDebug, [
  List<enums.RegionbusesRiverinamurray2GetDebug>? defaultValue,
]) {
  if (regionbusesRiverinamurray2GetDebug == null) {
    return defaultValue;
  }

  return regionbusesRiverinamurray2GetDebug
      .map((e) => regionbusesRiverinamurray2GetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesSoutheasttablelandsGetDebugNullableToJson(
  enums.RegionbusesSoutheasttablelandsGetDebug?
      regionbusesSoutheasttablelandsGetDebug,
) {
  return regionbusesSoutheasttablelandsGetDebug?.value;
}

String? regionbusesSoutheasttablelandsGetDebugToJson(
  enums.RegionbusesSoutheasttablelandsGetDebug
      regionbusesSoutheasttablelandsGetDebug,
) {
  return regionbusesSoutheasttablelandsGetDebug.value;
}

enums.RegionbusesSoutheasttablelandsGetDebug
    regionbusesSoutheasttablelandsGetDebugFromJson(
  Object? regionbusesSoutheasttablelandsGetDebug, [
  enums.RegionbusesSoutheasttablelandsGetDebug? defaultValue,
]) {
  return enums.RegionbusesSoutheasttablelandsGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesSoutheasttablelandsGetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesSoutheasttablelandsGetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesSoutheasttablelandsGetDebug?
    regionbusesSoutheasttablelandsGetDebugNullableFromJson(
  Object? regionbusesSoutheasttablelandsGetDebug, [
  enums.RegionbusesSoutheasttablelandsGetDebug? defaultValue,
]) {
  if (regionbusesSoutheasttablelandsGetDebug == null) {
    return null;
  }
  return enums.RegionbusesSoutheasttablelandsGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesSoutheasttablelandsGetDebug,
      ) ??
      defaultValue;
}

String regionbusesSoutheasttablelandsGetDebugExplodedListToJson(
  List<enums.RegionbusesSoutheasttablelandsGetDebug>?
      regionbusesSoutheasttablelandsGetDebug,
) {
  return regionbusesSoutheasttablelandsGetDebug
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> regionbusesSoutheasttablelandsGetDebugListToJson(
  List<enums.RegionbusesSoutheasttablelandsGetDebug>?
      regionbusesSoutheasttablelandsGetDebug,
) {
  if (regionbusesSoutheasttablelandsGetDebug == null) {
    return [];
  }

  return regionbusesSoutheasttablelandsGetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesSoutheasttablelandsGetDebug>
    regionbusesSoutheasttablelandsGetDebugListFromJson(
  List? regionbusesSoutheasttablelandsGetDebug, [
  List<enums.RegionbusesSoutheasttablelandsGetDebug>? defaultValue,
]) {
  if (regionbusesSoutheasttablelandsGetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesSoutheasttablelandsGetDebug
      .map((e) => regionbusesSoutheasttablelandsGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesSoutheasttablelandsGetDebug>?
    regionbusesSoutheasttablelandsGetDebugNullableListFromJson(
  List? regionbusesSoutheasttablelandsGetDebug, [
  List<enums.RegionbusesSoutheasttablelandsGetDebug>? defaultValue,
]) {
  if (regionbusesSoutheasttablelandsGetDebug == null) {
    return defaultValue;
  }

  return regionbusesSoutheasttablelandsGetDebug
      .map((e) => regionbusesSoutheasttablelandsGetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesSoutheasttablelands2GetDebugNullableToJson(
  enums.RegionbusesSoutheasttablelands2GetDebug?
      regionbusesSoutheasttablelands2GetDebug,
) {
  return regionbusesSoutheasttablelands2GetDebug?.value;
}

String? regionbusesSoutheasttablelands2GetDebugToJson(
  enums.RegionbusesSoutheasttablelands2GetDebug
      regionbusesSoutheasttablelands2GetDebug,
) {
  return regionbusesSoutheasttablelands2GetDebug.value;
}

enums.RegionbusesSoutheasttablelands2GetDebug
    regionbusesSoutheasttablelands2GetDebugFromJson(
  Object? regionbusesSoutheasttablelands2GetDebug, [
  enums.RegionbusesSoutheasttablelands2GetDebug? defaultValue,
]) {
  return enums.RegionbusesSoutheasttablelands2GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesSoutheasttablelands2GetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesSoutheasttablelands2GetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesSoutheasttablelands2GetDebug?
    regionbusesSoutheasttablelands2GetDebugNullableFromJson(
  Object? regionbusesSoutheasttablelands2GetDebug, [
  enums.RegionbusesSoutheasttablelands2GetDebug? defaultValue,
]) {
  if (regionbusesSoutheasttablelands2GetDebug == null) {
    return null;
  }
  return enums.RegionbusesSoutheasttablelands2GetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesSoutheasttablelands2GetDebug,
      ) ??
      defaultValue;
}

String regionbusesSoutheasttablelands2GetDebugExplodedListToJson(
  List<enums.RegionbusesSoutheasttablelands2GetDebug>?
      regionbusesSoutheasttablelands2GetDebug,
) {
  return regionbusesSoutheasttablelands2GetDebug
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> regionbusesSoutheasttablelands2GetDebugListToJson(
  List<enums.RegionbusesSoutheasttablelands2GetDebug>?
      regionbusesSoutheasttablelands2GetDebug,
) {
  if (regionbusesSoutheasttablelands2GetDebug == null) {
    return [];
  }

  return regionbusesSoutheasttablelands2GetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesSoutheasttablelands2GetDebug>
    regionbusesSoutheasttablelands2GetDebugListFromJson(
  List? regionbusesSoutheasttablelands2GetDebug, [
  List<enums.RegionbusesSoutheasttablelands2GetDebug>? defaultValue,
]) {
  if (regionbusesSoutheasttablelands2GetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesSoutheasttablelands2GetDebug
      .map((e) => regionbusesSoutheasttablelands2GetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesSoutheasttablelands2GetDebug>?
    regionbusesSoutheasttablelands2GetDebugNullableListFromJson(
  List? regionbusesSoutheasttablelands2GetDebug, [
  List<enums.RegionbusesSoutheasttablelands2GetDebug>? defaultValue,
]) {
  if (regionbusesSoutheasttablelands2GetDebug == null) {
    return defaultValue;
  }

  return regionbusesSoutheasttablelands2GetDebug
      .map((e) => regionbusesSoutheasttablelands2GetDebugFromJson(e.toString()))
      .toList();
}

String? regionbusesSydneysurroundsGetDebugNullableToJson(
  enums.RegionbusesSydneysurroundsGetDebug? regionbusesSydneysurroundsGetDebug,
) {
  return regionbusesSydneysurroundsGetDebug?.value;
}

String? regionbusesSydneysurroundsGetDebugToJson(
  enums.RegionbusesSydneysurroundsGetDebug regionbusesSydneysurroundsGetDebug,
) {
  return regionbusesSydneysurroundsGetDebug.value;
}

enums.RegionbusesSydneysurroundsGetDebug
    regionbusesSydneysurroundsGetDebugFromJson(
  Object? regionbusesSydneysurroundsGetDebug, [
  enums.RegionbusesSydneysurroundsGetDebug? defaultValue,
]) {
  return enums.RegionbusesSydneysurroundsGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesSydneysurroundsGetDebug,
      ) ??
      defaultValue ??
      enums.RegionbusesSydneysurroundsGetDebug.swaggerGeneratedUnknown;
}

enums.RegionbusesSydneysurroundsGetDebug?
    regionbusesSydneysurroundsGetDebugNullableFromJson(
  Object? regionbusesSydneysurroundsGetDebug, [
  enums.RegionbusesSydneysurroundsGetDebug? defaultValue,
]) {
  if (regionbusesSydneysurroundsGetDebug == null) {
    return null;
  }
  return enums.RegionbusesSydneysurroundsGetDebug.values.firstWhereOrNull(
        (e) => e.value == regionbusesSydneysurroundsGetDebug,
      ) ??
      defaultValue;
}

String regionbusesSydneysurroundsGetDebugExplodedListToJson(
  List<enums.RegionbusesSydneysurroundsGetDebug>?
      regionbusesSydneysurroundsGetDebug,
) {
  return regionbusesSydneysurroundsGetDebug?.map((e) => e.value!).join(',') ??
      '';
}

List<String> regionbusesSydneysurroundsGetDebugListToJson(
  List<enums.RegionbusesSydneysurroundsGetDebug>?
      regionbusesSydneysurroundsGetDebug,
) {
  if (regionbusesSydneysurroundsGetDebug == null) {
    return [];
  }

  return regionbusesSydneysurroundsGetDebug.map((e) => e.value!).toList();
}

List<enums.RegionbusesSydneysurroundsGetDebug>
    regionbusesSydneysurroundsGetDebugListFromJson(
  List? regionbusesSydneysurroundsGetDebug, [
  List<enums.RegionbusesSydneysurroundsGetDebug>? defaultValue,
]) {
  if (regionbusesSydneysurroundsGetDebug == null) {
    return defaultValue ?? [];
  }

  return regionbusesSydneysurroundsGetDebug
      .map((e) => regionbusesSydneysurroundsGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesSydneysurroundsGetDebug>?
    regionbusesSydneysurroundsGetDebugNullableListFromJson(
  List? regionbusesSydneysurroundsGetDebug, [
  List<enums.RegionbusesSydneysurroundsGetDebug>? defaultValue,
]) {
  if (regionbusesSydneysurroundsGetDebug == null) {
    return defaultValue;
  }

  return regionbusesSydneysurroundsGetDebug
      .map((e) => regionbusesSydneysurroundsGetDebugFromJson(e.toString()))
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
        body: DateTime.parse((response.body as String).replaceAll('"', ''))
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
