import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simulates device storage across new store/session instances, without secrets.
class SecureStorageTestDriver {
  static const tokenKey = 'auth.access_token.v1';
  static const _channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  final values = <String, String>{};
  final methods = <String>[];
  String? failingMethod;
  Completer<void>? writeCompletion;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          methods.add(call.method);
          if (call.method == failingMethod) {
            throw PlatformException(code: 'test_storage_unavailable');
          }
          final arguments = call.arguments as Map;
          final key = arguments['key'] as String;
          switch (call.method) {
            case 'read':
              return values[key];
            case 'write':
              await writeCompletion?.future;
              values[key] = arguments['value'] as String;
              return null;
            case 'delete':
              values.remove(key);
              return null;
            default:
              throw UnsupportedError(call.method);
          }
        });
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}
