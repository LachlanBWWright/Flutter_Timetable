part of 'package:lbww_flutter/schema/database.dart';

class StaticCacheStatuses extends SafeTable {
  TextColumn get endpoint {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  DateTimeColumn get stopsUpdatedAt {
    try {
      return safeDateTimeColumn(nullable: true);
    } catch (_) {
      return safeDateTimeColumn(nullable: true);
    }
  }

  DateTimeColumn get lineMembershipsUpdatedAt {
    try {
      return safeDateTimeColumn(nullable: true);
    } catch (_) {
      return safeDateTimeColumn(nullable: true);
    }
  }

  DateTimeColumn get lastBuildStartedAt {
    try {
      return safeDateTimeColumn(nullable: true);
    } catch (_) {
      return safeDateTimeColumn(nullable: true);
    }
  }

  DateTimeColumn get lastBuildFinishedAt {
    try {
      return safeDateTimeColumn(nullable: true);
    } catch (_) {
      return safeDateTimeColumn(nullable: true);
    }
  }

  TextColumn get lastError {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  BoolColumn get isBuilding {
    try {
      return safeBoolColumn(defaultValue: false);
    } catch (_) {
      return safeBoolColumn(defaultValue: false);
    }
  }

  @override
  Set<Column> get primaryKey => {endpoint};
}
