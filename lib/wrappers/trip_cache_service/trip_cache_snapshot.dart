import '../../services/transport_api_service.dart';

/// A successful fetch timestamp is never replaced by a failed refresh.
class TripCacheEntry {
  const TripCacheEntry({
    required this.response,
    required this.fetchedAt,
    this.error,
  });
  final GetTripsResponse response;
  final DateTime fetchedAt;
  final String? error;
}

/// Explicit cache policy metadata accompanies every response offered to the UI.
class TripCacheSnapshot {
  const TripCacheSnapshot({
    this.response,
    this.fetchedAt,
    this.error,
    this.isFresh = false,
    this.isStale = false,
    this.isExpired = false,
    this.isOffline = false,
  });
  final GetTripsResponse? response;
  final DateTime? fetchedAt;
  final String? error;
  final bool isFresh;
  final bool isStale;
  final bool isExpired;

  /// A confirmed network outage. Provider failures alone leave this false.
  final bool isOffline;
  bool get hasUsableData => response != null && !isExpired;
  bool get fresh => isFresh;
  bool get stale => isStale;
  bool get expired => isExpired;
  bool get offline => isOffline;
  String? get refreshError => error;
}
