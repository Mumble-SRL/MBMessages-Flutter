import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_button_widget.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/in_app_messages/widgets/tappable_widget.dart';
import 'package:mbmessages/messages/mbmessage.dart';

/// This widget is displayed in the middle of the screen, coming from the bottom (as a modal view) when the in app message has the style `MBInAppMessageStyle.fullscreenImage`.
/// This widget has only a big image as the background, the close button, and the actions button as the bottom. It's useful if the content to displayed is just a big visual image.
class MBInAppMessageFullscreenImage extends StatefulWidget {
  /// The main context, used to dismiss the message correctly
  final BuildContext mainContext;

  /// The message.
  final MBMessage message;

  /// The file where the image has been downloaded.
  final File imageFile;

  /// Function called when the button is pressed.
  final Function(MBInAppMessageButton) onButtonPressed;

  /// The theme to use for this message.
  final MBInAppMessageTheme theme;

  /// Initializes a `MBInAppMessageFullscreenImage` with the parameters passed
  const MBInAppMessageFullscreenImage({
    Key key,
    @required this.mainContext,
    @required this.message,
    @required this.imageFile,
    @required this.onButtonPressed,
    @required this.theme,
  });

  @override
  _MBInAppMessageFullscreenImageState createState() =>
      _MBInAppMessageFullscreenImageState();
}

class _MBInAppMessageFullscreenImageState
    extends State<MBInAppMessageFullscreenImage> {
  /// Returns the in-app message of this message
  MBInAppMessage get inAppMessage => widget.message.inAppMessage;

  /// Timer used to dismiss the message after the defined duration is passed.
  Timer timer;

  @override
  void initState() {
    timer = Timer(Duration(seconds: inAppMessage.duration.toInt()), () {
      timer.cancel();
      Navigator.of(widget.mainContext).pop(true);
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
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
            children: [
              _image(),
              _buttons(),
              _closeButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// The image for the widget.
  Widget _image() {
    if (inAppMessage.image != null && inAppMessage.image != '') {
      print(widget.imageFile);
      return Image.file(
        widget.imageFile,
        fit: BoxFit.cover,
      );
    }
    return Container();
  }

  /// The buttons of the widget.
  Widget _buttons() {
    bool hasButtons = inAppMessage.buttons?.length != 0;
    if (!hasButtons) {
      return Container();
    }
    const double buttonHeight = 44;
    bool has2Buttons = inAppMessage.buttons.length == 2;
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
          ),
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
                Container(width: has2Buttons ? 10 : 0),
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
        ),
      ),
    );
  }

  /// Function called when a button is pressed.
  /// The widget is dismissed and `onButtonPressed` is called.
  _buttonPressed(MBInAppMessageButton button) async {
    timer.cancel();
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
    timer.cancel();
    Navigator.of(widget.mainContext).pop(true);
    await Future.delayed(Duration(milliseconds: 300));
  }
}
