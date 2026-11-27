import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/services/home_stop_service.dart';
import 'package:lbww_flutter/set_home_stop_screen.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/widgets/stops/stops_search_repository.dart';

class _Stops implements StopRepository {
  _Stops(this.search);
  final Future<List<TransitStop>> Function() search;
  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) => search();
  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async => null;
}

TransitRegionServices _service(
  TransitRegion region,
  TransitProviderId provider,
  StopRepository stops,
) => TransitRegionServices(
  region: region,
  provider: provider,
  stops: stops,
  attribution: TransitProviderAttribution(
    provider: provider,
    name: 'Test',
    licenseName: 'Test',
    url: 'https://example.com',
  ),
);
const _stop = TransitStop(
  ref: TransitStopRef(
    region: TransitRegion.queensland,
    provider: TransitProviderId.translink,
    sourceId: TransitSourceId('qld:SEQ'),
    stopId: 'C',
  ),
  name: 'Central QLD',
);

void main() {
  for (final home in [false, true]) {
    for (final cancel in [false, true]) {
      testWidgets(
        '${home ? 'home' : 'trip'} picker shows regional results before completion and handles ${cancel ? 'cancel' : 'partial failure'}',
        (tester) async {
          final slow = Completer<List<TransitStop>>();
          final repository = RegionalStopsSearchRepository(
            enabledServices: () => [
              _service(
                TransitRegion.queensland,
                TransitProviderId.translink,
                _Stops(() async => [_stop]),
              ),
              _service(
                TransitRegion.victoria,
                TransitProviderId.ptv,
                _Stops(() => slow.future),
              ),
            ],
          );
          final screen = home
              ? SetHomeStopScreen(
                  stopSearchRepository: repository,
                  homeStopService: HomeStopService(
                    readString: (_) async => null,
                    containsKey: (_) async => false,
                  ),
                )
              : NewTripScreen(stopSearchRepository: repository);
          await tester.pumpWidget(MaterialApp(home: screen));
          await tester.pump();
          if (!home) {
            await tester.tap(find.byKey(const ValueKey('trip-origin')));
            await tester.pump();
          }
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text('Central QLD'), findsOneWidget);
          expect(find.text('Cancel loading'), findsOneWidget);
          if (cancel) {
            await tester.tap(find.text('Cancel loading'));
            await tester.pumpAndSettle();
            expect(find.textContaining('Loading stopped'), findsOneWidget);
          } else {
            slow.completeError(const ProviderUnavailable(message: 'Offline'));
            await tester.pumpAndSettle();
            expect(find.textContaining('Could not update VIC'), findsOneWidget);
          }
          expect(find.text('Central QLD'), findsOneWidget);
          expect(find.text('Retry'), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
          if (!slow.isCompleted) slow.complete(const []);
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
