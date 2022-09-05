import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/src/widgets/tappable_widget.dart';

/// A button of an in app message widget.
class MBInAppMessageButtonWidget extends StatelessWidget {
  /// The main context, used to dismiss the message correctly.
  final BuildContext mainContext;

  /// The `MBInAppMessageButton`.
  final MBInAppMessageButton button;

  /// The height of the button.
  final double height;

  /// If it's the first button.
  final bool isButton1;

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// The message theme.
  final MBInAppMessageTheme theme;

  const MBInAppMessageButtonWidget({
    Key? key,
    required this.mainContext,
    required this.button,
    required this.height,
    required this.isButton1,
    required this.onTap,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle =
        isButton1 ? theme.button1TextStyle : theme.button2TextStyle;
    if (button.titleColor != null) {
      textStyle = textStyle?.copyWith(color: button.titleColor);
    }
    Color? backgroundColor;
    if (button.backgroundColor != null) {
      backgroundColor = button.backgroundColor;
    } else {
      backgroundColor = isButton1
          ? theme.button1BackgroundColor
          : theme.button2BackgroundColor;
    }
    Color borderColor = Colors.transparent;
    if (!isButton1) {
      if (theme.button2BorderColor != null) {
        borderColor = theme.button2BorderColor!;
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(height / 2)),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(height / 2)),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: TappableWidget(
          onTap: onTap,
          child: Center(
            child: Text(
              button.title,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
