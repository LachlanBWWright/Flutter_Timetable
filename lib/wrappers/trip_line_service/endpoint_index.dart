part of '../trip_line_service_impl.dart';

extension _TripLineEndpointIndexes on TripLineService {
  Future<_EndpointLineIndex?> _getIndexForEndpointKey(
    String endpointKey,
  ) async {
    final future = _endpointIndexCache.putIfAbsent(
      endpointKey,
      () => _buildIndexForEndpointKey(endpointKey),
    );
    try {
      final index = await future;
      if (index == null &&
          identical(_endpointIndexCache[endpointKey], future)) {
        _endpointIndexCache.remove(endpointKey);
      }
      return index;
    } catch (_) {
      // A failed import must be retryable, without evicting a newer publication.
      if (identical(_endpointIndexCache[endpointKey], future)) {
        _endpointIndexCache.remove(endpointKey);
      }
      rethrow;
    }
  }

  Future<_EndpointLineIndex?> _buildIndexForEndpointKey(
    String endpointKey,
  ) async {
    final endpoint = StopsEndpoint.values
        .where((value) => value.key == endpointKey)
        .firstOrNull;
    if (endpoint == null) {
      return null;
    }

    final release = await EndpointStaticUpdateQueue.acquire(endpoint);
    try {
      return await _buildLockedIndexForEndpoint(endpoint);
    } finally {
      release();
    }
  }

  Future<_EndpointLineIndex?> _buildLockedIndexForEndpoint(
    StopsEndpoint endpoint,
  ) async {
    final endpointKey = endpoint.key;
    final mode = StopsService.modeForEndpointKey(endpointKey);
    if (mode == null) {
      return null;
    }

    final data = await _loadGtfsDataForEndpoint(endpoint);
    if (data == null) {
      return null;
    }

    if (_readPersistedCache) {
      return _prepareAndPublishStaticData(endpoint, data);
    }
    return _buildEndpointLineIndexInBackground(
      endpointKey: endpointKey,
      mode: mode,
      data: data,
    );
  }

  Future<_EndpointLineIndex> _buildEndpointLineIndexInBackground({
    required String endpointKey,
    required TransportMode mode,
    required GtfsData data,
  }) {
    return compute(
      _buildEndpointLineIndex,
      _EndpointLineIndexBuildRequest(
        endpointKey: endpointKey,
        mode: mode,
        data: data,
      ),
    );
  }
}
