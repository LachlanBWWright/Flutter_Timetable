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
import 'realtime_positions_v2.enums.swagger.dart' as enums;
export 'realtime_positions_v2.enums.swagger.dart';

part 'realtime_positions_v2.swagger.chopper.dart';
part 'realtime_positions_v2.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class RealtimePositionsV2 extends ChopperService {
  static RealtimePositionsV2 create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$RealtimePositionsV2(client);
    }

    final newClient = ChopperClient(
        services: [_$RealtimePositionsV2()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ??
            Uri.parse('http://api.transport.nsw.gov.au/v2/gtfs/vehiclepos'));
    return _$RealtimePositionsV2(newClient);
  }

  ///GTFS-realtime vehicle positions for Sydney Trains
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> sydneytrainsGet(
      {enums.SydneytrainsGetDebug? debug}) {
    return _sydneytrainsGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime vehicle positions for Sydney Trains
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @Get(path: '/sydneytrains')
  Future<chopper.Response<List<int>>> _sydneytrainsGet(
      {@Query('debug') String? debug});

  ///GTFS-realtime vehicle positions for Sydney Trains
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  Future<chopper.Response<List<int>>> metroGet({enums.MetroGetDebug? debug}) {
    return _metroGet(debug: debug?.value?.toString());
  }

  ///GTFS-realtime vehicle positions for Sydney Trains
  ///@param debug Retrieve protocol messages in a text, text-based format.  <br> Note return message may be truncated
  @Get(path: '/metro')
  Future<chopper.Response<List<int>>> _metroGet(
      {@Query('debug') String? debug});
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

extension $ErrorDetailsExtension on ErrorDetails {
  ErrorDetails copyWith(
      {String? errorDateTime,
      String? message,
      String? requestedMethod,
      String? requestedUrl,
      String? transactionId}) {
    return ErrorDetails(
        errorDateTime: errorDateTime ?? this.errorDateTime,
        message: message ?? this.message,
        requestedMethod: requestedMethod ?? this.requestedMethod,
        requestedUrl: requestedUrl ?? this.requestedUrl,
        transactionId: transactionId ?? this.transactionId);
  }

  ErrorDetails copyWithWrapped(
      {Wrapped<String>? errorDateTime,
      Wrapped<String>? message,
      Wrapped<String>? requestedMethod,
      Wrapped<String>? requestedUrl,
      Wrapped<String>? transactionId}) {
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
            (transactionId != null ? transactionId.value : this.transactionId));
  }
}

String? sydneytrainsGetDebugNullableToJson(
    enums.SydneytrainsGetDebug? sydneytrainsGetDebug) {
  return sydneytrainsGetDebug?.value;
}

String? sydneytrainsGetDebugToJson(
    enums.SydneytrainsGetDebug sydneytrainsGetDebug) {
  return sydneytrainsGetDebug.value;
}

enums.SydneytrainsGetDebug sydneytrainsGetDebugFromJson(
  Object? sydneytrainsGetDebug, [
  enums.SydneytrainsGetDebug? defaultValue,
]) {
  return enums.SydneytrainsGetDebug.values
          .firstWhereOrNull((e) => e.value == sydneytrainsGetDebug) ??
      defaultValue ??
      enums.SydneytrainsGetDebug.swaggerGeneratedUnknown;
}

enums.SydneytrainsGetDebug? sydneytrainsGetDebugNullableFromJson(
  Object? sydneytrainsGetDebug, [
  enums.SydneytrainsGetDebug? defaultValue,
]) {
  if (sydneytrainsGetDebug == null) {
    return null;
  }
  return enums.SydneytrainsGetDebug.values
          .firstWhereOrNull((e) => e.value == sydneytrainsGetDebug) ??
      defaultValue;
}

String sydneytrainsGetDebugExplodedListToJson(
    List<enums.SydneytrainsGetDebug>? sydneytrainsGetDebug) {
  return sydneytrainsGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> sydneytrainsGetDebugListToJson(
    List<enums.SydneytrainsGetDebug>? sydneytrainsGetDebug) {
  if (sydneytrainsGetDebug == null) {
    return [];
  }

  return sydneytrainsGetDebug.map((e) => e.value!).toList();
}

List<enums.SydneytrainsGetDebug> sydneytrainsGetDebugListFromJson(
  List? sydneytrainsGetDebug, [
  List<enums.SydneytrainsGetDebug>? defaultValue,
]) {
  if (sydneytrainsGetDebug == null) {
    return defaultValue ?? [];
  }

  return sydneytrainsGetDebug
      .map((e) => sydneytrainsGetDebugFromJson(e.toString()))
      .toList();
}

List<enums.SydneytrainsGetDebug>? sydneytrainsGetDebugNullableListFromJson(
  List? sydneytrainsGetDebug, [
  List<enums.SydneytrainsGetDebug>? defaultValue,
]) {
  if (sydneytrainsGetDebug == null) {
    return defaultValue;
  }

  return sydneytrainsGetDebug
      .map((e) => sydneytrainsGetDebugFromJson(e.toString()))
      .toList();
}

String? metroGetDebugNullableToJson(enums.MetroGetDebug? metroGetDebug) {
  return metroGetDebug?.value;
}

String? metroGetDebugToJson(enums.MetroGetDebug metroGetDebug) {
  return metroGetDebug.value;
}

enums.MetroGetDebug metroGetDebugFromJson(
  Object? metroGetDebug, [
  enums.MetroGetDebug? defaultValue,
]) {
  return enums.MetroGetDebug.values
          .firstWhereOrNull((e) => e.value == metroGetDebug) ??
      defaultValue ??
      enums.MetroGetDebug.swaggerGeneratedUnknown;
}

enums.MetroGetDebug? metroGetDebugNullableFromJson(
  Object? metroGetDebug, [
  enums.MetroGetDebug? defaultValue,
]) {
  if (metroGetDebug == null) {
    return null;
  }
  return enums.MetroGetDebug.values
          .firstWhereOrNull((e) => e.value == metroGetDebug) ??
      defaultValue;
}

String metroGetDebugExplodedListToJson(
    List<enums.MetroGetDebug>? metroGetDebug) {
  return metroGetDebug?.map((e) => e.value!).join(',') ?? '';
}

List<String> metroGetDebugListToJson(List<enums.MetroGetDebug>? metroGetDebug) {
  if (metroGetDebug == null) {
    return [];
  }

  return metroGetDebug.map((e) => e.value!).toList();
}

List<enums.MetroGetDebug> metroGetDebugListFromJson(
  List? metroGetDebug, [
  List<enums.MetroGetDebug>? defaultValue,
]) {
  if (metroGetDebug == null) {
    return defaultValue ?? [];
  }

  return metroGetDebug.map((e) => metroGetDebugFromJson(e.toString())).toList();
}

List<enums.MetroGetDebug>? metroGetDebugNullableListFromJson(
  List? metroGetDebug, [
  List<enums.MetroGetDebug>? defaultValue,
]) {
  if (metroGetDebug == null) {
    return defaultValue;
  }

  return metroGetDebug.map((e) => metroGetDebugFromJson(e.toString())).toList();
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
