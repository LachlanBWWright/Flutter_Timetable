import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/nsw/fetch_data/realtime_work_limiter.dart';

void main() {
  test(
    'bounds concurrent work and releases failed slots in FIFO order',
    () async {
      final limiter = RealtimeWorkLimiter(2);
      final first = Completer<void>();
      final second = Completer<void>();
      final third = Completer<void>();
      final started = <int>[];
      final thirdStarted = Completer<void>();
      var active = 0;
      var maximum = 0;
      Future<void> work(int id, Future<void> until) => limiter.run(() async {
        started.add(id);
        if (id == 3) thirdStarted.complete();
        active++;
        if (active > maximum) maximum = active;
        try {
          await until;
        } finally {
          active--;
        }
      });

      final one = work(1, first.future);
      final two = work(2, second.future);
      final three = work(3, third.future);
      final four = work(4, Future.value());
      expect(started, [1, 2]);
      final error = expectLater(one, throwsStateError);
      first.completeError(StateError('fetch failed'));
      await error;
      await thirdStarted.future;
      expect(started, [1, 2, 3]);
      second.complete();
      await two;
      await four;
      expect(started, [1, 2, 3, 4]);
      third.complete();
      await three;
      expect(maximum, 2);
      await limiter.run(() async => started.add(5));
      expect(started.last, 5);
    },
  );
}
