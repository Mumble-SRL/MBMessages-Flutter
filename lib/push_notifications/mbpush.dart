import 'package:mpush/mp_android_notifications_settings.dart';
import 'package:mpush/mp_topic.dart';
import 'package:mpush/mpush.dart';

export 'package:mpush/mp_topic.dart';
export 'package:mpush/mp_android_notifications_settings.dart';

/// Interface of MBMessage to MPush.
/// This is just an interface that calls MPush SDK classes.
class MBPush {
  /// Returns the MPush token.
  static String get pushToken => MPush.apiToken;

  /// Sets the MPush token.
  /// @param pushToken The MPush token.
  static set pushToken(String pushToken) {
    MPush.apiToken = pushToken;
  }

  /// Returns the callback called when a token is retrieved from APNS or FCM
  static Function(String)? get onToken => MPush.onToken;

  /// Sets called when a token is retrieved from APNS or FCM
  static set onToken(Function(String)? onToken) {
    MPush.onToken = onToken;
  }

  /// The notification that launched the app, if present, otherwise `null`.
  static Future<Map<String, dynamic>?> launchNotification() =>
      MPush.launchNotification();

  static MPAndroidNotificationsSettings? _androidPushNotificationsSettings;

  /// Returns the settings used to show notifications on android: the channel id, name, description and the icon.
  static MPAndroidNotificationsSettings? get androidPushNotificationsSettings =>
      _androidPushNotificationsSettings;

  /// Returns the callback called when a push notification arrives.
  static Function(Map<String, dynamic>)? get onNotificationArrival =>
      MPush.onNotificationArrival;

  /// Returns the callback called when a push notification is tapped.
  static Function(Map<String, dynamic>)? get onNotificationTap =>
      MPush.onNotificationTap;

  /// Configures the MPush plugin with the callbacks.
  /// @param onNotificationArrival Called when a push notification arrives.
  /// @param onNotificationTap Called when a push notification is tapped.
  /// @param androidNotificationsSettings Settings for the android notification.
  static Future<void> configure({
    required Function(Map<String, dynamic>) onNotificationArrival,
    required Function(Map<String, dynamic>) onNotificationTap,
    required MPAndroidNotificationsSettings androidNotificationsSettings,
  }) {
    _androidPushNotificationsSettings = androidNotificationsSettings;
    return MPush.configure(
      onNotificationArrival: onNotificationArrival,
      onNotificationTap: onNotificationTap,
      androidNotificationsSettings: androidNotificationsSettings,
    );
  }

  /// Register a device token.
  ///
  /// @param token: the token for this device, typically coming from the onToken` callback`.
  /// @returns A future that completes once the registration is successful.
  static Future<void> registerDevice(String token) async =>
      MPush.registerDevice(token);

  /// Register the current device to a topic.
  ///
  /// @param topic The topic you will register to.
  /// @returns A future that completes once the registration is successful.
  static Future<void> registerToTopic(MPTopic topic) async =>
      MPush.registerToTopic(topic);

  /// Register the current device to an array of topics.
  ///
  /// @param topics The array of topics you will register to.
  /// @returns A future that completes once the registration is successful.
  static Future<void> registerToTopics(List<MPTopic> topics) async =>
      MPush.registerToTopics(topics);

  /// Unregister the current device from a topic, the topic is matched using the code of the topic.
  ///
  /// @param topics The topic you will unregister from.
  /// @returns A future that completes once the registration is successful.
  static Future<void> unregisterFromTopic(String topic) async =>
      MPush.unregisterFromTopic(topic);

  /// Unregister the current device from an array of topics, the topics are matched using the code of the topic.
  ///
  /// @param topics The array of topics you will unregister from.
  /// @returns A future that completes once the registration is successful.
  static Future<void> unregisterFromTopics(List<String> topics) async =>
      MPush.unregisterFromTopics(topics);

  /// Unregister the current device from all topics it is registred to.
  ///
  /// @returns A future that completes once the registration is successful.
  static Future<void> unregisterFromAllTopics() async =>
      MPush.unregisterFromAllTopics();

  /// Requests the token to APNS & GCM.
  ///
  /// This will not return the token, use the `onToken` callback to
  /// retrieve the token once the registration is completed with success.
  ///
  /// @returns A future that completes once the registration is started successfully.
  static Future<void> requestToken() async => MPush.requestToken();
}
