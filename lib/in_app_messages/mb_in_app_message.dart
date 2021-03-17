import 'dart:convert';
import 'dart:ui';

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
  final int id;

  /// The style of the message
  final MBInAppMessageStyle style;

  /// The duration it will be on screen, after this duration the message will disappear automatically, by default it stays on screen until the user closes it
  final double duration;

  /// The title of the message, it's optional and defaults to `null`.
  final String? title;

  /// An optional color for the title, defaults to `null`.
  final Color? titleColor;

  /// The body of the message
  final String? body;

  /// An optional color for the body, defaults to `null`.
  final Color? bodyColor;

  /// An optional image of the message, defaults to `null`.
  final String? image;

  /// An optional background color, defaults to `null`.
  final Color? backgroundColor;

  /// An array of buttons, max 2 elements
  final List<MBInAppMessageButton>? buttons;

  /// Initializes a message with the parameters passed
  MBInAppMessage({
    required this.id,
    required this.style,
    required this.duration,
    required this.title,
    required this.titleColor,
    required this.body,
    required this.bodyColor,
    required this.image,
    required this.backgroundColor,
    required this.buttons,
  });

  /// Initializes a message with the dictionary returned by the APIs.
  factory MBInAppMessage.fromDictionary(Map<String, dynamic> dictionary) {
    int id = dictionary['id'] is int ? dictionary['id'] : 0;

    String? styleString = dictionary['type'];
    MBInAppMessageStyle style = _styleFromString(styleString);

    double duration = -1;
    if (dictionary['duration'] != null) {
      if (dictionary['duration'] is double) {
        duration = dictionary['duration'];
      } else if (dictionary['duration'] is int) {
        int intDuration = dictionary['duration'];
        duration = intDuration.toDouble();
      }
    }

    String? title = dictionary['title'] is String ? dictionary['title'] : null;
    Color? titleColor = _colorFromField(
      dictionary,
      'title_color',
    );

    String? body =
        dictionary['content'] is String ? dictionary['content'] : null;
    Color? bodyColor = _colorFromField(
      dictionary,
      'content_color',
    );

    Color? backgroundColor = _colorFromField(
      dictionary,
      'background_color',
    );

    String? image = dictionary['image'] is String ? dictionary['image'] : null;

    List<MBInAppMessageButton> buttons = [];
    String? button1Title =
        dictionary['cta_text'] is String ? dictionary['cta_text'] : null;
    String? button1TitleColor = dictionary['cta_text_color'] is String
        ? dictionary['cta_text_color']
        : null;
    String? button1BackgroundColor =
        dictionary['cta_background_color'] is String
            ? dictionary['cta_background_color']
            : null;
    String? button1Link =
        dictionary['cta_action'] is String ? dictionary['cta_action'] : null;
    String? button1LinkType = dictionary['cta_action_type'] is String
        ? dictionary['cta_action_type']
        : null;
    if (button1Title != null && button1LinkType != null) {
      int? sectionId;
      int? blockId;
      if (button1LinkType == 'section') {
        Map<String, dynamic>? actionMap =
            _extractSectionAndBlockId(button1Link);
        sectionId = actionMap?['sectionId'];
        blockId = actionMap?['blockId'];
      }
      buttons.add(
        MBInAppMessageButton(
          title: button1Title,
          titleColor: _colorFromHexString(button1TitleColor),
          backgroundColor: _colorFromHexString(button1BackgroundColor),
          link: button1Link,
          sectionId: sectionId,
          blockId: blockId,
          linkTypeString: button1LinkType,
        ),
      );
    }
    String? button2Title =
        dictionary['cta2_text'] is String ? dictionary['cta2_text'] : null;
    String? button2TitleColor = dictionary['cta2_text_color'] is String
        ? dictionary['cta2_text_color']
        : null;
    String? button2BackgroundColor =
        dictionary['cta2_background_color'] is String
            ? dictionary['cta2_background_color']
            : null;
    String? button2Link =
        dictionary['cta2_action'] is String ? dictionary['cta2_action'] : null;
    String? button2LinkType = dictionary['cta2_action_type'] is String
        ? dictionary['cta2_action_type']
        : null;
    if (button2Title != null && button2LinkType != null) {
      int? sectionId;
      int? blockId;
      if (button2LinkType == 'section') {
        Map<String, dynamic>? actionMap =
            _extractSectionAndBlockId(button1Link);
        sectionId = actionMap?['sectionId'];
        blockId = actionMap?['blockId'];
      }
      buttons.add(
        MBInAppMessageButton(
          title: button2Title,
          titleColor: _colorFromHexString(button2TitleColor),
          backgroundColor: _colorFromHexString(button2BackgroundColor),
          link: button2Link,
          sectionId: sectionId,
          blockId: blockId,
          linkTypeString: button2LinkType,
        ),
      );
    }

    return MBInAppMessage(
      id: id,
      style: style,
      duration: duration,
      title: title,
      titleColor: titleColor,
      body: body,
      bodyColor: bodyColor,
      image: image,
      backgroundColor: backgroundColor,
      buttons: buttons,
    );
  }

  /// Extracts the section id and the block id from a string value of the action
  static Map<String, int>? _extractSectionAndBlockId(String? value) {
    if (value != null) {
      int? sectionId = int.tryParse(value);
      if (sectionId != null) {
        return {'sectionId': sectionId};
      } else {
        try {
          Map<String, dynamic> jsonMap = json.decode(value);
          int sectionId = jsonMap['section_id'];
          int blockId = jsonMap['block_id'];
          return {
            'sectionId': sectionId,
            'blockId': blockId,
          };
        } catch (e) {}
      }
    }
    return null;
  }

  /// Converts a string to a `MBInAppMessageStyle`.
  /// @param styleString The string to convert.
  static MBInAppMessageStyle _styleFromString(String? styleString) {
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
  static Color? _colorFromField(
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
  static Color? _colorFromHexString(String? hexString) {
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
