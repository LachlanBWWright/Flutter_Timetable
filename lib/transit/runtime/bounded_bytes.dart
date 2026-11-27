import 'dart:async';

import '../errors/transit_failure.dart';

Stream<List<int>> boundedTransitBytes(
  Stream<List<int>> source, {
  int maximumBytes = 512 * 1024 * 1024,
}) {
  var received = 0;
  // A synchronous transformer forwards cancellation straight to the source,
  // including while the provider is stalled between response chunks.
  return source.transform(
    StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (bytes, sink) {
        received += bytes.length;
        if (received > maximumBytes) {
          sink.addError(
            const TransitResourceLimit(
              message: 'The downloaded feed exceeds the response-size budget.',
            ),
          );
        } else {
          sink.add(bytes);
        }
      },
    ),
  );
}
