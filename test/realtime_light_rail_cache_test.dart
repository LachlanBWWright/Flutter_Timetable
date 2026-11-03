import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/nsw/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/nsw/wrappers/realtime_service_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'canonical light rail cannot replace the four-source positions group',
    () async {
      await _withLightRailFeeds(() async {
        final canonical = await RealtimeService.getPositionsForTransportMode(
          TransportMode.lightrail,
        );
        final group = await RealtimeService.getAllLightRailPositions();

        expect(canonical?.entity.single.id, 'cbdandsoutheast');
        expect(
          group.map((feed) => feed?.entity.single.id),
          _allLightRailSources,
        );
      });
    },
  );

  test(
    'canonical light rail cannot replace the four-source updates group',
    () async {
      await _withLightRailFeeds(() async {
        final canonical = await RealtimeService.getUpdatesForTransportMode(
          TransportMode.lightrail,
        );
        final group = await RealtimeService.getAllLightRailUpdates();

        expect(canonical?.entity.single.id, 'cbdandsoutheast');
        expect(
          group.map((feed) => feed?.entity.single.id),
          _allLightRailSources,
        );
      });
    },
  );
}

const _allLightRailSources = [
  'cbdandsoutheast',
  'innerwest',
  'newcastle',
  'parramatta',
];

Future<void> _withLightRailFeeds(Future<void> Function() action) async {
  RealtimeService.invalidateRealtimeCache();
  await http.runWithClient(
    action,
    () => MockClient((request) async {
      final feed = FeedMessage(
        header: FeedHeader(gtfsRealtimeVersion: '2.0'),
        entity: [FeedEntity(id: request.url.pathSegments.last)],
      );
      return http.Response.bytes(feed.writeToBuffer(), 200);
    }),
  );
}
