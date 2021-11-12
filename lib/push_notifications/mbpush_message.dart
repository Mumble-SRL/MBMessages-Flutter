/// A push message
class MBPushMessage {
  /// The id of the push message.
  final String id;

  /// The title of the push message.
  final String title;

  /// The body of the push message.
  final String body;

  /// The push notification badge value.
  final int? badge;

  /// The push notification custom sound.
  final String? sound;

  /// The push notification launch image.
  final String? launchImage;

  /// Additional data for push notifications.
  final Map<String, dynamic>? userInfo;

  /// If the push notification was sent or not by the server.
  final bool sent;

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
    required this.id,
    required this.title,
    required this.body,
    this.badge,
    this.sound,
    this.launchImage,
    this.userInfo,
    required this.sent,
  });

  /// Initializes a push message from the dictionary returned from the APIs.
  /// @param dictionary The dictionary returned from the APIs.
  factory MBPushMessage.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    String title = '';
    String body = '';
    bool sent = false;
    int? badge;
    String? sound;

    String? launchImage;
    Map<String, dynamic>? userInfo;

    if (dictionary['payload'] != null) {
      Map<String, dynamic> payload = dictionary['payload'];

      title = payload['title'] ?? '';
      body = payload['body'] ?? '';
      if (payload['sent'] is int) {
        sent = payload['sent'] == 1;
      } else if (payload['sent'] is bool) {
        sent = payload['sent'];
      }
      badge = payload['badge'];
      sound = payload['sound'];

      launchImage = payload['launch-image'];
      userInfo = payload['custom'];
    }

    return MBPushMessage(
      id: id,
      title: title,
      body: body,
      badge: badge,
      sound: sound,
      launchImage: launchImage,
      userInfo: userInfo,
      sent: sent,
    );
  }
}
