// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_planner.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdditionalInfoResponse _$AdditionalInfoResponseFromJson(
        Map<String, dynamic> json) =>
    AdditionalInfoResponse(
      error: json['error'] == null
          ? null
          : ApiErrorResponse.fromJson(json['error'] as Map<String, dynamic>),
      infos: json['infos'] == null
          ? null
          : AdditionalInfoResponse$Infos.fromJson(
              json['infos'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String?,
      version: json['version'] as String?,
    );

Map<String, dynamic> _$AdditionalInfoResponseToJson(
        AdditionalInfoResponse instance) =>
    <String, dynamic>{
      'error': instance.error?.toJson(),
      'infos': instance.infos?.toJson(),
      'timestamp': instance.timestamp,
      'version': instance.version,
    };

AdditionalInfoResponseAffectedLine _$AdditionalInfoResponseAffectedLineFromJson(
        Map<String, dynamic> json) =>
    AdditionalInfoResponseAffectedLine(
      destination: json['destination'] == null
          ? null
          : AdditionalInfoResponseAffectedLine$Destination.fromJson(
              json['destination'] as Map<String, dynamic>),
      id: json['id'] as String?,
      name: json['name'] as String?,
      number: json['number'] as String?,
      product: json['product'] == null
          ? null
          : RouteProduct.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdditionalInfoResponseAffectedLineToJson(
        AdditionalInfoResponseAffectedLine instance) =>
    <String, dynamic>{
      'destination': instance.destination?.toJson(),
      'id': instance.id,
      'name': instance.name,
      'number': instance.number,
      'product': instance.product?.toJson(),
    };

AdditionalInfoResponseAffectedStop _$AdditionalInfoResponseAffectedStopFromJson(
        Map<String, dynamic> json) =>
    AdditionalInfoResponseAffectedStop(
      id: json['id'] as String?,
      name: json['name'] as String?,
      parent: json['parent'] == null
          ? null
          : ParentLocation.fromJson(json['parent'] as Map<String, dynamic>),
      type:
          additionalInfoResponseAffectedStopTypeNullableFromJson(json['type']),
    );

Map<String, dynamic> _$AdditionalInfoResponseAffectedStopToJson(
        AdditionalInfoResponseAffectedStop instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parent': instance.parent?.toJson(),
      'type':
          additionalInfoResponseAffectedStopTypeNullableToJson(instance.type),
    };

AdditionalInfoResponseMessage _$AdditionalInfoResponseMessageFromJson(
        Map<String, dynamic> json) =>
    AdditionalInfoResponseMessage(
      affected: json['affected'] == null
          ? null
          : AdditionalInfoResponseMessage$Affected.fromJson(
              json['affected'] as Map<String, dynamic>),
      content: json['content'] as String?,
      id: json['id'] as String?,
      priority: additionalInfoResponseMessagePriorityNullableFromJson(
          json['priority']),
      properties: json['properties'] == null
          ? null
          : AdditionalInfoResponseMessage$Properties.fromJson(
              json['properties'] as Map<String, dynamic>),
      subtitle: json['subtitle'] as String?,
      timestamps: json['timestamps'] == null
          ? null
          : AdditionalInfoResponseTimestamps.fromJson(
              json['timestamps'] as Map<String, dynamic>),
      type: additionalInfoResponseMessageTypeNullableFromJson(json['type']),
      url: json['url'] as String?,
      urlText: json['urlText'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdditionalInfoResponseMessageToJson(
        AdditionalInfoResponseMessage instance) =>
    <String, dynamic>{
      'affected': instance.affected?.toJson(),
      'content': instance.content,
      'id': instance.id,
      'priority': additionalInfoResponseMessagePriorityNullableToJson(
          instance.priority),
      'properties': instance.properties?.toJson(),
      'subtitle': instance.subtitle,
      'timestamps': instance.timestamps?.toJson(),
      'type': additionalInfoResponseMessageTypeNullableToJson(instance.type),
      'url': instance.url,
      'urlText': instance.urlText,
      'version': instance.version,
    };

AdditionalInfoResponseTimestamps _$AdditionalInfoResponseTimestampsFromJson(
        Map<String, dynamic> json) =>
    AdditionalInfoResponseTimestamps(
      availability: json['availability'] == null
          ? null
          : AdditionalInfoResponseTimestamps$Availability.fromJson(
              json['availability'] as Map<String, dynamic>),
      creation: json['creation'] as String?,
      lastModification: json['lastModification'] as String?,
      validity: (json['validity'] as List<dynamic>?)
          ?.map((e) => AdditionalInfoResponseTimestamps$Validity$Item.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdditionalInfoResponseTimestampsToJson(
        AdditionalInfoResponseTimestamps instance) =>
    <String, dynamic>{
      'availability': instance.availability?.toJson(),
      'creation': instance.creation,
      'lastModification': instance.lastModification,
      'validity': instance.validity?.map((e) => e.toJson()).toList(),
    };

ApiErrorResponse _$ApiErrorResponseFromJson(Map<String, dynamic> json) =>
    ApiErrorResponse(
      message: json['message'] as String?,
      versions: json['versions'] == null
          ? null
          : ApiErrorResponse$Versions.fromJson(
              json['versions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ApiErrorResponseToJson(ApiErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'versions': instance.versions?.toJson(),
    };

CoordRequestResponse _$CoordRequestResponseFromJson(
        Map<String, dynamic> json) =>
    CoordRequestResponse(
      error: json['error'] == null
          ? null
          : ApiErrorResponse.fromJson(json['error'] as Map<String, dynamic>),
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => CoordRequestResponseLocation.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      version: json['version'] as String?,
    );

Map<String, dynamic> _$CoordRequestResponseToJson(
        CoordRequestResponse instance) =>
    <String, dynamic>{
      'error': instance.error?.toJson(),
      'locations': instance.locations?.map((e) => e.toJson()).toList(),
      'version': instance.version,
    };

CoordRequestResponseLocation _$CoordRequestResponseLocationFromJson(
        Map<String, dynamic> json) =>
    CoordRequestResponseLocation(
      coord: (json['coord'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      disassembledName: json['disassembledName'] as String?,
      id: json['id'] as String?,
      name: json['name'] as String?,
      parent: json['parent'] == null
          ? null
          : ParentLocation.fromJson(json['parent'] as Map<String, dynamic>),
      properties: json['properties'] == null
          ? null
          : CoordRequestResponseLocation$Properties.fromJson(
              json['properties'] as Map<String, dynamic>),
      type: coordRequestResponseLocationTypeNullableFromJson(json['type']),
    );

Map<String, dynamic> _$CoordRequestResponseLocationToJson(
        CoordRequestResponseLocation instance) =>
    <String, dynamic>{
      'coord': instance.coord,
      'disassembledName': instance.disassembledName,
      'id': instance.id,
      'name': instance.name,
      'parent': instance.parent?.toJson(),
      'properties': instance.properties?.toJson(),
      'type': coordRequestResponseLocationTypeNullableToJson(instance.type),
    };

DepartureMonitorResponse _$DepartureMonitorResponseFromJson(
        Map<String, dynamic> json) =>
    DepartureMonitorResponse(
      error: json['error'] == null
          ? null
          : ApiErrorResponse.fromJson(json['error'] as Map<String, dynamic>),
      locations: (json['locations'] as List<dynamic>?)
              ?.map(
                  (e) => StopFinderLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stopEvents: (json['stopEvents'] as List<dynamic>?)
              ?.map((e) => DepartureMonitorResponseStopEvent.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      version: json['version'] as String?,
    );

Map<String, dynamic> _$DepartureMonitorResponseToJson(
        DepartureMonitorResponse instance) =>
    <String, dynamic>{
      'error': instance.error?.toJson(),
      'locations': instance.locations?.map((e) => e.toJson()).toList(),
      'stopEvents': instance.stopEvents?.map((e) => e.toJson()).toList(),
      'version': instance.version,
    };

DepartureMonitorResponseStopEvent _$DepartureMonitorResponseStopEventFromJson(
        Map<String, dynamic> json) =>
    DepartureMonitorResponseStopEvent(
      departureTimePlanned: json['departureTimePlanned'] as String?,
      infos: (json['infos'] as List<dynamic>?)
              ?.map((e) => TripRequestResponseJourneyLegStopInfo.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      location: json['location'] == null
          ? null
          : StopFinderLocation.fromJson(
              json['location'] as Map<String, dynamic>),
      transportation: json['transportation'] == null
          ? null
          : TripTransportation.fromJson(
              json['transportation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DepartureMonitorResponseStopEventToJson(
        DepartureMonitorResponseStopEvent instance) =>
    <String, dynamic>{
      'departureTimePlanned': instance.departureTimePlanned,
      'infos': instance.infos?.map((e) => e.toJson()).toList(),
      'location': instance.location?.toJson(),
      'transportation': instance.transportation?.toJson(),
    };

HttpErrorResponse _$HttpErrorResponseFromJson(Map<String, dynamic> json) =>
    HttpErrorResponse(
      errorDateTime: json['ErrorDateTime'] as String?,
      message: json['Message'] as String?,
      requestedMethod: json['RequestedMethod'] as String?,
      requestedUrl: json['RequestedUrl'] as String?,
      transactionId: json['TransactionId'] as String?,
    );

Map<String, dynamic> _$HttpErrorResponseToJson(HttpErrorResponse instance) =>
    <String, dynamic>{
      'ErrorDateTime': instance.errorDateTime,
      'Message': instance.message,
      'RequestedMethod': instance.requestedMethod,
      'RequestedUrl': instance.requestedUrl,
      'TransactionId': instance.transactionId,
    };

ParentLocation _$ParentLocationFromJson(Map<String, dynamic> json) =>
    ParentLocation(
      disassembledName: json['disassembledName'] as String?,
      id: json['id'] as String?,
      name: json['name'] as String?,
      parent: json['parent'] == null
          ? null
          : ParentLocation.fromJson(json['parent'] as Map<String, dynamic>),
      type: parentLocationTypeNullableFromJson(json['type']),
    );

Map<String, dynamic> _$ParentLocationToJson(ParentLocation instance) =>
    <String, dynamic>{
      'disassembledName': instance.disassembledName,
      'id': instance.id,
      'name': instance.name,
      'parent': instance.parent?.toJson(),
      'type': parentLocationTypeNullableToJson(instance.type),
    };

RouteProduct _$RouteProductFromJson(Map<String, dynamic> json) => RouteProduct(
      $class: (json['class'] as num?)?.toInt(),
      iconId: (json['iconId'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$RouteProductToJson(RouteProduct instance) =>
    <String, dynamic>{
      'class': instance.$class,
      'iconId': instance.iconId,
      'name': instance.name,
    };

StopFinderAssignedStop _$StopFinderAssignedStopFromJson(
        Map<String, dynamic> json) =>
    StopFinderAssignedStop(
      connectingMode: (json['connectingMode'] as num?)?.toInt(),
      coord: (json['coord'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      disassembledName: json['disassembledName'] as String?,
      distance: (json['distance'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      id: json['id'] as String?,
      modes: (json['modes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      name: json['name'] as String?,
      parent: json['parent'] == null
          ? null
          : ParentLocation.fromJson(json['parent'] as Map<String, dynamic>),
      type: stopFinderAssignedStopTypeNullableFromJson(json['type']),
    );

Map<String, dynamic> _$StopFinderAssignedStopToJson(
        StopFinderAssignedStop instance) =>
    <String, dynamic>{
      'connectingMode': instance.connectingMode,
      'coord': instance.coord,
      'disassembledName': instance.disassembledName,
      'distance': instance.distance,
      'duration': instance.duration,
      'id': instance.id,
      'modes': instance.modes,
      'name': instance.name,
      'parent': instance.parent?.toJson(),
      'type': stopFinderAssignedStopTypeNullableToJson(instance.type),
    };

StopFinderLocation _$StopFinderLocationFromJson(Map<String, dynamic> json) =>
    StopFinderLocation(
      assignedStops: (json['assignedStops'] as List<dynamic>?)
              ?.map((e) =>
                  StopFinderAssignedStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      buildingNumber: json['buildingNumber'] as String?,
      coord: (json['coord'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      disassembledName: json['disassembledName'] as String?,
      id: json['id'] as String?,
      isBest: json['isBest'] as bool?,
      isGlobalId: json['isGlobalId'] as bool?,
      matchQuality: (json['matchQuality'] as num?)?.toInt(),
      modes: (json['modes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      name: json['name'] as String?,
      parent: json['parent'] == null
          ? null
          : ParentLocation.fromJson(json['parent'] as Map<String, dynamic>),
      streetName: json['streetName'] as String?,
      type: stopFinderLocationTypeNullableFromJson(json['type']),
    );

Map<String, dynamic> _$StopFinderLocationToJson(StopFinderLocation instance) =>
    <String, dynamic>{
      'assignedStops': instance.assignedStops?.map((e) => e.toJson()).toList(),
      'buildingNumber': instance.buildingNumber,
      'coord': instance.coord,
      'disassembledName': instance.disassembledName,
      'id': instance.id,
      'isBest': instance.isBest,
      'isGlobalId': instance.isGlobalId,
      'matchQuality': instance.matchQuality,
      'modes': instance.modes,
      'name': instance.name,
      'parent': instance.parent?.toJson(),
      'streetName': instance.streetName,
      'type': stopFinderLocationTypeNullableToJson(instance.type),
    };

StopFinderResponse _$StopFinderResponseFromJson(Map<String, dynamic> json) =>
    StopFinderResponse(
      error: json['error'] == null
          ? null
          : ApiErrorResponse.fromJson(json['error'] as Map<String, dynamic>),
      locations: (json['locations'] as List<dynamic>?)
              ?.map(
                  (e) => StopFinderLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      version: json['version'] as String?,
    );

Map<String, dynamic> _$StopFinderResponseToJson(StopFinderResponse instance) =>
    <String, dynamic>{
      'error': instance.error?.toJson(),
      'locations': instance.locations?.map((e) => e.toJson()).toList(),
      'version': instance.version,
    };

TripRequestResponse _$TripRequestResponseFromJson(Map<String, dynamic> json) =>
    TripRequestResponse(
      error: json['error'] == null
          ? null
          : ApiErrorResponse.fromJson(json['error'] as Map<String, dynamic>),
      journeys: (json['journeys'] as List<dynamic>?)
              ?.map((e) => TripRequestResponseJourney.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      systemMessages: json['systemMessages'] == null
          ? null
          : TripRequestResponse$SystemMessages.fromJson(
              json['systemMessages'] as Map<String, dynamic>),
      version: json['version'] as String?,
    );

Map<String, dynamic> _$TripRequestResponseToJson(
        TripRequestResponse instance) =>
    <String, dynamic>{
      'error': instance.error?.toJson(),
      'journeys': instance.journeys?.map((e) => e.toJson()).toList(),
      'systemMessages': instance.systemMessages?.toJson(),
      'version': instance.version,
    };

TripRequestResponseJourney _$TripRequestResponseJourneyFromJson(
        Map<String, dynamic> json) =>
    TripRequestResponseJourney(
      isAdditional: json['isAdditional'] as bool?,
      legs: (json['legs'] as List<dynamic>?)
              ?.map((e) => TripRequestResponseJourneyLeg.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TripRequestResponseJourneyToJson(
        TripRequestResponseJourney instance) =>
    <String, dynamic>{
      'isAdditional': instance.isAdditional,
      'legs': instance.legs?.map((e) => e.toJson()).toList(),
      'rating': instance.rating,
    };

TripRequestResponseJourneyFareZone _$TripRequestResponseJourneyFareZoneFromJson(
        Map<String, dynamic> json) =>
    TripRequestResponseJourneyFareZone(
      fromLeg: (json['fromLeg'] as num?)?.toInt(),
      net: json['net'] as String?,
      neutralZone: json['neutralZone'] as String?,
      toLeg: (json['toLeg'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TripRequestResponseJourneyFareZoneToJson(
        TripRequestResponseJourneyFareZone instance) =>
    <String, dynamic>{
      'fromLeg': instance.fromLeg,
      'net': instance.net,
      'neutralZone': instance.neutralZone,
      'toLeg': instance.toLeg,
    };

TripRequestResponseJourneyLeg _$TripRequestResponseJourneyLegFromJson(
        Map<String, dynamic> json) =>
    TripRequestResponseJourneyLeg(
      coords: (json['coords'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>)
                  .map((e) => (e as num?)?.toDouble())
                  .toList())
              .toList() ??
          [],
      destination: json['destination'] == null
          ? null
          : TripRequestResponseJourneyLegStop.fromJson(
              json['destination'] as Map<String, dynamic>),
      distance: (json['distance'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      footPathInfo: (json['footPathInfo'] as List<dynamic>?)
              ?.map((e) =>
                  TripRequestResponseJourneyLegStopFootpathInfo.fromJson(
                      e as Map<String, dynamic>))
              .toList() ??
          [],
      hints: (json['hints'] as List<dynamic>?)
          ?.map((e) => TripRequestResponseJourneyLeg$Hints$Item.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      infos: (json['infos'] as List<dynamic>?)
              ?.map((e) => TripRequestResponseJourneyLegStopInfo.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      interchange: json['interchange'] == null
          ? null
          : TripRequestResponseJourneyLegInterchange.fromJson(
              json['interchange'] as Map<String, dynamic>),
      isRealtimeControlled: json['isRealtimeControlled'] as bool?,
      origin: json['origin'] == null
          ? null
          : TripRequestResponseJourneyLegStop.fromJson(
              json['origin'] as Map<String, dynamic>),
      pathDescriptions: (json['pathDescriptions'] as List<dynamic>?)
              ?.map((e) =>
                  TripRequestResponseJourneyLegPathDescription.fromJson(
                      e as Map<String, dynamic>))
              .toList() ??
          [],
      properties: json['properties'] == null
          ? null
          : TripRequestResponseJourneyLeg$Properties.fromJson(
              json['properties'] as Map<String, dynamic>),
      stopSequence: (json['stopSequence'] as List<dynamic>?)
              ?.map((e) => TripRequestResponseJourneyLegStop.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      transportation: json['transportation'] == null
          ? null
          : TripTransportation.fromJson(
              json['transportation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TripRequestResponseJourneyLegToJson(
        TripRequestResponseJourneyLeg instance) =>
    <String, dynamic>{
      'coords': instance.coords,
      'destination': instance.destination?.toJson(),
      'distance': instance.distance,
      'duration': instance.duration,
      'footPathInfo': instance.footPathInfo?.map((e) => e.toJson()).toList(),
      'hints': instance.hints?.map((e) => e.toJson()).toList(),
      'infos': instance.infos?.map((e) => e.toJson()).toList(),
      'interchange': instance.interchange?.toJson(),
      'isRealtimeControlled': instance.isRealtimeControlled,
      'origin': instance.origin?.toJson(),
      'pathDescriptions':
          instance.pathDescriptions?.map((e) => e.toJson()).toList(),
      'properties': instance.properties?.toJson(),
      'stopSequence': instance.stopSequence?.map((e) => e.toJson()).toList(),
      'transportation': instance.transportation?.toJson(),
    };

TripRequestResponseJourneyLegInterchange
    _$TripRequestResponseJourneyLegInterchangeFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegInterchange(
          coords: (json['coords'] as List<dynamic>?)
                  ?.map((e) => (e as List<dynamic>)
                      .map((e) => (e as num?)?.toDouble())
                      .toList())
                  .toList() ??
              [],
          desc: json['desc'] as String?,
          type: (json['type'] as num?)?.toInt(),
        );

Map<String, dynamic> _$TripRequestResponseJourneyLegInterchangeToJson(
        TripRequestResponseJourneyLegInterchange instance) =>
    <String, dynamic>{
      'coords': instance.coords,
      'desc': instance.desc,
      'type': instance.type,
    };

TripRequestResponseJourneyLegPathDescription
    _$TripRequestResponseJourneyLegPathDescriptionFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegPathDescription(
          coord: (json['coord'] as List<dynamic>?)
                  ?.map((e) => (e as num).toDouble())
                  .toList() ??
              [],
          cumDistance: (json['cumDistance'] as num?)?.toInt(),
          cumDuration: (json['cumDuration'] as num?)?.toInt(),
          distance: (json['distance'] as num?)?.toInt(),
          distanceDown: (json['distanceDown'] as num?)?.toInt(),
          distanceUp: (json['distanceUp'] as num?)?.toInt(),
          duration: (json['duration'] as num?)?.toInt(),
          fromCoordsIndex: (json['fromCoordsIndex'] as num?)?.toInt(),
          manoeuvre:
              tripRequestResponseJourneyLegPathDescriptionManoeuvreNullableFromJson(
                  json['manoeuvre']),
          name: json['name'] as String?,
          skyDirection: (json['skyDirection'] as num?)?.toInt(),
          toCoordsIndex: (json['toCoordsIndex'] as num?)?.toInt(),
          turnDirection:
              tripRequestResponseJourneyLegPathDescriptionTurnDirectionNullableFromJson(
                  json['turnDirection']),
        );

Map<String, dynamic> _$TripRequestResponseJourneyLegPathDescriptionToJson(
        TripRequestResponseJourneyLegPathDescription instance) =>
    <String, dynamic>{
      'coord': instance.coord,
      'cumDistance': instance.cumDistance,
      'cumDuration': instance.cumDuration,
      'distance': instance.distance,
      'distanceDown': instance.distanceDown,
      'distanceUp': instance.distanceUp,
      'duration': instance.duration,
      'fromCoordsIndex': instance.fromCoordsIndex,
      'manoeuvre':
          tripRequestResponseJourneyLegPathDescriptionManoeuvreNullableToJson(
              instance.manoeuvre),
      'name': instance.name,
      'skyDirection': instance.skyDirection,
      'toCoordsIndex': instance.toCoordsIndex,
      'turnDirection':
          tripRequestResponseJourneyLegPathDescriptionTurnDirectionNullableToJson(
              instance.turnDirection),
    };

TripRequestResponseJourneyLegStop _$TripRequestResponseJourneyLegStopFromJson(
        Map<String, dynamic> json) =>
    TripRequestResponseJourneyLegStop(
      arrivalTimeEstimated: json['arrivalTimeEstimated'] as String?,
      arrivalTimePlanned: json['arrivalTimePlanned'] as String?,
      coord: (json['coord'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      departureTimeEstimated: json['departureTimeEstimated'] as String?,
      departureTimePlanned: json['departureTimePlanned'] as String?,
      disassembledName: json['disassembledName'] as String?,
      id: json['id'] as String?,
      name: json['name'] as String?,
      parent: json['parent'] == null
          ? null
          : ParentLocation.fromJson(json['parent'] as Map<String, dynamic>),
      properties: json['properties'] == null
          ? null
          : TripRequestResponseJourneyLegStop$Properties.fromJson(
              json['properties'] as Map<String, dynamic>),
      type: tripRequestResponseJourneyLegStopTypeNullableFromJson(json['type']),
    );

Map<String, dynamic> _$TripRequestResponseJourneyLegStopToJson(
        TripRequestResponseJourneyLegStop instance) =>
    <String, dynamic>{
      'arrivalTimeEstimated': instance.arrivalTimeEstimated,
      'arrivalTimePlanned': instance.arrivalTimePlanned,
      'coord': instance.coord,
      'departureTimeEstimated': instance.departureTimeEstimated,
      'departureTimePlanned': instance.departureTimePlanned,
      'disassembledName': instance.disassembledName,
      'id': instance.id,
      'name': instance.name,
      'parent': instance.parent?.toJson(),
      'properties': instance.properties?.toJson(),
      'type':
          tripRequestResponseJourneyLegStopTypeNullableToJson(instance.type),
    };

TripRequestResponseJourneyLegStopDownload
    _$TripRequestResponseJourneyLegStopDownloadFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegStopDownload(
          type: json['type'] as String?,
          url: json['url'] as String?,
        );

Map<String, dynamic> _$TripRequestResponseJourneyLegStopDownloadToJson(
        TripRequestResponseJourneyLegStopDownload instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
    };

TripRequestResponseJourneyLegStopFootpathInfo
    _$TripRequestResponseJourneyLegStopFootpathInfoFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegStopFootpathInfo(
          duration: (json['duration'] as num?)?.toInt(),
          footPathElem: (json['footPathElem'] as List<dynamic>?)
                  ?.map((e) =>
                      TripRequestResponseJourneyLegStopFootpathInfoFootpathElem
                          .fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
          position:
              tripRequestResponseJourneyLegStopFootpathInfoPositionNullableFromJson(
                  json['position']),
        );

Map<String, dynamic> _$TripRequestResponseJourneyLegStopFootpathInfoToJson(
        TripRequestResponseJourneyLegStopFootpathInfo instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'footPathElem': instance.footPathElem?.map((e) => e.toJson()).toList(),
      'position':
          tripRequestResponseJourneyLegStopFootpathInfoPositionNullableToJson(
              instance.position),
    };

TripRequestResponseJourneyLegStopFootpathInfoFootpathElem
    _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegStopFootpathInfoFootpathElem(
          description: json['description'] as String?,
          destination: json['destination'] == null
              ? null
              : TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation
                  .fromJson(json['destination'] as Map<String, dynamic>),
          level:
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelNullableFromJson(
                  json['level']),
          levelFrom: (json['levelFrom'] as num?)?.toInt(),
          levelTo: (json['levelTo'] as num?)?.toInt(),
          origin: json['origin'] == null
              ? null
              : TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation
                  .fromJson(json['origin'] as Map<String, dynamic>),
          type:
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeNullableFromJson(
                  json['type']),
        );

Map<String,
    dynamic> _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemToJson(
        TripRequestResponseJourneyLegStopFootpathInfoFootpathElem instance) =>
    <String, dynamic>{
      'description': instance.description,
      'destination': instance.destination?.toJson(),
      'level':
          tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLevelNullableToJson(
              instance.level),
      'levelFrom': instance.levelFrom,
      'levelTo': instance.levelTo,
      'origin': instance.origin?.toJson(),
      'type':
          tripRequestResponseJourneyLegStopFootpathInfoFootpathElemTypeNullableToJson(
              instance.type),
    };

TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation
    _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocationFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation(
          area: (json['area'] as num?)?.toInt(),
          georef: json['georef'] as String?,
          location: json['location'] == null
              ? null
              : TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location
                  .fromJson(json['location'] as Map<String, dynamic>),
          platform: (json['platform'] as num?)?.toInt(),
        );

Map<String, dynamic>
    _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocationToJson(
            TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation
                instance) =>
        <String, dynamic>{
          'area': instance.area,
          'georef': instance.georef,
          'location': instance.location?.toJson(),
          'platform': instance.platform,
        };

TripRequestResponseJourneyLegStopInfo
    _$TripRequestResponseJourneyLegStopInfoFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegStopInfo(
          content: json['content'] as String?,
          id: json['id'] as String?,
          priority:
              tripRequestResponseJourneyLegStopInfoPriorityNullableFromJson(
                  json['priority']),
          subtitle: json['subtitle'] as String?,
          timestamps: json['timestamps'] == null
              ? null
              : AdditionalInfoResponseTimestamps.fromJson(
                  json['timestamps'] as Map<String, dynamic>),
          url: json['url'] as String?,
          urlText: json['urlText'] as String?,
          version: (json['version'] as num?)?.toInt(),
        );

Map<String, dynamic> _$TripRequestResponseJourneyLegStopInfoToJson(
        TripRequestResponseJourneyLegStopInfo instance) =>
    <String, dynamic>{
      'content': instance.content,
      'id': instance.id,
      'priority': tripRequestResponseJourneyLegStopInfoPriorityNullableToJson(
          instance.priority),
      'subtitle': instance.subtitle,
      'timestamps': instance.timestamps?.toJson(),
      'url': instance.url,
      'urlText': instance.urlText,
      'version': instance.version,
    };

TripRequestResponseMessage _$TripRequestResponseMessageFromJson(
        Map<String, dynamic> json) =>
    TripRequestResponseMessage(
      code: (json['code'] as num?)?.toInt(),
      error: json['error'] as String?,
      module: json['module'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TripRequestResponseMessageToJson(
        TripRequestResponseMessage instance) =>
    <String, dynamic>{
      'code': instance.code,
      'error': instance.error,
      'module': instance.module,
      'type': instance.type,
    };

TripTransportation _$TripTransportationFromJson(Map<String, dynamic> json) =>
    TripTransportation(
      description: json['description'] as String?,
      destination: json['destination'] == null
          ? null
          : TripTransportation$Destination.fromJson(
              json['destination'] as Map<String, dynamic>),
      disassembledName: json['disassembledName'] as String?,
      iconId: (json['iconId'] as num?)?.toInt(),
      id: json['id'] as String?,
      name: json['name'] as String?,
      number: json['number'] as String?,
      $operator: json['operator'] == null
          ? null
          : TripTransportation$Operator.fromJson(
              json['operator'] as Map<String, dynamic>),
      product: json['product'] == null
          ? null
          : RouteProduct.fromJson(json['product'] as Map<String, dynamic>),
      properties: json['properties'] == null
          ? null
          : TripTransportation$Properties.fromJson(
              json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TripTransportationToJson(TripTransportation instance) =>
    <String, dynamic>{
      'description': instance.description,
      'destination': instance.destination?.toJson(),
      'disassembledName': instance.disassembledName,
      'iconId': instance.iconId,
      'id': instance.id,
      'name': instance.name,
      'number': instance.number,
      'operator': instance.$operator?.toJson(),
      'product': instance.product?.toJson(),
      'properties': instance.properties?.toJson(),
    };

AdditionalInfoResponse$Infos _$AdditionalInfoResponse$InfosFromJson(
        Map<String, dynamic> json) =>
    AdditionalInfoResponse$Infos(
      affected: json['affected'] == null
          ? null
          : AdditionalInfoResponse$Infos$Affected.fromJson(
              json['affected'] as Map<String, dynamic>),
      current: (json['current'] as List<dynamic>?)
              ?.map((e) => AdditionalInfoResponseMessage.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      historic: (json['historic'] as List<dynamic>?)
              ?.map((e) => AdditionalInfoResponseMessage.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$AdditionalInfoResponse$InfosToJson(
        AdditionalInfoResponse$Infos instance) =>
    <String, dynamic>{
      'affected': instance.affected?.toJson(),
      'current': instance.current?.map((e) => e.toJson()).toList(),
      'historic': instance.historic?.map((e) => e.toJson()).toList(),
    };

AdditionalInfoResponseAffectedLine$Destination
    _$AdditionalInfoResponseAffectedLine$DestinationFromJson(
            Map<String, dynamic> json) =>
        AdditionalInfoResponseAffectedLine$Destination(
          name: json['name'] as String?,
          type:
              additionalInfoResponseAffectedLine$DestinationTypeNullableFromJson(
                  json['type']),
        );

Map<String, dynamic> _$AdditionalInfoResponseAffectedLine$DestinationToJson(
        AdditionalInfoResponseAffectedLine$Destination instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': additionalInfoResponseAffectedLine$DestinationTypeNullableToJson(
          instance.type),
    };

AdditionalInfoResponseMessage$Affected
    _$AdditionalInfoResponseMessage$AffectedFromJson(
            Map<String, dynamic> json) =>
        AdditionalInfoResponseMessage$Affected(
          lines: (json['lines'] as List<dynamic>?)
                  ?.map((e) => AdditionalInfoResponseAffectedLine.fromJson(
                      e as Map<String, dynamic>))
                  .toList() ??
              [],
          stops: (json['stops'] as List<dynamic>?)
                  ?.map((e) => AdditionalInfoResponseAffectedStop.fromJson(
                      e as Map<String, dynamic>))
                  .toList() ??
              [],
        );

Map<String, dynamic> _$AdditionalInfoResponseMessage$AffectedToJson(
        AdditionalInfoResponseMessage$Affected instance) =>
    <String, dynamic>{
      'lines': instance.lines?.map((e) => e.toJson()).toList(),
      'stops': instance.stops?.map((e) => e.toJson()).toList(),
    };

AdditionalInfoResponseMessage$Properties
    _$AdditionalInfoResponseMessage$PropertiesFromJson(
            Map<String, dynamic> json) =>
        AdditionalInfoResponseMessage$Properties(
          providerCode: json['providerCode'] as String?,
          smsText: json['smsText'] as String?,
          source: json['source'] == null
              ? null
              : AdditionalInfoResponseMessage$Properties$Source.fromJson(
                  json['source'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$AdditionalInfoResponseMessage$PropertiesToJson(
        AdditionalInfoResponseMessage$Properties instance) =>
    <String, dynamic>{
      'providerCode': instance.providerCode,
      'smsText': instance.smsText,
      'source': instance.source?.toJson(),
    };

AdditionalInfoResponseTimestamps$Availability
    _$AdditionalInfoResponseTimestamps$AvailabilityFromJson(
            Map<String, dynamic> json) =>
        AdditionalInfoResponseTimestamps$Availability(
          from: json['from'] as String?,
          to: json['to'] as String?,
        );

Map<String, dynamic> _$AdditionalInfoResponseTimestamps$AvailabilityToJson(
        AdditionalInfoResponseTimestamps$Availability instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
    };

AdditionalInfoResponseTimestamps$Validity$Item
    _$AdditionalInfoResponseTimestamps$Validity$ItemFromJson(
            Map<String, dynamic> json) =>
        AdditionalInfoResponseTimestamps$Validity$Item(
          from: json['from'] as String?,
          to: json['to'] as String?,
        );

Map<String, dynamic> _$AdditionalInfoResponseTimestamps$Validity$ItemToJson(
        AdditionalInfoResponseTimestamps$Validity$Item instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
    };

ApiErrorResponse$Versions _$ApiErrorResponse$VersionsFromJson(
        Map<String, dynamic> json) =>
    ApiErrorResponse$Versions(
      controller: json['controller'] as String?,
      interfaceMax: json['interfaceMax'] as String?,
      interfaceMin: json['interfaceMin'] as String?,
    );

Map<String, dynamic> _$ApiErrorResponse$VersionsToJson(
        ApiErrorResponse$Versions instance) =>
    <String, dynamic>{
      'controller': instance.controller,
      'interfaceMax': instance.interfaceMax,
      'interfaceMin': instance.interfaceMin,
    };

CoordRequestResponseLocation$Properties
    _$CoordRequestResponseLocation$PropertiesFromJson(
            Map<String, dynamic> json) =>
        CoordRequestResponseLocation$Properties(
          gisdrawclass: json['GIS_DRAW_CLASS'] as String?,
          gisdrawclasstype:
              coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPENullableFromJson(
                  json['GIS_DRAW_CLASS_TYPE']),
          gisniveau: json['GIS_NIVEAU'] as String?,
          poidrawclass: json['POI_DRAW_CLASS'] as String?,
          poidrawclasstype:
              coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPENullableFromJson(
                  json['POI_DRAW_CLASS_TYPE']),
          poihierarchy0: json['POI_HIERARCHY_0'] as String?,
          poihierarchykey: json['POI_HIERARCHY_KEY'] as String?,
          distance: json['distance'] as String?,
        );

Map<String, dynamic> _$CoordRequestResponseLocation$PropertiesToJson(
        CoordRequestResponseLocation$Properties instance) =>
    <String, dynamic>{
      'GIS_DRAW_CLASS': instance.gisdrawclass,
      'GIS_DRAW_CLASS_TYPE':
          coordRequestResponseLocation$PropertiesGISDRAWCLASSTYPENullableToJson(
              instance.gisdrawclasstype),
      'GIS_NIVEAU': instance.gisniveau,
      'POI_DRAW_CLASS': instance.poidrawclass,
      'POI_DRAW_CLASS_TYPE':
          coordRequestResponseLocation$PropertiesPOIDRAWCLASSTYPENullableToJson(
              instance.poidrawclasstype),
      'POI_HIERARCHY_0': instance.poihierarchy0,
      'POI_HIERARCHY_KEY': instance.poihierarchykey,
      'distance': instance.distance,
    };

TripRequestResponse$SystemMessages _$TripRequestResponse$SystemMessagesFromJson(
        Map<String, dynamic> json) =>
    TripRequestResponse$SystemMessages(
      responseMessages: (json['responseMessages'] as List<dynamic>?)
              ?.map((e) => TripRequestResponseMessage.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$TripRequestResponse$SystemMessagesToJson(
        TripRequestResponse$SystemMessages instance) =>
    <String, dynamic>{
      'responseMessages':
          instance.responseMessages?.map((e) => e.toJson()).toList(),
    };

TripRequestResponseJourneyLeg$Hints$Item
    _$TripRequestResponseJourneyLeg$Hints$ItemFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLeg$Hints$Item(
          infoText: json['infoText'] as String?,
        );

Map<String, dynamic> _$TripRequestResponseJourneyLeg$Hints$ItemToJson(
        TripRequestResponseJourneyLeg$Hints$Item instance) =>
    <String, dynamic>{
      'infoText': instance.infoText,
    };

TripRequestResponseJourneyLeg$Properties
    _$TripRequestResponseJourneyLeg$PropertiesFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLeg$Properties(
          differentfares: json['DIFFERENT_FARES'] as String?,
          planLowFloorVehicle: json['PlanLowFloorVehicle'] as String?,
          planWheelChairAccess: json['PlanWheelChairAccess'] as String?,
          lineType: json['lineType'] as String?,
          vehicleAccess: (json['vehicleAccess'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
        );

Map<String, dynamic> _$TripRequestResponseJourneyLeg$PropertiesToJson(
        TripRequestResponseJourneyLeg$Properties instance) =>
    <String, dynamic>{
      'DIFFERENT_FARES': instance.differentfares,
      'PlanLowFloorVehicle': instance.planLowFloorVehicle,
      'PlanWheelChairAccess': instance.planWheelChairAccess,
      'lineType': instance.lineType,
      'vehicleAccess': instance.vehicleAccess,
    };

TripRequestResponseJourneyLegStop$Properties
    _$TripRequestResponseJourneyLegStop$PropertiesFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegStop$Properties(
          wheelchairAccess:
              tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessNullableFromJson(
                  json['WheelchairAccess']),
          downloads: (json['downloads'] as List<dynamic>?)
                  ?.map((e) =>
                      TripRequestResponseJourneyLegStopDownload.fromJson(
                          e as Map<String, dynamic>))
                  .toList() ??
              [],
        );

Map<String, dynamic> _$TripRequestResponseJourneyLegStop$PropertiesToJson(
        TripRequestResponseJourneyLegStop$Properties instance) =>
    <String, dynamic>{
      'WheelchairAccess':
          tripRequestResponseJourneyLegStop$PropertiesWheelchairAccessNullableToJson(
              instance.wheelchairAccess),
      'downloads': instance.downloads?.map((e) => e.toJson()).toList(),
    };

TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location
    _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationFromJson(
            Map<String, dynamic> json) =>
        TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location(
          coord: (json['coord'] as List<dynamic>?)
                  ?.map((e) => (e as num).toDouble())
                  .toList() ??
              [],
          id: json['id'] as String?,
          type:
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeNullableFromJson(
                  json['type']),
        );

Map<String, dynamic>
    _$TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationToJson(
            TripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$Location
                instance) =>
        <String, dynamic>{
          'coord': instance.coord,
          'id': instance.id,
          'type':
              tripRequestResponseJourneyLegStopFootpathInfoFootpathElemLocation$LocationTypeNullableToJson(
                  instance.type),
        };

TripTransportation$Destination _$TripTransportation$DestinationFromJson(
        Map<String, dynamic> json) =>
    TripTransportation$Destination(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$TripTransportation$DestinationToJson(
        TripTransportation$Destination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

TripTransportation$Operator _$TripTransportation$OperatorFromJson(
        Map<String, dynamic> json) =>
    TripTransportation$Operator(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$TripTransportation$OperatorToJson(
        TripTransportation$Operator instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

TripTransportation$Properties _$TripTransportation$PropertiesFromJson(
        Map<String, dynamic> json) =>
    TripTransportation$Properties(
      isTTB: json['isTTB'] as bool?,
      tripCode: (json['tripCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TripTransportation$PropertiesToJson(
        TripTransportation$Properties instance) =>
    <String, dynamic>{
      'isTTB': instance.isTTB,
      'tripCode': instance.tripCode,
    };

AdditionalInfoResponse$Infos$Affected
    _$AdditionalInfoResponse$Infos$AffectedFromJson(
            Map<String, dynamic> json) =>
        AdditionalInfoResponse$Infos$Affected(
          lines: (json['lines'] as List<dynamic>?)
                  ?.map((e) => AdditionalInfoResponseAffectedLine.fromJson(
                      e as Map<String, dynamic>))
                  .toList() ??
              [],
          stops: (json['stops'] as List<dynamic>?)
                  ?.map((e) => AdditionalInfoResponseAffectedStop.fromJson(
                      e as Map<String, dynamic>))
                  .toList() ??
              [],
        );

Map<String, dynamic> _$AdditionalInfoResponse$Infos$AffectedToJson(
        AdditionalInfoResponse$Infos$Affected instance) =>
    <String, dynamic>{
      'lines': instance.lines?.map((e) => e.toJson()).toList(),
      'stops': instance.stops?.map((e) => e.toJson()).toList(),
    };

AdditionalInfoResponseMessage$Properties$Source
    _$AdditionalInfoResponseMessage$Properties$SourceFromJson(
            Map<String, dynamic> json) =>
        AdditionalInfoResponseMessage$Properties$Source(
          id: json['id'] as String?,
          name: json['name'] as String?,
          type: json['type'] as String?,
        );

Map<String, dynamic> _$AdditionalInfoResponseMessage$Properties$SourceToJson(
        AdditionalInfoResponseMessage$Properties$Source instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
    };
