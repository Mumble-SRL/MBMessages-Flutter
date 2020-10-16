class MBPushMessage {
  String id;
  String title;
  String body;
  int badge;
  String sound;
  String launchImage;
  Map<String, dynamic> userInfo;
  bool sent;

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
