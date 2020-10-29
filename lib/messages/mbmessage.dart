import 'package:flutter/foundation.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/push_notifications/mbpush_message.dart';

enum MBMessageType {
  inAppMessage,
  push,
}

class MBMessage {
  int id;

  String title;

  String messageDescription;

  MBMessageType messageType;

  MBInAppMessage inAppMessage;

  MBPushMessage pushMessage;

  DateTime startDate;

  DateTime endDate;

  bool automationIsOn;

  int sendAfterDays;

  dynamic triggers;

  MBMessage({
    @required this.id,
    @required this.title,
    @required this.messageDescription,
    @required this.messageType,
    @required this.inAppMessage,
    @required this.pushMessage,
    @required this.startDate,
    @required this.endDate,
    @required this.automationIsOn,
    @required this.sendAfterDays,
    @required this.triggers,
  });

  MBMessage.fromDictionary(Map<String, dynamic> dictionary) {
    id = dictionary['id'];
    title = dictionary['title'];
    messageDescription = dictionary['description'];

    String typeString = dictionary['type'];
    messageType = _messageTypeFromString(typeString);

    Map<String, dynamic> content = dictionary['content'];
    if (content != null) {
      if (messageType == MBMessageType.inAppMessage) {
        inAppMessage = MBInAppMessage.fromDictionary(content);
      } else if (messageType == MBMessageType.push) {
        pushMessage = MBPushMessage.fromDictionary(content);
      }
    }

    int startDateInt = dictionary['starts_at'] ?? 0;
    startDate = DateTime.fromMicrosecondsSinceEpoch(startDateInt * 1000);

    int endDateInt = dictionary['ends_at'] ?? 0;
    endDate = DateTime.fromMicrosecondsSinceEpoch(endDateInt * 1000);

    if (dictionary['automation'] is int) {
      automationIsOn = dictionary['automation'] == 1;
    } else {
      automationIsOn = dictionary['automation'] ?? false;
    }

    sendAfterDays = dictionary['send_after_days'];

    triggers = dictionary['triggers'] ?? null;
  }

  static MBMessageType _messageTypeFromString(String messageTypeString) {
    if (messageTypeString == null) {
      return MBMessageType.inAppMessage;
    }
    if (messageTypeString == 'inApp') {
      return MBMessageType.inAppMessage;
    } else if (messageTypeString == 'push') {
      return MBMessageType.push;
    }
    return MBMessageType.inAppMessage;
  }
}
