part of 'home_page.dart';

extension _HomeSorting on _MyHomePageState {
  Future<void> _toggleSortMode() async {
    if (_isSavingSorting) return;
    _isSavingSorting = true;
    final newValue = !_isAlphabeticalSorting;
    try {
      await LocationService.setSortingPreference(newValue);
    } catch (_) {
      if (mounted) {
        showSnackBar(
          const SnackBar(
            content: Text('Could not save the sort order. Please try again.'),
          ),
        );
      }
      return;
    } finally {
      _isSavingSorting = false;
    }
    if (!mounted) return;
    guardedSetState(() => _isAlphabeticalSorting = newValue);
    await getTrips();
  }
}
