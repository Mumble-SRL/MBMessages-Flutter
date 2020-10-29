import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_manager.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/mbmessages_plugin.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/metrics/mbmessage_metrics.dart';
import 'package:mburger/mb_manager.dart';
import 'package:mburger/mb_plugin/mb_plugin.dart';

import 'package:http/http.dart' as http;
import 'package:mburger/mb_plugin/mb_plugins_manager.dart';
import 'package:mpush/mp_android_notifications_settings.dart';
import 'package:mpush/mp_topic.dart';

import 'in_app_messages/mb_in_app_message.dart';
import 'push_notifications/mbpush.dart';

class MBMessages extends MBPlugin {
  static BuildContext Function() contextCallback;

  /// The delayed (in seconds) used to delay the presenting of the message after a successful fetch.
  /// The default is 1 second.
  int messagesDelay = 1;

  /// If the plugin should automatically check messages at startup
  bool automaticallyCheckMessagesAtStartup;

  /// Settings this var to true will always display the messages returned by the api, even if they've been already showed.
  bool debug = false;

  /// Use this function to provide a theme for the in app message
  MBInAppMessageTheme Function(MBInAppMessage) themeForMessage;

  /// Use this function to receive a callback when a button is pressed
  Function(MBInAppMessageButton) onButtonPressed;

  MBMessages({
    this.messagesDelay: 1,
    this.automaticallyCheckMessagesAtStartup: true,
    this.debug: false,
    this.themeForMessage,
    this.onButtonPressed,
  }) {
    _pluginStartup();
  }

  Future<void> _pluginStartup() async {
    await MBMessagesPlugin.initializeMethodCall(
      onAppEnterForeground: () => checkMessages(),
    );
  }

//region plugin
  int order = 1;

  Future<void> startupBlock() async {
    if (automaticallyCheckMessagesAtStartup) {
      await _performCheckMessages(fromStartup: true);
    }
  }
//endregion

  Future<void> checkMessages() async {
    _performCheckMessages(fromStartup: false);
  }

  Future<void> _performCheckMessages({@required bool fromStartup}) async {
    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: false);

    Map<String, dynamic> parameters = Map<String, dynamic>();
    parameters.addAll(defaultParameters);

    var uri = Uri.https(
      MBManager.shared.endpoint,
      'api/messages',
      Map.castFrom<String, dynamic, String, String>(parameters),
    );

    var response = await http.get(
      uri,
      headers: headers,
    );

    Map<String, dynamic> responseMap =
        MBManager.checkResponse(response.body, checkBody: false);

    List<dynamic> messagesDictionaries = responseMap['body'];
    int messagesLength = messagesDictionaries?.length ?? 0;
    if (messagesLength == 0) {
      return null;
    }

    List<MBMessage> messages = [];
    for (dynamic message in messagesDictionaries) {
      if (message is Map<String, dynamic>) {
        messages.add(MBMessage.fromDictionary(message));
      }
    }

    MBPluginsManager.messagesReceived(
      messages,
      fromStartup,
    );

    int delay = messagesDelay ?? 0;
    List<MBMessage> validMessages = messages
        .where((message) =>
            message.messageType == MBMessageType.inAppMessage &&
            !message.automationIsOn)
        .toList();

    if (validMessages.length != 0) {
      await Future.delayed(Duration(seconds: delay.toInt()));
      MBInAppMessageManager.presentMessages(
        messages: validMessages,
        ignoreShowedMessages: debug ?? false,
        themeForMessage: themeForMessage,
        onButtonPressed: onButtonPressed,
      );
    }
  }

  presentMessages(List<MBMessage> messages) {
    MBInAppMessageManager.presentMessages(
      messages: messages,
      ignoreShowedMessages: debug,
      themeForMessage: themeForMessage,
      onButtonPressed: onButtonPressed,
    );
  }
//region Push handling

  static String get pushToken => MBPush.pushToken;

  static set pushToken(String pushToken) {
    MBPush.pushToken = pushToken;
  }

  static Function(String) get onToken => MBPush.onToken;

  static set onToken(Function(String) onToken) {
    MBPush.onToken = onToken;
  }

  static Future<Map<String, dynamic>> launchNotification() async =>
      MBPush.launchNotification();

  static configurePush({
    @required Function(Map<String, dynamic>) onNotificationArrival,
    @required Function(Map<String, dynamic>) onNotificationTap,
    @required MPAndroidNotificationsSettings androidNotificationsSettings,
  }) {
    MBPush.configure(
      onNotificationArrival: (notification) {
        MBMessageMetrics.notificationArrived(notification);
        if (onNotificationArrival != null) {
          onNotificationArrival(notification);
        }
      },
      onNotificationTap: (notification) {
        MBMessageMetrics.notificationTapped(notification);
        if (onNotificationTap != null) {
          onNotificationTap(notification);
        }
      },
      androidNotificationsSettings: androidNotificationsSettings,
    );
    MBMessageMetrics.checkLaunchNotification();
  }

  static Future<void> registerDevice(String token) async =>
      MBPush.registerDevice(token);

  static Future<void> registerToTopic(MPTopic topic) async =>
      MBPush.registerToTopic(topic);

  static Future<void> registerToTopics(List<MPTopic> topics) async =>
      MBPush.registerToTopics(topics);

  static Future<void> unregisterFromTopic(String topic) async =>
      MBPush.unregisterFromTopic(topic);

  static Future<void> unregisterFromTopics(List<String> topics) async =>
      MBPush.unregisterFromTopics(topics);

  static Future<void> unregisterFromAllTopics() async =>
      MBPush.unregisterFromAllTopics();

  static Future<void> requestToken() async => MBPush.requestToken();

  static Future<MPTopic> projectPushTopic() async => MPTopic(
        code: 'project.all',
        title: 'All users',
        single: false,
      );

  static Future<MPTopic> devicePushTopic() async {
    String deviceId;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.androidId;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }
    if (deviceId != null) {
      return MPTopic(
        code: deviceId,
        title: 'Device: $deviceId',
        single: true,
      );
    } else {
      return null;
    }
  }

//endregion
}
