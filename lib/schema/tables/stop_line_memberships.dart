part of 'package:lbww_flutter/schema/database.dart';

class StopLineMemberships extends SafeTable {
  TextColumn get endpoint {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

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

  TextColumn get lineId {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  TextColumn get lineName {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  TextColumn get mode {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  IntColumn get stopOrder {
    try {
      return safeIntColumn();
    } catch (_) {
      return safeIntColumn();
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

  @override
  Set<Column> get primaryKey => {endpoint, stopId, lineId};
}
