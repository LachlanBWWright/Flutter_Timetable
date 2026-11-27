part of '../database.dart';

/// Shared column builders for application tables.
///
/// Keep these methods as thin wrappers around Drift's builders so that errors
/// while constructing a column surface immediately instead of substituting a
/// fabricated schema column.
abstract class SafeTable extends Table {
  TextColumn safeTextColumn({bool nullable = false, String? defaultValue}) {
    if (defaultValue != null) {
      return text().withDefault(Constant(defaultValue))();
    }
    if (nullable) {
      return text().nullable()();
    }
    return text()();
  }

  IntColumn safeIntColumn({bool nullable = false, bool autoIncrement = false}) {
    if (autoIncrement) {
      return integer().autoIncrement()();
    }
    if (nullable) {
      return integer().nullable()();
    }
    return integer()();
  }

  RealColumn safeRealColumn({bool nullable = false}) {
    if (nullable) {
      return real().nullable()();
    }
    return real()();
  }

  BoolColumn safeBoolColumn({bool? defaultValue}) {
    if (defaultValue != null) {
      return boolean().withDefault(Constant(defaultValue))();
    }
    return boolean()();
  }

  DateTimeColumn safeDateTimeColumn({bool nullable = false}) {
    if (nullable) {
      return dateTime().nullable()();
    }
    return dateTime()();
  }
}
