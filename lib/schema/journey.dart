class Journey {
  final String origin;
  final String destination;
  final String originId;
  final String destinationId;

  const Journey(
      {required this.origin,
      required this.originId,
      required this.destination,
      required this.destinationId});

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'originId': originId,
      'destination': destination,
      'destinationId': destinationId
    };
  }

  @override
  String toString() {
    return 'Journey; origin = $origin $originId, destination = $destination $destinationId';
  }
}
