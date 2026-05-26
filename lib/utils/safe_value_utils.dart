import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:zard/zard.dart';

final _doubleSchema = z.coerce.double();
final _intSchema = z.coerce.int();

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
  return map[key];
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

Map<String, dynamic>? readMap(Map<String, dynamic>? map, String key) {
  return tryReadJsonMap(map, key);
}

List<dynamic>? readList(Map<String, dynamic>? map, String key) {
  return tryReadListValue(map, key);
}

String? readString(Map<String, dynamic>? map, String key) {
  return tryReadStringValue(map, key);
}

num? readNum(Map<String, dynamic>? map, String key) {
  final raw = tryReadMapValue(map, key);
  if (raw is num) {
    return raw;
  }
  if (raw is String) {
    return num.tryParse(raw);
  }
  return null;
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
  return _doubleSchema.safeParse(raw).unwrapOrNull();
}

int? tryParseIntValue(Object? raw) {
  return _intSchema.safeParse(raw).unwrapOrNull();
}

DateTime? tryParseDateTimeValue(Object? raw) {
  if (raw is DateTime) {
    return raw;
  }
  final value = trimmedOrNull(raw?.toString());
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value);
}

Uri? tryParseUriValue(Object? raw) {
  final value = trimmedOrNull(raw?.toString());
  if (value == null) {
    return null;
  }
  return Uri.tryParse(value);
}

String? prettyPrintJsonOrNull(Object? value) {
  return const JsonEncoder.withIndent('  ').convert(value);
}

T? _listValueOrNull<T>(List<T>? values, int index) {
  if (values == null || index < 0 || index >= values.length) {
    return null;
  }
  return values[index];
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
  final pair = tryParseCoordinatePair(raw);
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
