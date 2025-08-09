// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_timetables_v2.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$RealtimeTimetablesV2 extends RealtimeTimetablesV2 {
  _$RealtimeTimetablesV2([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = RealtimeTimetablesV2;

  @override
  Future<Response<List<int>>> _metroGet() {
    final Uri $url = Uri.parse('/metro');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<int>, int>($request);
  }
}
