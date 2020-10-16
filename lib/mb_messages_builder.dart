import 'package:flutter/cupertino.dart';

import 'mbmessages.dart';

class MBMessagesBuilder extends StatelessWidget {
  final Widget child;

  const MBMessagesBuilder({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MBMessages.contextCallback = () => context;
    return child;
  }
}
