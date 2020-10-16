import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mbmessages/mbmessages.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MBInAppMessageManager {
  static void presentMessages({
    @required List<MBMessage> messages,
    bool ignoreShowedMessages: false,
  }) async {
    List<MBMessage> messagesToShow = messages
        .where((message) => message.messageType == MBMessageType.inAppMessage)
        .toList();
    if (!ignoreShowedMessages) {
      List<MBMessage> messages = [];
      for (MBMessage message in messagesToShow) {
        bool messageHasBeenShowed = await _messageHasBeenShowed(message);
        if (!messageHasBeenShowed) {
          messages.add(message);
        }
      }
      messagesToShow = messages;
    }

    if (messagesToShow.length == 0) {
      return;
    }

    _presentMessage(
      index: 0,
      messages: messagesToShow,
    );
  }

  static _presentMessage({
    @required int index,
    @required List<MBMessage> messages,
  }) {
    if (index >= messages.length) {
      return;
    }
    MBMessage message = messages[index];
    print(message.inAppMessage);
    if (message.inAppMessage == null) {
      return;
    }

    BuildContext context = MBMessages.contextCallback();

    showDialog(
      context: context,
      builder: (context) => Container(
        height: 100,
        color: Colors.red,
      ),
    );
  }

  static Future<bool> _messageHasBeenShowed(MBMessage message) async {
    if (message.id == null) {
      return false;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> showedMessages = prefs.getStringList(_showedMessageKey) ?? [];
    return showedMessages.contains(message.id.toString());
  }

  static Future<void> _setMessageShowed(MBMessage message) async {
    if (message.id == null) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> showedMessages = prefs.getStringList(_showedMessageKey) ?? [];
    if (!showedMessages.contains(message.id)) {
      showedMessages.add(message.id.toString());
      await prefs.setStringList(
        _showedMessageKey,
        showedMessages,
      );
    }
  }

  static String get _showedMessageKey =>
      'com.mumble.mburger.messages.showedMessages';
}
