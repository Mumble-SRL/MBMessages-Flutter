import 'dart:convert';

import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/push_notifications/mbpush.dart';
import 'package:http/http.dart' as http;
import 'package:mburger/mb_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MBMessageMetricsMetric {
  view,
  interaction,
}

class MBMessageMetrics {
  static Future<void> checkLaunchNotification() async {
    Map<String, dynamic> launchNotification = await MBPush.launchNotification();
    if (launchNotification != null) {
      notificationTapped(launchNotification);
    }
  }

  static Future<void> notificationArrived(
      Map<String, dynamic> notification) async {
    if (notification == null) {
      return;
    }
    int messageId = notification['message_id'];
    if (messageId == null) {
      return;
    }
    return _createPushNotificationMetric(
      MBMessageMetricsMetric.view,
      messageId,
    );
  }

  static Future<void> notificationTapped(
      Map<String, dynamic> notification) async {
    if (notification == null) {
      return;
    }
    int messageId = notification['message_id'];
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

  static Future<void> inAppMessageShowed(MBMessage message) async {
    return _createMessageMetric(
      MBMessageMetricsMetric.view,
      message.id,
    );
  }

  static Future<void> inAppMessageInteracted(MBMessage message) async {
    return _createMessageMetric(
      MBMessageMetricsMetric.interaction,
      message.id,
    );
  }

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

  static String _metricStringForMetric(MBMessageMetricsMetric metric) {
    if (metric == MBMessageMetricsMetric.view) {
      return 'view';
    } else if (metric == MBMessageMetricsMetric.interaction) {
      return 'interaction';
    }
    return 'view';
  }

  static Future<bool> _pushNotificationMetricSent(
    MBMessageMetricsMetric metric,
    int messageId,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> metricsStrings =
        prefs.getStringList(_notificationMetricsKey());
    return metricsStrings.contains(_metricString(metric, messageId));
  }

  static Future<bool> _setPushNotificationMetricSent(
    MBMessageMetricsMetric metric,
    int messageId,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> metricsStrings = prefs
        .getStringList('com.mumble.mburger.messages.pushNotificationViewed');
    String metricString = _metricString(metric, messageId);
    if (!metricsStrings.contains(metricString)) {
      metricsStrings.add(metricString);
      await prefs.setStringList(
        _notificationMetricsKey(),
        metricsStrings,
      );
    }
  }

  static String _metricString(
    MBMessageMetricsMetric metric,
    int messageId,
  ) {
    return _metricStringForMetric(metric) + '_' + messageId.toString();
  }

  static String _notificationMetricsKey() {
    return 'com.mumble.mburger.messages.pushNotificationViewed';
  }
}
