part of '../settings.dart';

extension _SettingsDataManagementSection on _SettingsScreenState {
  Widget _buildDataManagementSection() {
    final currentServices = _currentServices;
    return _settingsSection(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Provider Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _updateStatus ?? 'No recent updates',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            if (_isUpdating)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Updating...'),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: currentServices.supportsStaticImport
                          ? () => _performUpdate()
                          : null,
                      icon: const Icon(Icons.download),
                      label: Text(
                        'Update ${currentServices.region.shortLabel} static data',
                      ),
                      style: ButtonStyles.elevated(Colors.green),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: currentServices.supportsStaticImport
                          ? () => _performUpdate(force: true)
                          : null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Force refresh'),
                      style: ButtonStyles.elevated(Colors.orange),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (_staticEndpointsUpdated > 0)
              Text('Updated $_staticEndpointsUpdated static endpoint(s).'),
            if (_staticEndpointErrors.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._staticEndpointErrors.entries.map(
                (entry) => Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            if (_updateStatus?.isNotEmpty == true && !_isUpdating)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _clearUpdateStatus,
                  child: const Text('Clear status'),
                ),
              ),

            // Dev-only: full DB reset (delete file and recreate)
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _resetDatabase,
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset DB (dev)'),
                    style: ButtonStyles.elevated(Colors.redAccent),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _performUpdate({bool force = false}) async {
    final staticGtfs = _currentServices.staticGtfs;
    if (staticGtfs == null) {
      showSnackBar(
        SnackBar(
          content: Text(
            'Static data import is unavailable for ${_selectedRegion.label}.',
          ),
        ),
      );
      return;
    }
    guardedSetState(() {
      _isUpdating = true;
      _updateStatus =
          'Starting ${_currentServices.attribution.name} static data update...';
      _staticEndpointsUpdated = 0;
      _staticEndpointErrors.clear();
    });

    try {
      await for (final progress in staticGtfs.refreshStaticData(
        StaticImportRequest(force: force),
      )) {
        if (!mounted) return;
        final endpoint = progress.sourceId?.value ?? 'all sources';
        final error = progress.error;
        guardedSetState(() {
          _staticEndpointsUpdated = progress.completed;
          if (error != null && progress.sourceId != null) {
            _staticEndpointErrors.addAll({progress.sourceId!.value: error});
          }
          _updateStatus =
              '${progress.message.isNotEmpty ? progress.message : endpoint} '
              '(${progress.completed}/${progress.total})';
        });
      }
      guardedSetState(() {
        _updateStatus = _staticEndpointErrors.isEmpty
            ? 'Static transport data update completed successfully'
            : 'Static transport data update completed with '
                  '${_staticEndpointErrors.length} error(s)';
        _isUpdating = false;
      });
    } catch (error) {
      guardedSetState(() {
        _updateStatus = 'Update failed: $error';
        _isUpdating = false;
      });
    }
  }

  void _clearUpdateStatus() {
    guardedSetState(() {
      _updateStatus = null;
      _staticEndpointErrors.clear();
    });
  }

  Future<void> _resetDatabase() async {
    guardedSetState(() {
      _isUpdating = true;
      _updateStatus = 'Resetting database...';
    });

    final reset = await DatabaseAdminService.resetDatabase();
    if (reset) {
      showSnackBar(
        const SnackBar(
          content: Text('Database reset successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showSnackBar(
        const SnackBar(
          content: Text('Database reset failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
    guardedSetState(() {
      _isUpdating = false;
      _updateStatus = null;
    });
  }

  void _openDebugBrowser(DebugEntityType entityType) {
    DebugNavigation.pushBrowser(
      context,
      entityType: entityType,
      listLoader: _debugListLoader,
      pageLoader: _debugPageLoader,
    );
  }

  Future<void> _navigateToRealtimeMap() async {
    if (_selectedRegion != TransitRegion.nsw) {
      showSnackBar(
        const SnackBar(
          content: Text(
            'The detailed realtime map is currently available only for NSW.',
          ),
        ),
      );
      return;
    }
    await pushPage((context) => const RealtimeMapPage());
  }

  Future<void> _navigateToSetHomeStop() async {
    await pushPage((context) => const SetHomeStopScreen());
  }
}
