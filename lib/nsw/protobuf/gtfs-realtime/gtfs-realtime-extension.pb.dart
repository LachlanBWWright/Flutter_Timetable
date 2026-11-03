// This is a generated file - do not edit.
//
// Generated from gtfs-realtime-extension.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'gtfs-realtime-extension.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'gtfs-realtime-extension.pbenum.dart';

/// NEW
/// An addition to the GTFS static bundle
class UpdateBundle extends $pb.GeneratedMessage {
  factory UpdateBundle({
    $core.String? gTFSStaticBundle,
    $core.int? updateSequence,
    $core.Iterable<$core.String>? cancelledTrip,
  }) {
    final result = UpdateBundle._();
    if (gTFSStaticBundle != null) result.gTFSStaticBundle = gTFSStaticBundle;
    if (updateSequence != null) result.updateSequence = updateSequence;
    if (cancelledTrip != null) result.cancelledTrip.addAll(cancelledTrip);
    return result;
  }

  UpdateBundle._();

  factory UpdateBundle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateBundle()..mergeFromBuffer(data, registry);
  factory UpdateBundle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateBundle()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateBundle',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: UpdateBundle.$_createMessage)
    ..aQS(1, _omitFieldNames ? '' : 'GTFSStaticBundle',
        protoName: 'GTFSStaticBundle')
    ..aI(2, _omitFieldNames ? '' : 'updateSequence',
        fieldType: $pb.PbFieldType.Q3)
    ..pPS(4, _omitFieldNames ? '' : 'cancelledTrip');

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateBundle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateBundle copyWith(void Function(UpdateBundle) updates) =>
      super.copyWith((message) => updates(message as UpdateBundle))
          as UpdateBundle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateBundle() / UpdateBundle.new instead')
  static UpdateBundle create() => UpdateBundle._();
  static $pb.GeneratedMessage $_createMessage() => UpdateBundle._();
  @$core.override
  UpdateBundle createEmptyInstance() => UpdateBundle._();
  @$core.pragma('dart2js:noInline')
  static UpdateBundle getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateBundle>(
          UpdateBundle.$_createMessage);
  static UpdateBundle? _defaultInstance;

