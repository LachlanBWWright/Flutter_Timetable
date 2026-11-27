// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum V3StatusHealth {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1);

  final int? value;

  const V3StatusHealth(this.value);
}

enum V3DeparturesBroadParametersExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3DeparturesBroadParametersExpand(this.value);
}

enum V3RunExternalService {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(8)
  value_8(8),
  @JsonValue(9)
  value_9(9),
  @JsonValue(10)
  value_10(10);

  final int? value;

  const V3RunExternalService(this.value);
}

enum V3DeparturesSpecificParametersExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3DeparturesSpecificParametersExpand(this.value);
}

enum V3RouteDeparturesSpecificParametersExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3RouteDeparturesSpecificParametersExpand(this.value);
}

enum V3BulkDeparturesRequestExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3BulkDeparturesRequestExpand(this.value);
}

enum V3StopDepartureRequestRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3StopDepartureRequestRouteType(this.value);
}

enum V3FareEstimateParametersTravelledRouteTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3FareEstimateParametersTravelledRouteTypes(this.value);
}

enum V3JourneyPlannerLocationRouteTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3JourneyPlannerLocationRouteTypes(this.value);
}

enum V3PatternsParametersExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3PatternsParametersExpand(this.value);
}

enum V3RunsBroadParametersExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3RunsBroadParametersExpand(this.value);
}

enum V3RunsSpecificParametersExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3RunsSpecificParametersExpand(this.value);
}

enum V3RunAndRouteTypeParametersExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3RunAndRouteTypeParametersExpand(this.value);
}

enum V3SearchParametersRouteTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3SearchParametersRouteTypes(this.value);
}

enum V3SiriLineRefDirectionRefStopPointRefDirectionRef {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(5)
  value_5(5),
  @JsonValue(10)
  value_10(10),
  @JsonValue(16)
  value_16(16),
  @JsonValue(32)
  value_32(32),
  @JsonValue(65)
  value_65(65),
  @JsonValue(130)
  value_130(130);

  final int? value;

  const V3SiriLineRefDirectionRefStopPointRefDirectionRef(this.value);
}

enum V3SiriReferenceDataDetailNoMatchReason {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5);

  final int? value;

  const V3SiriReferenceDataDetailNoMatchReason(this.value);
}

enum V3SiriLineRefDirectionRef {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(5)
  value_5(5),
  @JsonValue(10)
  value_10(10),
  @JsonValue(16)
  value_16(16),
  @JsonValue(32)
  value_32(32),
  @JsonValue(65)
  value_65(65),
  @JsonValue(130)
  value_130(130);

  final int? value;

  const V3SiriLineRefDirectionRef(this.value);
}

enum V3DynamoDbTimetableTransportType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3DynamoDbTimetableTransportType(this.value);
}

enum V3SiriDownstreamSubscriptionMessageType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1);

  final int? value;

  const V3SiriDownstreamSubscriptionMessageType(this.value);
}

enum V3SiriDownstreamSubscriptionSiriFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1);

  final int? value;

  const V3SiriDownstreamSubscriptionSiriFormat(this.value);
}

enum V3SiriDownstreamSubscriptionTopicDirectionRef {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(5)
  value_5(5),
  @JsonValue(10)
  value_10(10),
  @JsonValue(16)
  value_16(16),
  @JsonValue(32)
  value_32(32),
  @JsonValue(65)
  value_65(65),
  @JsonValue(130)
  value_130(130);

  final int? value;

  const V3SiriDownstreamSubscriptionTopicDirectionRef(this.value);
}

enum V3SiriDownstreamSubscriptionTopicRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3SiriDownstreamSubscriptionTopicRouteType(this.value);
}

enum V3SiriProductionTimetableSubscriptionRequestSiriFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1);

  final int? value;

  const V3SiriProductionTimetableSubscriptionRequestSiriFormat(this.value);
}

enum V3SiriSubscriptionTopicDirectionRef {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(5)
  value_5(5),
  @JsonValue(10)
  value_10(10),
  @JsonValue(16)
  value_16(16),
  @JsonValue(32)
  value_32(32),
  @JsonValue(65)
  value_65(65),
  @JsonValue(130)
  value_130(130);

  final int? value;

  const V3SiriSubscriptionTopicDirectionRef(this.value);
}

enum V3SiriSubscriptionTopicRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3SiriSubscriptionTopicRouteType(this.value);
}

enum V3SiriEstimatedTimetableSubscriptionRequestSiriFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1);

  final int? value;

  const V3SiriEstimatedTimetableSubscriptionRequestSiriFormat(this.value);
}

enum V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('3')
  value_3('3'),
  @JsonValue('4')
  value_4('4');

  final String? value;

  const V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType(this.value);
}

