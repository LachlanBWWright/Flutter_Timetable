sealed class TransitFailure implements Exception {
  const TransitFailure({this.message});

  final String? message;

  @override
  String toString() => message ?? runtimeType.toString();
}

class UnsupportedCapability extends TransitFailure {
  const UnsupportedCapability({super.message});
}

class InvalidCredentials extends TransitFailure {
  const InvalidCredentials({super.message});
}

class RateLimited extends TransitFailure {
  const RateLimited({this.retryAfter, super.message});

  final Duration? retryAfter;
}

class ProviderUnavailable extends TransitFailure {
  const ProviderUnavailable({super.message});
}

class InvalidProviderResponse extends TransitFailure {
  const InvalidProviderResponse({super.message});
}

class NetworkUnavailable extends TransitFailure {
  const NetworkUnavailable({super.message});
}

class StaleDataUnavailable extends TransitFailure {
  const StaleDataUnavailable({super.message});
}
