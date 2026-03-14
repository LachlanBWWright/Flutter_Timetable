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
  final bool isPinned;
  const Journey({
    required this.id,
    required this.origin,
    required this.originId,
    required this.destination,
    required this.destinationId,
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
      'isPinned': serializer.toJson<bool>(isPinned),
    };
  }

  Journey copyWith({
    int? id,
    String? origin,
    String? originId,
    String? destination,
    String? destinationId,
    bool? isPinned,
  }) => Journey(
    id: id ?? this.id,
    origin: origin ?? this.origin,
    originId: originId ?? this.originId,
    destination: destination ?? this.destination,
    destinationId: destinationId ?? this.destinationId,
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
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, origin, originId, destination, destinationId, isPinned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Journey &&
          other.id == this.id &&
          other.origin == this.origin &&
          other.originId == this.originId &&
          other.destination == this.destination &&
          other.destinationId == this.destinationId &&
          other.isPinned == this.isPinned);
}

class JourneysCompanion extends UpdateCompanion<Journey> {
  final Value<int> id;
  final Value<String> origin;
  final Value<String> originId;
  final Value<String> destination;
  final Value<String> destinationId;
  final Value<bool> isPinned;
  const JourneysCompanion({
    this.id = const Value.absent(),
    this.origin = const Value.absent(),
    this.originId = const Value.absent(),
    this.destination = const Value.absent(),
    this.destinationId = const Value.absent(),
    this.isPinned = const Value.absent(),
  });
  JourneysCompanion.insert({
    this.id = const Value.absent(),
    required String origin,
    required String originId,
    required String destination,
    required String destinationId,
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
    Expression<bool>? isPinned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origin != null) 'origin': origin,
      if (originId != null) 'origin_id': originId,
      if (destination != null) 'destination': destination,
      if (destinationId != null) 'destination_id': destinationId,
      if (isPinned != null) 'is_pinned': isPinned,
    });
  }

  JourneysCompanion copyWith({
    Value<int>? id,
    Value<String>? origin,
    Value<String>? originId,
    Value<String>? destination,
    Value<String>? destinationId,
    Value<bool>? isPinned,
  }) {
    return JourneysCompanion(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      originId: originId ?? this.originId,
      destination: destination ?? this.destination,
      destinationId: destinationId ?? this.destinationId,
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
          ..write('isPinned: $isPinned')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JourneysTable journeys = $JourneysTable(this);
  late final $StopsTable stops = $StopsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [journeys, stops];
}

typedef $$JourneysTableCreateCompanionBuilder =
    JourneysCompanion Function({
      Value<int> id,
      required String origin,
      required String originId,
      required String destination,
      required String destinationId,
      Value<bool> isPinned,
    });
typedef $$JourneysTableUpdateCompanionBuilder =
    JourneysCompanion Function({
      Value<int> id,
      Value<String> origin,
      Value<String> originId,
      Value<String> destination,
      Value<String> destinationId,
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
                Value<bool> isPinned = const Value.absent(),
              }) => JourneysCompanion(
                id: id,
                origin: origin,
                originId: originId,
                destination: destination,
                destinationId: destinationId,
                isPinned: isPinned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String origin,
                required String originId,
                required String destination,
                required String destinationId,
                Value<bool> isPinned = const Value.absent(),
              }) => JourneysCompanion.insert(
                id: id,
                origin: origin,
                originId: originId,
                destination: destination,
                destinationId: destinationId,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JourneysTableTableManager get journeys =>
      $$JourneysTableTableManager(_db, _db.journeys);
  $$StopsTableTableManager get stops =>
      $$StopsTableTableManager(_db, _db.stops);
}
