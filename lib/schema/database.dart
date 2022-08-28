import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//TODO: Consider properly implementing

class LbwwDatabase {
  Future<Database> getDb() async {
    final database =
        await openDatabase(join(await getDatabasesPath(), 'trip_database.db'),
            onCreate: ((Database db, int version) async {
      return await db.execute(
          'CREATE TABLE journeys(id INTEGER PRIMARY KEY AUTOINCREMENT, origin TEXT, originId TEXT, destination TEXT, destinationId TEXT)');
    }), version: 1);
    return database;
  }
}
