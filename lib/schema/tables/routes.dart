part of 'package:lbww_flutter/schema/database.dart';

class Routes extends SafeTable {
  TextColumn get endpoint {
    try {
      return safeTextColumn();
    } catch (_) {
      return safeTextColumn();
    }
  }

  TextColumn get routeId {
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

  TextColumn get routeShortName {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get routeLongName {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get routeDesc {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get routeType {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get routeColor {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get routeTextColor {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  TextColumn get routeSortOrder {
    try {
      return safeTextColumn(nullable: true);
    } catch (_) {
      return safeTextColumn(nullable: true);
    }
  }

  @override
  Set<Column> get primaryKey => {endpoint, routeId};
}
