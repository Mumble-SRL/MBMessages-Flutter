import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_banner_bottom.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_banner_top.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_center.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_fullscreen_image.dart';
import 'package:mbmessages/mbmessages.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/metrics/mbmessage_metrics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

/// Main class that manages the displaying of in-app messages, and keeps references of what messages have already been displayed.
class MBInAppMessageManager {
  /// If the manager is showing messages, this var has the messages showed.
  static List<MBMessage>? _showingMessages;

  /// Present an array of in-app messages, if they're not been already presented
  /// @param messages The messages that needs to be presented
  /// @param ignoreShowedMessages if this is true a message will be displayed even if it has already been displayed
  /// @param themeForMessage A function that provides the theme of an in-app message.
  /// @param onButtonPressed Function called when a button is pressed.
  static void presentMessages({
    required List<MBMessage> messages,
    bool ignoreShowedMessages = false,
    MBInAppMessageTheme Function(BuildContext, MBInAppMessage)? themeForMessage,
    Function(MBInAppMessageButton)? onButtonPressed,
  }) async {
    if (_showingMessages != null) {
      List<int> showingMessagesIds = [];
      if (_showingMessages != null) {
        showingMessagesIds = _showingMessages!.map((m) => m.id).toList();
      }
      List<MBMessage> messagesWithoutShowedMessages = messages;
      messagesWithoutShowedMessages
          .removeWhere((m) => showingMessagesIds.contains(m.id));
      await Future.delayed(const Duration(seconds: 1));
      presentMessages(
        messages: messagesWithoutShowedMessages,
        ignoreShowedMessages: ignoreShowedMessages,
        themeForMessage: themeForMessage,
        onButtonPressed: onButtonPressed,
      );
      return;
    }

    List<MBMessage> messagesToShow = messages
        .where((message) => message.messageType == MBMessageType.inAppMessage)
        .toList();
    if (!ignoreShowedMessages) {
      List<MBMessage> messages = [];
      for (MBMessage message in messagesToShow) {
        bool needsToShowMessage = await _needsToShowMessage(message);
        if (needsToShowMessage) {
          messages.add(message);
        }
      }
      messagesToShow = messages;
    }

    if (messagesToShow.isEmpty) {
      return;
    }

    messagesToShow.sort(
      (m1, m2) => -m1.createdAt.compareTo(m2.createdAt),
    );

    _showingMessages = messagesToShow;
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
    required int index,
    required List<MBMessage> messages,
    required MBInAppMessageTheme Function(BuildContext, MBInAppMessage)?
        themeForMessage,
    required Function(MBInAppMessageButton)? onButtonPressed,
  }) async {
    if (index >= messages.length) {
      _showingMessages = null;
      return;
    }
    MBMessage message = messages[index];
    MBInAppMessage? inAppMessage = message.inAppMessage;
    if (inAppMessage == null) {
      _showingMessages = null;
      return;
    }

    if (MBMessages.contextCallback == null) {
      _showingMessages = null;
      return;
    }

    BuildContext? context;
    if (MBMessages.contextCallback != null) {
      context = MBMessages.contextCallback!();
    }

    if (context == null) {
      _showingMessages = null;
      return;
    }

    MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);

    MBInAppMessageTheme theme = themeForMessage != null
        ? themeForMessage(context, inAppMessage)
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

    // For blocking messages add WillPopScope widget to disable Android back button
    if (inAppMessage.isBlocking) {
      widget = PopScope(
        canPop: false,
        child: widget,
      );
    }

    await _setMessageShowed(message);
    MBMessageMetrics.inAppMessageShowed(message);

    if (context.mounted) {
      dynamic result = await showGeneralDialog(
        context: context,
        barrierDismissible: !inAppMessage.isBlocking ? true : false,
        barrierLabel: materialLocalizations.modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.5),
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

      bool booleanResult = result is bool ? result : false;

      /// Result is false if the message has been hidden by a button press
      /// Otherwise it's true, defaults to true if it's null because dismissing it
      /// from the barrier returns null
      if (booleanResult) {
        if (index + 1 < messages.length) {
          _presentMessage(
            index: index + 1,
            messages: messages,
            themeForMessage: themeForMessage,
            onButtonPressed: onButtonPressed,
          );
        } else {
          _showingMessages = null;
        }
      } else {
        _showingMessages = null;
      }
    }
  }

  /// Returns and configures the widget for the message passed.
  /// @param context The `BuildContext`, used to dismiss the widget correctly
  /// @param message The in-app message.
  /// @param onButtonPressed Function called when a button is pressed.
  /// @param theme The theme that will be used in the message widget
  static Future<Widget> _widgetForInAppMessage({
    required BuildContext context,
    required MBMessage message,
    required Function(MBInAppMessageButton)? onButtonPressed,
    required MBInAppMessageTheme theme,
  }) async {
    MBInAppMessage? inAppMessage = message.inAppMessage;
    if (inAppMessage == null) {
      return const SizedBox.shrink();
    }
    switch (inAppMessage.style) {
      case MBInAppMessageStyle.bannerTop:
        return MBInAppMessageBannerTop(
          mainContext: context,
          message: message,
          onButtonPressed: onButtonPressed,
          theme: theme,
        );
      case MBInAppMessageStyle.bannerBottom:
        return MBInAppMessageBannerBottom(
          mainContext: context,
          message: message,
          onButtonPressed: onButtonPressed,
          theme: theme,
        );
      case MBInAppMessageStyle.center:
        return MBInAppMessageCenter(
          mainContext: context,
          message: message,
          onButtonPressed: onButtonPressed,
          theme: theme,
        );
      case MBInAppMessageStyle.fullscreenImage:
        File? imageFile = await _downloadImage(inAppMessage);
        if (context.mounted) {
          return MBInAppMessageFullscreenImage(
            mainContext: context,
            message: message,
            imageFile: imageFile,
            onButtonPressed: onButtonPressed,
            theme: theme,
          );
        } else {
          return const SizedBox.shrink();
        }
    }
  }

  /// Builds the transition for the message passed.
  /// All in-app messages appear from the bottom with the exception of bannerTop that appears from the top.
  static Widget _transitionForMessage(
    MBMessage message,
    Animation<double> animation,
    Widget child,
  ) {
    MBInAppMessage? inAppMessage = message.inAppMessage;
    Animation<Offset> offset;

    if (inAppMessage?.style == MBInAppMessageStyle.bannerTop) {
      offset = Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: const Offset(0.0, 0.0),
      ).animate(animation);
    } else {
      offset = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: const Offset(0.0, 0.0),
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
  static Future<File?> _downloadImage(MBInAppMessage inAppMessage) async {
    if (inAppMessage.image == null || inAppMessage.image == '') {
      return null;
    }

    String image = inAppMessage.image!;
    Uri? imageUri = Uri.tryParse(image);
    if (imageUri == null) {
      return null;
    }

    final fileName = basename(image);
    final response = await http.get(imageUri);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, fileName));
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

