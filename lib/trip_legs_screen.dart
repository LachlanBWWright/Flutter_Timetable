import 'package:flutter/material.dart';
import 'package:lbww_flutter/widgets/trip_leg_card.dart';

class TripLegScreen extends StatefulWidget {
  const TripLegScreen({super.key, required this.trip});
  final dynamic trip;

  @override
  State<TripLegScreen> createState() => _TripLegScreenState();
}

class _TripLegScreenState extends State<TripLegScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Legs')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return TripLegCard(leg: widget.trip['legs'][index]);
        },
        itemCount: widget.trip['legs'].length,
      ),
    );
  }
}
