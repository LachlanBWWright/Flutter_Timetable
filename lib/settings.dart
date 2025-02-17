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
  String _apiKey = '';

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

  Future<void> _stealApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = 'Xh0bAW1JmyVP93vjB784EK9dyZlbJb2FxJuw';
      prefs.setString('apiKey', 'Xh0bAW1JmyVP93vjB784EK9dyZlbJb2FxJuw');
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
                    : 'Your API Key is: $_apiKey'),
                const SizedBox(height: 10),
                const Text(
                    'How to set API key: Go to Transport for NSW\'s OpenData page, create an account, hover over \'My Account\', select \'Applications\', and create an application.'),
                const Text(''),
                const Text(
                    'You\'ll need to give the application access to the following APIs: \'Trip Planner APIs\', \'Public Transport - Timetables - For Realtime\'. Or you can just steal mine.'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _stealApiKey,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.red),
                  child: const Text('Steal API Key'),
                ),
              ],
            )));
  }
}
