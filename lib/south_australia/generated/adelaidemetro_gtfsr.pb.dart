// This is a generated file - do not edit.
//
// Generated from adelaidemetro_gtfsr.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'adelaidemetro_gtfsr.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'adelaidemetro_gtfsr.pbenum.dart';

/// The contents of a feed message.
/// A feed is a continuous stream of feed messages. Each message in the stream is
/// obtained as a response to an appropriate HTTP GET request.
/// A realtime feed is always defined with relation to an existing GTFS feed.
/// All the entity ids are resolved with respect to the GTFS feed.
/// Note that "required" and "optional" as stated in this file refer to Protocol
/// Buffer cardinality, not semantic cardinality.  See reference.md at
/// https://github.com/google/transit/tree/master/gtfs-realtime for field
/// semantic cardinality.
class FeedMessage extends $pb.GeneratedMessage {
  factory FeedMessage({
    FeedHeader? header,
    $core.Iterable<FeedEntity>? entity,
  }) {
    final result = create();
    if (header != null) result.header = header;
    if (entity != null) result.entity.addAll(entity);
    return result;
  }

  FeedMessage._();

  factory FeedMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FeedMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeedMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aQM<FeedHeader>(1, _omitFieldNames ? '' : 'header',
        subBuilder: FeedHeader.create)
    ..pPM<FeedEntity>(2, _omitFieldNames ? '' : 'entity',
        subBuilder: FeedEntity.create)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedMessage copyWith(void Function(FeedMessage) updates) =>
      super.copyWith((message) => updates(message as FeedMessage))
          as FeedMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeedMessage create() => FeedMessage._();
  @$core.override
  FeedMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FeedMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FeedMessage>(create);
  static FeedMessage? _defaultInstance;

