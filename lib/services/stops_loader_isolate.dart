import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../constants/transport_modes.dart';
import '../fetch_data/timetable_data.dart';
import '../gtfs/stop.dart';
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

  LoadStopsResult({required this.success, this.error, required this.stopsLoaded});
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
          'Loading ${endpoint.name}...',
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
            print('Error loading stops for endpoint ${endpoint.name}: $e');
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
  static Future<dynamic> _fetchGtfsDataForEndpoint(StopsEndpoint endpoint) async {
    switch (endpoint) {
      // Trains
      case StopsEndpoint.nswtrains:
        return await fetchNswTrainsGtfsData();
      case StopsEndpoint.sydneytrains:
        return await fetchSydneyTrainsGtfsData();
      case StopsEndpoint.metro:
        return await fetchMetroGtfsData();

      // Light Rail
      case StopsEndpoint.lightrail_innerwest:
        return await fetchLightRailInnerWestGtfsData();
      case StopsEndpoint.lightrail_newcastle:
        return await fetchLightRailNewcastleGtfsData();
      case StopsEndpoint.lightrail_cbdandsoutheast:
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case StopsEndpoint.lightrail_parramatta:
        return await fetchLightRailParramattaGtfsData();

      // Buses
      case StopsEndpoint.buses:
        return await fetchBusesGtfsData();
      case StopsEndpoint.buses_SBSC006:
        return await fetchBusesSBSC006GtfsData();
      case StopsEndpoint.buses_GSBC001:
        return await fetchBusesGSBC001GtfsData();
      case StopsEndpoint.buses_GSBC002:
        return await fetchBusesGSBC002GtfsData();
      case StopsEndpoint.buses_GSBC003:
        return await fetchBusesGSBC003GtfsData();
      case StopsEndpoint.buses_GSBC004:
        return await fetchBusesGSBC004GtfsData();
      case StopsEndpoint.buses_GSBC007:
        return await fetchBusesGSBC007GtfsData();
      case StopsEndpoint.buses_GSBC008:
        return await fetchBusesGSBC008GtfsData();
      case StopsEndpoint.buses_GSBC009:
        return await fetchBusesGSBC009GtfsData();
      case StopsEndpoint.buses_GSBC010:
        return await fetchBusesGSBC010GtfsData();
      case StopsEndpoint.buses_GSBC014:
        return await fetchBusesGSBC014GtfsData();
      case StopsEndpoint.buses_OSMBSC001:
        return await fetchBusesOSMBSC001GtfsData();
      case StopsEndpoint.buses_OSMBSC002:
        return await fetchBusesOSMBSC002GtfsData();
      case StopsEndpoint.buses_OSMBSC003:
        return await fetchBusesOSMBSC003GtfsData();
      case StopsEndpoint.buses_OSMBSC004:
        return await fetchBusesOSMBSC004GtfsData();
      case StopsEndpoint.buses_OMBSC006:
        return await fetchBusesOMBSC006GtfsData();
      case StopsEndpoint.buses_OMBSC007:
        return await fetchBusesOMBSC007GtfsData();
      case StopsEndpoint.buses_OSMBSC008:
        return await fetchBusesOSMBSC008GtfsData();
      case StopsEndpoint.buses_OSMBSC009:
        return await fetchBusesOSMBSC009GtfsData();
      case StopsEndpoint.buses_OSMBSC010:
        return await fetchBusesOSMBSC010GtfsData();
      case StopsEndpoint.buses_OSMBSC011:
        return await fetchBusesOSMBSC011GtfsData();
      case StopsEndpoint.buses_OSMBSC012:
        return await fetchBusesOSMBSC012GtfsData();
      case StopsEndpoint.buses_NISC001:
        return await fetchBusesNISC001GtfsData();
      case StopsEndpoint.buses_ReplacementBus:
        return await fetchBusesReplacementBusGtfsData();

      // Ferries
      case StopsEndpoint.ferries_sydneyferries:
        return await fetchFerriesSydneyFerriesGtfsData();
      case StopsEndpoint.ferries_MFF:
        return await fetchFerriesMFFGtfsData();
    }
  }
}
