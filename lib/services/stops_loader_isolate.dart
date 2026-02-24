import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../fetch_data/timetable_data.dart';
import '../gtfs/gtfs_data.dart';
// stop type is available via GtfsData import
import 'stops_service.dart';

/// Message types for communication between isolate and main thread
class LoadStopsMessage {
  final List<StopsEndpoint> endpoints;
  final SendPort sendPort;

  LoadStopsMessage(this.endpoints, this.sendPort);
}

class LoadStopsProgress {
  final String message;
  final int current;
  final int total;

  LoadStopsProgress(this.message, this.current, this.total);
}

class LoadStopsResult {
  final bool success;
  final String? error;
  final int stopsLoaded;

  LoadStopsResult(
      {required this.success, this.error, required this.stopsLoaded});
}

/// Service for loading stops data in background using isolates
class StopsLoaderIsolate {
  /// Load stops for multiple endpoints in background isolate
  static Future<void> loadStopsInBackground({
    required List<StopsEndpoint> endpoints,
    required Function(LoadStopsProgress) onProgress,
    required Function(LoadStopsResult) onComplete,
  }) async {
    final receivePort = ReceivePort();

    try {
      await Isolate.spawn(
        _loadStopsWorker,
        LoadStopsMessage(endpoints, receivePort.sendPort),
      );

      await for (final message in receivePort) {
        if (message is LoadStopsProgress) {
          onProgress(message);
        } else if (message is LoadStopsResult) {
          onComplete(message);
          receivePort.close();
          break;
        }
      }
    } catch (e) {
      onComplete(LoadStopsResult(
        success: false,
        error: e.toString(),
        stopsLoaded: 0,
      ));
      receivePort.close();
    }
  }

  /// Worker function that runs in the isolate
  static Future<void> _loadStopsWorker(LoadStopsMessage message) async {
    final sendPort = message.sendPort;
    int totalLoaded = 0;
    int current = 0;
    final total = message.endpoints.length;

    try {
      for (final endpoint in message.endpoints) {
        current++;
        sendPort.send(LoadStopsProgress(
          'Loading ${endpoint.key}...',
          current,
          total,
        ));

        try {
          // Fetch GTFS data from endpoint
          final gtfsData = await _fetchGtfsDataForEndpoint(endpoint);

          if (gtfsData != null && gtfsData.stops.isNotEmpty) {
            // Store stops to database
            await StopsService.storeStopsToDatabase(
              gtfsData.stops,
              endpoint,
            );
            totalLoaded += gtfsData.stops.length;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading stops for endpoint ${endpoint.key}: $e');
          }
          // Continue with next endpoint even if one fails
        }
      }

      sendPort.send(LoadStopsResult(
        success: true,
        stopsLoaded: totalLoaded,
      ));
    } catch (e) {
      sendPort.send(LoadStopsResult(
        success: false,
        error: e.toString(),
        stopsLoaded: totalLoaded,
      ));
    }
  }

  /// Helper function to fetch GTFS data for an endpoint
  static Future<GtfsData?> _fetchGtfsDataForEndpoint(
      StopsEndpoint endpoint) async {
    switch (endpoint) {
      // Trains
      case StopsEndpoint.nswtrains:
        return await fetchNswTrainsGtfsData();
      case StopsEndpoint.sydneytrains:
        return await fetchSydneyTrainsGtfsData();
      case StopsEndpoint.metro:
        return await fetchMetroGtfsData();

      // Light Rail
      case StopsEndpoint.lightrailInnerwest:
        return await fetchLightRailInnerWestGtfsData();
      case StopsEndpoint.lightrailNewcastle:
        return await fetchLightRailNewcastleGtfsData();
      case StopsEndpoint.lightrailCbdandsoutheast:
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case StopsEndpoint.lightrailParramatta:
        return await fetchLightRailParramattaGtfsData();

      // Buses
      case StopsEndpoint.buses:
        return await fetchBusesGtfsData();
      case StopsEndpoint.busesSbsc006:
        return await fetchBusesSBSC006GtfsData();
      case StopsEndpoint.busesGbsc001:
        return await fetchBusesGSBC001GtfsData();
      case StopsEndpoint.busesGsbc002:
        return await fetchBusesGSBC002GtfsData();
      case StopsEndpoint.busesGsbc003:
        return await fetchBusesGSBC003GtfsData();
      case StopsEndpoint.busesGsbc004:
        return await fetchBusesGSBC004GtfsData();
      case StopsEndpoint.busesGsbc007:
        return await fetchBusesGSBC007GtfsData();
      case StopsEndpoint.busesGsbc008:
        return await fetchBusesGSBC008GtfsData();
      case StopsEndpoint.busesGsbc009:
        return await fetchBusesGSBC009GtfsData();
      case StopsEndpoint.busesGsbc010:
        return await fetchBusesGSBC010GtfsData();
      case StopsEndpoint.busesGsbc014:
        return await fetchBusesGSBC014GtfsData();
      case StopsEndpoint.busesOsmbsc001:
        return await fetchBusesOSMBSC001GtfsData();
      case StopsEndpoint.busesOsmbsc002:
        return await fetchBusesOSMBSC002GtfsData();
      case StopsEndpoint.busesOsmbsc003:
        return await fetchBusesOSMBSC003GtfsData();
      case StopsEndpoint.busesOsmbsc004:
        return await fetchBusesOSMBSC004GtfsData();
      case StopsEndpoint.busesOmbsc006:
        return await fetchBusesOMBSC006GtfsData();
      case StopsEndpoint.busesOmbsc007:
        return await fetchBusesOMBSC007GtfsData();
      case StopsEndpoint.busesOsmbsc008:
        return await fetchBusesOSMBSC008GtfsData();
      case StopsEndpoint.busesOsmbsc009:
        return await fetchBusesOSMBSC009GtfsData();
      case StopsEndpoint.busesOsmbsc010:
        return await fetchBusesOSMBSC010GtfsData();
      case StopsEndpoint.busesOsmbsc011:
        return await fetchBusesOSMBSC011GtfsData();
      case StopsEndpoint.busesOsmbsc012:
        return await fetchBusesOSMBSC012GtfsData();
      case StopsEndpoint.busesNisc001:
        return await fetchBusesNISC001GtfsData();
      case StopsEndpoint.busesReplacementBus:
        return await fetchBusesReplacementBusGtfsData();

      // Ferries
      case StopsEndpoint.ferriesSydneyFerries:
        return await fetchFerriesSydneyFerriesGtfsData();
      case StopsEndpoint.ferriesMff:
        return await fetchFerriesMFFGtfsData();
      // Unhandled endpoints fall through to null
      default:
        return null;
    }
  }
}
