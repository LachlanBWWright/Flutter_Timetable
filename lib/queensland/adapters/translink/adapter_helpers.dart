part of '../translink_transit_adapter.dart';

GtfsData _emptyGtfsData() {
  return GtfsData(
    agencies: const [],
    calendars: const [],
    calendarDates: const [],
    routes: const [],
    stops: const [],
    stopTimes: const [],
    trips: const [],
    shapes: const [],
    notes: const [],
  );
}

String _feedIdFromSource(String sourceId) => sourceId.replaceFirst('qld:', '');

TransportMode? _modeFromStopName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('ferry')) return TransportMode.ferry;
  if (lower.contains('tram')) return TransportMode.lightrail;
  if (lower.contains('bus')) return TransportMode.bus;
  if (lower.contains('station')) return TransportMode.train;
  return null;
}

TransportMode? _modeFromRouteType(String routeType) {
  switch (routeType) {
    case '0':
    case '1':
      return TransportMode.train;
    case '3':
      return TransportMode.bus;
    case '4':
      return TransportMode.ferry;
    default:
      return null;
  }
}

Set<String> _activeServiceIds(GtfsData data, DateTime moment) {
  final yyyymmdd =
      '${moment.year.toString().padLeft(4, '0')}${moment.month.toString().padLeft(2, '0')}${moment.day.toString().padLeft(2, '0')}';
  final services = <String>{};
  for (final calendar in data.calendars) {
    if (yyyymmdd.compareTo(calendar.startDate) < 0 ||
        yyyymmdd.compareTo(calendar.endDate) > 0) {
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
    if (enabled) {
      services.add(calendar.serviceId);
    }
  }
  for (final exception in data.calendarDates.where(
    (entry) => entry.date == yyyymmdd,
  )) {
    if (exception.exceptionType == '1') {
      services.add(exception.serviceId);
    } else if (exception.exceptionType == '2') {
      services.remove(exception.serviceId);
    }
  }
  return services;
}

DateTime? _gtfsTimeToDateTime(DateTime anchor, String value) {
  final parts = value.split(':');
  if (parts.length != 3) return null;
  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);
  final seconds = int.tryParse(parts[2]);
  if (hours == null || minutes == null || seconds == null) return null;
  final dayOffset = hours ~/ 24;
  final normalizedHours = hours % 24;
  return DateTime(
    anchor.year,
    anchor.month,
    anchor.day + dayOffset,
    normalizedHours,
    minutes,
    seconds,
  );
}
