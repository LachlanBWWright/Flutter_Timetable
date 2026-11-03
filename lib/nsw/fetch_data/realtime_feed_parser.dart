import 'dart:developer';

import 'package:flutter/foundation.dart';
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

/// Native platforms decode on a worker isolate. Flutter web's compute executes
/// on the current event loop because web isolates are not available.
Future<FeedMessage> decodeRealtimeFeed(Uint8List bytes) => compute(
  _decodeRealtimeFeed,
  bytes,
  debugLabel: 'GTFS realtime protobuf decode',
);

FeedMessage _decodeRealtimeFeed(Uint8List bytes) => Timeline.timeSync(
  'GTFS realtime protobuf decode',
  () => FeedMessage.fromBuffer(bytes),
  arguments: {'bytes': bytes.length},
);
