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
  final int id;

  /// The title of the message.
  final String title;

  /// The description of the message.
  final String messageDescription;

  /// The type of message.
  final MBMessageType messageType;

  /// If the type of the message is in-app message, this is the in app message connected to the message.
  final MBInAppMessage? inAppMessage;

  /// If the type of the message is push, this is the push message connected to the message.
  final MBPushMessage? pushMessage;

  /// The creation date of the message.
  final DateTime createdAt;

  /// The start date of the message.
  final DateTime startDate;

  /// The end date of the message.
  final DateTime endDate;

  /// If automation is on for this message.
  final bool automationIsOn;

  /// The number of days to wait to show the message.
  int sendAfterDays;

  /// The number of times this message needs to be repeated.
  int repeatTimes;

  /// The triggers for the messages.
  dynamic? triggers;

  /// Initializes a message with the parameters passed.
  MBMessage({
    required this.id,
    required this.title,
    required this.messageDescription,
    required this.messageType,
    this.inAppMessage,
    this.pushMessage,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.automationIsOn,
    required this.sendAfterDays,
    required this.repeatTimes,
    this.triggers,
  });

  /// Initializes a message with the dictionary returned by the APIs.
  factory MBMessage.fromDictionary(Map<String, dynamic> dictionary) {
    int id = dictionary['id'] is int ? dictionary['id'] : 0;
    String title = dictionary['title'] is String ? dictionary['title'] : '';
    String messageDescription =
        dictionary['description'] is String ? dictionary['description'] : '';

    String? typeString = dictionary['type'];
    MBMessageType messageType = _messageTypeFromString(typeString);

    MBInAppMessage? inAppMessage;
    MBPushMessage? pushMessage;
    Map<String, dynamic>? content = dictionary['content'];
    if (content != null) {
      if (messageType == MBMessageType.inAppMessage) {
        inAppMessage = MBInAppMessage.fromDictionary(content);
      } else if (messageType == MBMessageType.push) {
        pushMessage = MBPushMessage.fromDictionary(content);
      }
    }

    int creationDateInt = dictionary['created_at'] ?? 0;
    DateTime creationDate =
        DateTime.fromMillisecondsSinceEpoch(creationDateInt * 1000);

    int startDateInt = dictionary['starts_at'] ?? 0;
    DateTime startDate =
        DateTime.fromMillisecondsSinceEpoch(startDateInt * 1000);

    int endDateInt = dictionary['ends_at'] ?? 0;
    DateTime endDate = DateTime.fromMillisecondsSinceEpoch(endDateInt * 1000);

    bool automationIsOn = false;
    if (dictionary['automation'] is int) {
      automationIsOn = dictionary['automation'] == 1;
    } else if (dictionary['automation'] is bool) {
      automationIsOn = dictionary['automation'] ?? false;
    }

    int sendAfterDays = dictionary['send_after_days'] is int
        ? dictionary['send_after_days']
        : 0;
    int repeatTimes = dictionary['repeat'] is int ? dictionary['repeat'] : 1;

    dynamic triggers = dictionary['triggers'];

    return MBMessage(
      id: id,
      title: title,
      messageDescription: messageDescription,
      messageType: messageType,
      inAppMessage: inAppMessage,
      pushMessage: pushMessage,
      createdAt: creationDate,
      startDate: startDate,
      endDate: endDate,
      automationIsOn: automationIsOn,
      sendAfterDays: sendAfterDays,
      repeatTimes: repeatTimes,
      triggers: triggers,
    );
  }

  /// The message type frm the string returned by the APIs.
  /// @param messageTypeString The string that needs to be converted to `MBMessageType`.
  static MBMessageType _messageTypeFromString(String? messageTypeString) {
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
