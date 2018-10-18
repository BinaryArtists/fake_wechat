import 'dart:async';

import 'package:flutter/services.dart';

class FakeWechat {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/fake_wechat');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
