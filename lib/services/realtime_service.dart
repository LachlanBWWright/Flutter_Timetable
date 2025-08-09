import '../fetch_data/realtime_positions.dart' as positions;
import '../fetch_data/realtime_updates.dart' as updates;
import '../protobuf/gtfs-realtime/gtfs-realtime.pb.dart';

/// Service for managing realtime transport data
class RealtimeService {
  
  /// Get realtime positions for all transport modes
  static Future<Map<String, FeedMessage?>> getAllRealtimePositions() async {
    final results = <String, FeedMessage?>{};
    
    // Trains
    results['sydney_trains'] = await positions.fetchSydneyTrainsPositions();
    results['nsw_trains'] = await positions.fetchNswTrainsPositions();
    results['metro'] = await positions.fetchSydneyMetroPositions();
    
    // Buses  
    results['buses'] = await positions.fetchBusesPositions();
    
    // Light Rail
    results['lightrail_cbd_southeast'] = await positions.fetchLightRailCbdAndSoutheastPositions();
    results['lightrail_innerwest'] = await positions.fetchLightRailInnerWestPositions();
    results['lightrail_newcastle'] = await positions.fetchLightRailNewcastlePositions();
    results['lightrail_parramatta'] = await positions.fetchLightRailParramattaPositions();
    
    // Ferries
    results['ferries_sydney'] = await positions.fetchFerriesSydneyFerriesPositions();
    results['ferries_mff'] = await positions.fetchFerriesMFFPositions();
    
    return results;
  }
  
  /// Get realtime trip updates for all transport modes  
  static Future<Map<String, FeedMessage?>> getAllRealtimeUpdates() async {
    final results = <String, FeedMessage?>{};
    
    // Trains
    results['sydney_trains'] = await updates.fetchSydneyTrainsUpdates();
    results['nsw_trains'] = await updates.fetchNswTrainsUpdates();
    results['metro'] = await updates.fetchSydneyMetroUpdates();
    
    // Buses
    results['buses'] = await updates.fetchBusesUpdates();
    
    // Light Rail
    results['lightrail_cbd_southeast'] = await updates.fetchLightRailCbdAndSoutheastUpdates();
    results['lightrail_innerwest'] = await updates.fetchLightRailInnerWestUpdates();
    results['lightrail_newcastle'] = await updates.fetchLightRailNewcastleUpdates();
    results['lightrail_parramatta'] = await updates.fetchLightRailParramattaUpdates();
    
    // Ferries
    results['ferries_sydney'] = await updates.fetchFerriesSydneyFerriesUpdates();
    results['ferries_mff'] = await updates.fetchFerriesMFFUpdates();
    
    return results;
  }
  
  /// Get positions for specific transport mode
  static Future<FeedMessage?> getPositionsForMode(String mode) async {
    switch (mode.toLowerCase()) {
      case 'sydney_trains':
        return await positions.fetchSydneyTrainsPositions();
      case 'nsw_trains':
        return await positions.fetchNswTrainsPositions();
      case 'metro':
        return await positions.fetchSydneyMetroPositions();
      case 'buses':
        return await positions.fetchBusesPositions();
      case 'lightrail_cbd_southeast':
        return await positions.fetchLightRailCbdAndSoutheastPositions();
      case 'lightrail_innerwest':
        return await positions.fetchLightRailInnerWestPositions();
      case 'lightrail_newcastle':
        return await positions.fetchLightRailNewcastlePositions();
      case 'lightrail_parramatta':
        return await positions.fetchLightRailParramattaPositions();
      case 'ferries_sydney':
        return await positions.fetchFerriesSydneyFerriesPositions();
      case 'ferries_mff':
        return await positions.fetchFerriesMFFPositions();
      default:
        return null;
    }
  }
  
  /// Get trip updates for specific transport mode
  static Future<FeedMessage?> getUpdatesForMode(String mode) async {
    switch (mode.toLowerCase()) {
      case 'sydney_trains':
        return await updates.fetchSydneyTrainsUpdates();
      case 'nsw_trains':
        return await updates.fetchNswTrainsUpdates();
      case 'metro':
        return await updates.fetchSydneyMetroUpdates();
      case 'buses':
        return await updates.fetchBusesUpdates();
      case 'lightrail_cbd_southeast':
        return await updates.fetchLightRailCbdAndSoutheastUpdates();
      case 'lightrail_innerwest':
        return await updates.fetchLightRailInnerWestUpdates();
      case 'lightrail_newcastle':
        return await updates.fetchLightRailNewcastleUpdates();
      case 'lightrail_parramatta':
        return await updates.fetchLightRailParramattaUpdates();
      case 'ferries_sydney':
        return await updates.fetchFerriesSydneyFerriesUpdates();
      case 'ferries_mff':
        return await updates.fetchFerriesMFFUpdates();
      default:
        return null;
    }
  }
  
  /// Get region bus positions
  static Future<List<FeedMessage?>> getRegionBusPositions() async {
    return await positions.getAllRegionBuses();
  }
  
  /// Get region bus updates
  static Future<List<FeedMessage?>> getRegionBusUpdates() async {
    return await updates.fetchAllRegionBuses();
  }
  
  /// Get all ferry positions
  static Future<List<FeedMessage?>> getAllFerryPositions() async {
    return await positions.getAllFerries();
  }
  
  /// Get all ferry updates
  static Future<List<FeedMessage?>> getAllFerryUpdates() async {
    return await updates.fetchAllFerries();
  }
  
  /// Get all light rail positions
  static Future<List<FeedMessage?>> getAllLightRailPositions() async {
    return await positions.getAllLightRail();
  }
  
  /// Get all light rail updates
  static Future<List<FeedMessage?>> getAllLightRailUpdates() async {
    return await updates.fetchAllLightRail();
  }
  
  /// Extract vehicle positions from feed message
  static List<VehiclePosition> extractVehiclePositions(FeedMessage? feed) {
    if (feed == null) return [];
    
    return feed.entity
        .where((entity) => entity.hasVehicle())
        .map((entity) => entity.vehicle)
        .toList();
  }
  
  /// Extract trip updates from feed message
  static List<TripUpdate> extractTripUpdates(FeedMessage? feed) {
    if (feed == null) return [];
    
    return feed.entity
        .where((entity) => entity.hasTripUpdate())
        .map((entity) => entity.tripUpdate)
        .toList();
  }
  
  /// Get realtime status summary
  static Future<Map<String, dynamic>> getRealtimeStatusSummary() async {
    final positions = await getAllRealtimePositions();
    final updates = await getAllRealtimeUpdates();
    
    final summary = <String, dynamic>{};
    
    for (final mode in positions.keys) {
      final positionCount = extractVehiclePositions(positions[mode]).length;
      final updateCount = extractTripUpdates(updates[mode]).length;
      
      summary[mode] = {
        'vehicles': positionCount,
        'updates': updateCount,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
    
    return summary;
  }
}