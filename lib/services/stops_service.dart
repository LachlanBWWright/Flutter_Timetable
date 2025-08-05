import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../fetch_data/timetable_data.dart';
import '../gtfs/stop.dart';

/// Service for managing GTFS stops data - parsing from assets and API endpoints
class StopsService {
  static Database? _database;
  static const String _stopsTable = 'stops';
  
  /// Get or create database instance
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  /// Initialize the stops database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'stops_database.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_stopsTable (
            stop_id TEXT PRIMARY KEY,
            stop_name TEXT NOT NULL,
            stop_lat REAL,
            stop_lon REAL,
            location_type INTEGER,
            parent_station TEXT,
            wheelchair_boarding INTEGER,
            platform_code TEXT,
            endpoint TEXT NOT NULL
          )
        ''');
        
        // Create index for faster queries
        await db.execute('CREATE INDEX idx_stops_endpoint ON $_stopsTable(endpoint)');
        await db.execute('CREATE INDEX idx_stops_name ON $_stopsTable(stop_name)');
      },
    );
  }
  
  /// Parse CSV file from assets and return list of Stop objects
  static Future<List<Stop>> parseStopsFromAsset(String assetPath) async {
    try {
      final csvString = await rootBundle.loadString(assetPath);
      return _parseStopsFromCsv(csvString);
    } catch (e) {
      print('Error loading stops from asset $assetPath: $e');
      return [];
    }
  }
  
  /// Parse CSV string and return list of Stop objects
  static List<Stop> _parseStopsFromCsv(String csvString) {
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
    
    if (csvData.isEmpty) return [];
    
    // Skip header row
    final dataRows = csvData.skip(1);
    final stops = <Stop>[];
    
    for (final row in dataRows) {
      if (row.length >= 8) {
        try {
          stops.add(Stop.fromCsv(row.map((e) => e.toString()).toList()));
        } catch (e) {
          print('Error parsing stop row: $row, error: $e');
        }
      }
    }
    
    return stops;
  }
  
  /// Store stops to database for a specific endpoint
  static Future<void> storeStopsToDatabase(List<Stop> stops, String endpoint) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Clear existing stops for this endpoint
      await txn.delete(_stopsTable, where: 'endpoint = ?', whereArgs: [endpoint]);
      
      // Insert new stops
      for (final stop in stops) {
        await txn.insert(_stopsTable, {
          'stop_id': stop.stopId,
          'stop_name': stop.stopName,
          'stop_lat': stop.stopLat,
          'stop_lon': stop.stopLon,
          'location_type': stop.locationType,
          'parent_station': stop.parentStation,
          'wheelchair_boarding': stop.wheelchairBoarding,
          'platform_code': stop.platformCode,
          'endpoint': endpoint,
        });
      }
    });
  }
  
  /// Get all stops for a specific endpoint from database
  static Future<List<Stop>> getStopsForEndpoint(String endpoint) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _stopsTable,
      where: 'endpoint = ?',
      whereArgs: [endpoint],
      orderBy: 'stop_name',
    );
    
    return maps.map((map) => Stop(
      stopId: map['stop_id'],
      stopName: map['stop_name'],
      stopLat: map['stop_lat'] ?? 0.0,
      stopLon: map['stop_lon'] ?? 0.0,
      locationType: map['location_type'] ?? 0,
      parentStation: map['parent_station'],
      wheelchairBoarding: map['wheelchair_boarding'] ?? 0,
      platformCode: map['platform_code'],
    )).toList();
  }
  
  /// Search stops by name across all endpoints
  static Future<List<Stop>> searchStops(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _stopsTable,
      where: 'stop_name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'stop_name',
      limit: 50,
    );
    
    return maps.map((map) => Stop(
      stopId: map['stop_id'],
      stopName: map['stop_name'],
      stopLat: map['stop_lat'] ?? 0.0,
      stopLon: map['stop_lon'] ?? 0.0,
      locationType: map['location_type'] ?? 0,
      parentStation: map['parent_station'],
      wheelchairBoarding: map['wheelchair_boarding'] ?? 0,
      platformCode: map['platform_code'],
    )).toList();
  }
  
  /// Load all placeholder stops from assets into database
  static Future<void> loadAllPlaceholderStops() async {
    // List of all endpoint asset files
    final endpoints = [
      // Buses
      'buses', 'buses_SBSC006', 'buses_GSBC001', 'buses_GSBC002', 'buses_GSBC003',
      'buses_GSBC004', 'buses_GSBC007', 'buses_GSBC008', 'buses_GSBC009', 'buses_GSBC010',
      'buses_GSBC014', 'buses_OSMBSC001', 'buses_OSMBSC002', 'buses_OSMBSC003', 'buses_OSMBSC004',
      'buses_OMBSC006', 'buses_OMBSC007', 'buses_OSMBSC008', 'buses_OSMBSC009', 'buses_OSMBSC010',
      'buses_OSMBSC011', 'buses_OSMBSC012', 'buses_NISC001', 'buses_ReplacementBus',
      
      // Ferries
      'ferries_sydneyferries', 'ferries_MFF',
      
      // Light Rail
      'lightrail_innerwest', 'lightrail_newcastle', 'lightrail_cbdandsoutheast', 'lightrail_parramatta',
      
      // Trains
      'nswtrains', 'sydneytrains',
      
      // Regional Buses
      'regionbuses_southeasttablelands', 'regionbuses_southeasttablelands2', 'regionbuses_northcoast',
      'regionbuses_northcoast2', 'regionbuses_centralwestandorana', 'regionbuses_centralwestandorana2',
      'regionbuses_riverinamurray', 'regionbuses_newenglandnorthwest', 'regionbuses_riverinamurray2',
      'regionbuses_northcoast3', 'regionbuses_sydneysurrounds', 'regionbuses_newcastlehunter',
      'regionbuses_farwest',
      
      // Metro
      'metro',
    ];
    
    for (final endpoint in endpoints) {
      try {
        final assetPath = 'assets/stops/${endpoint}_stops.txt';
        final stops = await parseStopsFromAsset(assetPath);
        await storeStopsToDatabase(stops, endpoint);
        print('Loaded ${stops.length} stops for $endpoint');
      } catch (e) {
        print('Failed to load stops for $endpoint: $e');
      }
    }
  }
  
  /// Fetch stops from API endpoint and update database (manual update function)
  static Future<void> updateStopsFromEndpoint(String endpoint) async {
    try {
      print('Fetching stops from API for endpoint: $endpoint');
      
      // Get GTFS data from the appropriate endpoint
      final gtfsData = await _fetchGtfsDataForEndpoint(endpoint);
      if (gtfsData == null) {
        print('Failed to fetch GTFS data for $endpoint');
        return;
      }
      
      // Store the stops to database
      await storeStopsToDatabase(gtfsData.stops, endpoint);
      print('Updated ${gtfsData.stops.length} stops for $endpoint from API');
      
    } catch (e) {
      print('Error updating stops from endpoint $endpoint: $e');
    }
  }
  
  /// Helper function to call the appropriate GTFS fetch function for an endpoint
  static Future<dynamic> _fetchGtfsDataForEndpoint(String endpoint) async {
    switch (endpoint) {
      // Buses
      case 'buses':
        return await fetchBusesGtfsData();
      case 'buses_SBSC006':
        return await fetchBusesSBSC006GtfsData();
      case 'buses_GSBC001':
        return await fetchBusesGSBC001GtfsData();
      case 'buses_GSBC002':
        return await fetchBusesGSBC002GtfsData();
      case 'buses_GSBC003':
        return await fetchBusesGSBC003GtfsData();
      case 'buses_GSBC004':
        return await fetchBusesGSBC004GtfsData();
      case 'buses_GSBC007':
        return await fetchBusesGSBC007GtfsData();
      case 'buses_GSBC008':
        return await fetchBusesGSBC008GtfsData();
      case 'buses_GSBC009':
        return await fetchBusesGSBC009GtfsData();
      case 'buses_GSBC010':
        return await fetchBusesGSBC010GtfsData();
      case 'buses_GSBC014':
        return await fetchBusesGSBC014GtfsData();
      case 'buses_OSMBSC001':
        return await fetchBusesOSMBSC001GtfsData();
      case 'buses_OSMBSC002':
        return await fetchBusesOSMBSC002GtfsData();
      case 'buses_OSMBSC003':
        return await fetchBusesOSMBSC003GtfsData();
      case 'buses_OSMBSC004':
        return await fetchBusesOSMBSC004GtfsData();
      case 'buses_OMBSC006':
        return await fetchBusesOMBSC006GtfsData();
      case 'buses_OMBSC007':
        return await fetchBusesOMBSC007GtfsData();
      case 'buses_OSMBSC008':
        return await fetchBusesOSMBSC008GtfsData();
      case 'buses_OSMBSC009':
        return await fetchBusesOSMBSC009GtfsData();
      case 'buses_OSMBSC010':
        return await fetchBusesOSMBSC010GtfsData();
      case 'buses_OSMBSC011':
        return await fetchBusesOSMBSC011GtfsData();
      case 'buses_OSMBSC012':
        return await fetchBusesOSMBSC012GtfsData();
      case 'buses_NISC001':
        return await fetchBusesNISC001GtfsData();
      case 'buses_ReplacementBus':
        return await fetchBusesReplacementBusGtfsData();
        
      // Ferries
      case 'ferries_sydneyferries':
        return await fetchFerriesSydneyFerriesGtfsData();
      case 'ferries_MFF':
        return await fetchFerriesMFFGtfsData();
        
      // Light Rail
      case 'lightrail_innerwest':
        return await fetchLightRailInnerWestGtfsData();
      case 'lightrail_newcastle':
        return await fetchLightRailNewcastleGtfsData();
      case 'lightrail_cbdandsoutheast':
        return await fetchLightRailCbdAndSoutheastGtfsData();
      case 'lightrail_parramatta':
        return await fetchLightRailParramattaGtfsData();
        
      // Trains
      case 'nswtrains':
        return await fetchNswTrainsGtfsData();
      case 'sydneytrains':
        return await fetchSydneyTrainsGtfsData();
        
      // Regional Buses
      case 'regionbuses_southeasttablelands':
        return await fetchRegionBusesSouthEastTablelandsGtfsData();
      case 'regionbuses_southeasttablelands2':
        return await fetchRegionBusesSouthEastTablelands2GtfsData();
      case 'regionbuses_northcoast':
        return await fetchRegionBusesNorthCoastGtfsData();
      case 'regionbuses_northcoast2':
        return await fetchRegionBusesNorthCoast2GtfsData();
      case 'regionbuses_centralwestandorana':
        return await fetchRegionBusesCentralWestAndOranaGtfsData();
      case 'regionbuses_centralwestandorana2':
        return await fetchRegionBusesCentralWestAndOrana2GtfsData();
      case 'regionbuses_riverinamurray':
        return await fetchRegionBusesRiverinaMurrayGtfsData();
      case 'regionbuses_newenglandnorthwest':
        return await fetchRegionBusesNewEnglandNorthWestGtfsData();
      case 'regionbuses_riverinamurray2':
        return await fetchRegionBusesRiverinaMurray2GtfsData();
      case 'regionbuses_northcoast3':
        return await fetchRegionBusesNorthCoast3GtfsData();
      case 'regionbuses_sydneysurrounds':
        return await fetchRegionBusesSydneySurroundsGtfsData();
      case 'regionbuses_newcastlehunter':
        return await fetchRegionBusesNewcastleHunterGtfsData();
      case 'regionbuses_farwest':
        return await fetchRegionBusesFarWestGtfsData();
        
      default:
        print('Unknown endpoint: $endpoint');
        return null;
    }
  }
  
  /// Update all endpoints from API (manual function - not called automatically)
  static Future<void> updateAllStopsFromApi() async {
    final endpoints = [
      'buses', 'buses_SBSC006', 'buses_GSBC001', 'buses_GSBC002', 'buses_GSBC003',
      'buses_GSBC004', 'buses_GSBC007', 'buses_GSBC008', 'buses_GSBC009', 'buses_GSBC010',
      'buses_GSBC014', 'buses_OSMBSC001', 'buses_OSMBSC002', 'buses_OSMBSC003', 'buses_OSMBSC004',
      'buses_OMBSC006', 'buses_OMBSC007', 'buses_OSMBSC008', 'buses_OSMBSC009', 'buses_OSMBSC010',
      'buses_OSMBSC011', 'buses_OSMBSC012', 'buses_NISC001', 'buses_ReplacementBus',
      'ferries_sydneyferries', 'ferries_MFF',
      'lightrail_innerwest', 'lightrail_newcastle', 'lightrail_cbdandsoutheast', 'lightrail_parramatta',
      'nswtrains', 'sydneytrains',
      'regionbuses_southeasttablelands', 'regionbuses_southeasttablelands2', 'regionbuses_northcoast',
      'regionbuses_northcoast2', 'regionbuses_centralwestandorana', 'regionbuses_centralwestandorana2',
      'regionbuses_riverinamurray', 'regionbuses_newenglandnorthwest', 'regionbuses_riverinamurray2',
      'regionbuses_northcoast3', 'regionbuses_sydneysurrounds', 'regionbuses_newcastlehunter',
      'regionbuses_farwest',
    ];
    
    print('Starting to update all stops from API endpoints...');
    int successCount = 0;
    int failureCount = 0;
    
    for (final endpoint in endpoints) {
      try {
        await updateStopsFromEndpoint(endpoint);
        successCount++;
      } catch (e) {
        print('Failed to update $endpoint: $e');
        failureCount++;
      }
    }
    
    print('Finished updating stops. Success: $successCount, Failures: $failureCount');
  }
  
  /// Get total number of stops in database
  static Future<int> getTotalStopsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_stopsTable');
    return result.first['count'] as int;
  }
  
  /// Get stops count by endpoint
  static Future<Map<String, int>> getStopsCountByEndpoint() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT endpoint, COUNT(*) as count FROM $_stopsTable GROUP BY endpoint ORDER BY endpoint'
    );
    
    return Map.fromEntries(
      result.map((row) => MapEntry(row['endpoint'] as String, row['count'] as int))
    );
  }
}