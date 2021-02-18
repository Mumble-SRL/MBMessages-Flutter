import 'package:flutter/foundation.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/push_notifications/mbpush_message.dart';

/// The type of message, in-app message or push.
enum MBMessageType {
  /// An in-app message.
  inAppMessage,

  /// A push message.
  push,
}

/// This object represents a message from MBurger.
class MBMessage {
  /// The id of the message.
  int id;

  /// The title of the message.
  String title;

  /// The description of the message.
  String messageDescription;

  /// The type of message.
  MBMessageType messageType;

  /// If the type of the message is in-app message, this is the in app message connected to the message.
  MBInAppMessage inAppMessage;

  /// If the type of the message is push, this is the push message connected to the message.
  MBPushMessage pushMessage;

  /// The start date of the message.
  DateTime startDate;

  /// The end date of the message.
  DateTime endDate;

  /// If automation is on for this message.
  bool automationIsOn;

  /// The number of days to wait to show the message.
  int sendAfterDays;

  /// The number of times this message needs to be repeated.
  int repeatTimes;

  /// The triggers for the messages.
  dynamic triggers;

  /// Initializes a message with the parameters passed.
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
    @required this.repeatTimes,
    @required this.triggers,
  });

  /// Initializes a message with the dictionary returned by the APIs.
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
    startDate = DateTime.fromMillisecondsSinceEpoch(startDateInt * 1000);

    int endDateInt = dictionary['ends_at'] ?? 0;
    endDate = DateTime.fromMillisecondsSinceEpoch(endDateInt * 1000);

    if (dictionary['automation'] is int) {
      automationIsOn = dictionary['automation'] == 1;
    } else {
      automationIsOn = dictionary['automation'] ?? false;
    }

    sendAfterDays = dictionary['send_after_days'];
    repeatTimes = dictionary['repeat'];

    triggers = dictionary['triggers'] ?? null;
  }

  /// The message type frm the string returned by the APIs.
  /// @param messageTypeString The string that needs to be converted to `MBMessageType`.
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
