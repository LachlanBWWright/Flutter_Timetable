part of 'stops_management_widget.dart';

extension _StopsManagementActions on _StopsManagementWidgetState {
  Future<void> _updateFromApi() async {
    guardedSetState(() {
      _isLoading = true;
      _error = null;
    });

    await runAsyncGuarded(
      () async {
        final confirmed = await _showSafeDialog<bool>(
          builder: (dialogContext) => AlertDialog(
            title: const Text('Update from API'),
            content: const Text(
              'This will fetch static transport data from all API endpoints and may take several minutes. '
              'This operation requires a valid API key. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => _safePop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _safePop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // Show the progress dialog first, then start the stream once the
          // dialog's setState is available — this ensures no progress events
          // are silently dropped while dialogSetState is still null.
          String dialogMessage = 'Preparing update...';
          StateSetter? dialogSetState;
          StreamSubscription<StaticTransportUpdateProgress>? subscription;

          if (!mounted) return;

          // Show modal progress dialog (not dismissible)
          final dialogFuture = _showSafeDialog<void>(
            barrierDismissible: false,
            builder: (dialogContext) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  dialogSetState = setDialogState;
                  return AlertDialog(
                    title: const Text('Updating static transport data'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(dialogMessage),
                      ],
                    ),
                  );
                },
              );
            },
          );

          // Wait one frame so the dialog is built and dialogSetState is populated
          // before starting the stream.
          await Future.microtask(() {});

          subscription = NewTripService.updateStaticTransportData(force: true)
              .listen(
                (progress) {
                  final epLabel = progress.endpoint?.key ?? '';
                  final text =
                      '${progress.completed}/${progress.total}: ${progress.message ?? epLabel}';
                  _updateDialogState(dialogSetState, () {
                    dialogMessage = text;
                  });
                },
                onError: (e) {
                  _updateDialogState(dialogSetState, () {
                    dialogMessage = 'Error: $e';
                  });
                },
                onDone: () async {
                  _safePop(null, true);
                  await subscription?.cancel();
                },
              );

          await dialogFuture;

          // After dialog closes, refresh counts
          await _loadStopsData();

          if (mounted) {
            showSnackBarMessage(
              'Static transport data updated from API successfully',
              backgroundColor: Colors.green,
            );
          }
        } else {
          guardedSetState(() {
            _isLoading = false;
          });
        }
      },
      onError: (error, _) {
        if (!mounted) return;
        guardedSetState(() {
          _error = error.toString();
          _isLoading = false;
        });
        showSnackBarMessage(
          'Error updating from API: $error',
          backgroundColor: Colors.red,
        );
      },
    );
  }

  Future<void> _wipeStopsData() async {
    // Show confirmation dialog
    final confirmed = await _showSafeDialog<bool>(
      builder: (dialogContext) => AlertDialog(
        title: const Text('Wipe Stops Data'),
        content: const Text(
          'This will permanently delete all stops data from the local database. '
          'You will need to reload the data from API or placeholders afterwards. '
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => _safePop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _safePop(true),
            style: ButtonStyles.elevatedSmall(Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      guardedSetState(() {
        _isLoading = true;
        _error = null;
      });

      await runAsyncGuarded(
        () async {
          await StopsService.wipeAllStopsData();
          await _loadStopsData(); // Refresh the counts

          if (mounted) {
            showSnackBarMessage(
              'All stops data wiped successfully',
              backgroundColor: Colors.orange,
            );
          }
        },
        onError: (error, _) {
          if (!mounted) return;
          guardedSetState(() {
            _error = error.toString();
            _isLoading = false;
          });
          showSnackBarMessage(
            'Error wiping stops data: $error',
            backgroundColor: Colors.red,
          );
        },
      );
    }
  }
}
