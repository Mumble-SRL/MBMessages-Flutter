import 'package:flutter/material.dart';

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
    MBManager.shared.apiToken = 'YOUR_API_TOKEN';
    MBManager.shared.plugins = [
      MBMessages(
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
          body: Center(
            child: TextButton(
              child: Text(
                'Configure push notifications',
              ),
              onPressed: () => _configurePushNotifications(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _configurePushNotifications() async {
    MBMessages.pushToken = 'YOUR_PUSH_API_KEY';
    MBMessages.onToken = (token) async {
      print("Token received $token");
      await MBMessages.registerDevice(token).catchError(
        (error) => print(error),
      );
      await MBMessages.registerToTopics(
        [
          await MBMessages.projectPushTopic(),
          await MBMessages.devicePushTopic(),
          MPTopic(code: 'Topic'),
        ],
      ).catchError(
        (error) => print(error),
      );
      print('Registered');
    };

    MBMessages.configurePush(
      onNotificationArrival: (notification) {
        print("Notification arrived: $notification");
      },
      onNotificationTap: (notification) {
        print("Notification tapped: $notification");
      },
      androidNotificationsSettings: MPAndroidNotificationsSettings(
        channelId: 'mpush_example',
        channelName: 'mpush',
        channelDescription: 'mpush',
        icon: '@mipmap/icon_notif',
      ),
    );

    MBMessages.requestToken();

    Map<String, dynamic>? launchNotification =
        await MBMessages.launchNotification();
    print(launchNotification);
  }
}
