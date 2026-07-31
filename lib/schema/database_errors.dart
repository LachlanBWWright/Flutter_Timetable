class DatabaseOperationFailure implements Exception {
  const DatabaseOperationFailure({
    required this.operation,
    required this.cause,
    required this.stackTrace,
  });

  final String operation;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'DatabaseOperationFailure(operation: $operation, cause: $cause)';
  }
}
