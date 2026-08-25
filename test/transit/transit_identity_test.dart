import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

void main() {
  test('stop refs round-trip through storage keys', () {
    const ref = TransitStopRef(
      region: TransitRegion.queensland,
      provider: TransitProviderId.translink,
      sourceId: TransitSourceId('qld:SEQ'),
      stopId: '12345',
    );

    final parsed = TransitStopRef.tryParse(ref.storageKey);

    expect(parsed, isNotNull);
    expect(parsed, ref);
  });

  test('invalid storage keys do not parse', () {
    expect(TransitStopRef.tryParse('bad-key'), isNull);
  });

  test('station copies preserve provider-qualified stop identity', () {
    const ref = TransitStopRef(
      region: TransitRegion.victoria,
      provider: TransitProviderId.ptv,
      sourceId: TransitSourceId('ptv:route_type:0'),
      stopId: '1071',
    );
    final station = Station(
      name: 'Flinders Street',
      id: '1071',
      transitRef: ref,
    );

    expect(station.copyWith(name: 'Flinders St').transitRef, ref);
  });
}
