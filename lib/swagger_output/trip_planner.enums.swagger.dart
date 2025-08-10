import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum AdditionalInfoResponseAffectedLine$DestinationType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb'),
  @JsonValue('gisPoint')
  gispoint('gisPoint'),
  @JsonValue('unknown')
  unknown('unknown');

  final String? value;

  const AdditionalInfoResponseAffectedLine$DestinationType(this.value);
}

enum AdditionalInfoResponseAffectedStopType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb'),
  @JsonValue('gisPoint')
  gispoint('gisPoint'),
  @JsonValue('unknown')
  unknown('unknown');

  final String? value;

  const AdditionalInfoResponseAffectedStopType(this.value);
}

enum AdditionalInfoResponseMessagePriority {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('veryLow')
  verylow('veryLow'),
  @JsonValue('low')
  low('low'),
  @JsonValue('normal')
  normal('normal'),
  @JsonValue('high')
  high('high'),
  @JsonValue('veryHigh')
  veryhigh('veryHigh');

  final String? value;

  const AdditionalInfoResponseMessagePriority(this.value);
}

enum AdditionalInfoResponseMessageType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('routeInfo')
  routeinfo('routeInfo'),
  @JsonValue('stopInfo')
  stopinfo('stopInfo'),
  @JsonValue('lineInfo')
  lineinfo('lineInfo'),
  @JsonValue('bannerInfo')
  bannerinfo('bannerInfo'),
  @JsonValue('stopBlocking')
  stopblocking('stopBlocking');

  final String? value;

  const AdditionalInfoResponseMessageType(this.value);
}

enum CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('POINT')
  point('POINT');

  final String? value;

  const CoordRequestResponseLocation$PropertiesGISDRAWCLASSTYPE(this.value);
}

enum CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('POINT')
  point('POINT');

  final String? value;

  const CoordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPE(this.value);
}

enum CoordRequestResponseLocationType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb'),
  @JsonValue('gisPoint')
  gispoint('gisPoint'),
  @JsonValue('unknown')
  unknown('unknown');

  final String? value;

  const CoordRequestResponseLocationType(this.value);
}

enum ParentLocationType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb'),
  @JsonValue('unknown')
  unknown('unknown');

  final String? value;

  const ParentLocationType(this.value);
}

enum StopFinderAssignedStopType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb'),
  @JsonValue('unknown')
  unknown('unknown');

  final String? value;

  const StopFinderAssignedStopType(this.value);
}

enum StopFinderLocationType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb'),
  @JsonValue('address')
  address('address'),
  @JsonValue('unknown')
  unknown('unknown');

  final String? value;

  const StopFinderLocationType(this.value);
}

enum TripRequestResponseJourneyLegInterchangeType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue(99)
  value_99(99),
  @JsonValue(100)
  value_100(100);

  final int? value;

  const TripRequestResponseJourneyLegInterchangeType(this.value);
}

enum TripRequestResponseJourneyLegPathDescriptionManoeuvre {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('LEAVE')
  leave('LEAVE'),
  @JsonValue('KEEP')
  keep('KEEP'),
  @JsonValue('TURN')
  turn('TURN'),
  @JsonValue('ENTER')
  enter('ENTER'),
  @JsonValue('CONTINUE')
  $continue('CONTINUE');

  final String? value;

  const TripRequestResponseJourneyLegPathDescriptionManoeuvre(this.value);
}

enum TripRequestResponseJourneyLegPathDescriptionTurnDirection {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('UNKNOWN')
  unknown('UNKNOWN'),
  @JsonValue('STRAIGHT')
  straight('STRAIGHT'),
  @JsonValue('RIGHT')
  right('RIGHT'),
  @JsonValue('LEFT')
  left('LEFT'),
  @JsonValue('SLIGHT_RIGHT')
  slightRight('SLIGHT_RIGHT'),
  @JsonValue('SLIGHT_LEFT')
  slightLeft('SLIGHT_LEFT'),
  @JsonValue('SHARP_LEFT')
  sharpLeft('SHARP_LEFT'),
  @JsonValue('SHARP_RIGHT')
  sharpRight('SHARP_RIGHT');

  final String? value;

  const TripRequestResponseJourneyLegPathDescriptionTurnDirection(this.value);
}

enum TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('true')
  $true('true'),
  @JsonValue('false')
  $false('false');

  final String? value;

  const TripRequestResponseJourneyLegStop$PropertiesWheelchairAccess(
      this.value);
}

enum TripRequestResponseJourneyLegStopType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb'),
  @JsonValue('unknown')
  unknown('unknown');

  final String? value;

  const TripRequestResponseJourneyLegStopType(this.value);
}

