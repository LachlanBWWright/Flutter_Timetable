import 'dart:io';

import 'package:drift/native.dart';
import 'package:lbww_flutter/northern_territory/nt_gtfs.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/services/journey_service.dart';
import 'package:lbww_flutter/tasmania/tasmania_gtfs.dart';
import 'package:lbww_flutter/transit/domain/transit_types.dart';
import 'package:lbww_flutter/transit/interfaces/transit_interfaces.dart';
import 'package:lbww_flutter/transit/registry/transit_registry.dart';
import 'package:lbww_flutter/western_australia/transperth_gtfs.dart';
import 'package:test/test.dart';

void main() {
  final runLiveTests =
      Platform.environment['RUN_PUBLIC_STATE_API_TESTS'] == 'true';

  final cases =
      <
        ({
          String name,
          String originQuery,
          String destinationQuery,
          TransitRegionServices Function({db.AppDatabase? database}) build,
        })
      >[
        (
          name: 'Tasmania',
          originQuery: 'Argyle',
          destinationQuery: 'Hobart City',
          build: buildTasmaniaRegionServices,
        ),
        (
          name: 'Northern Territory',
          originQuery: 'Palmerston',
          destinationQuery: 'Casuarina',
          build: buildNorthernTerritoryRegionServices,
        ),
        (
          name: 'Western Australia',
          originQuery: 'Carousel',
          destinationQuery: 'Kelmscott',
          build: buildWesternAustraliaRegionServices,
        ),
      ];

  for (final testCase in cases) {
    test(
      '${testCase.name} user flow imports, finds, and plans a trip',
      () async {
        final database = db.AppDatabase.connect(NativeDatabase.memory());
        try {
          final services = testCase.build(database: database);
          final progress = await services.staticGtfs!
              .refreshStaticData(const StaticImportRequest())
              .toList();
          expect(progress, isNotEmpty);
          expect(progress.where((item) => item.error != null), isEmpty);
          expect(progress.last.completed, progress.last.total);

          if (testCase.name == 'Northern Territory') {
            expect(
              progress.map((item) => item.sourceId?.value),
              containsAll(<String>['nt:darwin', 'nt:alice']),
            );
            final aliceStops = await services.stops.searchStops(
              const StopSearchRequest(query: 'Alice', limit: 20),
            );
            expect(aliceStops, isNotEmpty);
            expect(
              aliceStops.every((stop) => stop.ref.sourceId.value == 'nt:alice'),
              isTrue,
            );
          }

          final originCandidates = await services.stops.searchStops(
            StopSearchRequest(query: testCase.originQuery, limit: 20),
          );
          final destinationCandidates = await services.stops.searchStops(
            StopSearchRequest(query: testCase.destinationQuery, limit: 20),
          );
          expect(originCandidates, isNotEmpty);
          expect(destinationCandidates, isNotEmpty);

          TransitStop? stop;
          List<TransitDeparture> departures = const <TransitDeparture>[];
          TransitStop? destination;
          JourneyPlan? plan;
          for (final candidateOrigin in originCandidates) {
            final candidateDepartures = await services.departures!
                .getDepartures(DepartureRequest(stop: candidateOrigin.ref));
            if (candidateDepartures.isEmpty) continue;
            for (final candidateDestination in destinationCandidates) {
              if (candidateOrigin.ref == candidateDestination.ref) continue;
              final candidatePlan = await services.journeyPlanner!.planJourney(
                JourneyPlanRequest(
                  origin: candidateOrigin.ref,
                  destination: candidateDestination.ref,
                ),
              );
              if (candidatePlan.journeys.isNotEmpty) {
                stop = candidateOrigin;
                departures = candidateDepartures;
                destination = candidateDestination;
                plan = candidatePlan;
                break;
              }
            }
            if (plan != null) break;
          }
          expect(stop, isNotNull);
          expect(destination, isNotNull);
          expect(departures, isNotEmpty);
          expect(departures.first.tripId, isNotEmpty);
          expect(departures.first.plannedTime, isNotNull);
          expect(departures.first.stop, selectedStopRef(stop));
          expect(plan?.journeys, isNotEmpty);
          expect(plan!.journeys.first.legs, isNotEmpty);
          expect(plan.journeys.first.legs.first.origin.name, isNotEmpty);
          expect(plan.journeys.first.legs.first.destination.name, isNotEmpty);
          expect(await services.stops.getStop(stop!.ref), isNotNull);
          print(
            'STATE_SAMPLE ${testCase.name} stop=${stop!.name} '
            'id=${stop.ref.stopId} destination=${destination!.name} '
            'id=${destination.ref.stopId} departures=${departures.length} '
            'journeys=${plan!.journeys.length}',
          );

          final saved = await JourneyService.insertJourney(
            database,
            db.JourneysCompanion.insert(
              origin: stop!.name,
              originId: stop.ref.storageKey,
              destination: destination!.name,
              destinationId: destination.ref.storageKey,
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
  }
}

TransitStopRef selectedStopRef(TransitStop? stop) => stop!.ref;
