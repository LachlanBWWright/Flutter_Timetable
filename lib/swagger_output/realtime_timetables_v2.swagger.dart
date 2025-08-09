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

part 'realtime_timetables_v2.swagger.chopper.dart';
part 'realtime_timetables_v2.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class RealtimeTimetablesV2 extends ChopperService {
  static RealtimeTimetablesV2 create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$RealtimeTimetablesV2(client);
    }

    final newClient = ChopperClient(
        services: [_$RealtimeTimetablesV2()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ??
            Uri.parse('http://api.transport.nsw.gov.au/v2/gtfs/schedule'));
    return _$RealtimeTimetablesV2(newClient);
  }

  ///GTFS timetables, stops, and route shapes for Sydney Metro
  Future<chopper.Response<List<int>>> metroGet() {
    return _metroGet();
  }

  ///GTFS timetables, stops, and route shapes for Sydney Metro
  @Get(path: '/metro')
  Future<chopper.Response<List<int>>> _metroGet();
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