enum V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3DeparturesRouteTypeRouteTypeStopStopIdGetExpand(this.value);
}

enum V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('3')
  value_3('3'),
  @JsonValue('4')
  value_4('4');

  final String? value;

  const V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetRouteType(
    this.value,
  );
}

enum V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3DeparturesRouteTypeRouteTypeStopStopIdRouteRouteIdGetExpand(
    this.value,
  );
}

enum V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('3')
  value_3('3'),
  @JsonValue('4')
  value_4('4');

  final String? value;

  const V3DirectionsDirectionIdRouteTypeRouteTypeGetRouteType(this.value);
}

enum V3DisruptionsGetRouteTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3DisruptionsGetRouteTypes(this.value);
}

enum V3DisruptionsGetDisruptionModes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(7)
  value_7(7),
  @JsonValue(8)
  value_8(8),
  @JsonValue(9)
  value_9(9),
  @JsonValue(10)
  value_10(10),
  @JsonValue(11)
  value_11(11),
  @JsonValue(12)
  value_12(12),
  @JsonValue(13)
  value_13(13),
  @JsonValue(14)
  value_14(14),
  @JsonValue(100)
  value_100(100);

  final int? value;

  const V3DisruptionsGetDisruptionModes(this.value);
}

enum V3DisruptionsGetDisruptionStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1');

  final String? value;

  const V3DisruptionsGetDisruptionStatus(this.value);
}

enum V3DisruptionsRouteRouteIdGetDisruptionStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1');

  final String? value;

  const V3DisruptionsRouteRouteIdGetDisruptionStatus(this.value);
}

enum V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1');

  final String? value;

  const V3DisruptionsRouteRouteIdStopStopIdGetDisruptionStatus(this.value);
}

enum V3DisruptionsStopStopIdGetDisruptionStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1');

  final String? value;

  const V3DisruptionsStopStopIdGetDisruptionStatus(this.value);
}

enum V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3FareEstimateMinZoneMinZoneMaxZoneMaxZoneGetTravelledRouteTypes(
    this.value,
  );
}

enum V3PatternRunRunRefRouteTypeRouteTypeGetRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('3')
  value_3('3'),
  @JsonValue('4')
  value_4('4');

  final String? value;

  const V3PatternRunRunRefRouteTypeRouteTypeGetRouteType(this.value);
}

enum V3PatternRunRunRefRouteTypeRouteTypeGetExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4),
  @JsonValue(5)
  value_5(5),
  @JsonValue(6)
  value_6(6),
  @JsonValue(7)
  value_7(7),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3PatternRunRunRefRouteTypeRouteTypeGetExpand(this.value);
}

enum V3RoutesGetRouteTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3RoutesGetRouteTypes(this.value);
}

enum V3RunsRouteRouteIdGetExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3RunsRouteRouteIdGetExpand(this.value);
}

enum V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('3')
  value_3('3'),
  @JsonValue('4')
  value_4('4');

  final String? value;

  const V3RunsRouteRouteIdRouteTypeRouteTypeGetRouteType(this.value);
}

enum V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3RunsRouteRouteIdRouteTypeRouteTypeGetExpand(this.value);
}

enum V3RunsRunRefGetExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3RunsRunRefGetExpand(this.value);
}

enum V3RunsRunRefRouteTypeRouteTypeGetRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('3')
  value_3('3'),
  @JsonValue('4')
  value_4('4');

  final String? value;

  const V3RunsRunRefRouteTypeRouteTypeGetRouteType(this.value);
}

enum V3RunsRunRefRouteTypeRouteTypeGetExpand {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(2147483647)
  value_2147483647(2147483647);

  final int? value;

  const V3RunsRunRefRouteTypeRouteTypeGetExpand(this.value);
}

enum V3SearchSearchTermGetRouteTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3SearchSearchTermGetRouteTypes(this.value);
}

enum V3StopsStopIdRouteTypeRouteTypeGetRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('3')
  value_3('3'),
  @JsonValue('4')
  value_4('4');

  final String? value;

  const V3StopsStopIdRouteTypeRouteTypeGetRouteType(this.value);
}

enum V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('0')
  value_0('0'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('3')
  value_3('3'),
  @JsonValue('4')
  value_4('4');

  final String? value;

  const V3StopsRouteRouteIdRouteTypeRouteTypeGetRouteType(this.value);
}

enum V3StopsLocationLatitudeLongitudeGetRouteTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(0)
  value_0(0),
  @JsonValue(1)
  value_1(1),
  @JsonValue(2)
  value_2(2),
  @JsonValue(3)
  value_3(3),
  @JsonValue(4)
  value_4(4);

  final int? value;

  const V3StopsLocationLatitudeLongitudeGetRouteTypes(this.value);
}
