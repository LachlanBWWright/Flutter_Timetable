import 'dart:async';

import '../errors/transit_failure.dart';

/// A cooperative cancellation signal shared by repository and network layers.
class TransitCancellation {
  final _cancelled = Completer<void>();
  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;
  void cancel() {
    if (!isCancelled) _cancelled.complete();
  }

  void throwIfCancelled() {
    if (isCancelled) throw const TransitOperationCancelled();
  }

  Stream<T> bind<T>(Stream<T> source) {
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;
    var finished = false;
    void close() {
      if (finished) return;
      finished = true;
      unawaited(controller.close());
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = source.listen(
          (value) {
            if (!finished) controller.add(value);
          },
          onError: (Object error, StackTrace stack) {
            if (!finished) controller.addError(error, stack);
          },
          onDone: close,
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () async {
        finished = true;
        await subscription?.cancel();
      },
    );
    unawaited(
      whenCancelled.then((_) {
        if (finished) return;
        controller.addError(const TransitOperationCancelled());
        if (subscription != null) unawaited(subscription!.cancel());
        close();
      }),
    );
    return controller.stream;
  }

  Future<T> wait<T>(Future<T> work) {
    // Always observe work, even after cancellation, so a late transport error
    // cannot become an unhandled asynchronous exception.
    return Future.any<T>([
      work,
      whenCancelled.then<T>((_) => throw const TransitOperationCancelled()),
    ]);
  }
}
