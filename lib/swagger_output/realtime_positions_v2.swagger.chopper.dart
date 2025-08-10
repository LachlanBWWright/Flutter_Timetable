// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_positions_v2.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$RealtimePositionsV2 extends RealtimePositionsV2 {
  _$RealtimePositionsV2([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = RealtimePositionsV2;

  @override
  Future<Response<List<int>>> _sydneytrainsGet({String? debug}) {
    final Uri $url = Uri.parse('/sydneytrains');
    final Map<String, dynamic> $params = <String, dynamic>{'debug': debug};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }

  @override
  Future<Response<List<int>>> _metroGet({String? debug}) {
    final Uri $url = Uri.parse('/metro');
    final Map<String, dynamic> $params = <String, dynamic>{'debug': debug};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<int>, int>($request);
  }
}
