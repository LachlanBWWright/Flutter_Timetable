import 'package:flutter/material.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/utils/visible_realtime_refresh.dart';

import 'next_journey_times.dart';

class JourneyNextTripSubtitle extends StatefulWidget {
  const JourneyNextTripSubtitle({
    super.key,
    required this.journey,
    this.reverse = false,
  });

  final Journey journey;
  final bool reverse;

  @override
  State<JourneyNextTripSubtitle> createState() =>
      _JourneyNextTripSubtitleState();
}

class _JourneyNextTripSubtitleState extends State<JourneyNextTripSubtitle> {
  late final Listenable _cacheChanges;
  late VisibleRealtimeRefresh _refresh;
  NextJourneyTimes? _times;
  DateTime? _displayDay;

  String get _origin =>
      widget.reverse ? widget.journey.destinationId : widget.journey.originId;
  String get _destination =>
      widget.reverse ? widget.journey.originId : widget.journey.destinationId;

  @override
  void initState() {
    super.initState();
    _cacheChanges = TripCacheService.changes;
    _cacheChanges.addListener(_onCacheChanged);
    _readTimes();
    _configureRefresh();
  }

  void _configureRefresh() {
    _refresh = VisibleRealtimeRefresh(
      enabled: TripCacheService.canLoadJourney(widget.journey),
      onRefresh: () async {
        _onCacheChanged();
        if (widget.reverse) {
          TripCacheService.prefetchReverseJourney(widget.journey);
        } else {
          TripCacheService.prefetchJourney(widget.journey);
        }
      },
    );
  }

  void _readTimes() {
    _displayDay = DateUtils.dateOnly(DateTime.now());
    _times = NextJourneyTimes.fromSnapshot(
      TripCacheService.peekSnapshot(_origin, _destination),
      DateTime.now(),
    );
  }

  void _onCacheChanged() {
    if (!mounted) return;
    final old = _times;
    final oldDay = _displayDay;
    _readTimes();
    if (old?.departure != _times?.departure ||
        old?.arrival != _times?.arrival ||
        oldDay != _displayDay) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refresh.updateRoute(context);
  }

  @override
  void didUpdateWidget(covariant JourneyNextTripSubtitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journey.originId != widget.journey.originId ||
        oldWidget.journey.destinationId != widget.journey.destinationId ||
        oldWidget.journey.tripType != widget.journey.tripType ||
        oldWidget.reverse != widget.reverse) {
      _readTimes();
      _refresh.dispose();
      _configureRefresh();
      _refresh.updateRoute(context);
    }
  }

  String _formatDateTime(DateTime value, {DateTime? sameDayAs}) {
    final local = value.toLocal();
    final now = DateTime.now();
    final localizations = MaterialLocalizations.of(context);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    if (sameDay(local, sameDayAs?.toLocal() ?? now)) return time;
    if (sameDay(local, DateTime(now.year, now.month, now.day + 1))) {
      return 'Tomorrow $time';
    }
    return '${localizations.formatShortDate(local)} $time';
  }

  @override
  Widget build(BuildContext context) {
    if (!TripCacheService.canLoadJourney(widget.journey)) {
      return const SizedBox.shrink();
    }
    final times = _times;
    // Reserve one line while data loads, without displaying cache/fetch status.
    if (times == null) return const SizedBox(height: 20);
    final departure = _formatDateTime(times.departure);
    final arrival = times.arrival;
    final label = arrival == null
        ? 'Next $departure'
        : 'Next $departure – ${_formatDateTime(arrival, sameDayAs: times.departure)}';
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refresh.dispose();
    _cacheChanges.removeListener(_onCacheChanged);
    super.dispose();
  }
}
