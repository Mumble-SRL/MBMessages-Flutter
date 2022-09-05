import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Messages plugin to interact with native app.
class MBMessagesPlugin {
  /// Function that needs to be called when the app enters foreground.
  static VoidCallback? onAppEnterForeground;

  /// The method channel to interact with native code.
  static const MethodChannel _channel = MethodChannel('mbmessages');

  /// If method call has been initialized or not
  static bool _methodCallInitialized = false;

  /// Initialize the callbacks from the native side to dart.
  /// @param onAppEnterForeground Function that needs to be called when the app enters foreground.
  static Future<void> initializeMethodCall({
    required VoidCallback? onAppEnterForeground,
  }) async {
    if (!_methodCallInitialized) {
      _methodCallInitialized = true;
      _channel.setMethodCallHandler(_mbmessagesHandler);
      MBMessagesPlugin.onAppEnterForeground = onAppEnterForeground;
    }
  }

  //region method call handler
  /// The handler of the native call from native to Flutter/dart.
  static Future<dynamic> _mbmessagesHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'applicationWillEnterForeground':
        if (MBMessagesPlugin.onAppEnterForeground != null) {
          MBMessagesPlugin.onAppEnterForeground!();
        }
        break;
      default:
        debugPrint('${methodCall.method} not implemented');
        return;
    }
  }
}
