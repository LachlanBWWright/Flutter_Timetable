// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $JourneysTable extends Journeys with TableInfo<$JourneysTable, Journey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JourneysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originIdMeta = const VerificationMeta(
    'originId',
  );
  @override
  late final GeneratedColumn<String> originId = GeneratedColumn<String>(
    'origin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationIdMeta = const VerificationMeta(
    'destinationId',
  );
  @override
  late final GeneratedColumn<String> destinationId = GeneratedColumn<String>(
    'destination_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripTypeMeta = const VerificationMeta(
    'tripType',
  );
  @override
  late final GeneratedColumn<String> tripType = GeneratedColumn<String>(
    'trip_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('direct'),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<String> lineId = GeneratedColumn<String>(
    'line_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineNameMeta = const VerificationMeta(
    'lineName',
  );
  @override
  late final GeneratedColumn<String> lineName = GeneratedColumn<String>(
    'line_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legsJsonMeta = const VerificationMeta(
    'legsJson',
  );
  @override
  late final GeneratedColumn<String> legsJson = GeneratedColumn<String>(
    'legs_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    origin,
    originId,
    destination,
    destinationId,
    tripType,
    mode,
    lineId,
    lineName,
    legsJson,
    isPinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journeys';
  @override
  VerificationContext validateIntegrity(
    Insertable<Journey> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('origin_id')) {
      context.handle(
        _originIdMeta,
        originId.isAcceptableOrUnknown(data['origin_id']!, _originIdMeta),
      );
    } else if (isInserting) {
      context.missing(_originIdMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('destination_id')) {
      context.handle(
        _destinationIdMeta,
        destinationId.isAcceptableOrUnknown(
          data['destination_id']!,
          _destinationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationIdMeta);
    }
    if (data.containsKey('trip_type')) {
      context.handle(
        _tripTypeMeta,
        tripType.isAcceptableOrUnknown(data['trip_type']!, _tripTypeMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    }
    if (data.containsKey('line_name')) {
      context.handle(
        _lineNameMeta,
        lineName.isAcceptableOrUnknown(data['line_name']!, _lineNameMeta),
      );
    }
    if (data.containsKey('legs_json')) {
      context.handle(
        _legsJsonMeta,
        legsJson.isAcceptableOrUnknown(data['legs_json']!, _legsJsonMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Journey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Journey(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      originId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_id'],
      )!,
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      )!,
      destinationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_id'],
      )!,
      tripType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_type'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      ),
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_id'],
      ),
      lineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_name'],
      ),
      legsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legs_json'],
      ),
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
    );
  }

  @override
  $JourneysTable createAlias(String alias) {
    return $JourneysTable(attachedDatabase, alias);
  }
}

