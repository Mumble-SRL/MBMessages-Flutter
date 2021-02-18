import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/widgets/tappable_widget.dart';
import 'package:mbmessages/messages/mbmessage.dart';

import 'mb_in_app_message_button_widget.dart';
import 'mb_in_app_message_theme.dart';

/// This widget is displayed in the middle of the screen, coming from the bottom (as a modal view) when the in app message has the style `MBInAppMessageStyle.center`
class MBInAppMessageCenter extends StatefulWidget {
  /// The main context, used to dismiss the message correctly
  final BuildContext mainContext;

  /// The message.
  final MBMessage message;

  /// Function called when the button is pressed.
  final Function(MBInAppMessageButton) onButtonPressed;

  /// The theme to use for this message.
  final MBInAppMessageTheme theme;

  /// Initializes a `MBInAppMessageCenter` with the parameters passed
  const MBInAppMessageCenter({
    Key key,
    @required this.mainContext,
    @required this.message,
    @required this.onButtonPressed,
    @required this.theme,
  });

  @override
  _MBInAppMessageCenterState createState() => _MBInAppMessageCenterState();
}

class _MBInAppMessageCenterState extends State<MBInAppMessageCenter> {
  /// Returns the in-app message of this message
  MBInAppMessage get inAppMessage => widget.message.inAppMessage;

  /// Timer used to dismiss the message after the defined duration is passed.
  Timer timer;

  @override
  void initState() {
    if (inAppMessage.duration != -1 && inAppMessage.duration != null) {
      timer = Timer(Duration(seconds: inAppMessage.duration.toInt()), () {
        timer?.cancel();
        Navigator.of(widget.mainContext).pop(true);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color containerColor = Colors.white;
    if (inAppMessage.backgroundColor != null) {
      containerColor = inAppMessage.backgroundColor;
    } else {
      containerColor = widget.theme.backgroundColor;
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 100,
          minWidth: MediaQuery.of(context).size.width - 20,
          maxWidth: MediaQuery.of(context).size.width - 20,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(162, 162, 162, 0.37),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.loose,
            children: [
              _column(),
              _closeButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// The main column of contents.
  Widget _column() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _image(),
          Flexible(child: _content()),
          _buttons(),
        ],
      ),
    );
  }

  /// The image for the widget.
  Widget _image() {
    if (inAppMessage.image != null && inAppMessage.image != '') {
      const double imageHeight = 175.0;
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: imageHeight,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 10 * 2,
          ),
          child: Image.network(
            inAppMessage.image,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return Container();
  }

  /// The main textual content of the widget.
  Widget _content() {
    bool hasTitle = inAppMessage.title != null && inAppMessage.title != '';
    bool hasBody = inAppMessage.body != null && inAppMessage.body != '';
    TextStyle titleStyle = widget.theme.titleStyle;
    if (inAppMessage.titleColor != null) {
      titleStyle = titleStyle.copyWith(color: inAppMessage.titleColor);
    }
    TextStyle bodyStyle = widget.theme.bodyStyle;
    if (inAppMessage.bodyColor != null) {
      bodyStyle = bodyStyle.copyWith(color: inAppMessage.bodyColor);
    }
    return Padding(
      padding: EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hasTitle
              ? Text(
                  inAppMessage.title,
                  style: titleStyle,
                )
              : Container(),
          Container(height: hasTitle && hasBody ? 20 : 0),
          hasBody
              ? Text(
                  inAppMessage.body,
                  style: bodyStyle,
                )
              : Container(),
        ],
      ),
    );
  }

  /// The buttons of the widget.
  Widget _buttons() {
    bool hasButtons = inAppMessage.buttons?.length != 0;
    if (!hasButtons) {
      return Container();
    }
    const double buttonHeight = 44;
    bool has2Buttons = inAppMessage.buttons.length == 2;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        height: has2Buttons ? buttonHeight * 2 + 10 : buttonHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MBInAppMessageButtonWidget(
                mainContext: widget.mainContext,
                button: inAppMessage.buttons[0],
                height: buttonHeight,
                onTap: () => _buttonPressed(inAppMessage.buttons[0]),
                theme: widget.theme,
                isButton1: true,
              ),
            ),
            Container(height: has2Buttons ? 10 : 0),
            has2Buttons
                ? Expanded(
                    child: MBInAppMessageButtonWidget(
                      mainContext: widget.mainContext,
                      button: inAppMessage.buttons[1],
                      height: buttonHeight,
                      onTap: () => _buttonPressed(inAppMessage.buttons[1]),
                      theme: widget.theme,
                      isButton1: false,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  /// Function called when a button is pressed.
  /// The widget is dismissed and `onButtonPressed` is called.
  _buttonPressed(MBInAppMessageButton button) async {
    timer?.cancel();
    Navigator.of(widget.mainContext).pop(false);
    await Future.delayed(Duration(milliseconds: 300));
    if (widget.onButtonPressed != null) {
      widget.onButtonPressed(button);
    }
  }

  /// The close button for this widget.
  Widget _closeButton() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TappableWidget(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: widget.theme.closeButtonBackgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Icon(
                Icons.close,
                color: widget.theme.closeButtonColor,
                size: 20,
              ),
            ),
            onTap: () => _closePressed(),
          ),
        ),
      ),
    );
  }

  /// Function called when close is pressed.
  _closePressed() async {
    timer?.cancel();
    Navigator.of(widget.mainContext).pop(true);
    await Future.delayed(Duration(milliseconds: 300));
  }
}
