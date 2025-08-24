//
//  Generated code. Do not modify.
//  source: gtfs-realtime-extension.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use trackDirectionDescriptor instead')
const TrackDirection$json = {
  '1': 'TrackDirection',
  '2': [
    {'1': 'UP', '2': 0},
    {'1': 'DOWN', '2': 1},
  ],
};

/// Descriptor for `TrackDirection`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List trackDirectionDescriptor = $convert.base64Decode(
    'Cg5UcmFja0RpcmVjdGlvbhIGCgJVUBAAEggKBERPV04QAQ==');

@$core.Deprecated('Use updateBundleDescriptor instead')
const UpdateBundle$json = {
  '1': 'UpdateBundle',
  '2': [
    {'1': 'GTFSStaticBundle', '3': 1, '4': 2, '5': 9, '10': 'GTFSStaticBundle'},
    {'1': 'update_sequence', '3': 2, '4': 2, '5': 5, '10': 'updateSequence'},
    {'1': 'cancelled_trip', '3': 4, '4': 3, '5': 9, '10': 'cancelledTrip'},
  ],
};

/// Descriptor for `UpdateBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateBundleDescriptor = $convert.base64Decode(
    'CgxVcGRhdGVCdW5kbGUSKgoQR1RGU1N0YXRpY0J1bmRsZRgBIAIoCVIQR1RGU1N0YXRpY0J1bm'
    'RsZRInCg91cGRhdGVfc2VxdWVuY2UYAiACKAVSDnVwZGF0ZVNlcXVlbmNlEiUKDmNhbmNlbGxl'
    'ZF90cmlwGAQgAygJUg1jYW5jZWxsZWRUcmlw');

@$core.Deprecated('Use tfnswVehicleDescriptorDescriptor instead')
const TfnswVehicleDescriptor$json = {
  '1': 'TfnswVehicleDescriptor',
  '2': [
    {'1': 'air_conditioned', '3': 1, '4': 1, '5': 8, '7': 'false', '10': 'airConditioned'},
    {'1': 'wheelchair_accessible', '3': 2, '4': 1, '5': 5, '7': '0', '10': 'wheelchairAccessible'},
    {'1': 'vehicle_model', '3': 3, '4': 1, '5': 9, '10': 'vehicleModel'},
    {'1': 'performing_prior_trip', '3': 4, '4': 1, '5': 8, '7': 'false', '10': 'performingPriorTrip'},
    {'1': 'special_vehicle_attributes', '3': 5, '4': 1, '5': 5, '7': '0', '10': 'specialVehicleAttributes'},
  ],
};

/// Descriptor for `TfnswVehicleDescriptor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tfnswVehicleDescriptorDescriptor = $convert.base64Decode(
    'ChZUZm5zd1ZlaGljbGVEZXNjcmlwdG9yEi4KD2Fpcl9jb25kaXRpb25lZBgBIAEoCDoFZmFsc2'
    'VSDmFpckNvbmRpdGlvbmVkEjYKFXdoZWVsY2hhaXJfYWNjZXNzaWJsZRgCIAEoBToBMFIUd2hl'
    'ZWxjaGFpckFjY2Vzc2libGUSIwoNdmVoaWNsZV9tb2RlbBgDIAEoCVIMdmVoaWNsZU1vZGVsEj'
    'kKFXBlcmZvcm1pbmdfcHJpb3JfdHJpcBgEIAEoCDoFZmFsc2VSE3BlcmZvcm1pbmdQcmlvclRy'
    'aXASPwoac3BlY2lhbF92ZWhpY2xlX2F0dHJpYnV0ZXMYBSABKAU6ATBSGHNwZWNpYWxWZWhpY2'
    'xlQXR0cmlidXRlcw==');

