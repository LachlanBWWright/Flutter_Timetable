import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:lbww_flutter/fetch_data/timetable_data.dart';
import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  test('fetchMetroScheduleRealtime returns a FeedMessage on success', () async {
    final feed = await fetchMetroScheduleRealtime();
    expect(feed, isNotNull,
        reason:
            'FeedMessage should not be null if API key and endpoint are valid');
    expect(feed, isA<FeedMessage>());
  });
}
