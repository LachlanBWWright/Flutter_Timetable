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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
      'origin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originIdMeta =
      const VerificationMeta('originId');
  @override
  late final GeneratedColumn<String> originId = GeneratedColumn<String>(
      'origin_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationMeta =
      const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
      'destination', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationIdMeta =
      const VerificationMeta('destinationId');
  @override
  late final GeneratedColumn<String> destinationId = GeneratedColumn<String>(
      'destination_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, origin, originId, destination, destinationId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journeys';
  @override
  VerificationContext validateIntegrity(Insertable<Journey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('origin_id')) {
      context.handle(_originIdMeta,
          originId.isAcceptableOrUnknown(data['origin_id']!, _originIdMeta));
    } else if (isInserting) {
      context.missing(_originIdMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
          _destinationMeta,
          destination.isAcceptableOrUnknown(
              data['destination']!, _destinationMeta));
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('destination_id')) {
      context.handle(
          _destinationIdMeta,
          destinationId.isAcceptableOrUnknown(
              data['destination_id']!, _destinationIdMeta));
    } else if (isInserting) {
      context.missing(_destinationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Journey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Journey(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin'])!,
      originId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin_id'])!,
      destination: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destination'])!,
      destinationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destination_id'])!,
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
  const Journey(
      {required this.id,
      required this.origin,
      required this.originId,
      required this.destination,
      required this.destinationId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['origin'] = Variable<String>(origin);
    map['origin_id'] = Variable<String>(originId);
    map['destination'] = Variable<String>(destination);
    map['destination_id'] = Variable<String>(destinationId);
    return map;
  }

  JourneysCompanion toCompanion(bool nullToAbsent) {
    return JourneysCompanion(
      id: Value(id),
      origin: Value(origin),
      originId: Value(originId),
      destination: Value(destination),
      destinationId: Value(destinationId),
    );
  }

  factory Journey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Journey(
      id: serializer.fromJson<int>(json['id']),
      origin: serializer.fromJson<String>(json['origin']),
      originId: serializer.fromJson<String>(json['originId']),
      destination: serializer.fromJson<String>(json['destination']),
      destinationId: serializer.fromJson<String>(json['destinationId']),
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
    };
  }

  Journey copyWith(
          {int? id,
          String? origin,
          String? originId,
          String? destination,
          String? destinationId}) =>
      Journey(
        id: id ?? this.id,
        origin: origin ?? this.origin,
        originId: originId ?? this.originId,
        destination: destination ?? this.destination,
        destinationId: destinationId ?? this.destinationId,
      );
  Journey copyWithCompanion(JourneysCompanion data) {
    return Journey(
      id: data.id.present ? data.id.value : this.id,
      origin: data.origin.present ? data.origin.value : this.origin,
      originId: data.originId.present ? data.originId.value : this.originId,
      destination:
          data.destination.present ? data.destination.value : this.destination,
      destinationId: data.destinationId.present
          ? data.destinationId.value
          : this.destinationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Journey(')
          ..write('id: $id, ')
          ..write('origin: $origin, ')
          ..write('originId: $originId, ')
          ..write('destination: $destination, ')
          ..write('destinationId: $destinationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, origin, originId, destination, destinationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Journey &&
          other.id == this.id &&
          other.origin == this.origin &&
          other.originId == this.originId &&
          other.destination == this.destination &&
          other.destinationId == this.destinationId);
}

class JourneysCompanion extends UpdateCompanion<Journey> {
  final Value<int> id;
  final Value<String> origin;
  final Value<String> originId;
  final Value<String> destination;
  final Value<String> destinationId;
  const JourneysCompanion({
    this.id = const Value.absent(),
    this.origin = const Value.absent(),
    this.originId = const Value.absent(),
    this.destination = const Value.absent(),
    this.destinationId = const Value.absent(),
  });
  JourneysCompanion.insert({
    this.id = const Value.absent(),
    required String origin,
    required String originId,
    required String destination,
    required String destinationId,
  })  : origin = Value(origin),
        originId = Value(originId),
        destination = Value(destination),
        destinationId = Value(destinationId);
  static Insertable<Journey> custom({
    Expression<int>? id,
    Expression<String>? origin,
    Expression<String>? originId,
    Expression<String>? destination,
    Expression<String>? destinationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origin != null) 'origin': origin,
      if (originId != null) 'origin_id': originId,
      if (destination != null) 'destination': destination,
      if (destinationId != null) 'destination_id': destinationId,
    });
  }

  JourneysCompanion copyWith(
      {Value<int>? id,
      Value<String>? origin,
      Value<String>? originId,
      Value<String>? destination,
      Value<String>? destinationId}) {
    return JourneysCompanion(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      originId: originId ?? this.originId,
      destination: destination ?? this.destination,
      destinationId: destinationId ?? this.destinationId,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JourneysCompanion(')
          ..write('id: $id, ')
          ..write('origin: $origin, ')
          ..write('originId: $originId, ')
          ..write('destination: $destination, ')
          ..write('destinationId: $destinationId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JourneysTable journeys = $JourneysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [journeys];
}

typedef $$JourneysTableCreateCompanionBuilder = JourneysCompanion Function({
  Value<int> id,
  required String origin,
  required String originId,
  required String destination,
  required String destinationId,
});
typedef $$JourneysTableUpdateCompanionBuilder = JourneysCompanion Function({
  Value<int> id,
  Value<String> origin,
  Value<String> originId,
  Value<String> destination,
  Value<String> destinationId,
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originId => $composableBuilder(
      column: $table.originId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationId => $composableBuilder(
      column: $table.destinationId, builder: (column) => ColumnFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originId => $composableBuilder(
      column: $table.originId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationId => $composableBuilder(
      column: $table.destinationId,
      builder: (column) => ColumnOrderings(column));
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
      column: $table.destination, builder: (column) => column);

  GeneratedColumn<String> get destinationId => $composableBuilder(
      column: $table.destinationId, builder: (column) => column);
}

class $$JourneysTableTableManager extends RootTableManager<
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
    PrefetchHooks Function()> {
  $$JourneysTableTableManager(_$AppDatabase db, $JourneysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JourneysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JourneysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JourneysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> origin = const Value.absent(),
            Value<String> originId = const Value.absent(),
            Value<String> destination = const Value.absent(),
            Value<String> destinationId = const Value.absent(),
          }) =>
              JourneysCompanion(
            id: id,
            origin: origin,
            originId: originId,
            destination: destination,
            destinationId: destinationId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String origin,
            required String originId,
            required String destination,
            required String destinationId,
          }) =>
              JourneysCompanion.insert(
            id: id,
            origin: origin,
            originId: originId,
            destination: destination,
            destinationId: destinationId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JourneysTableProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JourneysTableTableManager get journeys =>
      $$JourneysTableTableManager(_db, _db.journeys);
}
