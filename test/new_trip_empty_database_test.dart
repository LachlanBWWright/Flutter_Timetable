import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lbww_flutter/new_trip.dart';
import 'package:lbww_flutter/schema/database.dart';

void main() {
  testWidgets(
    'empty database fetches, retries, caches, and loads newly selected modes',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync('trip-stops-test');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => directory.path,
      );
      await tester.runAsync(() async {
        await AppDatabase().customSelect('SELECT 1').get();
      });
      addTearDown(() async {
        await tester.runAsync(() async {
          await AppDatabase().close();
          await directory.delete(recursive: true);
        });
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
      });
      final files = {
        'stops.txt': 'stop_id,stop_name,stop_lat,stop_lon\ncentral,Central,-33.88,151.20\ntownhall,Town Hall,-33.87,151.20\n',
        'routes.txt': 'route_id,route_short_name,route_long_name,route_type\nr,T1,North Shore,2\n',
        'calendar_dates.txt': 'service_id,date,exception_type\ns,20261106,1\n',
        'trips.txt': 'route_id,service_id,trip_id\nr,s,t\n',
        'stop_times.txt': 'trip_id,arrival_time,departure_time,stop_id,stop_sequence\nt,10:00:00,10:00:00,central,1\nt,10:02:00,10:02:00,townhall,2\n',
      };
      final archive = Archive();
      for (final entry in files.entries) {
        final bytes = utf8.encode(entry.value);
        archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
      }
      final zip = ZipEncoder().encode(archive);
      final metroArchive = Archive();
      for (final entry in files.entries) {
        final bytes = utf8.encode(
          entry.value
              .replaceAll('Central', 'Metro Central')
              .replaceAll('North Shore,2', 'North Shore,1'),
        );
        metroArchive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
      }
      final metroZip = ZipEncoder().encode(metroArchive);
      final requests = <Uri>[];
      await http.runWithClient(
        () async {
          await tester.pumpWidget(const MaterialApp(home: NewTripScreen()));
          await tester.tap(find.byKey(const ValueKey('trip-origin')));
          {
            for (var i = 0; i < 100; i++) {
              await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 20)),
              );
              await tester.pump();
              if (find.text('Retry').evaluate().isNotEmpty) break;
            }
            expect(find.text('Retry'), findsOneWidget);
            await tester.tap(find.text('Retry'));
          }
          for (var i = 0; i < 100; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)),
            );
            await tester.pump();
            if (find.text('Central').evaluate().isNotEmpty) break;
          }
          expect(
            requests.where((uri) => uri.path.endsWith('/sydneytrains')),
            hasLength(2),
          );
          expect(find.text('Central'), findsOneWidget);
          expect(find.textContaining('from Settings'), findsNothing);
          expect(
            requests.every((uri) => uri.path.endsWith('/sydneytrains')),
            isTrue,
          );
          final count = requests.length;
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('trip-origin')));
          await tester.pumpAndSettle();
          expect(find.text('Central'), findsOneWidget);
          expect(requests, hasLength(count));
          await tester.tap(find.byIcon(Icons.subway));
          await tester.pump(const Duration(milliseconds: 350));
          for (var i = 0; i < 100; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)),
            );
            await tester.pump(const Duration(milliseconds: 50));
            if (requests.length > count &&
                find.text('Metro Central').evaluate().isNotEmpty &&
                find.text('Downloading stops and routes…').evaluate().isEmpty) {
              break;
            }
          }
          expect(requests, hasLength(count + 1));
          expect(requests.last.path, endsWith('/metro'));
          expect(find.text('Metro Central'), findsOneWidget);
          final membershipCount = await tester.runAsync(
            () => AppDatabase().getStopLineMembershipCountForEndpoint('metro'),
          );
          expect(membershipCount, greaterThan(0));
          await tester.pumpWidget(const SizedBox.shrink());
          expect(tester.takeException(), isNull);
        },
        () => MockClient((request) async {
          requests.add(request.url);
          if (requests.length == 1) {
            return http.Response('Unavailable', 401);
          }
          return http.Response.bytes(
            request.url.path.endsWith('/metro') ? metroZip : zip,
            200,
          );
        }),
      );
    },
  );
}
