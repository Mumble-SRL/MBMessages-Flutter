import 'dart:convert';

import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/push_notifications/mbpush.dart';
import 'package:http/http.dart' as http;
import 'package:mburger/mb_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The type of metric of the message, if the message has been viewed or if the user interacted with the push.
enum MBMessageMetricsMetric {
  /// View metric.
  view,

  /// Interaction metric.
  interaction,
}

/// The class that send metrics/analytics data to MBurger.
class MBMessageMetrics {
  /// Checks the launch notification and sends analytics data to MBurger if a notification has launched the app.
  static Future<void> checkLaunchNotification() async {
    Map<String, dynamic>? launchNotification =
        await MBPush.launchNotification();
    if (launchNotification != null) {
      notificationTapped(launchNotification);
    }
  }

  /// Called when a notification arrives sends the `MBMessageMetricsMetric.view` metric.
  static Future<void> notificationArrived(
    Map<String, dynamic> notification,
  ) async {
    int? messageId = notification['message_id'];
    if (messageId == null) {
      return;
    }
    return _createPushNotificationMetric(
      MBMessageMetricsMetric.view,
      messageId,
    );
  }

  /// Called when a notification is tapped, it sends the `MBMessageMetricsMetric.interaction` metric.
  /// If the `MBMessageMetricsMetric.view` metric has not been sent yet it sends also this metric.
  static Future<void> notificationTapped(
    Map<String, dynamic> notification,
  ) async {
    int? messageId = notification['message_id'];
    if (messageId == null) {
      return;
    }
    bool viewSent = await _pushNotificationMetricSent(
      MBMessageMetricsMetric.view,
      messageId,
    );
    if (!viewSent) {
      await _createMessageMetric(
        MBMessageMetricsMetric.view,
        messageId,
      );
      return _createPushNotificationMetric(
        MBMessageMetricsMetric.interaction,
        messageId,
      );
    } else {
      return _createPushNotificationMetric(
        MBMessageMetricsMetric.interaction,
        messageId,
      );
    }
  }

  /// Creates a metric for a push notification.
  /// @param metric The metric type.
  /// @param messageId The id of the message.
  static Future<void> _createPushNotificationMetric(
    MBMessageMetricsMetric metric,
    int messageId,
  ) async {
    bool metricSent = await _pushNotificationMetricSent(metric, messageId);
    if (metricSent) {
      return;
    }
    await _setPushNotificationMetricSent(metric, messageId);
    return _createMessageMetric(metric, messageId);
  }

  /// Called when an in-app message is showed, it sends the `MBMessageMetricsMetric.view` metric.
  static Future<void> inAppMessageShowed(MBMessage message) async {
    return _createMessageMetric(
      MBMessageMetricsMetric.view,
      message.id,
    );
  }

  /// Called when an in-app message has an interaction, it sends the `MBMessageMetricsMetric.interaction` metric.
  /// If the `MBMessageMetricsMetric.view` metric has not been sent yet it sends also this metric.
  static Future<void> inAppMessageInteracted(MBMessage message) async {
    return _createMessageMetric(
      MBMessageMetricsMetric.interaction,
      message.id,
    );
  }

  /// Sends the message metric to MBurger.
  /// @param metric The message metric to create.
  /// @param messageId The id of the message that will be showed.
  static Future<void> _createMessageMetric(
    MBMessageMetricsMetric metric,
    int messageId,
  ) async {
    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: true);

    Map<String, dynamic> parameters = {
      'metric': _metricStringForMetric(metric),
      'message_id': messageId,
    };
    parameters.addAll(defaultParameters);

    var uri = Uri.https(
      MBManager.shared.endpoint,
      'api/metrics',
    );

    var response = await http.post(
      uri,
      headers: headers,
      body: json.encode(parameters),
    );

    MBManager.checkResponse(response.body, checkBody: false);
  }

  /// Converts a `MBMessageMetricsMetric` to a `String` to send to MBurger APIs
  static String _metricStringForMetric(MBMessageMetricsMetric metric) {
    if (metric == MBMessageMetricsMetric.view) {
      return 'view';
    } else if (metric == MBMessageMetricsMetric.interaction) {
      return 'interaction';
    }
    return 'view';
  }

  /// If the push notification metric has been already sent or not.
  /// @param metric The metric type.
  /// @param messageId The id of the message.
  static Future<bool> _pushNotificationMetricSent(
    MBMessageMetricsMetric metric,
    int messageId,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> metricsStrings =
        prefs.getStringList(_notificationMetricsKey()) ?? [];
    return metricsStrings.contains(_metricString(metric, messageId));
  }

  /// Sets a push notification metric as sent in MBurger.
  /// @param metric The metric type.
  /// @param messageId The id of the message.
  static Future<void> _setPushNotificationMetricSent(
    MBMessageMetricsMetric metric,
    int messageId,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> metricsStrings = prefs.getStringList(
            'com.mumble.mburger.messages.pushNotificationViewed') ??
        [];
    String metricString = _metricString(metric, messageId);
    if (!metricsStrings.contains(metricString)) {
      metricsStrings.add(metricString);
      await prefs.setStringList(
        _notificationMetricsKey(),
        metricsStrings,
      );
    }
  }

  /// The metric string used to save in the shared preference if the metric has been sent or not.
  /// @param metric The metric type.
  /// @param messageId The id of the message.
  static String _metricString(
    MBMessageMetricsMetric metric,
    int messageId,
  ) {
    return _metricStringForMetric(metric) + '_' + messageId.toString();
  }

  /// The key used to store information in shared preferences.
  static String _notificationMetricsKey() {
    return 'com.mumble.mburger.messages.pushNotificationViewed';
  }
}
