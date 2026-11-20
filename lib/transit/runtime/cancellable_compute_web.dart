import 'package:flutter/foundation.dart';

import '../domain/transit_cancellation.dart';

Future<R> runTransitCompute<Q, R>(
  R Function(Q) callback,
  Q message, {
  TransitCancellation? cancellation,
}) {
  cancellation?.throwIfCancelled();
  final result = compute(callback, message);
  return cancellation?.wait(result) ?? result;
}
