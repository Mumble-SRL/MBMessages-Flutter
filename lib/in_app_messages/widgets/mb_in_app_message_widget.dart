import 'package:flutter/cupertino.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/messages/mbmessage.dart';

class MBInAppMessageWidget extends StatelessWidget {
  final MBMessage message;

  MBInAppMessage get inAppMessage => message.inAppMessage;

  const MBInAppMessageWidget({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
