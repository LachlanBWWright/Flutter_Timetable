import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/transit.dart';

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
}
