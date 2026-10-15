import 'package:flutter/foundation.dart';

import '../../constants/transport_modes.dart';

/// Positive, bounded mode results and their publication generation.
class StopModeCache {
  final Map<String, TransportMode> _values = {};
  final ValueNotifier<int> _generation = ValueNotifier(0);
  static const _maxEntries = 4096;

  int get generation => _generation.value;
  ValueListenable<int> get changes => _generation;

  TransportMode? lookup(String stopId) {
    final mode = _values.remove(stopId);
    if (mode != null) _values[stopId] = mode;
    return mode;
  }

  void store(String stopId, TransportMode? mode) {
    // Missing stops and failed reads remain retryable after an import.
    if (mode == null) return;
    _values.remove(stopId);
    _values[stopId] = mode;
    if (_values.length > _maxEntries) _values.remove(_values.keys.first);
  }

  void clear() {
    _values.clear();
    _generation.value += 1;
  }
}
