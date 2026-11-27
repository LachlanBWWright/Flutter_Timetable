import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/regional_saved_trip_service.dart';
import 'package:lbww_flutter/services/saved_trip_render_service.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/transit/domain/transit_cancellation.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/errors/transit_failure.dart';
import 'package:lbww_flutter/transit/registry/region_feature_flags.dart';
import 'package:lbww_flutter/utils/trip_screen_utils.dart';
import 'package:lbww_flutter/widgets/trip_cache/age_snapshot.dart';
import 'package:option_result/option_result.dart';

@immutable
class TripScreenState {
  TripScreenState({
    List<TripJourney> trips = const [],
    this.isLoading = false,
    this.error,
    this.snapshot,
    this.rawTripJson,
    this.testText = '',
  }) : trips = List.unmodifiable(trips);
  final List<TripJourney> trips;
  final bool isLoading;
  final String? error;
  final TripCacheSnapshot? snapshot;
  final String? rawTripJson;
  final String testText;
}

typedef TripCacheLoader = Future<TripCacheSnapshot> Function({
  required String originId,
  required String destinationId,
  required bool forceRefresh,
});
typedef ManualTripBuilder = Future<TripJourney?> Function(Journey trip);
typedef TripClock = DateTime Function();

class TripScreenController extends ChangeNotifier {
  TripScreenController({
    required this.trip,
    List<TripJourney> initialTrips = const [],
    TripCacheLoader? cacheLoader,
    ManualTripBuilder? manualBuilder,
    this.regionalPlanLoader,
    TripClock? clock,
    this.onUsableData,
    bool startAgingTimer = true,
  }) : _cacheLoader = cacheLoader ?? _defaultCacheLoader,
       _manualBuilder =
           manualBuilder ?? SavedTripRenderService.buildManualTripJourney,
       _clock = clock ?? DateTime.now,
       _state = TripScreenState(trips: initialTrips) {
    if (startAgingTimer && !trip.isManualMultiLeg) {
      _departureTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => ageNow(),
      );
    }
  }
  final Journey trip;
  final void Function()? onUsableData;
  final TripCacheLoader _cacheLoader;
  final ManualTripBuilder _manualBuilder;
  final RegionalPlanLoader? regionalPlanLoader;
  final TripClock _clock;
  TripScreenState _state;
  TripScreenState get state => _state;
  int _generation = 0;
  Timer? _departureTimer;
  bool _disposed = false;
  DateTime? planningTime;
  bool arrivalBased = false;
  Duration? walkingLimit;
  TransitAccessibility accessibility = TransitAccessibility.none;
  TransitCancellation? _cancellation;
  bool get hasPlanningOptions =>
      planningTime != null ||
      arrivalBased ||
      walkingLimit != null ||
      accessibility != TransitAccessibility.none;
  void cancelPlanning() {
    _cancellation?.cancel();
  }

  static Future<TripCacheSnapshot> _defaultCacheLoader({
    required String originId,
    required String destinationId,
    required bool forceRefresh,
  }) => TripCacheService.getSnapshotOrFetch(
    originId: originId,
    destinationId: destinationId,
    forceRefresh: forceRefresh,
  );

  void _emit(TripScreenState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_disposed) return;
    _cancellation?.cancel();
    final cancellation = _cancellation = TransitCancellation();
    final generation = ++_generation;
    _emit(
      TripScreenState(
        trips: _state.trips,
        isLoading: true,
        snapshot: _state.snapshot,
        rawTripJson: _state.rawTripJson,
        testText: _state.testText,
      ),
    );
    try {
      if (trip.isManualMultiLeg) {
        final journey = await _manualBuilder(trip);
        if (_disposed || generation != _generation) return;
        _emit(
          journey == null
              ? TripScreenState(error: 'Unable to load the saved manual trip.')
              : TripScreenState(
                  trips: [journey],
                  rawTripJson: prettyPrintRawJson(journey.rawJson),
                ),
        );
        return;
      }
      if (hasPlanningOptions) {
        List<TripJourney> journeys;
        if (TransitStopRef.tryParse(trip.originId) != null &&
            TransitStopRef.tryParse(trip.destinationId) != null) {
          journeys = await RegionalSavedTripService.planSavedTrip(
            trip,
            planLoader: regionalPlanLoader,
            when: planningTime ?? _clock(),
            arrivalBased: arrivalBased,
            walkingLimit: walkingLimit,
            accessibility: accessibility,
            cancellation: cancellation,
          );
        } else {
          if (walkingLimit != null) {
            throw const UnsupportedCapability(
              message:
                  'Choose provider-qualified stops to apply a walking limit.',
            );
          }
          final result = await cancellation.wait(
            TransportApiService.getTrips(
              originId: trip.originId,
              destinationId: trip.destinationId,
              when: planningTime ?? _clock(),
              arrivalBased: arrivalBased,
              wheelchair: accessibility != TransitAccessibility.none,
            ),
          );
          journeys = switch (result) {
            Ok(:final v) => v.tripJourneys,
            Err(:final e) => throw ProviderUnavailable(message: e),
          };
        }
        if (_disposed || generation != _generation) return;
        _emit(
          TripScreenState(
            trips: sortTripJourneysForDisplay(journeys),
            rawTripJson: prettyPrintRawJson({
              'journeys': journeys.map((j) => j.rawJson).toList(),
            }),
          ),
        );
        return;
      }
      final originRef = TransitStopRef.tryParse(trip.originId);
      final destinationRef = TransitStopRef.tryParse(trip.destinationId);
      if (RegionalSavedTripService.hasStructuredStops(trip)) {
        final originIsStructured = trip.originId.contains('|');
        final destinationIsStructured = trip.destinationId.contains('|');
        if ((originIsStructured && originRef == null) ||
            (destinationIsStructured && destinationRef == null)) {
          _emit(TripScreenState(error: 'Saved trip cannot be loaded.'));
          return;
        }
        final refRegion = originRef?.region ?? destinationRef!.region;
        if (refRegion != TransitRegion.nsw &&
            (originRef == null || destinationRef == null)) {
          _emit(TripScreenState(error: 'Saved trip cannot be loaded.'));
          return;
        }
        if (!RegionFeatureFlags.isEnabled(refRegion)) {
          _emit(
            TripScreenState(
              error:
                  'Saved journeys for ${refRegion.label} are unavailable in this build.',
            ),
          );
          return;
        }
        final parsedRefs = [?originRef, ?destinationRef];
        if (refRegion == TransitRegion.nsw &&
            destinationRef?.region == TransitRegion.nsw &&
            parsedRefs.any((ref) => ref.provider != TransitProviderId.tfnsw)) {
          _emit(TripScreenState(error: 'Saved trip provider is unavailable.'));
          return;
        }
        if (refRegion != TransitRegion.nsw ||
            destinationRef?.region != TransitRegion.nsw) {
          final regionalOriginRef = originRef!;
          final regionalDestinationRef = destinationRef!;
          final fetchedAt = _clock();
          final journeys = await RegionalSavedTripService.planSavedTrip(
            trip,
            planLoader: regionalPlanLoader,
            when: fetchedAt,
            cancellation: cancellation,
          );
          if (_disposed || generation != _generation) return;
          _emit(
            TripScreenState(
              trips: sortTripJourneysForDisplay(journeys),
              snapshot: TripCacheSnapshot(
                response: GetTripsResponse(
                  tripJourneys: journeys,
                  systemMessages: const SystemMessages(),
                  version: 'regional',
                  rawJson: {
                    'provenance': 'regional_journey_planner',
                    'transitRegion': regionalOriginRef.region.name,
                    'transitProvider': regionalOriginRef.provider.name,
                    'origin': regionalOriginRef.storageKey,
                    'destination': regionalDestinationRef.storageKey,
                    'journeys': journeys
                        .map((journey) => journey.rawJson)
                        .toList(),
                  },
                ),
                fetchedAt: fetchedAt,
                isFresh: true,
              ),
              rawTripJson: prettyPrintRawJson({
                'provenance': 'regional_journey_planner',
                'transitRegion': regionalOriginRef.region.name,
                'transitProvider': regionalOriginRef.provider.name,
                'origin': regionalOriginRef.storageKey,
                'destination': regionalDestinationRef.storageKey,
                'journeys': journeys.map((journey) => journey.rawJson).toList(),
              }),
            ),
          );
          return;
        }
      }
      final cacheRegion =
          originRef?.region ?? destinationRef?.region ?? TransitRegion.nsw;
      if (!RegionFeatureFlags.isEnabled(cacheRegion)) {
        _emit(
          TripScreenState(
            error:
                'Saved journeys for ${cacheRegion.label} are unavailable in this build.',
          ),
        );
        return;
      }
      final snapshot = await cancellation.wait(
        _cacheLoader(
          originId: originRef?.stopId ?? trip.originId,
          destinationId: destinationRef?.stopId ?? trip.destinationId,
          forceRefresh: forceRefresh,
        ),
      );
      if (_disposed || generation != _generation) return;
      final response = snapshot.response;
      if (response == null) {
        _emit(
          TripScreenState(
            error: snapshot.error ?? 'Current journeys are unavailable.',
            snapshot: snapshot,
          ),
        );
        return;
      }
      _emit(
        TripScreenState(
          trips: sortTripJourneysForDisplay(response.tripJourneys),
          snapshot: snapshot,
          testText: response.toString(),
          rawTripJson: prettyPrintRawJson(response.rawJson),
        ),
      );
      if (snapshot.hasUsableData) onUsableData?.call();
    } on TransitFailure catch (error) {
      if (_disposed || generation != _generation) return;
      _emit(
        TripScreenState(
          error:
              error.message ??
              (RegionalSavedTripService.hasStructuredStops(trip)
                  ? 'Regional journey planning is unavailable.'
                  : 'Journey planning is unavailable.'),
        ),
      );
    } on Exception {
      if (_disposed || generation != _generation) return;
      _emit(
        TripScreenState(
          error: RegionalSavedTripService.hasStructuredStops(trip)
              ? 'Unable to load regional journeys. Check region availability and try again.'
              : 'Unable to load journeys. Please retry.',
        ),
      );
    }
  }

  void ageNow() {
    final snapshot = _state.snapshot;
    if (snapshot == null || trip.isManualMultiLeg || hasPlanningOptions) return;
    final updated = ageTripCacheSnapshot(snapshot, _clock());
    final upcoming = updated.response?.tripJourneys ?? const <TripJourney>[];
    if (upcoming.length == _state.trips.length &&
        updated.isStale == snapshot.isStale &&
        updated.isFresh == snapshot.isFresh &&
        updated.isExpired == snapshot.isExpired) {
      return;
    }
    _emit(
      TripScreenState(
        trips: sortTripJourneysForDisplay(upcoming),
        isLoading: _state.isLoading,
        error: updated.isExpired
            ? 'Refresh to see current departures.'
            : _state.error,
        snapshot: updated,
        rawTripJson: _state.rawTripJson,
        testText: _state.testText,
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _departureTimer?.cancel();
    _cancellation?.cancel();
    super.dispose();
  }
}
