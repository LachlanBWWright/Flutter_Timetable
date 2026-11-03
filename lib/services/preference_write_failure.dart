/// A setting could not be persisted. Suitable for showing in a save error UI.
class PreferenceWriteFailure implements Exception {
  const PreferenceWriteFailure(this.key);

  final String key;

  @override
  String toString() => 'Could not save your settings. Please try again.';
}
