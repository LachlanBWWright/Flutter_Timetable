// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_trip_update_v1.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$RealtimeTripUpdateV1 extends RealtimeTripUpdateV1 {
  _$RealtimeTripUpdateV1([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = RealtimeTripUpdateV1;

  @override
  Future<Response<List<int>>> _busesGet({String? debug}) {
    final Uri $url = Uri.parse('/buses');
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
  Future<Response<List<int>>> _ferriesSydneyferriesGet({String? debug}) {
    final Uri $url = Uri.parse('/ferries/sydneyferries');
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
  Future<Response<List<int>>> _ferriesMFFGet({String? debug}) {
    final Uri $url = Uri.parse('/ferries/MFF');
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
  Future<Response<List<int>>> _lightrailCbdandsoutheastGet({String? debug}) {
    final Uri $url = Uri.parse('/lightrail/cbdandsoutheast');
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
  Future<Response<List<int>>> _lightrailInnerwestGet({String? debug}) {
    final Uri $url = Uri.parse('/lightrail/innerwest');
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
  Future<Response<List<int>>> _lightrailNewcastleGet({String? debug}) {
    final Uri $url = Uri.parse('/lightrail/newcastle');
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
  Future<Response<List<int>>> _lightrailParramattaGet({String? debug}) {
    final Uri $url = Uri.parse('/lightrail/parramatta');
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
  Future<Response<List<int>>> _nswtrainsGet({String? debug}) {
    final Uri $url = Uri.parse('/nswtrains');
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
  Future<Response<List<int>>> _regionbusesCentralwestandoranaGet(
      {String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/centralwestandorana');
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
  Future<Response<List<int>>> _regionbusesCentralwestandorana2Get(
      {String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/centralwestandorana2');
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
  Future<Response<List<int>>> _regionbusesFarwestGet({String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/farwest');
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
  Future<Response<List<int>>> _regionbusesNewcastlehunterGet({String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/newcastlehunter');
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
  Future<Response<List<int>>> _regionbusesNewenglandnorthwestGet(
      {String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/newenglandnorthwest');
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
  Future<Response<List<int>>> _regionbusesNorthcoastGet({String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/northcoast');
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
  Future<Response<List<int>>> _regionbusesNorthcoast2Get({String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/northcoast2');
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
  Future<Response<List<int>>> _regionbusesNorthcoast3Get({String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/northcoast3');
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
  Future<Response<List<int>>> _regionbusesRiverinamurrayGet({String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/riverinamurray');
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
  Future<Response<List<int>>> _regionbusesRiverinamurray2Get({String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/riverinamurray2');
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
  Future<Response<List<int>>> _regionbusesSoutheasttablelandsGet(
      {String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/southeasttablelands');
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
  Future<Response<List<int>>> _regionbusesSoutheasttablelands2Get(
      {String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/southeasttablelands2');
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
  Future<Response<List<int>>> _regionbusesSydneysurroundsGet({String? debug}) {
    final Uri $url = Uri.parse('/regionbuses/sydneysurrounds');
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
