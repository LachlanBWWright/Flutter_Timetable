import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/journey_service.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/queensland/adapters/translink_transit_adapter.dart';
import 'package:test/test.dart';

void main() {
  final runLiveTests = Platform.environment['RUN_QLD_API_TESTS'] == 'true';

  test(
    'QLD user flow imports, finds, plans, and saves a trip',
    () async {
      final database = db.AppDatabase.connect(NativeDatabase.memory());
      final services = buildTranslinkRegionServices(database: database);
      final staticGtfs = services.staticGtfs;
      final departures = services.departures;
      final planner = services.journeyPlanner;
      expect(staticGtfs, isNotNull);
      expect(departures, isNotNull);
      expect(planner, isNotNull);

      final progress = await staticGtfs!
          .refreshStaticData(
            const StaticImportRequest(sourceIds: [TransitSourceId('qld:SEQ')]),
          )
          .toList();
      expect(progress, isNotEmpty);
      expect(progress.last.error, isNull);
      expect(progress.last.completed, 1);

      final originCandidates = await services.stops.searchStops(
        const StopSearchRequest(query: 'Central', limit: 20),
      );
      final destinationCandidates = await services.stops.searchStops(
        const StopSearchRequest(query: 'South Bank', limit: 20),
      );
      expect(originCandidates, isNotEmpty);
      expect(destinationCandidates, isNotEmpty);

      TransitStop? origin;
      TransitStop? destination;
      JourneyPlan? plan;
      for (final candidateOrigin in originCandidates) {
        final candidateDepartures = await departures!.getDepartures(
          DepartureRequest(stop: candidateOrigin.ref),
        );
        if (candidateDepartures.isEmpty) continue;
        for (final candidateDestination in destinationCandidates) {
          if (candidateOrigin.ref == candidateDestination.ref) continue;
          final candidatePlan = await planner!.planJourney(
            JourneyPlanRequest(
              origin: candidateOrigin.ref,
              destination: candidateDestination.ref,
            ),
          );
          if (candidatePlan.journeys.isNotEmpty) {
            origin = candidateOrigin;
            destination = candidateDestination;
            plan = candidatePlan;
            break;
          }
        }
        if (plan != null) break;
      }

      expect(origin, isNotNull);
      expect(destination, isNotNull);
      expect(plan, isNotNull);
      expect(plan!.journeys, isNotEmpty);
      final selectedOrigin = origin!;
      final selectedDestination = destination!;
      print(
        'STATE_SAMPLE QLD stop=${selectedOrigin.name} '
        'id=${selectedOrigin.ref.stopId} destination=${selectedDestination.name} '
        'id=${selectedDestination.ref.stopId} journeys=${plan!.journeys.length}',
      );

      final saved = await JourneyService.insertJourney(
        database,
        db.JourneysCompanion.insert(
          origin: selectedOrigin.name,
          originId: selectedOrigin.ref.storageKey,
          destination: selectedDestination.name,
          destinationId: selectedDestination.ref.storageKey,
          mode: drift.Value(selectedOrigin.mode?.id),
        ),
      );
      expect(saved, isTrue);

      final journeys = await database.getAllJourneys();
      final savedJourney = journeys.lastWhere(
        (journey) =>
            journey.originId == selectedOrigin.ref.storageKey &&
            journey.destinationId == selectedDestination.ref.storageKey,
      );

      await database.deleteJourney(savedJourney.id);
    },
    skip: !runLiveTests,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
