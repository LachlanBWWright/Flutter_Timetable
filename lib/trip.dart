// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({Key? key}) : super(key: key);

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Trip')),
        body: Column(
          children: [
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
          ],
        ));
  }
}

//For each leg of the trip (E.G Station, Bus stop, ETC.)
class TripLegScreen extends StatefulWidget {
  const TripLegScreen({Key? key}) : super(key: key);

  @override
  State<TripLegScreen> createState() => _TripLegScreenState();
}

class _TripLegScreenState extends State<TripLegScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Trip')),
        body: Column(
          children: [
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
            Text('TEST'),
          ],
        ));
  }
}
