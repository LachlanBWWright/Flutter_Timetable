// ignore_for_file: catch_unknown_dynamic_calls

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
import 'package:lbww_flutter/utils/button_styles.dart';
import 'package:lbww_flutter/utils/guarded_state.dart';
import 'package:lbww_flutter/widgets/interchange_stop_selection_screen.dart';
import 'package:lbww_flutter/widgets/selected_stops/selected_stops_helpers.dart';
import 'package:lbww_flutter/widgets/selected_stops/selected_stops_parts.dart';
import 'package:lbww_flutter/widgets/selected_stops_widget.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

typedef InterchangeCandidateLoader =
    Future<List<Station>> Function(int insertIndex);
typedef InterchangeInserter = void Function(int insertIndex, Station station);

class TripComposerScreen extends StatefulWidget {
  const TripComposerScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.currentMode,
    required this.originMode,
    required this.destinationMode,
    required this.selectedLine,
    required this.interchanges,
    required this.manualValidationMessage,
    required this.canSaveManual,
    required this.onLoadInterchangeCandidates,
    required this.onInsertInterchange,
    required this.onRemoveInterchange,
    required this.onMoveInterchange,
    required this.onSaveManual,
  });

  final Station origin;
  final Station destination;
  final TransportMode currentMode;
  final TransportMode? originMode;
  final TransportMode? destinationMode;
  final StopLineMatch? selectedLine;
  final List<Station> interchanges;
  final String? manualValidationMessage;
  final bool canSaveManual;
  final InterchangeCandidateLoader onLoadInterchangeCandidates;
  final InterchangeInserter onInsertInterchange;
  final void Function(int interchangeIndex) onRemoveInterchange;
  final void Function(int interchangeIndex, int delta) onMoveInterchange;
  final VoidCallback onSaveManual;

  @override
  State<TripComposerScreen> createState() => _TripComposerScreenState();
}

