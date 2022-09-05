import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_manager.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/mbmessages_plugin.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/metrics/mbmessage_metrics.dart';
import 'package:mburger/mb_manager.dart';
import 'package:mburger/mb_plugin/mb_plugin.dart';
import 'package:mburger/mb_plugin/mb_plugins_manager.dart';

import 'in_app_messages/mb_in_app_message.dart';
import 'push_notifications/mbpush.dart';

export 'package:mpush/mp_android_notifications_settings.dart';
export 'package:mpush/mp_topic.dart';

export 'in_app_messages/mb_in_app_message_button.dart';
export 'in_app_messages/widgets/mb_in_app_message_theme.dart';
export 'mb_messages_builder.dart';

/// This is the main entry point to manage all the messages features of MBurger.
/// To use create an instance of MBMessages and add it to the MBManager plugins.
/// `MBManager.shared.plugins = [MBMessages()];`
/// You can pass other options described below in the init method described below.
class MBMessages extends MBPlugin {
  /// A function to provide the `BuildContext` to show in-app messages.
  /// To present in-app messages `MBMessages` uses the `showDialog` function that needs a `BuildContext`.
  /// If you use a `MBMessagesBuilder` you don't have to set this and it will be handled automatically.
  static BuildContext Function()? contextCallback;

  /// The delayed (in seconds) used to delay the presenting of the message after a successful fetch.
  /// The default is 1 second.
  int messagesDelay = 1;

  /// If the plugin should automatically check messages at startup.
  /// If you set this value to false you can call `checkMessages()` to manually check the messages.
  bool automaticallyCheckMessagesAtStartup;

  /// Settings this var to true will always display the messages returned by the api, even if they've been already showed.
  bool debug = false;

  /// Use this function to provide a theme for in-app messages.
  MBInAppMessageTheme Function(MBInAppMessage)? themeForMessage;

  /// Use this function to receive a callback when a button is pressed
  Function(MBInAppMessageButton)? onButtonPressed;

  /// Initializes an instance of MBMessages plugin
  /// @param messagesDelay The delayed (in seconds) used to delay the presenting of the message after a successful fetch. By default it's 1 second.
  /// @param automaticallyCheckMessagesAtStartup If the plugin should automatically check messages at startup. By default it's true.
  /// @param debug  Settings this var to true will always display the messages returned by the api, even if they've been already showed.
  /// @param themeForMessage A theme used to define and override colors and fonts of in-app messages.
  /// @param onButtonPressed Callback called when a button of an in-app message is tapped. Use this to bring you user to the correct screen, based on the button settings.
  MBMessages({
    this.messagesDelay = 1,
    this.automaticallyCheckMessagesAtStartup = true,
    this.debug = false,
    this.themeForMessage,
    this.onButtonPressed,
  }) {
    _pluginStartup();
  }

  /// Starts the plugin and initializes the call to check messages when the app becomes active
  Future<void> _pluginStartup() async {
    await MBMessagesPlugin.initializeMethodCall(
      onAppEnterForeground: () => checkMessages(),
    );
  }

//region plugin
  /// The order of startup for this plugin, in MBurger
  int order = 2;

  /// The function run at startup by MBurger, initializes the plugin and do the startup work.
  /// It increments the session number and updates the metadata.
  @override
  Future<void> startupBlock() async {
    if (automaticallyCheckMessagesAtStartup) {
      await _performCheckMessages(fromStartup: true);
    }
  }

//endregion

  /// This method checks the messages from the server and shows them, if needed.
  /// It's called automatically at startup, but it can be called to force the check.
  Future<void> checkMessages() async {
    _performCheckMessages(fromStartup: false);
  }

  /// Performs the check of messages from the server.
  Future<void> _performCheckMessages({required bool fromStartup}) async {
    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: false);

    Map<String, dynamic> parameters = <String, dynamic>{};
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

    List<dynamic>? messagesDictionaries = responseMap['body'];
    int messagesLength = messagesDictionaries?.length ?? 0;
    if (messagesLength == 0 || messagesDictionaries == null) {
      return;
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

    int delay = messagesDelay;
    List<MBMessage> validMessages = messages
        .where((message) =>
            message.messageType == MBMessageType.inAppMessage &&
            !message.automationIsOn)
        .toList();

    if (validMessages.isNotEmpty) {
      await Future.delayed(Duration(seconds: delay.toInt()));
      MBInAppMessageManager.presentMessages(
        messages: validMessages,
        ignoreShowedMessages: debug,
        themeForMessage: themeForMessage,
        onButtonPressed: onButtonPressed,
      );
    }
  }

  /// Presents in app messages to the user.
  /// @param messages In app messages that will be presented.
  presentMessages(List<MBMessage> messages) {
    MBInAppMessageManager.presentMessages(
      messages: messages,
      ignoreShowedMessages: debug,
      themeForMessage: themeForMessage,
      onButtonPressed: onButtonPressed,
    );
  }

//region Push handling

  /// Returns the `pushToken` of the push notifications plugin of MBurger.
  /// This will return the token of the MPush SDK.
  /// If you need help setting up the push notifications go to the [MPush documentation](https://docs.mpush.cloud/flutter-sdk/introduction).
  static String get pushToken => MBPush.pushToken;

