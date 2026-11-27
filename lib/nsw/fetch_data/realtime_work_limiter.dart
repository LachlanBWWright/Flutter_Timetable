import 'dart:async';
import 'dart:collection';

/// Bounds simultaneous network and decode work while serving waiters in order.
class RealtimeWorkLimiter {
  RealtimeWorkLimiter(this.capacity) : assert(capacity > 0);

  final int capacity;
  int _active = 0;
  final Queue<Completer<void>> _waiting = Queue();

  Future<T> run<T>(Future<T> Function() action) async {
    if (_active < capacity) {
      _active++;
    } else {
      final ready = Completer<void>();
      _waiting.add(ready);
      await ready.future;
    }
    try {
      return await action();
    } finally {
      if (_waiting.isEmpty) {
        _active--;
      } else {
        // Transfer this slot directly to the oldest waiter.
        _waiting.removeFirst().complete();
      }
    }
  }
}
