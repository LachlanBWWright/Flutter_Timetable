part of '../trip_leg_detail_screen.dart';

/// Matches realtime stop updates and overlays them onto scheduled rows.
extension _RealtimeStops on _TripLegDetailScreenState {
  String? _isoFromUnixSeconds(int? unixSeconds) {
    if (unixSeconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      unixSeconds * 1000,
      isUtc: true,
    ).toIso8601String();
  }

  String? _plannedFromEvent(TripUpdate_StopTimeEvent event) {
    if (!event.hasTime()) return null;
    return _isoFromUnixSeconds(
      event.time.toInt() - (event.hasDelay() ? event.delay : 0),
    );
  }

  String? _estimatedFromEvent(
    TripUpdate_StopTimeEvent? event,
    String? planned,
    String? previous,
  ) {
    if (event == null) return previous;
    if (event.hasTime()) return _isoFromUnixSeconds(event.time.toInt());
    if (!event.hasDelay()) return previous;
    final baseline = DateTime.tryParse(planned ?? '');
    return baseline?.add(Duration(seconds: event.delay)).toIso8601String() ??
        previous;
  }

  Future<List<_VehicleStopRow>> _buildVehicleStopsFromTripUpdate(
    TripUpdate update,
    Leg leg,
  ) async => _overlayTripStopRows(update, _buildTripStopRows(_legStops(leg)));

  List<_VehicleStopRow> _liveTripStopRows(Leg leg) {
    final rows = _buildTripStopRows(_legStops(leg));
    return _overlayCurrentTripUpdate(leg, rows);
  }

  List<_VehicleStopRow> _overlayCurrentTripUpdate(
    Leg leg,
    List<_VehicleStopRow> rows,
  ) {
    if (!_supportsRealtimeForLeg(leg)) return rows;
    final updates = _realtimeController.state.tripUpdates?.tripUpdates;
    final update = updates == null
        ? null
        : _matchTripUpdateForLeg(updates, leg: leg);
    return update == null
        ? rows
        : _overlayTripStopRows(update, rows, includeExtraStops: false);
  }

  _VehicleStopRow _liveEndpointRow(Leg leg, {required bool arrival}) {
    final endpoint = arrival ? leg.destination : leg.origin;
    final baseline = _buildTripStopRows([endpoint]).single;
    final rows = _buildTripStopRows(_legStops(leg));
    final endpointId = trimmedOrNull(endpoint.id);
    var matchIndex = -1;
    for (var index = 0; index < rows.length; index++) {
      if (endpointId != null && rows[index].stopId == endpointId) {
        matchIndex = index;
        if (!arrival) break;
      }
    }
    if (matchIndex >= 0) {
      final row = rows[matchIndex];
      // EFA can supply endpoint estimates without repeating them in the stop
      // sequence. Merge those fields before applying live data so NO_DATA can
      // still explicitly clear estimates rather than restoring a fallback.
      rows[matchIndex] = _VehicleStopRow(
        label: row.label,
        stopId: row.stopId,
        platform: row.platform ?? baseline.platform,
        wheelchairAccess: row.wheelchairAccess ?? baseline.wheelchairAccess,
        arrivalTimePlanned:
            row.arrivalTimePlanned ?? baseline.arrivalTimePlanned,
        arrivalTimeEstimated:
            row.arrivalTimeEstimated ?? baseline.arrivalTimeEstimated,
        departureTimePlanned:
            row.departureTimePlanned ?? baseline.departureTimePlanned,
        departureTimeEstimated:
            row.departureTimeEstimated ?? baseline.departureTimeEstimated,
        skipped: row.skipped,
        cancelled: row.cancelled,
      );
      return _overlayCurrentTripUpdate(leg, rows)[matchIndex];
    }
    final endpoints = _overlayCurrentTripUpdate(
      leg,
      _buildTripStopRows([leg.origin, leg.destination]),
    );
    return arrival ? endpoints.last : endpoints.first;
  }

