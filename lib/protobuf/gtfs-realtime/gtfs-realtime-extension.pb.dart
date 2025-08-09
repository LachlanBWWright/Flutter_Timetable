//
//  Generated code. Do not modify.
//  source: gtfs-realtime-extension.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

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
    final $result = create();
    if (gTFSStaticBundle != null) {
      $result.gTFSStaticBundle = gTFSStaticBundle;
    }
    if (updateSequence != null) {
      $result.updateSequence = updateSequence;
    }
    if (cancelledTrip != null) {
      $result.cancelledTrip.addAll(cancelledTrip);
    }
    return $result;
  }
  UpdateBundle._() : super();
  factory UpdateBundle.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateBundle.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateBundle', package: const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'), createEmptyInstance: create)
    ..aQS(1, _omitFieldNames ? '' : 'GTFSStaticBundle', protoName: 'GTFSStaticBundle')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'updateSequence', $pb.PbFieldType.Q3)
    ..pPS(4, _omitFieldNames ? '' : 'cancelledTrip')
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateBundle clone() => UpdateBundle()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateBundle copyWith(void Function(UpdateBundle) updates) => super.copyWith((message) => updates(message as UpdateBundle)) as UpdateBundle;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateBundle create() => UpdateBundle._();
  UpdateBundle createEmptyInstance() => create();
  static $pb.PbList<UpdateBundle> createRepeated() => $pb.PbList<UpdateBundle>();
  @$core.pragma('dart2js:noInline')
  static UpdateBundle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateBundle>(create);
  static UpdateBundle? _defaultInstance;

  /// the name of the bundle to be updated. This is to allow consumers to update the correct bundle
  @$pb.TagNumber(1)
  $core.String get gTFSStaticBundle => $_getSZ(0);
  @$pb.TagNumber(1)
  set gTFSStaticBundle($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGTFSStaticBundle() => $_has(0);
  @$pb.TagNumber(1)
  void clearGTFSStaticBundle() => $_clearField(1);

  /// This field is the update sequence ID. It should commence at 1 for the first update to a static bundle and increment by 1 for each successive update
  /// The intent of this field is to allow the consumer to identify updates they may already have processed.
  @$pb.TagNumber(2)
  $core.int get updateSequence => $_getIZ(1);
  @$pb.TagNumber(2)
  set updateSequence($core.int v) { $_setSignedInt32(1, v); }
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
    final $result = create();
    if (airConditioned != null) {
      $result.airConditioned = airConditioned;
    }
    if (wheelchairAccessible != null) {
      $result.wheelchairAccessible = wheelchairAccessible;
    }
    if (vehicleModel != null) {
      $result.vehicleModel = vehicleModel;
    }
    if (performingPriorTrip != null) {
      $result.performingPriorTrip = performingPriorTrip;
    }
    if (specialVehicleAttributes != null) {
      $result.specialVehicleAttributes = specialVehicleAttributes;
    }
    return $result;
  }
  TfnswVehicleDescriptor._() : super();
  factory TfnswVehicleDescriptor.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TfnswVehicleDescriptor.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TfnswVehicleDescriptor', package: const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'airConditioned')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'wheelchairAccessible', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'vehicleModel')
    ..aOB(4, _omitFieldNames ? '' : 'performingPriorTrip')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'specialVehicleAttributes', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TfnswVehicleDescriptor clone() => TfnswVehicleDescriptor()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TfnswVehicleDescriptor copyWith(void Function(TfnswVehicleDescriptor) updates) => super.copyWith((message) => updates(message as TfnswVehicleDescriptor)) as TfnswVehicleDescriptor;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TfnswVehicleDescriptor create() => TfnswVehicleDescriptor._();
  TfnswVehicleDescriptor createEmptyInstance() => create();
  static $pb.PbList<TfnswVehicleDescriptor> createRepeated() => $pb.PbList<TfnswVehicleDescriptor>();
  @$core.pragma('dart2js:noInline')
  static TfnswVehicleDescriptor getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TfnswVehicleDescriptor>(create);
  static TfnswVehicleDescriptor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get airConditioned => $_getBF(0);
  @$pb.TagNumber(1)
  set airConditioned($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAirConditioned() => $_has(0);
  @$pb.TagNumber(1)
  void clearAirConditioned() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get wheelchairAccessible => $_getIZ(1);
  @$pb.TagNumber(2)
  set wheelchairAccessible($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWheelchairAccessible() => $_has(1);
  @$pb.TagNumber(2)
  void clearWheelchairAccessible() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get vehicleModel => $_getSZ(2);
  @$pb.TagNumber(3)
  set vehicleModel($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVehicleModel() => $_has(2);
  @$pb.TagNumber(3)
  void clearVehicleModel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get performingPriorTrip => $_getBF(3);
  @$pb.TagNumber(4)
  set performingPriorTrip($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPerformingPriorTrip() => $_has(3);
  @$pb.TagNumber(4)
  void clearPerformingPriorTrip() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get specialVehicleAttributes => $_getIZ(4);
  @$pb.TagNumber(5)
  set specialVehicleAttributes($core.int v) { $_setSignedInt32(4, v); }
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
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (positionInConsist != null) {
      $result.positionInConsist = positionInConsist;
    }
    if (occupancyStatus != null) {
      $result.occupancyStatus = occupancyStatus;
    }
    if (quietCarriage != null) {
      $result.quietCarriage = quietCarriage;
    }
    if (toilet != null) {
      $result.toilet = toilet;
    }
    if (luggageRack != null) {
      $result.luggageRack = luggageRack;
    }
    if (departureOccupancyStatus != null) {
      $result.departureOccupancyStatus = departureOccupancyStatus;
    }
    return $result;
  }
  CarriageDescriptor._() : super();
  factory CarriageDescriptor.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CarriageDescriptor.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CarriageDescriptor', package: const $pb.PackageName(_omitMessageNames ? '' : 'transit_realtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'positionInConsist', $pb.PbFieldType.Q3)
    ..e<CarriageDescriptor_OccupancyStatus>(3, _omitFieldNames ? '' : 'occupancyStatus', $pb.PbFieldType.OE, defaultOrMaker: CarriageDescriptor_OccupancyStatus.EMPTY, valueOf: CarriageDescriptor_OccupancyStatus.valueOf, enumValues: CarriageDescriptor_OccupancyStatus.values)
    ..aOB(4, _omitFieldNames ? '' : 'quietCarriage')
    ..e<CarriageDescriptor_ToiletStatus>(5, _omitFieldNames ? '' : 'toilet', $pb.PbFieldType.OE, defaultOrMaker: CarriageDescriptor_ToiletStatus.NONE, valueOf: CarriageDescriptor_ToiletStatus.valueOf, enumValues: CarriageDescriptor_ToiletStatus.values)
    ..aOB(6, _omitFieldNames ? '' : 'luggageRack')
    ..e<CarriageDescriptor_OccupancyStatus>(7, _omitFieldNames ? '' : 'departureOccupancyStatus', $pb.PbFieldType.OE, defaultOrMaker: CarriageDescriptor_OccupancyStatus.EMPTY, valueOf: CarriageDescriptor_OccupancyStatus.valueOf, enumValues: CarriageDescriptor_OccupancyStatus.values)
    ..hasExtensions = true
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CarriageDescriptor clone() => CarriageDescriptor()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CarriageDescriptor copyWith(void Function(CarriageDescriptor) updates) => super.copyWith((message) => updates(message as CarriageDescriptor)) as CarriageDescriptor;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CarriageDescriptor create() => CarriageDescriptor._();
  CarriageDescriptor createEmptyInstance() => create();
  static $pb.PbList<CarriageDescriptor> createRepeated() => $pb.PbList<CarriageDescriptor>();
  @$core.pragma('dart2js:noInline')
  static CarriageDescriptor getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CarriageDescriptor>(create);
  static CarriageDescriptor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get positionInConsist => $_getIZ(1);
  @$pb.TagNumber(2)
  set positionInConsist($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPositionInConsist() => $_has(1);
  @$pb.TagNumber(2)
  void clearPositionInConsist() => $_clearField(2);

  @$pb.TagNumber(3)
  CarriageDescriptor_OccupancyStatus get occupancyStatus => $_getN(2);
  @$pb.TagNumber(3)
  set occupancyStatus(CarriageDescriptor_OccupancyStatus v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasOccupancyStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearOccupancyStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get quietCarriage => $_getBF(3);
  @$pb.TagNumber(4)
  set quietCarriage($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasQuietCarriage() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuietCarriage() => $_clearField(4);

  @$pb.TagNumber(5)
  CarriageDescriptor_ToiletStatus get toilet => $_getN(4);
  @$pb.TagNumber(5)
  set toilet(CarriageDescriptor_ToiletStatus v) { $_setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasToilet() => $_has(4);
  @$pb.TagNumber(5)
  void clearToilet() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get luggageRack => $_getBF(5);
  @$pb.TagNumber(6)
  set luggageRack($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLuggageRack() => $_has(5);
  @$pb.TagNumber(6)
  void clearLuggageRack() => $_clearField(6);

  @$pb.TagNumber(7)
  CarriageDescriptor_OccupancyStatus get departureOccupancyStatus => $_getN(6);
  @$pb.TagNumber(7)
  set departureOccupancyStatus(CarriageDescriptor_OccupancyStatus v) { $_setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasDepartureOccupancyStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearDepartureOccupancyStatus() => $_clearField(7);
}

class Gtfs_realtime_extension {
  static final update = $pb.Extension<UpdateBundle>(_omitMessageNames ? '' : 'transit_realtime.FeedEntity', _omitFieldNames ? '' : 'update', 1007, $pb.PbFieldType.OM, defaultOrMaker: UpdateBundle.getDefault, subBuilder: UpdateBundle.create);
  static final consist = $pb.Extension<CarriageDescriptor>.repeated(_omitMessageNames ? '' : 'transit_realtime.VehiclePosition', _omitFieldNames ? '' : 'consist', 1007, $pb.PbFieldType.PM, check: $pb.getCheckFunction($pb.PbFieldType.PM), subBuilder: CarriageDescriptor.create);
  static final trackDirection = $pb.Extension<TrackDirection>(_omitMessageNames ? '' : 'transit_realtime.Position', _omitFieldNames ? '' : 'trackDirection', 1007, $pb.PbFieldType.OE, defaultOrMaker: TrackDirection.UP, valueOf: TrackDirection.valueOf, enumValues: TrackDirection.values);
  static final tfnswVehicleDescriptor = $pb.Extension<TfnswVehicleDescriptor>(_omitMessageNames ? '' : 'transit_realtime.VehicleDescriptor', _omitFieldNames ? '' : 'tfnswVehicleDescriptor', 1007, $pb.PbFieldType.OM, defaultOrMaker: TfnswVehicleDescriptor.getDefault, subBuilder: TfnswVehicleDescriptor.create);
  static final carriageSeqPredictiveOccupancy = $pb.Extension<CarriageDescriptor>.repeated(_omitMessageNames ? '' : 'transit_realtime.TripUpdate.StopTimeUpdate', _omitFieldNames ? '' : 'carriageSeqPredictiveOccupancy', 1007, $pb.PbFieldType.PM, check: $pb.getCheckFunction($pb.PbFieldType.PM), subBuilder: CarriageDescriptor.create);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(update);
    registry.add(consist);
    registry.add(trackDirection);
    registry.add(tfnswVehicleDescriptor);
    registry.add(carriageSeqPredictiveOccupancy);
  }
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
