import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_button_widget.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/messages/mbmessage.dart';

/// This widget is displayed as a banner coming from the top when the in app message has the style `MBInAppMessageStyle.topBanner`
class MBInAppMessageBannerTop extends StatefulWidget {
  /// The main context, used to dismiss the message correctly.
  final BuildContext mainContext;

  /// The message.
  final MBMessage message;

  /// Function called when the button is pressed.
  final Function(MBInAppMessageButton)? onButtonPressed;

  /// The theme to use for this message.
  final MBInAppMessageTheme theme;

  /// Initializes a `MBInAppMessageBannerTop` with the parameters passed
  const MBInAppMessageBannerTop({
    super.key,
    required this.mainContext,
    required this.message,
    required this.onButtonPressed,
    required this.theme,
  });

  @override
  State<MBInAppMessageBannerTop> createState() =>
      _MBInAppMessageBannerTopState();
}

class _MBInAppMessageBannerTopState extends State<MBInAppMessageBannerTop> {
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
    bool isBlockingMessage = inAppMessage?.isBlocking ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: MediaQuery.of(context).padding.top + 10),
        !isBlockingMessage
            ? Dismissible(
                direction: DismissDirection.up,
                key: const Key('mburger.mbmessages.bannerTop'),
                onDismissed: (_) => Navigator.of(context).pop(true),
                child: _MBInAppMessageBannerTopMainContentWidget(
                  mainContext: widget.mainContext,
                  inAppMessage: inAppMessage,
                  theme: widget.theme,
                  onButtonPressed: (button) => _buttonPressed(button),
                ),
              )
            : _MBInAppMessageBannerTopMainContentWidget(
                mainContext: widget.mainContext,
                inAppMessage: inAppMessage,
                theme: widget.theme,
                onButtonPressed: (button) => _buttonPressed(button),
              ),
      ],
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
}

class _MBInAppMessageBannerTopMainContentWidget extends StatelessWidget {
  final BuildContext mainContext;
  final MBInAppMessage? inAppMessage;
  final MBInAppMessageTheme theme;
  final Function(MBInAppMessageButton) onButtonPressed;

  const _MBInAppMessageBannerTopMainContentWidget({
    super.key,
    required this.mainContext,
    required this.inAppMessage,
    required this.theme,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color containerColor = theme.backgroundColor ?? Colors.white;
    if (inAppMessage != null) {
      if (inAppMessage!.backgroundColor != null) {
        containerColor = inAppMessage!.backgroundColor!;
      }
    }
    bool isBlockingMessage = inAppMessage?.isBlocking ?? false;
    return ConstrainedBox(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MBInAppMessageBannerTopImageWidget(
                  inAppMessage: inAppMessage,
                ),
                Flexible(
                    child: _MBInAppMessageBannerTopContentWidget(
                  inAppMessage: inAppMessage,
                  theme: theme,
                )),
              ],
            ),
            _MBInAppMessageBannerTopButtonsWidget(
              mainContext: mainContext,
              inAppMessage: inAppMessage,
              theme: theme,
              onButtonPressed: (button) => onButtonPressed(button),
            ),
            !isBlockingMessage
                ? _MBInAppMessageBannerTopHandleWidget()
                : Container(),
          ],
        ),
      ),
    );
  }
}

/// The image for the widget
class _MBInAppMessageBannerTopImageWidget extends StatelessWidget {
  final MBInAppMessage? inAppMessage;

  const _MBInAppMessageBannerTopImageWidget({
    super.key,
    required this.inAppMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (inAppMessage != null) {
      if (inAppMessage!.image != null && inAppMessage!.image != '') {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
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
    return const SizedBox.shrink();
  }
}

/// The main textual content of the widget.
class _MBInAppMessageBannerTopContentWidget extends StatelessWidget {
  final MBInAppMessage? inAppMessage;
  final MBInAppMessageTheme theme;

  const _MBInAppMessageBannerTopContentWidget({
    super.key,
    required this.inAppMessage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (this.inAppMessage == null) {
      return const SizedBox.shrink();
    }
    MBInAppMessage inAppMessage = this.inAppMessage!;
    bool hasImage = inAppMessage.image != null && inAppMessage.image != '';
    bool hasTitle = inAppMessage.title != null && inAppMessage.title != '';
    bool hasBody = inAppMessage.body != null && inAppMessage.body != '';
    TextStyle? titleStyle =
        theme.titleStyle ?? Theme.of(context).textTheme.displayMedium;
    if (inAppMessage.titleColor != null) {
      titleStyle = titleStyle?.copyWith(color: inAppMessage.titleColor);
    }
    TextStyle? bodyStyle =
        theme.bodyStyle ?? Theme.of(context).textTheme.bodyMedium;
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
class _MBInAppMessageBannerTopButtonsWidget extends StatelessWidget {
  final BuildContext mainContext;
  final MBInAppMessage? inAppMessage;
  final MBInAppMessageTheme theme;
  final Function(MBInAppMessageButton) onButtonPressed;

  const _MBInAppMessageBannerTopButtonsWidget({
    super.key,
    required this.mainContext,
    required this.inAppMessage,
    required this.theme,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (this.inAppMessage == null) {
      return const SizedBox.shrink();
    }
    MBInAppMessage inAppMessage = this.inAppMessage!;
    if (inAppMessage.buttons == null) {
      return const SizedBox.shrink();
    }

    List<MBInAppMessageButton> buttons = inAppMessage.buttons!;

    bool hasButtons = buttons.isNotEmpty;
    if (!hasButtons) {
      return const SizedBox.shrink();
    }
    const double buttonHeight = 30;
    bool has2Buttons = buttons.length == 2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 10, right: 10),
      child: SizedBox(
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
class _MBInAppMessageBannerTopHandleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Center(
        child: Container(
          width: 80,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}
