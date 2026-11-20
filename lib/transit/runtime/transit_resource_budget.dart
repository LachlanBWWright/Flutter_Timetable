/// Configurable budgets. Retained-memory estimates include index overhead.
class TransitResourceBudget {
  const TransitResourceBudget({
    this.parsedBytes = 256 * 1024 * 1024,
    this.archiveBytes = 512 * 1024 * 1024,
    this.diskArchiveBytes = 1024 * 1024 * 1024,
    this.maximumConnections = 1000000,
    this.maximumStopTimes = defaultMaximumStopTimes,
    this.maximumLabelsPerStop = 256,
    this.maximumServiceDays = 366,
  });
  static const defaultMaximumStopTimes = 2000000;
  final int maximumStopTimes;
  final int parsedBytes, archiveBytes, diskArchiveBytes;
  final int maximumConnections, maximumLabelsPerStop, maximumServiceDays;
}
