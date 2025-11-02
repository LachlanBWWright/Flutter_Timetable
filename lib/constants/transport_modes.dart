/// Enum and helpers for transport modes used in the app.
///
/// Contains the five primary modes used by the New Trip screen and other
/// UI: train, lightrail, metro, bus and ferry.
enum TransportMode {
  train,
  lightrail,
  metro,
  bus,
  ferry,
}

extension TransportModeExt on TransportMode {
  /// Short identifier (lowercase) matching existing strings used across the app
  /// (e.g. 'train', 'lightrail', 'metro', 'bus', 'ferry').
  String get id => toString().split('.').last;

  /// Human-friendly display name for UI.
  String get displayName {
    switch (this) {
      case TransportMode.train:
        return 'Train';
      case TransportMode.lightrail:
        return 'Light Rail';
      case TransportMode.metro:
        return 'Metro';
      case TransportMode.bus:
        return 'Bus';
      case TransportMode.ferry:
        return 'Ferry';
    }
  }
}

/// Try to parse a transport mode from a string. Returns null if no match.
TransportMode? transportModeFromString(String? s) {
  if (s == null) return null;
  switch (s.toLowerCase()) {
    case 'train':
      return TransportMode.train;
    case 'lightrail':
    case 'light rail':
      return TransportMode.lightrail;
    case 'metro':
      return TransportMode.metro;
    case 'bus':
      return TransportMode.bus;
    case 'ferry':
      return TransportMode.ferry;
    default:
      return null;
  }
}
