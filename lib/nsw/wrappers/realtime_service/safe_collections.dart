part of '../realtime_service_impl.dart';

void _putValue<K, V>(Map<K, V> map, K key, V value) {
  map.remove(key);
  map[key] = value;
}

void _incrementCount(Map<String, int> counts, String key, int delta) {
  _putValue(counts, key, (counts[key] ?? 0) + delta);
}

Future<T> _loadOrFallback<T>(Future<T> Function() loader, T fallback) async {
  try {
    return await loader();
  } catch (_) {
    return fallback;
  }
}