  /// the name of the bundle to be updated. This is to allow consumers to update the correct bundle
  @$pb.TagNumber(1)
  $core.String get gTFSStaticBundle => $_getSZ(0);
  @$pb.TagNumber(1)
  set gTFSStaticBundle($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGTFSStaticBundle() => $_has(0);
  @$pb.TagNumber(1)
  void clearGTFSStaticBundle() => $_clearField(1);

  /// This field is the update sequence ID. It should commence at 1 for the first update to a static bundle and increment by 1 for each successive update
  /// The intent of this field is to allow the consumer to identify updates they may already have processed.
  @$pb.TagNumber(2)
  $core.int get updateSequence => $_getIZ(1);
  @$pb.TagNumber(2)
  set updateSequence($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateSequence() => $_clearField(2);

  /// repeated field to cancel scheduled trips in the bundle. This is the trip_id to cancel.
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get cancelledTrip => $_getList(2);
}

/// NEW
class TfnswVehicleDescriptor extends $pb.GeneratedMessage {
  factory TfnswVehicleDescriptor({
    $core.bool? airConditioned,
    $core.int? wheelchairAccessible,
    $core.String? vehicleModel,
    $core.bool? performingPriorTrip,
    $core.int? specialVehicleAttributes,
  }) {
    final result = TfnswVehicleDescriptor._();
    if (airConditioned != null) result.airConditioned = airConditioned;
    if (wheelchairAccessible != null)
      result.wheelchairAccessible = wheelchairAccessible;
    if (vehicleModel != null) result.vehicleModel = vehicleModel;
    if (performingPriorTrip != null)
      result.performingPriorTrip = performingPriorTrip;
    if (specialVehicleAttributes != null)
      result.specialVehicleAttributes = specialVehicleAttributes;
    return result;
  }

  TfnswVehicleDescriptor._();

  factory TfnswVehicleDescriptor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TfnswVehicleDescriptor()..mergeFromBuffer(data, registry);
  factory TfnswVehicleDescriptor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TfnswVehicleDescriptor()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TfnswVehicleDescriptor',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: TfnswVehicleDescriptor.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'airConditioned')
    ..aI(2, _omitFieldNames ? '' : 'wheelchairAccessible')
    ..aOS(3, _omitFieldNames ? '' : 'vehicleModel')
    ..aOB(4, _omitFieldNames ? '' : 'performingPriorTrip')
    ..aI(5, _omitFieldNames ? '' : 'specialVehicleAttributes')
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
  @$core.Deprecated(
      'Use TfnswVehicleDescriptor() / TfnswVehicleDescriptor.new instead')
  static TfnswVehicleDescriptor create() => TfnswVehicleDescriptor._();
  static $pb.GeneratedMessage $_createMessage() => TfnswVehicleDescriptor._();
  @$core.override
  TfnswVehicleDescriptor createEmptyInstance() => TfnswVehicleDescriptor._();
  @$core.pragma('dart2js:noInline')
  static TfnswVehicleDescriptor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TfnswVehicleDescriptor>(
          TfnswVehicleDescriptor.$_createMessage);
  static TfnswVehicleDescriptor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get airConditioned => $_getBF(0);
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

  @$pb.TagNumber(3)
  $core.String get vehicleModel => $_getSZ(2);
  @$pb.TagNumber(3)
  set vehicleModel($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVehicleModel() => $_has(2);
  @$pb.TagNumber(3)
  void clearVehicleModel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get performingPriorTrip => $_getBF(3);
  @$pb.TagNumber(4)
  set performingPriorTrip($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPerformingPriorTrip() => $_has(3);
  @$pb.TagNumber(4)
  void clearPerformingPriorTrip() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get specialVehicleAttributes => $_getIZ(4);
  @$pb.TagNumber(5)
  set specialVehicleAttributes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpecialVehicleAttributes() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpecialVehicleAttributes() => $_clearField(5);
}

/// NEW
class CarriageDescriptor extends $pb.GeneratedMessage {
  factory CarriageDescriptor({
    $core.String? name,
    $core.int? positionInConsist,
    CarriageDescriptor_OccupancyStatus? occupancyStatus,
    $core.bool? quietCarriage,
    CarriageDescriptor_ToiletStatus? toilet,
    $core.bool? luggageRack,
    CarriageDescriptor_OccupancyStatus? departureOccupancyStatus,
  }) {
    final result = CarriageDescriptor._();
    if (name != null) result.name = name;
    if (positionInConsist != null) result.positionInConsist = positionInConsist;
    if (occupancyStatus != null) result.occupancyStatus = occupancyStatus;
    if (quietCarriage != null) result.quietCarriage = quietCarriage;
    if (toilet != null) result.toilet = toilet;
    if (luggageRack != null) result.luggageRack = luggageRack;
    if (departureOccupancyStatus != null)
      result.departureOccupancyStatus = departureOccupancyStatus;
    return result;
  }

  CarriageDescriptor._();

  factory CarriageDescriptor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CarriageDescriptor()..mergeFromBuffer(data, registry);
  factory CarriageDescriptor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CarriageDescriptor()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CarriageDescriptor',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'),
      createEmptyInstance: CarriageDescriptor.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'positionInConsist',
        fieldType: $pb.PbFieldType.Q3)
    ..aE<CarriageDescriptor_OccupancyStatus>(
        3, _omitFieldNames ? '' : 'occupancyStatus',
        enumValues: CarriageDescriptor_OccupancyStatus.values)
    ..aOB(4, _omitFieldNames ? '' : 'quietCarriage')
    ..aE<CarriageDescriptor_ToiletStatus>(5, _omitFieldNames ? '' : 'toilet',
        enumValues: CarriageDescriptor_ToiletStatus.values)
    ..aOB(6, _omitFieldNames ? '' : 'luggageRack')
    ..aE<CarriageDescriptor_OccupancyStatus>(
        7, _omitFieldNames ? '' : 'departureOccupancyStatus',
        enumValues: CarriageDescriptor_OccupancyStatus.values)
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CarriageDescriptor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CarriageDescriptor copyWith(void Function(CarriageDescriptor) updates) =>
      super.copyWith((message) => updates(message as CarriageDescriptor))
          as CarriageDescriptor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CarriageDescriptor() / CarriageDescriptor.new instead')
  static CarriageDescriptor create() => CarriageDescriptor._();
  static $pb.GeneratedMessage $_createMessage() => CarriageDescriptor._();
  @$core.override
  CarriageDescriptor createEmptyInstance() => CarriageDescriptor._();
  @$core.pragma('dart2js:noInline')
  static CarriageDescriptor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CarriageDescriptor>(
          CarriageDescriptor.$_createMessage);
  static CarriageDescriptor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get positionInConsist => $_getIZ(1);
  @$pb.TagNumber(2)
  set positionInConsist($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPositionInConsist() => $_has(1);
  @$pb.TagNumber(2)
  void clearPositionInConsist() => $_clearField(2);

  @$pb.TagNumber(3)
  CarriageDescriptor_OccupancyStatus get occupancyStatus => $_getN(2);
  @$pb.TagNumber(3)
  set occupancyStatus(CarriageDescriptor_OccupancyStatus value) =>
      $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOccupancyStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearOccupancyStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get quietCarriage => $_getBF(3);
  @$pb.TagNumber(4)
  set quietCarriage($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQuietCarriage() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuietCarriage() => $_clearField(4);

  @$pb.TagNumber(5)
  CarriageDescriptor_ToiletStatus get toilet => $_getN(4);
  @$pb.TagNumber(5)
  set toilet(CarriageDescriptor_ToiletStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasToilet() => $_has(4);
  @$pb.TagNumber(5)
  void clearToilet() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get luggageRack => $_getBF(5);
  @$pb.TagNumber(6)
  set luggageRack($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLuggageRack() => $_has(5);
  @$pb.TagNumber(6)
  void clearLuggageRack() => $_clearField(6);

  @$pb.TagNumber(7)
  CarriageDescriptor_OccupancyStatus get departureOccupancyStatus => $_getN(6);
  @$pb.TagNumber(7)
  set departureOccupancyStatus(CarriageDescriptor_OccupancyStatus value) =>
      $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDepartureOccupancyStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearDepartureOccupancyStatus() => $_clearField(7);
}

class Gtfs_realtime_extension {
  static final update = $pb.Extension<UpdateBundle>(
      _omitMessageNames ? '' : 'transit_realtime.FeedEntity',
      _omitFieldNames ? '' : 'update',
      1007,
      $pb.PbFieldType.OM,
      defaultOrMaker: UpdateBundle.getDefault,
      subBuilder: UpdateBundle.$_createMessage);
  static final consist = $pb.Extension<CarriageDescriptor>.repeated(
      _omitMessageNames ? '' : 'transit_realtime.VehiclePosition',
      _omitFieldNames ? '' : 'consist',
      1007,
      $pb.PbFieldType.PM,
      check: $pb.getCheckFunction($pb.PbFieldType.PM),
      subBuilder: CarriageDescriptor.$_createMessage);
  static final trackDirection = $pb.Extension<TrackDirection>(
      _omitMessageNames ? '' : 'transit_realtime.Position',
      _omitFieldNames ? '' : 'trackDirection',
      1007,
      $pb.PbFieldType.OE,
      defaultOrMaker: TrackDirection.UP,
      valueOf: TrackDirection.valueOf,
      enumValues: TrackDirection.values);
  static final tfnswVehicleDescriptor = $pb.Extension<TfnswVehicleDescriptor>(
      _omitMessageNames ? '' : 'transit_realtime.VehicleDescriptor',
      _omitFieldNames ? '' : 'tfnswVehicleDescriptor',
      1007,
      $pb.PbFieldType.OM,
      defaultOrMaker: TfnswVehicleDescriptor.getDefault,
      subBuilder: TfnswVehicleDescriptor.$_createMessage);
  static final carriageSeqPredictiveOccupancy =
      $pb.Extension<CarriageDescriptor>.repeated(
          _omitMessageNames ? '' : 'transit_realtime.TripUpdate.StopTimeUpdate',
          _omitFieldNames ? '' : 'carriageSeqPredictiveOccupancy',
          1007,
          $pb.PbFieldType.PM,
          check: $pb.getCheckFunction($pb.PbFieldType.PM),
          subBuilder: CarriageDescriptor.$_createMessage);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(update);
    registry.add(consist);
    registry.add(trackDirection);
    registry.add(tfnswVehicleDescriptor);
    registry.add(carriageSeqPredictiveOccupancy);
  }
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
