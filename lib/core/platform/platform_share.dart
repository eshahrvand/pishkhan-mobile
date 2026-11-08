import 'package:flutter/services.dart';

import '../result/failure.dart';
import '../result/result.dart';

/// Opens the platform share sheet; it never sends content automatically.
abstract final class PlatformShare {
  static const _channel = MethodChannel('pishkhan/platform_share');
  static Future<Result<void>> shareText(String text) async {
    try {
      await _channel.invokeMethod<void>('shareText', text);
      return const Success(null);
    } on PlatformException {
      return const Err(DataFailure('platform.share.unavailable'));
    } on MissingPluginException {
      return const Err(DataFailure('platform.share.unavailable'));
    }
  }
}
