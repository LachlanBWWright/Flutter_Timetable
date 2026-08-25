import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/journey_service.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/victoria/adapters/ptv_transit_adapter.dart';
import 'package:lbww_flutter/victoria/services/victoria_gtfs_endpoints.dart';
import 'package:test/test.dart';

void main() {
  final runLiveTests = Platform.environment['RUN_VIC_API_TESTS'] == 'true';

  test(
    'Victoria user flow imports, finds, plans, and saves a trip',
    () async {
      await dotenv.load();
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      try {
        final services = buildPtvRegionServices(database: database);
        final staticGtfs = services.staticGtfs;
        expect(staticGtfs, isNotNull);

        final progress = await staticGtfs!
            .refreshStaticData(const StaticImportRequest())
            .toList();
        expect(progress, isNotEmpty);
        expect(progress.last.error, isNull);
        expect(progress.last.completed, 1);

        final originCandidates = await services.stops.searchStops(
          const StopSearchRequest(query: 'Flinders Street', limit: 20),
        );
        final destinationCandidates = await services.stops.searchStops(
          const StopSearchRequest(query: 'Southern Cross', limit: 20),
        );
        expect(originCandidates, isNotEmpty);
        expect(destinationCandidates, isNotEmpty);

        expect(services.departures, isNotNull);
        expect(services.journeyPlanner, isNotNull);

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
        expect(selectedPlan, isNotNull);
        expect(selectedPlan!.journeys, isNotEmpty);
        final origin = selectedOrigin!;
        final destination = selectedDestination!;
        print(
          'STATE_SAMPLE VIC stop=${origin.name} id=${origin.ref.stopId} '
          'destination=${destination.name} id=${destination.ref.stopId} '
          'journeys=${selectedPlan!.journeys.length}',
        );
        expect(await services.stops.getStop(origin.ref), isNotNull);

        final saved = await JourneyService.insertJourney(
          database,
          db.JourneysCompanion.insert(
            origin: origin.name,
            originId: origin.ref.storageKey,
            destination: destination.name,
            destinationId: destination.ref.storageKey,
            mode: driftValue(origin.mode),
          ),
        );
        expect(saved, isTrue);
        final journeys = await database.getAllJourneys();
        expect(
          journeys.any(
            (journey) =>
                journey.originId == origin.ref.storageKey &&
                journey.destinationId == destination.ref.storageKey,
          ),
          isTrue,
        );
      } finally {
        await database.close();
      }
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(minutes: 8)),
  );

  test(
    'Victoria realtime feeds decode with the supplied portal API key',
    () async {
      await dotenv.load();
      final services = buildPtvRegionServices();
      expect(services.realtime, isNotNull);
      for (final feed in victoriaRealtimeFeedSets) {
        final request = RealtimeRequest(
          sourceId: TransitSourceId('ptv:${feed.id}'),
        );
        final updates = await services.realtime!.getTripUpdates(request);
        final vehicles = await services.realtime!.getVehiclePositions(request);
        expect(updates.fetchedAt, isNotNull, reason: feed.id);
        expect(vehicles.fetchedAt, isNotNull, reason: feed.id);
        if (feed.alertsUrl != null) {
          final alerts = await services.realtime!.getAlerts(request);
          expect(alerts.fetchedAt, isNotNull, reason: feed.id);
        }
      }
      expect(services.disruptions, isNotNull);
      final disruptions = await services.disruptions!.getDisruptions(
        const DisruptionRequest(),
      );
      expect(disruptions, isA<List<TransitAlert>>());
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

// Kept local to make the test's persisted model setup explicit without
// importing the generated Drift Value type into every assertion.
drift.Value<String?> driftValue(TransportMode? mode) =>
    drift.Value(mode?.toString().split('.').last);
