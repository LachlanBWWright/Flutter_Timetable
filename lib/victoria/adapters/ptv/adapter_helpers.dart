part of '../ptv_transit_adapter.dart';

Future<GtfsData>? _victoriaGtfs;

Future<GtfsData> _loadVictoriaGtfs() => _victoriaGtfs ??= () async {
  final override = _readEnv('VICTORIA_STATIC_GTFS_URL');
  final uri = Uri.parse(override.isNotEmpty ? override : victoriaStaticGtfsUrl);
  final response = await AppHttpClient.get(uri);
  if (response == null || response.statusCode != 200) {
    throw const ProviderUnavailable(
      message: 'Failed to download Victoria GTFS for journey planning.',
    );
  }
  return await compute(
    parseVictoriaGtfsFromZip,
    Uint8List.fromList(response.bodyBytes),
  );
}();

int? _parseRouteType(String sourceId) {
  final value = sourceId.split(':').last;
  return int.tryParse(value);
}

TransportMode? _transportModeForRouteType(int routeType) {
  switch (routeType) {
    case 0:
      return TransportMode.train;
    case 1:
      return TransportMode.metro;
    case 2:
      return TransportMode.train;
    case 3:
      return TransportMode.bus;
    case 4:
      return TransportMode.ferry;
  }
  return null;
}

enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType _stopRouteTypeEnum(
  int routeType,
) {
  switch (routeType) {
    case 0:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_0;
    case 1:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_1;
    case 2:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_2;
    case 3:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_3;
    case 4:
      return enums.V3StopsStopIdRouteTypeRouteTypeGetRouteType.value_4;
    default:
      return enums
          .V3StopsStopIdRouteTypeRouteTypeGetRouteType
          .swaggerGeneratedUnknown;
  }
}

enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
_departureRouteTypeEnum(int routeType) {
  switch (routeType) {
    case 0:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_0;
    case 1:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_1;
    case 2:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_2;
    case 3:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_3;
    case 4:
      return enums.V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType.value_4;
    default:
      return enums
          .V3DeparturesRouteTypeRouteTypeStopStopIdGetRouteType
          .swaggerGeneratedUnknown;
  }
}

String _readEnv(String key) {
  try {
    return dotenv.env[key]?.trim() ?? '';
  } catch (_) {
    return '';
  }
}

Set<String> _activeServiceIds(GtfsData data, DateTime moment) {
  final date =
      '${moment.year.toString().padLeft(4, '0')}'
      '${moment.month.toString().padLeft(2, '0')}'
      '${moment.day.toString().padLeft(2, '0')}';
  final active = <String>{};
  for (final calendar in data.calendars) {
    if (date.compareTo(calendar.startDate) < 0 ||
        date.compareTo(calendar.endDate) > 0) {
      continue;
    }
    final enabled = switch (moment.weekday) {
      DateTime.monday => calendar.monday == '1',
      DateTime.tuesday => calendar.tuesday == '1',
      DateTime.wednesday => calendar.wednesday == '1',
      DateTime.thursday => calendar.thursday == '1',
      DateTime.friday => calendar.friday == '1',
      DateTime.saturday => calendar.saturday == '1',
      DateTime.sunday => calendar.sunday == '1',
      _ => false,
    };
    if (enabled) active.add(calendar.serviceId);
  }
  for (final exception in data.calendarDates) {
    if (exception.date != date) continue;
    if (exception.exceptionType == '1') {
      active.add(exception.serviceId);
    } else if (exception.exceptionType == '2') {
      active.remove(exception.serviceId);
    }
  }
  return active;
}

DateTime? _gtfsTimeToDateTime(DateTime date, String value) {
  final parts = value.split(':');
  if (parts.length != 3) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  final second = int.tryParse(parts[2]);
  if (hour == null || minute == null || second == null) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).add(Duration(hours: hour, minutes: minute, seconds: second));
}
