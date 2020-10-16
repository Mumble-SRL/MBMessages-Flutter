import 'dart:ui';

import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';

enum MBInAppMessageStyle {
  bannerTop,
  bannerBottom,
  center,
  fullscreenImage,
}

class MBInAppMessage {
  int id;

  MBInAppMessageStyle style;

  double duration;

  String title;

  Color titleColor;

  String body;

  Color bodyColor;

  String image;

  Color backgroundColor;

  List<MBInAppMessageButton> buttons;

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

  Color _colorFromHexString(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
