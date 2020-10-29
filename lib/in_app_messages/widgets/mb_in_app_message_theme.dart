import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';

class MBInAppMessageTheme {
  final Color backgroundColor;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final Color closeButtonColor;
  final Color closeButtonBackgroundColor;
  final Color button1BackgroundColor;
  final TextStyle button1TextStyle;
  final Color button2BackgroundColor;
  final Color button2BorderColor;
  final TextStyle button2TextStyle;

  MBInAppMessageTheme({
    this.backgroundColor,
    this.titleStyle,
    this.bodyStyle,
    this.closeButtonColor,
    this.closeButtonBackgroundColor,
    this.button1BackgroundColor,
    this.button1TextStyle,
    this.button2BackgroundColor,
    this.button2BorderColor,
    this.button2TextStyle,
  });

  static MBInAppMessageTheme defaultThemeForMessage(
    BuildContext context,
    MBInAppMessage message,
  ) {
    ThemeData theme = Theme.of(context);
    Color mburgerColor = Color.fromRGBO(19, 140, 252, 1);
    Color mburgerDarkColor = Color.fromRGBO(4, 20, 68, 1);
    return MBInAppMessageTheme(
      backgroundColor: message.backgroundColor ?? Colors.white.withOpacity(0.9),
      titleStyle: theme.textTheme.headline2.copyWith(
        color: Colors.black,
        fontSize: 20,
      ),
      bodyStyle: theme.textTheme.bodyText1.copyWith(
        color: Colors.black,
      ),
      closeButtonColor: Colors.black,
      closeButtonBackgroundColor: Colors.white,
      button1BackgroundColor:
          message.style == MBInAppMessageStyle.fullscreenImage
              ? Colors.white
              : mburgerColor,
      button1TextStyle: theme.textTheme.bodyText1.copyWith(
        color: message.style == MBInAppMessageStyle.fullscreenImage
            ? mburgerDarkColor
            : Colors.white,
      ),
      button2BackgroundColor: Colors.transparent,
      button2TextStyle: theme.textTheme.bodyText1.copyWith(
        color: message.style == MBInAppMessageStyle.fullscreenImage
            ? Colors.white
            : mburgerColor,
      ),
      button2BorderColor: message.style == MBInAppMessageStyle.fullscreenImage
          ? Colors.white
          : mburgerColor,
    );
  }
}
