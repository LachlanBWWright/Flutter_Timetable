part of '../stops_map_widget.dart';

extension _StopsMapLoading on _StopsMapWidgetState {
  Future<void> _loadStopsAndLocation() async {
    final generation = ++_stopLoadGeneration;
    final cameraInteraction = _cameraInteractionGeneration;
    guardedSetState(() {
      _isLoading = true;
      _error = null;
      _mapIsReady = false;
      _cachedMarkers = const [];
      _pendingMapAction = null;
      _userLocation = null;
    });

    // Start the local query before requesting permission or waiting for GPS.
    final stopsFuture = _getStopsForTransportMode(
      widget.transportMode,
      widget.endpoints,
    );
    unawaited(_loadUserLocation(generation, cameraInteraction));
    await runAsyncGuarded(
      () async {
        final allStops = await stopsFuture;
        if (!mounted || generation != _stopLoadGeneration) return;

        guardedSetState(() {
          _replaceStops(allStops.where((stop) => stop.parentStation == null));
          _isLoading = false;
        });
        if (_userLocation != null) {
          _centerOnLoadedLocation(generation, cameraInteraction);
        } else if (_stops.isNotEmpty) {
          _centerMapOnStops();
        }
      },
      onError: (error, _) {
        if (!mounted || generation != _stopLoadGeneration) return;
        guardedSetState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _loadUserLocation(int generation, int cameraInteraction) async {
    // Location is optional: denial, timeout, or service failure must not prevent
    // displaying the local stop catalog.
    final location = await runAsyncGuardedWithFallback<Position?>(
      LocationService.getCurrentLocation,
      null,
    );
    if (!mounted || generation != _stopLoadGeneration || location == null) {
      return;
    }
    guardedSetState(() => _userLocation = location);
    _centerOnLoadedLocation(generation, cameraInteraction);
  }

  void _centerOnLoadedLocation(int generation, int cameraInteraction) {
    if (_isLoading || _stops.isEmpty) return;
    void action() {
      final location = _userLocation;
      if (!mounted ||
          generation != _stopLoadGeneration ||
          cameraInteraction != _cameraInteractionGeneration ||
          location == null ||
          !(ModalRoute.of(context)?.isCurrent ?? true)) {
        return;
      }
      _mapController.move(LatLng(location.latitude, location.longitude), 13.0);
    }

    if (_mapIsReady) {
      action();
    } else {
      _pendingMapAction = action;
    }
  }

  Future<List<Stop>> _getStopsForTransportMode(
    TransportMode mode,
    List<StopsEndpoint>? requestedEndpoints,
  ) {
    final endpoints = requestedEndpoints ?? endpointsForTransportMode(mode);
    return runAsyncGuardedWithFallback(
      () => StopsService.getStopsForEndpoints(endpoints),
      const <Stop>[],
    );
  }

  void _centerMapOnStops() {
    if (_stops.isEmpty) return;
    final first = _stops.first;
    final bounds = LatLngBounds(
      LatLng(first.stopLat, first.stopLon),
      LatLng(first.stopLat, first.stopLon),
    );
    for (final stop in _stops.skip(1)) {
      bounds.extend(LatLng(stop.stopLat, stop.stopLon));
    }
    void action() {
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)),
      );
    }

    if (_mapIsReady) {
      action();
    } else {
      _pendingMapAction = action;
    }
  }
}
