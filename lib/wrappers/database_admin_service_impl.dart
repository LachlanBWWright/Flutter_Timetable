import 'package:lbww_flutter/schema/database.dart' as db;

import '../logs/logger.dart';

class DatabaseAdminService {
  const DatabaseAdminService._();

  static Future<bool> resetDatabase() async {
    try {
      await db.AppDatabase.resetDatabase();
      return true;
    } catch (error, stackTrace) {
      safeLogError(
        'Failed to reset database',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