enum TripRequestResponseJourneyLegStopFootpathInfoPosition {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('BEFORE')
  before('BEFORE'),
  @JsonValue('AFTER')
  after('AFTER'),
  @JsonValue('IDEST')
  idest('IDEST');

  final String? value;

  const TripRequestResponseJourneyLegStopFootpathInfoPosition(this.value);
}

enum TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('DOWN')
  down('DOWN'),
  @JsonValue('LEVEL')
  level('LEVEL'),
  @JsonValue('UP')
  up('UP');

  final String? value;

  const TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevel(
      this.value);
}

enum TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('ESCALATOR')
  escalator('ESCALATOR'),
  @JsonValue('ELEVATOR')
  elevator('ELEVATOR'),
  @JsonValue('STAIRS')
  stairs('STAIRS'),
  @JsonValue('LEVEL')
  level('LEVEL'),
  @JsonValue('RAMP')
  ramp('RAMP');

  final String? value;

  const TripRequestResponseJourneyLegStopFootpathInfoFootpathElemType(
      this.value);
}

enum TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb'),
  @JsonValue('unknown')
  unknown('unknown');

  final String? value;

  const TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationType(
      this.value);
}

enum TripRequestResponseJourneyLegStopInfoPriority {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('veryLow')
  verylow('veryLow'),
  @JsonValue('low')
  low('low'),
  @JsonValue('normal')
  normal('normal'),
  @JsonValue('high')
  high('high'),
  @JsonValue('veryHigh')
  veryhigh('veryHigh');

  final String? value;

  const TripRequestResponseJourneyLegStopInfoPriority(this.value);
}

enum AddInfoGetOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('rapidJSON')
  rapidjson('rapidJSON');

  final String? value;

  const AddInfoGetOutputFormat(this.value);
}

enum AddInfoGetFilterMOTType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('4')
  value_4('4'),
  @JsonValue('5')
  value_5('5'),
  @JsonValue('7')
  value_7('7'),
  @JsonValue('9')
  value_9('9'),
  @JsonValue('11')
  value_11('11');

  final String? value;

  const AddInfoGetFilterMOTType(this.value);
}

enum AddInfoGetFilterPublicationStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('current')
  current('current');

  final String? value;

  const AddInfoGetFilterPublicationStatus(this.value);
}

enum CoordGetOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('rapidJSON')
  rapidjson('rapidJSON');

  final String? value;

  const CoordGetOutputFormat(this.value);
}

enum CoordGetCoordOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('EPSG:4326')
  epsg4326('EPSG:4326');

  final String? value;

  const CoordGetCoordOutputFormat(this.value);
}

enum CoordGetInclFilter {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const CoordGetInclFilter(this.value);
}

enum CoordGetType1 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('GIS_POINT')
  gisPoint('GIS_POINT'),
  @JsonValue('BUS_POINT')
  busPoint('BUS_POINT'),
  @JsonValue('POI_POINT')
  poiPoint('POI_POINT');

  final String? value;

  const CoordGetType1(this.value);
}

enum CoordGetInclDrawClasses1 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('74')
  value_74('74');

  final String? value;

  const CoordGetInclDrawClasses1(this.value);
}

enum CoordGetPoisOnMapMacro {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('true')
  $true('true');

  final String? value;

  const CoordGetPoisOnMapMacro(this.value);
}

enum DepartureMonGetOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('rapidJSON')
  rapidjson('rapidJSON');

  final String? value;

  const DepartureMonGetOutputFormat(this.value);
}

enum DepartureMonGetCoordOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('EPSG:4326')
  epsg4326('EPSG:4326');

  final String? value;

  const DepartureMonGetCoordOutputFormat(this.value);
}

enum DepartureMonGetMode {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('direct')
  direct('direct');

  final String? value;

  const DepartureMonGetMode(this.value);
}

enum DepartureMonGetTypeDm {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('any')
  any('any'),
  @JsonValue('coord')
  coord('coord'),
  @JsonValue('poi')
  poi('poi'),
  @JsonValue('singlehouse')
  singlehouse('singlehouse'),
  @JsonValue('stop')
  stop('stop'),
  @JsonValue('platform')
  platform('platform'),
  @JsonValue('street')
  street('street'),
  @JsonValue('locality')
  locality('locality'),
  @JsonValue('suburb')
  suburb('suburb');

  final String? value;

  const DepartureMonGetTypeDm(this.value);
}

enum DepartureMonGetNameKeyDm {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('\$USEPOINT\$')
  usepoint('\$USEPOINT\$');

  final String? value;

  const DepartureMonGetNameKeyDm(this.value);
}

enum DepartureMonGetDepartureMonitorMacro {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('true')
  $true('true');

  final String? value;

  const DepartureMonGetDepartureMonitorMacro(this.value);
}