  List<_VehicleStopRow> _overlayTripStopRows(
    TripUpdate update,
    List<_VehicleStopRow> rows, {
    bool includeExtraStops = true,
  }) {
    final stopUpdates = update.stopTimeUpdate;
    final used = <int>{};
    final matches = <int, int>{};
    final cancelled =
        update.trip.scheduleRelationship ==
        TripDescriptor_ScheduleRelationship.CANCELED;

    // The leg may begin halfway through a vehicle's trip. Infer its sequence
    // offset only from an unambiguous ID match rather than assuming stop one.
    int? offset;
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final id = rows[rowIndex].stopId;
      if (id == null || id.isEmpty) continue;
      final candidates = stopUpdates
          .where(
            (value) =>
                value.hasStopId() &&
                value.stopId == id &&
                value.hasStopSequence(),
          )
          .toList();
      if (candidates.length == 1 &&
          rows.where((row) => row.stopId == id).length == 1) {
        offset = candidates.single.stopSequence - rowIndex;
        break;
      }
    }

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final rowId = rows[rowIndex].stopId;
      final targetSequence = rowIndex + (offset ?? 1);
      final candidates = <int>[];
      for (var index = 0; index < stopUpdates.length; index++) {
        if (used.contains(index)) continue;
        final candidate = stopUpdates[index];
        if (rowId != null &&
            rowId.isNotEmpty &&
            candidate.hasStopId() &&
            candidate.stopId == rowId) {
          if (candidate.hasStopSequence()) {
            final sequenceRow = candidate.stopSequence - (offset ?? 1);
            if (sequenceRow >= 0 &&
                sequenceRow < rows.length &&
                sequenceRow != rowIndex &&
                rows[sequenceRow].stopId == rowId) {
              continue;
            }
          }
          candidates.add(index);
        }
      }
      // Sequence disambiguates multiple visits to the same stop. Otherwise
      // consume matching occurrences in vehicle sequence order.
      candidates.sort((a, b) {
        final first = stopUpdates[a];
        final second = stopUpdates[b];
        final firstExact =
            first.hasStopSequence() && first.stopSequence == targetSequence;
        final secondExact =
            second.hasStopSequence() && second.stopSequence == targetSequence;
        if (firstExact != secondExact) return firstExact ? -1 : 1;
        if (first.hasStopSequence() && second.hasStopSequence()) {
          return first.stopSequence.compareTo(second.stopSequence);
        }
        return a.compareTo(b);
      });
      int? match = candidates.isEmpty ? null : candidates.first;
      if (match == null) {
        for (var index = 0; index < stopUpdates.length; index++) {
          final candidate = stopUpdates[index];
          if (used.contains(index) ||
              !candidate.hasStopSequence() ||
              candidate.stopSequence != targetSequence) {
            continue;
          }
          // Never replace a known stop with an update for a different stop.
          if (rowId != null &&
              rowId.isNotEmpty &&
              candidate.hasStopId() &&
              candidate.stopId.isNotEmpty &&
              candidate.stopId != rowId) {
            continue;
          }
          match = index;
          break;
        }
      }
      if (match != null) {
        matches[rowIndex] = match;
        used.add(match);
      }
    }

    _VehicleStopRow overlay(
      _VehicleStopRow row,
      TripUpdate_StopTimeUpdate? stopUpdate,
    ) {
      final arrival = stopUpdate != null && stopUpdate.hasArrival()
          ? stopUpdate.arrival
          : null;
      final departure = stopUpdate != null && stopUpdate.hasDeparture()
          ? stopUpdate.departure
          : null;
      final arrivalPlanned =
          row.arrivalTimePlanned ??
          (arrival == null ? null : _plannedFromEvent(arrival));
      final departurePlanned =
          row.departureTimePlanned ??
          (departure == null ? null : _plannedFromEvent(departure));
      final noData =
          stopUpdate?.scheduleRelationship ==
          TripUpdate_StopTimeUpdate_ScheduleRelationship.NO_DATA;
      return _VehicleStopRow(
        label: row.label,
        stopId: row.stopId,
        platform: row.platform,
        wheelchairAccess: row.wheelchairAccess,
        arrivalTimePlanned: arrivalPlanned,
        departureTimePlanned: departurePlanned,
        arrivalTimeEstimated: noData
            ? null
            : _estimatedFromEvent(
                arrival,
                arrivalPlanned,
                row.arrivalTimeEstimated,
              ),
        departureTimeEstimated: noData
            ? null
            : _estimatedFromEvent(
                departure,
                departurePlanned,
                row.departureTimeEstimated,
              ),
        cancelled: cancelled || row.cancelled,
        skipped:
            row.skipped ||
            stopUpdate?.scheduleRelationship ==
                TripUpdate_StopTimeUpdate_ScheduleRelationship.SKIPPED,
      );
    }

    if (!includeExtraStops) {
      return [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
          overlay(
            rows[rowIndex],
            matches[rowIndex] == null ? null : stopUpdates[matches[rowIndex]!],
          ),
      ];
    }

    final result = <_VehicleStopRow>[];
    final extras = <int>[
      for (var index = 0; index < stopUpdates.length; index++)
        if (!used.contains(index)) index,
    ];
    extras.sort((a, b) {
      final first = stopUpdates[a];
      final second = stopUpdates[b];
      if (first.hasStopSequence() != second.hasStopSequence()) {
        return first.hasStopSequence() ? -1 : 1;
      }
      final order = first.stopSequence.compareTo(second.stopSequence);
      return order == 0 ? a.compareTo(b) : order;
    });
    var nextExtra = 0;
    void addExtra(int index) {
      final extra = stopUpdates[index];
      final id = extra.hasStopId() ? extra.stopId : null;
      final sequence = extra.hasStopSequence() ? extra.stopSequence : index + 1;
      result.add(
        overlay(
          _VehicleStopRow(
            label: id != null && id.isNotEmpty ? id : 'Stop $sequence',
            stopId: id,
          ),
          extra,
        ),
      );
    }

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final match = matches[rowIndex];
      final matchedUpdate = match == null ? null : stopUpdates[match];
      final sequence = matchedUpdate != null && matchedUpdate.hasStopSequence()
          ? matchedUpdate.stopSequence
          : rowIndex + (offset ?? 1);
      while (nextExtra < extras.length) {
        final extra = stopUpdates[extras[nextExtra]];
        if (!extra.hasStopSequence() || extra.stopSequence >= sequence) break;
        addExtra(extras[nextExtra++]);
      }
      result.add(overlay(rows[rowIndex], matchedUpdate));
    }
    while (nextExtra < extras.length) {
      addExtra(extras[nextExtra++]);
    }
    return result;
  }

  Future<void> _loadVehicleStopsForLeg() async {
    final generation = _requestGeneration;
    final stopGeneration = ++_stopRequestGeneration;
    final leg = _activeLeg;
    bool isCurrent() =>
        _isCurrentRequest(generation, leg) &&
        stopGeneration == _stopRequestGeneration;
    guardedSetState(() {
      _isLoadingVehicleStops = true;
      _vehicleStopsError = null;
      _vehicleStops = [];
    });

    await runAsyncGuarded(
      () async {
        final aggregate = await _getTripUpdateAggregate();
        if (!isCurrent()) return;
        final tripUpdates = aggregate.tripUpdates;
        final tripIds = _collectTripIdsForActiveLeg();
        final routeId = _legRouteId();
        final match = _matchTripUpdateForLeg(tripUpdates, leg: leg);
        if (match == null) {
          safeLogInfo(
            'No realtime trip update matched this leg '
            '(tripIds=${tripIds.join(', ')}, routeId=$routeId, '
            'feeds=${aggregate.breakdown.keys.join(', ')}).',
          );
          guardedSetState(() {
            _vehicleStopsError = _vehicleStopsUnavailableMessage;
            _isLoadingVehicleStops = false;
          });
          return;
        }

        final rows = await _buildVehicleStopsFromTripUpdate(match, leg);
        if (!isCurrent()) return;

        guardedSetState(() {
          _vehicleStops = rows;
          _isLoadingVehicleStops = false;
        });
      },
      onError: (error, _) {
        if (!isCurrent()) return;
        safeLogInfo('Failed to load vehicle stops for leg: $error');
        guardedSetState(() {
          _vehicleStopsError = _vehicleStopsUnavailableMessage;
          _isLoadingVehicleStops = false;
        });
      },
    );
  }

  static const _vehicleStopsUnavailableMessage =
      'Live stop updates are unavailable right now. Showing scheduled stops.';
}
