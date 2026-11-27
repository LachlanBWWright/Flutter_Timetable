/// A preference could not be read reliably, such as when storage is
/// unavailable or the stored value has a different type than expected.
class PreferenceReadFailure implements Exception {
  const PreferenceReadFailure(this.key);

  final String key;

  @override
  String toString() => 'Could not load your settings. Please try again.';
}
