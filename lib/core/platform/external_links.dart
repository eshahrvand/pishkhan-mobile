import 'package:flutter/services.dart';

/// Opens the official registry in the device browser, never inside the bank UI.
abstract final class ExternalLinks {
  static const _channel = MethodChannel('pishkhan/external_links');
  static Future<void> openRegistry() =>
      _channel.invokeMethod<void>('openRegistry');
}
