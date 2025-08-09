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
import 'realtime_alerts_v2.enums.swagger.dart' as enums;
export 'realtime_alerts_v2.enums.swagger.dart';

part 'realtime_alerts_v2.swagger.chopper.dart';
part 'realtime_alerts_v2.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class RealtimeAlertsV2 extends ChopperService {
  static RealtimeAlertsV2 create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$RealtimeAlertsV2(client);
    }

    final newClient = ChopperClient(
      services: [_$RealtimeAlertsV2()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl:
          baseUrl ??
          Uri.parse('http://api.transport.nsw.gov.au/v2/gtfs/alerts'),
    );
    return _$RealtimeAlertsV2(newClient);
  }

  ///GTFS-realtime alerts for all Transport for NSW operators
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  Future<chopper.Response<List<int>>> allGet({enums.AllGetFormat? format}) {
    return _allGet(format: format?.value?.toString());
  }

  ///GTFS-realtime alerts for all Transport for NSW operators
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  @GET(path: '/all')
  Future<chopper.Response<List<int>>> _allGet({
    @Query('format') String? format,
  });

  ///GTFS-realtime alerts for Buses
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  Future<chopper.Response<List<int>>> busesGet({enums.BusesGetFormat? format}) {
    return _busesGet(format: format?.value?.toString());
  }

  ///GTFS-realtime alerts for Buses
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  @GET(path: '/buses')
  Future<chopper.Response<List<int>>> _busesGet({
    @Query('format') String? format,
  });

  ///GTFS-realtime alerts for Ferries
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  Future<chopper.Response<List<int>>> ferriesGet({
    enums.FerriesGetFormat? format,
  }) {
    return _ferriesGet(format: format?.value?.toString());
  }

  ///GTFS-realtime alerts for Ferries
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  @GET(path: '/ferries')
  Future<chopper.Response<List<int>>> _ferriesGet({
    @Query('format') String? format,
  });

  ///GTFS-realtime alerts for Light Rail
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  Future<chopper.Response<List<int>>> lightrailGet({
    enums.LightrailGetFormat? format,
  }) {
    return _lightrailGet(format: format?.value?.toString());
  }

  ///GTFS-realtime alerts for Light Rail
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  @GET(path: '/lightrail')
  Future<chopper.Response<List<int>>> _lightrailGet({
    @Query('format') String? format,
  });

  ///GTFS-realtime alerts for Sydney Metro
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  Future<chopper.Response<List<int>>> metroGet({enums.MetroGetFormat? format}) {
    return _metroGet(format: format?.value?.toString());
  }

  ///GTFS-realtime alerts for Sydney Metro
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  @GET(path: '/metro')
  Future<chopper.Response<List<int>>> _metroGet({
    @Query('format') String? format,
  });

  ///GTFS-realtime alerts for NSW Trains
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  Future<chopper.Response<List<int>>> nswtrainsGet({
    enums.NswtrainsGetFormat? format,
  }) {
    return _nswtrainsGet(format: format?.value?.toString());
  }

  ///GTFS-realtime alerts for NSW Trains
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  @GET(path: '/nswtrains')
  Future<chopper.Response<List<int>>> _nswtrainsGet({
    @Query('format') String? format,
  });

  ///GTFS-realtime alerts for Regional Buses
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  Future<chopper.Response<List<int>>> regionbusesGet({
    enums.RegionbusesGetFormat? format,
  }) {
    return _regionbusesGet(format: format?.value?.toString());
  }

  ///GTFS-realtime alerts for Regional Buses
  ///@param format Retrieve protocol messages in a text-based, JSON format.
  @GET(path: '/regionbuses')
  Future<chopper.Response<List<int>>> _regionbusesGet({
    @Query('format') String? format,
  });

  ///GTFS-realtime alerts for Sydney Trains
  ///@param format Retrieve protocol messages in a text-based, JSON format
  Future<chopper.Response<List<int>>> sydneytrainsGet({
    enums.SydneytrainsGetFormat? format,
  }) {
    return _sydneytrainsGet(format: format?.value?.toString());
  }

  ///GTFS-realtime alerts for Sydney Trains
  ///@param format Retrieve protocol messages in a text-based, JSON format
  @GET(path: '/sydneytrains')
  Future<chopper.Response<List<int>>> _sydneytrainsGet({
    @Query('format') String? format,
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
      errorDateTime: (errorDateTime != null
          ? errorDateTime.value
          : this.errorDateTime),
      message: (message != null ? message.value : this.message),
      requestedMethod: (requestedMethod != null
          ? requestedMethod.value
          : this.requestedMethod),
      requestedUrl: (requestedUrl != null
          ? requestedUrl.value
          : this.requestedUrl),
      transactionId: (transactionId != null
          ? transactionId.value
          : this.transactionId),
    );
  }
}

