import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lbww_flutter/schema/database.dart' as db;
import 'package:lbww_flutter/transit/gtfs/gtfs_journey_planner.dart';
import 'package:lbww_flutter/transit/gtfs/persistent_gtfs_store.dart';
import 'package:lbww_flutter/transit/runtime/cancellable_compute.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/trip.dart';

int _busy(int milliseconds) {
  final end = DateTime.now().add(Duration(milliseconds: milliseconds));
  var n = 0;
  while (DateTime.now().isBefore(end)) {
    n++;
  }
  return n;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native timetable survives reopen offline and computes independent of device timezone',
    (tester) async {
      final directory = await Directory.systemTemp.createTemp(
        'transit_android_',
      );
      final file = File('${directory.path}/timetable.sqlite');
      var database = db.AppDatabase.connect(NativeDatabase(file));
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });
      final archive = Archive();
      final files = {
        'agency.txt': 'agency_id,agency_name,agency_url,agency_timezone\nx,Test,https://example.com,Australia/Brisbane\n',
        'stops.txt':
            'stop_id,stop_name,wheelchair_boarding\nA,Alpha,1\nB,Beta,1\n',
        'routes.txt': 'route_id,route_short_name,route_long_name,route_type\nR,1,Route,3\n',
        'trips.txt':
            'route_id,service_id,trip_id,wheelchair_accessible\nR,S,T,1\n',
        'calendar_dates.txt': 'service_id,date,exception_type\nS,20260813,1\n',
        'stop_times.txt': 'trip_id,arrival_time,departure_time,stop_id,stop_sequence\nT,10:00:00,10:00:00,A,1\nT,10:20:00,10:20:00,B,2\n',
      };
      for (final entry in files.entries) {
        archive.addFile(ArchiveFile.string(entry.key, entry.value));
      }
      final bytes = Uint8List.fromList(ZipEncoder().encode(archive));
      final now = DateTime.utc(2026, 8, 13);
      await PersistentGtfsStore(database: database, now: () => now).load(
        source: 'qld:SEQ',
        requireTimetable: true,
        fetch: () async => bytes,
      );
      await database.close();
      database = db.AppDatabase.connect(NativeDatabase(file));
      var offlineAttempts = 0;
      final data =
          await PersistentGtfsStore(
            database: database,
            now: () => now.add(const Duration(days: 2)),
          ).load(
            source: 'qld:SEQ',
            requireTimetable: true,
            fetch: () async {
              offlineAttempts++;
              throw const NetworkUnavailable(message: 'Offline test');
            },
          );
      expect(offlineAttempts, 1);
      expect(data.timetable!.offlineFallback, isTrue);
      TransitStopRef stop(String id) => TransitStopRef(
        region: TransitRegion.queensland,
        provider: TransitProviderId.translink,
        sourceId: const TransitSourceId('qld:SEQ'),
        stopId: id,
      );
      final planner = GtfsJourneyPlanner(
        region: TransitRegion.queensland,
        provider: TransitProviderId.translink,
        loadData: (_) async => data,
      );
      final plan = await planner.planJourney(
        JourneyPlanRequest(
          origin: stop('A'),
          destination: stop('B'),
          when: DateTime.utc(2026, 8, 13, 0, 25),
          arrivalBased: true,
          accessibility: TransitAccessibility.stepFreeOnly,
          walkingLimit: Duration.zero,
        ),
      );
      expect(
        plan.journeys.single.legs.single.arrivalTime,
        DateTime.utc(2026, 8, 13, 0, 20),
      );
      final token = TransitCancellation();
      final work = runTransitCompute(_busy, 10000, cancellation: token);
      final checked = expectLater(
        work,
        throwsA(isA<TransitOperationCancelled>()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      token.cancel();
      await checked;
      expect(await runTransitCompute(_busy, 10), greaterThan(0));
    },
  );
  testWidgets(
    'journey options expose date, arrive-by, access and walking controls',
    (tester) async {
      final trip = const db.Journey(
        id: 1,
        origin: 'Alpha',
        originId: 'queensland|translink|qld:SEQ|A',
        destination: 'Beta',
        destinationId: 'queensland|translink|qld:SEQ|B',
        tripType: 'stop_pair',
        isPinned: false,
      );
      await tester.pumpWidget(
        MaterialApp(home: TripScreen(trip: trip, skipInitialLoad: true)),
      );
      await tester.tap(find.byTooltip('Journey options'));
      await tester.pumpAndSettle();
      expect(find.text('Arrive by'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Total walking time'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    },
  );
}
