part of 'package:lbww_flutter/schema/database.dart';

// Drift table for stops
class Stops extends SafeTable {
  TextColumn get stopId {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  TextColumn get stopName {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  TextColumn get stopCode {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get ttsStopName {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get stopDesc {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get zoneId {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get stopUrl {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get stopTimezone {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get levelId {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  RealColumn get stopLat {
    try {
      return safeRealColumn(nullable: true);
    } catch (_) {
      return safeRealColumn(nullable: true);
    }
  }

  RealColumn get stopLon {
    try {
      return safeRealColumn(nullable: true);
    } catch (_) {
      return safeRealColumn(nullable: true);
    }
  }

  IntColumn get locationType {
    try {
      return safeIntColumn(nullable: true);
    } catch (_) {
      return safeIntColumn(nullable: true);
    }
  }

  TextColumn get parentStation {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  IntColumn get wheelchairBoarding {
    try {
      return safeIntColumn(nullable: true);
    } catch (_) {
      return safeIntColumn(nullable: true);
    }
  }

  TextColumn get platformCode {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get endpoint {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  @override
  Set<Column> get primaryKey => {stopId, endpoint};
}
