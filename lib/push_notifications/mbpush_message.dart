import 'package:flutter/foundation.dart';

/// A push message
class MBPushMessage {
  /// The id of the push message.
  String id;

  /// The title of the push message.
  String title;

  /// The body of the push message.
  String body;

  /// The push notification badge value.
  int badge;

  /// The push notification custom sound.
  String sound;

  /// The push notification launch image.
  String launchImage;

  /// Additional data for push notifications.
  Map<String, dynamic> userInfo;

  /// If the push notification was sent or not by the server.
  bool sent;

  /// Initializes a new push message with the data given.
  /// @param id The id of the push message.
  /// @param title The title of the push message.
  /// @param body The body of the push message.
  /// @param badge The push notification badge value.
  /// @param sound The push notification custom sound.
  /// @param launchImage The push notification launch image.
  /// @param userInfo Additional data for push notifications.
  /// @param sent If the push notification was sent or not by the server.
  MBPushMessage({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.badge,
    @required this.sound,
    @required this.launchImage,
    @required this.userInfo,
    @required this.sent,
  });

  /// Initializes a push message from the dictionary returned from the APIs.
  /// @param dictionary The dictionary returned from the APIs.
  MBPushMessage.fromDictionary(Map<String, dynamic> dictionary) {
    id = dictionary['id'];

    if (dictionary['payload'] != null) {
      Map<String, dynamic> payload = dictionary['payload'];

      title = payload['title'];
      body = payload['body'];
      if (payload['sent'] is int) {
        sent = payload['sent'] == 1;
      } else {
        sent = payload['sent'];
      }
      badge = payload['badge'];
      sound = payload['sound'];

      launchImage = payload['launch-image'];
      userInfo = payload['custom'];
    }
  }
}
