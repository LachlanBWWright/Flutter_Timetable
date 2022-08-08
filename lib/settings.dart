// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final keyController = TextEditingController();

  @override
  void dispose() {
    //This is akin to ReactJS' componentWillUnmount()
    keyController.dispose();
    super.dispose(); //Calls parent's dispose function
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: keyController,
                  style: 
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: const Text('Set API Key'),
                ),
              ],
            )));
  }
}
