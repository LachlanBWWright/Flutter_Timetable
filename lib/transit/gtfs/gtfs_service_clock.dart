import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../gtfs/gtfs_data.dart';
import '../../gtfs/timetable_index.dart';
import '../domain/transit_types.dart';
import '../errors/transit_failure.dart';

bool _timezoneDatabaseInitialized = false;

tz.Location gtfsFeedTimeZone(GtfsData data, TransitRegion region) {
  initializeGtfsTimeZones();

  final configuredZones = <String>{};
  for (final agency in data.agencies) {
    final zone = agency.agencyTimezone.trim();
    if (zone.isEmpty) {
      throw const UnsupportedCapability(
        message: 'The local GTFS feed has an agency without a timezone.',
      );
    }
    configuredZones.add(zone);
  }

  final zoneName = configuredZones.length == 1
      ? configuredZones.single
      : _fallbackTimeZone(region);
  try {
    return tz.getLocation(zoneName);
  } on Exception {
    throw UnsupportedCapability(
      message: 'The local GTFS agency timezone "$zoneName" is unknown.',
    );
  }
}

Map<String, String> gtfsRouteTimeZones(GtfsData data, TransitRegion region) {
  final fallback = gtfsFeedTimeZone(data, region).name;
  final agencies = {
    for (final agency in data.agencies) agency.agencyId: agency.agencyTimezone,
  };
  final result = <String, String>{};
  for (final route in data.routes) {
    if (data.agencies.map((a) => a.agencyTimezone).toSet().length > 1 &&
        route.agencyId == null) {
      throw const InvalidProviderResponse(
        message: 'Routes in a multi-timezone feed must identify their agency.',
      );
    }
    final zone =
        agencies[route.agencyId] ??
        (agencies.length == 1 ? agencies.values.single : fallback);
    try {
      tz.getLocation(zone);
    } on Exception {
      throw InvalidProviderResponse(
        message: 'Unknown route agency timezone: $zone',
      );
    }
    result[route.routeId] = zone;
  }
  return Map.unmodifiable(result);
}

void initializeGtfsTimeZones() {
  if (!_timezoneDatabaseInitialized) {
    tzdata.initializeTimeZones();
    _timezoneDatabaseInitialized = true;
  }
}

String _fallbackTimeZone(TransitRegion region) {
  switch (region) {
    case TransitRegion.nsw:
      return 'Australia/Sydney';
    case TransitRegion.victoria:
      return 'Australia/Melbourne';
    case TransitRegion.queensland:
      return 'Australia/Brisbane';
    case TransitRegion.southAustralia:
      return 'Australia/Adelaide';
    case TransitRegion.tasmania:
      return 'Australia/Hobart';
    case TransitRegion.northernTerritory:
      return 'Australia/Darwin';
    case TransitRegion.westernAustralia:
      return 'Australia/Perth';
  }
}

List<DateTime> gtfsCandidateServiceDates(
  DateTime when,
  int lookbackDays, {
  tz.Location? location,
}) {
  final localWhen = location == null
      ? when
      : tz.TZDateTime.from(when, location);
  // These are calendar dates, not elapsed 24-hour periods, so DST cannot
  // skip or duplicate a service date.
  final date = DateTime.utc(localWhen.year, localWhen.month, localWhen.day);
  return List<DateTime>.generate(
    lookbackDays + 2,
    (offset) =>
        DateTime.utc(date.year, date.month, date.day - lookbackDays + offset),
    growable: false,
  );
}

DateTime? gtfsTimeOnDate(
  DateTime serviceDate,
  String value,
  tz.Location location,
) {
  final seconds = gtfsTimeSeconds(value);
  if (seconds == null) return null;

  // GTFS time is measured from noon minus 12 hours on the service date.
  // Keeping that anchor in the agency zone follows DST transitions correctly.
  final serviceNoon = tz.TZDateTime(
    location,
    serviceDate.year,
    serviceDate.month,
    serviceDate.day,
    12,
  );
  return serviceNoon
      .subtract(const Duration(hours: 12))
      .add(Duration(seconds: seconds))
      .toUtc()
      .native;
}