//region message showed or not

  /// If the manager needs to show an in-app message or not.
  /// @param message The in-app message to show.
  /// @returns A future that completes with a bool that tells if the message needs to be showed or not.
  static Future<bool> _needsToShowMessage(MBMessage message) async {
    if (message.endDate != null) {
      DateTime endDate = message.endDate!;
      if (endDate.millisecondsSinceEpoch <
          DateTime.now().millisecondsSinceEpoch) {
        return false;
      }
    }

    // Always show a blocking in app message
    if (message.inAppMessage?.isBlocking == true) {
      return true;
    }

    Map<String, dynamic> showedMessagesCount = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? showedMessagesString = prefs.getString(_showedMessageKey);
    if (showedMessagesString != null) {
      showedMessagesCount =
          Map<String, dynamic>.from(json.decode(showedMessagesString));
    }
    int messageShowCount = showedMessagesCount[message.id.toString()] ?? 0;
    return messageShowCount < message.repeatTimes;
  }

  /// Set the message as showed in shared_preferences
  /// @param message The in-app message to set as showed.
  static Future<void> _setMessageShowed(MBMessage message) async {
    Map<String, dynamic> showedMessagesCount = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? showedMessagesString = prefs.getString(_showedMessageKey);
    if (showedMessagesString != null) {
      showedMessagesCount =
          Map<String, dynamic>.from(json.decode(showedMessagesString));
    }
    int messageShowCount = showedMessagesCount[message.id.toString()] ?? 0;
    showedMessagesCount[message.id.toString()] = messageShowCount + 1;
    await prefs.setString(_showedMessageKey, json.encode(showedMessagesCount));
  }

  /// The key used to store showed messages in shared_preferences.
  static String get _showedMessageKey =>
      'com.mumble.mburger.messages.showedMessages.count';
//endregion
}
