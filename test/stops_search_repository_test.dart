import 'package:flutter_test/flutter_test.dart';
import 'package:lbww_flutter/transit/transit.dart';
import 'package:lbww_flutter/widgets/stops/stops_search_repository.dart';

class _Stops implements StopRepository {
  _Stops(this.search);

  final Future<List<TransitStop>> Function(StopSearchRequest) search;

  @override
  Future<List<TransitStop>> searchStops(StopSearchRequest request) =>
      search(request);

  @override
  Future<TransitStop?> getStop(TransitStopRef stop) async => null;
}

TransitRegionServices _service(
  Future<List<TransitStop>> Function(StopSearchRequest) search,
) {
  const provider = TransitProviderId.tfnsw;
  return TransitRegionServices(
    region: TransitRegion.nsw,
    provider: provider,
    stops: _Stops(search),
    attribution: const TransitProviderAttribution(
      provider: provider,
      name: 'Test',
      licenseName: 'Test license',
      url: 'https://example.com',
    ),
  );
}

TransitStop _stop(String name) => TransitStop(
  ref: TransitStopRef(
    region: TransitRegion.nsw,
    provider: TransitProviderId.tfnsw,
    sourceId: const TransitSourceId('test'),
    stopId: name,
  ),
  name: name,
);

void main() {
  test('keeps successful regional results when another region fails', () async {
    final repository = RegionalStopsSearchRepository(
      enabledServices: () => [
        _service((request) async {
          expect(request.query, 'Central');
          expect(request.limit, 50);
          return [_stop('Central')];
        }),
        _service((_) async => throw Exception('backend unavailable')),
      ],
    );

    expect((await repository.searchStops('Central')).map((s) => s.name), [
      'Central',
    ]);
  });

  test('reports failure when every enabled region fails', () async {
    final repository = RegionalStopsSearchRepository(
      enabledServices: () => [
        _service((_) async => throw Exception('first unavailable')),
        _service((_) async => throw Exception('second unavailable')),
      ],
    );

    await expectLater(
      repository.searchStops('Central'),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'allows programming Errors from regional services to propagate',
    () async {
      final repository = RegionalStopsSearchRepository(
        enabledServices: () => [
          _service((_) async => throw StateError('programming error')),
        ],
      );

      await expectLater(
        repository.searchStops('Central'),
        throwsA(isA<StateError>()),
      );
    },
  );
}
