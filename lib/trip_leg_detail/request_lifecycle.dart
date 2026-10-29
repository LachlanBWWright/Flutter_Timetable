part of '../trip_leg_detail_screen.dart';

/// Every completion must still belong to the visible leg and refresh.
extension _RequestLifecycle on _TripLegDetailScreenState {
  bool _isCurrentRequest(int generation, Leg leg) =>
      mounted && generation == _requestGeneration && identical(leg, _activeLeg);

  void _invalidateLegRequests() {
    _requestGeneration++;
    _realtimeController.beginGeneration(clearSnapshot: true);
    _stopRequestGeneration++;
    _debugRequestGeneration++;
    _vehicles = [];
    _vehicleBreakdown = {};
    _vehicleStops = [];
    _vehicleStopsError = null;
    _isLoadingVehicles = false;
    _isLoadingVehicleStops = false;
    _error = null;
    _resetRouteDebugState();
  }
}
