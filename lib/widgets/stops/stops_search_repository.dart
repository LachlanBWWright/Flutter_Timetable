import 'package:lbww_flutter/transit/transit.dart';

/// Searches the currently enabled regional stop repositories.
class RegionalStopsSearchRepository {
  RegionalStopsSearchRepository({required this.enabledServices});

  final List<TransitRegionServices> Function() enabledServices;

  Future<List<TransitStop>> searchStops(String query) async {
    final services = enabledServices();
    var failures = 0;
    final regionalResults = await Future.wait(
      services.map((region) async {
        try {
          return await region.stops.searchStops(
            StopSearchRequest(query: query, limit: 50),
          );
        } on Exception {
          failures++;
          return const <TransitStop>[];
        }
      }),
    );
    if (services.isNotEmpty && failures == services.length) {
      throw Exception('Stop search unavailable');
    }
    return regionalResults
        .expand((stops) => stops)
        .take(50)
        .toList(growable: false);
  }
}
