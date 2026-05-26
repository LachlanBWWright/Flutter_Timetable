part of 'package:lbww_flutter/schema/database.dart';

class TripPlannerCache extends SafeTable {
  TextColumn get originId {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  TextColumn get destinationId {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  DateTimeColumn get fetchedAt {
    try {
      return safeDateTimeColumn();
    } catch (_) {
      return safeDateTimeColumn();
    }
  }

  TextColumn get responseJson {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get error {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  @override
  Set<Column> get primaryKey => {originId, destinationId};
}
