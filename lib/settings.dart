// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final keyController = TextEditingController();
  String _apiKey = "";

  //This is akin to ReactJS' componentDidMount()
  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  //This is akin to ReactJS' componentWillUnmount()
  @override
  void dispose() {
    keyController.dispose();
    super.dispose(); //Calls parent's dispose function
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('apiKey') ?? "";
    });
  }

  Future<void> _setApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = keyController.text;
      prefs.setString('apiKey', keyController.text);
    });
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
                  onPressed: _setApiKey,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: const Text('Set API Key'),
                ),
                const SizedBox(height: 10),
                Text(_apiKey == ""
                    ? 'Your API key has not been set'
                    : 'Your API Key is: $_apiKey')
              ],
            )));
  }
}
