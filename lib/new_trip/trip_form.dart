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
                  Text(
                    'Trip stops',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your starting stop and destination. Tap a stop to change it.',
                  ),
                  if (_draftRegion case final region?) ...[
                    const SizedBox(height: 12),
                    Text('Trip region: ${region.label}'),
                  ],
                  const SizedBox(height: 24),
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
                    TextButton(
                      onPressed: canEdit ? _clearAllSelections : null,
                      child: const Text('Clear all stops'),
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
    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: ValueKey('trip-${target.name}${index == null ? '' : '-$index'}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          target == _StopTarget.origin
              ? Icons.trip_origin
              : target == _StopTarget.destination
              ? Icons.location_on_outlined
              : Icons.alt_route,
        ),
        title: Text(label, style: Theme.of(context).textTheme.labelMedium),
        subtitle: Text(
          station?.name ?? 'Choose a stop',
          style: Theme.of(context).textTheme.titleMedium,
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
