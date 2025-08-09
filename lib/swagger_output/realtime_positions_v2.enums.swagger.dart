import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum SydneytrainsGetDebug {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('true')
  $true('true');

  final String? value;

  const SydneytrainsGetDebug(this.value);
}

enum MetroGetDebug {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('true')
  $true('true');

  final String? value;

  const MetroGetDebug(this.value);
}
