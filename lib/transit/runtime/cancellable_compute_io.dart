import 'dart:isolate';

import '../domain/transit_cancellation.dart';

Future<R> runTransitCompute<Q, R>(
  R Function(Q) callback,
  Q message, {
  TransitCancellation? cancellation,
}) async {
  cancellation?.throwIfCancelled();
  final port = ReceivePort();
  Isolate? worker;
  try {
    worker = await Isolate.spawn(
      _run<Q, R>,
      _Task(callback, message, port.sendPort),
      onExit: port.sendPort,
      onError: port.sendPort,
      errorsAreFatal: true,
    );
    final result = await (cancellation?.wait(port.first) ?? port.first);
    if (result is _Success<R>) return result.value;
    if (result is _Failure) {
      Error.throwWithStackTrace(
        result.error,
        StackTrace.fromString(result.stack),
      );
    }
    throw StateError('The timetable worker exited without a result.');
  } finally {
    worker?.kill(priority: Isolate.immediate);
    port.close();
  }
}

class _Task<Q, R> {
  const _Task(this.callback, this.message, this.port);
  final R Function(Q) callback;
  final Q message;
  final SendPort port;
}

class _Success<R> {
  const _Success(this.value);
  final R value;
}

class _Failure {
  const _Failure(this.error, this.stack);
  final Object error;
  final String stack;
}

void _run<Q, R>(_Task<Q, R> task) {
  try {
    task.port.send(_Success(task.callback(task.message)));
  } catch (error, stack) {
    task.port.send(_Failure(error, stack.toString()));
  }
}
