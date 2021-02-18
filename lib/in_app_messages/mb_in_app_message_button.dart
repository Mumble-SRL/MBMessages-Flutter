import 'dart:ui';
import 'package:flutter/foundation.dart';

/// This class represents the type of link attttached to a button
enum MBInAppMessageButtonLinkType {
  /// A web link
  link,

  /// An in app link
  inApp,

  /// An MBurger section
  section,

  /// No action
  noAction,
}

/// This class represent a button of an in app message
class MBInAppMessageButton {
  /// The title of the button
  String title;

  /// An optional color for the title
  Color titleColor;

  /// An optional background color
  Color backgroundColor;

  /// The link of the button
  String link;

  /// If the link type is `MBInAppMessageButtonLinkType.section`, the id of the MBurger section
  int sectionId;

  /// If the link type is `MBInAppMessageButtonLinkType.section`, the id of the MBurger block of the section
  int blockId;

  /// The type of link of the button
  MBInAppMessageButtonLinkType linkType;

  /// Initializes a button with the parameters passed
  MBInAppMessageButton({
    @required this.title,
    @required this.titleColor,
    @required this.backgroundColor,
    @required this.link,
    @required this.blockId,
    @required this.sectionId,
    @required String linkTypeString,
  }) {
    this.linkType = _linkTypeFromString(linkTypeString);
  }

  /// Converts a string to a `MBInAppMessageButtonLinkType`
  /// @param linkTypeString The string to convert.
  MBInAppMessageButtonLinkType _linkTypeFromString(String linkTypeString) {
    if (linkTypeString == 'link') {
      return MBInAppMessageButtonLinkType.link;
    } else if (linkTypeString == 'in_app' || linkTypeString == 'inapp') {
      return MBInAppMessageButtonLinkType.inApp;
    } else if (linkTypeString == 'section') {
      return MBInAppMessageButtonLinkType.section;
    } else if (linkTypeString == 'no-action') {
      return MBInAppMessageButtonLinkType.noAction;
    }
    return MBInAppMessageButtonLinkType.noAction;
  }
}
