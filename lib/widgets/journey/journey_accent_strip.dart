import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/models/manual_trip_models.dart';
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/stops_service.dart';

import 'journey_accent_utils.dart';

typedef JourneyStopModeLookup = Future<TransportMode?> Function(String stopId);

class JourneyAccentStrip extends StatefulWidget {
  const JourneyAccentStrip({
    super.key,
    required this.journey,
    this.modeLookup = StopsService.getModeForStopId,
  });

  final Journey journey;
  final JourneyStopModeLookup modeLookup;

  @override
  State<JourneyAccentStrip> createState() => _JourneyAccentStripState();
}

class _JourneyAccentStripState extends State<JourneyAccentStrip> {
  TransportMode? _originMode;
  TransportMode? _destinationMode;
  int _lookupGeneration = 0;
  bool _listeningForModeChanges = false;

  @override
  void initState() {
    super.initState();
    _syncModeListener();
    _resolveModes(widget.journey);
  }

  @override
  void didUpdateWidget(covariant JourneyAccentStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncModeListener();
    final oldJourney = oldWidget.journey;
    final journey = widget.journey;
    if (oldJourney.id != journey.id ||
        oldJourney.originId != journey.originId ||
        oldJourney.destinationId != journey.destinationId ||
        oldJourney.savedMode != journey.savedMode ||
        oldWidget.modeLookup != widget.modeLookup) {
      _resolveModes(journey);
    }
  }

  void _syncModeListener() {
    final shouldListen =
        widget.journey.savedMode == null &&
        widget.modeLookup == StopsService.getModeForStopId;
    if (shouldListen == _listeningForModeChanges) return;
    _listeningForModeChanges = shouldListen;
    if (shouldListen) {
      StopsService.modeChanges.addListener(_onModePublication);
    } else {
      StopsService.modeChanges.removeListener(_onModePublication);
    }
  }

  void _onModePublication() => _resolveModes(widget.journey);

  @override
  void dispose() {
    _lookupGeneration += 1;
    if (_listeningForModeChanges) {
      StopsService.modeChanges.removeListener(_onModePublication);
    }
    super.dispose();
  }

  void _resolveModes(Journey journey) {
    final generation = ++_lookupGeneration;
    final savedMode = journey.savedMode;
    if (savedMode != null) {
      _originMode = savedMode;
      _destinationMode = savedMode;
      return;
    }

    _originMode = null;
    _destinationMode = null;
    unawaited(() async {
      final modes = await Future.wait([
        _lookupMode(journey.originId),
        _lookupMode(journey.destinationId),
      ]);
      if (!mounted || generation != _lookupGeneration) return;
      setState(() {
        _originMode = modes[0];
        _destinationMode = modes[1];
      });
    }());
  }

  Future<TransportMode?> _lookupMode(String stopId) async {
    if (stopId.isEmpty) return null;
    try {
      return await widget.modeLookup(stopId);
    } on Exception {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final journey = widget.journey;
    final savedMode = journey.savedMode;
    final originColor = accentColorForModeOrFallback(
      savedMode ?? _originMode,
      journey,
    );
    final destinationColor = accentColorForModeOrFallback(
      savedMode ?? _destinationMode,
      journey,
    );

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(child: Container(height: 6, color: originColor)),
          Expanded(child: Container(height: 6, color: destinationColor)),
        ],
      ),
    );
  }
}
