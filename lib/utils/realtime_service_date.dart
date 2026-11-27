import 'package:lbww_flutter/protobuf/gtfs-realtime/gtfs-realtime.pb.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import 'safe_value_utils.dart';

final _sydney = _sydneyLocation();

timezone.Location _sydneyLocation() {
  timezone_data.initializeTimeZones();
  return timezone.getLocation('Australia/Sydney');
}

/// Offset-free TfNSW timestamps belong to Sydney, regardless of device locale.
DateTime? tfnswDepartureInstant(Leg leg) {
  return tfnswTimeInstant(leg.origin.departureTimePlanned);
}

DateTime? tfnswTimeInstant(String? raw) {
  if (raw == null) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  if (parsed.isUtc) return parsed;
  return timezone.TZDateTime(
    _sydney,
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  ).toUtc().native;
}

bool realtimeServiceDateMatches(
  TripDescriptor descriptor,
  Leg leg, {
  bool allowPreviousServiceDate = false,
}) {
  if (!descriptor.hasStartDate() || descriptor.startDate.isEmpty) return true;
  final explicitDate = trimmedOrNull(
    tryReadStringValue(leg.rawJson, 'startDate') ??
        tryReadStringValue(leg.rawJson, 'start_date'),
  );
  if (explicitDate != null) return explicitDate == descriptor.startDate;
  final departure = tfnswDepartureInstant(leg);
  if (departure == null) return true;
  final value = descriptor.startDate;
  if (!RegExp(r'^\d{8}$').hasMatch(value)) return false;
  final year = int.parse(value.substring(0, 4));
  final month = int.parse(value.substring(4, 6));
  final day = int.parse(value.substring(6, 8));
  final serviceDay = DateTime.utc(year, month, day);
  if (serviceDay.year != year ||
      serviceDay.month != month ||
      serviceDay.day != day) {
    return false;
  }
  final local = timezone.TZDateTime.from(departure, _sydney);
  final departureDay = DateTime.utc(local.year, local.month, local.day);
  final days = departureDay.difference(serviceDay).inDays;
  if (days == 0) return true;
  if (days < 0) return false;
  // GTFS start_time can exceed 24 hours. Compare calendar days, not instants
  // at midnight: a DST change must not shift the service day.
  final start = descriptor.startTime.split(':');
  final hours = start.length == 3 ? int.tryParse(start.first) : null;
  if (hours != null && hours >= 24 && days == hours ~/ 24) return true;
  // Boarding after midnight on a previous day's service requires stop-time
  // evidence, or a descriptor already matched using that evidence.
  return allowPreviousServiceDate;
}
