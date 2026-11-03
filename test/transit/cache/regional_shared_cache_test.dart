import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/northern_territory/nt_gtfs.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:lbww_flutter/queensland/translink/translink_endpoints.dart';
import 'package:lbww_flutter/services/app_http_client.dart';
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/south_australia/adelaide_metro/adelaide_metro_endpoints.dart';
import 'package:lbww_flutter/tasmania/tasmania_gtfs.dart';
import 'package:lbww_flutter/transit/cache/provider_sources.dart';
import 'package:lbww_flutter/transit/cache/realtime_query.dart';
import 'package:lbww_flutter/transit/cache/shared_transit_cache.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';
import 'package:lbww_flutter/victoria/services/victoria_gtfs_endpoints.dart';
import 'package:lbww_flutter/western_australia/transperth_gtfs.dart';
import 'package:lbww_flutter/wrappers/app_http_client_impl.dart';

void main() {
  final endpoint = Uri.parse('https://cache.example/transitCache');
  final fetched = DateTime.now().toUtc().subtract(const Duration(seconds: 10));
  final feed = FeedMessage(
    header: FeedHeader(gtfsRealtimeVersion: '2.0'),
    entity: [
      FeedEntity(
        id: 'a',
        vehicle: VehiclePosition(
          vehicle: VehicleDescriptor(id: 'bus'),
          trip: TripDescriptor(tripId: 'trip-a', routeId: 'route-a'),
          position: Position(latitude: -33, longitude: 151),
        ),
      ),
    ],
  ).writeToBuffer();
  final zip = ZipEncoder().encode(
    Archive()..addFile(ArchiveFile('stops.txt', 3, utf8.encode('id\n'))),
  );
  Map<String, String> headers({bool isStatic = false}) => {
    'x-transit-version': '1',
    'x-transit-fetched-at': fetched.toIso8601String(),
    'x-transit-expires-at': fetched
        .add(Duration(seconds: isStatic ? 21600 : 30))
        .toIso8601String(),
  };

  setUpAll(() {
    dotenv.loadFromString(envString: 'FIREBASE_CACHE_URL=$endpoint');
  });
  setUp(() => SharedTransitCache.instance.invalidate());

  test('shared source catalog covers every default regional feed', () {
    expect(sharedProviderSources, {
      for (final feed in translinkStaticGtfsFeeds) feed.url: 'static',
      for (final feed in translinkRealtimeFeedSets) ...{
        feed.tripUpdatesUrl: 'realtime',
        feed.vehiclePositionsUrl: 'realtime',
        feed.alertsUrl: 'realtime',
      },
      victoriaStaticGtfsUrl: 'static',
      for (final feed in victoriaRealtimeFeedSets) ...{
        feed.tripUpdatesUrl: 'realtime',
        feed.vehiclePositionsUrl: 'realtime',
        if (feed.alertsUrl != null) feed.alertsUrl!: 'realtime',
      },
      adelaideMetroStaticGtfsUrl: 'static',
      adelaideMetroVehiclePositionsUrl: 'realtime',
      adelaideMetroTripUpdatesUrl: 'realtime',
      adelaideMetroServiceAlertsUrl: 'realtime',
      tasmaniaGtfsUrl: 'static',
      ntDarwinGtfsUrl: 'static',
      ntAliceSpringsGtfsUrl: 'static',
      transperthGtfsUrl: 'static',
    });
  });

  final repositories = <String, RealtimeRepository>{
    'victoria': const VictoriaRealtimeRepository(),
    'queensland': const TranslinkRealtimeRepository(),
    'adelaide': const AdelaideMetroRealtimeRepository(),
  };
  for (final entry in repositories.entries) {
    test(
      '${entry.key} realtime uses Firebase, scoped queries and original age',
      () async {
        var requests = 0;
        await http.runWithClient(
          () async {
            for (var i = 0; i < 2; i++) {
              final snapshot = await entry.value.getVehiclePositions(
                RealtimeRequest(query: RealtimeQuery(tripIds: ['trip-a'])),
              );
              expect(snapshot.items.single.id, 'bus');
              expect(snapshot.fetchedAt, fetched);
            }
          },
          () => MockClient((request) async {
            expect(request.url, endpoint);
            expect(request.headers.containsKey('authorization'), isFalse);
            expect(request.headers.containsKey('keyid'), isFalse);
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['filter'], {
              'tripIds': ['trip-a'],
            });
            requests++;
            return http.Response.bytes(feed, 200, headers: headers());
          }),
        );
        expect(requests, 1);
      },
    );

    test(
      '${entry.key} falls back to original provider when Firebase fails',
      () async {
        final urls = <Uri>[];
        await http.runWithClient(
          () async {
            final snapshot = await entry.value.getVehiclePositions(
              const RealtimeRequest(),
            );
            expect(snapshot.items.single.id, 'bus');
          },
          () => MockClient((request) async {
            urls.add(request.url);
            return request.url == endpoint
                ? http.Response('offline', 503)
                : http.Response.bytes(feed, 200);
          }),
        );
        expect(urls, hasLength(2));
        expect(urls.first, endpoint);
        expect(urls.last.host, isNot(endpoint.host));
      },
    );
  }

  test(
    'all regional static URLs use Firebase and valid ZIP responses',
    () async {
      final cache = SharedTransitCache(endpoint: endpoint);
      final urls = sharedProviderSources.entries
          .where((entry) => entry.value == 'static')
          .map((entry) => Uri.parse(entry.key))
          .toList();
      var requests = 0;
      final client = MockClient((request) async {
        expect(request.url, endpoint);
        requests++;
        return http.Response.bytes(zip, 200, headers: headers(isStatic: true));
      });
      for (final url in urls) {
        final result = await AppHttpClient.get(
          url,
          sharedCache: cache,
          client: client,
        );
        expect(result!.bodyBytes, zip);
      }
      expect(requests, urls.length);
    },
  );

  test(
    'archive pointer downloads directly from Storage without provider keys',
    () async {
      final cache = SharedTransitCache(endpoint: endpoint);
      final url = Uri.parse(
        sharedProviderSources.entries
            .firstWhere((entry) => entry.value == 'static')
            .key,
      );
      final storage = Uri.parse(
        'https://firebasestorage.googleapis.com/v0/b/project/o/transit-cache%2Ffeed?alt=media&token=public-data',
      );
      final seen = <Uri>[];
      final client = MockClient((request) async {
        seen.add(request.url);
        expect(request.headers.containsKey('authorization'), isFalse);
        if (request.url == endpoint) {
          return http.Response(
            '',
            200,
            headers: {
              ...headers(isStatic: true),
              'x-transit-download-url': storage.toString(),
            },
          );
        }
        expect(request.url, storage);
        return http.Response.bytes(zip, 200);
      });
      final response = await AppHttpClient.get(
        url,
        headers: {'Authorization': 'private'},
        client: client,
        sharedCache: cache,
      );
      expect(response!.bodyBytes, zip);
      expect(seen, [endpoint, storage]);
    },
  );

  test(
    'PTV device signatures never reach Firebase; direct fallback retains them',
    () async {
      final url = Uri.parse(
        'https://timetableapi.ptv.vic.gov.au/v3/search/Central?devid=device-id&signature=device-signature&include_outlets=false',
      );
      final seen = <Uri>[];
      final cache = SharedTransitCache(endpoint: endpoint);
      final client = BoundedHttpClient(
        sharedCache: cache,
        inner: MockClient((request) async {
          seen.add(request.url);
          if (request.url == endpoint) {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['url'].toString(), isNot(contains('signature')));
            expect(body['url'].toString(), isNot(contains('device-id')));
            return http.Response('offline', 503);
          }
          expect(request.url, url);
          return http.Response('{"stops":[]}', 200);
        }),
      );
      expect((await client.get(url)).body, '{"stops":[]}');
      expect(seen, [endpoint, url]);
      client.close();
    },
  );

  test('PTV JSON hits avoid the signed upstream request', () async {
    final cache = SharedTransitCache(endpoint: endpoint);
    final url = Uri.parse(
      'https://timetableapi.ptv.vic.gov.au/v3/departures/route_type/0/stop/1?devid=1&signature=private&max_results=20',
    );
    final client = BoundedHttpClient(
      sharedCache: cache,
      inner: MockClient((request) async {
        expect(request.url, endpoint);
        return http.Response('{"departures":[]}', 200, headers: headers());
      }),
    );
    expect((await client.get(url)).body, '{"departures":[]}');
    client.close();
  });
  test(
    'PTV disruption lookups strip credentials even with no other parameters',
    () async {
      final cache = SharedTransitCache(endpoint: endpoint);
      final url = Uri.parse(
        'https://timetableapi.ptv.vic.gov.au/v3/disruptions?devid=device&signature=private',
      );
      final client = MockClient((request) async {
        expect(request.url, endpoint);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final upstream = Uri.parse(body['url'] as String);
        expect(upstream.queryParameters, isEmpty);
        return http.Response('{"disruptions":{}}', 200, headers: headers());
      });
      expect(
        (await cache.lookup(url, client: client))!.body,
        '{"disruptions":{}}',
      );
    },
  );

  test('failed Storage downloads fall back to original archive URL', () async {
    final cache = SharedTransitCache(endpoint: endpoint);
    final provider = Uri.parse(
      sharedProviderSources.entries
          .firstWhere((entry) => entry.value == 'static')
          .key,
    );
    final seen = <Uri>[];
    final storage = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/test/o/archive',
    );
    final client = MockClient((request) async {
      seen.add(request.url);
      if (request.url == endpoint) {
        return http.Response(
          '',
          200,
          headers: {
            ...headers(isStatic: true),
            'x-transit-download-url': storage.toString(),
          },
        );
      }
      if (request.url == storage) return http.Response('missing', 404);
      expect(request.url, provider);
      return http.Response.bytes(zip, 200);
    });
    expect(
      (await AppHttpClient.get(
        provider,
        client: client,
        sharedCache: cache,
      ))!.bodyBytes,
      zip,
    );
    expect(seen, [endpoint, storage, provider]);
  });
  test(
    'PTV departures use backend credentials without device credentials',
    () async {
      const stop = TransitStopRef(
        region: TransitRegion.victoria,
        provider: TransitProviderId.ptv,
        sourceId: TransitSourceId('ptv:route_type:0'),
        stopId: '1',
      );
      await http.runWithClient(
        () async {
          final departures = await PtvDepartureRepository().getDepartures(
            const DepartureRequest(stop: stop),
          );
          expect(departures.single.route!.name, 'Train');
          expect(departures.single.destinationName, 'City');
        },
        () => MockClient((request) async {
          expect(request.url, endpoint);
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['url'].toString(), isNot(contains('devid')));
          return http.Response(
            '{"departures":[{"route_id":1,"run_id":2,"direction_id":3}],"routes":{"1":{"route_name":"Train"}},"directions":{"3":{"direction_name":"City"}}}',
            200,
            headers: {...headers(), 'content-type': 'application/json'},
          );
        }),
      );
    },
  );

  test(
    'PTV disruptions use backend credentials without device credentials',
    () async {
      await http.runWithClient(
        () async {
          final alerts = await PtvDisruptionRepository().getDisruptions(
            const DisruptionRequest(),
          );
          expect(alerts.single.title, 'Track works');
        },
        () => MockClient((request) async {
          expect(request.url, endpoint);
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(Uri.parse(body['url'] as String).queryParameters, isEmpty);
          return http.Response(
            '{"disruptions":{"metro_train":[{"disruption_id":1,"title":"Track works"}]}}',
            200,
            headers: {...headers(), 'content-type': 'application/json'},
          );
        }),
      );
    },
  );
}
