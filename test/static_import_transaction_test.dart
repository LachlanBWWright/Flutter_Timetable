import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/schema/database_errors.dart';

void main() {
  late AppDatabase database;
  setUp(() => database = AppDatabase.connect(NativeDatabase.memory()));
  tearDown(() => database.close());

  Future<void> publish(String endpoint, String id, {bool duplicate = false}) =>
      database.replaceStaticDataForEndpoint(
        endpoint: endpoint,
        stopRows: [
          StopsCompanion.insert(
            endpoint: endpoint,
            stopId: id,
            stopName: 'Stop $id',
          ),
        ],
        routeRows: [
          RoutesCompanion.insert(
            endpoint: endpoint,
            routeId: id,
            lineId: '$endpoint|$id',
          ),
        ],
        memberships: [
          for (var i = 0; i < (duplicate ? 2 : 1); i++)
            StopLineMembershipsCompanion.insert(
              endpoint: endpoint,
              stopId: id,
              stopName: 'Stop $id',
              lineId: '$endpoint|$id',
              lineName: id,
              mode: 'train',
              stopOrder: 1,
            ),
        ],
      );

  test(
    'publishes stops, routes, memberships and success metadata together',
    () async {
      await publish('nswtrains', 'old');
      await publish('metro', 'other');
      await publish('nswtrains', 'new');
      expect(
        (await database.getAllStopsForEndpoint('nswtrains')).single.stopId,
        'new',
      );
      expect(
        (await database.getRoutesForEndpoint('nswtrains')).single.routeId,
        'new',
      );
      expect(
        await database.getStopLineMembershipsForLine('nswtrains|old'),
        isEmpty,
      );
      expect(
        (await database.getStopLineMembershipsForLine(
          'nswtrains|new',
        )).single.stopId,
        'new',
      );
      final status = await database.getStaticCacheStatus('nswtrains');
      expect(status?.stopsUpdatedAt, status?.lineMembershipsUpdatedAt);
      expect(status?.isBuilding, false);
      expect(
        (await database.getAllStopsForEndpoint('metro')).single.stopId,
        'other',
      );
    },
  );

  test(
    'late membership SQL failure rolls back previous tables and timestamps',
    () async {
      await publish('nswtrains', 'old');
      await publish('metro', 'other');
      final before = await database.getStaticCacheStatus('nswtrains');
      await expectLater(
        publish('nswtrains', 'new', duplicate: true),
        throwsA(isA<DatabaseOperationFailure>()),
      );
      expect(
        (await database.getAllStopsForEndpoint('nswtrains')).single.stopId,
        'old',
      );
      expect(
        (await database.getRoutesForEndpoint('nswtrains')).single.routeId,
        'old',
      );
      expect(
        (await database.getStopLineMembershipsForLine(
          'nswtrains|old',
        )).single.stopId,
        'old',
      );
      expect(
        await database.getStopLineMembershipsForLine('nswtrains|new'),
        isEmpty,
      );
      final after = await database.getStaticCacheStatus('nswtrains');
      expect(after?.stopsUpdatedAt, before?.stopsUpdatedAt);
      expect(after?.lineMembershipsUpdatedAt, before?.lineMembershipsUpdatedAt);
      expect(after?.lastBuildFinishedAt, before?.lastBuildFinishedAt);
      expect(
        (await database.getAllStopsForEndpoint('metro')).single.stopId,
        'other',
      );
      expect(
        (await database.getRoutesForEndpoint('metro')).single.routeId,
        'other',
      );
    },
  );

  test(
    'rejects incomplete or cross-endpoint feeds without deleting data',
    () async {
      await publish('nswtrains', 'old');
      await expectLater(
        database.replaceStaticDataForEndpoint(
          endpoint: 'nswtrains',
          stopRows: [],
          routeRows: [],
          memberships: [],
        ),
        throwsArgumentError,
      );
      await expectLater(
        database.replaceStaticDataForEndpoint(
          endpoint: 'nswtrains',
          stopRows: [
            StopsCompanion.insert(
              endpoint: 'metro',
              stopId: 'x',
              stopName: 'X',
            ),
          ],
          routeRows: [
            RoutesCompanion.insert(
              endpoint: 'nswtrains',
              routeId: 'x',
              lineId: 'nswtrains|x',
            ),
          ],
          memberships: [
            StopLineMembershipsCompanion.insert(
              endpoint: 'nswtrains',
              stopId: 'x',
              stopName: 'X',
              lineId: 'nswtrains|x',
              lineName: 'X',
              mode: 'train',
              stopOrder: 1,
            ),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        (await database.getAllStopsForEndpoint('nswtrains')).single.stopId,
        'old',
      );
    },
  );
}
