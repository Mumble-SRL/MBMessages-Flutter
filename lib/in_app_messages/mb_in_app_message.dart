import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';

/// The presentation style of the message, this enum represents the style in which the message will appear
enum MBInAppMessageStyle {
  /// Messages with this style will appear as a banner from the top
  bannerTop,
  /// Messages with this style will appear as a banner from the bottom
  bannerBottom,
  /// Messages with this style will appear as a center message
  center,
  /// Messages with this style will appear as fullscreen images
  fullscreenImage,
}

/// This class represents an in app message retrieved by the MBurger in app messages APIs
class MBInAppMessage {
  /// The id of the message
  int id;

  /// The style of the message
  MBInAppMessageStyle style;

  /// The duration it will be on screen, after this duration the message will disappear automatically, the default is 5 seconds
  double duration;

  /// The title of the message, it's optional and defaults to `null`.
  String title;

  /// An optional color for the title, defaults to `null`.
  Color titleColor;

  /// The body of the message
  String body;

  /// An optional color for the body, defaults to `null`.
  Color bodyColor;

  /// An optional image of the message, defaults to `null`.
  String image;

  /// An optional background color, defaults to `null`.
  Color backgroundColor;

  /// An array of buttons, max 2 elements
  List<MBInAppMessageButton> buttons;

  /// Initializes a message with the parameters passed
  MBInAppMessage({
    @required this.id,
    @required this.style,
    @required this.duration,
    @required this.title,
    @required this.titleColor,
    @required this.body,
    @required this.bodyColor,
    @required this.image,
    @required this.backgroundColor,
    @required this.buttons,
  });

  /// Initializes a message with the dictionary returned by the APIs.
  MBInAppMessage.fromDictionary(Map<String, dynamic> dictionary) {
    id = dictionary['id'];

    String styleString = dictionary['type'];
    style = _styleFromString(styleString);

    if (dictionary['duration'] != null) {
      duration = dictionary['duration'];
    } else {
      duration = 5;
    }

    title = dictionary['title'];
    titleColor = _colorFromField(
      dictionary,
      'title_color',
    );

    body = dictionary['content'];
    bodyColor = _colorFromField(
      dictionary,
      'content_color',
    );

    backgroundColor = _colorFromField(
      dictionary,
      'background_color',
    );

    image = dictionary['image'];

    buttons = [];
    String button1Title = dictionary['cta_text'];
    String button1TitleColor = dictionary['cta_text_color'];
    String button1BackgroundColor = dictionary['cta_background_color'];
    String button1Link = dictionary['cta_action'];
    String button1LinkType = dictionary['cta_action_type'];
    if (button1Title != null &&
        button1Link != null &&
        button1LinkType != null) {
      buttons.add(
        MBInAppMessageButton(
          title: button1Title,
          titleColor: _colorFromHexString(button1TitleColor),
          backgroundColor: _colorFromHexString(button1BackgroundColor),
          link: button1Link,
          linkTypeString: button1LinkType,
        ),
      );
    }
    String button2Title = dictionary['cta2_text'];
    String button2TitleColor = dictionary['cta2_text_color'];
    String button2BackgroundColor = dictionary['cta2_background_color'];
    String button2Link = dictionary['cta2_action'];
    String button2LinkType = dictionary['cta2_action_type'];
    if (button2Title != null &&
        button2Link != null &&
        button2LinkType != null) {
      buttons.add(
        MBInAppMessageButton(
          title: button2Title,
          titleColor: _colorFromHexString(button2TitleColor),
          backgroundColor: _colorFromHexString(button2BackgroundColor),
          link: button2Link,
          linkTypeString: button2LinkType,
        ),
      );
    }
  }

  /// Converts a string to a `MBInAppMessageStyle`.
  /// @param styleString The string to convert.
  MBInAppMessageStyle _styleFromString(String styleString) {
    if (styleString == 'banner_top') {
      return MBInAppMessageStyle.bannerTop;
    } else if (styleString == 'banner_bottom') {
      return MBInAppMessageStyle.bannerBottom;
    } else if (styleString == 'center') {
      return MBInAppMessageStyle.center;
    } else if (styleString == 'fullscreen_image') {
      return MBInAppMessageStyle.fullscreenImage;
    }
    return MBInAppMessageStyle.center;
  }

  /// Extract a `Color` from the object of the dictionary with the specified key.
  /// @param dictionary The dictionary.
  /// @param key The key.
  Color _colorFromField(
    Map<String, dynamic> dictionary,
    String key,
  ) {
    if (dictionary[key] != null) {
      if (dictionary[key] is String) {
        String value = dictionary[key];
        return _colorFromHexString(value);
      }
    }
    return null;
  }

  /// Converts an hex string to a Color object.
  /// @param hexString The string to convert.
  Color _colorFromHexString(String hexString) {
    if (hexString == null) {
      return null;
    }
    if (hexString.length < 6) {
      return null;
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
