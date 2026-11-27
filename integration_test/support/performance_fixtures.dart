import 'package:flutter/material.dart';
import 'package:lbww_flutter/schema/database.dart' show Journey;
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/services/trip_cache_service.dart';
import 'package:lbww_flutter/widgets/journey_widgets.dart';
import 'package:option_result/option_result.dart';

List<Journey> savedJourneys(int count) => List.generate(
  count,
  (index) => Journey(
    id: index,
    origin: 'Station $index',
    originId: 'origin-$index',
    destination: 'Destination $index',
    destinationId: 'destination-$index',
    tripType: 'direct',
    mode: 'train',
    isPinned: false,
  ),
);

GetTripsResponse journeyResponse(DateTime now, {int count = 12}) =>
    GetTripsResponse(
      tripJourneys: List.generate(count, (index) {
        final departure = now.add(Duration(minutes: 30 + index * 10));
        return TripJourney(
          legs: List.generate(3, (leg) {
            final start = departure.add(Duration(minutes: leg * 20));
            return Leg(
              duration: 900,
              origin: Stop(
                id: 'stop-$leg',
                name: 'Stop $leg',
                type: 'stop',
                departureTimePlanned: start.toIso8601String(),
              ),
              destination: Stop(
                id: 'stop-${leg + 1}',
                name: 'Stop ${leg + 1}',
                type: 'stop',
                arrivalTimePlanned: start
                    .add(const Duration(minutes: 15))
                    .toIso8601String(),
              ),
            );
          }),
        );
      }),
      systemMessages: const SystemMessages(),
      version: 'performance-fixture',
      rawJson: const {},
    );

/// Real cache policy and widgets; only transport and disk are replaced.
class PerformanceCache {
  PerformanceCache({this.latency = Duration.zero}) {
    repository = TripCacheRepository(
      fetchTrips: (origin, destination) async {
        fetches++;
        active++;
        if (active > peakActive) peakActive = active;
        try {
          await Future<void>.delayed(latency);
          return Ok(journeyResponse(DateTime.now()));
        } finally {
          active--;
        }
      },
      readCache: (_, _) async {
        reads++;
        return null;
      },
      writeCache: (_, _, _) async => writes++,
      markError: (_, _, _) async {},
      deleteCache: (_, _) async {},
      deleteAll: () async {},
    );
  }

  final Duration latency;
  late final TripCacheRepository repository;
  int fetches = 0;
  int reads = 0;
  int writes = 0;
  int active = 0;
  int peakActive = 0;

  Map<String, int> get counters => {
    'fetches': fetches,
    'disk_reads': reads,
    'disk_writes': writes,
    'peak_concurrent_fetches': peakActive,
  };
}

Widget subtitleList(List<Journey> journeys) => MaterialApp(
  home: Scaffold(
    body: CustomScrollView(
      slivers: [
        JourneyList(
          asSliver: true,
          journeys: journeys,
          showNextTripTimes: true,
          onJourneyTap: (_) {},
          onReverseJourneyTap: (_) {},
          onJourneyVisible: TripCacheService.prefetchJourney,
          onDeleteJourney: (_) {},
          onTogglePin: (_, _) {},
          isEditingMode: false,
          isPinnedSection: false,
        ),
      ],
    ),
  ),
);
