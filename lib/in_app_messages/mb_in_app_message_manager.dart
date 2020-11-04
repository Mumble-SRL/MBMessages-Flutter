import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_banner_bottom.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_banner_top.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_center.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_fullscreen_image.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/mbmessages.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/metrics/mbmessage_metrics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

/// Main class that manages the displaying of in-app messages, and keeps references of what messages have already been displayed.
class MBInAppMessageManager {
  /// Present an array of in-app messages, if they're not been already presented
  /// @param messages The messages that needs to be presented
  /// @param ignoreShowedMessages if this is true a message will be displayed even if it has already been displayed
  /// @param themeForMessage A function that provides the theme of an in-app message.
  /// @param onButtonPressed Function called when a button is pressed.
  static void presentMessages({
    @required List<MBMessage> messages,
    bool ignoreShowedMessages: false,
    MBInAppMessageTheme Function(MBInAppMessage) themeForMessage,
    Function(MBInAppMessageButton) onButtonPressed,
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
      themeForMessage: themeForMessage,
      onButtonPressed: onButtonPressed,
    );
  }

  /// Presents a message at the `index` specified of the `messages` array.
  /// @param index The index of the message to show.
  /// @param messages The list of messages.
  /// @param themeForMessage A function that provides the theme of an in-app message.
  /// @param onButtonPressed Function called when a button is pressed.
  static _presentMessage({
    @required int index,
    @required List<MBMessage> messages,
    @required MBInAppMessageTheme Function(MBInAppMessage) themeForMessage,
    @required Function(MBInAppMessageButton) onButtonPressed,
  }) async {
    if (index >= messages.length) {
      return;
    }
    MBMessage message = messages[index];
    if (message.inAppMessage == null) {
      return;
    }

    MBInAppMessage inAppMessage = message.inAppMessage;

    if (MBMessages.contextCallback == null) {
      return;
    }

    BuildContext context = MBMessages.contextCallback();

    bool isBanner = inAppMessage.style == MBInAppMessageStyle.bannerTop ||
        inAppMessage.style == MBInAppMessageStyle.bannerBottom;

    MBInAppMessageTheme theme = themeForMessage != null
        ? themeForMessage(inAppMessage)
        : MBInAppMessageTheme.defaultThemeForMessage(context, inAppMessage);
    Widget widget = await _widgetForInAppMessage(
      context: context,
      message: message,
      onButtonPressed: (button) {
        MBMessageMetrics.inAppMessageInteracted(message);
        if (onButtonPressed != null) {
          onButtonPressed(button);
        }
      },
      theme: theme,
    );

    await _setMessageShowed(message);
    MBMessageMetrics.inAppMessageShowed(message);

    bool result = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor:
          isBanner ? Colors.transparent : Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          _transitionForMessage(
        message,
        animation,
        child,
      ),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) =>
          widget,
    );

    /// Result is false if the message has been hidden by a button press
    /// Otherwise it's true, defaults to true if it's null because dismissing it
    /// from the barrier returns null
    if (result ?? true) {
      if (index + 1 < messages.length) {
        _presentMessage(
          index: index + 1,
          messages: messages,
          themeForMessage: themeForMessage,
          onButtonPressed: onButtonPressed,
        );
      }
    }
  }

  /// Returns and configures the widget for the message passed.
  /// @param context The `BuildContext`, used to dismiss the widget correctly
  /// @param message The in-app message.
  /// @param onButtonPressed Function called when a button is pressed.
  /// @param theme The theme that will be used in the message widget
  static Future<Widget> _widgetForInAppMessage({
    @required BuildContext context,
    @required MBMessage message,
    @required Function(MBInAppMessageButton) onButtonPressed,
    @required MBInAppMessageTheme theme,
  }) async {
    MBInAppMessage inAppMessage = message.inAppMessage;
    switch (inAppMessage.style) {
      case MBInAppMessageStyle.bannerTop:
        return MBInAppMessageBannerTop(
          mainContext: context,
          message: message,
          onButtonPressed: onButtonPressed,
          theme: theme,
        );
        break;
      case MBInAppMessageStyle.bannerBottom:
        return MBInAppMessageBannerBottom(
          mainContext: context,
          message: message,
          onButtonPressed: onButtonPressed,
          theme: theme,
        );
        break;
      case MBInAppMessageStyle.center:
        return MBInAppMessageCenter(
          mainContext: context,
          message: message,
          onButtonPressed: onButtonPressed,
          theme: theme,
        );
        break;
      case MBInAppMessageStyle.fullscreenImage:
        File imageFile = await _downloadImage(inAppMessage);
        return MBInAppMessageFullscreenImage(
          mainContext: context,
          message: message,
          imageFile: imageFile,
          onButtonPressed: onButtonPressed,
          theme: theme,
        );
        break;
    }
    return Container();
  }

  /// Builds the transition for the message passed.
  /// All in-app messages appear from the bottom with the exception of bannerTop that appears from the top.
  static Widget _transitionForMessage(
    MBMessage message,
    Animation animation,
    Widget child,
  ) {
    MBInAppMessage inAppMessage = message.inAppMessage;
    Animation<Offset> offset;

    if (inAppMessage.style == MBInAppMessageStyle.bannerTop) {
      offset = Tween<Offset>(
        begin: Offset(0.0, -1.0),
        end: Offset(0.0, 0.0),
      ).animate(animation);
    } else {
      offset = Tween<Offset>(
        begin: Offset(0.0, 1.0),
        end: Offset(0.0, 0.0),
      ).animate(animation);
    }
    return SlideTransition(
      position: offset,
      child: child,
    );
  }

  /// Downloads and saves the image for an in-app message
  /// @param inAppMessage The in-app message
  /// @returns A Future that completes with the File where the image has been downloaded.
  /// If the in-app message doesn't have an image it returns null.
  static Future<File> _downloadImage(MBInAppMessage inAppMessage) async {
    if (inAppMessage.image == null || inAppMessage.image == '') {
      return null;
    }

    final fileName = basename(inAppMessage.image);
    final response = await http.get(inAppMessage.image);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, fileName));
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

//region message showed or not

  /// If an in-app message has already been showed or not.
  /// @param message The in-app message to show.
  /// @returns A future that completes with a bool that tells if the message has been showed or not.
  static Future<bool> _messageHasBeenShowed(MBMessage message) async {
    if (message.id == null) {
      return false;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> showedMessages = prefs.getStringList(_showedMessageKey) ?? [];
    return showedMessages.contains(message.id.toString());
  }

  /// Set the message as showed in shared_preferences
  /// @param message The in-app message to set as showed.
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

  /// The key used to store showed messages in shared_preferences.
  static String get _showedMessageKey =>
      'com.mumble.mburger.messages.showedMessages';
//endregion
}
