part of '../trip_leg_detail_screen.dart';

/// Normalizes transport metadata used by presentation and diagnostics.
extension _LegMetadata on _TripLegDetailScreenState {
  T? _itemAt<T>(List<T> items, int index) {
    if (index < 0) {
      return null;
    }
    var currentIndex = 0;
    for (final item in items) {
      if (currentIndex == index) {
        return item;
      }
      currentIndex++;
    }
    return null;
  }

  StopsEndpoint? _endpointForKey(String key) {
    for (final endpoint in StopsEndpoint.values) {
      if (endpoint.key == key) {
        return endpoint;
      }
    }
    return null;
  }

  Leg get _activeLeg => _updatedLeg ?? widget.leg;
  List<Leg> get _tripLegs => widget.trip?.legs ?? const <Leg>[];

  String? _trimmedOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _firstNonBlank(Iterable<String?> values) {
    for (final value in values) {
      final trimmed = _trimmedOrNull(value);
      if (trimmed != null) {
        return trimmed;
      }
    }
    return null;
  }

  String _displayOrNa(String? value) => value ?? 'N/A';

  String _displayValueOrNa(Object? value) => value?.toString() ?? 'N/A';

  String? _legRouteIdFor(Leg leg) => _trimmedOrNull(leg.transportation?.id);

  List<Stop> _legStops(Leg leg) => leg.stopSequence ?? const <Stop>[];

  String? _transportDisassembledName(Transportation? transportation) {
    return _trimmedOrNull(transportation?.disassembledName);
  }

  String? _transportOperatorId(Transportation? transportation) {
    return _trimmedOrNull(transportation?.operator?.id);
  }

  String? _transportLabel(Transportation? transportation) {
    return _firstNonBlank([
      transportation?.name,
      transportation?.disassembledName,
      transportation?.id,
    ]);
  }

  String _legTransportLabel(Leg leg) {
    return _displayOrNa(_transportLabel(leg.transportation));
  }

  String? _transportNumber(Transportation? transportation) {
    return _trimmedOrNull(transportation?.number);
  }

  String? _transportDescription(Transportation? transportation) {
    return _trimmedOrNull(transportation?.description);
  }

  String? _transportDestinationId(Transportation? transportation) {
    return _trimmedOrNull(transportation?.destination?.id);
  }

  String? _transportDestinationName(Transportation? transportation) {
    return _firstNonBlank([transportation?.destination?.name]);
  }

  String? _transportOperatorName(Transportation? transportation) {
    return _firstNonBlank([transportation?.operator?.name]);
  }

  String? _transportProductName(Transportation? transportation) {
    return _firstNonBlank([transportation?.product?.name]);
  }

  int? _transportClass(Transportation? transportation) {
    return transportation?.product?.classField;
  }

  Map<String, dynamic>? _transportRawJson(Transportation? transportation) {
    if (transportation == null || transportation.rawJson.isEmpty) {
      return null;
    }
    return transportation.rawJson;
  }
}
