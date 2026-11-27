part of '../new_trip.dart';

extension _TripForm on _NewTripScreenState {
  Widget _buildTripForm() {
    final canEdit = !_isSavingTrip && !_isApplyingStop;
    final hasEndpoints = _originStation != null && _destinationStation != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Trip')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _stopRow(
                    label: 'From',
                    station: _originStation,
                    target: _StopTarget.origin,
                    onClear: _originStation == null ? null : _clearOrigin,
                  ),
                  for (var i = 0; i <= _interchanges.length; i++) ...[
                    if (hasEndpoints)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: canEdit
                              ? () => _startInterchangeSelection(i + 1)
                              : null,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add interchange'),
                        ),
                      )
                    else
                      const SizedBox(height: 12),
                    if (i < _interchanges.length)
                      _stopRow(
                        label: 'Interchange ${i + 1}',
                        station: _interchanges[i],
                        target: _StopTarget.editInterchange,
                        index: i,
                      ),
                  ],
                  _stopRow(
                    label: 'To',
                    station: _destinationStation,
                    target: _StopTarget.destination,
                    onClear: _destinationStation == null
                        ? null
                        : _clearDestination,
                  ),
                  const SizedBox(height: 16),
                  if (_isApplyingStop || _isResolvingSharedLines)
                    const LinearProgressIndicator(),
                  if (_statusMessage case final message?)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Semantics(liveRegion: true, child: Text(message)),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed:
                        canEdit &&
                            (_interchanges.isEmpty
                                ? _canSaveDirect
                                : _canSaveManual)
                        ? _saveTrip
                        : null,
                    icon: const Icon(Icons.check),
                    label: Text(_isSavingTrip ? 'Saving…' : 'Save trip'),
                  ),
                  if (_originStation != null ||
                      _destinationStation != null ||
                      _interchanges.isNotEmpty)
                    Center(
                      child: TextButton(
                        onPressed: canEdit ? _clearAllSelections : null,
                        child: const Text('Clear all stops'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stopRow({
    required String label,
    required Station? station,
    required _StopTarget target,
    int? index,
    VoidCallback? onClear,
  }) {
    final canEdit = !_isSavingTrip && !_isApplyingStop;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mode = station?.mode;
    final accent = mode == null
        ? switch (target) {
            _StopTarget.origin => colors.primary,
            _StopTarget.destination => colors.tertiary,
            _ => colors.secondary,
          }
        : TransportColors.getColorByTransportMode(mode);
    final marker = switch (target) {
      _StopTarget.origin => Icons.trip_origin,
      _StopTarget.destination => Icons.location_on_outlined,
      _ => Icons.alt_route,
    };
    return StopAccentCard(
      accent: station == null ? null : accent,
      child: ListTile(
        key: ValueKey('trip-${target.name}${index == null ? '' : '-$index'}'),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 8, 12, 8),
        leading: DecoratedBox(
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(
              marker,
              size: 20,
              color: getContrastingForeground(accent),
            ),
          ),
        ),
        title: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          station?.name ?? 'Choose a stop',
          style: theme.textTheme.titleMedium?.copyWith(
            color: station == null ? colors.onSurfaceVariant : colors.onSurface,
            fontWeight: station == null ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
        onTap: canEdit ? () => _openStopPicker(target, index: index) : null,
        trailing: index != null
            ? PopupMenuButton<String>(
                enabled: canEdit,
                tooltip: 'Interchange options',
                onSelected: (action) {
                  switch (action) {
                    case 'up':
                      _moveInterchange(index, -1);
                    case 'down':
                      _moveInterchange(index, 1);
                    case 'remove':
                      _removeInterchange(index);
                  }
                },
                itemBuilder: (_) => [
                  if (index > 0)
                    const PopupMenuItem(value: 'up', child: Text('Move up')),
                  if (index < _interchanges.length - 1)
                    const PopupMenuItem(
                      value: 'down',
                      child: Text('Move down'),
                    ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove interchange'),
                  ),
                ],
              )
            : onClear != null
            ? IconButton(
                onPressed: canEdit ? onClear : null,
                tooltip: target == _StopTarget.origin
                    ? 'Clear starting stop'
                    : 'Clear destination',
                icon: const Icon(Icons.close),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
