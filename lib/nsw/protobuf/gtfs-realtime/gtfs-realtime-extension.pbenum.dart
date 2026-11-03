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

class TrackDirection extends $pb.ProtobufEnum {
  static const TrackDirection UP =
      TrackDirection._(0, _omitEnumNames ? '' : 'UP');
  static const TrackDirection DOWN =
      TrackDirection._(1, _omitEnumNames ? '' : 'DOWN');

  static const $core.List<TrackDirection> values = <TrackDirection>[
    UP,
    DOWN,
  ];

  static final $core.List<TrackDirection?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static TrackDirection? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TrackDirection._(super.value, super.name);
}

class CarriageDescriptor_OccupancyStatus extends $pb.ProtobufEnum {
  static const CarriageDescriptor_OccupancyStatus EMPTY =
      CarriageDescriptor_OccupancyStatus._(0, _omitEnumNames ? '' : 'EMPTY');
  static const CarriageDescriptor_OccupancyStatus MANY_SEATS_AVAILABLE =
      CarriageDescriptor_OccupancyStatus._(
          1, _omitEnumNames ? '' : 'MANY_SEATS_AVAILABLE');
  static const CarriageDescriptor_OccupancyStatus FEW_SEATS_AVAILABLE =
      CarriageDescriptor_OccupancyStatus._(
          2, _omitEnumNames ? '' : 'FEW_SEATS_AVAILABLE');
  static const CarriageDescriptor_OccupancyStatus STANDING_ROOM_ONLY =
      CarriageDescriptor_OccupancyStatus._(
          3, _omitEnumNames ? '' : 'STANDING_ROOM_ONLY');
  static const CarriageDescriptor_OccupancyStatus CRUSHED_STANDING_ROOM_ONLY =
      CarriageDescriptor_OccupancyStatus._(
          4, _omitEnumNames ? '' : 'CRUSHED_STANDING_ROOM_ONLY');
  static const CarriageDescriptor_OccupancyStatus FULL =
      CarriageDescriptor_OccupancyStatus._(5, _omitEnumNames ? '' : 'FULL');

  static const $core.List<CarriageDescriptor_OccupancyStatus> values =
      <CarriageDescriptor_OccupancyStatus>[
    EMPTY,
    MANY_SEATS_AVAILABLE,
    FEW_SEATS_AVAILABLE,
    STANDING_ROOM_ONLY,
    CRUSHED_STANDING_ROOM_ONLY,
    FULL,
  ];

  static final $core.List<CarriageDescriptor_OccupancyStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static CarriageDescriptor_OccupancyStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CarriageDescriptor_OccupancyStatus._(super.value, super.name);
}

class CarriageDescriptor_ToiletStatus extends $pb.ProtobufEnum {
  static const CarriageDescriptor_ToiletStatus NONE =
      CarriageDescriptor_ToiletStatus._(0, _omitEnumNames ? '' : 'NONE');
  static const CarriageDescriptor_ToiletStatus NORMAL =
      CarriageDescriptor_ToiletStatus._(1, _omitEnumNames ? '' : 'NORMAL');
  static const CarriageDescriptor_ToiletStatus ACCESSIBLE =
      CarriageDescriptor_ToiletStatus._(2, _omitEnumNames ? '' : 'ACCESSIBLE');

  static const $core.List<CarriageDescriptor_ToiletStatus> values =
      <CarriageDescriptor_ToiletStatus>[
    NONE,
    NORMAL,
    ACCESSIBLE,
  ];

  static final $core.List<CarriageDescriptor_ToiletStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static CarriageDescriptor_ToiletStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CarriageDescriptor_ToiletStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
