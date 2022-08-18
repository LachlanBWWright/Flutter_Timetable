class Journey {
  final String origin;
  final String destination;

  const Journey({required this.origin, required this.destination});

  Map<String, dynamic> toMap() {
    return {'origin': origin, 'destination': destination};
  }

  @override
  String toString() {
    return 'Journey; origin = $origin, destination = $destination';
  }
}
