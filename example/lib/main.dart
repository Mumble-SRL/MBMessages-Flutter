import 'package:flutter/material.dart';
import 'package:mbmessages/mb_messages_builder.dart';
import 'package:mbmessages/mbmessages.dart';
import 'package:mburger/mburger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    MBManager.shared.apiToken = '0e3362a17c74a43ec57cc160ca6d222fad79c5ee';
    MBManager.shared.plugins = [
      MBMessages(
        debug: true,
        onButtonPressed: (button) {
          print(button);
        },
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MBMessagesBuilder(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('MBMessages example app'),
          ),
          body: Center(),
        ),
      ),
    );
  }
}
