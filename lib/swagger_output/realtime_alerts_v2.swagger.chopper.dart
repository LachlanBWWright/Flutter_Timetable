// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_alerts_v2.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$RealtimeAlertsV2 extends RealtimeAlertsV2 {
  _$RealtimeAlertsV2([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = RealtimeAlertsV2;

  @override
  Future<Response<List<int>>> _allGet({String? format}) {
    final Uri $url = Uri.parse('/all');
    final Map<String, dynamic> $params = <String, dynamic>{'format': format};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }

  @override
  Future<Response<List<int>>> _busesGet({String? format}) {
    final Uri $url = Uri.parse('/buses');
    final Map<String, dynamic> $params = <String, dynamic>{'format': format};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }

  @override
  Future<Response<List<int>>> _ferriesGet({String? format}) {
    final Uri $url = Uri.parse('/ferries');
    final Map<String, dynamic> $params = <String, dynamic>{'format': format};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }

  @override
  Future<Response<List<int>>> _lightrailGet({String? format}) {
    final Uri $url = Uri.parse('/lightrail');
    final Map<String, dynamic> $params = <String, dynamic>{'format': format};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }

  @override
  Future<Response<List<int>>> _metroGet({String? format}) {
    final Uri $url = Uri.parse('/metro');
    final Map<String, dynamic> $params = <String, dynamic>{'format': format};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }

  @override
  Future<Response<List<int>>> _nswtrainsGet({String? format}) {
    final Uri $url = Uri.parse('/nswtrains');
    final Map<String, dynamic> $params = <String, dynamic>{'format': format};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }

  @override
  Future<Response<List<int>>> _regionbusesGet({String? format}) {
    final Uri $url = Uri.parse('/regionbuses');
    final Map<String, dynamic> $params = <String, dynamic>{'format': format};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }

  @override
  Future<Response<List<int>>> _sydneytrainsGet({String? format}) {
    final Uri $url = Uri.parse('/sydneytrains');
    final Map<String, dynamic> $params = <String, dynamic>{'format': format};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }
}
