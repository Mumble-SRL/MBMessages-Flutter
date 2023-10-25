import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';

/// Theme for in-app message
class MBInAppMessageTheme {
  /// The background color for the alert.
  final Color? backgroundColor;

  /// The title text style.
  final TextStyle? titleStyle;

  /// The body text style.
  final TextStyle? bodyStyle;

  /// The color of the close button icon.
  final Color? closeButtonColor;

  /// The background color of the close button.
  final Color? closeButtonBackgroundColor;

  /// The background color for the first button.
  final Color? button1BackgroundColor;

  /// The text style for the first button.
  final TextStyle? button1TextStyle;

  /// The border radius for the first button.
  final double? button1BorderRadius;

  /// The background color for the second button.
  final Color? button2BackgroundColor;

  /// The border color for the second button.
  final Color? button2BorderColor;

  /// The text style for the second button.
  final TextStyle? button2TextStyle;

  /// The border radius for the second button.
  final double? button2BorderRadius;

  /// Initializes a new in-app message theme with the parameters passed.
  const MBInAppMessageTheme({
    this.backgroundColor,
    this.titleStyle,
    this.bodyStyle,
    this.closeButtonColor,
    this.closeButtonBackgroundColor,
    this.button1BackgroundColor,
    this.button1TextStyle,
    this.button1BorderRadius,
    this.button2BackgroundColor,
    this.button2BorderColor,
    this.button2TextStyle,
    this.button2BorderRadius,
  });

  /// Provides a default theme for the in-app message passed.
  /// The fonts are taken from the Theme of the context passed:
  ///   - title font: `theme.textTheme.headline2`
  ///   - body font: `theme.textTheme.bodyText1`
  /// By default messages has a white background an black texts.
  /// The background color of the button is the MBurger blue and the text color is white.
  /// @param context The `BuildContext`.
  /// @param message The in-app message.
  /// @returns The default theme for the in-app message.
  static MBInAppMessageTheme defaultThemeForMessage(
    BuildContext context,
    MBInAppMessage message,
  ) {
    ThemeData theme = Theme.of(context);
    Color mburgerColor = const Color.fromRGBO(19, 140, 252, 1);
    Color mburgerDarkColor = const Color.fromRGBO(4, 20, 68, 1);
    return MBInAppMessageTheme(
      backgroundColor: message.backgroundColor ?? Colors.white.withOpacity(0.9),
      titleStyle: theme.textTheme.displayMedium?.copyWith(
        color: Colors.black,
        fontSize: 20,
      ),
      bodyStyle: theme.textTheme.bodyLarge?.copyWith(
        color: Colors.black,
      ),
      closeButtonColor: Colors.black,
      closeButtonBackgroundColor: Colors.white,
      button1BackgroundColor:
          message.style == MBInAppMessageStyle.fullscreenImage
              ? Colors.white
              : mburgerColor,
      button1TextStyle: theme.textTheme.bodyLarge?.copyWith(
        color: message.style == MBInAppMessageStyle.fullscreenImage
            ? mburgerDarkColor
            : Colors.white,
      ),
      button1BorderRadius: 10,
      button2BackgroundColor: Colors.transparent,
      button2TextStyle: theme.textTheme.bodyLarge?.copyWith(
        color: message.style == MBInAppMessageStyle.fullscreenImage
            ? Colors.white
            : mburgerColor,
      ),
      button2BorderColor: message.style == MBInAppMessageStyle.fullscreenImage
          ? Colors.white
          : mburgerColor,
      button2BorderRadius: 10,
    );
  }

  /// Creates a copy of this theme but with the given fields replaced with the new values
  MBInAppMessageTheme copyWith({
    Color? backgroundColor,
    TextStyle? titleStyle,
    TextStyle? bodyStyle,
    Color? closeButtonColor,
    Color? closeButtonBackgroundColor,
    Color? button1BackgroundColor,
    TextStyle? button1TextStyle,
    double? button1BorderRadius,
    Color? button2BackgroundColor,
    Color? button2BorderColor,
    TextStyle? button2TextStyle,
    double? button2BorderRadius,
  }) {
    return MBInAppMessageTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleStyle: titleStyle ?? this.titleStyle,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      closeButtonColor: closeButtonColor ?? this.closeButtonColor,
      closeButtonBackgroundColor:
          closeButtonBackgroundColor ?? this.closeButtonBackgroundColor,
      button1BackgroundColor:
          button1BackgroundColor ?? this.button1BackgroundColor,
      button1TextStyle: button1TextStyle ?? this.button1TextStyle,
      button1BorderRadius: button1BorderRadius ?? this.button1BorderRadius,
      button2BackgroundColor:
          button2BackgroundColor ?? this.button2BackgroundColor,
      button2BorderColor: button2BorderColor ?? this.button2BorderColor,
      button2TextStyle: button2TextStyle ?? this.button2TextStyle,
      button2BorderRadius: button2BorderRadius ?? this.button2BorderRadius,
    );
  }
}