enum DepartureMonGetExcludedMeans {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('checkbox')
  checkbox('checkbox'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('4')
  value_4('4'),
  @JsonValue('5')
  value_5('5'),
  @JsonValue('7')
  value_7('7'),
  @JsonValue('9')
  value_9('9'),
  @JsonValue('11')
  value_11('11');

  final String? value;

  const DepartureMonGetExcludedMeans(this.value);
}

enum DepartureMonGetExclMOT1 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const DepartureMonGetExclMOT1(this.value);
}

enum DepartureMonGetExclMOT2 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const DepartureMonGetExclMOT2(this.value);
}

enum DepartureMonGetExclMOT4 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const DepartureMonGetExclMOT4(this.value);
}

enum DepartureMonGetExclMOT5 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const DepartureMonGetExclMOT5(this.value);
}

enum DepartureMonGetExclMOT7 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const DepartureMonGetExclMOT7(this.value);
}

enum DepartureMonGetExclMOT9 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const DepartureMonGetExclMOT9(this.value);
}

enum DepartureMonGetExclMOT11 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const DepartureMonGetExclMOT11(this.value);
}

enum DepartureMonGetTfNSWDM {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('true')
  $true('true');

  final String? value;

  const DepartureMonGetTfNSWDM(this.value);
}

enum StopFinderGetOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('rapidJSON')
  rapidjson('rapidJSON');

  final String? value;

  const StopFinderGetOutputFormat(this.value);
}

enum StopFinderGetTypeSf {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('any')
  any('any'),
  @JsonValue('coord')
  coord('coord'),
  @JsonValue('poi')
  poi('poi'),
  @JsonValue('stop')
  stop('stop');

  final String? value;

  const StopFinderGetTypeSf(this.value);
}

enum StopFinderGetCoordOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('EPSG:4326')
  epsg4326('EPSG:4326');

  final String? value;

  const StopFinderGetCoordOutputFormat(this.value);
}

enum StopFinderGetTfNSWSF {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('true')
  $true('true');

  final String? value;

  const StopFinderGetTfNSWSF(this.value);
}

enum TripGetOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('rapidJSON')
  rapidjson('rapidJSON');

  final String? value;

  const TripGetOutputFormat(this.value);
}

enum TripGetCoordOutputFormat {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('EPSG:4326')
  epsg4326('EPSG:4326');

  final String? value;

  const TripGetCoordOutputFormat(this.value);
}

enum TripGetDepArrMacro {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('dep')
  dep('dep'),
  @JsonValue('arr')
  arr('arr');

  final String? value;

  const TripGetDepArrMacro(this.value);
}

enum TripGetTypeOrigin {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('any')
  any('any'),
  @JsonValue('coord')
  coord('coord');

  final String? value;

  const TripGetTypeOrigin(this.value);
}

enum TripGetTypeDestination {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('any')
  any('any'),
  @JsonValue('coord')
  coord('coord');

  final String? value;

  const TripGetTypeDestination(this.value);
}

enum TripGetWheelchair {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('on')
  on('on');

  final String? value;

  const TripGetWheelchair(this.value);
}

enum TripGetExcludedMeans {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('checkbox')
  checkbox('checkbox'),
  @JsonValue('1')
  value_1('1'),
  @JsonValue('2')
  value_2('2'),
  @JsonValue('4')
  value_4('4'),
  @JsonValue('5')
  value_5('5'),
  @JsonValue('7')
  value_7('7'),
  @JsonValue('9')
  value_9('9'),
  @JsonValue('11')
  value_11('11');

  final String? value;

  const TripGetExcludedMeans(this.value);
}

enum TripGetExclMOT1 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const TripGetExclMOT1(this.value);
}

enum TripGetExclMOT2 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const TripGetExclMOT2(this.value);
}

enum TripGetExclMOT4 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const TripGetExclMOT4(this.value);
}

enum TripGetExclMOT5 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const TripGetExclMOT5(this.value);
}

enum TripGetExclMOT7 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const TripGetExclMOT7(this.value);
}

enum TripGetExclMOT9 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const TripGetExclMOT9(this.value);
}

enum TripGetExclMOT11 {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('1')
  value_1('1');

  final String? value;

  const TripGetExclMOT11(this.value);
}

enum TripGetTfNSWTR {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('true')
  $true('true');

  final String? value;

  const TripGetTfNSWTR(this.value);
}

enum TripGetBikeProfSpeed {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('EASIER')
  easier('EASIER'),
  @JsonValue('MODERATE')
  moderate('MODERATE'),
  @JsonValue('MOST_DIRECT')
  mostDirect('MOST_DIRECT');

  final String? value;

  const TripGetBikeProfSpeed(this.value);
}
