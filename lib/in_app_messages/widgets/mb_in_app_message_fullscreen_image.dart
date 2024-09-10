import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_button_widget.dart';
import 'package:mbmessages/in_app_messages/widgets/mb_in_app_message_theme.dart';
import 'package:mbmessages/src/widgets/tappable_widget.dart';
import 'package:mbmessages/messages/mbmessage.dart';

/// This widget is displayed in the middle of the screen, coming from the bottom (as a modal view) when the in app message has the style `MBInAppMessageStyle.fullscreenImage`.
/// This widget has only a big image as the background, the close button, and the actions button as the bottom. It's useful if the content to displayed is just a big visual image.
class MBInAppMessageFullscreenImage extends StatefulWidget {
  /// The main context, used to dismiss the message correctly
  final BuildContext mainContext;

  /// The message.
  final MBMessage message;

  /// The file where the image has been downloaded.
  final File? imageFile;

  /// Function called when the button is pressed.
  final Function(MBInAppMessageButton)? onButtonPressed;

  /// The theme to use for this message.
  final MBInAppMessageTheme theme;

  /// Initializes a `MBInAppMessageFullscreenImage` with the parameters passed
  const MBInAppMessageFullscreenImage({
    super.key,
    required this.mainContext,
    required this.message,
    required this.imageFile,
    required this.onButtonPressed,
    required this.theme,
  });

  @override
  State<MBInAppMessageFullscreenImage> createState() =>
      _MBInAppMessageFullscreenImageState();
}

class _MBInAppMessageFullscreenImageState
    extends State<MBInAppMessageFullscreenImage> {
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
            children: [
              _MBInAppMessageFullscreenImageImageWidget(
                imageFile: widget.imageFile,
              ),
              _MBInAppMessageFullscreenImageButtonsWidget(
                mainContext: widget.mainContext,
                inAppMessage: inAppMessage,
                theme: widget.theme,
                onButtonPressed: (button) => _buttonPressed(button),
              ),
              !isBlockingMessage
                  ? _MBInAppMessageFullscreenImageCloseWidget(
                      theme: widget.theme,
                      onTap: () => _closePressed(),
                    )
                  : const SizedBox(width: 0, height: 0),
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
    bool isBlockerMessage = inAppMessage?.isBlocking ?? false;
    if (!isBlockerMessage) {
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
class _MBInAppMessageFullscreenImageImageWidget extends StatelessWidget {
  final File? imageFile;

  const _MBInAppMessageFullscreenImageImageWidget({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox.shrink();
  }
}

/// The buttons of the widget.
class _MBInAppMessageFullscreenImageButtonsWidget extends StatelessWidget {
  final BuildContext mainContext;
  final MBInAppMessage? inAppMessage;
  final MBInAppMessageTheme theme;
  final Function(MBInAppMessageButton) onButtonPressed;

  const _MBInAppMessageFullscreenImageButtonsWidget({
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
    const double buttonHeight = 44;
    bool has2Buttons = buttons.length == 2;
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
          ),
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
        ),
      ),
    );
  }
}

/// The close button for this widget.
class _MBInAppMessageFullscreenImageCloseWidget extends StatelessWidget {
  final MBInAppMessageTheme theme;
  final VoidCallback onTap;

  const _MBInAppMessageFullscreenImageCloseWidget({
    super.key,
    required this.theme,
    required this.onTap,
  });

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
