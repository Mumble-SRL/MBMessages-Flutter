import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/in_app_messages/widgets/tappable_widget.dart';

class MBInAppMessageButtonWidget extends StatelessWidget {
  final BuildContext mainContext;
  final MBInAppMessageButton button;
  final double height;
  final bool isButton1;
  final VoidCallback onTap;
  final MBInAppMessageTheme theme;

  const MBInAppMessageButtonWidget({
    Key key,
    @required this.mainContext,
    @required this.button,
    @required this.height,
    @required this.isButton1,
    @required this.onTap,
    @required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        isButton1 ? theme.button1TextStyle : theme.button2TextStyle;
    if (button.titleColor != null) {
      textStyle = textStyle.copyWith(color: button.titleColor);
    }
    Color backgroundColor;
    if (button.backgroundColor != null) {
      backgroundColor = button.backgroundColor;
    } else {
      backgroundColor = isButton1
          ? theme.button1BackgroundColor
          : theme.button2BackgroundColor;
    }
    Color borderColor = Colors.transparent;
    if (!isButton1) {
      borderColor = theme.button2BorderColor;
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
          child: Center(
            child: Text(
              button.title,
              style: textStyle,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