class _TripComposerScreenState extends State<TripComposerScreen>
    with GuardedState<TripComposerScreen> {
  late Station _origin;
  late Station _destination;
  late List<Station> _interchanges;

  Future<T?> _pushPageSafe<T>(WidgetBuilder builder) {
    return pushPage<T>(builder);
  }

  Future<List<Station>> _loadInterchangeCandidates(int insertIndex) async {
    return widget.onLoadInterchangeCandidates(insertIndex);
  }

  void _insertInterchange(int insertIndex, Station station) {
    widget.onInsertInterchange(insertIndex, station);
  }

  void _notifyRemoveInterchange(int interchangeIndex) {
    widget.onRemoveInterchange(interchangeIndex);
  }

  void _notifyMoveInterchange(int interchangeIndex, int delta) {
    widget.onMoveInterchange(interchangeIndex, delta);
  }

  Station? _stationAtOrNull(List<Station> stations, int index) {
    return stations.elementAtOrNull(index);
  }

  @override
  void initState() {
    super.initState();
    _origin = widget.origin;
    _destination = widget.destination;
    _interchanges = List<Station>.from(widget.interchanges);
  }

  List<Station> get _orderedStops {
    return buildOrderedStops(
      origin: _origin,
      destination: _destination,
      interchanges: _interchanges,
    );
  }

  List<SequenceStopDescriptor> get _descriptors {
    return buildSequenceDescriptors(
      orderedStops: _orderedStops,
      interchangeCount: _interchanges.length,
    );
  }

  bool get _canSaveManual {
    return _interchanges.isNotEmpty && _validationMessage == null;
  }

  String? get _validationMessage {
    if (_interchanges.isEmpty) {
      return 'A manual multi-leg trip needs at least one interchange.';
    }
    return NewTripService.validateManualTrip(
      origin: _origin,
      destination: _destination,
      interchanges: _interchanges,
      fallbackMode: widget.currentMode,
    );
  }

  Future<void> _openStopSelectionPage(int insertIndex) async {
    final selectedStation = await _pushPageSafe<Station>(
      (context) => InterchangeStopSelectionScreen(
        insertIndex: insertIndex,
        contextLabel: _contextLabel(insertIndex),
        currentMode: widget.currentMode,
        candidatesFuture: _loadInterchangeCandidates(insertIndex),
      ),
    );

    if (!mounted || selectedStation == null) {
      return;
    }

    _insertInterchange(insertIndex, selectedStation);

    guardedSetState(() {
      if (insertIndex == 0) {
        _interchanges.insert(0, _origin);
        _origin = selectedStation;
      } else if (insertIndex >= _orderedStops.length) {
        _interchanges.add(_destination);
        _destination = selectedStation;
      } else {
        _interchanges.insert(insertIndex - 1, selectedStation);
      }
    });
  }

  void _removeInterchange(int interchangeIndex) {
    _notifyRemoveInterchange(interchangeIndex);
    guardedSetState(() {
      _interchanges.removeAt(interchangeIndex);
    });
  }

  void _moveInterchange(int interchangeIndex, int delta) {
    final newIndex = interchangeIndex + delta;
    if (newIndex < 0 || newIndex >= _interchanges.length) {
      return;
    }
    _notifyMoveInterchange(interchangeIndex, delta);
    guardedSetState(() {
      final updated = List<Station>.from(_interchanges);
      final station = updated.removeAt(interchangeIndex);
      updated.insert(newIndex, station);
      _interchanges = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentMode = resolveAccentMode(
      fallbackMode: widget.currentMode,
      selectedLine: null,
    );
    final accentColor = TransportColors.getColorByTransportMode(accentMode);

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Composer')),
      body: Column(
        children: [
          SelectedStopsSummaryBar(
            origin: _origin,
            destination: _destination,
            currentMode: widget.currentMode,
            originMode: widget.originMode,
            destinationMode: widget.destinationMode,
            selectedLine: null,
            isLoadingLineCandidates: false,
            originLineCount: 0,
            statusMessage: 'Multi-mode manual trip ready',
            onClearOrigin: () {},
            onClearDestination: () {},
            onSaveDirect: () {},
            onOpenComposer: () {},
            canSaveDirect: false,
            canComposeManual: false,
            allowClearing: false,
          ),
          Expanded(child: _buildSequenceEditor(accentColor)),
          _ComposerActions(
            accentColor: accentColor,
            validationMessage: _validationMessage,
            canSave: _canSaveManual,
            onSave: widget.onSaveManual,
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceEditor(Color accentColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual stop chain',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12.0),
          StopSequenceSection(
            descriptors: _descriptors,
            accentColor: accentColor,
            allowAddingInterchanges: true,
            pendingInterchangeInsertIndex: null,
            onAddInterchange: _openStopSelectionPage,
            onRemoveInterchange: _removeInterchange,
            onMoveInterchange: _moveInterchange,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Derived legs',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8.0),
          DerivedLegsSection(
            origin: _origin,
            destination: _destination,
            interchanges: _interchanges,
            fallbackMode: widget.currentMode,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }

  String _contextLabel(int insertIndex) {
    final orderedStops = _orderedStops;
    final previousStop = _stationAtOrNull(orderedStops, insertIndex - 1);
    final nextStop = _stationAtOrNull(orderedStops, insertIndex);
    if (insertIndex == 0 && orderedStops.isNotEmpty) {
      return 'Adding before ${orderedStops.first.name}';
    }
    if (insertIndex >= orderedStops.length && orderedStops.isNotEmpty) {
      return 'Adding after ${orderedStops.last.name}';
    }
    if (previousStop != null && nextStop != null) {
      return 'Adding between ${previousStop.name} and ${nextStop.name}';
    }
    return 'Adding stop';
  }
}

class _ComposerActions extends StatelessWidget {
  const _ComposerActions({
    required this.accentColor,
    required this.validationMessage,
    required this.canSave,
    required this.onSave,
  });

  final Color accentColor;
  final String? validationMessage;
  final bool canSave;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: accentColor.withValues(alpha: 0.2)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (validationMessage != null) ...[
              Text(
                validationMessage ?? '',
                style: TextStyle(color: Colors.orange.shade300),
              ),
              const SizedBox(height: 10.0),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canSave ? onSave : null,
                icon: const Icon(Icons.save),
                label: const Text('Save Trip'),
                style: ButtonStyles.elevated(accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