  /// Set the `pushToken` of the push notifications plugin of MBurger.
  /// This will set the token of the MPush SDK.
  /// If you need help setting up the push notifications go to the [MPush documentation](https://docs.mpush.cloud/flutter-sdk/introduction).
  static set pushToken(String pushToken) {
    MBPush.pushToken = pushToken;
  }

  /// Callback called when a token is retrieved from APNS or FCM
  static Function(String)? get onToken => MBPush.onToken;

  /// Callback called when a token is retrieved from APNS or FCM
  static set onToken(Function(String)? onToken) {
    MBPush.onToken = onToken;
  }

  /// The notification that launched the app, if present, otherwise `null`.
  static Future<Map<String, dynamic>?> launchNotification() async =>
      MBPush.launchNotification();

  /// Configures the MBPush plugin with the callbacks.
  ///
  /// @param onNotificationArrival Called when a push notification arrives.
  /// @param onNotificationTap Called when a push notification is tapped.
  /// @param androidNotificationsSettings Settings for the android notification.
  static configurePush({
    required Function(Map<String, dynamic>) onNotificationArrival,
    required Function(Map<String, dynamic>) onNotificationTap,
    required MPAndroidNotificationsSettings androidNotificationsSettings,
  }) {
    MBPush.configure(
      onNotificationArrival: (notification) {
        MBMessageMetrics.notificationArrived(notification);
        onNotificationArrival(notification);
      },
      onNotificationTap: (notification) {
        MBMessageMetrics.notificationTapped(notification);
        onNotificationTap(notification);
      },
      androidNotificationsSettings: androidNotificationsSettings,
    );
    MBMessageMetrics.checkLaunchNotification();
  }

  /// Register a device token.
  ///
  /// @param token: the token for this device, typically coming from the onToken` callback`.
  /// @returns A future that completes once the registration is successful.
  static Future<void> registerDevice(String token) async =>
      MBPush.registerDevice(token);

  /// Register the current device to a topic.
  ///
  /// @param topic The topic you will register to.
  /// @returns A future that completes once the registration is successful.
  static Future<void> registerToTopic(MPTopic topic) async =>
      MBPush.registerToTopic(topic);

  /// Register the current device to an array of topics.
  ///
  /// @param topics The array of topics you will register to.
  /// @returns A future that completes once the registration is successful.
  static Future<void> registerToTopics(List<MPTopic> topics) async =>
      MBPush.registerToTopics(topics);

  /// Unregister the current device from a topic, the topic is matched using the code of the topic.
  ///
  /// @param topics The topic you will unregister from.
  /// @returns A future that completes once the registration is successful.
  static Future<void> unregisterFromTopic(String topic) async =>
      MBPush.unregisterFromTopic(topic);

  /// Unregister the current device from an array of topics, the topics are matched using the code of the topic.
  ///
  /// @param topics The array of topics you will unregister from.
  /// @returns A future that completes once the registration is successful.
  static Future<void> unregisterFromTopics(List<String> topics) async =>
      MBPush.unregisterFromTopics(topics);

  /// Unregister the current device from all topics it is registred to.
  ///
  /// @returns A future that completes once the registration is successful.
  static Future<void> unregisterFromAllTopics() async =>
      MBPush.unregisterFromAllTopics();

  /// Requests the token to APNS & GCM.
  ///
  /// This will not return the token, use the onToken callback to
  /// retrieve the token once the registration is completed with success.
  ///
  /// @returns A future that completes once the registration is started successfully.
  static Future<void> requestToken() async => MBPush.requestToken();

  /// A push topic that represents all devices, used to send a push to all apps.
  /// @returns a future that completes with the project push topic.
  static Future<MPTopic> projectPushTopic() async => MPTopic(
        code: 'project.all',
        title: 'All users',
        single: false,
      );

  /// A push topic that represents this device, used to send a push to only this device.
  /// @returns a future that completes with the device push topic.
  static Future<MPTopic> devicePushTopic() async {
    String deviceId = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      const androidIdPlugin = AndroidId();
      String? androidId = await androidIdPlugin.getId();
      deviceId = androidId ?? '';
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    }
    return MPTopic(
      code: deviceId,
      title: 'Device: $deviceId',
      single: true,
    );
  }

  /// Configures the MBPush plugin with custom replacements map made of
  /// Key -> String to replace
  /// Value -> String to add
  ///
  /// @param customReplacements Map.
  /// Be aware that saved custom replacements maintain between apps openings
  static Future<void> addCustomReplacements({
    required Map<String, String>? customReplacements,
  }) =>
      MBPush.addCustomReplacements(customReplacements);

  /// Clears the custom replacements from MBPush plugin
  static Future<void> removeCustomReplacements() =>
      MBPush.removeCustomReplacements();

  /// Obtain current saved custom replacements
  /// If there are no maps saved it will return null
  static Future<Map<String, String>?> getCustomReplacements() =>
      MBPush.getCustomReplacements();

//endregion
}
