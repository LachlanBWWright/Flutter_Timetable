import 'package:lbww_flutter/schema/journey.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Service class for handling database operations
class DatabaseService {
  static Database? _database;

  /// Get database instance (singleton pattern)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'trip_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create tables when database is first created
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journeys(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        origin TEXT NOT NULL,
        originId TEXT NOT NULL,
        destination TEXT NOT NULL,
        destinationId TEXT NOT NULL
      )
    ''');
  }

  /// Insert a journey into the database
  static Future<int> insertJourney(Journey journey) async {
    final db = await database;
    return await db.insert(
      'journeys',
      journey.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all journeys from the database
  static Future<List<Map<String, dynamic>>> getAllJourneys() async {
    final db = await database;
    return await db.query('journeys');
  }

  /// Delete a journey by ID
  static Future<int> deleteJourney(int id) async {
    final db = await database;
    return await db.delete(
      'journeys',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Close the database
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