class Journey extends DataClass implements Insertable<Journey> {
  final int id;
  final String origin;
  final String originId;
  final String destination;
  final String destinationId;
  final String tripType;
  final String? mode;
  final String? lineId;
  final String? lineName;
  final String? legsJson;
  final bool isPinned;
  const Journey({
    required this.id,
    required this.origin,
    required this.originId,
    required this.destination,
    required this.destinationId,
    required this.tripType,
    this.mode,
    this.lineId,
    this.lineName,
    this.legsJson,
    required this.isPinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['origin'] = Variable<String>(origin);
    map['origin_id'] = Variable<String>(originId);
    map['destination'] = Variable<String>(destination);
    map['destination_id'] = Variable<String>(destinationId);
    map['trip_type'] = Variable<String>(tripType);
    if (!nullToAbsent || mode != null) {
      map['mode'] = Variable<String>(mode);
    }
    if (!nullToAbsent || lineId != null) {
      map['line_id'] = Variable<String>(lineId);
    }
    if (!nullToAbsent || lineName != null) {
      map['line_name'] = Variable<String>(lineName);
    }
    if (!nullToAbsent || legsJson != null) {
      map['legs_json'] = Variable<String>(legsJson);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    return map;
  }

  JourneysCompanion toCompanion(bool nullToAbsent) {
    return JourneysCompanion(
      id: Value(id),
      origin: Value(origin),
      originId: Value(originId),
      destination: Value(destination),
      destinationId: Value(destinationId),
      tripType: Value(tripType),
      mode: mode == null && nullToAbsent ? const Value.absent() : Value(mode),
      lineId: lineId == null && nullToAbsent
          ? const Value.absent()
          : Value(lineId),
      lineName: lineName == null && nullToAbsent
          ? const Value.absent()
          : Value(lineName),
      legsJson: legsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(legsJson),
      isPinned: Value(isPinned),
    );
  }

  factory Journey.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Journey(
      id: serializer.fromJson<int>(json['id']),
      origin: serializer.fromJson<String>(json['origin']),
      originId: serializer.fromJson<String>(json['originId']),
      destination: serializer.fromJson<String>(json['destination']),
      destinationId: serializer.fromJson<String>(json['destinationId']),
      tripType: serializer.fromJson<String>(json['tripType']),
      mode: serializer.fromJson<String?>(json['mode']),
      lineId: serializer.fromJson<String?>(json['lineId']),
      lineName: serializer.fromJson<String?>(json['lineName']),
      legsJson: serializer.fromJson<String?>(json['legsJson']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'origin': serializer.toJson<String>(origin),
      'originId': serializer.toJson<String>(originId),
      'destination': serializer.toJson<String>(destination),
      'destinationId': serializer.toJson<String>(destinationId),
      'tripType': serializer.toJson<String>(tripType),
      'mode': serializer.toJson<String?>(mode),
      'lineId': serializer.toJson<String?>(lineId),
      'lineName': serializer.toJson<String?>(lineName),
      'legsJson': serializer.toJson<String?>(legsJson),
      'isPinned': serializer.toJson<bool>(isPinned),
    };
  }

  Journey copyWith({
    int? id,
    String? origin,
    String? originId,
    String? destination,
    String? destinationId,
    String? tripType,
    Value<String?> mode = const Value.absent(),
    Value<String?> lineId = const Value.absent(),
    Value<String?> lineName = const Value.absent(),
    Value<String?> legsJson = const Value.absent(),
    bool? isPinned,
  }) => Journey(
    id: id ?? this.id,
    origin: origin ?? this.origin,
    originId: originId ?? this.originId,
    destination: destination ?? this.destination,
    destinationId: destinationId ?? this.destinationId,
    tripType: tripType ?? this.tripType,
    mode: mode.present ? mode.value : this.mode,
    lineId: lineId.present ? lineId.value : this.lineId,
    lineName: lineName.present ? lineName.value : this.lineName,
    legsJson: legsJson.present ? legsJson.value : this.legsJson,
    isPinned: isPinned ?? this.isPinned,
  );
  Journey copyWithCompanion(JourneysCompanion data) {
    return Journey(
      id: data.id.present ? data.id.value : this.id,
      origin: data.origin.present ? data.origin.value : this.origin,
      originId: data.originId.present ? data.originId.value : this.originId,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      destinationId: data.destinationId.present
          ? data.destinationId.value
          : this.destinationId,
      tripType: data.tripType.present ? data.tripType.value : this.tripType,
      mode: data.mode.present ? data.mode.value : this.mode,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      lineName: data.lineName.present ? data.lineName.value : this.lineName,
      legsJson: data.legsJson.present ? data.legsJson.value : this.legsJson,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Journey(')
          ..write('id: $id, ')
          ..write('origin: $origin, ')
          ..write('originId: $originId, ')
          ..write('destination: $destination, ')
          ..write('destinationId: $destinationId, ')
          ..write('tripType: $tripType, ')
          ..write('mode: $mode, ')
          ..write('lineId: $lineId, ')
          ..write('lineName: $lineName, ')
          ..write('legsJson: $legsJson, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    origin,
    originId,
    destination,
    destinationId,
    tripType,
    mode,
    lineId,
    lineName,
    legsJson,
    isPinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Journey &&
          other.id == this.id &&
          other.origin == this.origin &&
          other.originId == this.originId &&
          other.destination == this.destination &&
          other.destinationId == this.destinationId &&
          other.tripType == this.tripType &&
          other.mode == this.mode &&
          other.lineId == this.lineId &&
          other.lineName == this.lineName &&
          other.legsJson == this.legsJson &&
          other.isPinned == this.isPinned);
}

class JourneysCompanion extends UpdateCompanion<Journey> {
  final Value<int> id;
  final Value<String> origin;
  final Value<String> originId;
  final Value<String> destination;
  final Value<String> destinationId;
  final Value<String> tripType;
  final Value<String?> mode;
  final Value<String?> lineId;
  final Value<String?> lineName;
  final Value<String?> legsJson;
  final Value<bool> isPinned;
  const JourneysCompanion({
    this.id = const Value.absent(),
    this.origin = const Value.absent(),
    this.originId = const Value.absent(),
    this.destination = const Value.absent(),
    this.destinationId = const Value.absent(),
    this.tripType = const Value.absent(),
    this.mode = const Value.absent(),
    this.lineId = const Value.absent(),
    this.lineName = const Value.absent(),
    this.legsJson = const Value.absent(),
    this.isPinned = const Value.absent(),
  });
  JourneysCompanion.insert({
    this.id = const Value.absent(),
    required String origin,
    required String originId,
    required String destination,
    required String destinationId,
    this.tripType = const Value.absent(),
    this.mode = const Value.absent(),
    this.lineId = const Value.absent(),
    this.lineName = const Value.absent(),
    this.legsJson = const Value.absent(),
    this.isPinned = const Value.absent(),
  }) : origin = Value(origin),
       originId = Value(originId),
       destination = Value(destination),
       destinationId = Value(destinationId);
  static Insertable<Journey> custom({
    Expression<int>? id,
    Expression<String>? origin,
    Expression<String>? originId,
    Expression<String>? destination,
    Expression<String>? destinationId,
    Expression<String>? tripType,
    Expression<String>? mode,
    Expression<String>? lineId,
    Expression<String>? lineName,
    Expression<String>? legsJson,
    Expression<bool>? isPinned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origin != null) 'origin': origin,
      if (originId != null) 'origin_id': originId,
      if (destination != null) 'destination': destination,
      if (destinationId != null) 'destination_id': destinationId,
      if (tripType != null) 'trip_type': tripType,
      if (mode != null) 'mode': mode,
      if (lineId != null) 'line_id': lineId,
      if (lineName != null) 'line_name': lineName,
      if (legsJson != null) 'legs_json': legsJson,
      if (isPinned != null) 'is_pinned': isPinned,
    });
  }

  JourneysCompanion copyWith({
    Value<int>? id,
    Value<String>? origin,
    Value<String>? originId,
    Value<String>? destination,
    Value<String>? destinationId,
    Value<String>? tripType,
    Value<String?>? mode,
    Value<String?>? lineId,
    Value<String?>? lineName,
    Value<String?>? legsJson,
    Value<bool>? isPinned,
  }) {
    return JourneysCompanion(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      originId: originId ?? this.originId,
      destination: destination ?? this.destination,
      destinationId: destinationId ?? this.destinationId,
      tripType: tripType ?? this.tripType,
      mode: mode ?? this.mode,
      lineId: lineId ?? this.lineId,
      lineName: lineName ?? this.lineName,
      legsJson: legsJson ?? this.legsJson,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (originId.present) {
      map['origin_id'] = Variable<String>(originId.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (destinationId.present) {
      map['destination_id'] = Variable<String>(destinationId.value);
    }
    if (tripType.present) {
      map['trip_type'] = Variable<String>(tripType.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<String>(lineId.value);
    }
    if (lineName.present) {
      map['line_name'] = Variable<String>(lineName.value);
    }
    if (legsJson.present) {
      map['legs_json'] = Variable<String>(legsJson.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JourneysCompanion(')
          ..write('id: $id, ')
          ..write('origin: $origin, ')
          ..write('originId: $originId, ')
          ..write('destination: $destination, ')
          ..write('destinationId: $destinationId, ')
          ..write('tripType: $tripType, ')
          ..write('mode: $mode, ')
          ..write('lineId: $lineId, ')
          ..write('lineName: $lineName, ')
          ..write('legsJson: $legsJson, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }
}

class $RoutesTable extends Routes with TableInfo<$RoutesTable, Route> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<String> routeId = GeneratedColumn<String>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<String> lineId = GeneratedColumn<String>(
    'line_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeShortNameMeta = const VerificationMeta(
    'routeShortName',
  );
  @override
  late final GeneratedColumn<String> routeShortName = GeneratedColumn<String>(
    'route_short_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeLongNameMeta = const VerificationMeta(
    'routeLongName',
  );
  @override
  late final GeneratedColumn<String> routeLongName = GeneratedColumn<String>(
    'route_long_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeDescMeta = const VerificationMeta(
    'routeDesc',
  );
  @override
  late final GeneratedColumn<String> routeDesc = GeneratedColumn<String>(
    'route_desc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeTypeMeta = const VerificationMeta(
    'routeType',
  );
  @override
  late final GeneratedColumn<String> routeType = GeneratedColumn<String>(
    'route_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeColorMeta = const VerificationMeta(
    'routeColor',
  );
  @override
  late final GeneratedColumn<String> routeColor = GeneratedColumn<String>(
    'route_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeTextColorMeta = const VerificationMeta(
    'routeTextColor',
  );
  @override
  late final GeneratedColumn<String> routeTextColor = GeneratedColumn<String>(
    'route_text_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeSortOrderMeta = const VerificationMeta(
    'routeSortOrder',
  );
  @override
  late final GeneratedColumn<String> routeSortOrder = GeneratedColumn<String>(
    'route_sort_order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    endpoint,
    routeId,
    lineId,
    routeShortName,
    routeLongName,
    routeDesc,
    routeType,
    routeColor,
    routeTextColor,
    routeSortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Route> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineIdMeta);
    }
    if (data.containsKey('route_short_name')) {
      context.handle(
        _routeShortNameMeta,
        routeShortName.isAcceptableOrUnknown(
          data['route_short_name']!,
          _routeShortNameMeta,
        ),
      );
    }
    if (data.containsKey('route_long_name')) {
      context.handle(
        _routeLongNameMeta,
        routeLongName.isAcceptableOrUnknown(
          data['route_long_name']!,
          _routeLongNameMeta,
        ),
      );
    }
    if (data.containsKey('route_desc')) {
      context.handle(
        _routeDescMeta,
        routeDesc.isAcceptableOrUnknown(data['route_desc']!, _routeDescMeta),
      );
    }
    if (data.containsKey('route_type')) {
      context.handle(
        _routeTypeMeta,
        routeType.isAcceptableOrUnknown(data['route_type']!, _routeTypeMeta),
      );
    }
    if (data.containsKey('route_color')) {
      context.handle(
        _routeColorMeta,
        routeColor.isAcceptableOrUnknown(data['route_color']!, _routeColorMeta),
      );
    }
    if (data.containsKey('route_text_color')) {
      context.handle(
        _routeTextColorMeta,
        routeTextColor.isAcceptableOrUnknown(
          data['route_text_color']!,
          _routeTextColorMeta,
        ),
      );
    }
    if (data.containsKey('route_sort_order')) {
      context.handle(
        _routeSortOrderMeta,
        routeSortOrder.isAcceptableOrUnknown(
          data['route_sort_order']!,
          _routeSortOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {endpoint, routeId};
  @override
  Route map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Route(
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_id'],
      )!,
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_id'],
      )!,
      routeShortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_short_name'],
      ),
      routeLongName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_long_name'],
      ),
      routeDesc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_desc'],
      ),
      routeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_type'],
      ),
      routeColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_color'],
      ),
      routeTextColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_text_color'],
      ),
      routeSortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_sort_order'],
      ),
    );
  }

  @override
  $RoutesTable createAlias(String alias) {
    return $RoutesTable(attachedDatabase, alias);
  }
}

class Route extends DataClass implements Insertable<Route> {
  final String endpoint;
  final String routeId;
  final String lineId;
  final String? routeShortName;
  final String? routeLongName;
  final String? routeDesc;
  final String? routeType;
  final String? routeColor;
  final String? routeTextColor;
  final String? routeSortOrder;
  const Route({
    required this.endpoint,
    required this.routeId,
    required this.lineId,
    this.routeShortName,
    this.routeLongName,
    this.routeDesc,
    this.routeType,
    this.routeColor,
    this.routeTextColor,
    this.routeSortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['endpoint'] = Variable<String>(endpoint);
    map['route_id'] = Variable<String>(routeId);
    map['line_id'] = Variable<String>(lineId);
    if (!nullToAbsent || routeShortName != null) {
      map['route_short_name'] = Variable<String>(routeShortName);
    }
    if (!nullToAbsent || routeLongName != null) {
      map['route_long_name'] = Variable<String>(routeLongName);
    }
    if (!nullToAbsent || routeDesc != null) {
      map['route_desc'] = Variable<String>(routeDesc);
    }
    if (!nullToAbsent || routeType != null) {
      map['route_type'] = Variable<String>(routeType);
    }
    if (!nullToAbsent || routeColor != null) {
      map['route_color'] = Variable<String>(routeColor);
    }
    if (!nullToAbsent || routeTextColor != null) {
      map['route_text_color'] = Variable<String>(routeTextColor);
    }
    if (!nullToAbsent || routeSortOrder != null) {
      map['route_sort_order'] = Variable<String>(routeSortOrder);
    }
    return map;
  }

  RoutesCompanion toCompanion(bool nullToAbsent) {
    return RoutesCompanion(
      endpoint: Value(endpoint),
      routeId: Value(routeId),
      lineId: Value(lineId),
      routeShortName: routeShortName == null && nullToAbsent
          ? const Value.absent()
          : Value(routeShortName),
      routeLongName: routeLongName == null && nullToAbsent
          ? const Value.absent()
          : Value(routeLongName),
      routeDesc: routeDesc == null && nullToAbsent
          ? const Value.absent()
          : Value(routeDesc),
      routeType: routeType == null && nullToAbsent
          ? const Value.absent()
          : Value(routeType),
      routeColor: routeColor == null && nullToAbsent
          ? const Value.absent()
          : Value(routeColor),
      routeTextColor: routeTextColor == null && nullToAbsent
          ? const Value.absent()
          : Value(routeTextColor),
      routeSortOrder: routeSortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(routeSortOrder),
    );
  }

  factory Route.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Route(
      endpoint: serializer.fromJson<String>(json['endpoint']),
      routeId: serializer.fromJson<String>(json['routeId']),
      lineId: serializer.fromJson<String>(json['lineId']),
      routeShortName: serializer.fromJson<String?>(json['routeShortName']),
      routeLongName: serializer.fromJson<String?>(json['routeLongName']),
      routeDesc: serializer.fromJson<String?>(json['routeDesc']),
      routeType: serializer.fromJson<String?>(json['routeType']),
      routeColor: serializer.fromJson<String?>(json['routeColor']),
      routeTextColor: serializer.fromJson<String?>(json['routeTextColor']),
      routeSortOrder: serializer.fromJson<String?>(json['routeSortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'endpoint': serializer.toJson<String>(endpoint),
      'routeId': serializer.toJson<String>(routeId),
      'lineId': serializer.toJson<String>(lineId),
      'routeShortName': serializer.toJson<String?>(routeShortName),
      'routeLongName': serializer.toJson<String?>(routeLongName),
      'routeDesc': serializer.toJson<String?>(routeDesc),
      'routeType': serializer.toJson<String?>(routeType),
      'routeColor': serializer.toJson<String?>(routeColor),
      'routeTextColor': serializer.toJson<String?>(routeTextColor),
      'routeSortOrder': serializer.toJson<String?>(routeSortOrder),
    };
  }

  Route copyWith({
    String? endpoint,
    String? routeId,
    String? lineId,
    Value<String?> routeShortName = const Value.absent(),
    Value<String?> routeLongName = const Value.absent(),
    Value<String?> routeDesc = const Value.absent(),
    Value<String?> routeType = const Value.absent(),
    Value<String?> routeColor = const Value.absent(),
    Value<String?> routeTextColor = const Value.absent(),
    Value<String?> routeSortOrder = const Value.absent(),
  }) => Route(
    endpoint: endpoint ?? this.endpoint,
    routeId: routeId ?? this.routeId,
    lineId: lineId ?? this.lineId,
    routeShortName: routeShortName.present
        ? routeShortName.value
        : this.routeShortName,
    routeLongName: routeLongName.present
        ? routeLongName.value
        : this.routeLongName,
    routeDesc: routeDesc.present ? routeDesc.value : this.routeDesc,
    routeType: routeType.present ? routeType.value : this.routeType,
    routeColor: routeColor.present ? routeColor.value : this.routeColor,
    routeTextColor: routeTextColor.present
        ? routeTextColor.value
        : this.routeTextColor,
    routeSortOrder: routeSortOrder.present
        ? routeSortOrder.value
        : this.routeSortOrder,
  );
  Route copyWithCompanion(RoutesCompanion data) {
    return Route(
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      routeShortName: data.routeShortName.present
          ? data.routeShortName.value
          : this.routeShortName,
      routeLongName: data.routeLongName.present
          ? data.routeLongName.value
          : this.routeLongName,
      routeDesc: data.routeDesc.present ? data.routeDesc.value : this.routeDesc,
      routeType: data.routeType.present ? data.routeType.value : this.routeType,
      routeColor: data.routeColor.present
          ? data.routeColor.value
          : this.routeColor,
      routeTextColor: data.routeTextColor.present
          ? data.routeTextColor.value
          : this.routeTextColor,
      routeSortOrder: data.routeSortOrder.present
          ? data.routeSortOrder.value
          : this.routeSortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Route(')
          ..write('endpoint: $endpoint, ')
          ..write('routeId: $routeId, ')
          ..write('lineId: $lineId, ')
          ..write('routeShortName: $routeShortName, ')
          ..write('routeLongName: $routeLongName, ')
          ..write('routeDesc: $routeDesc, ')
          ..write('routeType: $routeType, ')
          ..write('routeColor: $routeColor, ')
          ..write('routeTextColor: $routeTextColor, ')
          ..write('routeSortOrder: $routeSortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    endpoint,
    routeId,
    lineId,
    routeShortName,
    routeLongName,
    routeDesc,
    routeType,
    routeColor,
    routeTextColor,
    routeSortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Route &&
          other.endpoint == this.endpoint &&
          other.routeId == this.routeId &&
          other.lineId == this.lineId &&
          other.routeShortName == this.routeShortName &&
          other.routeLongName == this.routeLongName &&
          other.routeDesc == this.routeDesc &&
          other.routeType == this.routeType &&
          other.routeColor == this.routeColor &&
          other.routeTextColor == this.routeTextColor &&
          other.routeSortOrder == this.routeSortOrder);
}

class RoutesCompanion extends UpdateCompanion<Route> {
  final Value<String> endpoint;
  final Value<String> routeId;
  final Value<String> lineId;
  final Value<String?> routeShortName;
  final Value<String?> routeLongName;
  final Value<String?> routeDesc;
  final Value<String?> routeType;
  final Value<String?> routeColor;
  final Value<String?> routeTextColor;
  final Value<String?> routeSortOrder;
  final Value<int> rowid;
  const RoutesCompanion({
    this.endpoint = const Value.absent(),
    this.routeId = const Value.absent(),
    this.lineId = const Value.absent(),
    this.routeShortName = const Value.absent(),
    this.routeLongName = const Value.absent(),
    this.routeDesc = const Value.absent(),
    this.routeType = const Value.absent(),
    this.routeColor = const Value.absent(),
    this.routeTextColor = const Value.absent(),
    this.routeSortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutesCompanion.insert({
    required String endpoint,
    required String routeId,
    required String lineId,
    this.routeShortName = const Value.absent(),
    this.routeLongName = const Value.absent(),
    this.routeDesc = const Value.absent(),
    this.routeType = const Value.absent(),
    this.routeColor = const Value.absent(),
    this.routeTextColor = const Value.absent(),
    this.routeSortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : endpoint = Value(endpoint),
       routeId = Value(routeId),
       lineId = Value(lineId);
  static Insertable<Route> custom({
    Expression<String>? endpoint,
    Expression<String>? routeId,
    Expression<String>? lineId,
    Expression<String>? routeShortName,
    Expression<String>? routeLongName,
    Expression<String>? routeDesc,
    Expression<String>? routeType,
    Expression<String>? routeColor,
    Expression<String>? routeTextColor,
    Expression<String>? routeSortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (endpoint != null) 'endpoint': endpoint,
      if (routeId != null) 'route_id': routeId,
      if (lineId != null) 'line_id': lineId,
      if (routeShortName != null) 'route_short_name': routeShortName,
      if (routeLongName != null) 'route_long_name': routeLongName,
      if (routeDesc != null) 'route_desc': routeDesc,
      if (routeType != null) 'route_type': routeType,
      if (routeColor != null) 'route_color': routeColor,
      if (routeTextColor != null) 'route_text_color': routeTextColor,
      if (routeSortOrder != null) 'route_sort_order': routeSortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutesCompanion copyWith({
    Value<String>? endpoint,
    Value<String>? routeId,
    Value<String>? lineId,
    Value<String?>? routeShortName,
    Value<String?>? routeLongName,
    Value<String?>? routeDesc,
    Value<String?>? routeType,
    Value<String?>? routeColor,
    Value<String?>? routeTextColor,
    Value<String?>? routeSortOrder,
    Value<int>? rowid,
  }) {
    return RoutesCompanion(
      endpoint: endpoint ?? this.endpoint,
      routeId: routeId ?? this.routeId,
      lineId: lineId ?? this.lineId,
      routeShortName: routeShortName ?? this.routeShortName,
      routeLongName: routeLongName ?? this.routeLongName,
      routeDesc: routeDesc ?? this.routeDesc,
      routeType: routeType ?? this.routeType,
      routeColor: routeColor ?? this.routeColor,
      routeTextColor: routeTextColor ?? this.routeTextColor,
      routeSortOrder: routeSortOrder ?? this.routeSortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<String>(routeId.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<String>(lineId.value);
    }
    if (routeShortName.present) {
      map['route_short_name'] = Variable<String>(routeShortName.value);
    }
    if (routeLongName.present) {
      map['route_long_name'] = Variable<String>(routeLongName.value);
    }
    if (routeDesc.present) {
      map['route_desc'] = Variable<String>(routeDesc.value);
    }
    if (routeType.present) {
      map['route_type'] = Variable<String>(routeType.value);
    }
    if (routeColor.present) {
      map['route_color'] = Variable<String>(routeColor.value);
    }
    if (routeTextColor.present) {
      map['route_text_color'] = Variable<String>(routeTextColor.value);
    }
    if (routeSortOrder.present) {
      map['route_sort_order'] = Variable<String>(routeSortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutesCompanion(')
          ..write('endpoint: $endpoint, ')
          ..write('routeId: $routeId, ')
          ..write('lineId: $lineId, ')
          ..write('routeShortName: $routeShortName, ')
          ..write('routeLongName: $routeLongName, ')
          ..write('routeDesc: $routeDesc, ')
          ..write('routeType: $routeType, ')
          ..write('routeColor: $routeColor, ')
          ..write('routeTextColor: $routeTextColor, ')
          ..write('routeSortOrder: $routeSortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StopsTable extends Stops with TableInfo<$StopsTable, Stop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stopIdMeta = const VerificationMeta('stopId');
  @override
  late final GeneratedColumn<String> stopId = GeneratedColumn<String>(
    'stop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopNameMeta = const VerificationMeta(
    'stopName',
  );
  @override
  late final GeneratedColumn<String> stopName = GeneratedColumn<String>(
    'stop_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopCodeMeta = const VerificationMeta(
    'stopCode',
  );
  @override
  late final GeneratedColumn<String> stopCode = GeneratedColumn<String>(
    'stop_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ttsStopNameMeta = const VerificationMeta(
    'ttsStopName',
  );
  @override
  late final GeneratedColumn<String> ttsStopName = GeneratedColumn<String>(
    'tts_stop_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopDescMeta = const VerificationMeta(
    'stopDesc',
  );
  @override
  late final GeneratedColumn<String> stopDesc = GeneratedColumn<String>(
    'stop_desc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopUrlMeta = const VerificationMeta(
    'stopUrl',
  );
  @override
  late final GeneratedColumn<String> stopUrl = GeneratedColumn<String>(
    'stop_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopTimezoneMeta = const VerificationMeta(
    'stopTimezone',
  );
  @override
  late final GeneratedColumn<String> stopTimezone = GeneratedColumn<String>(
    'stop_timezone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
    'level_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopLatMeta = const VerificationMeta(
    'stopLat',
  );
  @override
  late final GeneratedColumn<double> stopLat = GeneratedColumn<double>(
    'stop_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopLonMeta = const VerificationMeta(
    'stopLon',
  );
  @override
  late final GeneratedColumn<double> stopLon = GeneratedColumn<double>(
    'stop_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationTypeMeta = const VerificationMeta(
    'locationType',
  );
  @override
  late final GeneratedColumn<int> locationType = GeneratedColumn<int>(
    'location_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentStationMeta = const VerificationMeta(
    'parentStation',
  );
  @override
  late final GeneratedColumn<String> parentStation = GeneratedColumn<String>(
    'parent_station',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wheelchairBoardingMeta =
      const VerificationMeta('wheelchairBoarding');
  @override
  late final GeneratedColumn<int> wheelchairBoarding = GeneratedColumn<int>(
    'wheelchair_boarding',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformCodeMeta = const VerificationMeta(
    'platformCode',
  );
  @override
  late final GeneratedColumn<String> platformCode = GeneratedColumn<String>(
    'platform_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stopId,
    stopName,
    stopCode,
    ttsStopName,
    stopDesc,
    zoneId,
    stopUrl,
    stopTimezone,
    levelId,
    stopLat,
    stopLon,
    locationType,
    parentStation,
    wheelchairBoarding,
    platformCode,
    endpoint,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stops';
  @override
  VerificationContext validateIntegrity(
    Insertable<Stop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stop_id')) {
      context.handle(
        _stopIdMeta,
        stopId.isAcceptableOrUnknown(data['stop_id']!, _stopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stopIdMeta);
    }
    if (data.containsKey('stop_name')) {
      context.handle(
        _stopNameMeta,
        stopName.isAcceptableOrUnknown(data['stop_name']!, _stopNameMeta),
      );
    } else if (isInserting) {
      context.missing(_stopNameMeta);
    }
    if (data.containsKey('stop_code')) {
      context.handle(
        _stopCodeMeta,
        stopCode.isAcceptableOrUnknown(data['stop_code']!, _stopCodeMeta),
      );
    }
    if (data.containsKey('tts_stop_name')) {
      context.handle(
        _ttsStopNameMeta,
        ttsStopName.isAcceptableOrUnknown(
          data['tts_stop_name']!,
          _ttsStopNameMeta,
        ),
      );
    }
    if (data.containsKey('stop_desc')) {
      context.handle(
        _stopDescMeta,
        stopDesc.isAcceptableOrUnknown(data['stop_desc']!, _stopDescMeta),
      );
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    }
    if (data.containsKey('stop_url')) {
      context.handle(
        _stopUrlMeta,
        stopUrl.isAcceptableOrUnknown(data['stop_url']!, _stopUrlMeta),
      );
    }
    if (data.containsKey('stop_timezone')) {
      context.handle(
        _stopTimezoneMeta,
        stopTimezone.isAcceptableOrUnknown(
          data['stop_timezone']!,
          _stopTimezoneMeta,
        ),
      );
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    }
    if (data.containsKey('stop_lat')) {
      context.handle(
        _stopLatMeta,
        stopLat.isAcceptableOrUnknown(data['stop_lat']!, _stopLatMeta),
      );
    }
    if (data.containsKey('stop_lon')) {
      context.handle(
        _stopLonMeta,
        stopLon.isAcceptableOrUnknown(data['stop_lon']!, _stopLonMeta),
      );
    }
    if (data.containsKey('location_type')) {
      context.handle(
        _locationTypeMeta,
        locationType.isAcceptableOrUnknown(
          data['location_type']!,
          _locationTypeMeta,
        ),
      );
    }
    if (data.containsKey('parent_station')) {
      context.handle(
        _parentStationMeta,
        parentStation.isAcceptableOrUnknown(
          data['parent_station']!,
          _parentStationMeta,
        ),
      );
    }
    if (data.containsKey('wheelchair_boarding')) {
      context.handle(
        _wheelchairBoardingMeta,
        wheelchairBoarding.isAcceptableOrUnknown(
          data['wheelchair_boarding']!,
          _wheelchairBoardingMeta,
        ),
      );
    }
    if (data.containsKey('platform_code')) {
      context.handle(
        _platformCodeMeta,
        platformCode.isAcceptableOrUnknown(
          data['platform_code']!,
          _platformCodeMeta,
        ),
      );
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stopId, endpoint};
  @override
  Stop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stop(
      stopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_id'],
      )!,
      stopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_name'],
      )!,
      stopCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_code'],
      ),
      ttsStopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tts_stop_name'],
      ),
      stopDesc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_desc'],
      ),
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      ),
      stopUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_url'],
      ),
      stopTimezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_timezone'],
      ),
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_id'],
      ),
      stopLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stop_lat'],
      ),
      stopLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stop_lon'],
      ),
      locationType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location_type'],
      ),
      parentStation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_station'],
      ),
      wheelchairBoarding: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wheelchair_boarding'],
      ),
      platformCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_code'],
      ),
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
    );
  }

  @override
  $StopsTable createAlias(String alias) {
    return $StopsTable(attachedDatabase, alias);
  }
}

class Stop extends DataClass implements Insertable<Stop> {
  final String stopId;
  final String stopName;
  final String? stopCode;
  final String? ttsStopName;
  final String? stopDesc;
  final String? zoneId;
  final String? stopUrl;
  final String? stopTimezone;
  final String? levelId;
  final double? stopLat;
  final double? stopLon;
  final int? locationType;
  final String? parentStation;
  final int? wheelchairBoarding;
  final String? platformCode;
  final String endpoint;
  const Stop({
    required this.stopId,
    required this.stopName,
    this.stopCode,
    this.ttsStopName,
    this.stopDesc,
    this.zoneId,
    this.stopUrl,
    this.stopTimezone,
    this.levelId,
    this.stopLat,
    this.stopLon,
    this.locationType,
    this.parentStation,
    this.wheelchairBoarding,
    this.platformCode,
    required this.endpoint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stop_id'] = Variable<String>(stopId);
    map['stop_name'] = Variable<String>(stopName);
    if (!nullToAbsent || stopCode != null) {
      map['stop_code'] = Variable<String>(stopCode);
    }
    if (!nullToAbsent || ttsStopName != null) {
      map['tts_stop_name'] = Variable<String>(ttsStopName);
    }
    if (!nullToAbsent || stopDesc != null) {
      map['stop_desc'] = Variable<String>(stopDesc);
    }
    if (!nullToAbsent || zoneId != null) {
      map['zone_id'] = Variable<String>(zoneId);
    }
    if (!nullToAbsent || stopUrl != null) {
      map['stop_url'] = Variable<String>(stopUrl);
    }
    if (!nullToAbsent || stopTimezone != null) {
      map['stop_timezone'] = Variable<String>(stopTimezone);
    }
    if (!nullToAbsent || levelId != null) {
      map['level_id'] = Variable<String>(levelId);
    }
    if (!nullToAbsent || stopLat != null) {
      map['stop_lat'] = Variable<double>(stopLat);
    }
    if (!nullToAbsent || stopLon != null) {
      map['stop_lon'] = Variable<double>(stopLon);
    }
    if (!nullToAbsent || locationType != null) {
      map['location_type'] = Variable<int>(locationType);
    }
    if (!nullToAbsent || parentStation != null) {
      map['parent_station'] = Variable<String>(parentStation);
    }
    if (!nullToAbsent || wheelchairBoarding != null) {
      map['wheelchair_boarding'] = Variable<int>(wheelchairBoarding);
    }
    if (!nullToAbsent || platformCode != null) {
      map['platform_code'] = Variable<String>(platformCode);
    }
    map['endpoint'] = Variable<String>(endpoint);
    return map;
  }

  StopsCompanion toCompanion(bool nullToAbsent) {
    return StopsCompanion(
      stopId: Value(stopId),
      stopName: Value(stopName),
      stopCode: stopCode == null && nullToAbsent
          ? const Value.absent()
          : Value(stopCode),
      ttsStopName: ttsStopName == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsStopName),
      stopDesc: stopDesc == null && nullToAbsent
          ? const Value.absent()
          : Value(stopDesc),
      zoneId: zoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(zoneId),
      stopUrl: stopUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(stopUrl),
      stopTimezone: stopTimezone == null && nullToAbsent
          ? const Value.absent()
          : Value(stopTimezone),
      levelId: levelId == null && nullToAbsent
          ? const Value.absent()
          : Value(levelId),
      stopLat: stopLat == null && nullToAbsent
          ? const Value.absent()
          : Value(stopLat),
      stopLon: stopLon == null && nullToAbsent
          ? const Value.absent()
          : Value(stopLon),
      locationType: locationType == null && nullToAbsent
          ? const Value.absent()
          : Value(locationType),
      parentStation: parentStation == null && nullToAbsent
          ? const Value.absent()
          : Value(parentStation),
      wheelchairBoarding: wheelchairBoarding == null && nullToAbsent
          ? const Value.absent()
          : Value(wheelchairBoarding),
      platformCode: platformCode == null && nullToAbsent
          ? const Value.absent()
          : Value(platformCode),
      endpoint: Value(endpoint),
    );
  }

  factory Stop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stop(
      stopId: serializer.fromJson<String>(json['stopId']),
      stopName: serializer.fromJson<String>(json['stopName']),
      stopCode: serializer.fromJson<String?>(json['stopCode']),
      ttsStopName: serializer.fromJson<String?>(json['ttsStopName']),
      stopDesc: serializer.fromJson<String?>(json['stopDesc']),
      zoneId: serializer.fromJson<String?>(json['zoneId']),
      stopUrl: serializer.fromJson<String?>(json['stopUrl']),
      stopTimezone: serializer.fromJson<String?>(json['stopTimezone']),
      levelId: serializer.fromJson<String?>(json['levelId']),
      stopLat: serializer.fromJson<double?>(json['stopLat']),
      stopLon: serializer.fromJson<double?>(json['stopLon']),
      locationType: serializer.fromJson<int?>(json['locationType']),
      parentStation: serializer.fromJson<String?>(json['parentStation']),
      wheelchairBoarding: serializer.fromJson<int?>(json['wheelchairBoarding']),
      platformCode: serializer.fromJson<String?>(json['platformCode']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stopId': serializer.toJson<String>(stopId),
      'stopName': serializer.toJson<String>(stopName),
      'stopCode': serializer.toJson<String?>(stopCode),
      'ttsStopName': serializer.toJson<String?>(ttsStopName),
      'stopDesc': serializer.toJson<String?>(stopDesc),
      'zoneId': serializer.toJson<String?>(zoneId),
      'stopUrl': serializer.toJson<String?>(stopUrl),
      'stopTimezone': serializer.toJson<String?>(stopTimezone),
      'levelId': serializer.toJson<String?>(levelId),
      'stopLat': serializer.toJson<double?>(stopLat),
      'stopLon': serializer.toJson<double?>(stopLon),
      'locationType': serializer.toJson<int?>(locationType),
      'parentStation': serializer.toJson<String?>(parentStation),
      'wheelchairBoarding': serializer.toJson<int?>(wheelchairBoarding),
      'platformCode': serializer.toJson<String?>(platformCode),
      'endpoint': serializer.toJson<String>(endpoint),
    };
  }

  Stop copyWith({
    String? stopId,
    String? stopName,
    Value<String?> stopCode = const Value.absent(),
    Value<String?> ttsStopName = const Value.absent(),
    Value<String?> stopDesc = const Value.absent(),
    Value<String?> zoneId = const Value.absent(),
    Value<String?> stopUrl = const Value.absent(),
    Value<String?> stopTimezone = const Value.absent(),
    Value<String?> levelId = const Value.absent(),
    Value<double?> stopLat = const Value.absent(),
    Value<double?> stopLon = const Value.absent(),
    Value<int?> locationType = const Value.absent(),
    Value<String?> parentStation = const Value.absent(),
    Value<int?> wheelchairBoarding = const Value.absent(),
    Value<String?> platformCode = const Value.absent(),
    String? endpoint,
  }) => Stop(
    stopId: stopId ?? this.stopId,
    stopName: stopName ?? this.stopName,
    stopCode: stopCode.present ? stopCode.value : this.stopCode,
    ttsStopName: ttsStopName.present ? ttsStopName.value : this.ttsStopName,
    stopDesc: stopDesc.present ? stopDesc.value : this.stopDesc,
    zoneId: zoneId.present ? zoneId.value : this.zoneId,
    stopUrl: stopUrl.present ? stopUrl.value : this.stopUrl,
    stopTimezone: stopTimezone.present ? stopTimezone.value : this.stopTimezone,
    levelId: levelId.present ? levelId.value : this.levelId,
    stopLat: stopLat.present ? stopLat.value : this.stopLat,
    stopLon: stopLon.present ? stopLon.value : this.stopLon,
    locationType: locationType.present ? locationType.value : this.locationType,
    parentStation: parentStation.present
        ? parentStation.value
        : this.parentStation,
    wheelchairBoarding: wheelchairBoarding.present
        ? wheelchairBoarding.value
        : this.wheelchairBoarding,
    platformCode: platformCode.present ? platformCode.value : this.platformCode,
    endpoint: endpoint ?? this.endpoint,
  );
  Stop copyWithCompanion(StopsCompanion data) {
    return Stop(
      stopId: data.stopId.present ? data.stopId.value : this.stopId,
      stopName: data.stopName.present ? data.stopName.value : this.stopName,
      stopCode: data.stopCode.present ? data.stopCode.value : this.stopCode,
      ttsStopName: data.ttsStopName.present
          ? data.ttsStopName.value
          : this.ttsStopName,
      stopDesc: data.stopDesc.present ? data.stopDesc.value : this.stopDesc,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      stopUrl: data.stopUrl.present ? data.stopUrl.value : this.stopUrl,
      stopTimezone: data.stopTimezone.present
          ? data.stopTimezone.value
          : this.stopTimezone,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      stopLat: data.stopLat.present ? data.stopLat.value : this.stopLat,
      stopLon: data.stopLon.present ? data.stopLon.value : this.stopLon,
      locationType: data.locationType.present
          ? data.locationType.value
          : this.locationType,
      parentStation: data.parentStation.present
          ? data.parentStation.value
          : this.parentStation,
      wheelchairBoarding: data.wheelchairBoarding.present
          ? data.wheelchairBoarding.value
          : this.wheelchairBoarding,
      platformCode: data.platformCode.present
          ? data.platformCode.value
          : this.platformCode,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stop(')
          ..write('stopId: $stopId, ')
          ..write('stopName: $stopName, ')
          ..write('stopCode: $stopCode, ')
          ..write('ttsStopName: $ttsStopName, ')
          ..write('stopDesc: $stopDesc, ')
          ..write('zoneId: $zoneId, ')
          ..write('stopUrl: $stopUrl, ')
          ..write('stopTimezone: $stopTimezone, ')
          ..write('levelId: $levelId, ')
          ..write('stopLat: $stopLat, ')
          ..write('stopLon: $stopLon, ')
          ..write('locationType: $locationType, ')
          ..write('parentStation: $parentStation, ')
          ..write('wheelchairBoarding: $wheelchairBoarding, ')
          ..write('platformCode: $platformCode, ')
          ..write('endpoint: $endpoint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    stopId,
    stopName,
    stopCode,
    ttsStopName,
    stopDesc,
    zoneId,
    stopUrl,
    stopTimezone,
    levelId,
    stopLat,
    stopLon,
    locationType,
    parentStation,
    wheelchairBoarding,
    platformCode,
    endpoint,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stop &&
          other.stopId == this.stopId &&
          other.stopName == this.stopName &&
          other.stopCode == this.stopCode &&
          other.ttsStopName == this.ttsStopName &&
          other.stopDesc == this.stopDesc &&
          other.zoneId == this.zoneId &&
          other.stopUrl == this.stopUrl &&
          other.stopTimezone == this.stopTimezone &&
          other.levelId == this.levelId &&
          other.stopLat == this.stopLat &&
          other.stopLon == this.stopLon &&
          other.locationType == this.locationType &&
          other.parentStation == this.parentStation &&
          other.wheelchairBoarding == this.wheelchairBoarding &&
          other.platformCode == this.platformCode &&
          other.endpoint == this.endpoint);
}

class StopsCompanion extends UpdateCompanion<Stop> {
  final Value<String> stopId;
  final Value<String> stopName;
  final Value<String?> stopCode;
  final Value<String?> ttsStopName;
  final Value<String?> stopDesc;
  final Value<String?> zoneId;
  final Value<String?> stopUrl;
  final Value<String?> stopTimezone;
  final Value<String?> levelId;
  final Value<double?> stopLat;
  final Value<double?> stopLon;
  final Value<int?> locationType;
  final Value<String?> parentStation;
  final Value<int?> wheelchairBoarding;
  final Value<String?> platformCode;
  final Value<String> endpoint;
  final Value<int> rowid;
  const StopsCompanion({
    this.stopId = const Value.absent(),
    this.stopName = const Value.absent(),
    this.stopCode = const Value.absent(),
    this.ttsStopName = const Value.absent(),
    this.stopDesc = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.stopUrl = const Value.absent(),
    this.stopTimezone = const Value.absent(),
    this.levelId = const Value.absent(),
    this.stopLat = const Value.absent(),
    this.stopLon = const Value.absent(),
    this.locationType = const Value.absent(),
    this.parentStation = const Value.absent(),
    this.wheelchairBoarding = const Value.absent(),
    this.platformCode = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StopsCompanion.insert({
    required String stopId,
    required String stopName,
    this.stopCode = const Value.absent(),
    this.ttsStopName = const Value.absent(),
    this.stopDesc = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.stopUrl = const Value.absent(),
    this.stopTimezone = const Value.absent(),
    this.levelId = const Value.absent(),
    this.stopLat = const Value.absent(),
    this.stopLon = const Value.absent(),
    this.locationType = const Value.absent(),
    this.parentStation = const Value.absent(),
    this.wheelchairBoarding = const Value.absent(),
    this.platformCode = const Value.absent(),
    required String endpoint,
    this.rowid = const Value.absent(),
  }) : stopId = Value(stopId),
       stopName = Value(stopName),
       endpoint = Value(endpoint);
  static Insertable<Stop> custom({
    Expression<String>? stopId,
    Expression<String>? stopName,
    Expression<String>? stopCode,
    Expression<String>? ttsStopName,
    Expression<String>? stopDesc,
    Expression<String>? zoneId,
    Expression<String>? stopUrl,
    Expression<String>? stopTimezone,
    Expression<String>? levelId,
    Expression<double>? stopLat,
    Expression<double>? stopLon,
    Expression<int>? locationType,
    Expression<String>? parentStation,
    Expression<int>? wheelchairBoarding,
    Expression<String>? platformCode,
    Expression<String>? endpoint,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stopId != null) 'stop_id': stopId,
      if (stopName != null) 'stop_name': stopName,
      if (stopCode != null) 'stop_code': stopCode,
      if (ttsStopName != null) 'tts_stop_name': ttsStopName,
      if (stopDesc != null) 'stop_desc': stopDesc,
      if (zoneId != null) 'zone_id': zoneId,
      if (stopUrl != null) 'stop_url': stopUrl,
      if (stopTimezone != null) 'stop_timezone': stopTimezone,
      if (levelId != null) 'level_id': levelId,
      if (stopLat != null) 'stop_lat': stopLat,
      if (stopLon != null) 'stop_lon': stopLon,
      if (locationType != null) 'location_type': locationType,
      if (parentStation != null) 'parent_station': parentStation,
      if (wheelchairBoarding != null) 'wheelchair_boarding': wheelchairBoarding,
      if (platformCode != null) 'platform_code': platformCode,
      if (endpoint != null) 'endpoint': endpoint,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StopsCompanion copyWith({
    Value<String>? stopId,
    Value<String>? stopName,
    Value<String?>? stopCode,
    Value<String?>? ttsStopName,
    Value<String?>? stopDesc,
    Value<String?>? zoneId,
    Value<String?>? stopUrl,
    Value<String?>? stopTimezone,
    Value<String?>? levelId,
    Value<double?>? stopLat,
    Value<double?>? stopLon,
    Value<int?>? locationType,
    Value<String?>? parentStation,
    Value<int?>? wheelchairBoarding,
    Value<String?>? platformCode,
    Value<String>? endpoint,
    Value<int>? rowid,
  }) {
    return StopsCompanion(
      stopId: stopId ?? this.stopId,
      stopName: stopName ?? this.stopName,
      stopCode: stopCode ?? this.stopCode,
      ttsStopName: ttsStopName ?? this.ttsStopName,
      stopDesc: stopDesc ?? this.stopDesc,
      zoneId: zoneId ?? this.zoneId,
      stopUrl: stopUrl ?? this.stopUrl,
      stopTimezone: stopTimezone ?? this.stopTimezone,
      levelId: levelId ?? this.levelId,
      stopLat: stopLat ?? this.stopLat,
      stopLon: stopLon ?? this.stopLon,
      locationType: locationType ?? this.locationType,
      parentStation: parentStation ?? this.parentStation,
      wheelchairBoarding: wheelchairBoarding ?? this.wheelchairBoarding,
      platformCode: platformCode ?? this.platformCode,
      endpoint: endpoint ?? this.endpoint,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stopId.present) {
      map['stop_id'] = Variable<String>(stopId.value);
    }
    if (stopName.present) {
      map['stop_name'] = Variable<String>(stopName.value);
    }
    if (stopCode.present) {
      map['stop_code'] = Variable<String>(stopCode.value);
    }
    if (ttsStopName.present) {
      map['tts_stop_name'] = Variable<String>(ttsStopName.value);
    }
    if (stopDesc.present) {
      map['stop_desc'] = Variable<String>(stopDesc.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (stopUrl.present) {
      map['stop_url'] = Variable<String>(stopUrl.value);
    }
    if (stopTimezone.present) {
      map['stop_timezone'] = Variable<String>(stopTimezone.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (stopLat.present) {
      map['stop_lat'] = Variable<double>(stopLat.value);
    }
    if (stopLon.present) {
      map['stop_lon'] = Variable<double>(stopLon.value);
    }
    if (locationType.present) {
      map['location_type'] = Variable<int>(locationType.value);
    }
    if (parentStation.present) {
      map['parent_station'] = Variable<String>(parentStation.value);
    }
    if (wheelchairBoarding.present) {
      map['wheelchair_boarding'] = Variable<int>(wheelchairBoarding.value);
    }
    if (platformCode.present) {
      map['platform_code'] = Variable<String>(platformCode.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StopsCompanion(')
          ..write('stopId: $stopId, ')
          ..write('stopName: $stopName, ')
          ..write('stopCode: $stopCode, ')
          ..write('ttsStopName: $ttsStopName, ')
          ..write('stopDesc: $stopDesc, ')
          ..write('zoneId: $zoneId, ')
          ..write('stopUrl: $stopUrl, ')
          ..write('stopTimezone: $stopTimezone, ')
          ..write('levelId: $levelId, ')
          ..write('stopLat: $stopLat, ')
          ..write('stopLon: $stopLon, ')
          ..write('locationType: $locationType, ')
          ..write('parentStation: $parentStation, ')
          ..write('wheelchairBoarding: $wheelchairBoarding, ')
          ..write('platformCode: $platformCode, ')
          ..write('endpoint: $endpoint, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StopLineMembershipsTable extends StopLineMemberships
    with TableInfo<$StopLineMembershipsTable, StopLineMembership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StopLineMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopIdMeta = const VerificationMeta('stopId');
  @override
  late final GeneratedColumn<String> stopId = GeneratedColumn<String>(
    'stop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopNameMeta = const VerificationMeta(
    'stopName',
  );
  @override
  late final GeneratedColumn<String> stopName = GeneratedColumn<String>(
    'stop_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<String> lineId = GeneratedColumn<String>(
    'line_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineNameMeta = const VerificationMeta(
    'lineName',
  );
  @override
  late final GeneratedColumn<String> lineName = GeneratedColumn<String>(
    'line_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopOrderMeta = const VerificationMeta(
    'stopOrder',
  );
  @override
  late final GeneratedColumn<int> stopOrder = GeneratedColumn<int>(
    'stop_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopLatMeta = const VerificationMeta(
    'stopLat',
  );
  @override
  late final GeneratedColumn<double> stopLat = GeneratedColumn<double>(
    'stop_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopLonMeta = const VerificationMeta(
    'stopLon',
  );
  @override
  late final GeneratedColumn<double> stopLon = GeneratedColumn<double>(
    'stop_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    endpoint,
    stopId,
    stopName,
    lineId,
    lineName,
    mode,
    stopOrder,
    stopLat,
    stopLon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stop_line_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<StopLineMembership> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('stop_id')) {
      context.handle(
        _stopIdMeta,
        stopId.isAcceptableOrUnknown(data['stop_id']!, _stopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stopIdMeta);
    }
    if (data.containsKey('stop_name')) {
      context.handle(
        _stopNameMeta,
        stopName.isAcceptableOrUnknown(data['stop_name']!, _stopNameMeta),
      );
    } else if (isInserting) {
      context.missing(_stopNameMeta);
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineIdMeta);
    }
    if (data.containsKey('line_name')) {
      context.handle(
        _lineNameMeta,
        lineName.isAcceptableOrUnknown(data['line_name']!, _lineNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNameMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('stop_order')) {
      context.handle(
        _stopOrderMeta,
        stopOrder.isAcceptableOrUnknown(data['stop_order']!, _stopOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_stopOrderMeta);
    }
    if (data.containsKey('stop_lat')) {
      context.handle(
        _stopLatMeta,
        stopLat.isAcceptableOrUnknown(data['stop_lat']!, _stopLatMeta),
      );
    }
    if (data.containsKey('stop_lon')) {
      context.handle(
        _stopLonMeta,
        stopLon.isAcceptableOrUnknown(data['stop_lon']!, _stopLonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {endpoint, stopId, lineId};
  @override
  StopLineMembership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StopLineMembership(
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      stopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_id'],
      )!,
      stopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_name'],
      )!,
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_id'],
      )!,
      lineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_name'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      stopOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stop_order'],
      )!,
      stopLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stop_lat'],
      ),
      stopLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stop_lon'],
      ),
    );
  }

  @override
  $StopLineMembershipsTable createAlias(String alias) {
    return $StopLineMembershipsTable(attachedDatabase, alias);
  }
}

class StopLineMembership extends DataClass
    implements Insertable<StopLineMembership> {
  final String endpoint;
  final String stopId;
  final String stopName;
  final String lineId;
  final String lineName;
  final String mode;
  final int stopOrder;
  final double? stopLat;
  final double? stopLon;
  const StopLineMembership({
    required this.endpoint,
    required this.stopId,
    required this.stopName,
    required this.lineId,
    required this.lineName,
    required this.mode,
    required this.stopOrder,
    this.stopLat,
    this.stopLon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['endpoint'] = Variable<String>(endpoint);
    map['stop_id'] = Variable<String>(stopId);
    map['stop_name'] = Variable<String>(stopName);
    map['line_id'] = Variable<String>(lineId);
    map['line_name'] = Variable<String>(lineName);
    map['mode'] = Variable<String>(mode);
    map['stop_order'] = Variable<int>(stopOrder);
    if (!nullToAbsent || stopLat != null) {
      map['stop_lat'] = Variable<double>(stopLat);
    }
    if (!nullToAbsent || stopLon != null) {
      map['stop_lon'] = Variable<double>(stopLon);
    }
    return map;
  }

  StopLineMembershipsCompanion toCompanion(bool nullToAbsent) {
    return StopLineMembershipsCompanion(
      endpoint: Value(endpoint),
      stopId: Value(stopId),
      stopName: Value(stopName),
      lineId: Value(lineId),
      lineName: Value(lineName),
      mode: Value(mode),
      stopOrder: Value(stopOrder),
      stopLat: stopLat == null && nullToAbsent
          ? const Value.absent()
          : Value(stopLat),
      stopLon: stopLon == null && nullToAbsent
          ? const Value.absent()
          : Value(stopLon),
    );
  }

  factory StopLineMembership.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StopLineMembership(
      endpoint: serializer.fromJson<String>(json['endpoint']),
      stopId: serializer.fromJson<String>(json['stopId']),
      stopName: serializer.fromJson<String>(json['stopName']),
      lineId: serializer.fromJson<String>(json['lineId']),
      lineName: serializer.fromJson<String>(json['lineName']),
      mode: serializer.fromJson<String>(json['mode']),
      stopOrder: serializer.fromJson<int>(json['stopOrder']),
      stopLat: serializer.fromJson<double?>(json['stopLat']),
      stopLon: serializer.fromJson<double?>(json['stopLon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'endpoint': serializer.toJson<String>(endpoint),
      'stopId': serializer.toJson<String>(stopId),
      'stopName': serializer.toJson<String>(stopName),
      'lineId': serializer.toJson<String>(lineId),
      'lineName': serializer.toJson<String>(lineName),
      'mode': serializer.toJson<String>(mode),
      'stopOrder': serializer.toJson<int>(stopOrder),
      'stopLat': serializer.toJson<double?>(stopLat),
      'stopLon': serializer.toJson<double?>(stopLon),
    };
  }

  StopLineMembership copyWith({
    String? endpoint,
    String? stopId,
    String? stopName,
    String? lineId,
    String? lineName,
    String? mode,
    int? stopOrder,
    Value<double?> stopLat = const Value.absent(),
    Value<double?> stopLon = const Value.absent(),
  }) => StopLineMembership(
    endpoint: endpoint ?? this.endpoint,
    stopId: stopId ?? this.stopId,
    stopName: stopName ?? this.stopName,
    lineId: lineId ?? this.lineId,
    lineName: lineName ?? this.lineName,
    mode: mode ?? this.mode,
    stopOrder: stopOrder ?? this.stopOrder,
    stopLat: stopLat.present ? stopLat.value : this.stopLat,
    stopLon: stopLon.present ? stopLon.value : this.stopLon,
  );
  StopLineMembership copyWithCompanion(StopLineMembershipsCompanion data) {
    return StopLineMembership(
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      stopId: data.stopId.present ? data.stopId.value : this.stopId,
      stopName: data.stopName.present ? data.stopName.value : this.stopName,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      lineName: data.lineName.present ? data.lineName.value : this.lineName,
      mode: data.mode.present ? data.mode.value : this.mode,
      stopOrder: data.stopOrder.present ? data.stopOrder.value : this.stopOrder,
      stopLat: data.stopLat.present ? data.stopLat.value : this.stopLat,
      stopLon: data.stopLon.present ? data.stopLon.value : this.stopLon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StopLineMembership(')
          ..write('endpoint: $endpoint, ')
          ..write('stopId: $stopId, ')
          ..write('stopName: $stopName, ')
          ..write('lineId: $lineId, ')
          ..write('lineName: $lineName, ')
          ..write('mode: $mode, ')
          ..write('stopOrder: $stopOrder, ')
          ..write('stopLat: $stopLat, ')
          ..write('stopLon: $stopLon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    endpoint,
    stopId,
    stopName,
    lineId,
    lineName,
    mode,
    stopOrder,
    stopLat,
    stopLon,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StopLineMembership &&
          other.endpoint == this.endpoint &&
          other.stopId == this.stopId &&
          other.stopName == this.stopName &&
          other.lineId == this.lineId &&
          other.lineName == this.lineName &&
          other.mode == this.mode &&
          other.stopOrder == this.stopOrder &&
          other.stopLat == this.stopLat &&
          other.stopLon == this.stopLon);
}

class StopLineMembershipsCompanion extends UpdateCompanion<StopLineMembership> {
  final Value<String> endpoint;
  final Value<String> stopId;
  final Value<String> stopName;
  final Value<String> lineId;
  final Value<String> lineName;
  final Value<String> mode;
  final Value<int> stopOrder;
  final Value<double?> stopLat;
  final Value<double?> stopLon;
  final Value<int> rowid;
  const StopLineMembershipsCompanion({
    this.endpoint = const Value.absent(),
    this.stopId = const Value.absent(),
    this.stopName = const Value.absent(),
    this.lineId = const Value.absent(),
    this.lineName = const Value.absent(),
    this.mode = const Value.absent(),
    this.stopOrder = const Value.absent(),
    this.stopLat = const Value.absent(),
    this.stopLon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StopLineMembershipsCompanion.insert({
    required String endpoint,
    required String stopId,
    required String stopName,
    required String lineId,
    required String lineName,
    required String mode,
    required int stopOrder,
    this.stopLat = const Value.absent(),
    this.stopLon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : endpoint = Value(endpoint),
       stopId = Value(stopId),
       stopName = Value(stopName),
       lineId = Value(lineId),
       lineName = Value(lineName),
       mode = Value(mode),
       stopOrder = Value(stopOrder);
  static Insertable<StopLineMembership> custom({
    Expression<String>? endpoint,
    Expression<String>? stopId,
    Expression<String>? stopName,
    Expression<String>? lineId,
    Expression<String>? lineName,
    Expression<String>? mode,
    Expression<int>? stopOrder,
    Expression<double>? stopLat,
    Expression<double>? stopLon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (endpoint != null) 'endpoint': endpoint,
      if (stopId != null) 'stop_id': stopId,
      if (stopName != null) 'stop_name': stopName,
      if (lineId != null) 'line_id': lineId,
      if (lineName != null) 'line_name': lineName,
      if (mode != null) 'mode': mode,
      if (stopOrder != null) 'stop_order': stopOrder,
      if (stopLat != null) 'stop_lat': stopLat,
      if (stopLon != null) 'stop_lon': stopLon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StopLineMembershipsCompanion copyWith({
    Value<String>? endpoint,
    Value<String>? stopId,
    Value<String>? stopName,
    Value<String>? lineId,
    Value<String>? lineName,
    Value<String>? mode,
    Value<int>? stopOrder,
    Value<double?>? stopLat,
    Value<double?>? stopLon,
    Value<int>? rowid,
  }) {
    return StopLineMembershipsCompanion(
      endpoint: endpoint ?? this.endpoint,
      stopId: stopId ?? this.stopId,
      stopName: stopName ?? this.stopName,
      lineId: lineId ?? this.lineId,
      lineName: lineName ?? this.lineName,
      mode: mode ?? this.mode,
      stopOrder: stopOrder ?? this.stopOrder,
      stopLat: stopLat ?? this.stopLat,
      stopLon: stopLon ?? this.stopLon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (stopId.present) {
      map['stop_id'] = Variable<String>(stopId.value);
    }
    if (stopName.present) {
      map['stop_name'] = Variable<String>(stopName.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<String>(lineId.value);
    }
    if (lineName.present) {
      map['line_name'] = Variable<String>(lineName.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (stopOrder.present) {
      map['stop_order'] = Variable<int>(stopOrder.value);
    }
    if (stopLat.present) {
      map['stop_lat'] = Variable<double>(stopLat.value);
    }
    if (stopLon.present) {
      map['stop_lon'] = Variable<double>(stopLon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StopLineMembershipsCompanion(')
          ..write('endpoint: $endpoint, ')
          ..write('stopId: $stopId, ')
          ..write('stopName: $stopName, ')
          ..write('lineId: $lineId, ')
          ..write('lineName: $lineName, ')
          ..write('mode: $mode, ')
          ..write('stopOrder: $stopOrder, ')
          ..write('stopLat: $stopLat, ')
          ..write('stopLon: $stopLon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaticCacheStatusesTable extends StaticCacheStatuses
    with TableInfo<$StaticCacheStatusesTable, StaticCacheStatuse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaticCacheStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopsUpdatedAtMeta = const VerificationMeta(
    'stopsUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> stopsUpdatedAt =
      GeneratedColumn<DateTime>(
        'stops_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lineMembershipsUpdatedAtMeta =
      const VerificationMeta('lineMembershipsUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> lineMembershipsUpdatedAt =
      GeneratedColumn<DateTime>(
        'line_memberships_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastBuildStartedAtMeta =
      const VerificationMeta('lastBuildStartedAt');
  @override
  late final GeneratedColumn<DateTime> lastBuildStartedAt =
      GeneratedColumn<DateTime>(
        'last_build_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastBuildFinishedAtMeta =
      const VerificationMeta('lastBuildFinishedAt');
  @override
  late final GeneratedColumn<DateTime> lastBuildFinishedAt =
      GeneratedColumn<DateTime>(
        'last_build_finished_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBuildingMeta = const VerificationMeta(
    'isBuilding',
  );
  @override
  late final GeneratedColumn<bool> isBuilding = GeneratedColumn<bool>(
    'is_building',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_building" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    endpoint,
    stopsUpdatedAt,
    lineMembershipsUpdatedAt,
    lastBuildStartedAt,
    lastBuildFinishedAt,
    lastError,
    isBuilding,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'static_cache_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaticCacheStatuse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('stops_updated_at')) {
      context.handle(
        _stopsUpdatedAtMeta,
        stopsUpdatedAt.isAcceptableOrUnknown(
          data['stops_updated_at']!,
          _stopsUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('line_memberships_updated_at')) {
      context.handle(
        _lineMembershipsUpdatedAtMeta,
        lineMembershipsUpdatedAt.isAcceptableOrUnknown(
          data['line_memberships_updated_at']!,
          _lineMembershipsUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_build_started_at')) {
      context.handle(
        _lastBuildStartedAtMeta,
        lastBuildStartedAt.isAcceptableOrUnknown(
          data['last_build_started_at']!,
          _lastBuildStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_build_finished_at')) {
      context.handle(
        _lastBuildFinishedAtMeta,
        lastBuildFinishedAt.isAcceptableOrUnknown(
          data['last_build_finished_at']!,
          _lastBuildFinishedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('is_building')) {
      context.handle(
        _isBuildingMeta,
        isBuilding.isAcceptableOrUnknown(data['is_building']!, _isBuildingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {endpoint};
  @override
  StaticCacheStatuse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaticCacheStatuse(
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      stopsUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}stops_updated_at'],
      ),
      lineMembershipsUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}line_memberships_updated_at'],
      ),
      lastBuildStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_build_started_at'],
      ),
      lastBuildFinishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_build_finished_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      isBuilding: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_building'],
      )!,
    );
  }

  @override
  $StaticCacheStatusesTable createAlias(String alias) {
    return $StaticCacheStatusesTable(attachedDatabase, alias);
  }
}

class StaticCacheStatuse extends DataClass
    implements Insertable<StaticCacheStatuse> {
  final String endpoint;
  final DateTime? stopsUpdatedAt;
  final DateTime? lineMembershipsUpdatedAt;
  final DateTime? lastBuildStartedAt;
  final DateTime? lastBuildFinishedAt;
  final String? lastError;
  final bool isBuilding;
  const StaticCacheStatuse({
    required this.endpoint,
    this.stopsUpdatedAt,
    this.lineMembershipsUpdatedAt,
    this.lastBuildStartedAt,
    this.lastBuildFinishedAt,
    this.lastError,
    required this.isBuilding,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['endpoint'] = Variable<String>(endpoint);
    if (!nullToAbsent || stopsUpdatedAt != null) {
      map['stops_updated_at'] = Variable<DateTime>(stopsUpdatedAt);
    }
    if (!nullToAbsent || lineMembershipsUpdatedAt != null) {
      map['line_memberships_updated_at'] = Variable<DateTime>(
        lineMembershipsUpdatedAt,
      );
    }
    if (!nullToAbsent || lastBuildStartedAt != null) {
      map['last_build_started_at'] = Variable<DateTime>(lastBuildStartedAt);
    }
    if (!nullToAbsent || lastBuildFinishedAt != null) {
      map['last_build_finished_at'] = Variable<DateTime>(lastBuildFinishedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['is_building'] = Variable<bool>(isBuilding);
    return map;
  }

  StaticCacheStatusesCompanion toCompanion(bool nullToAbsent) {
    return StaticCacheStatusesCompanion(
      endpoint: Value(endpoint),
      stopsUpdatedAt: stopsUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(stopsUpdatedAt),
      lineMembershipsUpdatedAt: lineMembershipsUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lineMembershipsUpdatedAt),
      lastBuildStartedAt: lastBuildStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBuildStartedAt),
      lastBuildFinishedAt: lastBuildFinishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBuildFinishedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      isBuilding: Value(isBuilding),
    );
  }

  factory StaticCacheStatuse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaticCacheStatuse(
      endpoint: serializer.fromJson<String>(json['endpoint']),
      stopsUpdatedAt: serializer.fromJson<DateTime?>(json['stopsUpdatedAt']),
      lineMembershipsUpdatedAt: serializer.fromJson<DateTime?>(
        json['lineMembershipsUpdatedAt'],
      ),
      lastBuildStartedAt: serializer.fromJson<DateTime?>(
        json['lastBuildStartedAt'],
      ),
      lastBuildFinishedAt: serializer.fromJson<DateTime?>(
        json['lastBuildFinishedAt'],
      ),
      lastError: serializer.fromJson<String?>(json['lastError']),
      isBuilding: serializer.fromJson<bool>(json['isBuilding']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'endpoint': serializer.toJson<String>(endpoint),
      'stopsUpdatedAt': serializer.toJson<DateTime?>(stopsUpdatedAt),
      'lineMembershipsUpdatedAt': serializer.toJson<DateTime?>(
        lineMembershipsUpdatedAt,
      ),
      'lastBuildStartedAt': serializer.toJson<DateTime?>(lastBuildStartedAt),
      'lastBuildFinishedAt': serializer.toJson<DateTime?>(lastBuildFinishedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'isBuilding': serializer.toJson<bool>(isBuilding),
    };
  }

  StaticCacheStatuse copyWith({
    String? endpoint,
    Value<DateTime?> stopsUpdatedAt = const Value.absent(),
    Value<DateTime?> lineMembershipsUpdatedAt = const Value.absent(),
    Value<DateTime?> lastBuildStartedAt = const Value.absent(),
    Value<DateTime?> lastBuildFinishedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    bool? isBuilding,
  }) => StaticCacheStatuse(
    endpoint: endpoint ?? this.endpoint,
    stopsUpdatedAt: stopsUpdatedAt.present
        ? stopsUpdatedAt.value
        : this.stopsUpdatedAt,
    lineMembershipsUpdatedAt: lineMembershipsUpdatedAt.present
        ? lineMembershipsUpdatedAt.value
        : this.lineMembershipsUpdatedAt,
    lastBuildStartedAt: lastBuildStartedAt.present
        ? lastBuildStartedAt.value
        : this.lastBuildStartedAt,
    lastBuildFinishedAt: lastBuildFinishedAt.present
        ? lastBuildFinishedAt.value
        : this.lastBuildFinishedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    isBuilding: isBuilding ?? this.isBuilding,
  );
  StaticCacheStatuse copyWithCompanion(StaticCacheStatusesCompanion data) {
    return StaticCacheStatuse(
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      stopsUpdatedAt: data.stopsUpdatedAt.present
          ? data.stopsUpdatedAt.value
          : this.stopsUpdatedAt,
      lineMembershipsUpdatedAt: data.lineMembershipsUpdatedAt.present
          ? data.lineMembershipsUpdatedAt.value
          : this.lineMembershipsUpdatedAt,
      lastBuildStartedAt: data.lastBuildStartedAt.present
          ? data.lastBuildStartedAt.value
          : this.lastBuildStartedAt,
      lastBuildFinishedAt: data.lastBuildFinishedAt.present
          ? data.lastBuildFinishedAt.value
          : this.lastBuildFinishedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      isBuilding: data.isBuilding.present
          ? data.isBuilding.value
          : this.isBuilding,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaticCacheStatuse(')
          ..write('endpoint: $endpoint, ')
          ..write('stopsUpdatedAt: $stopsUpdatedAt, ')
          ..write('lineMembershipsUpdatedAt: $lineMembershipsUpdatedAt, ')
          ..write('lastBuildStartedAt: $lastBuildStartedAt, ')
          ..write('lastBuildFinishedAt: $lastBuildFinishedAt, ')
          ..write('lastError: $lastError, ')
          ..write('isBuilding: $isBuilding')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    endpoint,
    stopsUpdatedAt,
    lineMembershipsUpdatedAt,
    lastBuildStartedAt,
    lastBuildFinishedAt,
    lastError,
    isBuilding,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaticCacheStatuse &&
          other.endpoint == this.endpoint &&
          other.stopsUpdatedAt == this.stopsUpdatedAt &&
          other.lineMembershipsUpdatedAt == this.lineMembershipsUpdatedAt &&
          other.lastBuildStartedAt == this.lastBuildStartedAt &&
          other.lastBuildFinishedAt == this.lastBuildFinishedAt &&
          other.lastError == this.lastError &&
          other.isBuilding == this.isBuilding);
}

class StaticCacheStatusesCompanion extends UpdateCompanion<StaticCacheStatuse> {
  final Value<String> endpoint;
  final Value<DateTime?> stopsUpdatedAt;
  final Value<DateTime?> lineMembershipsUpdatedAt;
  final Value<DateTime?> lastBuildStartedAt;
  final Value<DateTime?> lastBuildFinishedAt;
  final Value<String?> lastError;
  final Value<bool> isBuilding;
  final Value<int> rowid;
  const StaticCacheStatusesCompanion({
    this.endpoint = const Value.absent(),
    this.stopsUpdatedAt = const Value.absent(),
    this.lineMembershipsUpdatedAt = const Value.absent(),
    this.lastBuildStartedAt = const Value.absent(),
    this.lastBuildFinishedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isBuilding = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaticCacheStatusesCompanion.insert({
    required String endpoint,
    this.stopsUpdatedAt = const Value.absent(),
    this.lineMembershipsUpdatedAt = const Value.absent(),
    this.lastBuildStartedAt = const Value.absent(),
    this.lastBuildFinishedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isBuilding = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : endpoint = Value(endpoint);
  static Insertable<StaticCacheStatuse> custom({
    Expression<String>? endpoint,
    Expression<DateTime>? stopsUpdatedAt,
    Expression<DateTime>? lineMembershipsUpdatedAt,
    Expression<DateTime>? lastBuildStartedAt,
    Expression<DateTime>? lastBuildFinishedAt,
    Expression<String>? lastError,
    Expression<bool>? isBuilding,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (endpoint != null) 'endpoint': endpoint,
      if (stopsUpdatedAt != null) 'stops_updated_at': stopsUpdatedAt,
      if (lineMembershipsUpdatedAt != null)
        'line_memberships_updated_at': lineMembershipsUpdatedAt,
      if (lastBuildStartedAt != null)
        'last_build_started_at': lastBuildStartedAt,
      if (lastBuildFinishedAt != null)
        'last_build_finished_at': lastBuildFinishedAt,
      if (lastError != null) 'last_error': lastError,
      if (isBuilding != null) 'is_building': isBuilding,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaticCacheStatusesCompanion copyWith({
    Value<String>? endpoint,
    Value<DateTime?>? stopsUpdatedAt,
    Value<DateTime?>? lineMembershipsUpdatedAt,
    Value<DateTime?>? lastBuildStartedAt,
    Value<DateTime?>? lastBuildFinishedAt,
    Value<String?>? lastError,
    Value<bool>? isBuilding,
    Value<int>? rowid,
  }) {
    return StaticCacheStatusesCompanion(
      endpoint: endpoint ?? this.endpoint,
      stopsUpdatedAt: stopsUpdatedAt ?? this.stopsUpdatedAt,
      lineMembershipsUpdatedAt:
          lineMembershipsUpdatedAt ?? this.lineMembershipsUpdatedAt,
      lastBuildStartedAt: lastBuildStartedAt ?? this.lastBuildStartedAt,
      lastBuildFinishedAt: lastBuildFinishedAt ?? this.lastBuildFinishedAt,
      lastError: lastError ?? this.lastError,
      isBuilding: isBuilding ?? this.isBuilding,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (stopsUpdatedAt.present) {
      map['stops_updated_at'] = Variable<DateTime>(stopsUpdatedAt.value);
    }
    if (lineMembershipsUpdatedAt.present) {
      map['line_memberships_updated_at'] = Variable<DateTime>(
        lineMembershipsUpdatedAt.value,
      );
    }
    if (lastBuildStartedAt.present) {
      map['last_build_started_at'] = Variable<DateTime>(
        lastBuildStartedAt.value,
      );
    }
    if (lastBuildFinishedAt.present) {
      map['last_build_finished_at'] = Variable<DateTime>(
        lastBuildFinishedAt.value,
      );
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (isBuilding.present) {
      map['is_building'] = Variable<bool>(isBuilding.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaticCacheStatusesCompanion(')
          ..write('endpoint: $endpoint, ')
          ..write('stopsUpdatedAt: $stopsUpdatedAt, ')
          ..write('lineMembershipsUpdatedAt: $lineMembershipsUpdatedAt, ')
          ..write('lastBuildStartedAt: $lastBuildStartedAt, ')
          ..write('lastBuildFinishedAt: $lastBuildFinishedAt, ')
          ..write('lastError: $lastError, ')
          ..write('isBuilding: $isBuilding, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripPlannerCacheTable extends TripPlannerCache
    with TableInfo<$TripPlannerCacheTable, TripPlannerCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripPlannerCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _originIdMeta = const VerificationMeta(
    'originId',
  );
  @override
  late final GeneratedColumn<String> originId = GeneratedColumn<String>(
    'origin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationIdMeta = const VerificationMeta(
    'destinationId',
  );
  @override
  late final GeneratedColumn<String> destinationId = GeneratedColumn<String>(
    'destination_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseJsonMeta = const VerificationMeta(
    'responseJson',
  );
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
    'response_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    originId,
    destinationId,
    fetchedAt,
    responseJson,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_planner_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripPlannerCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('origin_id')) {
      context.handle(
        _originIdMeta,
        originId.isAcceptableOrUnknown(data['origin_id']!, _originIdMeta),
      );
    } else if (isInserting) {
      context.missing(_originIdMeta);
    }
    if (data.containsKey('destination_id')) {
      context.handle(
        _destinationIdMeta,
        destinationId.isAcceptableOrUnknown(
          data['destination_id']!,
          _destinationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationIdMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('response_json')) {
      context.handle(
        _responseJsonMeta,
        responseJson.isAcceptableOrUnknown(
          data['response_json']!,
          _responseJsonMeta,
        ),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {originId, destinationId};
  @override
  TripPlannerCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripPlannerCacheData(
      originId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_id'],
      )!,
      destinationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_id'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      responseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_json'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $TripPlannerCacheTable createAlias(String alias) {
    return $TripPlannerCacheTable(attachedDatabase, alias);
  }
}

class TripPlannerCacheData extends DataClass
    implements Insertable<TripPlannerCacheData> {
  final String originId;
  final String destinationId;
  final DateTime fetchedAt;
  final String? responseJson;
  final String? error;
  const TripPlannerCacheData({
    required this.originId,
    required this.destinationId,
    required this.fetchedAt,
    this.responseJson,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['origin_id'] = Variable<String>(originId);
    map['destination_id'] = Variable<String>(destinationId);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || responseJson != null) {
      map['response_json'] = Variable<String>(responseJson);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  TripPlannerCacheCompanion toCompanion(bool nullToAbsent) {
    return TripPlannerCacheCompanion(
      originId: Value(originId),
      destinationId: Value(destinationId),
      fetchedAt: Value(fetchedAt),
      responseJson: responseJson == null && nullToAbsent
          ? const Value.absent()
          : Value(responseJson),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory TripPlannerCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripPlannerCacheData(
      originId: serializer.fromJson<String>(json['originId']),
      destinationId: serializer.fromJson<String>(json['destinationId']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      responseJson: serializer.fromJson<String?>(json['responseJson']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'originId': serializer.toJson<String>(originId),
      'destinationId': serializer.toJson<String>(destinationId),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'responseJson': serializer.toJson<String?>(responseJson),
      'error': serializer.toJson<String?>(error),
    };
  }

  TripPlannerCacheData copyWith({
    String? originId,
    String? destinationId,
    DateTime? fetchedAt,
    Value<String?> responseJson = const Value.absent(),
    Value<String?> error = const Value.absent(),
  }) => TripPlannerCacheData(
    originId: originId ?? this.originId,
    destinationId: destinationId ?? this.destinationId,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    responseJson: responseJson.present ? responseJson.value : this.responseJson,
    error: error.present ? error.value : this.error,
  );
  TripPlannerCacheData copyWithCompanion(TripPlannerCacheCompanion data) {
    return TripPlannerCacheData(
      originId: data.originId.present ? data.originId.value : this.originId,
      destinationId: data.destinationId.present
          ? data.destinationId.value
          : this.destinationId,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripPlannerCacheData(')
          ..write('originId: $originId, ')
          ..write('destinationId: $destinationId, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('responseJson: $responseJson, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(originId, destinationId, fetchedAt, responseJson, error);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripPlannerCacheData &&
          other.originId == this.originId &&
          other.destinationId == this.destinationId &&
          other.fetchedAt == this.fetchedAt &&
          other.responseJson == this.responseJson &&
          other.error == this.error);
}

class TripPlannerCacheCompanion extends UpdateCompanion<TripPlannerCacheData> {
  final Value<String> originId;
  final Value<String> destinationId;
  final Value<DateTime> fetchedAt;
  final Value<String?> responseJson;
  final Value<String?> error;
  final Value<int> rowid;
  const TripPlannerCacheCompanion({
    this.originId = const Value.absent(),
    this.destinationId = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.error = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripPlannerCacheCompanion.insert({
    required String originId,
    required String destinationId,
    required DateTime fetchedAt,
    this.responseJson = const Value.absent(),
    this.error = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : originId = Value(originId),
       destinationId = Value(destinationId),
       fetchedAt = Value(fetchedAt);
  static Insertable<TripPlannerCacheData> custom({
    Expression<String>? originId,
    Expression<String>? destinationId,
    Expression<DateTime>? fetchedAt,
    Expression<String>? responseJson,
    Expression<String>? error,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (originId != null) 'origin_id': originId,
      if (destinationId != null) 'destination_id': destinationId,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (responseJson != null) 'response_json': responseJson,
      if (error != null) 'error': error,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripPlannerCacheCompanion copyWith({
    Value<String>? originId,
    Value<String>? destinationId,
    Value<DateTime>? fetchedAt,
    Value<String?>? responseJson,
    Value<String?>? error,
    Value<int>? rowid,
  }) {
    return TripPlannerCacheCompanion(
      originId: originId ?? this.originId,
      destinationId: destinationId ?? this.destinationId,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      responseJson: responseJson ?? this.responseJson,
      error: error ?? this.error,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (originId.present) {
      map['origin_id'] = Variable<String>(originId.value);
    }
    if (destinationId.present) {
      map['destination_id'] = Variable<String>(destinationId.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripPlannerCacheCompanion(')
          ..write('originId: $originId, ')
          ..write('destinationId: $destinationId, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('responseJson: $responseJson, ')
          ..write('error: $error, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JourneysTable journeys = $JourneysTable(this);
  late final $RoutesTable routes = $RoutesTable(this);
  late final $StopsTable stops = $StopsTable(this);
  late final $StopLineMembershipsTable stopLineMemberships =
      $StopLineMembershipsTable(this);
  late final $StaticCacheStatusesTable staticCacheStatuses =
      $StaticCacheStatusesTable(this);
  late final $TripPlannerCacheTable tripPlannerCache = $TripPlannerCacheTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    journeys,
    routes,
    stops,
    stopLineMemberships,
    staticCacheStatuses,
    tripPlannerCache,
  ];
}

typedef $$JourneysTableCreateCompanionBuilder =
    JourneysCompanion Function({
      Value<int> id,
      required String origin,
      required String originId,
      required String destination,
      required String destinationId,
      Value<String> tripType,
      Value<String?> mode,
      Value<String?> lineId,
      Value<String?> lineName,
      Value<String?> legsJson,
      Value<bool> isPinned,
    });
typedef $$JourneysTableUpdateCompanionBuilder =
    JourneysCompanion Function({
      Value<int> id,
      Value<String> origin,
      Value<String> originId,
      Value<String> destination,
      Value<String> destinationId,
      Value<String> tripType,
      Value<String?> mode,
      Value<String?> lineId,
      Value<String?> lineName,
      Value<String?> legsJson,
      Value<bool> isPinned,
    });

class $$JourneysTableFilterComposer
    extends Composer<_$AppDatabase, $JourneysTable> {
  $$JourneysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originId => $composableBuilder(
    column: $table.originId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationId => $composableBuilder(
    column: $table.destinationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripType => $composableBuilder(
    column: $table.tripType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineName => $composableBuilder(
    column: $table.lineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legsJson => $composableBuilder(
    column: $table.legsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JourneysTableOrderingComposer
    extends Composer<_$AppDatabase, $JourneysTable> {
  $$JourneysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originId => $composableBuilder(
    column: $table.originId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationId => $composableBuilder(
    column: $table.destinationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripType => $composableBuilder(
    column: $table.tripType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineName => $composableBuilder(
    column: $table.lineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legsJson => $composableBuilder(
    column: $table.legsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JourneysTableAnnotationComposer
    extends Composer<_$AppDatabase, $JourneysTable> {
  $$JourneysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get originId =>
      $composableBuilder(column: $table.originId, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationId => $composableBuilder(
    column: $table.destinationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tripType =>
      $composableBuilder(column: $table.tripType, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get lineId =>
      $composableBuilder(column: $table.lineId, builder: (column) => column);

  GeneratedColumn<String> get lineName =>
      $composableBuilder(column: $table.lineName, builder: (column) => column);

  GeneratedColumn<String> get legsJson =>
      $composableBuilder(column: $table.legsJson, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);
}

class $$JourneysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JourneysTable,
          Journey,
          $$JourneysTableFilterComposer,
          $$JourneysTableOrderingComposer,
          $$JourneysTableAnnotationComposer,
          $$JourneysTableCreateCompanionBuilder,
          $$JourneysTableUpdateCompanionBuilder,
          (Journey, BaseReferences<_$AppDatabase, $JourneysTable, Journey>),
          Journey,
          PrefetchHooks Function()
        > {
  $$JourneysTableTableManager(_$AppDatabase db, $JourneysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JourneysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JourneysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JourneysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> originId = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<String> destinationId = const Value.absent(),
                Value<String> tripType = const Value.absent(),
                Value<String?> mode = const Value.absent(),
                Value<String?> lineId = const Value.absent(),
                Value<String?> lineName = const Value.absent(),
                Value<String?> legsJson = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
              }) => JourneysCompanion(
                id: id,
                origin: origin,
                originId: originId,
                destination: destination,
                destinationId: destinationId,
                tripType: tripType,
                mode: mode,
                lineId: lineId,
                lineName: lineName,
                legsJson: legsJson,
                isPinned: isPinned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String origin,
                required String originId,
                required String destination,
                required String destinationId,
                Value<String> tripType = const Value.absent(),
                Value<String?> mode = const Value.absent(),
                Value<String?> lineId = const Value.absent(),
                Value<String?> lineName = const Value.absent(),
                Value<String?> legsJson = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
              }) => JourneysCompanion.insert(
                id: id,
                origin: origin,
                originId: originId,
                destination: destination,
                destinationId: destinationId,
                tripType: tripType,
                mode: mode,
                lineId: lineId,
                lineName: lineName,
                legsJson: legsJson,
                isPinned: isPinned,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JourneysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JourneysTable,
      Journey,
      $$JourneysTableFilterComposer,
      $$JourneysTableOrderingComposer,
      $$JourneysTableAnnotationComposer,
      $$JourneysTableCreateCompanionBuilder,
      $$JourneysTableUpdateCompanionBuilder,
      (Journey, BaseReferences<_$AppDatabase, $JourneysTable, Journey>),
      Journey,
      PrefetchHooks Function()
    >;
typedef $$RoutesTableCreateCompanionBuilder =
    RoutesCompanion Function({
      required String endpoint,
      required String routeId,
      required String lineId,
      Value<String?> routeShortName,
      Value<String?> routeLongName,
      Value<String?> routeDesc,
      Value<String?> routeType,
      Value<String?> routeColor,
      Value<String?> routeTextColor,
      Value<String?> routeSortOrder,
      Value<int> rowid,
    });
typedef $$RoutesTableUpdateCompanionBuilder =
    RoutesCompanion Function({
      Value<String> endpoint,
      Value<String> routeId,
      Value<String> lineId,
      Value<String?> routeShortName,
      Value<String?> routeLongName,
      Value<String?> routeDesc,
      Value<String?> routeType,
      Value<String?> routeColor,
      Value<String?> routeTextColor,
      Value<String?> routeSortOrder,
      Value<int> rowid,
    });

class $$RoutesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeShortName => $composableBuilder(
    column: $table.routeShortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeLongName => $composableBuilder(
    column: $table.routeLongName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeDesc => $composableBuilder(
    column: $table.routeDesc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeType => $composableBuilder(
    column: $table.routeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeColor => $composableBuilder(
    column: $table.routeColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeTextColor => $composableBuilder(
    column: $table.routeTextColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeSortOrder => $composableBuilder(
    column: $table.routeSortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeShortName => $composableBuilder(
    column: $table.routeShortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeLongName => $composableBuilder(
    column: $table.routeLongName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeDesc => $composableBuilder(
    column: $table.routeDesc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeType => $composableBuilder(
    column: $table.routeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeColor => $composableBuilder(
    column: $table.routeColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeTextColor => $composableBuilder(
    column: $table.routeTextColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeSortOrder => $composableBuilder(
    column: $table.routeSortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => column);

  GeneratedColumn<String> get lineId =>
      $composableBuilder(column: $table.lineId, builder: (column) => column);

  GeneratedColumn<String> get routeShortName => $composableBuilder(
    column: $table.routeShortName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeLongName => $composableBuilder(
    column: $table.routeLongName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeDesc =>
      $composableBuilder(column: $table.routeDesc, builder: (column) => column);

  GeneratedColumn<String> get routeType =>
      $composableBuilder(column: $table.routeType, builder: (column) => column);

  GeneratedColumn<String> get routeColor => $composableBuilder(
    column: $table.routeColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeTextColor => $composableBuilder(
    column: $table.routeTextColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeSortOrder => $composableBuilder(
    column: $table.routeSortOrder,
    builder: (column) => column,
  );
}

class $$RoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutesTable,
          Route,
          $$RoutesTableFilterComposer,
          $$RoutesTableOrderingComposer,
          $$RoutesTableAnnotationComposer,
          $$RoutesTableCreateCompanionBuilder,
          $$RoutesTableUpdateCompanionBuilder,
          (Route, BaseReferences<_$AppDatabase, $RoutesTable, Route>),
          Route,
          PrefetchHooks Function()
        > {
  $$RoutesTableTableManager(_$AppDatabase db, $RoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> endpoint = const Value.absent(),
                Value<String> routeId = const Value.absent(),
                Value<String> lineId = const Value.absent(),
                Value<String?> routeShortName = const Value.absent(),
                Value<String?> routeLongName = const Value.absent(),
                Value<String?> routeDesc = const Value.absent(),
                Value<String?> routeType = const Value.absent(),
                Value<String?> routeColor = const Value.absent(),
                Value<String?> routeTextColor = const Value.absent(),
                Value<String?> routeSortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutesCompanion(
                endpoint: endpoint,
                routeId: routeId,
                lineId: lineId,
                routeShortName: routeShortName,
                routeLongName: routeLongName,
                routeDesc: routeDesc,
                routeType: routeType,
                routeColor: routeColor,
                routeTextColor: routeTextColor,
                routeSortOrder: routeSortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String endpoint,
                required String routeId,
                required String lineId,
                Value<String?> routeShortName = const Value.absent(),
                Value<String?> routeLongName = const Value.absent(),
                Value<String?> routeDesc = const Value.absent(),
                Value<String?> routeType = const Value.absent(),
                Value<String?> routeColor = const Value.absent(),
                Value<String?> routeTextColor = const Value.absent(),
                Value<String?> routeSortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutesCompanion.insert(
                endpoint: endpoint,
                routeId: routeId,
                lineId: lineId,
                routeShortName: routeShortName,
                routeLongName: routeLongName,
                routeDesc: routeDesc,
                routeType: routeType,
                routeColor: routeColor,
                routeTextColor: routeTextColor,
                routeSortOrder: routeSortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutesTable,
      Route,
      $$RoutesTableFilterComposer,
      $$RoutesTableOrderingComposer,
      $$RoutesTableAnnotationComposer,
      $$RoutesTableCreateCompanionBuilder,
      $$RoutesTableUpdateCompanionBuilder,
      (Route, BaseReferences<_$AppDatabase, $RoutesTable, Route>),
      Route,
      PrefetchHooks Function()
    >;
typedef $$StopsTableCreateCompanionBuilder =
    StopsCompanion Function({
      required String stopId,
      required String stopName,
      Value<String?> stopCode,
      Value<String?> ttsStopName,
      Value<String?> stopDesc,
      Value<String?> zoneId,
      Value<String?> stopUrl,
      Value<String?> stopTimezone,
      Value<String?> levelId,
      Value<double?> stopLat,
      Value<double?> stopLon,
      Value<int?> locationType,
      Value<String?> parentStation,
      Value<int?> wheelchairBoarding,
      Value<String?> platformCode,
      required String endpoint,
      Value<int> rowid,
    });
typedef $$StopsTableUpdateCompanionBuilder =
    StopsCompanion Function({
      Value<String> stopId,
      Value<String> stopName,
      Value<String?> stopCode,
      Value<String?> ttsStopName,
      Value<String?> stopDesc,
      Value<String?> zoneId,
      Value<String?> stopUrl,
      Value<String?> stopTimezone,
      Value<String?> levelId,
      Value<double?> stopLat,
      Value<double?> stopLon,
      Value<int?> locationType,
      Value<String?> parentStation,
      Value<int?> wheelchairBoarding,
      Value<String?> platformCode,
      Value<String> endpoint,
      Value<int> rowid,
    });

class $$StopsTableFilterComposer extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stopId => $composableBuilder(
    column: $table.stopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopName => $composableBuilder(
    column: $table.stopName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopCode => $composableBuilder(
    column: $table.stopCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttsStopName => $composableBuilder(
    column: $table.ttsStopName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopDesc => $composableBuilder(
    column: $table.stopDesc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopUrl => $composableBuilder(
    column: $table.stopUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopTimezone => $composableBuilder(
    column: $table.stopTimezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stopLat => $composableBuilder(
    column: $table.stopLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stopLon => $composableBuilder(
    column: $table.stopLon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentStation => $composableBuilder(
    column: $table.parentStation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wheelchairBoarding => $composableBuilder(
    column: $table.wheelchairBoarding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformCode => $composableBuilder(
    column: $table.platformCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StopsTableOrderingComposer
    extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stopId => $composableBuilder(
    column: $table.stopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopName => $composableBuilder(
    column: $table.stopName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopCode => $composableBuilder(
    column: $table.stopCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttsStopName => $composableBuilder(
    column: $table.ttsStopName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopDesc => $composableBuilder(
    column: $table.stopDesc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopUrl => $composableBuilder(
    column: $table.stopUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopTimezone => $composableBuilder(
    column: $table.stopTimezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stopLat => $composableBuilder(
    column: $table.stopLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stopLon => $composableBuilder(
    column: $table.stopLon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentStation => $composableBuilder(
    column: $table.parentStation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wheelchairBoarding => $composableBuilder(
    column: $table.wheelchairBoarding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformCode => $composableBuilder(
    column: $table.platformCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stopId =>
      $composableBuilder(column: $table.stopId, builder: (column) => column);

  GeneratedColumn<String> get stopName =>
      $composableBuilder(column: $table.stopName, builder: (column) => column);

  GeneratedColumn<String> get stopCode =>
      $composableBuilder(column: $table.stopCode, builder: (column) => column);

  GeneratedColumn<String> get ttsStopName => $composableBuilder(
    column: $table.ttsStopName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stopDesc =>
      $composableBuilder(column: $table.stopDesc, builder: (column) => column);

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<String> get stopUrl =>
      $composableBuilder(column: $table.stopUrl, builder: (column) => column);

  GeneratedColumn<String> get stopTimezone => $composableBuilder(
    column: $table.stopTimezone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<double> get stopLat =>
      $composableBuilder(column: $table.stopLat, builder: (column) => column);

  GeneratedColumn<double> get stopLon =>
      $composableBuilder(column: $table.stopLon, builder: (column) => column);

  GeneratedColumn<int> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentStation => $composableBuilder(
    column: $table.parentStation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wheelchairBoarding => $composableBuilder(
    column: $table.wheelchairBoarding,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platformCode => $composableBuilder(
    column: $table.platformCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);
}

class $$StopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StopsTable,
          Stop,
          $$StopsTableFilterComposer,
          $$StopsTableOrderingComposer,
          $$StopsTableAnnotationComposer,
          $$StopsTableCreateCompanionBuilder,
          $$StopsTableUpdateCompanionBuilder,
          (Stop, BaseReferences<_$AppDatabase, $StopsTable, Stop>),
          Stop,
          PrefetchHooks Function()
        > {
  $$StopsTableTableManager(_$AppDatabase db, $StopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stopId = const Value.absent(),
                Value<String> stopName = const Value.absent(),
                Value<String?> stopCode = const Value.absent(),
                Value<String?> ttsStopName = const Value.absent(),
                Value<String?> stopDesc = const Value.absent(),
                Value<String?> zoneId = const Value.absent(),
                Value<String?> stopUrl = const Value.absent(),
                Value<String?> stopTimezone = const Value.absent(),
                Value<String?> levelId = const Value.absent(),
                Value<double?> stopLat = const Value.absent(),
                Value<double?> stopLon = const Value.absent(),
                Value<int?> locationType = const Value.absent(),
                Value<String?> parentStation = const Value.absent(),
                Value<int?> wheelchairBoarding = const Value.absent(),
                Value<String?> platformCode = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StopsCompanion(
                stopId: stopId,
                stopName: stopName,
                stopCode: stopCode,
                ttsStopName: ttsStopName,
                stopDesc: stopDesc,
                zoneId: zoneId,
                stopUrl: stopUrl,
                stopTimezone: stopTimezone,
                levelId: levelId,
                stopLat: stopLat,
                stopLon: stopLon,
                locationType: locationType,
                parentStation: parentStation,
                wheelchairBoarding: wheelchairBoarding,
                platformCode: platformCode,
                endpoint: endpoint,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stopId,
                required String stopName,
                Value<String?> stopCode = const Value.absent(),
                Value<String?> ttsStopName = const Value.absent(),
                Value<String?> stopDesc = const Value.absent(),
                Value<String?> zoneId = const Value.absent(),
                Value<String?> stopUrl = const Value.absent(),
                Value<String?> stopTimezone = const Value.absent(),
                Value<String?> levelId = const Value.absent(),
                Value<double?> stopLat = const Value.absent(),
                Value<double?> stopLon = const Value.absent(),
                Value<int?> locationType = const Value.absent(),
                Value<String?> parentStation = const Value.absent(),
                Value<int?> wheelchairBoarding = const Value.absent(),
                Value<String?> platformCode = const Value.absent(),
                required String endpoint,
                Value<int> rowid = const Value.absent(),
              }) => StopsCompanion.insert(
                stopId: stopId,
                stopName: stopName,
                stopCode: stopCode,
                ttsStopName: ttsStopName,
                stopDesc: stopDesc,
                zoneId: zoneId,
                stopUrl: stopUrl,
                stopTimezone: stopTimezone,
                levelId: levelId,
                stopLat: stopLat,
                stopLon: stopLon,
                locationType: locationType,
                parentStation: parentStation,
                wheelchairBoarding: wheelchairBoarding,
                platformCode: platformCode,
                endpoint: endpoint,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StopsTable,
      Stop,
      $$StopsTableFilterComposer,
      $$StopsTableOrderingComposer,
      $$StopsTableAnnotationComposer,
      $$StopsTableCreateCompanionBuilder,
      $$StopsTableUpdateCompanionBuilder,
      (Stop, BaseReferences<_$AppDatabase, $StopsTable, Stop>),
      Stop,
      PrefetchHooks Function()
    >;
typedef $$StopLineMembershipsTableCreateCompanionBuilder =
    StopLineMembershipsCompanion Function({
      required String endpoint,
      required String stopId,
      required String stopName,
      required String lineId,
      required String lineName,
      required String mode,
      required int stopOrder,
      Value<double?> stopLat,
      Value<double?> stopLon,
      Value<int> rowid,
    });
typedef $$StopLineMembershipsTableUpdateCompanionBuilder =
    StopLineMembershipsCompanion Function({
      Value<String> endpoint,
      Value<String> stopId,
      Value<String> stopName,
      Value<String> lineId,
      Value<String> lineName,
      Value<String> mode,
      Value<int> stopOrder,
      Value<double?> stopLat,
      Value<double?> stopLon,
      Value<int> rowid,
    });

class $$StopLineMembershipsTableFilterComposer
    extends Composer<_$AppDatabase, $StopLineMembershipsTable> {
  $$StopLineMembershipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopId => $composableBuilder(
    column: $table.stopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopName => $composableBuilder(
    column: $table.stopName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineName => $composableBuilder(
    column: $table.lineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stopOrder => $composableBuilder(
    column: $table.stopOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stopLat => $composableBuilder(
    column: $table.stopLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stopLon => $composableBuilder(
    column: $table.stopLon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StopLineMembershipsTableOrderingComposer
    extends Composer<_$AppDatabase, $StopLineMembershipsTable> {
  $$StopLineMembershipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopId => $composableBuilder(
    column: $table.stopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopName => $composableBuilder(
    column: $table.stopName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineName => $composableBuilder(
    column: $table.lineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stopOrder => $composableBuilder(
    column: $table.stopOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stopLat => $composableBuilder(
    column: $table.stopLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stopLon => $composableBuilder(
    column: $table.stopLon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StopLineMembershipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StopLineMembershipsTable> {
  $$StopLineMembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get stopId =>
      $composableBuilder(column: $table.stopId, builder: (column) => column);

  GeneratedColumn<String> get stopName =>
      $composableBuilder(column: $table.stopName, builder: (column) => column);

  GeneratedColumn<String> get lineId =>
      $composableBuilder(column: $table.lineId, builder: (column) => column);

  GeneratedColumn<String> get lineName =>
      $composableBuilder(column: $table.lineName, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get stopOrder =>
      $composableBuilder(column: $table.stopOrder, builder: (column) => column);

  GeneratedColumn<double> get stopLat =>
      $composableBuilder(column: $table.stopLat, builder: (column) => column);

  GeneratedColumn<double> get stopLon =>
      $composableBuilder(column: $table.stopLon, builder: (column) => column);
}

class $$StopLineMembershipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StopLineMembershipsTable,
          StopLineMembership,
          $$StopLineMembershipsTableFilterComposer,
          $$StopLineMembershipsTableOrderingComposer,
          $$StopLineMembershipsTableAnnotationComposer,
          $$StopLineMembershipsTableCreateCompanionBuilder,
          $$StopLineMembershipsTableUpdateCompanionBuilder,
          (
            StopLineMembership,
            BaseReferences<
              _$AppDatabase,
              $StopLineMembershipsTable,
              StopLineMembership
            >,
          ),
          StopLineMembership,
          PrefetchHooks Function()
        > {
  $$StopLineMembershipsTableTableManager(
    _$AppDatabase db,
    $StopLineMembershipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StopLineMembershipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StopLineMembershipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StopLineMembershipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> endpoint = const Value.absent(),
                Value<String> stopId = const Value.absent(),
                Value<String> stopName = const Value.absent(),
                Value<String> lineId = const Value.absent(),
                Value<String> lineName = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> stopOrder = const Value.absent(),
                Value<double?> stopLat = const Value.absent(),
                Value<double?> stopLon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StopLineMembershipsCompanion(
                endpoint: endpoint,
                stopId: stopId,
                stopName: stopName,
                lineId: lineId,
                lineName: lineName,
                mode: mode,
                stopOrder: stopOrder,
                stopLat: stopLat,
                stopLon: stopLon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String endpoint,
                required String stopId,
                required String stopName,
                required String lineId,
                required String lineName,
                required String mode,
                required int stopOrder,
                Value<double?> stopLat = const Value.absent(),
                Value<double?> stopLon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StopLineMembershipsCompanion.insert(
                endpoint: endpoint,
                stopId: stopId,
                stopName: stopName,
                lineId: lineId,
                lineName: lineName,
                mode: mode,
                stopOrder: stopOrder,
                stopLat: stopLat,
                stopLon: stopLon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StopLineMembershipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StopLineMembershipsTable,
      StopLineMembership,
      $$StopLineMembershipsTableFilterComposer,
      $$StopLineMembershipsTableOrderingComposer,
      $$StopLineMembershipsTableAnnotationComposer,
      $$StopLineMembershipsTableCreateCompanionBuilder,
      $$StopLineMembershipsTableUpdateCompanionBuilder,
      (
        StopLineMembership,
        BaseReferences<
          _$AppDatabase,
          $StopLineMembershipsTable,
          StopLineMembership
        >,
      ),
      StopLineMembership,
      PrefetchHooks Function()
    >;
typedef $$StaticCacheStatusesTableCreateCompanionBuilder =
    StaticCacheStatusesCompanion Function({
      required String endpoint,
      Value<DateTime?> stopsUpdatedAt,
      Value<DateTime?> lineMembershipsUpdatedAt,
      Value<DateTime?> lastBuildStartedAt,
      Value<DateTime?> lastBuildFinishedAt,
      Value<String?> lastError,
      Value<bool> isBuilding,
      Value<int> rowid,
    });
typedef $$StaticCacheStatusesTableUpdateCompanionBuilder =
    StaticCacheStatusesCompanion Function({
      Value<String> endpoint,
      Value<DateTime?> stopsUpdatedAt,
      Value<DateTime?> lineMembershipsUpdatedAt,
      Value<DateTime?> lastBuildStartedAt,
      Value<DateTime?> lastBuildFinishedAt,
      Value<String?> lastError,
      Value<bool> isBuilding,
      Value<int> rowid,
    });

class $$StaticCacheStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $StaticCacheStatusesTable> {
  $$StaticCacheStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get stopsUpdatedAt => $composableBuilder(
    column: $table.stopsUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lineMembershipsUpdatedAt => $composableBuilder(
    column: $table.lineMembershipsUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBuildStartedAt => $composableBuilder(
    column: $table.lastBuildStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBuildFinishedAt => $composableBuilder(
    column: $table.lastBuildFinishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuilding => $composableBuilder(
    column: $table.isBuilding,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaticCacheStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $StaticCacheStatusesTable> {
  $$StaticCacheStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get stopsUpdatedAt => $composableBuilder(
    column: $table.stopsUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lineMembershipsUpdatedAt => $composableBuilder(
    column: $table.lineMembershipsUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBuildStartedAt => $composableBuilder(
    column: $table.lastBuildStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBuildFinishedAt => $composableBuilder(
    column: $table.lastBuildFinishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuilding => $composableBuilder(
    column: $table.isBuilding,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaticCacheStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaticCacheStatusesTable> {
  $$StaticCacheStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<DateTime> get stopsUpdatedAt => $composableBuilder(
    column: $table.stopsUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lineMembershipsUpdatedAt => $composableBuilder(
    column: $table.lineMembershipsUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastBuildStartedAt => $composableBuilder(
    column: $table.lastBuildStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastBuildFinishedAt => $composableBuilder(
    column: $table.lastBuildFinishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get isBuilding => $composableBuilder(
    column: $table.isBuilding,
    builder: (column) => column,
  );
}

class $$StaticCacheStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaticCacheStatusesTable,
          StaticCacheStatuse,
          $$StaticCacheStatusesTableFilterComposer,
          $$StaticCacheStatusesTableOrderingComposer,
          $$StaticCacheStatusesTableAnnotationComposer,
          $$StaticCacheStatusesTableCreateCompanionBuilder,
          $$StaticCacheStatusesTableUpdateCompanionBuilder,
          (
            StaticCacheStatuse,
            BaseReferences<
              _$AppDatabase,
              $StaticCacheStatusesTable,
              StaticCacheStatuse
            >,
          ),
          StaticCacheStatuse,
          PrefetchHooks Function()
        > {
  $$StaticCacheStatusesTableTableManager(
    _$AppDatabase db,
    $StaticCacheStatusesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaticCacheStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaticCacheStatusesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StaticCacheStatusesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> endpoint = const Value.absent(),
                Value<DateTime?> stopsUpdatedAt = const Value.absent(),
                Value<DateTime?> lineMembershipsUpdatedAt =
                    const Value.absent(),
                Value<DateTime?> lastBuildStartedAt = const Value.absent(),
                Value<DateTime?> lastBuildFinishedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> isBuilding = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaticCacheStatusesCompanion(
                endpoint: endpoint,
                stopsUpdatedAt: stopsUpdatedAt,
                lineMembershipsUpdatedAt: lineMembershipsUpdatedAt,
                lastBuildStartedAt: lastBuildStartedAt,
                lastBuildFinishedAt: lastBuildFinishedAt,
                lastError: lastError,
                isBuilding: isBuilding,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String endpoint,
                Value<DateTime?> stopsUpdatedAt = const Value.absent(),
                Value<DateTime?> lineMembershipsUpdatedAt =
                    const Value.absent(),
                Value<DateTime?> lastBuildStartedAt = const Value.absent(),
                Value<DateTime?> lastBuildFinishedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> isBuilding = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaticCacheStatusesCompanion.insert(
                endpoint: endpoint,
                stopsUpdatedAt: stopsUpdatedAt,
                lineMembershipsUpdatedAt: lineMembershipsUpdatedAt,
                lastBuildStartedAt: lastBuildStartedAt,
                lastBuildFinishedAt: lastBuildFinishedAt,
                lastError: lastError,
                isBuilding: isBuilding,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaticCacheStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaticCacheStatusesTable,
      StaticCacheStatuse,
      $$StaticCacheStatusesTableFilterComposer,
      $$StaticCacheStatusesTableOrderingComposer,
      $$StaticCacheStatusesTableAnnotationComposer,
      $$StaticCacheStatusesTableCreateCompanionBuilder,
      $$StaticCacheStatusesTableUpdateCompanionBuilder,
      (
        StaticCacheStatuse,
        BaseReferences<
          _$AppDatabase,
          $StaticCacheStatusesTable,
          StaticCacheStatuse
        >,
      ),
      StaticCacheStatuse,
      PrefetchHooks Function()
    >;
typedef $$TripPlannerCacheTableCreateCompanionBuilder =
    TripPlannerCacheCompanion Function({
      required String originId,
      required String destinationId,
      required DateTime fetchedAt,
      Value<String?> responseJson,
      Value<String?> error,
      Value<int> rowid,
    });
typedef $$TripPlannerCacheTableUpdateCompanionBuilder =
    TripPlannerCacheCompanion Function({
      Value<String> originId,
      Value<String> destinationId,
      Value<DateTime> fetchedAt,
      Value<String?> responseJson,
      Value<String?> error,
      Value<int> rowid,
    });

class $$TripPlannerCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TripPlannerCacheTable> {
  $$TripPlannerCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get originId => $composableBuilder(
    column: $table.originId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationId => $composableBuilder(
    column: $table.destinationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripPlannerCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TripPlannerCacheTable> {
  $$TripPlannerCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get originId => $composableBuilder(
    column: $table.originId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationId => $composableBuilder(
    column: $table.destinationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripPlannerCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripPlannerCacheTable> {
  $$TripPlannerCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get originId =>
      $composableBuilder(column: $table.originId, builder: (column) => column);

  GeneratedColumn<String> get destinationId => $composableBuilder(
    column: $table.destinationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$TripPlannerCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripPlannerCacheTable,
          TripPlannerCacheData,
          $$TripPlannerCacheTableFilterComposer,
          $$TripPlannerCacheTableOrderingComposer,
          $$TripPlannerCacheTableAnnotationComposer,
          $$TripPlannerCacheTableCreateCompanionBuilder,
          $$TripPlannerCacheTableUpdateCompanionBuilder,
          (
            TripPlannerCacheData,
            BaseReferences<
              _$AppDatabase,
              $TripPlannerCacheTable,
              TripPlannerCacheData
            >,
          ),
          TripPlannerCacheData,
          PrefetchHooks Function()
        > {
  $$TripPlannerCacheTableTableManager(
    _$AppDatabase db,
    $TripPlannerCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripPlannerCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripPlannerCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripPlannerCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> originId = const Value.absent(),
                Value<String> destinationId = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<String?> responseJson = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripPlannerCacheCompanion(
                originId: originId,
                destinationId: destinationId,
                fetchedAt: fetchedAt,
                responseJson: responseJson,
                error: error,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String originId,
                required String destinationId,
                required DateTime fetchedAt,
                Value<String?> responseJson = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripPlannerCacheCompanion.insert(
                originId: originId,
                destinationId: destinationId,
                fetchedAt: fetchedAt,
                responseJson: responseJson,
                error: error,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripPlannerCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripPlannerCacheTable,
      TripPlannerCacheData,
      $$TripPlannerCacheTableFilterComposer,
      $$TripPlannerCacheTableOrderingComposer,
      $$TripPlannerCacheTableAnnotationComposer,
      $$TripPlannerCacheTableCreateCompanionBuilder,
      $$TripPlannerCacheTableUpdateCompanionBuilder,
      (
        TripPlannerCacheData,
        BaseReferences<
          _$AppDatabase,
          $TripPlannerCacheTable,
          TripPlannerCacheData
        >,
      ),
      TripPlannerCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JourneysTableTableManager get journeys =>
      $$JourneysTableTableManager(_db, _db.journeys);
  $$RoutesTableTableManager get routes =>
      $$RoutesTableTableManager(_db, _db.routes);
  $$StopsTableTableManager get stops =>
      $$StopsTableTableManager(_db, _db.stops);
  $$StopLineMembershipsTableTableManager get stopLineMemberships =>
      $$StopLineMembershipsTableTableManager(_db, _db.stopLineMemberships);
  $$StaticCacheStatusesTableTableManager get staticCacheStatuses =>
      $$StaticCacheStatusesTableTableManager(_db, _db.staticCacheStatuses);
  $$TripPlannerCacheTableTableManager get tripPlannerCache =>
      $$TripPlannerCacheTableTableManager(_db, _db.tripPlannerCache);
}
