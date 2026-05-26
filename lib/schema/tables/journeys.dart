part of 'package:lbww_flutter/schema/database.dart';

// Drift table for journeys
class Journeys extends SafeTable {
  IntColumn get id {
    try {
      return safeIntColumn(autoIncrement: true);
    } catch (_) {
      return safeIntColumn(autoIncrement: true);
    }
  }

  TextColumn get origin {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  TextColumn get originId {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  TextColumn get destination {
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

  TextColumn get tripType {
    try {
      return safeTextColumn(defaultValue: 'direct');
    } catch (_) {
      return safeTextColumn(defaultValue: 'direct');
    }
  }

  TextColumn get mode {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get lineId {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get lineName {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get legsJson {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  BoolColumn get isPinned {
    try {
      return safeBoolColumn(defaultValue: false);
    } catch (_) {
      return safeBoolColumn(defaultValue: false);
    }
  }
}
