import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum AllGetFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('json')
  json('json');

  final String? value;

  const AllGetFormat(this.value);
}

enum BusesGetFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('json')
  json('json');

  final String? value;

  const BusesGetFormat(this.value);
}

enum FerriesGetFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('json')
  json('json');

  final String? value;

  const FerriesGetFormat(this.value);
}

enum LightrailGetFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('json')
  json('json');

  final String? value;

  const LightrailGetFormat(this.value);
}

enum MetroGetFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('json')
  json('json');

  final String? value;

  const MetroGetFormat(this.value);
}

enum NswtrainsGetFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('json')
  json('json');

  final String? value;

  const NswtrainsGetFormat(this.value);
}

enum RegionbusesGetFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('json')
  json('json');

  final String? value;

  const RegionbusesGetFormat(this.value);
}

enum SydneytrainsGetFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('json')
  json('json');

  final String? value;

  const SydneytrainsGetFormat(this.value);
}