@$core.Deprecated('Use carriageDescriptorDescriptor instead')
const CarriageDescriptor$json = {
  '1': 'CarriageDescriptor',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'position_in_consist', '3': 2, '4': 2, '5': 5, '10': 'positionInConsist'},
    {'1': 'occupancy_status', '3': 3, '4': 1, '5': 14, '6': '.transit_realtime.CarriageDescriptor.OccupancyStatus', '10': 'occupancyStatus'},
    {'1': 'quiet_carriage', '3': 4, '4': 1, '5': 8, '7': 'false', '10': 'quietCarriage'},
    {'1': 'toilet', '3': 5, '4': 1, '5': 14, '6': '.transit_realtime.CarriageDescriptor.ToiletStatus', '10': 'toilet'},
    {'1': 'luggage_rack', '3': 6, '4': 1, '5': 8, '7': 'false', '10': 'luggageRack'},
    {'1': 'departure_occupancy_status', '3': 7, '4': 1, '5': 14, '6': '.transit_realtime.CarriageDescriptor.OccupancyStatus', '10': 'departureOccupancyStatus'},
  ],
  '4': [CarriageDescriptor_OccupancyStatus$json, CarriageDescriptor_ToiletStatus$json],
  '5': [
    {'1': 1000, '2': 2000},
  ],
};

@$core.Deprecated('Use carriageDescriptorDescriptor instead')
const CarriageDescriptor_OccupancyStatus$json = {
  '1': 'OccupancyStatus',
  '2': [
    {'1': 'EMPTY', '2': 0},
    {'1': 'MANY_SEATS_AVAILABLE', '2': 1},
    {'1': 'FEW_SEATS_AVAILABLE', '2': 2},
    {'1': 'STANDING_ROOM_ONLY', '2': 3},
    {'1': 'CRUSHED_STANDING_ROOM_ONLY', '2': 4},
    {'1': 'FULL', '2': 5},
  ],
};

@$core.Deprecated('Use carriageDescriptorDescriptor instead')
const CarriageDescriptor_ToiletStatus$json = {
  '1': 'ToiletStatus',
  '2': [
    {'1': 'NONE', '2': 0},
    {'1': 'NORMAL', '2': 1},
    {'1': 'ACCESSIBLE', '2': 2},
  ],
};

/// Descriptor for `CarriageDescriptor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List carriageDescriptorDescriptor = $convert.base64Decode(
    'ChJDYXJyaWFnZURlc2NyaXB0b3ISEgoEbmFtZRgBIAEoCVIEbmFtZRIuChNwb3NpdGlvbl9pbl'
    '9jb25zaXN0GAIgAigFUhFwb3NpdGlvbkluQ29uc2lzdBJfChBvY2N1cGFuY3lfc3RhdHVzGAMg'
    'ASgOMjQudHJhbnNpdF9yZWFsdGltZS5DYXJyaWFnZURlc2NyaXB0b3IuT2NjdXBhbmN5U3RhdH'
    'VzUg9vY2N1cGFuY3lTdGF0dXMSLAoOcXVpZXRfY2FycmlhZ2UYBCABKAg6BWZhbHNlUg1xdWll'
    'dENhcnJpYWdlEkkKBnRvaWxldBgFIAEoDjIxLnRyYW5zaXRfcmVhbHRpbWUuQ2FycmlhZ2VEZX'
    'NjcmlwdG9yLlRvaWxldFN0YXR1c1IGdG9pbGV0EigKDGx1Z2dhZ2VfcmFjaxgGIAEoCDoFZmFs'
    'c2VSC2x1Z2dhZ2VSYWNrEnIKGmRlcGFydHVyZV9vY2N1cGFuY3lfc3RhdHVzGAcgASgOMjQudH'
    'JhbnNpdF9yZWFsdGltZS5DYXJyaWFnZURlc2NyaXB0b3IuT2NjdXBhbmN5U3RhdHVzUhhkZXBh'
    'cnR1cmVPY2N1cGFuY3lTdGF0dXMikQEKD09jY3VwYW5jeVN0YXR1cxIJCgVFTVBUWRAAEhgKFE'
    '1BTllfU0VBVFNfQVZBSUxBQkxFEAESFwoTRkVXX1NFQVRTX0FWQUlMQUJMRRACEhYKElNUQU5E'
    'SU5HX1JPT01fT05MWRADEh4KGkNSVVNIRURfU1RBTkRJTkdfUk9PTV9PTkxZEAQSCAoERlVMTB'
    'AFIjQKDFRvaWxldFN0YXR1cxIICgROT05FEAASCgoGTk9STUFMEAESDgoKQUNDRVNTSUJMRRAC'
    'KgYI6AcQ0A8=');

