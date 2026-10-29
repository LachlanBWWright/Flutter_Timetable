import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/stops_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('unsubscribed updates do not start endpoint work', () async {
    final release = await EndpointStaticUpdateQueue.acquire(
      StopsEndpoint.metro,
    );
    NewTripService.updateStaticTransportData(endpoints: [StopsEndpoint.metro]);
    release();
    final releaseNext = await EndpointStaticUpdateQueue.acquire(
      StopsEndpoint.metro,
    ).timeout(const Duration(seconds: 1));
    releaseNext();
  });

  test('cancelled queued update releases its slot without fetching', () async {
    final release = await EndpointStaticUpdateQueue.acquire(
      StopsEndpoint.metro,
    );
    final progress = <StaticTransportUpdateProgress>[];
    final subscription = NewTripService.updateStaticTransportData(
      endpoints: [StopsEndpoint.metro],
    ).listen(progress.add);
    await subscription.cancel();
    release();
    final releaseNext = await EndpointStaticUpdateQueue.acquire(
      StopsEndpoint.metro,
    ).timeout(const Duration(seconds: 1));
    releaseNext();
    expect(progress, isEmpty);
  });
}
