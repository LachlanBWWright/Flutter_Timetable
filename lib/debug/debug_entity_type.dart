enum DebugEntityType { stop, trip, route, vehicle }

extension DebugEntityTypeX on DebugEntityType {
  String get label {
    switch (this) {
      case DebugEntityType.stop:
        return 'Stop';
      case DebugEntityType.trip:
        return 'Trip';
      case DebugEntityType.route:
        return 'Route';
      case DebugEntityType.vehicle:
        return 'Vehicle';
    }
  }

  String get routeSegment {
    switch (this) {
      case DebugEntityType.stop:
        return 'stop';
      case DebugEntityType.trip:
        return 'trip';
      case DebugEntityType.route:
        return 'route';
      case DebugEntityType.vehicle:
        return 'vehicle';
    }
  }
}
