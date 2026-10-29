part of 'gtfs_journey_planner.dart';

bool _timezoneDatabaseInitialized = false;

tz.Location _feedTimeZone(GtfsData data, TransitRegion region) {
  _initializePlannerTimeZones();

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

  if (configuredZones.length > 1) {
    throw const UnsupportedCapability(
      message:
          'Local GTFS feeds with multiple agency timezones are unsupported.',
    );
  }

  final zoneName = configuredZones.isEmpty
      ? _fallbackTimeZone(region)
      : configuredZones.single;
  try {
    return tz.getLocation(zoneName);
  } on Exception {
    throw UnsupportedCapability(
      message: 'The local GTFS agency timezone "$zoneName" is unknown.',
    );
  }
}

void _initializePlannerTimeZones() {
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

List<DateTime> _candidateServiceDates(DateTime localWhen, int lookbackDays) {
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

DateTime? _timeOnDate(
  DateTime serviceDate,
  String value,
  tz.Location location,
) {
  final parts = value.split(':').map(int.tryParse).toList();
  if (parts.length != 3 ||
      parts.any((part) => part == null) ||
      parts[0]! < 0 ||
      parts[1]! < 0 ||
      parts[1]! > 59 ||
      parts[2]! < 0 ||
      parts[2]! > 59) {
    return null;
  }

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
      .add(Duration(hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!))
      .toUtc()
      .native;
}
