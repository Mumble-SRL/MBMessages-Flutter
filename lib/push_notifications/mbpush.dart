import 'package:flutter/foundation.dart';
import 'package:mpush/mp_android_notifications_settings.dart';
import 'package:mpush/mp_topic.dart';
import 'package:mpush/mpush.dart';

class MBPush {
  static String get pushToken => MPush.apiToken;

  static set pushToken(String pushToken) {
    MPush.apiToken = pushToken;
  }

  static Function(String) get onToken => MPush.onToken;

  static set onToken(Function(String) onToken) {
    MPush.onToken = onToken;
  }

  static Future<Map<String, dynamic>> launchNotification() =>
      MPush.launchNotification();

  static MPAndroidNotificationsSettings _androidPushNotificationsSettings;
  static MPAndroidNotificationsSettings get androidPushNotificationsSettings =>
      _androidPushNotificationsSettings;

  static configure({
    @required Function(Map<String, dynamic>) onNotificationArrival,
    @required Function(Map<String, dynamic>) onNotificationTap,
    @required MPAndroidNotificationsSettings androidNotificationsSettings,
  }) {
    _androidPushNotificationsSettings = androidNotificationsSettings;
    MPush.configure(
      onNotificationArrival: onNotificationArrival,
      onNotificationTap: onNotificationTap,
      androidNotificationsSettings: androidNotificationsSettings,
    );
  }

  static Future<void> registerDevice(String token) async =>
      MPush.registerDevice(token);

  static Future<void> registerToTopic(MPTopic topic) async =>
      MPush.registerToTopic(topic);

  static Future<void> registerToTopics(List<MPTopic> topics) async =>
      MPush.registerToTopics(topics);

  static Future<void> unregisterFromTopic(String topic) async =>
      MPush.unregisterFromTopic(topic);

  static Future<void> unregisterFromTopics(List<String> topics) async =>
      MPush.unregisterFromTopics(topics);

  static Future<void> unregisterFromAllTopics() async =>
      MPush.unregisterFromAllTopics();

  static Future<void> requestToken() async => MPush.requestToken();
}