String? allGetFormatNullableToJson(enums.AllGetFormat? allGetFormat) {
  return allGetFormat?.value;
}

String? allGetFormatToJson(enums.AllGetFormat allGetFormat) {
  return allGetFormat.value;
}

enums.AllGetFormat allGetFormatFromJson(
  Object? allGetFormat, [
  enums.AllGetFormat? defaultValue,
]) {
  return enums.AllGetFormat.values.firstWhereOrNull(
        (e) => e.value == allGetFormat,
      ) ??
      defaultValue ??
      enums.AllGetFormat.swaggerGeneratedUnknown;
}

enums.AllGetFormat? allGetFormatNullableFromJson(
  Object? allGetFormat, [
  enums.AllGetFormat? defaultValue,
]) {
  if (allGetFormat == null) {
    return null;
  }
  return enums.AllGetFormat.values.firstWhereOrNull(
        (e) => e.value == allGetFormat,
      ) ??
      defaultValue;
}

String allGetFormatExplodedListToJson(List<enums.AllGetFormat>? allGetFormat) {
  return allGetFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> allGetFormatListToJson(List<enums.AllGetFormat>? allGetFormat) {
  if (allGetFormat == null) {
    return [];
  }

  return allGetFormat.map((e) => e.value!).toList();
}

List<enums.AllGetFormat> allGetFormatListFromJson(
  List? allGetFormat, [
  List<enums.AllGetFormat>? defaultValue,
]) {
  if (allGetFormat == null) {
    return defaultValue ?? [];
  }

  return allGetFormat.map((e) => allGetFormatFromJson(e.toString())).toList();
}

List<enums.AllGetFormat>? allGetFormatNullableListFromJson(
  List? allGetFormat, [
  List<enums.AllGetFormat>? defaultValue,
]) {
  if (allGetFormat == null) {
    return defaultValue;
  }

  return allGetFormat.map((e) => allGetFormatFromJson(e.toString())).toList();
}

String? busesGetFormatNullableToJson(enums.BusesGetFormat? busesGetFormat) {
  return busesGetFormat?.value;
}

String? busesGetFormatToJson(enums.BusesGetFormat busesGetFormat) {
  return busesGetFormat.value;
}

enums.BusesGetFormat busesGetFormatFromJson(
  Object? busesGetFormat, [
  enums.BusesGetFormat? defaultValue,
]) {
  return enums.BusesGetFormat.values.firstWhereOrNull(
        (e) => e.value == busesGetFormat,
      ) ??
      defaultValue ??
      enums.BusesGetFormat.swaggerGeneratedUnknown;
}

enums.BusesGetFormat? busesGetFormatNullableFromJson(
  Object? busesGetFormat, [
  enums.BusesGetFormat? defaultValue,
]) {
  if (busesGetFormat == null) {
    return null;
  }
  return enums.BusesGetFormat.values.firstWhereOrNull(
        (e) => e.value == busesGetFormat,
      ) ??
      defaultValue;
}

String busesGetFormatExplodedListToJson(
  List<enums.BusesGetFormat>? busesGetFormat,
) {
  return busesGetFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> busesGetFormatListToJson(
  List<enums.BusesGetFormat>? busesGetFormat,
) {
  if (busesGetFormat == null) {
    return [];
  }

  return busesGetFormat.map((e) => e.value!).toList();
}

List<enums.BusesGetFormat> busesGetFormatListFromJson(
  List? busesGetFormat, [
  List<enums.BusesGetFormat>? defaultValue,
]) {
  if (busesGetFormat == null) {
    return defaultValue ?? [];
  }

  return busesGetFormat
      .map((e) => busesGetFormatFromJson(e.toString()))
      .toList();
}

List<enums.BusesGetFormat>? busesGetFormatNullableListFromJson(
  List? busesGetFormat, [
  List<enums.BusesGetFormat>? defaultValue,
]) {
  if (busesGetFormat == null) {
    return defaultValue;
  }

  return busesGetFormat
      .map((e) => busesGetFormatFromJson(e.toString()))
      .toList();
}

String? ferriesGetFormatNullableToJson(
  enums.FerriesGetFormat? ferriesGetFormat,
) {
  return ferriesGetFormat?.value;
}

String? ferriesGetFormatToJson(enums.FerriesGetFormat ferriesGetFormat) {
  return ferriesGetFormat.value;
}

enums.FerriesGetFormat ferriesGetFormatFromJson(
  Object? ferriesGetFormat, [
  enums.FerriesGetFormat? defaultValue,
]) {
  return enums.FerriesGetFormat.values.firstWhereOrNull(
        (e) => e.value == ferriesGetFormat,
      ) ??
      defaultValue ??
      enums.FerriesGetFormat.swaggerGeneratedUnknown;
}

enums.FerriesGetFormat? ferriesGetFormatNullableFromJson(
  Object? ferriesGetFormat, [
  enums.FerriesGetFormat? defaultValue,
]) {
  if (ferriesGetFormat == null) {
    return null;
  }
  return enums.FerriesGetFormat.values.firstWhereOrNull(
        (e) => e.value == ferriesGetFormat,
      ) ??
      defaultValue;
}

String ferriesGetFormatExplodedListToJson(
  List<enums.FerriesGetFormat>? ferriesGetFormat,
) {
  return ferriesGetFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> ferriesGetFormatListToJson(
  List<enums.FerriesGetFormat>? ferriesGetFormat,
) {
  if (ferriesGetFormat == null) {
    return [];
  }

  return ferriesGetFormat.map((e) => e.value!).toList();
}

List<enums.FerriesGetFormat> ferriesGetFormatListFromJson(
  List? ferriesGetFormat, [
  List<enums.FerriesGetFormat>? defaultValue,
]) {
  if (ferriesGetFormat == null) {
    return defaultValue ?? [];
  }

  return ferriesGetFormat
      .map((e) => ferriesGetFormatFromJson(e.toString()))
      .toList();
}

List<enums.FerriesGetFormat>? ferriesGetFormatNullableListFromJson(
  List? ferriesGetFormat, [
  List<enums.FerriesGetFormat>? defaultValue,
]) {
  if (ferriesGetFormat == null) {
    return defaultValue;
  }

  return ferriesGetFormat
      .map((e) => ferriesGetFormatFromJson(e.toString()))
      .toList();
}

String? lightrailGetFormatNullableToJson(
  enums.LightrailGetFormat? lightrailGetFormat,
) {
  return lightrailGetFormat?.value;
}

String? lightrailGetFormatToJson(enums.LightrailGetFormat lightrailGetFormat) {
  return lightrailGetFormat.value;
}

enums.LightrailGetFormat lightrailGetFormatFromJson(
  Object? lightrailGetFormat, [
  enums.LightrailGetFormat? defaultValue,
]) {
  return enums.LightrailGetFormat.values.firstWhereOrNull(
        (e) => e.value == lightrailGetFormat,
      ) ??
      defaultValue ??
      enums.LightrailGetFormat.swaggerGeneratedUnknown;
}

enums.LightrailGetFormat? lightrailGetFormatNullableFromJson(
  Object? lightrailGetFormat, [
  enums.LightrailGetFormat? defaultValue,
]) {
  if (lightrailGetFormat == null) {
    return null;
  }
  return enums.LightrailGetFormat.values.firstWhereOrNull(
        (e) => e.value == lightrailGetFormat,
      ) ??
      defaultValue;
}

String lightrailGetFormatExplodedListToJson(
  List<enums.LightrailGetFormat>? lightrailGetFormat,
) {
  return lightrailGetFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> lightrailGetFormatListToJson(
  List<enums.LightrailGetFormat>? lightrailGetFormat,
) {
  if (lightrailGetFormat == null) {
    return [];
  }

  return lightrailGetFormat.map((e) => e.value!).toList();
}

List<enums.LightrailGetFormat> lightrailGetFormatListFromJson(
  List? lightrailGetFormat, [
  List<enums.LightrailGetFormat>? defaultValue,
]) {
  if (lightrailGetFormat == null) {
    return defaultValue ?? [];
  }

  return lightrailGetFormat
      .map((e) => lightrailGetFormatFromJson(e.toString()))
      .toList();
}

List<enums.LightrailGetFormat>? lightrailGetFormatNullableListFromJson(
  List? lightrailGetFormat, [
  List<enums.LightrailGetFormat>? defaultValue,
]) {
  if (lightrailGetFormat == null) {
    return defaultValue;
  }

  return lightrailGetFormat
      .map((e) => lightrailGetFormatFromJson(e.toString()))
      .toList();
}

String? metroGetFormatNullableToJson(enums.MetroGetFormat? metroGetFormat) {
  return metroGetFormat?.value;
}

String? metroGetFormatToJson(enums.MetroGetFormat metroGetFormat) {
  return metroGetFormat.value;
}

enums.MetroGetFormat metroGetFormatFromJson(
  Object? metroGetFormat, [
  enums.MetroGetFormat? defaultValue,
]) {
  return enums.MetroGetFormat.values.firstWhereOrNull(
        (e) => e.value == metroGetFormat,
      ) ??
      defaultValue ??
      enums.MetroGetFormat.swaggerGeneratedUnknown;
}

enums.MetroGetFormat? metroGetFormatNullableFromJson(
  Object? metroGetFormat, [
  enums.MetroGetFormat? defaultValue,
]) {
  if (metroGetFormat == null) {
    return null;
  }
  return enums.MetroGetFormat.values.firstWhereOrNull(
        (e) => e.value == metroGetFormat,
      ) ??
      defaultValue;
}

String metroGetFormatExplodedListToJson(
  List<enums.MetroGetFormat>? metroGetFormat,
) {
  return metroGetFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> metroGetFormatListToJson(
  List<enums.MetroGetFormat>? metroGetFormat,
) {
  if (metroGetFormat == null) {
    return [];
  }

  return metroGetFormat.map((e) => e.value!).toList();
}

List<enums.MetroGetFormat> metroGetFormatListFromJson(
  List? metroGetFormat, [
  List<enums.MetroGetFormat>? defaultValue,
]) {
  if (metroGetFormat == null) {
    return defaultValue ?? [];
  }

  return metroGetFormat
      .map((e) => metroGetFormatFromJson(e.toString()))
      .toList();
}

List<enums.MetroGetFormat>? metroGetFormatNullableListFromJson(
  List? metroGetFormat, [
  List<enums.MetroGetFormat>? defaultValue,
]) {
  if (metroGetFormat == null) {
    return defaultValue;
  }

  return metroGetFormat
      .map((e) => metroGetFormatFromJson(e.toString()))
      .toList();
}

String? nswtrainsGetFormatNullableToJson(
  enums.NswtrainsGetFormat? nswtrainsGetFormat,
) {
  return nswtrainsGetFormat?.value;
}

String? nswtrainsGetFormatToJson(enums.NswtrainsGetFormat nswtrainsGetFormat) {
  return nswtrainsGetFormat.value;
}

enums.NswtrainsGetFormat nswtrainsGetFormatFromJson(
  Object? nswtrainsGetFormat, [
  enums.NswtrainsGetFormat? defaultValue,
]) {
  return enums.NswtrainsGetFormat.values.firstWhereOrNull(
        (e) => e.value == nswtrainsGetFormat,
      ) ??
      defaultValue ??
      enums.NswtrainsGetFormat.swaggerGeneratedUnknown;
}

enums.NswtrainsGetFormat? nswtrainsGetFormatNullableFromJson(
  Object? nswtrainsGetFormat, [
  enums.NswtrainsGetFormat? defaultValue,
]) {
  if (nswtrainsGetFormat == null) {
    return null;
  }
  return enums.NswtrainsGetFormat.values.firstWhereOrNull(
        (e) => e.value == nswtrainsGetFormat,
      ) ??
      defaultValue;
}

String nswtrainsGetFormatExplodedListToJson(
  List<enums.NswtrainsGetFormat>? nswtrainsGetFormat,
) {
  return nswtrainsGetFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> nswtrainsGetFormatListToJson(
  List<enums.NswtrainsGetFormat>? nswtrainsGetFormat,
) {
  if (nswtrainsGetFormat == null) {
    return [];
  }

  return nswtrainsGetFormat.map((e) => e.value!).toList();
}

List<enums.NswtrainsGetFormat> nswtrainsGetFormatListFromJson(
  List? nswtrainsGetFormat, [
  List<enums.NswtrainsGetFormat>? defaultValue,
]) {
  if (nswtrainsGetFormat == null) {
    return defaultValue ?? [];
  }

  return nswtrainsGetFormat
      .map((e) => nswtrainsGetFormatFromJson(e.toString()))
      .toList();
}

List<enums.NswtrainsGetFormat>? nswtrainsGetFormatNullableListFromJson(
  List? nswtrainsGetFormat, [
  List<enums.NswtrainsGetFormat>? defaultValue,
]) {
  if (nswtrainsGetFormat == null) {
    return defaultValue;
  }

  return nswtrainsGetFormat
      .map((e) => nswtrainsGetFormatFromJson(e.toString()))
      .toList();
}

String? regionbusesGetFormatNullableToJson(
  enums.RegionbusesGetFormat? regionbusesGetFormat,
) {
  return regionbusesGetFormat?.value;
}

String? regionbusesGetFormatToJson(
  enums.RegionbusesGetFormat regionbusesGetFormat,
) {
  return regionbusesGetFormat.value;
}

enums.RegionbusesGetFormat regionbusesGetFormatFromJson(
  Object? regionbusesGetFormat, [
  enums.RegionbusesGetFormat? defaultValue,
]) {
  return enums.RegionbusesGetFormat.values.firstWhereOrNull(
        (e) => e.value == regionbusesGetFormat,
      ) ??
      defaultValue ??
      enums.RegionbusesGetFormat.swaggerGeneratedUnknown;
}

enums.RegionbusesGetFormat? regionbusesGetFormatNullableFromJson(
  Object? regionbusesGetFormat, [
  enums.RegionbusesGetFormat? defaultValue,
]) {
  if (regionbusesGetFormat == null) {
    return null;
  }
  return enums.RegionbusesGetFormat.values.firstWhereOrNull(
        (e) => e.value == regionbusesGetFormat,
      ) ??
      defaultValue;
}

String regionbusesGetFormatExplodedListToJson(
  List<enums.RegionbusesGetFormat>? regionbusesGetFormat,
) {
  return regionbusesGetFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> regionbusesGetFormatListToJson(
  List<enums.RegionbusesGetFormat>? regionbusesGetFormat,
) {
  if (regionbusesGetFormat == null) {
    return [];
  }

  return regionbusesGetFormat.map((e) => e.value!).toList();
}

List<enums.RegionbusesGetFormat> regionbusesGetFormatListFromJson(
  List? regionbusesGetFormat, [
  List<enums.RegionbusesGetFormat>? defaultValue,
]) {
  if (regionbusesGetFormat == null) {
    return defaultValue ?? [];
  }

  return regionbusesGetFormat
      .map((e) => regionbusesGetFormatFromJson(e.toString()))
      .toList();
}

List<enums.RegionbusesGetFormat>? regionbusesGetFormatNullableListFromJson(
  List? regionbusesGetFormat, [
  List<enums.RegionbusesGetFormat>? defaultValue,
]) {
  if (regionbusesGetFormat == null) {
    return defaultValue;
  }

  return regionbusesGetFormat
      .map((e) => regionbusesGetFormatFromJson(e.toString()))
      .toList();
}

String? sydneytrainsGetFormatNullableToJson(
  enums.SydneytrainsGetFormat? sydneytrainsGetFormat,
) {
  return sydneytrainsGetFormat?.value;
}

String? sydneytrainsGetFormatToJson(
  enums.SydneytrainsGetFormat sydneytrainsGetFormat,
) {
  return sydneytrainsGetFormat.value;
}

enums.SydneytrainsGetFormat sydneytrainsGetFormatFromJson(
  Object? sydneytrainsGetFormat, [
  enums.SydneytrainsGetFormat? defaultValue,
]) {
  return enums.SydneytrainsGetFormat.values.firstWhereOrNull(
        (e) => e.value == sydneytrainsGetFormat,
      ) ??
      defaultValue ??
      enums.SydneytrainsGetFormat.swaggerGeneratedUnknown;
}

enums.SydneytrainsGetFormat? sydneytrainsGetFormatNullableFromJson(
  Object? sydneytrainsGetFormat, [
  enums.SydneytrainsGetFormat? defaultValue,
]) {
  if (sydneytrainsGetFormat == null) {
    return null;
  }
  return enums.SydneytrainsGetFormat.values.firstWhereOrNull(
        (e) => e.value == sydneytrainsGetFormat,
      ) ??
      defaultValue;
}

String sydneytrainsGetFormatExplodedListToJson(
  List<enums.SydneytrainsGetFormat>? sydneytrainsGetFormat,
) {
  return sydneytrainsGetFormat?.map((e) => e.value!).join(',') ?? '';
}

List<String> sydneytrainsGetFormatListToJson(
  List<enums.SydneytrainsGetFormat>? sydneytrainsGetFormat,
) {
  if (sydneytrainsGetFormat == null) {
    return [];
  }

  return sydneytrainsGetFormat.map((e) => e.value!).toList();
}

List<enums.SydneytrainsGetFormat> sydneytrainsGetFormatListFromJson(
  List? sydneytrainsGetFormat, [
  List<enums.SydneytrainsGetFormat>? defaultValue,
]) {
  if (sydneytrainsGetFormat == null) {
    return defaultValue ?? [];
  }

  return sydneytrainsGetFormat
      .map((e) => sydneytrainsGetFormatFromJson(e.toString()))
      .toList();
}

List<enums.SydneytrainsGetFormat>? sydneytrainsGetFormatNullableListFromJson(
  List? sydneytrainsGetFormat, [
  List<enums.SydneytrainsGetFormat>? defaultValue,
]) {
  if (sydneytrainsGetFormat == null) {
    return defaultValue;
  }

  return sydneytrainsGetFormat
      .map((e) => sydneytrainsGetFormatFromJson(e.toString()))
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
