import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_button_widget.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/messages/mbmessage.dart';

/// This widget is displayed as a banner coming from the bottom when the in app message has the style `MBInAppMessageStyle.bottomBanner`
class MBInAppMessageBannerBottom extends StatefulWidget {
  /// The main context, used to dismiss the message correctly.
  final BuildContext mainContext;

  /// The message.
  final MBMessage message;

  /// Function called when the button is pressed.
  final Function(MBInAppMessageButton)? onButtonPressed;

  /// The theme to use for this message.
  final MBInAppMessageTheme theme;

  /// Initializes a `MBInAppMessageBannerBottom` with the parameters passed
  const MBInAppMessageBannerBottom({
    Key? key,
    required this.mainContext,
    required this.message,
    required this.onButtonPressed,
    required this.theme,
  });

  @override
  _MBInAppMessageBannerBottomState createState() =>
      _MBInAppMessageBannerBottomState();
}

class _MBInAppMessageBannerBottomState
    extends State<MBInAppMessageBannerBottom> {
  /// Returns the in-app message of this message
  MBInAppMessage? get inAppMessage => widget.message.inAppMessage;

  /// Timer used to dismiss the message after the defined duration is passed.
  Timer? timer;

  @override
  void initState() {
    MBInAppMessage? inAppMessage = this.inAppMessage;
    if (inAppMessage != null) {
      if (inAppMessage.duration != -1) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: Container()),
        Dismissible(
          direction: DismissDirection.down,
          key: const Key('mburger.mbmessages.bannerBottom'),
          onDismissed: (_) => Navigator.of(context).pop(true),
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
              child: Column(
                children: [
                  _MBInAppMessageBannerBottomHandleWidget(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MBInAppMessageBannerBottomImageWidget(
                        inAppMessage: inAppMessage,
                      ),
                      Flexible(
                        child: _MBInAppMessageBannerBottomContentWidget(
                          inAppMessage: inAppMessage,
                          theme: widget.theme,
                        ),
                      ),
                    ],
                  ),
                  _MBInAppMessageBannerBottomButtonsWidget(
                    mainContext: widget.mainContext,
                    inAppMessage: inAppMessage,
                    theme: widget.theme,
                    onButtonPressed: (button) => _buttonPressed(button),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(height: MediaQuery.of(context).padding.bottom + 10),
      ],
    );
  }

  /// Function called when a button is pressed.
  /// The widget is dismissed and `onButtonPressed` is called.
  _buttonPressed(MBInAppMessageButton button) async {
    timer?.cancel();
    Navigator.of(widget.mainContext).pop(false);
    await Future.delayed(Duration(milliseconds: 300));
    if (widget.onButtonPressed != null) {
      widget.onButtonPressed!(button);
    }
  }
}

/// The image for the widget.
class _MBInAppMessageBannerBottomImageWidget extends StatelessWidget {
  final MBInAppMessage? inAppMessage;

  const _MBInAppMessageBannerBottomImageWidget({
    Key? key,
    required this.inAppMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (inAppMessage != null) {
      if (inAppMessage!.image != null && inAppMessage!.image != '') {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: 80,
            height: 80,
            child: Image.network(
              inAppMessage!.image!,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }
    return Container();
  }
}

/// The main textual content of the widget.
class _MBInAppMessageBannerBottomContentWidget extends StatelessWidget {
  final MBInAppMessage? inAppMessage;
  final MBInAppMessageTheme theme;

  const _MBInAppMessageBannerBottomContentWidget({
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
    bool hasImage = inAppMessage.image != null && inAppMessage.image != '';
    bool hasTitle = inAppMessage.title != null && inAppMessage.title != '';
    bool hasBody = inAppMessage.body != null && inAppMessage.body != '';
    TextStyle? titleStyle =
        theme.titleStyle ?? Theme.of(context).textTheme.headline2;
    if (inAppMessage.titleColor != null) {
      titleStyle = titleStyle?.copyWith(color: inAppMessage.titleColor);
    }
    TextStyle? bodyStyle =
        theme.bodyStyle ?? Theme.of(context).textTheme.bodyText2;
    if (inAppMessage.bodyColor != null) {
      bodyStyle = bodyStyle?.copyWith(color: inAppMessage.bodyColor);
    }
    return Padding(
      padding: EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: hasImage ? 0 : 10,
        right: 10.0,
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
          Container(height: hasTitle && hasBody ? 10 : 0),
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
class _MBInAppMessageBannerBottomButtonsWidget extends StatelessWidget {
  final BuildContext mainContext;
  final MBInAppMessage? inAppMessage;
  final MBInAppMessageTheme theme;
  final Function(MBInAppMessageButton) onButtonPressed;

  const _MBInAppMessageBannerBottomButtonsWidget({
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

    bool hasButtons = buttons.length != 0;
    if (!hasButtons) {
      return Container();
    }

    const double buttonHeight = 30;
    bool has2Buttons = buttons.length == 2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 10, right: 10),
      child: Container(
        height: buttonHeight,
        child: Row(
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
            Container(width: has2Buttons ? 10 : 0),
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

/// The handle positioned at the top to indicate that the user can dismiss interactively this widget.
class _MBInAppMessageBannerBottomHandleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: Container(
          width: 80,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}
