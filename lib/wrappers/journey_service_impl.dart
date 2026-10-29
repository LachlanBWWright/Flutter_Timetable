import 'package:lbww_flutter/schema/database.dart' as db;

import '../logs/logger.dart';

class JourneyLoadResult {
  const JourneyLoadResult({
    required this.pinnedJourneys,
    required this.unpinnedJourneys,
    this.succeeded = true,
  });

  final List<db.Journey> pinnedJourneys;
  final List<db.Journey> unpinnedJourneys;

  /// False means storage failed; empty lists can still be a valid empty result.
  final bool succeeded;

  List<db.Journey> get allJourneys => [...pinnedJourneys, ...unpinnedJourneys];
}

class JourneyService {
  const JourneyService._();

  static Future<JourneyLoadResult> loadJourneys(db.AppDatabase database) async {
    try {
      final pinnedJourneys = await database.getPinnedJourneys();
      final unpinnedJourneys = await database.getUnpinnedJourneys();
      return JourneyLoadResult(
        pinnedJourneys: pinnedJourneys,
        unpinnedJourneys: unpinnedJourneys,
      );
    } on Exception catch (error, stackTrace) {
      safeLogError(
        'Failed to load journeys',
        error: error,
        stackTrace: stackTrace,
      );
      return const JourneyLoadResult(
        pinnedJourneys: <db.Journey>[],
        unpinnedJourneys: <db.Journey>[],
        succeeded: false,
      );
    }
  }

  static Future<bool> deleteJourney(db.AppDatabase database, int tripId) async {
    try {
      await database.deleteJourney(tripId);
      return true;
    } on Exception catch (error, stackTrace) {
      safeLogError(
        'Failed to delete journey $tripId',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<bool> toggleJourneyPin(
    db.AppDatabase database,
    int tripId,
    bool isPinned,
  ) async {
    try {
      await database.toggleJourneyPin(tripId, !isPinned);
      return true;
    } on Exception catch (error, stackTrace) {
      safeLogError(
        'Failed to toggle journey pin for $tripId',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<bool> insertJourney(
    db.AppDatabase database,
    db.JourneysCompanion companion,
  ) async {
    try {
      await database.insertJourney(companion);
      return true;
    } on Exception catch (error, stackTrace) {
      safeLogError(
        'Failed to insert journey',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
