import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/src/widgets/tappable_widget.dart';
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
  final Function(MBInAppMessageButton)? onButtonPressed;

  /// The theme to use for this message.
  final MBInAppMessageTheme theme;

  /// Initializes a `MBInAppMessageCenter` with the parameters passed
  const MBInAppMessageCenter({
    Key? key,
    required this.mainContext,
    required this.message,
    required this.onButtonPressed,
    required this.theme,
  }) : super(key: key);

  @override
  State<MBInAppMessageCenter> createState() => _MBInAppMessageCenterState();
}

class _MBInAppMessageCenterState extends State<MBInAppMessageCenter> {
  /// Returns the in-app message of this message
  MBInAppMessage? get inAppMessage => widget.message.inAppMessage;

  /// Timer used to dismiss the message after the defined duration is passed.
  Timer? timer;

  @override
  void initState() {
    MBInAppMessage? inAppMessage = this.inAppMessage;
    if (inAppMessage != null) {
      if (inAppMessage.duration != -1 && !inAppMessage.isBlocking) {
        timer = Timer(Duration(seconds: inAppMessage.duration.toInt()), () {
          timer?.cancel();
          Navigator.of(widget.mainContext).pop(true);
        });
      }
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
    Color containerColor = widget.theme.backgroundColor ?? Colors.white;
    if (inAppMessage != null) {
      if (inAppMessage!.backgroundColor != null) {
        containerColor = inAppMessage!.backgroundColor!;
      }
    }
    bool isBlockingMessage = inAppMessage?.isBlocking ?? false;
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
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(162, 162, 162, 0.37),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.loose,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MBInAppMessageCenterImageWidget(
                      inAppMessage: inAppMessage,
                    ),
                    Flexible(
                      child: _MBInAppMessageCenterContentWidget(
                        inAppMessage: inAppMessage,
                        theme: widget.theme,
                      ),
                    ),
                    _MBInAppMessageCenterButtonsWidget(
                      mainContext: widget.mainContext,
                      inAppMessage: inAppMessage,
                      theme: widget.theme,
                      onButtonPressed: (button) => _buttonPressed(button),
                    ),
                  ],
                ),
              ),
              !isBlockingMessage
                  ? _MBInAppMessageCenterCloseWidget(
                      theme: widget.theme,
                      onTap: () => _closePressed(),
                    )
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Function called when a button is pressed.
  /// The widget is dismissed and `onButtonPressed` is called.
  _buttonPressed(MBInAppMessageButton button) async {
    timer?.cancel();
    bool isBlockingMessage = inAppMessage?.isBlocking ?? false;
    if (!isBlockingMessage) {
      Navigator.of(widget.mainContext).pop(false);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (widget.onButtonPressed != null) {
      widget.onButtonPressed!(button);
    }
  }

  /// Function called when close is pressed.
  _closePressed() async {
    timer?.cancel();
    Navigator.of(widget.mainContext).pop(true);
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// The image for the widget.
class _MBInAppMessageCenterImageWidget extends StatelessWidget {
  final MBInAppMessage? inAppMessage;

  const _MBInAppMessageCenterImageWidget({
    Key? key,
    required this.inAppMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (inAppMessage != null) {
      if (inAppMessage!.image != null && inAppMessage!.image != '') {
        const double imageHeight = 175.0;
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: imageHeight,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 10 * 2,
            ),
            child: Image.network(
              inAppMessage!.image!,
              fit: BoxFit.contain,
            ),
          ),
        );
      }
    }
    return Container();
  }
}

/// The main textual content of the widget.
class _MBInAppMessageCenterContentWidget extends StatelessWidget {
  final MBInAppMessage? inAppMessage;
  final MBInAppMessageTheme theme;

  const _MBInAppMessageCenterContentWidget({
    Key? key,
    required this.inAppMessage,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.inAppMessage == null) {
      return Container();
    }
    MBInAppMessage inAppMessage = this.inAppMessage!;
    bool hasTitle = inAppMessage.title != null && inAppMessage.title != '';
    bool hasBody = inAppMessage.body != null && inAppMessage.body != '';
    TextStyle? titleStyle = theme.titleStyle;
    if (inAppMessage.titleColor != null) {
      titleStyle = titleStyle?.copyWith(color: inAppMessage.titleColor);
    }
    TextStyle? bodyStyle = theme.bodyStyle;
    if (inAppMessage.bodyColor != null) {
      bodyStyle = bodyStyle?.copyWith(color: inAppMessage.bodyColor);
    }
    return Padding(
      padding: const EdgeInsets.only(
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
                  inAppMessage.title ?? '',
                  style: titleStyle,
                )
              : Container(),
          Container(height: hasTitle && hasBody ? 20 : 0),
          hasBody
              ? Text(
                  inAppMessage.body ?? '',
                  style: bodyStyle,
                )
              : Container(),
        ],
      ),
    );
  }
}

/// The buttons of the widget.
class _MBInAppMessageCenterButtonsWidget extends StatelessWidget {
  final BuildContext mainContext;
  final MBInAppMessage? inAppMessage;
  final MBInAppMessageTheme theme;
  final Function(MBInAppMessageButton) onButtonPressed;

  const _MBInAppMessageCenterButtonsWidget({
    Key? key,
    required this.mainContext,
    required this.inAppMessage,
    required this.theme,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.inAppMessage == null) {
      return Container();
    }
    MBInAppMessage inAppMessage = this.inAppMessage!;
    if (inAppMessage.buttons == null) {
      return Container();
    }

    List<MBInAppMessageButton> buttons = inAppMessage.buttons!;

    bool hasButtons = buttons.isNotEmpty;
    if (!hasButtons) {
      return Container();
    }
    const double buttonHeight = 44;
    bool has2Buttons = buttons.length == 2;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        height: has2Buttons ? buttonHeight * 2 + 10 : buttonHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MBInAppMessageButtonWidget(
                mainContext: mainContext,
                button: buttons[0],
                height: buttonHeight,
                onTap: () => onButtonPressed(buttons[0]),
                theme: theme,
                isButton1: true,
              ),
            ),
            Container(height: has2Buttons ? 10 : 0),
            has2Buttons
                ? Expanded(
                    child: MBInAppMessageButtonWidget(
                      mainContext: mainContext,
                      button: buttons[1],
                      height: buttonHeight,
                      onTap: () => onButtonPressed(buttons[1]),
                      theme: theme,
                      isButton1: false,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

/// The close button for this widget.
class _MBInAppMessageCenterCloseWidget extends StatelessWidget {
  final MBInAppMessageTheme theme;
  final VoidCallback onTap;

  const _MBInAppMessageCenterCloseWidget({
    Key? key,
    required this.theme,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                color: theme.closeButtonBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Icon(
                Icons.close,
                color: theme.closeButtonColor,
                size: 20,
              ),
            ),
            onTap: () => onTap(),
          ),
        ),
      ),
    );
  }
}
