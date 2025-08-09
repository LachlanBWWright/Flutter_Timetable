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
    final legs = widget.trip['legs'] as List;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Legs')),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return TripLegCard(leg: legs[index]);
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 20,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          );
        },
        itemCount: legs.length,
      ),
    );
  }
}
