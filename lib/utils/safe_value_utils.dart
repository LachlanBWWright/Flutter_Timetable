import 'dart:convert';

import 'package:latlong2/latlong.dart';

String? trimmedOrNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

Map<String, dynamic>? tryDecodeJsonMap(String source) {
  try {
    final decoded = jsonDecode(source);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

Object? tryReadMapValue(Map<String, dynamic>? map, String key) {
  if (map == null) {
    return null;
  }
  try {
    return map[key];
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? tryReadJsonMap(Map<String, dynamic>? map, String key) {
  final raw = tryReadMapValue(map, key);
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return {for (final entry in raw.entries) entry.key.toString(): entry.value};
  }
  return null;
}

List<dynamic>? tryReadListValue(Map<String, dynamic>? map, String key) {
  final raw = tryReadMapValue(map, key);
  return raw is List ? raw : null;
}

String? tryReadStringValue(Map<String, dynamic>? map, String key) {
  final raw = tryReadMapValue(map, key);
  return raw?.toString();
}

List<dynamic>? tryDecodeJsonList(String source) {
  try {
    final decoded = jsonDecode(source);
    return decoded is List<dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

double? tryParseDoubleValue(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw);
  }
  return null;
}

int? tryParseIntValue(Object? raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  if (raw is String) {
    return int.tryParse(raw);
  }
  return null;
}

T? _listValueOrNull<T>(List<T>? values, int index) {
  if (values == null || index < 0 || index >= values.length) {
    return null;
  }
  try {
    return values[index];
  } catch (_) {
    return null;
  }
}

List<double>? tryParseDoubleList(Object? raw, {int minLength = 1}) {
  if (raw is! List || raw.length < minLength) {
    return null;
  }

  final values = <double>[];
  for (final entry in raw) {
    final parsed = tryParseDoubleValue(entry);
    if (parsed == null) {
      return null;
    }
    values.add(parsed);
  }
  return values;
}

List<List<double>>? tryParseDoubleMatrix(
  Object? raw, {
  int minLengthPerRow = 1,
}) {
  if (raw is! List) {
    return null;
  }

  final rows = <List<double>>[];
  for (final entry in raw) {
    final parsed = tryParseDoubleList(entry, minLength: minLengthPerRow);
    if (parsed == null) {
      return null;
    }
    rows.add(parsed);
  }
  return rows;
}

List<double>? tryParseCoordinatePair(Object? raw) {
  final values = tryParseDoubleList(raw, minLength: 2);
  if (values == null) {
    return null;
  }
  final latitude = _listValueOrNull(values, 0);
  final longitude = _listValueOrNull(values, 1);
  if (latitude == null || longitude == null) {
    return null;
  }
  return [latitude, longitude];
}

LatLng? tryParseLatLng(Object? raw) {
  List<double>? pair;
  try {
    pair = tryParseCoordinatePair(raw);
  } catch (_) {
    return null;
  }
  if (pair == null) {
    return null;
  }
  final latitude = _listValueOrNull(pair, 0);
  final longitude = _listValueOrNull(pair, 1);
  if (latitude == null || longitude == null) {
    return null;
  }
  return LatLng(latitude, longitude);
}
