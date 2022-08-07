import 'package:flutter/material.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({Key? key}) : super(key: key);

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Create New Trip')),
        body: const Center(child: Text('TEST')));
  }
}
