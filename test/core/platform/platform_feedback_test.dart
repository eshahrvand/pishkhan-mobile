import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/platform/external_links.dart';
import 'package:pishkhan_mobile/core/platform/platform_share.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final operation in [
    (
      channel: 'pishkhan/platform_share',
      method: 'shareText',
      arguments: 'receipt',
      invoke: () => PlatformShare.shareText('receipt'),
      failureCode: 'platform.share.unavailable',
    ),
    (
      channel: 'pishkhan/external_links',
      method: 'openRegistry',
      arguments: null,
      invoke: ExternalLinks.openRegistry,
      failureCode: 'platform.browser.unavailable',
    ),
  ]) {
    final channel = MethodChannel(operation.channel);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test(
      '${operation.method} returns success and preserves platform payload',
      () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          expect(call.method, operation.method);
          expect(call.arguments, operation.arguments);
          return null;
        });
        expect(await operation.invoke(), isA<Success<void>>());
      },
    );

    test(
      '${operation.method} returns platform failure for Cubit interpretation',
      () async {
        messenger.setMockMethodCallHandler(channel, (_) async {
          throw PlatformException(code: 'unavailable');
        });
        final result = await operation.invoke();
        expect(result, isA<Err<void>>());
        expect((result as Err<void>).failure.code, operation.failureCode);
      },
    );

    test(
      '${operation.method} returns missing-plugin failure for Cubit interpretation',
      () async {
        messenger.setMockMethodCallHandler(channel, null);
        final result = await operation.invoke();
        expect(result, isA<Err<void>>());
        expect((result as Err<void>).failure.code, operation.failureCode);
      },
    );
  }
}
