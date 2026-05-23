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
  return [values[0], values[1]];
}

LatLng? tryParseLatLng(Object? raw) {
  final pair = tryParseCoordinatePair(raw);
  if (pair == null) {
    return null;
  }
  return LatLng(pair[0], pair[1]);
}
