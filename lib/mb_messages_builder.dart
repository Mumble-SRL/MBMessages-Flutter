import 'package:flutter/widgets.dart';

import 'package:mbmessages/mbmessages.dart';

/// A Widget that let's you show in-app messages.
/// To present in-app messages `MBMessages` uses the `showDialog` function that needs a `BuildContext`.
/// Wrap your main widget in a MBMessagesBuilder to provide a `BuildContext` automatically to `MBMessages`.
/// @override
/// Widget build(BuildContext context) {
///   return MaterialApp(
///     home: MBMessagesBuilder(
///       child: ...,
///     ),
///   );
///  }
class MBMessagesBuilder extends StatelessWidget {
  /// The child of the message builder
  final Widget child;

  /// Initializes a message builder with a child
  /// @param child The child of the message builder.
  const MBMessagesBuilder({
    Key key,
    @required this.child,
  }) : super(key: key);

  /// Returns the child and sets the correct context in MBmessages.
  @override
  Widget build(BuildContext context) {
    MBMessages.contextCallback = () => context;
    return child;
  }
}