  /// Metadata about this feed and feed message.
  @$pb.TagNumber(1)
  FeedHeader get header => $_getN(0);
  @$pb.TagNumber(1)
  set header(FeedHeader value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeader() => $_clearField(1);
  @$pb.TagNumber(1)
  FeedHeader ensureHeader() => $_ensure(0);

  /// Contents of the feed.
  @$pb.TagNumber(2)
  $pb.PbList<FeedEntity> get entity => $_getList(1);
}

/// Metadata about a feed, included in feed messages.
class FeedHeader extends $pb.GeneratedMessage {
  factory FeedHeader({
    $core.String? gtfsRealtimeVersion,
    FeedHeader_Incrementality? incrementality,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (gtfsRealtimeVersion != null)
      result.gtfsRealtimeVersion = gtfsRealtimeVersion;
    if (incrementality != null) result.incrementality = incrementality;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  FeedHeader._();

  factory FeedHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FeedHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeedHeader',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aQS(1, _omitFieldNames ? '' : 'gtfsRealtimeVersion')
    ..aE<FeedHeader_Incrementality>(2, _omitFieldNames ? '' : 'incrementality',
        defaultOrMaker: FeedHeader_Incrementality.FULL_DATASET,
        enumValues: FeedHeader_Incrementality.values)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedHeader copyWith(void Function(FeedHeader) updates) =>
      super.copyWith((message) => updates(message as FeedHeader)) as FeedHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeedHeader create() => FeedHeader._();
  @$core.override
  FeedHeader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FeedHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FeedHeader>(create);
  static FeedHeader? _defaultInstance;

  /// Version of the feed specification.
  /// The current version is 2.0.
  @$pb.TagNumber(1)
  $core.String get gtfsRealtimeVersion => $_getSZ(0);
  @$pb.TagNumber(1)
  set gtfsRealtimeVersion($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGtfsRealtimeVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearGtfsRealtimeVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  FeedHeader_Incrementality get incrementality => $_getN(1);
  @$pb.TagNumber(2)
  set incrementality(FeedHeader_Incrementality value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasIncrementality() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncrementality() => $_clearField(2);

  /// This timestamp identifies the moment when the content of this feed has been
  /// created (in server time). In POSIX time (i.e., number of seconds since
  /// January 1st 1970 00:00:00 UTC).
  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
}

/// A definition (or update) of an entity in the transit feed.
class FeedEntity extends $pb.GeneratedMessage {
  factory FeedEntity({
    $core.String? id,
    $core.bool? isDeleted,
    TripUpdate? tripUpdate,
    VehiclePosition? vehicle,
    Alert? alert,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (isDeleted != null) result.isDeleted = isDeleted;
    if (tripUpdate != null) result.tripUpdate = tripUpdate;
    if (vehicle != null) result.vehicle = vehicle;
    if (alert != null) result.alert = alert;
    return result;
  }

  FeedEntity._();

  factory FeedEntity.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FeedEntity.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeedEntity',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aQS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'isDeleted')
    ..aOM<TripUpdate>(3, _omitFieldNames ? '' : 'tripUpdate',
        subBuilder: TripUpdate.create)
    ..aOM<VehiclePosition>(4, _omitFieldNames ? '' : 'vehicle',
        subBuilder: VehiclePosition.create)
    ..aOM<Alert>(5, _omitFieldNames ? '' : 'alert', subBuilder: Alert.create)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedEntity clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedEntity copyWith(void Function(FeedEntity) updates) =>
      super.copyWith((message) => updates(message as FeedEntity)) as FeedEntity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeedEntity create() => FeedEntity._();
  @$core.override
  FeedEntity createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FeedEntity getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FeedEntity>(create);
  static FeedEntity? _defaultInstance;

  /// The ids are used only to provide incrementality support. The id should be
  /// unique within a FeedMessage. Consequent FeedMessages may contain
  /// FeedEntities with the same id. In case of a DIFFERENTIAL update the new
  /// FeedEntity with some id will replace the old FeedEntity with the same id
  /// (or delete it - see is_deleted below).
  /// The actual GTFS entities (e.g. stations, routes, trips) referenced by the
  /// feed must be specified by explicit selectors (see EntitySelector below for
  /// more info).
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Whether this entity is to be deleted. Relevant only for incremental
  /// fetches.
  @$pb.TagNumber(2)
  $core.bool get isDeleted => $_getBF(1);
  @$pb.TagNumber(2)
  set isDeleted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsDeleted() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsDeleted() => $_clearField(2);

  /// Data about the entity itself. Exactly one of the following fields must be
  /// present (unless the entity is being deleted).
  @$pb.TagNumber(3)
  TripUpdate get tripUpdate => $_getN(2);
  @$pb.TagNumber(3)
  set tripUpdate(TripUpdate value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTripUpdate() => $_has(2);
  @$pb.TagNumber(3)
  void clearTripUpdate() => $_clearField(3);
  @$pb.TagNumber(3)
  TripUpdate ensureTripUpdate() => $_ensure(2);

  @$pb.TagNumber(4)
  VehiclePosition get vehicle => $_getN(3);
  @$pb.TagNumber(4)
  set vehicle(VehiclePosition value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasVehicle() => $_has(3);
  @$pb.TagNumber(4)
  void clearVehicle() => $_clearField(4);
  @$pb.TagNumber(4)
  VehiclePosition ensureVehicle() => $_ensure(3);

  @$pb.TagNumber(5)
  Alert get alert => $_getN(4);
  @$pb.TagNumber(5)
  set alert(Alert value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAlert() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlert() => $_clearField(5);
  @$pb.TagNumber(5)
  Alert ensureAlert() => $_ensure(4);
}

/// Timing information for a single predicted event (either arrival or
/// departure).
/// Timing consists of delay and/or estimated time, and uncertainty.
/// - delay should be used when the prediction is given relative to some
///   existing schedule in GTFS.
/// - time should be given whether there is a predicted schedule or not. If
///   both time and delay are specified, time will take precedence
///   (although normally, time, if given for a scheduled trip, should be
///   equal to scheduled time in GTFS + delay).
///
/// Uncertainty applies equally to both time and delay.
/// The uncertainty roughly specifies the expected error in true delay (but
/// note, we don't yet define its precise statistical meaning). It's possible
/// for the uncertainty to be 0, for example for trains that are driven under
/// computer timing control.
class TripUpdate_StopTimeEvent extends $pb.GeneratedMessage {
  factory TripUpdate_StopTimeEvent({
    $core.int? delay,
    $fixnum.Int64? time,
    $core.int? uncertainty,
  }) {
    final result = create();
    if (delay != null) result.delay = delay;
    if (time != null) result.time = time;
    if (uncertainty != null) result.uncertainty = uncertainty;
    return result;
  }

  TripUpdate_StopTimeEvent._();

  factory TripUpdate_StopTimeEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TripUpdate_StopTimeEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TripUpdate.StopTimeEvent',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'delay')
    ..aInt64(2, _omitFieldNames ? '' : 'time')
    ..aI(3, _omitFieldNames ? '' : 'uncertainty')
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripUpdate_StopTimeEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripUpdate_StopTimeEvent copyWith(
          void Function(TripUpdate_StopTimeEvent) updates) =>
      super.copyWith((message) => updates(message as TripUpdate_StopTimeEvent))
          as TripUpdate_StopTimeEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TripUpdate_StopTimeEvent create() => TripUpdate_StopTimeEvent._();
  @$core.override
  TripUpdate_StopTimeEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TripUpdate_StopTimeEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TripUpdate_StopTimeEvent>(create);
  static TripUpdate_StopTimeEvent? _defaultInstance;

  /// Delay (in seconds) can be positive (meaning that the vehicle is late) or
  /// negative (meaning that the vehicle is ahead of schedule). Delay of 0
  /// means that the vehicle is exactly on time.
  @$pb.TagNumber(1)
  $core.int get delay => $_getIZ(0);
  @$pb.TagNumber(1)
  set delay($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDelay() => $_has(0);
  @$pb.TagNumber(1)
  void clearDelay() => $_clearField(1);

  /// Event as absolute time.
  /// In Unix time (i.e., number of seconds since January 1st 1970 00:00:00
  /// UTC).
  @$pb.TagNumber(2)
  $fixnum.Int64 get time => $_getI64(1);
  @$pb.TagNumber(2)
  set time($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => $_clearField(2);

  /// If uncertainty is omitted, it is interpreted as unknown.
  /// If the prediction is unknown or too uncertain, the delay (or time) field
  /// should be empty. In such case, the uncertainty field is ignored.
  /// To specify a completely certain prediction, set its uncertainty to 0.
  @$pb.TagNumber(3)
  $core.int get uncertainty => $_getIZ(2);
  @$pb.TagNumber(3)
  set uncertainty($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUncertainty() => $_has(2);
  @$pb.TagNumber(3)
  void clearUncertainty() => $_clearField(3);
}

/// Realtime update for arrival and/or departure events for a given stop on a
/// trip. Updates can be supplied for both past and future events.
/// The producer is allowed, although not required, to drop past events.
class TripUpdate_StopTimeUpdate extends $pb.GeneratedMessage {
  factory TripUpdate_StopTimeUpdate({
    $core.int? stopSequence,
    TripUpdate_StopTimeEvent? arrival,
    TripUpdate_StopTimeEvent? departure,
    $core.String? stopId,
    TripUpdate_StopTimeUpdate_ScheduleRelationship? scheduleRelationship,
  }) {
    final result = create();
    if (stopSequence != null) result.stopSequence = stopSequence;
    if (arrival != null) result.arrival = arrival;
    if (departure != null) result.departure = departure;
    if (stopId != null) result.stopId = stopId;
    if (scheduleRelationship != null)
      result.scheduleRelationship = scheduleRelationship;
    return result;
  }

  TripUpdate_StopTimeUpdate._();

  factory TripUpdate_StopTimeUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TripUpdate_StopTimeUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TripUpdate.StopTimeUpdate',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'stopSequence',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<TripUpdate_StopTimeEvent>(2, _omitFieldNames ? '' : 'arrival',
        subBuilder: TripUpdate_StopTimeEvent.create)
    ..aOM<TripUpdate_StopTimeEvent>(3, _omitFieldNames ? '' : 'departure',
        subBuilder: TripUpdate_StopTimeEvent.create)
    ..aOS(4, _omitFieldNames ? '' : 'stopId')
    ..aE<TripUpdate_StopTimeUpdate_ScheduleRelationship>(
        5, _omitFieldNames ? '' : 'scheduleRelationship',
        defaultOrMaker:
            TripUpdate_StopTimeUpdate_ScheduleRelationship.SCHEDULED,
        enumValues: TripUpdate_StopTimeUpdate_ScheduleRelationship.values)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripUpdate_StopTimeUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripUpdate_StopTimeUpdate copyWith(
          void Function(TripUpdate_StopTimeUpdate) updates) =>
      super.copyWith((message) => updates(message as TripUpdate_StopTimeUpdate))
          as TripUpdate_StopTimeUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TripUpdate_StopTimeUpdate create() => TripUpdate_StopTimeUpdate._();
  @$core.override
  TripUpdate_StopTimeUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TripUpdate_StopTimeUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TripUpdate_StopTimeUpdate>(create);
  static TripUpdate_StopTimeUpdate? _defaultInstance;

  /// Must be the same as in stop_times.txt in the corresponding GTFS feed.
  @$pb.TagNumber(1)
  $core.int get stopSequence => $_getIZ(0);
  @$pb.TagNumber(1)
  set stopSequence($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStopSequence() => $_has(0);
  @$pb.TagNumber(1)
  void clearStopSequence() => $_clearField(1);

  @$pb.TagNumber(2)
  TripUpdate_StopTimeEvent get arrival => $_getN(1);
  @$pb.TagNumber(2)
  set arrival(TripUpdate_StopTimeEvent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasArrival() => $_has(1);
  @$pb.TagNumber(2)
  void clearArrival() => $_clearField(2);
  @$pb.TagNumber(2)
  TripUpdate_StopTimeEvent ensureArrival() => $_ensure(1);

  @$pb.TagNumber(3)
  TripUpdate_StopTimeEvent get departure => $_getN(2);
  @$pb.TagNumber(3)
  set departure(TripUpdate_StopTimeEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeparture() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeparture() => $_clearField(3);
  @$pb.TagNumber(3)
  TripUpdate_StopTimeEvent ensureDeparture() => $_ensure(2);

  /// Must be the same as in stops.txt in the corresponding GTFS feed.
  @$pb.TagNumber(4)
  $core.String get stopId => $_getSZ(3);
  @$pb.TagNumber(4)
  set stopId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStopId() => $_has(3);
  @$pb.TagNumber(4)
  void clearStopId() => $_clearField(4);

  @$pb.TagNumber(5)
  TripUpdate_StopTimeUpdate_ScheduleRelationship get scheduleRelationship =>
      $_getN(4);
  @$pb.TagNumber(5)
  set scheduleRelationship(
          TripUpdate_StopTimeUpdate_ScheduleRelationship value) =>
      $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasScheduleRelationship() => $_has(4);
  @$pb.TagNumber(5)
  void clearScheduleRelationship() => $_clearField(5);
}

/// Realtime update of the progress of a vehicle along a trip.
/// Depending on the value of ScheduleRelationship, a TripUpdate can specify:
/// - A trip that proceeds along the schedule.
/// - A trip that proceeds along a route but has no fixed schedule.
/// - A trip that have been added or removed with regard to schedule.
///
/// The updates can be for future, predicted arrival/departure events, or for
/// past events that already occurred.
/// Normally, updates should get more precise and more certain (see
/// uncertainty below) as the events gets closer to current time.
/// Even if that is not possible, the information for past events should be
/// precise and certain. In particular, if an update points to time in the past
/// but its update's uncertainty is not 0, the client should conclude that the
/// update is a (wrong) prediction and that the trip has not completed yet.
///
/// Note that the update can describe a trip that is already completed.
/// To this end, it is enough to provide an update for the last stop of the trip.
/// If the time of that is in the past, the client will conclude from that that
/// the whole trip is in the past (it is possible, although inconsequential, to
/// also provide updates for preceding stops).
/// This option is most relevant for a trip that has completed ahead of schedule,
/// but according to the schedule, the trip is still proceeding at the current
/// time. Removing the updates for this trip could make the client assume
/// that the trip is still proceeding.
/// Note that the feed provider is allowed, but not required, to purge past
/// updates - this is one case where this would be practically useful.
class TripUpdate extends $pb.GeneratedMessage {
  factory TripUpdate({
    TripDescriptor? trip,
    $core.Iterable<TripUpdate_StopTimeUpdate>? stopTimeUpdate,
    VehicleDescriptor? vehicle,
    $fixnum.Int64? timestamp,
    $core.int? delay,
  }) {
    final result = create();
    if (trip != null) result.trip = trip;
    if (stopTimeUpdate != null) result.stopTimeUpdate.addAll(stopTimeUpdate);
    if (vehicle != null) result.vehicle = vehicle;
    if (timestamp != null) result.timestamp = timestamp;
    if (delay != null) result.delay = delay;
    return result;
  }

  TripUpdate._();

  factory TripUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TripUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TripUpdate',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aQM<TripDescriptor>(1, _omitFieldNames ? '' : 'trip',
        subBuilder: TripDescriptor.create)
    ..pPM<TripUpdate_StopTimeUpdate>(2, _omitFieldNames ? '' : 'stopTimeUpdate',
        subBuilder: TripUpdate_StopTimeUpdate.create)
    ..aOM<VehicleDescriptor>(3, _omitFieldNames ? '' : 'vehicle',
        subBuilder: VehicleDescriptor.create)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(5, _omitFieldNames ? '' : 'delay')
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripUpdate copyWith(void Function(TripUpdate) updates) =>
      super.copyWith((message) => updates(message as TripUpdate)) as TripUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TripUpdate create() => TripUpdate._();
  @$core.override
  TripUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TripUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TripUpdate>(create);
  static TripUpdate? _defaultInstance;

  /// The Trip that this message applies to. There can be at most one
  /// TripUpdate entity for each actual trip instance.
  /// If there is none, that means there is no prediction information available.
  /// It does *not* mean that the trip is progressing according to schedule.
  @$pb.TagNumber(1)
  TripDescriptor get trip => $_getN(0);
  @$pb.TagNumber(1)
  set trip(TripDescriptor value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTrip() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrip() => $_clearField(1);
  @$pb.TagNumber(1)
  TripDescriptor ensureTrip() => $_ensure(0);

  /// Updates to StopTimes for the trip (both future, i.e., predictions, and in
  /// some cases, past ones, i.e., those that already happened).
  /// The updates must be sorted by stop_sequence, and apply for all the
  /// following stops of the trip up to the next specified one.
  ///
  /// Example 1:
  /// For a trip with 20 stops, a StopTimeUpdate with arrival delay and departure
  /// delay of 0 for stop_sequence of the current stop means that the trip is
  /// exactly on time.
  ///
  /// Example 2:
  /// For the same trip instance, 3 StopTimeUpdates are provided:
  /// - delay of 5 min for stop_sequence 3
  /// - delay of 1 min for stop_sequence 8
  /// - delay of unspecified duration for stop_sequence 10
  /// This will be interpreted as:
  /// - stop_sequences 3,4,5,6,7 have delay of 5 min.
  /// - stop_sequences 8,9 have delay of 1 min.
  /// - stop_sequences 10,... have unknown delay.
  @$pb.TagNumber(2)
  $pb.PbList<TripUpdate_StopTimeUpdate> get stopTimeUpdate => $_getList(1);

  /// Additional information on the vehicle that is serving this trip.
  @$pb.TagNumber(3)
  VehicleDescriptor get vehicle => $_getN(2);
  @$pb.TagNumber(3)
  set vehicle(VehicleDescriptor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasVehicle() => $_has(2);
  @$pb.TagNumber(3)
  void clearVehicle() => $_clearField(3);
  @$pb.TagNumber(3)
  VehicleDescriptor ensureVehicle() => $_ensure(2);

  /// Moment at which the vehicle's real-time progress was measured. In POSIX
  /// time (i.e., the number of seconds since January 1st 1970 00:00:00 UTC).
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);

  /// The current schedule deviation for the trip.  Delay should only be
  /// specified when the prediction is given relative to some existing schedule
  /// in GTFS.
  ///
  /// Delay (in seconds) can be positive (meaning that the vehicle is late) or
  /// negative (meaning that the vehicle is ahead of schedule). Delay of 0
  /// means that the vehicle is exactly on time.
  ///
  /// Delay information in StopTimeUpdates take precedent of trip-level delay
  /// information, such that trip-level delay is only propagated until the next
  /// stop along the trip with a StopTimeUpdate delay value specified.
  ///
  /// Feed providers are strongly encouraged to provide a TripUpdate.timestamp
  /// value indicating when the delay value was last updated, in order to
  /// evaluate the freshness of the data.
  ///
  /// NOTE: This field is still experimental, and subject to change. It may be
  /// formally adopted in the future.
  @$pb.TagNumber(5)
  $core.int get delay => $_getIZ(4);
  @$pb.TagNumber(5)
  set delay($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDelay() => $_has(4);
  @$pb.TagNumber(5)
  void clearDelay() => $_clearField(5);
}

/// Realtime positioning information for a given vehicle.
class VehiclePosition extends $pb.GeneratedMessage {
  factory VehiclePosition({
    TripDescriptor? trip,
    Position? position,
    $core.int? currentStopSequence,
    VehiclePosition_VehicleStopStatus? currentStatus,
    $fixnum.Int64? timestamp,
    VehiclePosition_CongestionLevel? congestionLevel,
    $core.String? stopId,
    VehicleDescriptor? vehicle,
    VehiclePosition_OccupancyStatus? occupancyStatus,
  }) {
    final result = create();
    if (trip != null) result.trip = trip;
    if (position != null) result.position = position;
    if (currentStopSequence != null)
      result.currentStopSequence = currentStopSequence;
    if (currentStatus != null) result.currentStatus = currentStatus;
    if (timestamp != null) result.timestamp = timestamp;
    if (congestionLevel != null) result.congestionLevel = congestionLevel;
    if (stopId != null) result.stopId = stopId;
    if (vehicle != null) result.vehicle = vehicle;
    if (occupancyStatus != null) result.occupancyStatus = occupancyStatus;
    return result;
  }

  VehiclePosition._();

  factory VehiclePosition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VehiclePosition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VehiclePosition',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aOM<TripDescriptor>(1, _omitFieldNames ? '' : 'trip',
        subBuilder: TripDescriptor.create)
    ..aOM<Position>(2, _omitFieldNames ? '' : 'position',
        subBuilder: Position.create)
    ..aI(3, _omitFieldNames ? '' : 'currentStopSequence',
        fieldType: $pb.PbFieldType.OU3)
    ..aE<VehiclePosition_VehicleStopStatus>(
        4, _omitFieldNames ? '' : 'currentStatus',
        defaultOrMaker: VehiclePosition_VehicleStopStatus.IN_TRANSIT_TO,
        enumValues: VehiclePosition_VehicleStopStatus.values)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aE<VehiclePosition_CongestionLevel>(
        6, _omitFieldNames ? '' : 'congestionLevel',
        enumValues: VehiclePosition_CongestionLevel.values)
    ..aOS(7, _omitFieldNames ? '' : 'stopId')
    ..aOM<VehicleDescriptor>(8, _omitFieldNames ? '' : 'vehicle',
        subBuilder: VehicleDescriptor.create)
    ..aE<VehiclePosition_OccupancyStatus>(
        9, _omitFieldNames ? '' : 'occupancyStatus',
        enumValues: VehiclePosition_OccupancyStatus.values)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VehiclePosition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VehiclePosition copyWith(void Function(VehiclePosition) updates) =>
      super.copyWith((message) => updates(message as VehiclePosition))
          as VehiclePosition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VehiclePosition create() => VehiclePosition._();
  @$core.override
  VehiclePosition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VehiclePosition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VehiclePosition>(create);
  static VehiclePosition? _defaultInstance;

  /// The Trip that this vehicle is serving.
  /// Can be empty or partial if the vehicle can not be identified with a given
  /// trip instance.
  @$pb.TagNumber(1)
  TripDescriptor get trip => $_getN(0);
  @$pb.TagNumber(1)
  set trip(TripDescriptor value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTrip() => $_has(0);
  @$pb.TagNumber(1)
  void clearTrip() => $_clearField(1);
  @$pb.TagNumber(1)
  TripDescriptor ensureTrip() => $_ensure(0);

  /// Current position of this vehicle.
  @$pb.TagNumber(2)
  Position get position => $_getN(1);
  @$pb.TagNumber(2)
  set position(Position value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosition() => $_clearField(2);
  @$pb.TagNumber(2)
  Position ensurePosition() => $_ensure(1);

  /// The stop sequence index of the current stop. The meaning of
  /// current_stop_sequence (i.e., the stop that it refers to) is determined by
  /// current_status.
  /// If current_status is missing IN_TRANSIT_TO is assumed.
  @$pb.TagNumber(3)
  $core.int get currentStopSequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set currentStopSequence($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrentStopSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentStopSequence() => $_clearField(3);

  /// The exact status of the vehicle with respect to the current stop.
  /// Ignored if current_stop_sequence is missing.
  @$pb.TagNumber(4)
  VehiclePosition_VehicleStopStatus get currentStatus => $_getN(3);
  @$pb.TagNumber(4)
  set currentStatus(VehiclePosition_VehicleStopStatus value) =>
      $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrentStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrentStatus() => $_clearField(4);

  /// Moment at which the vehicle's position was measured. In POSIX time
  /// (i.e., number of seconds since January 1st 1970 00:00:00 UTC).
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);

  @$pb.TagNumber(6)
  VehiclePosition_CongestionLevel get congestionLevel => $_getN(5);
  @$pb.TagNumber(6)
  set congestionLevel(VehiclePosition_CongestionLevel value) =>
      $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCongestionLevel() => $_has(5);
  @$pb.TagNumber(6)
  void clearCongestionLevel() => $_clearField(6);

  /// Identifies the current stop. The value must be the same as in stops.txt in
  /// the corresponding GTFS feed.
  @$pb.TagNumber(7)
  $core.String get stopId => $_getSZ(6);
  @$pb.TagNumber(7)
  set stopId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStopId() => $_has(6);
  @$pb.TagNumber(7)
  void clearStopId() => $_clearField(7);

  /// Additional information on the vehicle that is serving this trip.
  @$pb.TagNumber(8)
  VehicleDescriptor get vehicle => $_getN(7);
  @$pb.TagNumber(8)
  set vehicle(VehicleDescriptor value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasVehicle() => $_has(7);
  @$pb.TagNumber(8)
  void clearVehicle() => $_clearField(8);
  @$pb.TagNumber(8)
  VehicleDescriptor ensureVehicle() => $_ensure(7);

  @$pb.TagNumber(9)
  VehiclePosition_OccupancyStatus get occupancyStatus => $_getN(8);
  @$pb.TagNumber(9)
  set occupancyStatus(VehiclePosition_OccupancyStatus value) =>
      $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasOccupancyStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearOccupancyStatus() => $_clearField(9);
}

/// An alert, indicating some sort of incident in the public transit network.
class Alert extends $pb.GeneratedMessage {
  factory Alert({
    $core.Iterable<TimeRange>? activePeriod,
    $core.Iterable<EntitySelector>? informedEntity,
    Alert_Cause? cause,
    Alert_Effect? effect,
    TranslatedString? url,
    TranslatedString? headerText,
    TranslatedString? descriptionText,
  }) {
    final result = create();
    if (activePeriod != null) result.activePeriod.addAll(activePeriod);
    if (informedEntity != null) result.informedEntity.addAll(informedEntity);
    if (cause != null) result.cause = cause;
    if (effect != null) result.effect = effect;
    if (url != null) result.url = url;
    if (headerText != null) result.headerText = headerText;
    if (descriptionText != null) result.descriptionText = descriptionText;
    return result;
  }

  Alert._();

  factory Alert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Alert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Alert',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..pPM<TimeRange>(1, _omitFieldNames ? '' : 'activePeriod',
        subBuilder: TimeRange.create)
    ..pPM<EntitySelector>(5, _omitFieldNames ? '' : 'informedEntity',
        subBuilder: EntitySelector.create)
    ..aE<Alert_Cause>(6, _omitFieldNames ? '' : 'cause',
        defaultOrMaker: Alert_Cause.UNKNOWN_CAUSE,
        enumValues: Alert_Cause.values)
    ..aE<Alert_Effect>(7, _omitFieldNames ? '' : 'effect',
        defaultOrMaker: Alert_Effect.UNKNOWN_EFFECT,
        enumValues: Alert_Effect.values)
    ..aOM<TranslatedString>(8, _omitFieldNames ? '' : 'url',
        subBuilder: TranslatedString.create)
    ..aOM<TranslatedString>(10, _omitFieldNames ? '' : 'headerText',
        subBuilder: TranslatedString.create)
    ..aOM<TranslatedString>(11, _omitFieldNames ? '' : 'descriptionText',
        subBuilder: TranslatedString.create)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Alert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Alert copyWith(void Function(Alert) updates) =>
      super.copyWith((message) => updates(message as Alert)) as Alert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Alert create() => Alert._();
  @$core.override
  Alert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Alert getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Alert>(create);
  static Alert? _defaultInstance;

  /// Time when the alert should be shown to the user. If missing, the
  /// alert will be shown as long as it appears in the feed.
  /// If multiple ranges are given, the alert will be shown during all of them.
  @$pb.TagNumber(1)
  $pb.PbList<TimeRange> get activePeriod => $_getList(0);

  /// Entities whose users we should notify of this alert.
  @$pb.TagNumber(5)
  $pb.PbList<EntitySelector> get informedEntity => $_getList(1);

  @$pb.TagNumber(6)
  Alert_Cause get cause => $_getN(2);
  @$pb.TagNumber(6)
  set cause(Alert_Cause value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCause() => $_has(2);
  @$pb.TagNumber(6)
  void clearCause() => $_clearField(6);

  @$pb.TagNumber(7)
  Alert_Effect get effect => $_getN(3);
  @$pb.TagNumber(7)
  set effect(Alert_Effect value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasEffect() => $_has(3);
  @$pb.TagNumber(7)
  void clearEffect() => $_clearField(7);

  /// The URL which provides additional information about the alert.
  @$pb.TagNumber(8)
  TranslatedString get url => $_getN(4);
  @$pb.TagNumber(8)
  set url(TranslatedString value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasUrl() => $_has(4);
  @$pb.TagNumber(8)
  void clearUrl() => $_clearField(8);
  @$pb.TagNumber(8)
  TranslatedString ensureUrl() => $_ensure(4);

  /// Alert header. Contains a short summary of the alert text as plain-text.
  @$pb.TagNumber(10)
  TranslatedString get headerText => $_getN(5);
  @$pb.TagNumber(10)
  set headerText(TranslatedString value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasHeaderText() => $_has(5);
  @$pb.TagNumber(10)
  void clearHeaderText() => $_clearField(10);
  @$pb.TagNumber(10)
  TranslatedString ensureHeaderText() => $_ensure(5);

  /// Full description for the alert as plain-text. The information in the
  /// description should add to the information of the header.
  @$pb.TagNumber(11)
  TranslatedString get descriptionText => $_getN(6);
  @$pb.TagNumber(11)
  set descriptionText(TranslatedString value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasDescriptionText() => $_has(6);
  @$pb.TagNumber(11)
  void clearDescriptionText() => $_clearField(11);
  @$pb.TagNumber(11)
  TranslatedString ensureDescriptionText() => $_ensure(6);
}

/// A time interval. The interval is considered active at time 't' if 't' is
/// greater than or equal to the start time and less than the end time.
class TimeRange extends $pb.GeneratedMessage {
  factory TimeRange({
    $fixnum.Int64? start,
    $fixnum.Int64? end,
  }) {
    final result = create();
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    return result;
  }

  TimeRange._();

  factory TimeRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TimeRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeRange',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'start', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'end', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeRange copyWith(void Function(TimeRange) updates) =>
      super.copyWith((message) => updates(message as TimeRange)) as TimeRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimeRange create() => TimeRange._();
  @$core.override
  TimeRange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TimeRange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimeRange>(create);
  static TimeRange? _defaultInstance;

  /// Start time, in POSIX time (i.e., number of seconds since January 1st 1970
  /// 00:00:00 UTC).
  /// If missing, the interval starts at minus infinity.
  @$pb.TagNumber(1)
  $fixnum.Int64 get start => $_getI64(0);
  @$pb.TagNumber(1)
  set start($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearStart() => $_clearField(1);

  /// End time, in POSIX time (i.e., number of seconds since January 1st 1970
  /// 00:00:00 UTC).
  /// If missing, the interval ends at plus infinity.
  @$pb.TagNumber(2)
  $fixnum.Int64 get end => $_getI64(1);
  @$pb.TagNumber(2)
  set end($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);
}

/// A position.
class Position extends $pb.GeneratedMessage {
  factory Position({
    $core.double? latitude,
    $core.double? longitude,
    $core.double? bearing,
    $core.double? odometer,
    $core.double? speed,
  }) {
    final result = create();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (bearing != null) result.bearing = bearing;
    if (odometer != null) result.odometer = odometer;
    if (speed != null) result.speed = speed;
    return result;
  }

  Position._();

  factory Position.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Position.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Position',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'latitude', fieldType: $pb.PbFieldType.QF)
    ..aD(2, _omitFieldNames ? '' : 'longitude', fieldType: $pb.PbFieldType.QF)
    ..aD(3, _omitFieldNames ? '' : 'bearing', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'odometer')
    ..aD(5, _omitFieldNames ? '' : 'speed', fieldType: $pb.PbFieldType.OF)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Position clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Position copyWith(void Function(Position) updates) =>
      super.copyWith((message) => updates(message as Position)) as Position;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Position create() => Position._();
  @$core.override
  Position createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Position getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Position>(create);
  static Position? _defaultInstance;

  /// Degrees North, in the WGS-84 coordinate system.
  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  /// Degrees East, in the WGS-84 coordinate system.
  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  /// Bearing, in degrees, clockwise from North, i.e., 0 is North and 90 is East.
  /// This can be the compass bearing, or the direction towards the next stop
  /// or intermediate location.
  /// This should not be direction deduced from the sequence of previous
  /// positions, which can be computed from previous data.
  @$pb.TagNumber(3)
  $core.double get bearing => $_getN(2);
  @$pb.TagNumber(3)
  set bearing($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBearing() => $_has(2);
  @$pb.TagNumber(3)
  void clearBearing() => $_clearField(3);

  /// Odometer value, in meters.
  @$pb.TagNumber(4)
  $core.double get odometer => $_getN(3);
  @$pb.TagNumber(4)
  set odometer($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOdometer() => $_has(3);
  @$pb.TagNumber(4)
  void clearOdometer() => $_clearField(4);

  /// Momentary speed measured by the vehicle, in meters per second.
  @$pb.TagNumber(5)
  $core.double get speed => $_getN(4);
  @$pb.TagNumber(5)
  set speed($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpeed() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpeed() => $_clearField(5);
}

/// A descriptor that identifies an instance of a GTFS trip, or all instances of
/// a trip along a route.
/// - To specify a single trip instance, the trip_id (and if necessary,
///   start_time) is set. If route_id is also set, then it should be same as one
///   that the given trip corresponds to.
/// - To specify all the trips along a given route, only the route_id should be
///   set. Note that if the trip_id is not known, then stop sequence ids in
///   TripUpdate are not sufficient, and stop_ids must be provided as well. In
///   addition, absolute arrival/departure times must be provided.
class TripDescriptor extends $pb.GeneratedMessage {
  factory TripDescriptor({
    $core.String? tripId,
    $core.String? startTime,
    $core.String? startDate,
    TripDescriptor_ScheduleRelationship? scheduleRelationship,
    $core.String? routeId,
    $core.int? directionId,
  }) {
    final result = create();
    if (tripId != null) result.tripId = tripId;
    if (startTime != null) result.startTime = startTime;
    if (startDate != null) result.startDate = startDate;
    if (scheduleRelationship != null)
      result.scheduleRelationship = scheduleRelationship;
    if (routeId != null) result.routeId = routeId;
    if (directionId != null) result.directionId = directionId;
    return result;
  }

  TripDescriptor._();

  factory TripDescriptor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TripDescriptor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TripDescriptor',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tripId')
    ..aOS(2, _omitFieldNames ? '' : 'startTime')
    ..aOS(3, _omitFieldNames ? '' : 'startDate')
    ..aE<TripDescriptor_ScheduleRelationship>(
        4, _omitFieldNames ? '' : 'scheduleRelationship',
        enumValues: TripDescriptor_ScheduleRelationship.values)
    ..aOS(5, _omitFieldNames ? '' : 'routeId')
    ..aI(6, _omitFieldNames ? '' : 'directionId',
        fieldType: $pb.PbFieldType.OU3)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripDescriptor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TripDescriptor copyWith(void Function(TripDescriptor) updates) =>
      super.copyWith((message) => updates(message as TripDescriptor))
          as TripDescriptor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TripDescriptor create() => TripDescriptor._();
  @$core.override
  TripDescriptor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TripDescriptor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TripDescriptor>(create);
  static TripDescriptor? _defaultInstance;

  /// The trip_id from the GTFS feed that this selector refers to.
  /// For non frequency-based trips, this field is enough to uniquely identify
  /// the trip. For frequency-based trip, start_time and start_date might also be
  /// necessary.
  @$pb.TagNumber(1)
  $core.String get tripId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tripId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTripId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTripId() => $_clearField(1);

  /// The initially scheduled start time of this trip instance.
  /// When the trip_id corresponds to a non-frequency-based trip, this field
  /// should either be omitted or be equal to the value in the GTFS feed. When
  /// the trip_id corresponds to a frequency-based trip, the start_time must be
  /// specified for trip updates and vehicle positions. If the trip corresponds
  /// to exact_times=1 GTFS record, then start_time must be some multiple
  /// (including zero) of headway_secs later than frequencies.txt start_time for
  /// the corresponding time period. If the trip corresponds to exact_times=0,
  /// then its start_time may be arbitrary, and is initially expected to be the
  /// first departure of the trip. Once established, the start_time of this
  /// frequency-based trip should be considered immutable, even if the first
  /// departure time changes -- that time change may instead be reflected in a
  /// StopTimeUpdate.
  /// Format and semantics of the field is same as that of
  /// GTFS/frequencies.txt/start_time, e.g., 11:15:35 or 25:15:35.
  @$pb.TagNumber(2)
  $core.String get startTime => $_getSZ(1);
  @$pb.TagNumber(2)
  set startTime($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  /// The scheduled start date of this trip instance.
  /// Must be provided to disambiguate trips that are so late as to collide with
  /// a scheduled trip on a next day. For example, for a train that departs 8:00
  /// and 20:00 every day, and is 12 hours late, there would be two distinct
  /// trips on the same time.
  /// This field can be provided but is not mandatory for schedules in which such
  /// collisions are impossible - for example, a service running on hourly
  /// schedule where a vehicle that is one hour late is not considered to be
  /// related to schedule anymore.
  /// In YYYYMMDD format.
  @$pb.TagNumber(3)
  $core.String get startDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set startDate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStartDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartDate() => $_clearField(3);

  @$pb.TagNumber(4)
  TripDescriptor_ScheduleRelationship get scheduleRelationship => $_getN(3);
  @$pb.TagNumber(4)
  set scheduleRelationship(TripDescriptor_ScheduleRelationship value) =>
      $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasScheduleRelationship() => $_has(3);
  @$pb.TagNumber(4)
  void clearScheduleRelationship() => $_clearField(4);

  /// The route_id from the GTFS that this selector refers to.
  @$pb.TagNumber(5)
  $core.String get routeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set routeId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRouteId() => $_has(4);
  @$pb.TagNumber(5)
  void clearRouteId() => $_clearField(5);

  /// The direction_id from the GTFS feed trips.txt file, indicating the
  /// direction of travel for trips this selector refers to. This field is
  /// still experimental, and subject to change. It may be formally adopted in
  /// the future.
  @$pb.TagNumber(6)
  $core.int get directionId => $_getIZ(5);
  @$pb.TagNumber(6)
  set directionId($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDirectionId() => $_has(5);
  @$pb.TagNumber(6)
  void clearDirectionId() => $_clearField(6);
}

/// Identification information for the vehicle performing the trip.
class VehicleDescriptor extends $pb.GeneratedMessage {
  factory VehicleDescriptor({
    $core.String? id,
    $core.String? label,
    $core.String? licensePlate,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    if (licensePlate != null) result.licensePlate = licensePlate;
    return result;
  }

  VehicleDescriptor._();

  factory VehicleDescriptor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VehicleDescriptor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VehicleDescriptor',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'licensePlate')
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VehicleDescriptor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VehicleDescriptor copyWith(void Function(VehicleDescriptor) updates) =>
      super.copyWith((message) => updates(message as VehicleDescriptor))
          as VehicleDescriptor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VehicleDescriptor create() => VehicleDescriptor._();
  @$core.override
  VehicleDescriptor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VehicleDescriptor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VehicleDescriptor>(create);
  static VehicleDescriptor? _defaultInstance;

  /// Internal system identification of the vehicle. Should be unique per
  /// vehicle, and can be used for tracking the vehicle as it proceeds through
  /// the system.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// User visible label, i.e., something that must be shown to the passenger to
  /// help identify the correct vehicle.
  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  /// The license plate of the vehicle.
  @$pb.TagNumber(3)
  $core.String get licensePlate => $_getSZ(2);
  @$pb.TagNumber(3)
  set licensePlate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLicensePlate() => $_has(2);
  @$pb.TagNumber(3)
  void clearLicensePlate() => $_clearField(3);
}

/// A selector for an entity in a GTFS feed.
class EntitySelector extends $pb.GeneratedMessage {
  factory EntitySelector({
    $core.String? agencyId,
    $core.String? routeId,
    $core.int? routeType,
    TripDescriptor? trip,
    $core.String? stopId,
  }) {
    final result = create();
    if (agencyId != null) result.agencyId = agencyId;
    if (routeId != null) result.routeId = routeId;
    if (routeType != null) result.routeType = routeType;
    if (trip != null) result.trip = trip;
    if (stopId != null) result.stopId = stopId;
    return result;
  }

  EntitySelector._();

  factory EntitySelector.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EntitySelector.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntitySelector',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'agencyId')
    ..aOS(2, _omitFieldNames ? '' : 'routeId')
    ..aI(3, _omitFieldNames ? '' : 'routeType')
    ..aOM<TripDescriptor>(4, _omitFieldNames ? '' : 'trip',
        subBuilder: TripDescriptor.create)
    ..aOS(5, _omitFieldNames ? '' : 'stopId')
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntitySelector clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntitySelector copyWith(void Function(EntitySelector) updates) =>
      super.copyWith((message) => updates(message as EntitySelector))
          as EntitySelector;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EntitySelector create() => EntitySelector._();
  @$core.override
  EntitySelector createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EntitySelector getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntitySelector>(create);
  static EntitySelector? _defaultInstance;

  /// The values of the fields should correspond to the appropriate fields in the
  /// GTFS feed.
  /// At least one specifier must be given. If several are given, then the
  /// matching has to apply to all the given specifiers.
  @$pb.TagNumber(1)
  $core.String get agencyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set agencyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAgencyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAgencyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set routeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRouteId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRouteId() => $_clearField(2);

  /// corresponds to route_type in GTFS.
  @$pb.TagNumber(3)
  $core.int get routeType => $_getIZ(2);
  @$pb.TagNumber(3)
  set routeType($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRouteType() => $_has(2);
  @$pb.TagNumber(3)
  void clearRouteType() => $_clearField(3);

  @$pb.TagNumber(4)
  TripDescriptor get trip => $_getN(3);
  @$pb.TagNumber(4)
  set trip(TripDescriptor value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTrip() => $_has(3);
  @$pb.TagNumber(4)
  void clearTrip() => $_clearField(4);
  @$pb.TagNumber(4)
  TripDescriptor ensureTrip() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get stopId => $_getSZ(4);
  @$pb.TagNumber(5)
  set stopId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStopId() => $_has(4);
  @$pb.TagNumber(5)
  void clearStopId() => $_clearField(5);
}

class TranslatedString_Translation extends $pb.GeneratedMessage {
  factory TranslatedString_Translation({
    $core.String? text,
    $core.String? language,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (language != null) result.language = language;
    return result;
  }

  TranslatedString_Translation._();

  factory TranslatedString_Translation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslatedString_Translation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslatedString.Translation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..aQS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'language')
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslatedString_Translation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslatedString_Translation copyWith(
          void Function(TranslatedString_Translation) updates) =>
      super.copyWith(
              (message) => updates(message as TranslatedString_Translation))
          as TranslatedString_Translation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslatedString_Translation create() =>
      TranslatedString_Translation._();
  @$core.override
  TranslatedString_Translation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslatedString_Translation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslatedString_Translation>(create);
  static TranslatedString_Translation? _defaultInstance;

  /// A UTF-8 string containing the message.
  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  /// BCP-47 language code. Can be omitted if the language is unknown or if
  /// no i18n is done at all for the feed. At most one translation is
  /// allowed to have an unspecified language tag.
  @$pb.TagNumber(2)
  $core.String get language => $_getSZ(1);
  @$pb.TagNumber(2)
  set language($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLanguage() => $_has(1);
  @$pb.TagNumber(2)
  void clearLanguage() => $_clearField(2);
}

/// An internationalized message containing per-language versions of a snippet of
/// text or a URL.
/// One of the strings from a message will be picked up. The resolution proceeds
/// as follows:
/// 1. If the UI language matches the language code of a translation,
///    the first matching translation is picked.
/// 2. If a default UI language (e.g., English) matches the language code of a
///    translation, the first matching translation is picked.
/// 3. If some translation has an unspecified language code, that translation is
///    picked.
class TranslatedString extends $pb.GeneratedMessage {
  factory TranslatedString({
    $core.Iterable<TranslatedString_Translation>? translation,
  }) {
    final result = create();
    if (translation != null) result.translation.addAll(translation);
    return result;
  }

  TranslatedString._();

  factory TranslatedString.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TranslatedString.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TranslatedString',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..pPM<TranslatedString_Translation>(1, _omitFieldNames ? '' : 'translation',
        subBuilder: TranslatedString_Translation.create)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslatedString clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TranslatedString copyWith(void Function(TranslatedString) updates) =>
      super.copyWith((message) => updates(message as TranslatedString))
          as TranslatedString;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TranslatedString create() => TranslatedString._();
  @$core.override
  TranslatedString createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TranslatedString getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TranslatedString>(create);
  static TranslatedString? _defaultInstance;

  /// At least one translation must be provided.
  @$pb.TagNumber(1)
  $pb.PbList<TranslatedString_Translation> get translation => $_getList(0);
}

class TfnswVehicleDescriptor extends $pb.GeneratedMessage {
  factory TfnswVehicleDescriptor({
    $core.bool? airConditioned,
    $core.int? wheelchairAccessible,
  }) {
    final result = create();
    if (airConditioned != null) result.airConditioned = airConditioned;
    if (wheelchairAccessible != null)
      result.wheelchairAccessible = wheelchairAccessible;
    return result;
  }

  TfnswVehicleDescriptor._();

  factory TfnswVehicleDescriptor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TfnswVehicleDescriptor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TfnswVehicleDescriptor',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: create)
    ..a<$core.bool>(
        1, _omitFieldNames ? '' : 'airConditioned', $pb.PbFieldType.OB,
        defaultOrMaker: true)
    ..aI(2, _omitFieldNames ? '' : 'wheelchairAccessible')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TfnswVehicleDescriptor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TfnswVehicleDescriptor copyWith(
          void Function(TfnswVehicleDescriptor) updates) =>
      super.copyWith((message) => updates(message as TfnswVehicleDescriptor))
          as TfnswVehicleDescriptor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TfnswVehicleDescriptor create() => TfnswVehicleDescriptor._();
  @$core.override
  TfnswVehicleDescriptor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TfnswVehicleDescriptor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TfnswVehicleDescriptor>(create);
  static TfnswVehicleDescriptor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get airConditioned => $_getB(0, true);
  @$pb.TagNumber(1)
  set airConditioned($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAirConditioned() => $_has(0);
  @$pb.TagNumber(1)
  void clearAirConditioned() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get wheelchairAccessible => $_getIZ(1);
  @$pb.TagNumber(2)
  set wheelchairAccessible($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWheelchairAccessible() => $_has(1);
  @$pb.TagNumber(2)
  void clearWheelchairAccessible() => $_clearField(2);
}

class Adelaidemetro_gtfsr {
  static final tfnswVehicleDescriptor = $pb.Extension<TfnswVehicleDescriptor>(
      _omitMessageNames ? '' : 'transit_realtime.VehicleDescriptor',
      _omitFieldNames ? '' : 'tfnswVehicleDescriptor',
      1999,
      $pb.PbFieldType.OM,
      defaultOrMaker: TfnswVehicleDescriptor.getDefault,
      subBuilder: TfnswVehicleDescriptor.create);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(tfnswVehicleDescriptor);
  }
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
