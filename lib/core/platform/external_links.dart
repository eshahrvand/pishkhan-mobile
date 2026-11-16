import 'package:flutter/services.dart';

import '../result/failure.dart';
import '../result/result.dart';

/// Opens the official registry in the device browser, never inside the bank UI.
abstract final class ExternalLinks {
  static const _channel = MethodChannel('pishkhan/external_links');
  static Future<Result<void>> openRegistry() async {
    try {
      await _channel.invokeMethod<void>('openRegistry');
      return const Success(null);
    } on PlatformException {
      return const Err(DataFailure('platform.browser.unavailable'));
    } on MissingPluginException {
      return const Err(DataFailure('platform.browser.unavailable'));
    }
  }
}
