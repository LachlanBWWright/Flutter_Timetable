import 'package:lbww_flutter/constants/transport_modes.dart';
import 'package:lbww_flutter/services/new_trip_service.dart';
import 'package:lbww_flutter/services/trip_line_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

TransportMode transportModeFromTabIndex(int index) {
  switch (index) {
    case 0:
      return TransportMode.train;
    case 1:
      return TransportMode.lightrail;
    case 2:
      return TransportMode.metro;
    case 3:
      return TransportMode.bus;
    case 4:
      return TransportMode.ferry;
    default:
      return TransportMode.train;
  }
}

int tabIndexForTransportMode(TransportMode mode) {
  switch (mode) {
    case TransportMode.train:
      return 0;
    case TransportMode.lightrail:
      return 1;
    case TransportMode.metro:
      return 2;
    case TransportMode.bus:
      return 3;
    case TransportMode.ferry:
      return 4;
  }
}

bool canSaveDirectTrip({
  required Station? origin,
  required Station? destination,
}) {
  return origin != null &&
      destination != null &&
      origin.id.isNotEmpty &&
      destination.id.isNotEmpty &&
      origin.id != destination.id;
}

List<Station> filterStationsByQuery(List<Station> stations, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return stations;
  }

  return stations
      .where((station) => station.name.toLowerCase().contains(normalizedQuery))
      .toList();
}

String? buildNewTripStatusMessage({
  required Station? origin,
  required Station? destination,
  required bool isResolvingSharedLines,
  required bool manualBuilderEnabled,
  required int? pendingInterchangeInsertIndex,
  required List<Station> orderedStops,
  required String? manualValidationMessage,
  required StopLineMatch? selectedLine,
  required bool canSaveDirect,
  required List<StopLineMatch> sharedLines,
  required TransportMode? originMode,
  required TransportMode? destinationMode,
}) {
  if (origin == null && destination == null) {
    return null;
  }

  if (isResolvingSharedLines) {
    return 'Checking for shared lines...';
  }

  if (manualBuilderEnabled && pendingInterchangeInsertIndex != null) {
    final insertIndex = pendingInterchangeInsertIndex;
    if (insertIndex > 0 && insertIndex < orderedStops.length) {
      final previous = orderedStops[insertIndex - 1];
      final next = orderedStops[insertIndex];
      return 'Choose an interchange between ${previous.name} and ${next.name}. Stops on the selected line within 5 km are listed first.';
    }
  }

  if (manualBuilderEnabled) {
    return manualValidationMessage ??
        'Add interchanges on ${selectedLine?.lineName ?? 'the selected line'} to split this trip into multiple legs.';
  }

  if (canSaveDirect && sharedLines.isEmpty) {
    if (originMode != null &&
        destinationMode != null &&
        originMode != destinationMode) {
      return 'These stops do not share a mode. You can still save them as a direct trip.';
    }
    return 'No shared line found. You can still save this as a direct trip.';
  }

  if (sharedLines.length == 1) {
    return 'A shared line is available. Save directly or build a manual multi-leg trip.';
  }

  if (sharedLines.length > 1) {
    return 'Multiple shared lines are available. Pick one before building a manual multi-leg trip.';
  }

  return null;
}

String buildManualModeLockedMessage(StopLineMatch selectedLine) {
  return 'Manual multi-leg editing is limited to ${selectedLine.mode.displayName} stops on ${selectedLine.lineName}.';
}

String buildInterchangeEmptyMessage(StopLineMatch selectedLine) {
  return 'No stops found on ${selectedLine.lineName} for this interchange.';
}

String? manualTripValidationMessage({
  required bool manualBuilderEnabled,
  required Station? origin,
  required Station? destination,
  required List<Station> interchanges,
  required StopLineMatch? selectedLine,
}) {
  if (!manualBuilderEnabled) {
    return null;
  }

  return NewTripService.validateManualTrip(
    origin: origin,
    destination: destination,
    interchanges: interchanges,
    selectedLine: selectedLine,
  );
}
