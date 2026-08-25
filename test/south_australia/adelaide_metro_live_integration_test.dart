import 'dart:io';

import 'package:drift/native.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/journey_service.dart';
import 'package:lbww_flutter/south_australia/adapters/adelaide_metro_transit_adapter.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:test/test.dart';

void main() {
  final runLiveTests = Platform.environment['RUN_SA_API_TESTS'] == 'true';

  test(
    'Adelaide Metro user flow imports, finds, plans, and saves a trip',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      try {
        final services = buildAdelaideMetroRegionServices(database: database);
        final progress = await services.staticGtfs!
            .refreshStaticData(const StaticImportRequest())
            .toList();
        expect(progress.last.error, isNull);
        expect(progress.last.completed, 1);

        final originCandidates = await services.stops.searchStops(
          const StopSearchRequest(query: 'Adelaide', limit: 20),
        );
        final destinationCandidates = await services.stops.searchStops(
          const StopSearchRequest(query: 'Mawson', limit: 20),
        );
        expect(originCandidates, isNotEmpty);
        expect(destinationCandidates, isNotEmpty);

        TransitStop? selectedOrigin;
        TransitStop? selectedDestination;
        JourneyPlan? selectedPlan;
        for (final origin in originCandidates.take(5)) {
          final departures = await services.departures!.getDepartures(
            DepartureRequest(stop: origin.ref),
          );
          if (departures.isEmpty) continue;
          for (final destination in destinationCandidates.take(5)) {
            if (origin.ref == destination.ref) continue;
            final plan = await services.journeyPlanner!.planJourney(
              JourneyPlanRequest(
                origin: origin.ref,
                destination: destination.ref,
              ),
            );
            if (plan.journeys.isNotEmpty) {
              selectedOrigin = origin;
              selectedDestination = destination;
              selectedPlan = plan;
              break;
            }
          }
          if (selectedPlan != null) break;
        }

        expect(selectedOrigin, isNotNull);
        expect(selectedDestination, isNotNull);
        expect(selectedPlan?.journeys, isNotEmpty);
        print(
          'STATE_SAMPLE SA stop=${selectedOrigin!.name} '
          'id=${selectedOrigin.ref.stopId} destination=${selectedDestination!.name} '
          'id=${selectedDestination.ref.stopId} journeys=${selectedPlan!.journeys.length}',
        );

        final saved = await JourneyService.insertJourney(
          database,
          db.JourneysCompanion.insert(
            origin: selectedOrigin!.name,
            originId: selectedOrigin.ref.storageKey,
            destination: selectedDestination!.name,
            destinationId: selectedDestination.ref.storageKey,
          ),
        );
        expect(saved, isTrue);
        expect(await database.getAllJourneys(), hasLength(1));
      } finally {
        await database.close();
      }
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(minutes: 5)),
  );

  test(
    'Adelaide Metro GTFS-Realtime feeds decode without credentials',
    () async {
      final realtime = const AdelaideMetroRealtimeRepository();
      final request = const RealtimeRequest(
        sourceId: TransitSourceId('sa:adelaide'),
      );
      final vehicles = await realtime.getVehiclePositions(request);
      final updates = await realtime.getTripUpdates(request);
      final alerts = await realtime.getAlerts(request);
      expect(vehicles.fetchedAt, isNotNull);
      expect(updates.fetchedAt, isNotNull);
      expect(alerts.fetchedAt, isNotNull);
      expect(vehicles.items, isA<List<TransitVehicle>>());
      expect(updates.items, isA<List<TransitTripUpdate>>());
      print(
        'STATE_SAMPLE SA realtime vehicles=${vehicles.items.length} '
        'tripUpdates=${updates.items.length} alerts=${alerts.items.length}',
      );
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
