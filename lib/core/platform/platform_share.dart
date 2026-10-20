import 'package:flutter/services.dart';

/// Opens the platform share sheet; it never sends content automatically.
abstract final class PlatformShare {
  static const _channel = MethodChannel('pishkhan/platform_share');
  static Future<void> shareText(String text) =>
      _channel.invokeMethod<void>('shareText', text);
}
