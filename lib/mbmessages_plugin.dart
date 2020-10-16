import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class MBMessagesPlugin {
  static VoidCallback onAppEnterForeground;

  static const MethodChannel _channel = const MethodChannel('mbmessages');

  /// If method call has been initialized or not
  static bool _methodCallInitialized = false;

  /// Initialize the callbacks from the native side to dart
  static Future<void> initializeMethodCall(
      {@required VoidCallback onAppEnterForeground}) async {
    if (!_methodCallInitialized) {
      _methodCallInitialized = true;
      _channel.setMethodCallHandler(_mbmessagesHandler);
      MBMessagesPlugin.onAppEnterForeground = onAppEnterForeground;
    }
  }

  //region method call handler
  static Future<dynamic> _mbmessagesHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'applicationWillEnterForeground':
        if (MBMessagesPlugin.onAppEnterForeground != null) {
          MBMessagesPlugin.onAppEnterForeground();
        }
        break;
      default:
        print('${methodCall.method} not implemented');
        return;
    }
  }
}
