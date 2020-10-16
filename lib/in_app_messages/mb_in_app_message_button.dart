import 'dart:ui';

import 'package:flutter/cupertino.dart';

enum MBInAppMessageButtonLinkType {
  link,
  inApp,
}

class MBInAppMessageButton {
  String title;
  Color titleColor;
  Color backgroundColor;
  String link;
  MBInAppMessageButtonLinkType linkType;

  MBInAppMessageButton({
    @required this.title,
    @required this.titleColor,
    @required this.backgroundColor,
    @required this.link,
    @required String linkTypeString,
  }) {
    this.linkType = _linkTypeFromString(linkTypeString);
  }

  MBInAppMessageButtonLinkType _linkTypeFromString(String linkTypeString) {
    if (linkTypeString == 'link') {
      return MBInAppMessageButtonLinkType.link;
    } else if (linkTypeString == 'in_app') {
      return MBInAppMessageButtonLinkType.inApp;
    }
    return MBInAppMessageButtonLinkType.link;
  }
}
