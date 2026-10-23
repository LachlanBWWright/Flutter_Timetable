part of '../database.dart';

mixin _DatabaseOperations on _$AppDatabase {
  bool get _isClosed;

  Future<void> _createAllSafe(Migrator migrator) async {
    await _runDatabaseOperation<void>(
      'create_all_tables',
      () async => migrator.createAll(),
    );
  }

  Future<T> _runDatabaseOperation<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    if (_isClosed) {
      final error = StateError('Database is closed.');
      final stackTrace = StackTrace.current;
      safeLogError(
        'Database operation failed during $operation',
        error: error,
        stackTrace: stackTrace,
      );
      throw DatabaseOperationFailure(
        operation: operation,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    try {
      return await action();
    } on Exception catch (error, stackTrace) {
      safeLogError(
        'Database operation failed during $operation',
        error: error,
        stackTrace: stackTrace,
      );
      throw DatabaseOperationFailure(
        operation: operation,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<T> _runDatabaseRead<T>(
    String operation,
    Future<T> Function() action,
  ) => _runDatabaseOperation(operation, action);

  Future<void> _runDatabaseTransaction(
    String operation,
    Future<void> Function() action,
  ) => _runDatabaseOperation(operation, () async {
    await transaction(action);
  });
}
