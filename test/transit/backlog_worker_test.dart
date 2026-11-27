import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/domain/transit_cancellation.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/runtime/bounded_bytes.dart';
import 'package:lbww_flutter/transit/runtime/cancellable_compute.dart';

int _slow(int value) {
  final watch = Stopwatch()..start();
  while (watch.elapsedMilliseconds < 5000) {}
  return value;
}

int _square(int value) => value * value;
void main() {
  test(
    'cancelled parsing is terminated instead of blocking the next request',
    () async {
      final token = TransitCancellation();
      final result = runTransitCompute(_slow, 5, cancellation: token);
      final cancelled = expectLater(
        result,
        throwsA(isA<TransitOperationCancelled>()),
      );
      Timer(const Duration(milliseconds: 30), token.cancel);
      await cancelled.timeout(const Duration(seconds: 1));
      expect(await runTransitCompute(_square, 7), 49);
    },
  );
  test('response budget stops consuming an oversized feed', () async {
    await expectLater(
      boundedTransitBytes(
        Stream.fromIterable([
          [1, 2],
          [3, 4],
        ]),
        maximumBytes: 3,
      ).toList(),
      throwsA(isA<TransitResourceLimit>()),
    );
  });
}
