// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final keyController = TextEditingController();

  //This is akin to ReactJS' componentDidMount()
  @override
  void initState() {
    super.initState();
  }

  //This is akin to ReactJS' componentWillUnmount()
  @override
  void dispose() {
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
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter an API key'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    //print(keyController.text);
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: const Text('Set API Key'),
                ),
                const SizedBox(height: 10),
                const Text('Your API Key is: ')
              ],
            )));
  }
}
